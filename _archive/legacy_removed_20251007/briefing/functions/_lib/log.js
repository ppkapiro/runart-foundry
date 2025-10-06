import { isAllowed, sampleHit } from './log_policy.js';

const EMAIL_MASK = '***';
const TTL_SECONDS = 60 * 60 * 24 * 30; // 30 días
const META_MAX_LEN = 2000;

export function maskEmail(email) {
  if (!email) return '';
  const parts = String(email).split('@');
  if (parts.length !== 2) return EMAIL_MASK;
  const user = parts[0] || '*';
  const domain = parts[1] || '';
  const head = user.charAt(0) || '*';
  return `${head}${EMAIL_MASK}@${domain}`;
}

function normalizeMeta(meta) {
  if (!meta || typeof meta !== 'object') return {};
  try {
    const raw = JSON.stringify(meta);
    if (raw.length > META_MAX_LEN) {
      return { truncated: true };
    }
    return JSON.parse(raw);
  } catch (error) {
    console.warn('[log:meta-error]', error);
    return {};
  }
}

function buildEventPayload(evt = {}) {
  const ts = evt.ts || new Date().toISOString();
  return {
    ts,
    role: evt.role || 'visitante',
    email: maskEmail(evt.email || ''),
    path: typeof evt.path === 'string' ? evt.path : '',
    action: evt.action || 'unknown',
    meta: normalizeMeta(evt.meta),
  };
}

export async function putEvent(context, evt = {}) {
  const action = typeof evt?.action === 'string' ? evt.action.trim() : 'unknown';
  const role = evt?.role || 'visitante';

  if (!isAllowed(action)) {
    return { ok: true, skipped: 'not-allowed', action };
  }

  if (!sampleHit(action, role)) {
    return { ok: true, skipped: 'sampled-out', action, role };
  }

  const payload = buildEventPayload({ ...evt, action, role });

  try {
    const store = context?.env?.LOG_EVENTS;
    if (!store) {
      console.warn('[log:fallback]', payload);
      return { ok: true, fallback: true };
    }

    const key = `evt:${payload.ts}:${Math.random().toString(36).slice(2, 8)}`;
    await store.put(key, JSON.stringify(payload), {
      expirationTtl: TTL_SECONDS,
    });
    return { ok: true, key };
  } catch (error) {
    console.warn('[log:error]', error);
    return { ok: false, error: String(error), fallback: !context?.env?.LOG_EVENTS };
  }
}

export async function listEvents(context, limit = 50) {
  const store = context?.env?.LOG_EVENTS;
  if (!store) return { ok: true, fallback: true, events: [] };

  const capped = Number.isFinite(limit) ? Math.max(1, Math.min(200, limit)) : 50;
  const list = await store.list({ prefix: 'evt:' });
  const keys = Array.isArray(list?.keys) ? list.keys : [];
  keys.sort((a, b) => (a.name < b.name ? 1 : -1));

  const events = [];
  for (const { name } of keys.slice(0, capped)) {
    try {
      const raw = await store.get(name);
      if (!raw) continue;
      events.push(JSON.parse(raw));
    } catch (error) {
      console.warn('[log:parse-error]', name, error);
    }
  }

  return { ok: true, events };
}
