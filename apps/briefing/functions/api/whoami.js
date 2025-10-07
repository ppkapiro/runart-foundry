import { classifyRole } from '../_middleware.js';

const JSON_HEADERS = Object.freeze({
  'Content-Type': 'application/json',
  'Cache-Control': 'no-store, no-cache, must-revalidate',
  Pragma: 'no-cache'
});

// WhoAmI expone el contrato básico de Access: email, rol y entorno actual.
export async function onRequestGet(context) {
  const { request, env } = context;
  const emailHeader = request.headers.get('X-RunArt-Email') || request.headers.get('Cf-Access-Authenticated-User-Email') || '';
  const email = emailHeader.trim();
  const roleHeader = request.headers.get('X-RunArt-Role');
  const role = roleHeader || classifyRole(email);
  const envValue = String(env?.RUNART_ENV || '').trim() || 'local';

  return new Response(
    JSON.stringify({ ok: true, email, role, env: envValue, ts: new Date().toISOString() }),
    { headers: JSON_HEADERS }
  );
}
