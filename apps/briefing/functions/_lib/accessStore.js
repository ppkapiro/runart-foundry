<<<<<<< HEAD
import staticRoles from '../../access/roles.json' assert { type: 'json' };
=======
import staticRoles from '../../access/roles.json' with { type: 'json' };
>>>>>>> chore/bootstrap-git

const normalize = (value) => (value || '').trim().toLowerCase();
const KEY = 'runart_roles';
const CACHE_TTL_MS = 30 * 1000;

const sanitizeCollection = (input) => {
  if (!Array.isArray(input)) return [];
  const seen = new Set();
  const result = [];
  for (const raw of input) {
    if (typeof raw !== 'string') continue;
    const value = raw.trim();
    if (!value) continue;
    const key = value.toLowerCase();
    if (seen.has(key)) continue;
    seen.add(key);
    result.push(value);
  }
  return result;
};

const sanitizeRoles = (roles) => ({
  owners: sanitizeCollection(roles?.owners || []),
<<<<<<< HEAD
  team_domains: sanitizeCollection(roles?.team_domains || []),
  clients: sanitizeCollection(roles?.clients || [])
=======
  client_admins: sanitizeCollection(roles?.client_admins || []),
  clients: sanitizeCollection(roles?.clients || []),
  team: sanitizeCollection(roles?.team || []),
  team_domains: sanitizeCollection(roles?.team_domains || []),
>>>>>>> chore/bootstrap-git
});

const state = {
  roles: sanitizeRoles(staticRoles),
  ownersSet: new Set(),
<<<<<<< HEAD
  teamDomainsSet: new Set(),
  clientsSet: new Set(),
=======
  teamSet: new Set(),
  teamDomainsSet: new Set(),
  clientsSet: new Set(),
  clientAdminsSet: new Set(),
>>>>>>> chore/bootstrap-git
  source: 'roles.json',
  lastSync: 0
};

const applyRolesToState = (roles, source = 'roles.json') => {
  const sanitized = sanitizeRoles(roles);
  state.roles = sanitized;
  state.ownersSet = new Set(sanitized.owners.map(normalize));
<<<<<<< HEAD
=======
  state.clientAdminsSet = new Set(sanitized.client_admins.map(normalize));
  state.teamSet = new Set(sanitized.team.map(normalize));
>>>>>>> chore/bootstrap-git
  state.teamDomainsSet = new Set(sanitized.team_domains.map(normalize));
  state.clientsSet = new Set(sanitized.clients.map(normalize));
  state.source = source;
  state.lastSync = Date.now();
  return sanitized;
};

applyRolesToState(state.roles, 'roles.json');

export const classifyEmail = (email) => {
  const normalizedEmail = normalize(email);
  if (!normalizedEmail) return 'visitor';
  if (state.ownersSet.has(normalizedEmail)) return 'owner';

<<<<<<< HEAD
  const domain = normalizedEmail.split('@').pop();
  if (domain && state.teamDomainsSet.has(domain)) return 'team';

  if (state.clientsSet.has(normalizedEmail)) return 'client';
=======
  if (state.clientAdminsSet.has(normalizedEmail)) return 'client_admin';
  if (state.clientsSet.has(normalizedEmail)) return 'client';
  if (state.teamSet.has(normalizedEmail)) return 'team';

  const domain = normalizedEmail.split('@').pop();
  if (domain && state.teamDomainsSet.has(domain)) return 'team';
>>>>>>> chore/bootstrap-git
  return 'visitor';
};

const fetchRolesFromKV = async (env) => {
  if (!env?.RUNART_ROLES) return null;
  try {
    const result = await env.RUNART_ROLES.get(KEY, { type: 'json' });
    if (!result) return null;
    return result;
  } catch (error) {
    console.warn('[AccessStore] No se pudo leer RUNART_ROLES', error);
    return null;
  }
};

export const ensureRolesSync = async (env, { force = false } = {}) => {
  if (!env?.RUNART_ROLES) {
    if (state.source !== 'roles.json') {
      applyRolesToState(state.roles, 'roles.json');
    }
    return { roles: { ...state.roles }, source: state.source, fetchedAt: state.lastSync };
  }

  const now = Date.now();
  if (!force && now - state.lastSync < CACHE_TTL_MS && state.source !== 'roles.json-missing') {
    return { roles: { ...state.roles }, source: state.source, fetchedAt: state.lastSync };
  }

  const kvRoles = await fetchRolesFromKV(env);
  if (kvRoles) {
    applyRolesToState(kvRoles, 'kv');
    return { roles: { ...state.roles }, source: state.source, fetchedAt: state.lastSync };
  }

  // Seed KV con los roles actuales para asegurar consistencia futura.
  try {
    await env.RUNART_ROLES.put(KEY, JSON.stringify(state.roles, null, 2));
    state.source = 'roles.json';
    state.lastSync = Date.now();
  } catch (error) {
    console.warn('[AccessStore] No se pudo sembrar RUNART_ROLES', error);
    state.source = 'roles.json-missing';
    state.lastSync = Date.now();
  }

  return { roles: { ...state.roles }, source: state.source, fetchedAt: state.lastSync };
};

export const persistRoles = async (env, roles) => {
  if (!env?.RUNART_ROLES) {
    throw new Error('RUNART_ROLES binding no configurado');
  }
  const sanitized = sanitizeRoles(roles);
  await env.RUNART_ROLES.put(KEY, JSON.stringify(sanitized, null, 2));
  applyRolesToState(sanitized, 'kv');
  return { roles: { ...state.roles }, source: state.source, fetchedAt: state.lastSync };
};

export const getRolesSnapshot = () => ({
  roles: { ...state.roles },
  source: state.source,
  fetchedAt: state.lastSync
});

export const getRolesKey = () => KEY;
export { sanitizeRoles };
