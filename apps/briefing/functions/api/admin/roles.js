import { getEmailFromRequest, resolveRole, logEvent, roleToAlias } from "../../_utils/roles.js";
import { ensureRolesSync, persistRoles } from "../../_lib/accessStore.js";

const JSON_HEADERS = Object.freeze({
  "content-type": "application/json; charset=utf-8",
  "cache-control": "no-store, no-cache, must-revalidate",
  pragma: "no-cache",
});

const ALLOWED_FIELDS = new Set(["owners", "client_admins", "clients", "team", "team_domains"]);

const isWriteAllowed = (role) => role === "owner" || role === "client_admin";
const isReadAllowed = (role) => isWriteAllowed(role) || role === "team";

const respond = (status, data) =>
  new Response(JSON.stringify(data, null, 2), {
    status,
    headers: JSON_HEADERS,
  });

const normalizeCollection = (value) => {
  if (!Array.isArray(value)) return [];
  return value
    .map((entry) => (typeof entry === "string" ? entry.trim() : ""))
    .filter(Boolean);
};

const normalizeBody = (raw) => {
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) {
    throw new Error("Payload inválido: se esperaba un objeto");
  }

  const result = {};
  for (const key of Object.keys(raw)) {
    if (!ALLOWED_FIELDS.has(key)) {
      throw new Error(`Campo no permitido: ${key}`);
    }
    result[key] = normalizeCollection(raw[key]);
  }

  for (const field of ALLOWED_FIELDS) {
    if (!(field in result)) {
      result[field] = [];
    }
  }

  return result;
};

async function handleGet(context, role) {
  if (!isReadAllowed(role)) {
    return respond(403, { ok: false, error: "forbidden", role });
  }

  const snapshot = await ensureRolesSync(context.env, { force: true });
  return respond(200, {
    ok: true,
    role,
    role_alias: roleToAlias(role),
    data: snapshot.roles,
    source: snapshot.source,
    fetched_at: new Date(snapshot.fetchedAt || Date.now()).toISOString(),
    read_only: !isWriteAllowed(role),
  });
}

async function handlePut(context, role, email) {
  if (!isWriteAllowed(role)) {
    return respond(403, { ok: false, error: "forbidden", role });
  }

  const { request, env } = context;

  let payload;
  try {
    payload = await request.json();
  } catch (error) {
    return respond(400, { ok: false, error: "invalid_json" });
  }

  let normalized;
  try {
    normalized = normalizeBody(payload);
  } catch (error) {
    return respond(400, { ok: false, error: "invalid_payload", message: error.message });
  }

  const result = await persistRoles(env, normalized);

  context.waitUntil(
    logEvent(env, "roles.update", {
      actor: email || "anonymous",
      role,
      owners: result.roles.owners.length,
      client_admins: result.roles.client_admins.length,
      clients: result.roles.clients.length,
      team: result.roles.team.length,
      team_domains: result.roles.team_domains.length,
    })
  );

  return respond(200, {
    ok: true,
    role,
    role_alias: roleToAlias(role),
    data: result.roles,
    source: result.source,
    updated_at: new Date(result.fetchedAt || Date.now()).toISOString(),
  });
}

export async function onRequest(context) {
  const { request, env } = context;
  const email = await getEmailFromRequest(request);
  const role = await resolveRole(email, env);
  const method = (request.method || "GET").toUpperCase();

  if (method === "GET") {
    return handleGet(context, role);
  }

  if (method === "PUT") {
    return handlePut(context, role, email);
  }

  return respond(405, { ok: false, error: "method_not_allowed" });
}
