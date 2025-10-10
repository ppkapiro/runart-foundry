#!/usr/bin/env node
import { readFile } from 'fs/promises';
import { createRequire } from 'module';
import { fileURLToPath, pathToFileURL } from 'url';
import path from 'path';

const require = createRequire(import.meta.url);

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const targetPath = path.resolve(__dirname, '../briefing/functions/api/whoami.js');
const rawCode = await readFile(targetPath, 'utf8');
const code = rawCode.replace('export async function onRequestGet', 'async function onRequestGet');

const moduleShim = { exports: {} };
const exportsShim = moduleShim.exports;

const wrapper = new Function('exports', 'module', 'require', 'Headers', 'Request', 'Response', `${code}; module.exports = { onRequestGet };`);
wrapper(exportsShim, moduleShim, require, Headers, Request, Response);

const { onRequestGet } = moduleShim.exports;

const env = {
  ACCESS_ADMINS: 'tu@correo.com,otra@correo.com',
  ACCESS_EQUIPO_DOMAINS: 'runart.com,studio.com',
};

const testEmails = [
  ['admin', 'tu@correo.com'],
  ['equipo', 'alguien@runart.com'],
  ['cliente', 'usuario@gmail.com'],
];

for (const [label, email] of testEmails) {
  const headers = new Headers();
  headers.set('Cf-Access-Authenticated-User-Email', email);
  const request = new Request('https://example.com/api/whoami', { headers });

  const response = await onRequestGet({ request, env });
  const payload = await response.json();
  console.log(`${label}: ${JSON.stringify(payload)}`);
}
