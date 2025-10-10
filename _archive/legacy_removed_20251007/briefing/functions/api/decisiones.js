const JSON_HEADERS = { 'Content-Type': 'application/json' };

const errorResponse = (status, message) =>
  new Response(JSON.stringify({ ok: false, error: message }), { status, headers: JSON_HEADERS });

function isOriginAllowed(request, allowedOrigin) {
  if (!allowedOrigin) return true;
  const originHeader = request.headers.get('Origin') || request.headers.get('Referer');
  if (!originHeader) return true;
  return originHeader.startsWith(allowedOrigin);
}

function getTokenFromRequest(request, bodyToken) {
  const headerToken = request.headers.get('X-Runart-Token');
  return (headerToken || bodyToken || '').trim();
}

function isTokenValid(submitted, expected, allowDevFallback) {
  if (!submitted) return false;
  if (expected && submitted === expected) return true;
  if (allowDevFallback && submitted === 'dev-token') return true;
  return false;
}

export const onRequestPost = async ({ request, env }) => {
  const userEmail = request.headers.get('Cf-Access-Authenticated-User-Email') || 'anon@local';
  const ip = request.headers.get('CF-Connecting-IP') || '0.0.0.0';
  const userAgent = request.headers.get('User-Agent') || 'unknown';

  if (!isOriginAllowed(request, env.ORIGIN_ALLOWED)) {
    return errorResponse(403, 'Origen no permitido.');
  }

  let body;
  try {
    body = await request.json();
  } catch (error) {
    return errorResponse(400, 'JSON inválido o cuerpo ausente.');
  }

  const honeypot = (body.website || '').trim();
  if (honeypot) {
    return errorResponse(400, 'Solicitud rechazada.');
  }

  const submittedToken = getTokenFromRequest(request, body.auth_token);
  const expectedToken = env.EDITOR_TOKEN ? String(env.EDITOR_TOKEN) : '';
  const allowDev = !expectedToken;

  if (!isTokenValid(submittedToken, expectedToken, allowDev)) {
    return errorResponse(401, 'Token inválido o ausente.');
  }

  const decisionId = (body.decision_id || '').trim();
  const tipo = (body.tipo || '').trim();
  if (!decisionId || !tipo) {
    return errorResponse(400, 'decision_id y tipo son obligatorios.');
  }

  const payload = body.payload;
  if (!payload || typeof payload !== 'object') {
    return errorResponse(400, 'payload inválido.');
  }

  const comentario = typeof body.comentario === 'string' ? body.comentario : '';
  const tokenOrigen = body.token_origen || 'editor_v1';
  const originHint = typeof body.origin_hint === 'string' ? body.origin_hint : '';

  const ts = new Date().toISOString();
  const requiresModeration = String(env.MOD_REQUIRED ?? '1') !== '0';
  const initialStatus = requiresModeration ? 'pending' : 'accepted';

  const record = {
    decision_id: decisionId,
    tipo,
    payload,
    comentario,
    token_origen: tokenOrigen,
    ts,
    meta: {
      userEmail,
      ip,
      userAgent,
      createdAt: ts,
      requiresModeration,
      originHint
    },
    moderation: {
      status: initialStatus,
      updatedAt: ts,
      by: requiresModeration ? userEmail : 'auto'
    },
    moderationTrail: [
      {
        status: initialStatus,
        action: initialStatus,
        by: requiresModeration ? userEmail : 'auto',
        at: ts,
        note: requiresModeration
          ? 'Registro pendiente de moderación.'
          : 'Moderación no requerida.'
      }
    ]
  };

  const key = `decision:${decisionId}:${ts}`;

  try {
    await env.DECISIONES.put(key, JSON.stringify(record));
  } catch (error) {
    return errorResponse(500, 'No se pudo registrar la decisión.');
  }

  return new Response(JSON.stringify({ ok: true, status: 'pending' }), {
    status: 200,
    headers: JSON_HEADERS
  });
};
