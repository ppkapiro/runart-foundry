#!/usr/bin/env node
/**
 * Actualiza la whitelist de canario (CANARY_ROLE_RESOLVER_EMAILS) en KV.
 * Uso:
 *   node scripts/kv_set_canary_whitelist.mjs --emails a@x b@y c@z d@w
 *   node scripts/kv_set_canary_whitelist.mjs --file lista.txt
 */
import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { resolve } from 'node:path';

const API_BASE = 'https://api.cloudflare.com/client/v4';

async function loadConfig() {
  const raw = await readFile(resolve('apps/briefing/scripts/canary.config.json'), 'utf8');
  return JSON.parse(raw);
}

function parseArgs() {
  const args = process.argv.slice(2);
  const emails = [];
  let file = null;
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--emails') {
      while (args[i+1] && !args[i+1].startsWith('--')) {
        emails.push(args[++i]);
      }
    } else if (args[i] === '--file') {
      file = args[++i];
    } else {
      console.error('Argumento no reconocido:', args[i]);
      process.exit(1);
    }
  }
  return { emails, file };
}

async function loadEmailsFromFile(path) {
  const raw = await readFile(resolve(path), 'utf8');
  return raw.split(/\r?\n/).map(l => l.trim()).filter(Boolean);
}

function normalizeEmail(e) {
  return e.trim().toLowerCase();
}

async function putKey(accountId, namespaceId, key, value, token) {
  const url = `${API_BASE}/accounts/${accountId}/storage/kv/namespaces/${namespaceId}/values/${encodeURIComponent(key)}`;
  const res = await fetch(url, { method: 'PUT', headers: { 'Authorization': `Bearer ${token}`, 'Content-Type': 'text/plain' }, body: value });
  if (!res.ok) throw new Error(`PUT key failed ${res.status}`);
}

function timestamp() {
  return new Date().toISOString().replace(/[-:]/g, '').replace(/\..+/, '') + 'Z';
}

async function main() {
  const token = process.env.CF_API_TOKEN || process.env.CLOUDFLARE_API_TOKEN;
  if (!token) { console.error('Falta CF_API_TOKEN'); process.exit(1); }
  const cfg = await loadConfig();
  const { accountId, namespaceIdRunartRolesPreview, kvKeyCanaryList } = cfg;
  if (!accountId || !namespaceIdRunartRolesPreview) { console.error('Config incompleta'); process.exit(1); }
  const { emails, file } = parseArgs();
  let finalEmails = [...emails];
  if (file) {
    const fromFile = await loadEmailsFromFile(file);
    finalEmails.push(...fromFile);
  }
  finalEmails = Array.from(new Set(finalEmails.map(normalizeEmail))).filter(Boolean);
  if (finalEmails.length === 0) {
    console.error('No se proporcionaron emails');
    process.exit(1);
  }
  // Validación mínima
  for (const e of finalEmails) {
    if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(e)) {
      console.error('Email inválido:', e);
      process.exit(1);
    }
  }
  const jsonValue = JSON.stringify(finalEmails);
  await putKey(accountId, namespaceIdRunartRolesPreview, kvKeyCanaryList, jsonValue, token);
  console.log('Whitelist actualizada con', finalEmails.length, 'emails');

  const reportsDir = resolve('apps/briefing/_reports');
  await mkdir(reportsDir, { recursive: true });
  const ts = timestamp();
  const cmdFile = resolve(reportsDir, `canary_allowlist_cmd_${ts}.txt`);
  const cmdDoc = `# PUT whitelist (placeholders)\nwrangler kv key put --namespace-id=${namespaceIdRunartRolesPreview} --key=${kvKeyCanaryList} --value='${jsonValue.replace(/'/g,"'\''")}' --preview\n`;
  await writeFile(cmdFile, cmdDoc, 'utf8');
  console.log('Doc comando:', cmdFile);
  console.log(jsonValue);
}

main().catch(e => { console.error(e); process.exit(1); });
