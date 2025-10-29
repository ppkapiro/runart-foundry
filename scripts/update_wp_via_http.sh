#!/bin/bash
set -e
REPORT_DIR="_reports/updates"
mkdir -p "$REPORT_DIR"

echo "=== 🧩 Iniciando actualización HTTP de WordPress ==="
DATE=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$REPORT_DIR/update_log_${DATE}.txt"

BASE_URL="${WP_BASE_URL:-https://staging.runartfoundry.com}"
USER="${WP_USER:-github-actions}"
APP_PASS="${WP_APP_PASSWORD}"

auth_header="Authorization: Basic $(echo -n "$USER:$APP_PASS" | base64)"

update_component() {
  local endpoint=$1
  local label=$2
  echo "--- 🔄 Actualizando $label ---" | tee -a "$LOG_FILE"
  curl -s -X POST "$BASE_URL/wp-json/wp/v2/$endpoint" \
       -H "$auth_header" \
       -H "Content-Type: application/json" \
       -d '{"status":"active"}' >> "$LOG_FILE" 2>&1 || echo "⚠️ Error al actualizar $label" | tee -a "$LOG_FILE"
}

# Actualización Core
echo "--- ⚙️ Actualizando Core ---" | tee -a "$LOG_FILE"
curl -s -X POST "$BASE_URL/wp-json/wp/v2/core/update" \
     -H "$auth_header" \
     -H "Content-Type: application/json" >> "$LOG_FILE" 2>&1 || echo "⚠️ Error al actualizar Core" | tee -a "$LOG_FILE"

# Actualización Plugins y Temas
update_component "plugins" "Plugins"
update_component "themes" "Temas"

echo "=== ✅ Actualización completada ===" | tee -a "$LOG_FILE"
ls -lh "$REPORT_DIR" | tee -a "$LOG_FILE"
