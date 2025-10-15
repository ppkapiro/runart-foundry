// TODO: remove in cleanup (ver CI 082 roles-canary)
import { requireAdmin } from '../_lib/guard.js';
import { resolveRole, ROLES } from '../_lib/roles.js';
import { resolveRoleUnifiedDetailed, isCanaryEmail } from '../_shared/roles.shared.js';

const JSON_HEADERS = { 'Content-Type': 'application/json' };

const notFound = () => new Response('Not Found', { status: 404 });

export async function onRequestGet(context) {
  const runEnv = (context.env.RUNART_ENV || '').toLowerCase();
  if (runEnv !== 'preview') return notFound();

  const gate = await requireAdmin(context);
  if (gate?.error) return gate.error;

  const attachDebugHeaders = (response) => {
    if (gate?.debugHeaders) {
      for (const [key, value] of Object.entries(gate.debugHeaders)) {
        response.headers.set(key, value);
      }
    }
    return response;
  };

  const url = new URL(context.request.url);
  const targetEmail = url.searchParams.get('email') || '';
  if (!targetEmail) {
    return attachDebugHeaders(
      new Response(JSON.stringify({ ok: false, error: 'Parámetro "email" requerido' }), {
        status: 400,
        headers: JSON_HEADERS,
      })
    );
  }

  const unifiedMeta = await resolveRoleUnifiedDetailed(targetEmail, context.env);
  const normalizedEmail = unifiedMeta.normalizedEmail || '';
  const legacyRole = resolveRole(normalizedEmail || targetEmail, context.env, { fallback: ROLES.VISITANTE });
  const canary = (await isCanaryEmail(targetEmail, context.env)) ? 1 : 0;

  const payload = {
    ok: true,
    email_normalizado: normalizedEmail,
    fuente: unifiedMeta.origin || 'unknown',
    coincidencia: unifiedMeta.matchedBy || 'fallback',
    rol_unificado: unifiedMeta.role,
    rol_legacy: legacyRole,
    canary_flag: canary,
  };

  return attachDebugHeaders(
    new Response(JSON.stringify(payload, null, 2), {
      status: 200,
      headers: JSON_HEADERS,
    })
  );
}
