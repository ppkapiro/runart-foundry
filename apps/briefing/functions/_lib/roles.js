const normalize = (value) => (value || '').trim().toLowerCase();

const splitList = (value) => {
  if (!value) return [];
  if (Array.isArray(value)) return value.map(normalize).filter(Boolean);
  return String(value)
    .split(',')
    .map(normalize)
    .filter(Boolean);
};

const ROLE_HIERARCHY = ['visitante', 'cliente', 'equipo', 'admin'];

const normalizeRole = (role) => {
  const map = {
    administrator: 'admin',
    staff: 'equipo',
    team: 'equipo',
    internal: 'equipo',
    publico: 'public',
    publico_total: 'public',
    publico_totalmente: 'public',
    publico_general: 'public',
    publico_cliente: 'cliente',
    cliente: 'cliente',
    clientes: 'cliente',
    publico_cliente_equipo: 'cliente',
    publico_cliente_admin: 'cliente',
    publico_admin: 'admin',
    publico_equipo: 'equipo',
    publico_equipo_admin: 'equipo',
    publico_admin_equipo: 'equipo',
    publico_admin_cliente: 'cliente',
  };
  const normalized = normalize(role);
  return map[normalized] || normalized;
};

const expandAllowed = (allowed) => {
  const roles = new Set();
  const normalized = splitList(allowed).map(normalizeRole);

  if (!normalized.length) return roles;

  for (const role of normalized) {
    if (role === 'public' || role === '*' || role === 'any') {
      normalized.push('cliente');
      normalized.push('equipo');
      normalized.push('admin');
      normalized.push('visitante');
      break;
    }
  }

  for (const role of normalized) {
    if (ROLE_HIERARCHY.includes(role)) {
      roles.add(role);
      continue;
    }
    if (role === 'equipo') {
      roles.add('equipo');
      roles.add('admin');
      continue;
    }
    if (role === 'cliente') {
      roles.add('cliente');
      roles.add('equipo');
      roles.add('admin');
      continue;
    }
    if (role === 'admin') {
      roles.add('admin');
      continue;
    }
    if (role === 'visitante') {
      roles.add('visitante');
      roles.add('cliente');
      roles.add('equipo');
      roles.add('admin');
      continue;
    }
  }

  return roles;
};

export const ROLES = Object.freeze({
  ADMIN: 'admin',
  EQUIPO: 'equipo',
  CLIENTE: 'cliente',
  VISITANTE: 'visitante',
});

export function resolveRole(email, env = {}, options = {}) {
  const fallback = options.fallback || ROLES.VISITANTE;
  const normalizedEmail = normalize(email);

  if (!normalizedEmail) return fallback;

  const admins = splitList(env.ACCESS_ADMINS);
  if (admins.includes(normalizedEmail)) return ROLES.ADMIN;

  const explicitEquipo = splitList(env.ACCESS_EQUIPO_EMAILS || env.ACCESS_TEAM_EMAILS);
  if (explicitEquipo.includes(normalizedEmail)) return ROLES.EQUIPO;

  const domain = normalizedEmail.includes('@') ? normalizedEmail.split('@').pop() : '';
  const equipoDomains = splitList(env.ACCESS_EQUIPO_DOMAINS || env.ACCESS_TEAM_DOMAINS);
  if (domain && equipoDomains.includes(domain)) return ROLES.EQUIPO;

  const clientEmails = splitList(
    env.ACCESS_CLIENT_EMAILS || env.ACCESS_CLIENTS || env.ACCESS_CLIENTES || env.ACCESS_CUSTOMERS,
  );
  if (clientEmails.includes(normalizedEmail)) return ROLES.CLIENTE;

  return ROLES.CLIENTE;
}

export function roleSatisfies(role, allowedRoles = []) {
  const normalizedRole = normalizeRole(role) || ROLES.VISITANTE;
  const allowedSet = expandAllowed(allowedRoles);
  if (!allowedSet.size) return true;
  return allowedSet.has(normalizedRole);
}

export const isTeam = (role) => {
  const normalizedRole = normalizeRole(role);
  return normalizedRole === ROLES.EQUIPO || normalizedRole === ROLES.ADMIN;
};

export const describeAccess = (allowedRoles = []) => {
  const allowedSet = expandAllowed(allowedRoles);
  if (!allowedSet.size) return 'public';
  if (allowedSet.has('visitante')) return 'public';
  if (!allowedSet.has('cliente') && allowedSet.has('equipo') && allowedSet.has('admin'))
    return 'interno-equipo';
  if (allowedSet.has('cliente')) return 'cliente';
  if (allowedSet.has('admin') && !allowedSet.has('equipo')) return 'solo-admin';
  return Array.from(allowedSet).join(',');
};

export function getRoleFromHeaders(request) {
  const header = request.headers.get('Cf-Access-Authenticated-User-Email') || '';
  return normalize(header);
}