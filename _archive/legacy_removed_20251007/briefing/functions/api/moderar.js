const JSON_HEADERS = { 'Content-Type': 'application/json' };

const errorResponse = (status, message) =>
  new Response(JSON.stringify({ ok: false, error: message }), { status, headers: JSON_HEADERS });

const isOriginAllowed = (request, allowedOrigin) => {
  if (!allowedOrigin) return true;
  const originHeader = request.headers.get('Origin') || request.headers.get('Referer');
  if (!originHeader) return true;
  return originHeader.startsWith(allowedOrigin);
};

const getTokenFromRequest = (request, bodyToken) => {
  const headerToken = request.headers.get('X-Runart-Token');
  return (headerToken || bodyToken || '').trim();
};

const isTokenValid = (submitted, expected, allowDevFallback) => {
  if (!submitted) return false;
  if (expected && submitted === expected) return true;
  if (allowDevFallback && submitted === 'dev-token') return true;
  return false;
};

const normalizeAction = (action = '') => {
  const map = {
    accept: 'accepted',
    aceptar: 'accepted',
    reject: 'rejected',
    rechazar: 'rejected',
    revert: 'pending',
    pendiente: 'pending',
    pending: 'pending'
  };
  return map[action.trim().toLowerCase()] || null;
};

export const onRequestPost = async ({ request, env }) => {
  const userEmail = request.headers.get('Cf-Access-Authenticated-User-Email') || '';

  if (!isOriginAllowed(request, env.ORIGIN_ALLOWED)) {
    return errorResponse(403, 'Origen no permitido.');
  }

  let body;
  try {
    body = await request.json();
  } catch (error) {
    return errorResponse(400, 'JSON inválido o cuerpo ausente.');
  }

  const submittedToken = getTokenFromRequest(request, body.auth_token);
  const expectedToken = env.EDITOR_TOKEN ? String(env.EDITOR_TOKEN) : '';
  const allowDev = !expectedToken;

  if (!isTokenValid(submittedToken, expectedToken, allowDev)) {
    return errorResponse(401, 'Token inválido o ausente.');
  }

  if (!userEmail && !allowDev) {
    return errorResponse(401, 'Autenticación requerida.');
  }

  const decisionId = (body.decision_id || '').trim();
  const actionStatus = normalizeAction(body.action);
  const note = typeof body.note === 'string' ? body.note.trim() : '';

  if (!decisionId || !actionStatus) {
    return errorResponse(400, 'decision_id y acción son obligatorios.');
  }

  const prefix = `decision:${decisionId}:`;
  let keyToUpdate;
  try {
    const list = await env.DECISIONES.list({ prefix });
    if (!list.keys.length) {
      return errorResponse(404, 'Decisión no encontrada.');
    }
    const sortedKeys = list.keys.map(({ name }) => name).sort();
    keyToUpdate = sortedKeys[sortedKeys.length - 1];
  } catch (error) {
    return errorResponse(500, 'No se pudo localizar la decisión.');
  }

  let stored;
  try {
    const raw = await env.DECISIONES.get(keyToUpdate);
    if (!raw) {
      return errorResponse(404, 'Decisión sin contenido.');
    }
    stored = JSON.parse(raw);
  } catch (error) {
    return errorResponse(500, 'Decisión corrupta o ilegible.');
  }

  const now = new Date().toISOString();
  const moderatedBy = userEmail || 'dev@local';

  const trail = Array.isArray(stored.moderationTrail) ? stored.moderationTrail : [];
  trail.push({ status: actionStatus, action: actionStatus, by: moderatedBy, at: now, note });

  const updatedRecord = {
    ...stored,
    moderation: {
      status: actionStatus,
      updatedAt: now,
      by: moderatedBy,
      note
    },
    moderationTrail: trail,
    meta: {
      ...(stored.meta || {}),
      updatedAt: now
    }
  };
 
   try {
     await env.DECISIONES.put(keyToUpdate, JSON.stringify(updatedRecord));
   } catch (error) {
     return errorResponse(500, 'No se pudo actualizar la decisión.');
   }
 
   return new Response(
     JSON.stringify({
       ok: true,
       status: actionStatus,
       key: keyToUpdate,
       moderationTrail: trail
     }),
     {
       status: 200,
       headers: JSON_HEADERS
     }
   );
 };
