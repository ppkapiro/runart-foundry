import { getEmailFromRequest, resolveRole } from '../../_utils/roles.js';
import { ensureRolesSync, persistRoles, sanitizeRoles } from '../../_lib/accessStore.js';

const JSON_HEADERS = Object.freeze({
  'Content-Type': 'application/json; charset=utf-8',
  'Cache-Control': 'no-store, no-cache, must-revalidate',
  Pragma: 'no-cache'
});

const asJSON = (payload, status = 200) =>
  new Response(JSON.stringify(payload), {
    status,
    headers: JSON_HEADERS
  });

const extractRoleFromRequest = async (request, env) => {
  const email = (await getEmailFromRequest(request)) || '';
  const trimmed = email.trim();
  const roleHeader = request.headers.get('X-RunArt-Role');
  const role = roleHeader || (await resolveRole(trimmed, env));
  return { email: trimmed, role };
};

const isOwner = (role) => role === 'owner';

const requiresOwner = async (context) => {
  const { request, env } = context;
  const { role } = await extractRoleFromRequest(request, env);
  if (!isOwner(role)) {
    return { error: asJSON({ ok: false, status: 403, role }, 403) };
  }
  return { role };
};

const isValidEmail = (value) => /.+@.+\..+/.test(value);
const isValidDomain = (value) => /^[a-z0-9.-]+\.[a-z]{2,}$/i.test(value);

const validateRolesPayload = (payload) => {
  const sanitized = sanitizeRoles(payload || {});
  const errors = [];

  const invalidOwners = sanitized.owners.filter((value) => !isValidEmail(value));
  const invalidClients = sanitized.clients.filter((value) => !isValidEmail(value));
  const invalidDomains = sanitized.team_domains.filter((value) => !isValidDomain(value));

  if (invalidOwners.length) {
    errors.push({ field: 'owners', message: 'Correos inválidos', values: invalidOwners });
  }
  if (invalidClients.length) {
    errors.push({ field: 'clients', message: 'Correos inválidos', values: invalidClients });
  }
  if (invalidDomains.length) {
    errors.push({ field: 'team_domains', message: 'Dominios inválidos', values: invalidDomains });
  }

  return { sanitized, errors };
};

const READABLE_ROLES = new Set(['owner', 'team', 'client']);

export async function onRequestGet(context) {
  const { request, env } = context;
  const { role } = await extractRoleFromRequest(request, env);

  if (!READABLE_ROLES.has(role)) {
    return asJSON({ ok: false, status: 403, role }, 403);
  }

  const noCache = (request.headers.get('Cache-Control') || '').includes('no-cache');
  const snapshot = await ensureRolesSync(context.env, { force: noCache });
  const issuedAt = new Date().toISOString();

  return asJSON({
    ok: true,
    status: 200,
    source: snapshot.source,
    fetchedAt: snapshot.fetchedAt,
    issuedAt,
    roles: snapshot.roles,
    readOnly: role !== 'owner'
  });
}

export async function onRequestPut(context) {
  const guard = await requiresOwner(context);
  if (guard.error) return guard.error;

  let body;
  try {
    body = await context.request.json();
  } catch (error) {
    return asJSON({ ok: false, status: 400, error: 'JSON inválido' }, 400);
  }

  const candidate = {
    owners: body?.owners ?? body?.roles?.owners ?? [],
    team_domains: body?.team_domains ?? body?.roles?.team_domains ?? [],
    clients: body?.clients ?? body?.roles?.clients ?? []
  };

  const { sanitized, errors } = validateRolesPayload(candidate);
  if (errors.length) {
    return asJSON({ ok: false, status: 400, errors }, 400);
  }

  try {
    const persisted = await persistRoles(context.env, sanitized);
    return asJSON({
      ok: true,
      status: 200,
      updated: true,
      source: persisted.source,
      fetchedAt: persisted.fetchedAt,
      roles: persisted.roles
    });
  } catch (error) {
    console.error('[AdminRoles] Error guardando roles', error);
    return asJSON({ ok: false, status: 500, error: 'No fue posible guardar los roles en KV.' }, 500);
  }
}

export async function onRequest(context) {
  const method = (context.request.method || 'GET').toUpperCase();
  if (method === 'GET') {
    return onRequestGet(context);
  }
  if (method === 'PUT') {
    return onRequestPut(context);
  }
  return asJSON({ ok: false, status: 405 }, 405);
}
