import { resolveRole, roleSatisfies, ROLES } from './roles.js';

const JSON_HEADERS = { 'Content-Type': 'application/json' };

const buildError = (status, message, extra = {}) =>
  new Response(JSON.stringify({ ok: false, error: message, ...extra }), {
    status,
    headers: JSON_HEADERS,
  });

const shouldAllowDevOverride = (env) => {
  const raw = env?.ACCESS_DEV_OVERRIDE || env?.DEV_ACCESS_OVERRIDE;
  if (!raw) return false;
  return ['1', 'true', 'yes', 'on'].includes(String(raw).trim().toLowerCase());
};

const extractDevRole = (request) => {
  const header =
    request.headers.get('X-Runart-Dev-Role') || request.headers.get('X-Runart-Role');
  return header ? header.trim().toLowerCase() : '';
};

export const guardRequest = (context, allowedRoles = [], options = {}) => {
  const { request, env } = context;
  const email = request.headers.get('Cf-Access-Authenticated-User-Email') || '';
  let role = resolveRole(email, env, { fallback: ROLES.VISITANTE });

  if (shouldAllowDevOverride(env)) {
    const forced = extractDevRole(request);
    if (forced) role = forced;
  }

  if (!roleSatisfies(role, allowedRoles)) {
    const meta = { role };
    if (email) meta.email = email;
    return { error: buildError(403, 'Acceso restringido', meta) };
  }

  return { email, role };
};

export const requireTeam = (context, options = {}) =>
  guardRequest(context, options.roles || [ROLES.ADMIN, ROLES.EQUIPO], options);

export const requireAdmin = (context, options = {}) =>
  guardRequest(context, options.roles || [ROLES.ADMIN], options);

export { ROLES } from './roles.js';