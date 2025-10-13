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

<<<<<<< HEAD
  if (role === 'owner' || role === 'team') {
=======
  if (role === 'owner' || role === 'team' || role === 'client_admin') {
>>>>>>> chore/bootstrap-git
    return new Response(JSON.stringify({ ok: true, status: 200, role }), {
      status: 200,
      headers: JSON_HEADERS
    });
  }

  return new Response(JSON.stringify({ ok: false, status: 403, role }), {
    status: 403,
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
