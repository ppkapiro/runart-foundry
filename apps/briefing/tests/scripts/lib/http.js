import { writeFile, mkdir } from "node:fs/promises";
import { join } from "node:path";

export function getTimestamp() {
  return new Date().toISOString().replace(/[-:]/g, "").replace(/\..+/, "");
}

export function normaliseBaseURL(raw) {
  if (!raw) return undefined;
  try {
    const url = new URL(raw);
    if (!url.pathname.endsWith("/")) url.pathname = `${url.pathname}/`;
    return url.toString();
  } catch (err) {
    console.error(`[http] URL inválida: ${raw}`);
    return undefined;
  }
}

export function buildRequest(baseURL, route, { method = "GET", headers = {}, body } = {}) {
  const url = new URL(route, baseURL);
  const init = { method, headers: new Headers(headers), redirect: "manual" };
  init.headers.set("Accept", "application/json");
  if (body !== undefined) {
    const payload = typeof body === "string" ? body : JSON.stringify(body);
    init.body = payload;
    if (!init.headers.has("Content-Type")) init.headers.set("Content-Type", "application/json");
  }
  return { url, init };
}

export async function doFetch(url, init, timeoutMs = 8000) {
  const controller = new AbortController();
  const id = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const res = await fetch(url, { ...init, signal: controller.signal });
    return res;
  } finally {
    clearTimeout(id);
  }
}

export function pickHeaders(headers, keys = ["date", "server", "cf-ray", "location", "content-type"]) {
  const out = {};
  for (const k of keys) {
    const val = headers.get(k);
    if (val) out[k] = val;
  }
  return out;
}

export async function ensureDir(dirPath) {
  await mkdir(dirPath, { recursive: true });
}

export async function writeText(filePath, text) {
  await writeFile(filePath, text, "utf8");
}
