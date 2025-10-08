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
  return rules.some((rx) => rx.test(pathname));
}
