#!/usr/bin/env node
/**
 * Pipeline canario end-to-end.
 * Requisitos: CF_API_TOKEN, config JSON, emails por CLI.
 */
import { readFile, writeFile, mkdir, access } from 'node:fs/promises';
import { resolve, dirname } from 'node:path';
import { spawn } from 'node:child_process';

function ts() { return new Date().toISOString().replace(/[-:]/g,'').replace(/\..+/,'')+'Z'; }
async function loadConfig() { return JSON.parse(await readFile(resolve('apps/briefing/scripts/canary.config.json'),'utf8')); }

function parseArgs() {
  const args = process.argv.slice(2);
  const opts = { extraControls: [] };
  for (let i=0;i<args.length;i++) {
    const a = args[i];
    if (a === '--host') opts.host = args[++i];
    else if (a === '--owner') opts.owner = args[++i];
    else if (a === '--team') opts.team = args[++i];
    else if (a === '--client_admin') opts.client_admin = args[++i];
    else if (a === '--client') opts.client = args[++i];
    else if (a === '--control') opts.extraControls.push(args[++i]);
    else if (a === '--skip-export') opts.skipExport = true;
    else if (a === '--skip-smokes') opts.skipSmokes = true;
    else if (a === '--help') opts.help = true;
    else { console.error('Arg no reconocido', a); opts.help = true; }
  }
  return opts;
}

function requireEmails(o) {
  const roles = ['owner','team','client_admin','client'];
  for (const r of roles) if (!o[r]) throw new Error('Falta email para rol '+r);
}

async function runNode(script, args=[]) {
  return new Promise((resolveP, reject) => {
    const p = spawn(process.execPath, [script, ...args], { stdio: ['ignore','pipe','pipe'] });
    let out=''; let err='';
    p.stdout.on('data', d=> out+=d);
    p.stderr.on('data', d=> err+=d);
    p.on('close', code => {
      if (code !== 0) return reject(new Error(`${script} exit ${code}: ${err}`));
      resolveP({out, err});
    });
  });
}

async function fileExists(path) { try { await access(path); return true; } catch { return false; } }

function extractAuditCounts(md) {
  const lines = md.split(/\n/);
  const counts = {};
  for (const l of lines) {
    const m = /^\|\s*(owner|team|client_admin|client|visitor|visitante)\s*\|\s*(\d+)\s*\|/.exec(l);
    if (m) counts[m[1]] = Number(m[2]);
  }
  return counts;
}

function extractSmokeRow(body) {
  try { return JSON.parse(body); } catch { return {}; }
}

async function main() {
  const start = Date.now();
  const cfg = await loadConfig();
  const args = parseArgs();
  if (args.help) {
    console.log('Uso: node canary_pipeline.mjs --host <url> --owner <e> --team <e> --client_admin <e> --client <e> [--control email]');
    process.exit(0);
  }
  requireEmails(args);
  if (!args.host) args.host = cfg.previewHost;
  if (!args.host) throw new Error('Host preview no definido');

  const stamp = ts();
  const reportsRoot = resolve('apps/briefing/_reports');
  await mkdir(reportsRoot, { recursive: true });
  const smokesDir = resolve(reportsRoot, `roles_canary_preview/smokes_${stamp}`);
  await mkdir(smokesDir, { recursive: true });

  // 1. Export snapshot
  let snapshotPath;
  if (!args.skipExport) {
    const { out } = await runNode('apps/briefing/scripts/kv_export_preview.mjs');
    // El script imprime la ruta del snapshot al final
    const match = out.trim().split(/\n/).slice(-1)[0];
    snapshotPath = match;
  } else {
    snapshotPath = (await fileExists(resolve(reportsRoot, `kv_snapshot_preview_${stamp}.json`))) ? resolve(reportsRoot, `kv_snapshot_preview_${stamp}.json`) : null;
  }
  if (!snapshotPath) throw new Error('No se obtuvo snapshot');

  // 2. Auditoría
  const auditOut = resolve(reportsRoot, `kv_audit_preview_${stamp}.md`);
  const auditRes = await runNode('apps/briefing/scripts/kv_audit.mjs', [snapshotPath]);
  // kv_audit escribe su propio archivo (por convención). Copiamos/renombramos si no coincide.
  // Detectar audit file autogenerado
  const generated = snapshotPath.replace('snapshot','audit').replace('.json','.md');
  if (await fileExists(generated) && generated !== auditOut) {
    // duplicar/nombre estándar
    const content = await readFile(generated,'utf8');
    await writeFile(auditOut, content,'utf8');
  }
  const auditContent = await readFile(auditOut,'utf8').catch(()=>auditRes.out);
  const counts = extractAuditCounts(auditContent);

  // 3. Set whitelist
  await runNode('apps/briefing/scripts/kv_set_canary_whitelist.mjs', ['--emails', args.owner, args.team, args.client_admin, args.client]);

  // 4. Smokes (whitelist + controles)
  if (!args.skipSmokes) {
    const emailList = [args.owner, args.team, args.client_admin, args.client, ...cfg.emailsControlLegacy, ...args.extraControls];
    await runNode('apps/briefing/scripts/smoke_canary_emails.mjs', [args.host, ...emailList, '--out', smokesDir]);
  }

  // 5. Resumen
  const resumenPath = resolve(reportsRoot, `roles_canary_preview/RESUMEN_${stamp}.md`);
  const tableFile = resolve(smokesDir, 'resumen_tabla.md');
  let tabla = '';
  if (await fileExists(tableFile)) tabla = await readFile(tableFile, 'utf8');
  const successCriteria = [
    '- Correos whitelist → X-RunArt-Canary=1 & Resolver=unified',
    '- Correos fuera whitelist → X-RunArt-Canary=0 & Resolver=legacy',
    '- Sin roles ascendidos indebidamente'
  ];

  const resumen = [
    `# Canary Roles Preview ${stamp}`,
    '',
    '## Conteos KV',
    '',
    'Archivo auditoría: ' + `kv_audit_preview_${stamp}.md`,
    '',
    'Roles:',
    '```',
    JSON.stringify(counts, null, 2),
    '```',
    '',
    '## Smokes',
    '',
    tabla || '_Smokes no ejecutados o sin datos_',
    '',
    '## Criterio de Éxito',
    '',
    ...successCriteria.map(l=>`- ${l}`),
    '',
    '## Veredicto',
    '',
    '_Pendiente de evaluación manual_ (revisar tabla de smokes).',
    '',
    '## Artefactos',
    '',
    `- Snapshot: kv_snapshot_preview_${stamp}.json`,
    `- Audit: kv_audit_preview_${stamp}.md`,
    `- Smokes: roles_canary_preview/smokes_${stamp}/`,
    `- Whitelist cmd: canary_allowlist_cmd_*.txt`,
    '',
    '---',
    `Duración: ${(Date.now()-start)/1000}s`
  ].join('\n');
  await mkdir(dirname(resumenPath), { recursive: true });
  await writeFile(resumenPath, resumen, 'utf8');
  console.log('Resumen:', resumenPath);
}

main().catch(e => { console.error(e); process.exit(1); });
