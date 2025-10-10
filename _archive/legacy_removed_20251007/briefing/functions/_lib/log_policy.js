/**
 * Política de logging — Etapa 6
 * - ALLOWED_ACTIONS: lista blanca de acciones registrables.
 * - sampleHit: decide si un evento se persiste con base en muestreo por acción/rol.
 */
export const ALLOWED_ACTIONS = new Set([
  'page_view',
  'export_run',
  'admin_action',
  'auth_event',
  'custom',
]);

export function isAllowed(action) {
  if (!action) return false;
  return ALLOWED_ACTIONS.has(String(action).trim());
}

export function sampleHit(action, role, options = {}) {
  const percent = samplingPercent(String(action || ''), String(role || 'visitante'));
  if (percent <= 0) return false;
  if (percent >= 100) return true;
  const rng = typeof options.rng === 'function' ? options.rng : randomPercentage;
  return rng() < percent / 100;
}

function samplingPercent(action, role) {
  if (action === 'page_view') {
    return role === 'admin' || role === 'equipo' ? 30 : 0;
  }
  if (action === 'export_run') return 100;
  if (action === 'admin_action') return 100;
  if (action === 'auth_event') return 50;
  if (action === 'custom') return 50;
  return 0;
}

function randomPercentage() {
  if (typeof crypto !== 'undefined' && typeof crypto.getRandomValues === 'function') {
    const buffer = new Uint32Array(1);
    crypto.getRandomValues(buffer);
    return (buffer[0] >>> 0) / 0xffffffff;
  }
  return Math.random();
}
