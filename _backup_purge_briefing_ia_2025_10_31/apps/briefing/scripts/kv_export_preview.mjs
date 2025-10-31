#!/usr/bin/env node
/**
 * Exporta el namespace RUNART_ROLES (preview) según config.
 * Usa paginación /keys y luego GET individual por key.
 * No imprime el token. CF_API_TOKEN debe estar en env.
 */
import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { resolve } from 'node:path';

const API_BASE = 'https://api.cloudflare.com/client/v4';

async function loadConfig() {
  const path = resolve('apps/briefing/scripts/canary.config.json');
  const raw = await readFile(path, 'utf8');
  return JSON.parse(raw);
}

async function cfApi(path, token) {
  const res = await fetch(API_BASE + path, {
    headers: { 'Authorization': `Bearer ${token}` }
  });
  if (!res.ok) throw new Error(`CF API error ${res.status} ${path}`);
  const json = await res.json();
  if (!json.success) throw new Error(`CF API success=false ${path}`);
  return json;
}

async function listAllKeys(accountId, namespaceId, token) {
  const keys = [];
  let cursor = undefined;
  do {
    const url = `/accounts/${accountId}/storage/kv/namespaces/${namespaceId}/keys?limit=1000` + (cursor ? `&cursor=${encodeURIComponent(cursor)}` : '');
    const json = await cfApi(url, token);
    keys.push(...json.result.map(r => r.name));
    cursor = json.result_info?.cursor;
  } while (cursor);
  return keys;
}

async function getValue(accountId, namespaceId, key, token) {
  const url = `${API_BASE}/accounts/${accountId}/storage/kv/namespaces/${namespaceId}/values/${encodeURIComponent(key)}`;
  const res = await fetch(url, { headers: { 'Authorization': `Bearer ${token}` } });
  if (!res.ok) return null;
  return await res.text();
}

function timestamp() {
  return new Date().toISOString().replace(/[-:]/g, '').replace(/\..+/, '') + 'Z';
}

async function main() {
  const token = process.env.CF_API_TOKEN || process.env.CLOUDFLARE_API_TOKEN;
  if (!token) {
    console.error('Falta CF_API_TOKEN');
    process.exit(1);
  }
  const cfg = await loadConfig();
  const { accountId, namespaceIdRunartRolesPreview } = cfg;
  if (!accountId || !namespaceIdRunartRolesPreview) {
    console.error('Config incompleta: accountId / namespaceIdRunartRolesPreview');
    process.exit(1);
  }
  const ts = timestamp();
  const outDir = resolve('apps/briefing/_reports');
  await mkdir(outDir, { recursive: true });

  console.log('Listando keys...');
  const keys = await listAllKeys(accountId, namespaceIdRunartRolesPreview, token);
  console.log(`Total keys: ${keys.length}`);

  const snapshot = {};
  for (const key of keys) {
    const val = await getValue(accountId, namespaceIdRunartRolesPreview, key, token);
    snapshot[key] = val;
  }

  const snapFile = resolve(outDir, `kv_snapshot_preview_${ts}.json`);
  await writeFile(snapFile, JSON.stringify(snapshot, null, 2), 'utf8');
  console.log('Snapshot escrito:', snapFile);

  const cmdFile = resolve(outDir, `kv_snapshot_preview_${ts}.cmd.txt`);
  const cmdContent = `# Reproducir export (placeholders)\n# curl -H 'Authorization: Bearer <CF_API_TOKEN>' '${API_BASE}/accounts/${accountId}/storage/kv/namespaces/${namespaceIdRunartRolesPreview}/keys?limit=1000'\n`;
  await writeFile(cmdFile, cmdContent, 'utf8');
  console.log('Cmd doc:', cmdFile);

  console.log(snapFile); // Para pipeline siguiente
}

main().catch(e => { console.error(e); process.exit(1); });
