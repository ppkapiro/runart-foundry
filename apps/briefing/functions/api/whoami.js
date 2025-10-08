import { getEmailFromRequest, resolveRole } from "../_utils/roles.js";

export async function onRequestGet(context) {
  const { request, env } = context;
  const email = await getEmailFromRequest(request);
  const rol = await resolveRole(email, env);

  const body = {
    ok: true,
    RUNART_ENV: env.RUNART_ENV || "unknown",
    MOD_REQUIRED: env.MOD_REQUIRED || "unknown",
    ORIGIN_ALLOWED: env.ORIGIN_ALLOWED || "unknown",
    email: email || null,
    rol,
    now: new Date().toISOString(),
  };

  return new Response(JSON.stringify(body, null, 2), {
    headers: { "content-type": "application/json; charset=utf-8" },
    status: 200,
  });
}
