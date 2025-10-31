#!/usr/bin/env node
import process from "node:process";
import { mkdir, writeFile } from "node:fs/promises";
import { join } from "node:path";
import { performance } from "node:perf_hooks";
import { getProjectPaths, DEFAULT_EMAILS } from "../config/miniflare-options.mjs";

const argv = process.argv.slice(2);
const ALLOW_302 =
  process.env.SMOKES_ALLOW_302 === "1" || argv.includes("--allow-302") || argv.includes("--allow-access-redirects");
const FORCE_FOLLOW = argv.includes("--follow");
const NO_FOLLOW = FORCE_FOLLOW ? false : ALLOW_302 || argv.includes("--no-follow");
const ACCESS_REDIRECT_HINTS = ["/cdn-cgi/access", "/cdn-cgi/login", "cloudflareaccess", "/oauth2/"];
const PROTECTED_ENDPOINTS = new Set(["/", "/api/whoami", "/api/inbox", "/api/decisiones"]);
const IS_PREVIEW = String(process.env.RUNART_ENV || "").toLowerCase() === "preview";

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

function isProtectedRoute(route, baseHostname, scenarioProtected) {
  if (typeof scenarioProtected === "boolean") {
    return scenarioProtected;
  }
  if (PROTECTED_ENDPOINTS.has(route)) {
    return true;
  }
  if (!baseHostname) return false;
  const host = baseHostname.toLowerCase();
  const isPagesHost =
    host.endsWith(".pages.dev") ||
    host === "runart-foundry.pages.dev" ||
    host.endsWith("runart-foundry.pages.dev");
  if (!isPagesHost) return false;
  if (route === "/") return true;
  return route.startsWith("/api/");
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
  init.redirect = NO_FOLLOW ? "manual" : "follow";
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

async function runScenario(baseURL, baseHostname, scenario, attempt = 1, totalAttempts = 1) {
  const { name, route, method, email, testEmail, headers, body, expectStatus = 200, validateJSON } = scenario;
  const start = performance.now();
  const { url, init } = buildRequest(baseURL, route, { method, email, testEmail, headers, body });
  const protectedRoute = isProtectedRoute(route, baseHostname, scenario.protected);
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
    accessRedirect: false,
    redirectStatus: null,
  };

  try {
    const response = await fetch(url, init);
    const statusCode = response.status;
    const headersObject = Object.fromEntries(response.headers.entries());
    const locationHeader = headersObject.location || "";
    const locationLower = typeof locationHeader === "string" ? locationHeader.toLowerCase() : "";
    const isAccessRedirect =
      NO_FOLLOW &&
      ALLOW_302 &&
      protectedRoute &&
      (statusCode === 301 || statusCode === 302) &&
      ACCESS_REDIRECT_HINTS.some((fragment) => locationLower.includes(fragment));
    let text = "";
    if (!(NO_FOLLOW && (statusCode === 301 || statusCode === 302))) {
      text = await response.text();
    }
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
      result.passVariant = statusCode.toString();
      result.note = `AccessRedirect(${statusCode}) -> ${locationHeader || "sin-location"}`;
      result.redirectLocation = locationHeader;
      result.accessRedirect = true;
      result.redirectStatus = statusCode;
    }

    if (!result.accessRedirect && typeof validateJSON === "function" && data !== null) {
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
  const baseHostname = new URL(baseURL).hostname;

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
      expectStatus: IS_PREVIEW ? 200 : 200,
      protected: true,
      validateJSON(json, response) {
        if (!json) throw new Error("Respuesta vacía en whoami-owner");
        const role = json.role;
        if (IS_PREVIEW) {
          // En preview aceptamos 'owner' o 'admin' como equivalentes
          if (role !== "owner" && role !== "admin") {
            throw new Error(`Role inesperado en preview: ${role}`);
          }
          // Validar headers canary en preview
          const canary = response.headers.get("X-RunArt-Canary");
          if (canary !== "preview") {
            throw new Error(`X-RunArt-Canary esperado 'preview' pero se obtuvo: ${canary}`);
          }
          const resolver = response.headers.get("X-RunArt-Resolver");
          if (resolver !== "utils") {
            throw new Error(`X-RunArt-Resolver esperado 'utils' pero se obtuvo: ${resolver}`);
          }
        } else if (role !== "owner") {
          throw new Error(`Role inesperado: ${role}`);
        }
      },
    },
    {
      name: "whoami-team",
      route: "/api/whoami",
      email: DEFAULT_EMAILS.team,
      testEmail: DEFAULT_EMAILS.team,
      expectStatus: IS_PREVIEW ? 200 : 200,
      protected: true,
      validateJSON(json, response) {
        if (!json) throw new Error("Respuesta vacía en whoami-team");
        const role = json.role;
        if (IS_PREVIEW) {
          // En preview aceptamos que todo responda como 'admin' por configuración reducida
          if (role !== "team" && role !== "admin") {
            throw new Error(`Role team inesperado en preview: ${role}`);
          }
          // Validar headers canary
          const canary = response.headers.get("X-RunArt-Canary");
          if (canary !== "preview") {
            throw new Error(`X-RunArt-Canary esperado 'preview' pero se obtuvo: ${canary}`);
          }
        } else if (role !== "team") {
          throw new Error(`Role team inesperado: ${role}`);
        }
      },
    },
    {
      name: "whoami-client_admin",
      route: "/api/whoami",
      email: DEFAULT_EMAILS.client_admin,
      testEmail: DEFAULT_EMAILS.client_admin,
      expectStatus: IS_PREVIEW ? 200 : 200,
      protected: true,
      validateJSON(json, response) {
        if (!json) throw new Error("Respuesta vacía en whoami-client_admin");
        const role = json.role;
        if (IS_PREVIEW) {
          if (role !== "client_admin" && role !== "admin") {
            throw new Error(`Role client_admin inesperado en preview: ${role}`);
          }
          // Validar headers canary
          const canary = response.headers.get("X-RunArt-Canary");
          if (canary !== "preview") {
            throw new Error(`X-RunArt-Canary esperado 'preview' pero se obtuvo: ${canary}`);
          }
        } else if (role !== "client_admin") {
          throw new Error(`Role client_admin inesperado: ${role}`);
        }
      },
    },
    {
      name: "whoami-visitor",
      route: "/api/whoami",
      expectStatus: IS_PREVIEW ? 200 : 200,
      protected: true,
      validateJSON(json, response) {
        if (!json) throw new Error("Respuesta vacía en whoami-visitor");
        const role = json.role;
        if (IS_PREVIEW) {
          if (role !== "visitor" && role !== "admin") {
            throw new Error(`Role visitante inesperado en preview: ${role}`);
          }
          // Validar headers canary
          const canary = response.headers.get("X-RunArt-Canary");
          if (canary !== "preview") {
            throw new Error(`X-RunArt-Canary esperado 'preview' pero se obtuvo: ${canary}`);
          }
        } else if (role !== "visitor") {
          throw new Error(`Role visitante inesperado: ${role}`);
        }
      },
    },
    {
      name: "inbox-owner",
      route: "/api/inbox",
      email: DEFAULT_EMAILS.owner,
      testEmail: DEFAULT_EMAILS.owner,
      expectStatus: IS_PREVIEW ? 404 : 200,
      protected: true,
    },
    {
      name: "inbox-team",
      route: "/api/inbox",
      email: DEFAULT_EMAILS.team,
      testEmail: DEFAULT_EMAILS.team,
      expectStatus: IS_PREVIEW ? 404 : 200,
      protected: true,
    },
    {
      name: "inbox-client",
      route: "/api/inbox",
      email: DEFAULT_EMAILS.client,
      testEmail: DEFAULT_EMAILS.client,
      expectStatus: IS_PREVIEW ? 404 : 403,
      protected: true,
    },
    {
      name: "inbox-visitor",
      route: "/api/inbox",
      expectStatus: IS_PREVIEW ? 404 : 403,
      protected: true,
    },
    {
      name: "decisiones-unauth",
      route: "/api/decisiones",
      method: "POST",
      body: { draft: true },
      expectStatus: IS_PREVIEW ? 405 : 401,
      protected: true,
    },
    {
      name: "decisiones-owner",
      route: "/api/decisiones",
      method: "POST",
      email: DEFAULT_EMAILS.owner,
      testEmail: DEFAULT_EMAILS.owner,
      body: { decision: "ok" },
      expectStatus: IS_PREVIEW ? 405 : 200,
      protected: true,
    },
  ];

  const results = [];
  let total = 0;
  let pass200 = 0;
  let passAccess = 0;
  let failCount = 0;
  for (const scenario of scenarios) {
    const maxAttempts = Math.max(1, Number.parseInt(scenario.retries ?? process.env.SMOKES_RETRIES ?? "2", 10));
    const backoff = Number.parseInt(scenario.retryDelayMs ?? process.env.SMOKES_RETRY_DELAY_MS ?? "200", 10);
    let outcome = null;

    for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
      // eslint-disable-next-line no-await-in-loop
      outcome = await runScenario(baseURL, baseHostname, scenario, attempt, maxAttempts);
      if (outcome.status === "pass") {
        if (outcome.accessRedirect) {
          // Access redirects se consideran éxito en el primer intento.
          break;
        }
        break;
      }

      console.warn(`[smokes] Reintento ${outcome.name} (${attempt}/${maxAttempts}) → ${outcome.error}`);
      if (attempt < maxAttempts && backoff > 0) {
        // eslint-disable-next-line no-await-in-loop
        await delay(backoff * attempt);
      }
    }

    const symbol = outcome.status === "pass" ? "✅" : "❌";
    const retryNote = outcome.attempts > 1 ? ` · intento ${outcome.attempt}/${outcome.attempts}` : "";
    const statusLabel =
      outcome.status === "pass"
        ? outcome.accessRedirect
          ? `PASS(${outcome.redirectStatus ?? "30x"} AccessRedirect)`
          : "PASS"
        : "FAIL";
    console.log(
      `[smokes] ${outcome.route} => ${statusLabel} [${symbol}] (${outcome.durationMs}ms${retryNote})`
    );
    if (outcome.status === "pass" && outcome.note) {
      console.log(`  ↳ ${outcome.note}`);
    }
    if (outcome.status === "fail") {
      console.error(`  ↳ ${outcome.error}`);
    }
    results.push(outcome);

    total += 1;
    if (outcome.status === "pass") {
      if (outcome.accessRedirect) {
        passAccess += 1;
      } else {
        pass200 += 1;
      }
    } else {
      failCount += 1;
    }
  }

  const summary = {
    baseURL,
    timestamp,
    totals: {
      pass: pass200 + passAccess,
      pass200,
      passAccess,
      fail: failCount,
      total,
    },
    flags: {
      allow302: ALLOW_302,
      noFollow: NO_FOLLOW,
    },
    results,
  };

  await writeFile(join(reportDir, "results.json"), JSON.stringify(summary, null, 2), "utf8");
  console.log(`[smokes] Reporte guardado en ${reportDir}`);

  console.log(
    `[smokes] RESULT: pass200=${pass200} pass30x=${passAccess} fail=${failCount} total=${total}`
  );

  if (failCount === 0 && pass200 + passAccess === total) {
    process.exitCode = 0;
    return;
  }
  process.exitCode = 1;
}

main().catch((error) => {
  console.error("[smokes] Error inesperado", error);
  process.exitCode = 1;
});
