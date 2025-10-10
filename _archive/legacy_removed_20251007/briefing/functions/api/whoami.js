import { resolveRole, ROLES } from '../_lib/roles';

export async function onRequestGet(context) {
  const { request, env } = context;
  const email = request.headers.get('Cf-Access-Authenticated-User-Email') || '';
  const role = resolveRole(email, env, { fallback: ROLES.VISITANTE });

  return new Response(
    JSON.stringify({ email, role, ts: new Date().toISOString() }),
    {
      headers: { 'Content-Type': 'application/json' },
    },
  );
}
