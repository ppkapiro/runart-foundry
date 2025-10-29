// TODO: remove in cleanup (ver CI 082 roles-canary)
import { requireAdmin } from '../_lib/guard.js';

const JSON_HEADERS = { 'Content-Type': 'application/json' };
const RUNART_ROLES_KEY = 'runart_roles';

const notFound = () => new Response('Not Found', { status: 404 });

const countRoles = (data) => {
  const counts = Object.create(null);
  const track = (role) => {
    const key = typeof role === 'string' && role.trim() ? role.trim().toLowerCase() : 'unknown';
    counts[key] = (counts[key] || 0) + 1;
  };

  if (!data) return counts;

  if (Array.isArray(data)) {
    for (const entry of data) {
      if (!entry || typeof entry !== 'object') continue;
      track(entry.role || entry.tipo || entry.type);
    }
    return counts;
  }

  for (const value of Object.values(data)) {
    if (!value) continue;
    if (typeof value === 'string') {
      try {
        const parsed = JSON.parse(value);
        if (parsed && typeof parsed === 'object') track(parsed.role || parsed.tipo || parsed.type);
      } catch (_err) {
        // ignora entradas no JSON
      }
      continue;
    }
    if (typeof value === 'object') {
      track(value.role || value.tipo || value.type);
    }
  }

  return counts;
};

export async function onRequestGet(context) {
  const runEnv = (context.env.RUNART_ENV || '').toLowerCase();
  if (runEnv !== 'preview') return notFound();

  const gate = await requireAdmin(context);
  if (gate?.error) return gate.error;

  const attachDebugHeaders = (response) => {
    if (gate?.debugHeaders) {
      for (const [key, value] of Object.entries(gate.debugHeaders)) {
        response.headers.set(key, value);
      }
    }
    return response;
  };

  if (!context.env?.RUNART_ROLES || typeof context.env.RUNART_ROLES.get !== 'function') {
    return attachDebugHeaders(
      new Response(JSON.stringify({ ok: false, error: 'RUNART_ROLES binding no disponible en preview' }), {
        status: 500,
        headers: JSON_HEADERS,
      })
    );
  }

  let snapshot = null;
  try {
    snapshot = await context.env.RUNART_ROLES.get(RUNART_ROLES_KEY, { type: 'json' });
  } catch (error) {
    return attachDebugHeaders(
      new Response(JSON.stringify({ ok: false, error: 'No se pudo leer RUNART_ROLES', detalle: String(error) }), {
        status: 500,
        headers: JSON_HEADERS,
      })
    );
  }

  const counts = countRoles(snapshot);
  const payload = {
    ok: true,
    total_roles: Object.values(counts).reduce((acc, value) => acc + value, 0),
    conteo: counts,
  };

  return attachDebugHeaders(
    new Response(JSON.stringify(payload, null, 2), {
      status: 200,
      headers: JSON_HEADERS,
    })
  );
}
