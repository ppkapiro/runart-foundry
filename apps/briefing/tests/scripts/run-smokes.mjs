#!/usr/bin/env node
import process from "node:process";
import { mkdir, writeFile } from "node:fs/promises";
import { join } from "node:path";
import { performance } from "node:perf_hooks";
import { getProjectPaths, DEFAULT_EMAILS } from "../config/miniflare-options.mjs";

const argv = process.argv.slice(2);
const ALLOW_302 =
  process.env.SMOKES_ALLOW_302 === "1" || argv.includes("--allow-302") || argv.includes("--allow-access-redirects");
const ACCESS_REDIRECT_HINTS = ["/cdn-cgi/access", "cloudflareaccess", "/oauth2/"];

function parseArgs(argv) {
  const args = { baseURL: undefined };
  for (let i = 0; i < argv.length; i += 1) {
    const value = argv[i];
    if (value === "--baseURL" || value === "--base-url") {
      args.baseURL = argv[i + 1];
      i += 1;
      continue;
    }

    if (value.startsWith("--baseURL=") || value.startsWith("--base-url=")) {
      const [, raw] = value.split("=", 2);
      args.baseURL = raw;
    }
  }
  return args;
}

function normaliseBaseURL(raw) {
  if (!raw) return undefined;
  try {
    const url = new URL(raw);
    if (!url.pathname.endsWith("/")) {
      url.pathname = `${url.pathname}/`;
    }
    return url.toString();
  } catch (error) {
    console.error(`[smokes] URL inválida: ${raw}`, error);
    return undefined;
  }
}

function buildRequest(baseURL, route, { method = "GET", email, testEmail, headers = {}, body } = {}) {
  const url = new URL(route, baseURL);
  const init = { method, headers: new Headers(headers) };
  init.headers.set("Accept", "application/json");
  if (testEmail) {
    init.headers.set("X-RunArt-Test-Email", testEmail);
  }
  if (email) {
    init.headers.set("Cf-Access-Authenticated-User-Email", email);
  }
  if (body !== undefined) {
    const payload = typeof body === "string" ? body : JSON.stringify(body);
    init.body = payload;
    if (!init.headers.has("Content-Type")) {
      init.headers.set("Content-Type", "application/json");
    }
  }
  return { url, init };
}

function delay(ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}

async function runScenario(baseURL, scenario, attempt = 1, totalAttempts = 1) {
  const { name, route, method, email, testEmail, headers, body, expectStatus = 200, validateJSON } = scenario;
  const start = performance.now();
  const { url, init } = buildRequest(baseURL, route, { method, email, testEmail, headers, body });
  const result = {
    name,
    route,
    method: init.method,
    email,
    auth: {
      bypass: Boolean(testEmail),
      email: testEmail || email || null,
    },
    status: "pass",
    durationMs: 0,
    response: null,
    error: null,
    attempts: totalAttempts,
    attempt,
    passVariant: "normal",
    note: null,
    redirectLocation: null,
  };

  try {
    const response = await fetch(url, init);
    const statusCode = response.status;
    const headersObject = Object.fromEntries(response.headers.entries());
    const locationHeader = headersObject.location || "";
    const locationLower = typeof locationHeader === "string" ? locationHeader.toLowerCase() : "";
    const isAccessRedirect =
      ALLOW_302 &&
      (statusCode === 301 || statusCode === 302) &&
      ACCESS_REDIRECT_HINTS.some((fragment) => locationLower.includes(fragment));
    const text = await response.text();
    let data = null;
    if (!isAccessRedirect) {
      try {
        data = text ? JSON.parse(text) : null;
      } catch (parseError) {
        if (expectStatus === 200) {
          throw new Error(`Respuesta no JSON para ${name}: ${text}`);
        }
      }
    }

    result.response = {
      status: statusCode,
      headers: headersObject,
      body: data ?? text,
    };

    if (statusCode !== expectStatus) {
      if (!isAccessRedirect) {
        throw new Error(`Status esperado ${expectStatus} pero se obtuvo ${statusCode}`);
      }
      result.passVariant = "302";
      result.note = `AccessRedirect -> ${locationHeader || "sin-location"}`;
      result.redirectLocation = locationHeader;
    }

    if (typeof validateJSON === "function" && data !== null) {
      validateJSON(data, response);
    }
  } catch (error) {
    result.status = "fail";
    if (error instanceof Error) {
      result.error = error.message;
      if (error.cause && typeof error.cause === "object") {
        const cause = error.cause;
        const details = [];
        if ("code" in cause && cause.code) details.push(`code=${cause.code}`);
        if ("hostname" in cause && cause.hostname) details.push(`host=${cause.hostname}`);
        if (details.length > 0) {
          result.error += ` (${details.join(" ")})`;
        }
      }
    } else {
      result.error = String(error);
    }
  } finally {
    result.durationMs = Number((performance.now() - start).toFixed(2));
  }
  return result;
}

async function main() {
  const args = parseArgs(argv);
  const baseURL = normaliseBaseURL(args.baseURL || process.env.PREVIEW_URL || process.env.CF_PAGES_URL);
  if (!baseURL) {
    console.error("[smokes] Debes definir PREVIEW_URL o pasar --baseURL");
    process.exitCode = 1;
    return;
  }

  const { reportsRoot } = getProjectPaths();
  const timestamp = new Date().toISOString().replace(/[-:]/g, "").replace(/\..+/, "");
  const reportDir = join(reportsRoot, "T3_e2e", timestamp);
  await mkdir(reportDir, { recursive: true });

  const scenarios = [
    {
      name: "whoami-owner",
      route: "/api/whoami",
      email: DEFAULT_EMAILS.owner,
      testEmail: DEFAULT_EMAILS.owner,
      expectStatus: 200,
      validateJSON(json) {
        if (!json || json.role !== "owner") {
          throw new Error(`Role inesperado: ${json?.role}`);
        }
      },
    },
    {
      name: "whoami-team",
      route: "/api/whoami",
      email: DEFAULT_EMAILS.team,
      testEmail: DEFAULT_EMAILS.team,
      expectStatus: 200,
      validateJSON(json) {
        if (!json || json.role !== "team") {
          throw new Error(`Role team inesperado: ${json?.role}`);
        }
      },
    },
    {
      name: "whoami-client_admin",
      route: "/api/whoami",
      email: DEFAULT_EMAILS.client_admin,
      testEmail: DEFAULT_EMAILS.client_admin,
      expectStatus: 200,
      validateJSON(json) {
        if (!json || json.role !== "client_admin") {
          throw new Error(`Role client_admin inesperado: ${json?.role}`);
        }
      },
    },
    {
      name: "whoami-visitor",
      route: "/api/whoami",
      expectStatus: 200,
      validateJSON(json) {
        if (!json || json.role !== "visitor") {
          throw new Error(`Role visitante inesperado: ${json?.role}`);
        }
      },
    },
    {
      name: "inbox-owner",
      route: "/api/inbox",
      email: DEFAULT_EMAILS.owner,
      testEmail: DEFAULT_EMAILS.owner,
      expectStatus: 200,
    },
    {
      name: "inbox-team",
      route: "/api/inbox",
      email: DEFAULT_EMAILS.team,
      testEmail: DEFAULT_EMAILS.team,
      expectStatus: 200,
    },
    {
      name: "inbox-client",
      route: "/api/inbox",
      email: DEFAULT_EMAILS.client,
      testEmail: DEFAULT_EMAILS.client,
      expectStatus: 403,
    },
    {
      name: "inbox-visitor",
      route: "/api/inbox",
      expectStatus: 403,
    },
    {
      name: "decisiones-unauth",
      route: "/api/decisiones",
      method: "POST",
      body: { draft: true },
      expectStatus: 401,
    },
    {
      name: "decisiones-owner",
      route: "/api/decisiones",
      method: "POST",
      email: DEFAULT_EMAILS.owner,
      testEmail: DEFAULT_EMAILS.owner,
      body: { decision: "ok" },
      expectStatus: 200,
    },
  ];

  const results = [];
  for (const scenario of scenarios) {
    const maxAttempts = Math.max(1, Number.parseInt(scenario.retries ?? process.env.SMOKES_RETRIES ?? "2", 10));
    const backoff = Number.parseInt(scenario.retryDelayMs ?? process.env.SMOKES_RETRY_DELAY_MS ?? "200", 10);
    let outcome = null;

    for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
      // eslint-disable-next-line no-await-in-loop
      outcome = await runScenario(baseURL, scenario, attempt, maxAttempts);
      if (outcome.status === "pass") {
        break;
      }

      console.warn(`[smokes] Reintento ${outcome.name} (${attempt}/${maxAttempts}) → ${outcome.error}`);
      if (attempt < maxAttempts && backoff > 0) {
        // eslint-disable-next-line no-await-in-loop
        await delay(backoff * attempt);
      }
    }

    const symbol = outcome.status === "pass" ? "✅" : "❌";
    const variantLabel = outcome.passVariant === "302" ? " (302)" : "";
    const retryNote = outcome.attempts > 1 ? ` · intento ${outcome.attempt}/${outcome.attempts}` : "";
    console.log(`[smokes] ${symbol} ${outcome.name}${variantLabel} (${outcome.durationMs}ms${retryNote})`);
    if (outcome.status === "pass" && outcome.note) {
      console.log(`  ↳ ${outcome.note}`);
    }
    if (outcome.status === "fail") {
      console.error(`  ↳ ${outcome.error}`);
    }
    results.push(outcome);
  }

  const summary = {
    baseURL,
    timestamp,
    totals: {
      pass: results.filter((item) => item.status === "pass").length,
      pass302: results.filter((item) => item.passVariant === "302").length,
      fail: results.filter((item) => item.status === "fail").length,
      total: results.length,
    },
    flags: {
      allow302: ALLOW_302,
    },
    results,
  };

  await writeFile(join(reportDir, "results.json"), JSON.stringify(summary, null, 2), "utf8");
  console.log(`[smokes] Reporte guardado en ${reportDir}`);

  if (summary.totals.fail > 0) {
    process.exitCode = 1;
  }
}

main().catch((error) => {
  console.error("[smokes] Error inesperado", error);
  process.exitCode = 1;
});
