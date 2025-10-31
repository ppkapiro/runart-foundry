import staticRoles from "../../access/roles.json" assert { type: "json" };

const RUNART_ROLES_KEY = "runart_roles";
const CACHE_TTL_MS = 30 * 1000;

const normalizeValue = (value) => (typeof value === "string" ? value.trim().toLowerCase() : "");

const normalizeCollection = (collection, { treatAsDomain = false } = {}) => {
  if (!Array.isArray(collection)) return [];
  const seen = new Set();
  const result = [];

  for (const raw of collection) {
    const normalized = normalizeValue(raw);
    if (!normalized) continue;

    const value = treatAsDomain
      ? normalized.includes("@")
        ? normalized.split("@").pop()
        : normalized
      : normalized;

    if (seen.has(value)) continue;
    seen.add(value);
    result.push(value);
  }

  return result;
};

const extractList = (roles, keys = []) => {
  for (const key of keys) {
    if (Array.isArray(roles?.[key])) return roles[key];
  }
  return [];
};

const buildRolesState = (roles) => {
  const owners = normalizeCollection(extractList(roles, ["owners", "owner", "admins", "administradores"]));
  const clientAdmins = normalizeCollection(
    extractList(roles, ["client_admins", "clientes_admin", "clientes_admins", "admin_clients"])
  );
  const clients = normalizeCollection(extractList(roles, ["clients", "clientes", "client"]));
  const team = normalizeCollection(extractList(roles, ["team", "teams", "equipo"]));
  const teamDomains = normalizeCollection(extractList(roles, ["team_domains", "equipo_domains", "domains_equipo"]), {
    treatAsDomain: true,
  });

  return {
    owners,
    client_admins: clientAdmins,
    clients,
    team,
    team_domains: teamDomains,
    ownersSet: new Set(owners),
    clientAdminsSet: new Set(clientAdmins),
    clientsSet: new Set(clients),
    teamSet: new Set(team),
    teamDomainsSet: new Set(teamDomains),
  };
};

let cachedRoles = buildRolesState(staticRoles);
let cacheTimestamp = 0;
let cacheSource = "static";

const getDomain = (email) => {
  if (!email || !email.includes("@")) return null;
  return email.split("@").pop().toLowerCase();
};

const parseCsv = (value) => {
  if (!value) return [];
  return value
    .split(",")
    .map((item) => normalizeValue(item))
    .filter(Boolean);
};

const loadRoles = async (env) => {
  if (!env?.RUNART_ROLES) {
    cacheSource = "static";
    return cachedRoles;
  }

  const now = Date.now();
  if (now - cacheTimestamp < CACHE_TTL_MS && cacheSource !== "static-missing") {
    return cachedRoles;
  }

  try {
    const stored = await env.RUNART_ROLES.get(RUNART_ROLES_KEY, { type: "json" });
    if (stored) {
      cachedRoles = buildRolesState(stored);
      cacheSource = "kv";
      cacheTimestamp = now;
      return cachedRoles;
    }
  } catch (error) {
    console.warn("[roles] No se pudo leer RUNART_ROLES", error);
  }

  cachedRoles = buildRolesState(staticRoles);
  cacheSource = "static-missing";
  cacheTimestamp = now;
  return cachedRoles;
};

export async function getEmailFromRequest(request) {
  return (
    request.headers.get("x-runart-email") ||
    request.headers.get("X-RunArt-Test-Email") ||
    request.headers.get("cf-access-authenticated-user-email") ||
    request.headers.get("cf-access-email") ||
    null
  );
}

export async function resolveRole(email, env) {
  if (!email) return "visitor";

  const normalizedEmail = normalizeValue(email);
  if (!normalizedEmail) return "visitor";

  const admins = parseCsv(env?.ACCESS_ADMINS);
  if (admins.includes(normalizedEmail)) return "owner";

  const clientAdminsEnv = parseCsv(env?.ACCESS_CLIENT_ADMINS);
  if (clientAdminsEnv.includes(normalizedEmail)) return "client_admin";

  const roles = await loadRoles(env);

  if (roles.ownersSet.has(normalizedEmail)) return "owner";
  if (roles.clientAdminsSet?.has(normalizedEmail)) return "client_admin";
  if (roles.clientsSet.has(normalizedEmail)) return "client";
  if (roles.teamSet.has(normalizedEmail)) return "team";

  const domain = getDomain(normalizedEmail);
  if (domain && roles.teamDomainsSet.has(domain)) return "team";

  return "visitor";
}

const ROLE_ALIASES = {
  owner: "propietario",
  client_admin: "cliente_admin",
  client: "cliente",
  team: "equipo",
  visitor: "visitante",
};

export function roleToAlias(role) {
  return ROLE_ALIASES[role] || ROLE_ALIASES.visitor;
}

// API extendida: igual que resolveRole pero devuelve metadatos útiles
// Contracto:
//  - input: (email: string | null, env: Env)
//  - output: { role: string, alias: string, source: 'kv'|'static'|'static-missing', email: string|null }
export async function resolveRoleWithMeta(email, env) {
  const role = await resolveRole(email, env);
  const alias = roleToAlias(role);
  // cacheSource refleja de dónde provino la última carga (kv, static, static-missing)
  return { role, alias, source: cacheSource, email: email || null };
}

export async function logEvent(env, kind, payload = {}) {
  try {
    const ts = new Date().toISOString();
    const data = JSON.stringify({ ts, kind, ...payload });
    const suffix = hash6(`${ts}|${kind}|${data}`);
    const key = `evt:${ts}:${suffix}`;
    if (env?.LOG_EVENTS && env.LOG_EVENTS.put) {
      await env.LOG_EVENTS.put(key, data, { expirationTtl: 60 * 60 * 24 * 30 });
    }
  } catch (error) {
    console.warn("[roles] No se pudo registrar evento", error);
  }
}

function hash6(str) {
  let h = 0x811c9dc5;
  for (let i = 0; i < str.length; i++) {
    h ^= str.charCodeAt(i);
    h = (h >>> 0) * 0x01000193;
  }
  const v = h >>> 0;
  return v.toString(36).slice(0, 6);
}

export function isPublicPath(pathname) {
  if (
    pathname.startsWith("/api/") ||
    pathname.startsWith("/assets/") ||
    pathname.startsWith("/static/") ||
    pathname.startsWith("/favicon") ||
    pathname.startsWith("/_")
  ) {
    return true;
  }
  return false;
}

export function roleFromPath(pathname) {
  const match = pathname.match(/^\/dash\/([a-z]+)/i);
  return match ? match[1].toLowerCase() : null;
}
