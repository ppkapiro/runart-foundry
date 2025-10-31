#!/usr/bin/env node
/* eslint-disable no-process-exit */
import { Miniflare } from "miniflare";
import { writeFile, mkdir, readFile } from "node:fs/promises";
import { join, dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { getProjectPaths, DEFAULT_EMAILS } from "../config/miniflare-options.mjs";

process.on("unhandledRejection", (reason) => {
  console.error("[unhandledRejection]", reason);
  process.exit(1);
});

process.on("uncaughtException", (error) => {
  console.error("[uncaughtException]", error);
  process.exit(1);
});

const WATCHDOG_MS = Number.parseInt(process.env.TEST_WATCHDOG_MS || "90000", 10);
const watchdog = setTimeout(() => {
  console.error(`[watchdog] setup-mocks excede ${WATCHDOG_MS}ms, abortando`);
  process.exit(124);
}, WATCHDOG_MS).unref();

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const rolesPath = resolve(__dirname, "../../access/roles.json");

const timestamp = new Date().toISOString().replace(/[-:]/g, "").replace(/\.\d{3}Z$/, "Z");
const { reportsRoot } = getProjectPaths();
const reportDir = join(reportsRoot, "T1_setup", timestamp);

async function ensureDir(path) {
  await mkdir(path, { recursive: true });
}

async function loadRolesSnapshot() {
  const raw = await readFile(rolesPath, "utf8");
  return JSON.parse(raw);
}

async function seedRoles(mf, rolesSnapshot) {
  const kv = await mf.getKVNamespace("RUNART_ROLES");
  const snapshotString = JSON.stringify(rolesSnapshot);
  await Promise.all([
    kv.put(DEFAULT_EMAILS.owner, JSON.stringify({ role: "owner" })),
    kv.put(DEFAULT_EMAILS.client_admin, JSON.stringify({ role: "client_admin" })),
    kv.put(DEFAULT_EMAILS.client, JSON.stringify({ role: "client" })),
    kv.put(DEFAULT_EMAILS.team, JSON.stringify({ role: "team" })),
    kv.put("runart_roles", snapshotString),
    kv.put("snapshot", snapshotString)
  ]);
}

async function main() {
  await ensureDir(reportDir);
  const rolesSnapshot = await loadRolesSnapshot();

  let mf;

  try {
    mf = new Miniflare({
      modules: true,
      script: `export default { async fetch() { return new Response("setup-ok", { status: 200 }); } };`,
      compatibilityDate: "2024-01-01",
      kvNamespaces: ["RUNART_ROLES", "LOG_EVENTS", "DECISIONES"],
      durableObjects: {},
      cachePersist: false,
      watch: false,
      liveReload: false,
      bindings: {
        RUNART_ENV: "preview",
      },
    });

  await seedRoles(mf, rolesSnapshot);
  console.log("[setup-mocks] seed RUNART_ROLES snapshot OK");

    const pingResponse = await mf.dispatchFetch("http://localhost/");
    const pingText = await pingResponse.text();

    const summary = {
      timestamp,
      ping: {
        status: pingResponse.status,
        body: pingText,
      },
      seededRoles: Object.keys(DEFAULT_EMAILS),
      notes: "Miniflare initialized with minimal worker and KV namespaces.",
      rolesSource: rolesPath,
    };

    await writeFile(join(reportDir, "summary.json"), JSON.stringify(summary, null, 2), "utf8");
    console.log(`[setup-mocks] DONE → ${reportDir}`);

    await mf.dispose();
    clearTimeout(watchdog);
    process.exit(0);
  } catch (error) {
    console.error("T1 setup failed", error);
    if (mf) {
      try {
        await mf.dispose();
      } catch (disposeError) {
        console.warn("[setup-mocks] dispose error", disposeError);
      }
    }
    clearTimeout(watchdog);
    console.error(
      JSON.stringify(
        {
          script: import.meta.url,
          cwd: process.cwd(),
          rolesPath,
        },
        null,
        2
      )
    );
    process.exit(1);
  }
}

main();
