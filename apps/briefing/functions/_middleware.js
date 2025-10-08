// Middleware de Access: clasifica correo y fija cabeceras internas para el resto de Functions.
import { getEmailFromRequest, resolveRole, logEvent, isPublicPath } from "./_utils/roles.js";
import { isAllowed } from "./_utils/acl.js";
import { onRequestGet as forbiddenResponse } from "./errors/forbidden.js";

/**
 * Middleware global:
 * - Detecta email vía Access.
 * - Resuelve rol y enruta según dashboards.
 * - Rutas públicas (api/assets/etc) continúan sin alterar.
 */
export const onRequest = [
  async (context) => {
    const { request, env, next } = context;
    const url = new URL(request.url);
    const pathname = url.pathname;

    // Rutas públicas pasan directo
    if (isPublicPath(pathname)) {
      return next();
    }

    const email = await getEmailFromRequest(request);
    const rol = await resolveRole(email, env);

    // Log de visitas (no bloqueante)
    context.waitUntil(
      logEvent(env, "visit", {
        path: pathname,
        email: email || "anon",
        rol,
        ua: request.headers.get("user-agent") || "",
      })
    );

    // Home redirige a dashboard del rol
    if (pathname === "/" || pathname === "/index.html") {
      return Response.redirect(`${url.origin}/dash/${rol}`, 302);
    }

    // Bloquear acceso cruzado entre dashboards usando ACL
    if (pathname.startsWith("/dash/")) {
      if (!isAllowed(rol, pathname)) {
        return forbiddenResponse({ env, request });
      }
    }

    const headers = new Headers(request.headers);
    if (email) {
      headers.set("X-RunArt-Email", email);
    } else {
      headers.delete("X-RunArt-Email");
    }
    headers.set("X-RunArt-Role", rol);

    const forwardedRequest = new Request(request, { headers });
    return next(forwardedRequest);
  },
];
