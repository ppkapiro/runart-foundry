#!/usr/bin/env node
import { readFile, writeFile } from 'node:fs/promises';
import { basename, dirname, resolve } from 'node:path';

async function main() {
  const input = process.argv[2];
  if (!input) {
    console.error('Usage: node scripts/kv_audit.mjs <snapshot.json>');
    process.exit(1);
  }

  const resolved = resolve(input);
  const raw = await readFile(resolved, 'utf8');
  let data;
  try {
    data = JSON.parse(raw);
  } catch (error) {
    console.error('Invalid JSON snapshot:', error.message);
    process.exit(1);
  }

  if (!data || typeof data !== 'object') {
    console.error('Unexpected snapshot format');
    process.exit(1);
  }

  const roles = Object.create(null);
  if (Array.isArray(data)) {
    for (const entry of data) {
      if (!entry || typeof entry !== 'object') continue;
      const role = entry.role || entry.tipo || entry.type || 'unknown';
      roles[role] = (roles[role] || 0) + 1;
    }
  } else {
    for (const [key, value] of Object.entries(data)) {
      if (!value) continue;
      if (typeof value === 'string') {
        try {
          const parsed = JSON.parse(value);
          if (parsed && typeof parsed === 'object') {
            const role = parsed.role || parsed.tipo || parsed.type || 'unknown';
            roles[role] = (roles[role] || 0) + 1;
          }
        } catch (_err) {
          // Ignore
        }
        continue;
      }
      if (typeof value === 'object') {
        const role = value.role || value.tipo || value.type || 'unknown';
        roles[role] = (roles[role] || 0) + 1;
      }
    }
  }

  const lines = ['# KV Audit', '', `Fuente: ${basename(resolved)}`, '', '| Rol | Conteo |', '| --- | --- |'];
  for (const role of Object.keys(roles).sort()) {
    lines.push(`| ${role} | ${roles[role]} |`);
  }
  const outputName = basename(resolved).replace('.json', '.md').replace('snapshot', 'audit');
  const outputPath = resolve(dirname(resolved), outputName);
  await writeFile(outputPath, lines.join('\n') + '\n', 'utf8');
  console.log(`Audit written to ${outputPath}`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
