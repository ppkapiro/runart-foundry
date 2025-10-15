#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="$HOME/.runart/env"
touch "$ENV_FILE"
chmod 600 "$ENV_FILE"

say(){ echo "$*"; }
prompt_secret(){
  local var="$1" prompt="$2"
  local cur="${!var:-}"
  if [ -z "$cur" ]; then
    read -s -p "$prompt: " val; echo
  else
    read -s -p "$prompt (ENTER para mantener el existente): " val; echo
    [ -z "$val" ] && val="$cur"
  fi
  export "$var=$val"
  grep -v -E "^${var}=" "$ENV_FILE" > "${ENV_FILE}.tmp" || true
  mv "${ENV_FILE}.tmp" "$ENV_FILE"
  printf '%s=%q\n' "$var" "$val" >> "$ENV_FILE"
}

say "=== RUNART • Configuración de entorno (~/.runart/env) — ESPAÑOL ==="
say "Se guardarán variables sensibles con permisos 600 (solo tu usuario)."

prompt_secret "CLOUDFLARE_API_TOKEN" "Introduce CLOUDFLARE_API_TOKEN (token API de Cloudflare)"
prompt_secret "ACCESS_CLIENT_ID" "Introduce ACCESS_CLIENT_ID (Service Token — Client ID)"
prompt_secret "ACCESS_CLIENT_SECRET" "Introduce ACCESS_CLIENT_SECRET (Service Token — Client Secret)"
prompt_secret "CLOUDFLARE_ACCOUNT_ID" "Introduce CLOUDFLARE_ACCOUNT_ID (Account ID)"
prompt_secret "NAMESPACE_ID_RUNART_ROLES_PREVIEW" "Introduce NAMESPACE_ID_RUNART_ROLES_PREVIEW (KV preview)"

say "✅ Variables guardadas en $ENV_FILE (permisos 600)."
