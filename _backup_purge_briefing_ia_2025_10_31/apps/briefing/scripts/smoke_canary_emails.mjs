#!/usr/bin/env node
/**
 * Ejecuta smokes focalizados contra /api/whoami para una lista de correos simulando
 * cabecera CF-Access-Authenticated-User-Email. Requiere que el servidor local/preview
 * acepte esa cabecera (en Cloudflare viene inyectada). Para local se usa miniflare.
 *
 * Uso:
 *   node scripts/smoke_canary_emails.mjs http://localhost:8787 owner@example.com team@example.com
 * Salida:
 *   Genera archivos whoami_<email>.txt en el directorio indicado por --out (default: stdout)
 */
import { writeFile, mkdir } from 'node:fs/promises';
import { basename, resolve } from 'node:path';

async function fetchWhoami(base, email) {
  const url = base.replace(/\/$/, '') + '/api/whoami';
  const res = await fetch(url, { headers: { 'Cf-Access-Authenticated-User-Email': email } });
  const text = await res.text();
  const headers = {};
  for (const [k, v] of res.headers.entries()) headers[k] = v;
  return { status: res.status, headers, body: text };
}

function formatResult(email, r) {
  const lines = [];
  lines.push(`# whoami ${email}`);
  lines.push(`Status: ${r.status}`);
  lines.push('Headers:');
  const interesting = Object.keys(r.headers).filter(k => k.toLowerCase().startsWith('x-runart'));
  for (const k of interesting.sort()) {
    lines.push(`  ${k}: ${r.headers[k]}`);
  }
  lines.push('\nBody:');
  lines.push(r.body);
  return lines.join('\n');
}

async function main() {
  const args = process.argv.slice(2);
  if (args.length < 2) {
    console.error('Uso: node scripts/smoke_canary_emails.mjs <baseUrl> <email1> [email2 ...] [--out dir]');
    process.exit(1);
  }
  let outDir = null;
  const base = args[0];
  const emails = [];
  for (let i = 1; i < args.length; i++) {
    if (args[i] === '--out') { outDir = args[++i]; continue; }
    emails.push(args[i]);
  }
  if (outDir) await mkdir(outDir, { recursive: true });
  const summary = [];
  for (const email of emails) {
    const r = await fetchWhoami(base, email);
    const content = formatResult(email, r);
    if (outDir) {
      const file = resolve(outDir, `whoami_${email.replace(/[^a-z0-9_.-]+/gi,'_')}.txt`);
      await writeFile(file, content, 'utf8');
    } else {
      console.log(content);
    }
    summary.push({ email, status: r.status, role: extractRole(r.body), resolver: r.headers['x-runart-resolver'] || '' , canary: r.headers['x-runart-canary'] || ''});
  }
  if (outDir) {
    const tableLines = ['| Email | Status | Rol | Resolver | Canary |', '| --- | --- | --- | --- | --- |'];
    for (const row of summary) {
      tableLines.push(`| ${row.email} | ${row.status} | ${row.role} | ${row.resolver} | ${row.canary} |`);
    }
    await writeFile(resolve(outDir, 'resumen_tabla.md'), tableLines.join('\n') + '\n', 'utf8');
  }
}

function extractRole(body) {
  try {
    const json = JSON.parse(body);
    return json.role || json.roleTranslated || json.roleOriginal || '?';
  } catch (_) {
    return '?';
  }
}

main().catch(e => { console.error(e); process.exit(1); });
