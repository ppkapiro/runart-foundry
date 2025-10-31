#!/usr/bin/env node
import process from "node:process";
import { join } from "node:path";
import { ensureDir, writeText, buildRequest, normaliseBaseURL, doFetch, pickHeaders, getTimestamp } from "./lib/http.js";
import { getProjectPaths } from "../config/miniflare-options.mjs";

const PROD_BASE_URL = normaliseBaseURL(process.env.PROD_BASE_URL || process.env.PROD_URL || process.env.BASE_URL);
if (!PROD_BASE_URL) {
  console.error("[prod-smokes] Debes definir PROD_BASE_URL (ej. https://runart-foundry.pages.dev)");
  process.exit(1);
}

const RUN_AUTH_SMOKES = process.env.RUN_AUTH_SMOKES === "1" && !!process.env.ACCESS_SERVICE_TOKEN;
const timestamp = getTimestamp();
const { reportsRoot } = getProjectPaths();
const artifactsDir = join(reportsRoot, `smokes_prod_${timestamp}`);

const ACCESS_HINTS = ["/cdn-cgi/access", "/cdn-cgi/login", "cloudflareaccess", "/oauth2/"];

function isAccessRedirect(status, location) {
  if (status !== 301 && status !== 302 && status !== 303 && status !== 307 && status !== 308) return false;
  const loc = String(location || "").toLowerCase();
  return ACCESS_HINTS.some((frag) => loc.includes(frag));
}

async function checkNoAuthRoot() {
  const { url, init } = buildRequest(PROD_BASE_URL, "/", { method: "GET" });
  const res = await doFetch(url, init, 10000);
  const hdrs = pickHeaders(res.headers);
  const ok = isAccessRedirect(res.status, hdrs.location);
  const lines = [
    `GET / → ${res.status}`,
    `location: ${hdrs.location || "-"}`,
    `headers: ${JSON.stringify(hdrs)}`,
  ];
  return { name: "A:GET:/", ok, status: res.status, lines };
}

async function checkNoAuthWhoami() {
  const { url, init } = buildRequest(PROD_BASE_URL, "/api/whoami", { method: "GET" });
  const res = await doFetch(url, init, 10000);
  const hdrs = pickHeaders(res.headers);
  const ok = isAccessRedirect(res.status, hdrs.location);
  const lines = [
    `GET /api/whoami → ${res.status}`,
    `location: ${hdrs.location || "-"}`,
    `headers: ${JSON.stringify(hdrs)}`,
  ];
  return { name: "B:GET:/api/whoami", ok, status: res.status, lines };
}

async function checkRobots() {
  const { url, init } = buildRequest(PROD_BASE_URL, "/robots.txt", { method: "HEAD" });
  let res;
  try {
    res = await doFetch(url, init, 10000);
  } catch (err) {
    // Si HEAD falla, intentar GET como fallback
    if (err && (err.message.includes("405") || err.message.includes("501"))) {
      const { url: urlGet, init: initGet } = buildRequest(PROD_BASE_URL, "/robots.txt", { method: "GET" });
      res = await doFetch(urlGet, initGet, 10000);
    } else {
      throw err;
    }
  }
  const hdrs = pickHeaders(res.headers);
  const ok = res.status === 200 || isAccessRedirect(res.status, hdrs.location);
  const lines = [
    `HEAD /robots.txt → ${res.status}`,
    hdrs.location ? `location: ${hdrs.location}` : `content-type: ${hdrs["content-type"] || "-"}`,
    `headers: ${JSON.stringify(hdrs)}`,
  ];
  return { name: "C:HEAD:/robots.txt", ok, status: res.status, lines };
}

async function runNoAuthSuite() {
  const checks = [checkNoAuthRoot, checkNoAuthWhoami, checkRobots];
  const results = [];
  for (const fn of checks) {
    try {
      // eslint-disable-next-line no-await-in-loop
      const r = await fn();
      results.push(r);
    } catch (err) {
      results.push({ name: fn.name, ok: false, status: 0, lines: [String(err && err.message ? err.message : err)] });
    }
  }
  return results;
}

// Placeholders AUTH: corren solo si RUN_AUTH_SMOKES=1 y hay ACCESS_SERVICE_TOKEN
async function runAuthSuite() {
  // TODO: implementar autenticación con ACCESS_SERVICE_TOKEN (cuando esté disponible)
  // Ejemplos de checks esperados (desactivados hasta tener token):
  // - GET /api/whoami → 200 con env:"production"
  // - GET /api/inbox → 403 o 200 según EXPECTED_INBOX_STATUS
  // - POST /api/decisiones → 401/403/200 según rol
  return [];
}

function formatSummary(results) {
  const pass = results.filter((r) => r.ok).length;
  const fail = results.length - pass;
  return { pass, fail, total: results.length };
}

async function main() {
  await ensureDir(artifactsDir);
  const lines = [];
  lines.push(`# Smokes Producción — ${timestamp}`);
  lines.push(`Base URL: ${PROD_BASE_URL}`);
  lines.push("");

  const noAuth = await runNoAuthSuite();
  lines.push("## NO-AUTH");
  for (const r of noAuth) {
    lines.push(`- ${r.ok ? "✅" : "❌"} ${r.name}`);
    for (const l of r.lines) lines.push(`  - ${l}`);
  }

  if (RUN_AUTH_SMOKES) {
    const auth = await runAuthSuite();
    lines.push("");
    lines.push("## AUTH (experimental)");
    lines.push("(Habilitado por RUN_AUTH_SMOKES=1 y ACCESS_SERVICE_TOKEN presente)");
    for (const r of auth) {
      lines.push(`- ${r.ok ? "✅" : "❌"} ${r.name}`);
      for (const l of r.lines) lines.push(`  - ${l}`);
    }
  } else {
    lines.push("");
    lines.push("## AUTH (pendiente)");
    lines.push("RUN_AUTH_SMOKES=1 y ACCESS_SERVICE_TOKEN requerido para habilitar estas pruebas.");
  }

  const summary = formatSummary(noAuth);
  lines.push("");
  lines.push(`RESUMEN: PASS=${summary.pass} FAIL=${summary.fail} TOTAL=${summary.total}`);

  await writeText(join(artifactsDir, "log.txt"), lines.join("\n"));
  
  // Crear SUMMARY.md con tabla
  const summaryLines = [
    `# Smokes Producción — ${timestamp}`,
    "",
    `**Base URL:** ${PROD_BASE_URL}`,
    `**Timestamp:** ${timestamp}`,
    "",
    "## Resultados",
    "",
    "| Check | Endpoint | Status | Resultado |",
    "|-------|----------|--------|-----------|",
  ];
  for (const r of noAuth) {
    summaryLines.push(`| ${r.name} | ${r.lines[0].split(" → ")[0]} | ${r.status} | ${r.ok ? "✅ PASS" : "❌ FAIL"} |`);
  }
  summaryLines.push("");
  summaryLines.push(`**Resumen:** PASS=${summary.pass} FAIL=${summary.fail} TOTAL=${summary.total}`);
  await writeText(join(artifactsDir, "SUMMARY.md"), summaryLines.join("\n"));
  
  console.log(`[prod-smokes] Artefactos guardados en ${artifactsDir}`);
  console.log(`[prod-smokes] Log: ${join(artifactsDir, "log.txt")}`);
  console.log(`[prod-smokes] Resumen: ${join(artifactsDir, "SUMMARY.md")}`);

  if (summary.fail === 0 && summary.pass === summary.total) {
    process.exit(0);
  } else {
    process.exit(1);
  }
}

main().catch((err) => {
  console.error("[prod-smokes] Error inesperado", err);
  process.exit(1);
});
