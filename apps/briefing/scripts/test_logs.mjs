import assert from 'node:assert/strict';

import { onRequestPost as handleLogEvent } from '../functions/api/log_event.js';
import { onRequestGet as handleLogsList } from '../functions/api/logs_list.js';

const ADMIN_EMAIL = 'tu@correo.com';
const TEAM_EMAIL = 'alguien@runart.com';
const CLIENT_EMAIL = 'cliente@example.com';

const BASE_ENV = {
  ACCESS_ADMINS: `${ADMIN_EMAIL},otra@correo.com`,
  ACCESS_EQUIPO_DOMAINS: 'runart.com,studio.com',
  // LOG_EVENTS intentionally undefined → fallback path exercise
};

const buildContext = ({ url, method = 'GET', email, body }) => {
  const headers = new Headers();
  if (email) headers.set('Cf-Access-Authenticated-User-Email', email);
  const init = { method, headers };
  if (body) {
    headers.set('Content-Type', 'application/json');
    init.body = JSON.stringify(body);
  }
  return { env: { ...BASE_ENV }, request: new Request(url, init) };
};

const asJson = async (response) => ({ status: response.status, body: await response.json() });

async function main() {
  const denied = await handleLogEvent(
    buildContext({
      url: 'https://local/api/log_event',
      method: 'POST',
      email: CLIENT_EMAIL,
      body: { action: 'page_view', path: '/exports/' },
    }),
  );
  const deniedPayload = await asJson(denied);
  assert.equal(deniedPayload.status, 403);
  console.log('cliente log_event =>', deniedPayload);

  const disallowed = await handleLogEvent(
    buildContext({
      url: 'https://local/api/log_event',
      method: 'POST',
      email: TEAM_EMAIL,
      body: { action: 'noise', path: '/exports/', meta: { scope: 'unit' } },
    }),
  );
  const disallowedPayload = await asJson(disallowed);
  assert.equal(disallowedPayload.status, 200);
  assert.equal(disallowedPayload.body.skipped, 'not-allowed');
  console.log('equipo log_event (not-allowed) =>', disallowedPayload);

  const sampled = await handleLogEvent(
    buildContext({
      url: 'https://local/api/log_event',
      method: 'POST',
      email: TEAM_EMAIL,
      body: { action: 'page_view', path: '/inbox?view=test' },
    }),
  );
  const sampledPayload = await asJson(sampled);
  assert.equal(sampledPayload.status, 200);
  if (sampledPayload.body.skipped) {
    assert.equal(sampledPayload.body.skipped, 'sampled-out');
  }
  console.log('equipo log_event (page_view) =>', sampledPayload);

  const adminExport = await handleLogEvent(
    buildContext({
      url: 'https://local/api/log_event',
      method: 'POST',
      email: ADMIN_EMAIL,
      body: { action: 'export_run', path: '/exports/latest' },
    }),
  );
  const adminPayload = await asJson(adminExport);
  assert.equal(adminPayload.status, 200);
  assert.ok(adminPayload.body.fallback === true || adminPayload.body.key);
  assert.ok(!adminPayload.body.skipped);
  console.log('admin log_event (export_run) =>', adminPayload);

  const list = await handleLogsList(
    buildContext({
      url: 'https://local/api/logs_list?limit=3',
      method: 'GET',
      email: ADMIN_EMAIL,
    }),
  );
  const listPayload = await asJson(list);
  assert.equal(listPayload.status, 200);
  assert.ok(Array.isArray(listPayload.body.events));
  console.log('admin logs_list =>', listPayload);
}

main().catch((error) => {
  console.error('[test-logs] error', error);
  process.exitCode = 1;
});
