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
  // Usar RNG determinista por acción/rol para evitar aleatoriedad global
  const seed = typeof options.seed === 'string' && options.seed.length
    ? options.seed
    : `${action}|${role}`;
  const rng = typeof options.rng === 'function' ? options.rng : () => stableRandom01(seed);
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

// Hash FNV-1a 32-bit para generar un número determinista por seed
function fnv1a32(str) {
  let h = 0x811c9dc5; // offset basis
  for (let i = 0; i < str.length; i++) {
    h ^= str.charCodeAt(i);
    // Multiplicación por el primo FNV 16777619 con overflow de 32 bits
    h = (h >>> 0) * 0x01000193;
  }
  return h >>> 0;
}

function stableRandom01(seed) {
  const h = fnv1a32(String(seed));
  // Mapear a [0,1)
  return h / 0x100000000; // 2^32
}
