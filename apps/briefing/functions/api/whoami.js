<<<<<<< HEAD
import { getEmailFromRequest, resolveRole } from "../_utils/roles.js";
=======
import { getEmailFromRequest, resolveRole, roleToAlias } from "../_utils/roles.js";
>>>>>>> chore/bootstrap-git

export async function onRequestGet(context) {
  const { request, env } = context;
  const email = await getEmailFromRequest(request);
<<<<<<< HEAD
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
=======
  const role = await resolveRole(email, env);
  const ts = new Date().toISOString();
  const alias = roleToAlias(role);

  const body = {
    ok: true,
    email: email || null,
    role,
    rol: alias,
    env: env.RUNART_ENV || "unknown",
    ts,
  };

  return new Response(JSON.stringify(body, null, 2), {
    headers: {
      "content-type": "application/json; charset=utf-8",
      "cache-control": "no-store, no-cache, must-revalidate",
      pragma: "no-cache",
    },
>>>>>>> chore/bootstrap-git
    status: 200,
  });
}
