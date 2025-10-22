#!/usr/bin/env bash
set -euo pipefail
# Valida endpoints del MU-plugin contra un sitio Local.
# Requiere BASE_URL en docs/integration_wp_staging_lite/local_site.env

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONF="$REPO_ROOT/docs/integration_wp_staging_lite/local_site.env"
TESTS="$REPO_ROOT/docs/integration_wp_staging_lite/TESTS_PLUGIN_LOCAL.md"

if [ ! -f "$CONF" ]; then
  echo "❌ Falta archivo de configuración: $CONF" >&2
  exit 1
fi
# shellcheck disable=SC1090
source "$CONF"
: "${BASE_URL:?Debe definir BASE_URL en $CONF}"

log() { echo "$*" | tee -a "$TESTS"; }

STATUS_URL="$BASE_URL/wp-json/briefing/v1/status"
TRIGGER_URL="$BASE_URL/wp-json/briefing/v1/trigger"
ROOT_JSON="$BASE_URL/wp-json/"
CURL_BIN="curl"

log "\n### $(date '+%Y-%m-%d %H:%M:%S') — Validación de endpoints"

summ() {
  local path="$1"
  if [ -s "$path" ]; then
    head -c 300 "$path" | tr '\n' ' '
  else
    echo "(sin contenido o no accesible)"
  fi
}

# 1) Verificar raíz REST
root_file="/tmp/wpjson_root.json"
code=$("$CURL_BIN" -sS -o "$root_file" -w "%{http_code}" "$ROOT_JSON" || true)
if [ "$code" = "000" ] && [ -x "/mnt/c/Windows/System32/curl.exe" ]; then
  log "  • Aviso: CURL Linux no alcanzable. Reintentando con curl.exe de Windows"
  CURL_BIN="/mnt/c/Windows/System32/curl.exe"
  code=$("$CURL_BIN" -s -o "$root_file" -w "%{http_code}" "$ROOT_JSON" || true)
fi
first=$(summ "$root_file")
log "- /wp-json/ → HTTP $code"
if echo "$first" | grep -qi 'briefing/v1' ; then
  log "  • Namespace briefing/v1 detectado"
else
  log "  • Namespace briefing/v1 NO detectado (revisar MU-plugin cargado o DNS/hosts)"
fi

# 2) GET status
status_file="/tmp/wpjson_status.json"
code=$("$CURL_BIN" -sS -o "$status_file" -w "%{http_code}" "$STATUS_URL" || true)
first=$(summ "$status_file")
log "- GET /briefing/v1/status → HTTP $code"
log "  • Resumen: ${first}"

# 3) POST trigger (debe estar deshabilitado → 501)
trigger_file="/tmp/wpjson_trigger.json"
code=$("$CURL_BIN" -sS -X POST -o "$trigger_file" -w "%{http_code}" "$TRIGGER_URL" || true)
first=$(summ "$trigger_file")
log "- POST /briefing/v1/trigger → HTTP $code (esperado 501)"
log "  • Resumen: ${first}"

log "\n(Consejo) Si /status da 404, guardar enlaces permanentes en WP para flush rewrites."
