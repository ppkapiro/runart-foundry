export async function onRequestGet(context) {
  const { request, env } = context;
  try {
    const runEnv = env?.RUNART_ENV || "unknown";
    if (runEnv !== "preview") {
      return new Response(JSON.stringify({ ok: false, error: "not-available", env: runEnv }), {
        status: 404,
        headers: { "content-type": "application/json; charset=utf-8" },
      });
    }
    const headers = request.headers;
    const authMode = headers.get("CF-Access-Client-Id") && headers.get("CF-Access-Client-Secret") ? "service" : "user";
    const email = headers.get("X-RunArt-Email") || headers.get("cf-access-authenticated-user-email") || null;
    const headerRole = headers.get("X-RunArt-Role") || null;
    let finalRole = "visitor";
    if (authMode === "service" && !email) {
      // Permitir override por header solo en Preview
      const allowedRoles = new Set(["owner", "client_admin", "team", "client", "visitor"]);
      finalRole = allowedRoles.has(headerRole?.toLowerCase()) ? headerRole?.toLowerCase() : "visitor";
    } else if (email) {
      finalRole = headerRole?.toLowerCase() || "visitor";
    }
    const body = {
      ok: true,
      env: runEnv,
      auth_mode: authMode,
      email,
      header_role: headerRole,
      final_role: finalRole,
      sources: {
        kv_hit: Boolean(env?.RUNART_ROLES),
        env_admin_hit: Boolean(env?.ACCESS_ADMINS),
      },
    };
    return new Response(JSON.stringify(body, null, 2), {
      status: 200,
      headers: { "content-type": "application/json; charset=utf-8", "cache-control": "no-store" },
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: err?.message || "unknown", hint: "debug roles error" }), {
      status: 500,
      headers: { "content-type": "application/json; charset=utf-8" }
    });
  }
}
