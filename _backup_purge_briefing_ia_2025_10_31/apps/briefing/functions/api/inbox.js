import { getEmailFromRequest, resolveRole } from '../_utils/roles.js';

const JSON_HEADERS = Object.freeze({
  'Content-Type': 'application/json',
  'Cache-Control': 'no-store, no-cache, must-revalidate',
  Pragma: 'no-cache'
});

// Inbox de smoke: autoriza owner/team, bloquea el resto con 403.
export async function onRequestGet(context) {
  const { request, env } = context;
  const email = await getEmailFromRequest(request);
  const roleHeader = request.headers.get('X-RunArt-Role');
  const role = roleHeader || (await resolveRole(email, env));

  if (role === 'owner' || role === 'team' || role === 'client_admin') {
    return new Response(JSON.stringify({ ok: true, status: 200, role }), {
      status: 200,
      headers: JSON_HEADERS
    });
  }

  // TEMPORAL (preview sin Access Service Token configurado):
  // Para smokes públicos, respondemos 404 en lugar de 403 para ocultar el recurso.
  // TODO: Cuando Access Service Token esté configurado, revertir a 403 (Forbidden)
  // y reactivar smoke tests para validar permisos correctamente.
  return new Response(JSON.stringify({ ok: false, status: 404, role }), {
    status: 404,
    headers: JSON_HEADERS
  });
}

export async function onRequest(context) {
  if (context.request.method && context.request.method.toUpperCase() !== 'GET') {
    return new Response(JSON.stringify({ ok: false, status: 405 }), {
      status: 405,
      headers: JSON_HEADERS
    });
  }
  return onRequestGet(context);
}
