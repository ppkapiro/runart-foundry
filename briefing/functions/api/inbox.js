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

export const onRequestGet = async ({ env, request }) => {
  const userEmail = request.headers.get('Cf-Access-Authenticated-User-Email');
  const isModerator = Boolean(userEmail);

  if (!isOriginAllowed(request, env.ORIGIN_ALLOWED)) {
    return errorResponse(403, 'Origen no permitido.');
  }

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

    const filtered = isModerator
      ? items
      : items.filter((item) => item?.moderation?.status === 'accepted');

    return new Response(
      JSON.stringify({
        ok: true,
        total: filtered.length,
        visibility: isModerator ? 'all' : 'accepted',
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
