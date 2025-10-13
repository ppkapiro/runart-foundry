// Middleware de Access: clasifica correo y fija cabeceras internas para el resto de Functions.
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

    const runEnv = env?.RUNART_ENV;
    const testMode = env?.ACCESS_TEST_MODE;
    const testEmailHeader = request.headers.get("X-RunArt-Test-Email")?.trim() ?? "";
    const isTestBypassActive = runEnv === "preview" && testMode === "1" && testEmailHeader.length > 0;
    // Determinar modo de autenticación
    const hasServiceId = !!request.headers.get("CF-Access-Client-Id");
    const hasServiceSecret = !!request.headers.get("CF-Access-Client-Secret");
    const authMode = hasServiceId && hasServiceSecret ? "service" : "user";
    const isPublic = isPublicPath(pathname);

    // Rutas públicas pasan directo
    if (isPublic && !isTestBypassActive) {
      return next();
    }

    let email = null;
    let role = "visitor";
    let headerRole = null;

    if (isTestBypassActive) {
      email = testEmailHeader;
      role = await resolveRole(email, env);
    } else {
      email = await getEmailFromRequest(request);
      // Regla: NUNCA elevar a admin por Service Token sin email resoluble
      // Resolver rol sólo por listas KV/ENV si hay email
      if (email) {
        role = await resolveRole(email, env);
      } else if (authMode === "service" && runEnv === "preview") {
        // Permitir override por header X-RunArt-Role en Preview bajo auth service
        headerRole = (request.headers.get("X-RunArt-Role") || "").trim().toLowerCase();
        const allowedRoles = new Set(["owner", "client_admin", "team", "client", "visitor"]);
        role = allowedRoles.has(headerRole) ? headerRole : "visitor";
      } else {
        role = "visitor";
      }
    }

    const roleAlias = roleToAlias(role);

    // Log de visitas (no bloqueante)
    context.waitUntil(
      logEvent(env, "visit", {
        path: pathname,
        email: email || "anon",
        role,
        roleAlias,
        ua: request.headers.get("user-agent") || "",
      })
    );

    // Home redirige a dashboard del rol
    if (pathname === "/" || pathname === "/index.html") {
      const dashSegment = ROLE_TO_DASHBOARD_SEGMENT[role] || ROLE_TO_DASHBOARD_SEGMENT.visitor;
      return Response.redirect(`${url.origin}/dash/${dashSegment}`, 302);
    }

    // Bloquear acceso cruzado entre dashboards usando ACL
    if (pathname.startsWith("/dash/")) {
      const aclRole = normalizeRoleForAcl(role);
      if (!isAllowed(aclRole, pathname)) {
        return forbiddenResponse({ env, request });
      }
    }

    const headers = new Headers(request.headers);
    if (email) {
      headers.set("X-RunArt-Email", email);
    } else {
      headers.delete("X-RunArt-Email");
    }
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

    // Logs de depuración sólo en Preview
    if (runEnv === "preview") {
      context.waitUntil(
        logEvent(env, "role_resolve", {
          path: pathname,
          auth_mode: authMode,
          email: email || null,
          header_role: headerRole || null,
          final_role: role,
        })
      );
    }

    const forwardedRequest = new Request(request, { headers });
    return next(forwardedRequest);
  },
];
