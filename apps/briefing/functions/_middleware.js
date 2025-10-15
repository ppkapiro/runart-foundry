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
    const isPublic = isPublicPath(pathname);

    const isApiRequest = pathname.startsWith("/api/");

    // Rutas públicas (excepto API) pasan directo
    if (isPublic && !isApiRequest && !isTestBypassActive) {
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

      // Canary headers para entorno preview
      if (runEnv === "preview") {
        headers.set("X-RunArt-Canary", "preview");
        headers.set("X-RunArt-Resolver", "utils");
      } else {
        headers.delete("X-RunArt-Canary");
        headers.delete("X-RunArt-Resolver");
      }

    const forwarded = new Request(request, { headers });
    const response = await next(forwarded);

    const isPreviewContext = runEnv === "preview" || url.hostname.endsWith(".pages.dev");
    if (isPreviewContext) {
      const responseHeaders = new Headers(response.headers);
      responseHeaders.set("X-RunArt-Canary", "preview");
      responseHeaders.set("X-RunArt-Resolver", "utils");
      return new Response(response.body, {
        status: response.status,
        statusText: response.statusText,
        headers: responseHeaders,
      });
    }

    return response;
  },
];
