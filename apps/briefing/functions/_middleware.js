// Middleware de Access: clasifica correo y fija cabeceras internas para el resto de Functions.
<<<<<<< HEAD
import { getEmailFromRequest, resolveRole, logEvent, isPublicPath } from "./_utils/roles.js";
import { isAllowed } from "./_utils/acl.js";
import { onRequestGet as forbiddenResponse } from "./errors/forbidden.js";

=======
import { getEmailFromRequest, resolveRole, logEvent, isPublicPath, roleToAlias } from "./_utils/roles.js";
import { isAllowed, normalizeRoleForAcl } from "./_utils/acl.js";
import { onRequestGet as forbiddenResponse } from "./errors/forbidden.js";

const ROLE_TO_DASHBOARD_SEGMENT = {
  owner: "owner",
  client_admin: "client",
  client: "client",
  team: "team",
  visitor: "visitor",
};

>>>>>>> chore/bootstrap-git
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

<<<<<<< HEAD
    // Rutas públicas pasan directo
    if (isPublicPath(pathname)) {
      return next();
    }

    const email = await getEmailFromRequest(request);
    const rol = await resolveRole(email, env);
=======
    const runEnv = env?.RUNART_ENV;
    const testMode = env?.ACCESS_TEST_MODE;
    const testEmailHeader = request.headers.get("X-RunArt-Test-Email")?.trim() ?? "";
    const isTestBypassActive = runEnv === "preview" && testMode === "1" && testEmailHeader.length > 0;
    const isPublic = isPublicPath(pathname);

    // Rutas públicas pasan directo
    if (isPublic && !isTestBypassActive) {
      return next();
    }

    let email = null;
    let role = "visitor";

    if (isTestBypassActive) {
      email = testEmailHeader;
      role = await resolveRole(email, env);
    } else {
      email = await getEmailFromRequest(request);
      role = await resolveRole(email, env);
    }

    const roleAlias = roleToAlias(role);
>>>>>>> chore/bootstrap-git

    // Log de visitas (no bloqueante)
    context.waitUntil(
      logEvent(env, "visit", {
        path: pathname,
        email: email || "anon",
<<<<<<< HEAD
        rol,
=======
        role,
        roleAlias,
>>>>>>> chore/bootstrap-git
        ua: request.headers.get("user-agent") || "",
      })
    );

    // Home redirige a dashboard del rol
    if (pathname === "/" || pathname === "/index.html") {
<<<<<<< HEAD
      return Response.redirect(`${url.origin}/dash/${rol}`, 302);
=======
      const dashSegment = ROLE_TO_DASHBOARD_SEGMENT[role] || ROLE_TO_DASHBOARD_SEGMENT.visitor;
      return Response.redirect(`${url.origin}/dash/${dashSegment}`, 302);
>>>>>>> chore/bootstrap-git
    }

    // Bloquear acceso cruzado entre dashboards usando ACL
    if (pathname.startsWith("/dash/")) {
<<<<<<< HEAD
      if (!isAllowed(rol, pathname)) {
=======
      const aclRole = normalizeRoleForAcl(role);
      if (!isAllowed(aclRole, pathname)) {
>>>>>>> chore/bootstrap-git
        return forbiddenResponse({ env, request });
      }
    }

    const headers = new Headers(request.headers);
    if (email) {
      headers.set("X-RunArt-Email", email);
    } else {
      headers.delete("X-RunArt-Email");
    }
<<<<<<< HEAD
    headers.set("X-RunArt-Role", rol);
=======
  headers.set("X-RunArt-Role", role);
  headers.set("X-RunArt-Role-Alias", roleAlias);
  headers.set("X-RunArt-Rol", roleAlias);
    if (isTestBypassActive) {
      headers.set("X-RunArt-Bypass", "ACCESS_TEST_MODE");
    } else {
      headers.delete("X-RunArt-Bypass");
    }

    if (isPublic) {
      const forwarded = new Request(request, { headers });
      return next(forwarded);
    }
>>>>>>> chore/bootstrap-git

    const forwardedRequest = new Request(request, { headers });
    return next(forwardedRequest);
  },
];
