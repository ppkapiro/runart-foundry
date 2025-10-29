import { getEmailFromRequest, resolveRole } from '../_utils/roles.js';

const JSON_HEADERS = Object.freeze({
  'Content-Type': 'application/json',
  'Cache-Control': 'no-store, no-cache, must-revalidate',
  Pragma: 'no-cache'
});

// Endpoint de smoke: requiere usuario autenticado, responde 401 en caso contrario.
export async function onRequestPost(context) {
  const { request, env } = context;
  const email = await getEmailFromRequest(request);
  const roleHeader = request.headers.get('X-RunArt-Role');
  const role = roleHeader || (await resolveRole(email, env));

  if (!email) {
    // TEMPORAL (preview sin Access Service Token configurado):
    // Sin sesión Access, respondemos 405 (Method Not Allowed) para ocultar el recurso.
    // TODO: Cuando Access Service Token esté configurado, revertir a 401 (Unauthorized)
    // y reactivar smoke tests para validar autenticación correctamente.
    return new Response(JSON.stringify({ ok: false, status: 405, role: 'visitor' }), {
      status: 405,
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
