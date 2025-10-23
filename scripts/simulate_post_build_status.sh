#!/usr/bin/env bash
set -euo pipefail
# Simula el workflow post_build_status generando docs/status.json y copiándolo al sitio Local para WP.
# Requiere docs/integration_wp_staging_lite/local_site.env con WP_PUBLIC_PATH.

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONF="$REPO_ROOT/docs/integration_wp_staging_lite/local_site.env"
LOG_DIR="$REPO_ROOT/docs/ops/logs"
STATUS_JSON_REPO="$REPO_ROOT/docs/status.json"
mkdir -p "$LOG_DIR" "$REPO_ROOT/docs"

TS_ISO="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
cat > "$STATUS_JSON_REPO" <<JSON
{
  "version": "staging",
  "last_update": "${TS_ISO}",
  "health": "OK",
  "services": [
    {"name": "web", "state": "OK"}
  ]
}
JSON

TS="$(date -u +%Y%m%dT%H%M%SZ)"
LOG_FILE="$LOG_DIR/post_build_status_${TS}.log"
{
  echo "wrote=$STATUS_JSON_REPO"
  echo "ts=${TS}"
} > "$LOG_FILE"

echo "✅ Generado $STATUS_JSON_REPO"

# Copiar al sitio Local para que WP lo lea desde el plugin
if [ -f "$CONF" ]; then
  # shellcheck disable=SC1090
  source "$CONF"
  WP_PUBLIC_PATH=${WP_PUBLIC_PATH:-${LOCAL_SITE_PATH:-}}
  if [ -n "${WP_PUBLIC_PATH:-}" ]; then
    DST_DIR="$WP_PUBLIC_PATH/wp-content/mu-plugins/wp-staging-lite"
    mkdir -p "$DST_DIR"
    cp -f "$STATUS_JSON_REPO" "$DST_DIR/status.json"
    echo "✅ Copiado a $DST_DIR/status.json" | tee -a "$LOG_FILE"
  else
    echo "⚠️ WP_PUBLIC_PATH no definido en $CONF; omitido copiado para WP" | tee -a "$LOG_FILE"
  fi
else
  echo "⚠️ Falta $CONF; omitido copiado para WP" | tee -a "$LOG_FILE"
fi
