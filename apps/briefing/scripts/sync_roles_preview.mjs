#!/usr/bin/env node
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { join } from "node:path";
import { spawnSync } from "node:child_process";

function main() {
  const root = join(process.cwd(), "apps", "briefing");
  const rolesPath = join(root, "access", "roles.json");
  const logDir = join(root, "_reports", "logs");
  const ts = new Date().toISOString().replace(/[-:]/g, "").replace(/\..+/, "");
  const logFile = join(logDir, `${ts}_sync_roles_preview.log`);

  // Asegurar directorio de logs
  try {
    mkdirSync(logDir, { recursive: true });
  } catch (_) {}

  const raw = readFileSync(rolesPath, "utf8");
  const json = JSON.parse(raw);
  const groups = {
    owners: Array.isArray(json.owners) ? json.owners : [],
    client_admins: Array.isArray(json.client_admins) ? json.client_admins : [],
    team: Array.isArray(json.team) ? json.team : [],
    clients: Array.isArray(json.clients) ? json.clients : [],
  };

  const bulk = ["owners", "client_admins", "team", "clients"].map((key) => ({
    key,
    value: JSON.stringify(groups[key]),
    metadata: { synced: ts, env: "preview" },
  }));

  const tmpFile = join(process.cwd(), `roles_bulk_${ts}.json`);
  writeFileSync(tmpFile, JSON.stringify(bulk, null, 2), "utf8");

  // Ejecutar wrangler KV bulk put apuntando a Preview
  // Requiere que wrangler.toml esté configurado con la namespace de Preview para RUNART_ROLES
  const cmd = "npx";
  // Forzar el uso de la namespace de preview (preview_id) definida en wrangler.toml
  const args = ["wrangler", "kv", "bulk", "put", tmpFile, "--binding", "RUNART_ROLES", "--preview"];
  const res = spawnSync(cmd, args, { cwd: root, stdio: "pipe", encoding: "utf8" });

  const summary = {
    ts,
    counts: Object.fromEntries(Object.entries(groups).map(([k, arr]) => [k, arr.length])),
    samples: Object.fromEntries(
      Object.entries(groups).map(([k, arr]) => [k, arr.slice(0, 2)])
    ),
  wrangler: { code: res.status, stdout: res.stdout?.slice(0, 2000), stderr: res.stderr?.slice(0, 2000) },
  };

  writeFileSync(logFile, `${JSON.stringify(summary, null, 2)}\n`, "utf8");
  console.log(`Sync roles preview: log -> ${logFile}`);
}

main();