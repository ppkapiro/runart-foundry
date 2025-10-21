#!/usr/bin/env bash
# Ejecuta el reparador final en un servidor remoto vía SSH y trae el reporte.
# Uso:
#   ./tools/remote_run_repair_final.sh user@host /ruta/base [/ruta/envfile]
# Requisitos:
#   - SSH y SCP funcionando sin prompt (o con agente)
#   - El envfile (opcional) define: DB_USER, DB_PASSWORD, DB_HOST, WP_USER, WP_APP_PASSWORD, CLOUDFLARE_API_TOKEN, CF_ZONE_ID
#   - En el servidor, WordPress en BASE_PATH (por defecto /) y staging en STAGING_SUBDIR (por defecto staging)

set -euo pipefail

REMOTE=${1:-}
BASE_PATH_REMOTE=${2:-/}
ENVFILE=${3:-}

if [ -z "$REMOTE" ]; then
  echo "Uso: $0 user@host /ruta/base [/ruta/envfile]" >&2
  exit 1
fi

DATE=$(date +%Y%m%d_%H%M%S)
REMOTE_SCRIPT="/tmp/repair_final_prod_staging.sh"
REMOTE_ENV="/tmp/runart_env_${DATE}"
REMOTE_REPORT_DIR="/tmp/_reports/repair_final"
LOCAL_REPORT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)/_reports/repair_final"
mkdir -p "$LOCAL_REPORT_DIR"

# Copiar script
scp -q "$(git rev-parse --show-toplevel 2>/dev/null || pwd)/tools/repair_final_prod_staging.sh" "$REMOTE:$REMOTE_SCRIPT"

# Subir env si existe
if [ -n "$ENVFILE" ]; then
  scp -q "$ENVFILE" "$REMOTE:$REMOTE_ENV"
fi

# Ejecutar en remoto
ssh -tt "$REMOTE" bash -lc "'
  set -euo pipefail
  [ -f "$REMOTE_SCRIPT" ] || { echo "No se encontró el script en $REMOTE_SCRIPT"; exit 1; }
  chmod +x "$REMOTE_SCRIPT"
  mkdir -p "$REMOTE_REPORT_DIR"
  if [ -f "$REMOTE_ENV" ]; then
    source "$REMOTE_ENV"
  fi
  BASE_PATH="$BASE_PATH_REMOTE" STAGING_SUBDIR="staging" REPORT_DIR="$REMOTE_REPORT_DIR" "$REMOTE_SCRIPT"
'"

# Traer reportes de vuelta
scp -q "$REMOTE:$REMOTE_REPORT_DIR/repair_final_*.md" "$LOCAL_REPORT_DIR/" || true

# Mostrar último reporte
LATEST=$(ls -1t "$LOCAL_REPORT_DIR"/repair_final_*.md 2>/dev/null | head -n1 || true)
if [ -n "$LATEST" ]; then
  echo "\n=== Último reporte descargado ===\n$LATEST\n"
  sed -n '1,120p' "$LATEST"
else
  echo "No se encontró reporte remoto para descargar (verificar ejecución remota)"
fi
