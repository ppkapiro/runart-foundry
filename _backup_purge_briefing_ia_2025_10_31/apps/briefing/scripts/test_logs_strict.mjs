import { onRequestPost as logPost } from '../functions/api/log_event.js';
import { onRequestGet as listGet } from '../functions/api/logs_list.js';

const ADMINS = 'tu@correo.com,otra@correo.com';
const TEAM_DOMAINS = 'runart.com,studio.com';

function buildContext(email, method = 'POST', body = {}) {
  const headers = new Headers();
  if (email) headers.set('Cf-Access-Authenticated-User-Email', email);
  const url = method === 'GET' ? 'https://x/api/logs_list?limit=2' : 'https://x/api/log_event';
  const init = { method, headers };
  if (method === 'POST') {
    headers.set('Content-Type', 'application/json');
    init.body = JSON.stringify(body);
  }

  return {
    env: {
      ACCESS_ADMINS: ADMINS,
      ACCESS_EQUIPO_DOMAINS: TEAM_DOMAINS,
      // LOG_EVENTS no se define en CI → log_event entra en modo fallback controlado
    },
    request: new Request(url, init),
  };
}

async function assertStatus(label, response, expected = 200) {
  if (!(response instanceof Response)) {
    throw new Error(`[${label}] respuesta inválida`);
  }
  const text = await response.text();
  if (response.status !== expected) {
    throw new Error(`[${label}] status ${response.status} ≠ ${expected}: ${text}`);
  }
  console.log(`${label}:`, response.status, text);
  return text;
}

async function run() {
  await assertStatus(
    'log_event not-allowed',
    await logPost(buildContext('alguien@runart.com', 'POST', { action: 'noise', path: '/x' })),
  );

  await assertStatus(
    'log_event page_view',
    await logPost(buildContext('alguien@runart.com', 'POST', { action: 'page_view', path: '/inbox' })),
  );

  await assertStatus(
    'log_event export_run',
    await logPost(buildContext('tu@correo.com', 'POST', { action: 'export_run', path: '/exports' })),
  );

  await assertStatus(
    'logs_list admin',
    await listGet(buildContext('tu@correo.com', 'GET')),
  );
}

run().catch((error) => {
  console.error('[test-logs-strict] error', error);
  process.exitCode = 1;
});
