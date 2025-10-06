import { guardRequest, ROLES } from '../_lib/guard.js';

const JSON_HEADERS = { 'Content-Type': 'application/json' };

const errorResponse = (status, message) =>
  new Response(JSON.stringify({ ok: false, error: message }), { status, headers: JSON_HEADERS });

const isOriginAllowed = (request, allowedOrigin) => {
  if (!allowedOrigin) return true;
  const originHeader = request.headers.get('Origin') || request.headers.get('Referer');
  if (!originHeader) return true;
  return originHeader.startsWith(allowedOrigin);
};

const parseDecision = (raw, name) => {
  try {
    const parsed = JSON.parse(raw);
    return { ...parsed, _kvKey: name };
  } catch (error) {
    return {
      ts: new Date().toISOString(),
      moderation: { status: 'pending' },
      meta: { parseError: true },
      _kvKey: name
    };
  }
};

export const onRequestGet = async (context) => {
  const { env, request } = context;

  if (!isOriginAllowed(request, env.ORIGIN_ALLOWED)) {
    return errorResponse(403, 'Origen no permitido.');
  }

  const { email = '', role, error } = guardRequest(context, [ROLES.ADMIN, ROLES.EQUIPO, ROLES.CLIENTE]);
  if (error) return error;

  try {
    const list = await env.DECISIONES.list({ prefix: 'decision:' });
    const items = [];
    for (const { name } of list.keys) {
      const stored = await env.DECISIONES.get(name);
      if (!stored) continue;
      items.push(parseDecision(stored, name));
    }

    items.sort((a, b) => {
      const aTs = a?.meta?.createdAt || a.ts || '';
      const bTs = b?.meta?.createdAt || b.ts || '';
      return aTs < bTs ? 1 : -1;
    });

    let filtered = items;
    if (role !== ROLES.ADMIN && role !== ROLES.EQUIPO) {
      const normalizedEmail = (email || '').toLowerCase();
      filtered = filtered
        .filter((item) => (item?.moderation?.status || '').toLowerCase() === 'accepted')
        .filter((item) => {
          const owner = (item?.meta?.userEmail || item?.meta?.email || '').toLowerCase();
          return normalizedEmail && owner === normalizedEmail;
        });
    }

    return new Response(
      JSON.stringify({
        ok: true,
        total: filtered.length,
        visibility: role === ROLES.ADMIN || role === ROLES.EQUIPO ? 'all' : 'own',
        items: filtered
      }),
      {
        status: 200,
        headers: JSON_HEADERS
      }
    );
  } catch (error) {
    return errorResponse(500, 'No se pudo obtener el inbox.');
  }
};
