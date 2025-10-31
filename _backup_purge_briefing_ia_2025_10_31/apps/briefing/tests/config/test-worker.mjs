import * as middlewareModule from "../../functions/_middleware.js";
import * as whoamiModule from "../../functions/api/whoami.js";
import * as inboxModule from "../../functions/api/inbox.js";
import * as decisionesModule from "../../functions/api/decisiones.js";

function detectBareSpecifiers(source) {
  const hits = [];
  const regex = /functions\//g;
  let match;
  while ((match = regex.exec(source)) !== null) {
    if (isBareSpecifier(source, match.index)) {
      const line = source.slice(0, match.index).split("\n").length;
      hits.push({ index: match.index, line });
    }
  }
  return hits;
}

function isBareSpecifier(source, index) {
  for (let i = index - 1; i >= 0; i--) {
    const char = source[i];
    if (char === "'" || char === '"' || char === "`") {
      if (source[i - 1] === "\\") {
        i -= 1;
        continue;
      }
      const first = source[i + 1];
      if (first === ".") return false;
      if (first === "/") {
        const next = source[i + 2];
        if (next === ".") return false;
      }
      return true;
    }
  }
  return true;
}

async function ensureNoBareSpecifiers() {
  try {
    const response = await fetch(import.meta.url);
    if (!response.ok) {
      console.warn(`[preflight] No se pudo leer ${import.meta.url}: ${response.status}`);
      return;
    }
    const source = await response.text();
    const issues = detectBareSpecifiers(source);
    if (issues.length > 0) {
      const detail = issues.map((item) => `línea ${item.line}`).join(", ");
      throw new Error(`[preflight] Specifiers prohibidos detectados en test-worker.mjs → ${detail}`);
    }
  } catch (error) {
    if (error && typeof error === "object" && "message" in error && typeof error.message === "string") {
      if (error.message.startsWith("[preflight] Specifiers prohibidos")) {
        throw error;
      }
    }
    console.warn("[preflight] Validación de specifiers no disponible", error);
  }
}

const IS_NODE_RUNTIME = typeof process !== "undefined" && process.release?.name === "node";

if (IS_NODE_RUNTIME) {
  await ensureNoBareSpecifiers();
}

const middlewareExport = middlewareModule.onRequest ?? middlewareModule.default;
const middlewareList = Array.isArray(middlewareExport) ? middlewareExport : [middlewareExport].filter(Boolean);

async function routeRequest(request, env) {
  const url = new URL(request.url);
  const method = request.method.toUpperCase();

  if (url.pathname === "/api/whoami" && method === "GET") {
    return whoamiModule.onRequestGet({ request, env });
  }

  if (url.pathname === "/api/inbox" && method === "GET") {
    return inboxModule.onRequestGet({ request, env });
  }

  if (url.pathname === "/api/decisiones" && method === "POST") {
    return decisionesModule.onRequestPost({ request, env });
  }

  return new Response("Not Found", { status: 404 });
}

function compose(middlewares, handler) {
  return middlewares.reduceRight((next, current) => {
    return ({ request, env, waitUntil }) =>
      current({
        request,
        env,
        waitUntil,
        next: async (nextRequest = request) => next({ request: nextRequest, env, waitUntil }),
      });
  }, handler);
}

const execute = compose(middlewareList, ({ request, env }) => routeRequest(request, env));

export default {
  async fetch(request, env, ctx) {
    return execute({
      request,
      env,
      waitUntil: (promise) => ctx.waitUntil?.(promise),
    });
  },
};
