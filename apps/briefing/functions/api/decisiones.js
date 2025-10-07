import { classifyRole } from '../_middleware.js';

const JSON_HEADERS = Object.freeze({
  'Content-Type': 'application/json',
  'Cache-Control': 'no-store, no-cache, must-revalidate',
  Pragma: 'no-cache'
});

// Endpoint de smoke: requiere usuario autenticado, responde 401 en caso contrario.
export async function onRequestPost(context) {
  const { request } = context;
  const emailHeader = request.headers.get('X-RunArt-Email') || request.headers.get('Cf-Access-Authenticated-User-Email') || '';
  const email = emailHeader.trim();
  const roleHeader = request.headers.get('X-RunArt-Role');
  const role = roleHeader || classifyRole(email);

  if (!email) {
    return new Response(JSON.stringify({ ok: false, status: 401, role: 'visitor' }), {
      status: 401,
      headers: JSON_HEADERS
    });
  }

  return new Response(
    JSON.stringify({ ok: true, status: 200, role, message: 'Solicitud registrada (mock).' }),
    { status: 200, headers: JSON_HEADERS }
  );
}

export async function onRequest(context) {
  if (context.request.method && context.request.method.toUpperCase() !== 'POST') {
    return new Response(JSON.stringify({ ok: false, status: 405 }), {
      status: 405,
      headers: JSON_HEADERS
    });
  }
  return onRequestPost(context);
}
