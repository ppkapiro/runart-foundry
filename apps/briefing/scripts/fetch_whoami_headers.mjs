#!/usr/bin/env node
/**
 * Helper simple para obtener headers de /api/whoami para un email.
 * Uso:
 *   node scripts/fetch_whoami_headers.mjs <baseUrl> <email>
 */
async function main() {
  const [base, email] = process.argv.slice(2);
  if (!base || !email) {
    console.error('Uso: node fetch_whoami_headers.mjs <baseUrl> <email>');
    process.exit(1);
  }

  const clientId = process.env.CF_ACCESS_CLIENT_ID || process.env.ACCESS_CLIENT_ID_SECRET;
  const clientSecret = process.env.CF_ACCESS_CLIENT_SECRET || process.env.ACCESS_CLIENT_SECRET_SECRET;
  if (!clientId || !clientSecret) {
    console.error('Faltan CF_ACCESS_CLIENT_ID / CF_ACCESS_CLIENT_SECRET en el entorno.');
    process.exit(2);
  }

  const url = base.replace(/\/$/, '') + '/api/whoami';
  const headers = new Headers({
    'CF-Access-Client-Id': clientId,
    'CF-Access-Client-Secret': clientSecret,
    'CF-Access-Authenticated-User-Email': email,
    'User-Agent': 'runart-canary/headers-fetch'
  });

  const res = await fetch(url, { headers, redirect: 'manual' });
  const body = await res.text();

  console.log('# Status:', res.status, res.statusText ?? '');
  console.log('# Headers:');
  for (const [k, v] of res.headers.entries()) {
    if (k.toLowerCase().startsWith('x-runart')) console.log(k + ':', v);
  }
  console.log('# Body:');
  console.log(body);
}
main().catch(e => { console.error(e); process.exit(1); });
