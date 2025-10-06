import { resolveRole, ROLES } from '../_lib/roles';

export async function onRequestGet(context) {
  const { request, env } = context;
  const email = request.headers.get('Cf-Access-Authenticated-User-Email') || '';
  const role = resolveRole(email, env, { fallback: ROLES.VISITANTE });
  const envSource =
    (typeof process !== 'undefined' && process.env && process.env.RUNART_ENV) ||
    env?.RUNART_ENV ||
    'local';
  const resolvedEnv = String(envSource).trim().toLowerCase();

  return new Response(
    JSON.stringify({ email, role, env: resolvedEnv, ts: new Date().toISOString() }),
    {
      headers: { 'Content-Type': 'application/json' },
    },
  );
}
