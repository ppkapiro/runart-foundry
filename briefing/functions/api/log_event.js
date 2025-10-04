import { requireTeam } from '../_lib/guard.js';
import { putEvent } from '../_lib/log.js';

const JSON_HEADERS = { 'Content-Type': 'application/json' };

const ok = (data = {}) =>
  new Response(JSON.stringify({ ok: true, ...data }), {
    status: 200,
    headers: JSON_HEADERS,
  });

const bad = (status, message) =>
  new Response(JSON.stringify({ ok: false, error: message }), {
    status,
    headers: JSON_HEADERS,
  });

export async function onRequestPost(context) {
  const gate = requireTeam(context);
  if (gate?.error) return gate.error;

  let body = {};
  try {
    body = await context.request.json();
  } catch (error) {
    return bad(400, 'JSON inválido o cuerpo ausente.');
  }

  const { path = '', action = 'custom', meta = {} } = body || {};
  if (typeof action !== 'string' || !action.trim()) {
    return bad(400, 'El campo "action" es obligatorio.');
  }

  const { email, role } = gate;
  const result = await putEvent(context, {
    email,
    role,
    path: typeof path === 'string' ? path : '',
    action: action.trim(),
    meta: meta && typeof meta === 'object' ? meta : {},
  });

  if (!result?.ok) {
    return new Response(JSON.stringify(result || { ok: false }), {
      status: 500,
      headers: JSON_HEADERS,
    });
  }

  const payload = { fallback: Boolean(result.fallback) };
  if (result.key) payload.key = result.key;
  if (result.skipped) payload.skipped = result.skipped;
  if (result.skipped && result.action) payload.action = result.action;
  return ok(payload);
}
