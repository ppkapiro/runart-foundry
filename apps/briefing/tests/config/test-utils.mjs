import { mkdir, writeFile, readFile } from "node:fs/promises";
import { join } from "node:path";
import { Miniflare } from "miniflare";
import { createMiniflareOptions, getProjectPaths, DEFAULT_EMAILS } from "./miniflare-options.mjs";

const { reportsRoot } = getProjectPaths();
const T2_TIMESTAMP = new Date().toISOString().replace(/[-:]/g, "").replace(/\..+/, "");
export const T2_REPORT_DIR = join(reportsRoot, "T2_unit_integration", T2_TIMESTAMP);
await mkdir(T2_REPORT_DIR, { recursive: true });

export const DEFAULT_TIMEOUT_MS = Number.parseInt(process.env.TEST_TIMEOUT_MS || "30000", 10);

let rolesSnapshotCache = null;

export async function loadRolesSnapshot() {
  if (!rolesSnapshotCache) {
    const rolesPath = join(process.cwd(), "access", "roles.json");
    const raw = await readFile(rolesPath, "utf8");
    rolesSnapshotCache = JSON.parse(raw);
  }
  return rolesSnapshotCache;
}

export async function writeReport(filename, data) {
  const filePath = join(T2_REPORT_DIR, `${filename}.json`);
  await writeFile(filePath, JSON.stringify(data, null, 2), "utf8");
  return filePath;
}

export async function createTestMiniflare({ env = {}, roles } = {}) {
  const bindings = { ...env };
  bindings.RUNART_ENV = bindings.RUNART_ENV ?? "preview";

  const rolesData = roles ?? (await loadRolesSnapshot());

  const mf = new Miniflare(
    createMiniflareOptions({
      env: bindings.RUNART_ENV,
      bindings,
      watch: false,
      liveReload: false,
    })
  );

  const rolesNamespace = await mf.getKVNamespace("RUNART_ROLES");
  const snapshotString = JSON.stringify(rolesData);
  const seeds = [rolesNamespace.put("snapshot", snapshotString), rolesNamespace.put("runart_roles", snapshotString)];

  const roleSeeds = {
    owner: DEFAULT_EMAILS.owner,
    client_admin: DEFAULT_EMAILS.client_admin,
    client: DEFAULT_EMAILS.client,
    team: DEFAULT_EMAILS.team,
  };

  for (const [role, email] of Object.entries(roleSeeds)) {
    if (!email) continue;
    seeds.push(rolesNamespace.put(email, JSON.stringify({ role })));
  }

  await Promise.all(seeds);
  return mf;
}

export function createRequest(path, { method = "GET", email, headers = {}, body } = {}) {
  const url = new URL(path, "http://localhost");
  const requestHeaders = new Headers(headers);
  if (email) {
    requestHeaders.set("Cf-Access-Authenticated-User-Email", email);
  }
  const init = { method, headers: requestHeaders };
  if (body !== undefined) {
    init.body = typeof body === "string" ? body : JSON.stringify(body);
    if (!requestHeaders.has("Content-Type")) {
      requestHeaders.set("Content-Type", "application/json");
    }
  }
  return {
    url: url.toString(),
    init,
    toRequest() {
      return new Request(url, init);
    },
  };
}

export function assertJsonStructure(t, json, expectedKeys) {
  for (const key of expectedKeys) {
    if (!(key in json)) {
      t.fail(`Falta la clave esperada '${key}' en la respuesta`);
    }
  }
}

export async function withTimeout(promise, label, timeout = DEFAULT_TIMEOUT_MS) {
  let timer;
  try {
    return await Promise.race([
      promise,
      new Promise((_, reject) => {
        timer = setTimeout(() => {
          reject(new Error(`[timeout] ${label} excede ${timeout}ms`));
        }, timeout);
        if (typeof timer.unref === "function") {
          timer.unref();
        }
      }),
    ]);
  } finally {
    if (timer) clearTimeout(timer);
  }
}
