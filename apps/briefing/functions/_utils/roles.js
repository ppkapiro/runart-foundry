/**
 * Utilidades de roles para Cloudflare Pages Functions.
 * Reglas:
 * 1) Intenta mapear por email exacto en KV RUNART_ROLES (clave = email, valor = "owner"/"cliente"/"equipo").
 * 2) Si no hay match, cae por dominio en ACCESS_EQUIPO_DOMAINS => "equipo".
 * 3) Si email está en ACCESS_ADMINS => "owner".
 * 4) Si nada aplica => "visitante".
 */
export async function getEmailFromRequest(request) {
  // Cabeceras típicas de Cloudflare Access
  return (
    request.headers.get("cf-access-authenticated-user-email") ||
    request.headers.get("cf-access-email") ||
    null
  );
}

export function getDomain(email) {
  if (!email || !email.includes("@")) return null;
  return email.split("@")[1].toLowerCase().trim();
}

export function parseCsv(value) {
  if (!value) return [];
  return value
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean)
    .map((s) => s.toLowerCase());
}

export async function resolveRole(email, env) {
  const fallback = "visitante";
  if (!email) return fallback;

  const lower = email.toLowerCase().trim();

  // 3) Admins por variable
  const admins = parseCsv(env.ACCESS_ADMINS);
  if (admins.includes(lower)) return "owner";

  // 1) Lookup exacto en KV (clave = email, valor = texto del rol)
  try {
    const kvRole = await env.RUNART_ROLES.get(lower);
    if (kvRole) {
      const r = kvRole.toLowerCase();
      if (["owner", "cliente", "equipo", "visitante"].includes(r)) return r;
    }
  } catch (e) {
    // silencioso: si KV falla, seguimos con heurísticas
  }

  // 2) Dominio de equipo
  const domain = getDomain(lower);
  if (domain) {
    const equipoDomains = parseCsv(env.ACCESS_EQUIPO_DOMAINS);
    if (equipoDomains.includes(domain)) return "equipo";
  }

  return fallback;
}

export async function logEvent(env, kind, payload = {}) {
  try {
    const ts = new Date().toISOString();
    const key = `evt:${ts}:${Math.random().toString(36).slice(2, 8)}`;
    const data = JSON.stringify({ ts, kind, ...payload });
    if (env.LOG_EVENTS && env.LOG_EVENTS.put) {
      await env.LOG_EVENTS.put(key, data, { expirationTtl: 60 * 60 * 24 * 30 }); // 30 días
    }
  } catch {
    // no bloquear flujo por logging
  }
}

export function isPublicPath(pathname) {
  // Rutas que NO deben forzar redirección por rol
  if (
    pathname.startsWith("/api/") ||
    pathname.startsWith("/assets/") ||
    pathname.startsWith("/static/") ||
    pathname.startsWith("/favicon") ||
    pathname.startsWith("/_") // internos de CF
  ) {
    return true;
  }
  return false;
}

export function roleFromPath(pathname) {
  // /dash/owner -> owner, etc.
  const m = pathname.match(/^\/dash\/([a-z]+)/i);
  return m ? m[1].toLowerCase() : null;
}
