#!/usr/bin/env node
/**
 * Exporta todas las claves de un namespace KV de Cloudflare usando la API REST.
 * Uso:
 *   node scripts/kv_export_namespace.mjs <account_id> <namespace_id> > snapshot.json
 * Requiere:
 *   - Variable de entorno CLOUDFLARE_API_TOKEN con permisos de lectura KV.
 */
import https from 'node:https';

function cfRequest(path) {
  const token = process.env.CLOUDFLARE_API_TOKEN;
  if (!token) throw new Error('Falta CLOUDFLARE_API_TOKEN');
  const opts = {
    hostname: 'api.cloudflare.com',
    path,
    method: 'GET',
    headers: { 'Authorization': `Bearer ${token}`, 'Content-Type': 'application/json' }
  };
  return new Promise((resolve, reject) => {
    https.request(opts, (res) => {
      let data = '';
      res.on('data', (c) => (data += c));
      res.on('end', () => {
        try { resolve(JSON.parse(data)); } catch (e) { reject(e); }
      });
    }).on('error', reject).end();
  });
}

async function listKeys(accountId, namespaceId) {
  let cursor = undefined;
  const keys = [];
  do {
    const url = `/client/v4/accounts/${accountId}/storage/kv/namespaces/${namespaceId}/keys?limit=1000` + (cursor ? `&cursor=${encodeURIComponent(cursor)}` : '');
    const json = await cfRequest(url);
    if (!json || !json.success) throw new Error('Error listando keys');
    keys.push(...json.result);
    cursor = json.result_info?.cursor;
  } while (cursor);
  return keys.map(k => k.name);
}

async function getValue(accountId, namespaceId, key) {
  const path = `/client/v4/accounts/${accountId}/storage/kv/namespaces/${namespaceId}/values/${encodeURIComponent(key)}`;
  const token = process.env.CLOUDFLARE_API_TOKEN;
  const opts = {
    hostname: 'api.cloudflare.com',
    path,
    method: 'GET',
    headers: { 'Authorization': `Bearer ${token}` }
  };
  return new Promise((resolve, reject) => {
    https.request(opts, (res) => {
      let data = '';
      res.on('data', (c) => (data += c));
      res.on('end', () => resolve(data));
    }).on('error', reject).end();
  });
}

async function main() {
  const [accountId, namespaceId] = process.argv.slice(2);
  if (!accountId || !namespaceId) {
    console.error('Uso: node scripts/kv_export_namespace.mjs <account_id> <namespace_id>');
    process.exit(1);
  }
  const keys = await listKeys(accountId, namespaceId);
  const out = {};
  for (const key of keys) {
    try {
      const v = await getValue(accountId, namespaceId, key);
      out[key] = v;
    } catch (e) {
      out[key] = null;
    }
  }
  process.stdout.write(JSON.stringify(out, null, 2));
}

main().catch(err => { console.error(err); process.exit(1); });
