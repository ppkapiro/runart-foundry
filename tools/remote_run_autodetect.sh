#!/usr/bin/env bash
# 🚀 Runner remoto para repair_autodetect_prod_staging.sh
# Ejecuta en servidor IONOS/remoto vía SSH, opcionalmente con variables de entorno

set -euo pipefail

usage() {
  cat >&2 <<EOF
Uso: $0 user@host [/ruta/envfile]

Ejecuta el script de auto-detección en el servidor remoto.

Argumentos:
  user@host      Destino SSH (ej: u111876951@access958591985.webspace-data.io)
  /ruta/envfile  (Opcional) Ruta remota a archivo con variables de entorno

Variables opcionales en envfile:
  DB_USER, DB_PASSWORD, DB_HOST
  WP_USER, WP_APP_PASSWORD
  CLOUDFLARE_API_TOKEN, CF_ZONE_ID

Ejemplo:
  $0 usuario@servidor.ionos.com ~/.runart_env

El script:
1. Copia repair_autodetect_prod_staging.sh al servidor
2. Ejecuta con las variables del envfile (si se proporciona)
3. Descarga el reporte generado a _reports/repair_autodetect/
EOF
  exit 1
}

[ $# -lt 1 ] && usage

REMOTE="$1"
ENVFILE="${2:-}"

SCRIPT_NAME="repair_autodetect_prod_staging.sh"
LOCAL_SCRIPT="tools/$SCRIPT_NAME"
REMOTE_SCRIPT="/tmp/$SCRIPT_NAME"
REPORT_DIR="_reports/repair_autodetect"

mkdir -p "$REPORT_DIR"

log() { echo "[$(date +%H:%M:%S)] $*"; }

log "═══════════════════════════════════════════════════════════"
log "  EJECUCIÓN REMOTA: Reparación auto-detect"
log "═══════════════════════════════════════════════════════════"
log "Destino: $REMOTE"
log "Envfile: ${ENVFILE:-<ninguno>}"
log ""

# 1. Copiar script al servidor
log "→ Copiando script al servidor…"
scp "$LOCAL_SCRIPT" "$REMOTE:$REMOTE_SCRIPT" || {
  log "❌ Error copiando script"
  exit 1
}
log "✓ Script copiado a $REMOTE:$REMOTE_SCRIPT"

# 2. Ejecutar en remoto
log ""
log "→ Ejecutando reparación en servidor remoto…"
log ""

if [ -n "$ENVFILE" ]; then
  ssh -tt "$REMOTE" bash -lc "'
    set -euo pipefail
    if [ -f \"$ENVFILE\" ]; then
      source \"$ENVFILE\"
      echo \"[INFO] Variables cargadas desde $ENVFILE\"
    else
      echo \"[WARN] Envfile $ENVFILE no encontrado, continuando sin variables\"
    fi
    chmod +x \"$REMOTE_SCRIPT\"
    \"$REMOTE_SCRIPT\"
  '"
else
  ssh -tt "$REMOTE" bash -lc "'
    set -euo pipefail
    chmod +x \"$REMOTE_SCRIPT\"
    \"$REMOTE_SCRIPT\"
  '"
fi

RUN_STATUS=$?

log ""
log "═══════════════════════════════════════════════════════════"
if [ $RUN_STATUS -eq 0 ]; then
  log "✓ Ejecución remota completada exitosamente"
else
  log "⚠️ Ejecución remota terminó con código $RUN_STATUS"
fi
log "═══════════════════════════════════════════════════════════"

# 3. Descargar reportes generados
log ""
log "→ Descargando reportes…"

# Detectar último reporte generado en remoto
LATEST_REPORT=$(ssh "$REMOTE" "ls -t _reports/repair_autodetect/repair_autodetect*.md 2>/dev/null | head -n 1" || echo "")

if [ -n "$LATEST_REPORT" ]; then
  scp "$REMOTE:$LATEST_REPORT" "$REPORT_DIR/" || {
    log "⚠️ No se pudo descargar reporte"
  }
  log "✓ Reporte descargado: $REPORT_DIR/$(basename "$LATEST_REPORT")"
  
  # Descargar también archivos de backup de URLs si existen
  BASENAME=$(basename "$LATEST_REPORT" .md)
  TIMESTAMP=$(echo "$BASENAME" | grep -oP '\d{8}_\d{6}' || true)
  
  if [ -n "$TIMESTAMP" ]; then
    for pattern in "prod_urls_before_${TIMESTAMP}.txt" "staging_urls_before_${TIMESTAMP}.txt"; do
      scp "$REMOTE:_reports/repair_autodetect/$pattern" "$REPORT_DIR/" 2>/dev/null || true
    done
  fi
  
  # Mostrar resumen del reporte
  log ""
  log "═══════════════════════════════════════════════════════════"
  log "  RESUMEN DEL REPORTE"
  log "═══════════════════════════════════════════════════════════"
  echo ""
  head -n 30 "$REPORT_DIR/$(basename "$LATEST_REPORT")"
  echo ""
  log "..."
  log "(Ver reporte completo en: $REPORT_DIR/$(basename "$LATEST_REPORT"))"
else
  log "⚠️ No se encontró reporte en el servidor remoto"
  log "   Verifica la salida anterior para errores"
fi

log ""
log "═══════════════════════════════════════════════════════════"
log "✔ Runner remoto completado"
log "═══════════════════════════════════════════════════════════"
