<<<<<<< HEAD
/**
 * ACL simple para dashboards: define qué rutas /dash/* están permitidas por rol.
 * Si no está permitido, el middleware responderá 403 (o redirigirá según configuración).
 */
export const ACL = {
  owner: [/^\/dash\/owner$/i, /^\/dash\/visitante$/i],
  equipo: [/^\/dash\/equipo$/i, /^\/dash\/visitante$/i],
  cliente: [/^\/dash\/cliente$/i, /^\/dash\/visitante$/i],
  visitante: [/^\/dash\/visitante$/i],
};

export function isAllowed(role, pathname) {
  const rules = ACL[role] || [];
=======
const ROLE_MAP = {
  owner: "owner",
  admin: "owner",
  client_admin: "client_admin",
  client: "client",
  team: "team",
  equipo: "team",
  visitor: "visitor",
  visitante: "visitor",
  cliente: "client",
};

const DASHBOARD_RULES = {
  owner: [/^\/dash\/owner$/i, /^\/dash\/client$/i, /^\/dash\/team$/i, /^\/dash\/visitor$/i, /^\/dash\/cliente$/i, /^\/dash\/equipo$/i, /^\/dash\/visitante$/i],
  client_admin: [/^\/dash\/client$/i, /^\/dash\/cliente$/i, /^\/dash\/visitor$/i, /^\/dash\/visitante$/i],
  client: [/^\/dash\/client$/i, /^\/dash\/cliente$/i, /^\/dash\/visitor$/i, /^\/dash\/visitante$/i],
  team: [/^\/dash\/team$/i, /^\/dash\/equipo$/i, /^\/dash\/visitor$/i, /^\/dash\/visitante$/i],
  visitor: [/^\/dash\/visitor$/i, /^\/dash\/visitante$/i],
};

export function normalizeRoleForAcl(role) {
  const key = (role || "visitor").toLowerCase();
  return ROLE_MAP[key] || "visitor";
}

export function isAllowed(role, pathname) {
  const normalized = normalizeRoleForAcl(role);
  const rules = DASHBOARD_RULES[normalized] || DASHBOARD_RULES.visitor;
>>>>>>> chore/bootstrap-git
  return rules.some((rx) => rx.test(pathname));
}
