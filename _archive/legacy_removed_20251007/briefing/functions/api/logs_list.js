import { requireAdmin } from '../_lib/guard.js';
import { listEvents } from '../_lib/log.js';

const JSON_HEADERS = { 'Content-Type': 'application/json' };

const ok = (data = {}) =>
  new Response(JSON.stringify({ ok: true, ...data }), {
    status: 200,
    headers: JSON_HEADERS,
  });

export async function onRequestGet(context) {
  const gate = requireAdmin(context);
  if (gate?.error) return gate.error;

  const url = new URL(context.request.url);
  const rawLimit = Number(url.searchParams.get('limit') || 50);
  const limit = Number.isFinite(rawLimit) ? Math.max(1, Math.min(200, rawLimit)) : 50;

  const result = await listEvents(context, limit);
  if (!result?.ok) {
    return new Response(JSON.stringify(result || { ok: false }), {
      status: 500,
      headers: JSON_HEADERS,
    });
  }

  return ok({ events: result.events || [], fallback: result.fallback || false });
}
