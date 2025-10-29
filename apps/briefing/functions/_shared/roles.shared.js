// Módulo compartido de roles unificados
// Reexporta lógica de _utils/roles.js

import {
  resolveRole,
  resolveRoleWithMeta,
  roleToAlias,
} from '../_utils/roles.js';

const CANARY_KEY = "CANARY_ROLE_RESOLVER_EMAILS";
const CANARY_CACHE_TTL_MS = 60 * 1000;

let canaryCache = {
  emails: [],
  fetchedAt: 0,
};

const normalizeEmail = (email) => (typeof email === "string" ? email.trim().toLowerCase() : "");

// Wrapper principal: fuente única KV RUNART_ROLES
export async function resolveRoleUnified(email, env) {
  const { role } = await resolveRoleWithMeta(email, env);
  return role;
}

export async function resolveRoleUnifiedDetailed(email, env) {
  return resolveRoleWithMeta(email, env);
}

export function roleToAliasUnified(role) {
  return roleToAlias(role);
}

// Utilidad simple para comparar roles permitidos
export function isAllowedUnified(role, allowed) {
  if (!role || !allowed) return false;
  const allowedSet = new Set(Array.isArray(allowed) ? allowed : [allowed]);
  return allowedSet.has(role);
}

async function loadCanaryEmails(env) {
  if (!env?.RUNART_ROLES || typeof env.RUNART_ROLES.get !== "function") {
    return [];
  }

  const now = Date.now();
  if (now - canaryCache.fetchedAt < CANARY_CACHE_TTL_MS) {
    return canaryCache.emails;
  }

  try {
    const stored = await env.RUNART_ROLES.get(CANARY_KEY, { type: "json" });
    if (Array.isArray(stored)) {
      const normalized = stored
        .map((item) => normalizeEmail(item))
        .filter(Boolean);
      canaryCache = { emails: normalized, fetchedAt: now };
      return normalized;
    }
  } catch (error) {
    console.warn("[roles] No se pudo leer lista canario", error);
  }

  canaryCache = { emails: [], fetchedAt: now };
  return [];
}

export async function isCanaryEmail(email, env) {
  const runEnv = (env?.RUNART_ENV || "").toLowerCase();
  if (runEnv !== "preview") return false;
  const normalized = normalizeEmail(email);
  if (!normalized) return false;
  const emails = await loadCanaryEmails(env);
  return emails.includes(normalized);
}

// ...pueden agregarse más utilidades según necesidad en Fase 2/3
