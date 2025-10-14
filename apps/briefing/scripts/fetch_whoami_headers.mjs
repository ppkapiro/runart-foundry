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
  const url = base.replace(/\/$/, '') + '/api/whoami';
  const res = await fetch(url, { headers: { 'Cf-Access-Authenticated-User-Email': email } });
  const body = await res.text();
  console.log('# Status:', res.status);
  console.log('# Headers:');
  for (const [k,v] of res.headers.entries()) {
    if (k.toLowerCase().startsWith('x-runart')) console.log(k+':', v);
  }
  console.log('# Body:');
  console.log(body);
}
main().catch(e => { console.error(e); process.exit(1); });
