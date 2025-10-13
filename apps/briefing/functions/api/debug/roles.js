export async function onRequestGet(context) {
  const { request, env } = context;
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
  const finalRole = headers.get("X-RunArt-Role") || "visitor";

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
}