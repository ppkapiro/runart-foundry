#!/usr/bin/env bash
set -euo pipefail

# Backup controlado de STAGING (RunArt Base v2)
# Requisitos:
#   - Variables de entorno:
#       STAGING_SSH   (usuario@host)
#       STAGING_PATH  (ruta base del sitio, ej: /var/www/html)
#   - Opcional:
#       BACKUPS_DIR   (directorio local de backups, default: backups)
#
# Qué copia (remoto → local tar.gz):
#   - wp-content/
#   - data/
#   - wp-cli bridge plugin (si existe en plugins/mu-plugins)

BACKUPS_DIR=${BACKUPS_DIR:-backups}
DATE=$(date +%Y%m%d)
OUT_NAME="staging_pre_monitor_${DATE}.tar.gz"
OUT_PATH="${BACKUPS_DIR}/${OUT_NAME}"

mkdir -p "${BACKUPS_DIR}"

if [[ -z "${STAGING_SSH:-}" || -z "${STAGING_PATH:-}" ]]; then
  echo "❌ Faltan variables STAGING_SSH o STAGING_PATH"
  echo "   Ejemplo: STAGING_SSH=deployer@staging.host STAGING_PATH=/var/www/html $0"
  exit 1
fi

REMOTE_WP_CONTENT="${STAGING_PATH}/wp-content"
REMOTE_DATA="${STAGING_PATH}/data"
REMOTE_PLUGIN="${STAGING_PATH}/wp-content/plugins/runart-wpcli-bridge"

# Generar tar remoto en /tmp y descargarlo
REMOTE_TMP="/tmp/runart_backup_${DATE}.tar.gz"

set -x
ssh -o BatchMode=yes "$STAGING_SSH" \
  "tar -czf '$REMOTE_TMP' -C '$STAGING_PATH' \"$(basename \"$REMOTE_WP_CONTENT\")\" \"$(basename \"$REMOTE_DATA\")\" 2>/dev/null || true; \
   if [ -d '$REMOTE_PLUGIN' ]; then tar -rzf '$REMOTE_TMP' -C '$STAGING_PATH/wp-content/plugins' 'runart-wpcli-bridge'; fi"
set +x

scp -o BatchMode=yes "$STAGING_SSH:$REMOTE_TMP" "$OUT_PATH"
ssh -o BatchMode=yes "$STAGING_SSH" "rm -f '$REMOTE_TMP'"

if [[ -f "$OUT_PATH" ]]; then
  echo "✅ Backup creado: $OUT_PATH"
  tar -tzf "$OUT_PATH" | head -n 20 || true
else
  echo "❌ No se pudo crear el backup"
  exit 1
fi
