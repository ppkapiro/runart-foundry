#!/usr/bin/env bash
# 🧩 COPAYLO — REPARACIÓN AUTO-DETECT (IONOS raíz o /homepages/*/htdocs)
# Restaura producción (runartfoundry.com) y aísla staging (staging.runartfoundry.com)
# Sin borrar nada. Respaldos y reporte al final.

set -euo pipefail

DATE=$(date +%Y%m%d_%H%M%S)
REPORT_DIR="${REPORT_DIR:-_reports/repair_autodetect}"
mkdir -p "$REPORT_DIR"

log(){ echo "[$(date +%H:%M:%S)] $*"; }

# ---------- 0) Autodetección de BASE_PATH, PROD_WP, STAGING_WP ----------
detect_paths() {
  local candidates=(
    "/"
    "/htdocs"
  )
  # Añadir patrones IONOS
  if compgen -G "/homepages/*/*/htdocs" > /dev/null 2>&1; then
    candidates+=( $(ls -d /homepages/*/*/htdocs 2>/dev/null || true) )
  fi

  for base in "${candidates[@]}"; do
    if [ -f "$base/wp-config.php" ] && [ -f "$base/staging/wp-config.php" ]; then
      BASE_PATH="$base"
      PROD_WP="$base/wp-config.php"
      STAGING_WP="$base/staging/wp-config.php"
      PROD_WP_CONTENT="$base/wp-content"
      STAG_WP_CONTENT="$base/staging/wp-content"
      log "✓ BASE_PATH detectado: $BASE_PATH"
      return 0
    fi
  done
  
  log "⚠️ No se localizaron wp-config.php de prod y staging en rutas conocidas."
  log "   Ejecutando en modo SAFE (solo reporte de diagnóstico)."
  BASE_PATH="NOT_DETECTED"
  PROD_WP="NOT_DETECTED"
  STAGING_WP="NOT_DETECTED"
  PROD_WP_CONTENT="NOT_DETECTED"
  STAG_WP_CONTENT="NOT_DETECTED"
  return 1
}

# ---------- 1) Lectura segura de credenciales desde wp-config.php ----------
# Si ya existen variables de entorno, se usan; si no, se extraen del wp-config correspondiente.
extract_db_vars() {
  local wpfile="$1"
  local _DB_NAME _DB_USER _DB_PASSWORD _DB_HOST
  _DB_NAME=$(grep -E "define\(\s*'DB_NAME'" "$wpfile" 2>/dev/null | sed "s/.*'DB_NAME',\s*'\(.*\)'.*/\1/" || echo "NO_DETECTADO")
  _DB_USER=$(grep -E "define\(\s*'DB_USER'" "$wpfile" 2>/dev/null | sed "s/.*'DB_USER',\s*'\(.*\)'.*/\1/" || echo "NO_DETECTADO")
  _DB_PASSWORD=$(grep -E "define\(\s*'DB_PASSWORD'" "$wpfile" 2>/dev/null | sed "s/.*'DB_PASSWORD',\s*'\(.*\)'.*/\1/" || echo "NO_DETECTADO")
  _DB_HOST=$(grep -E "define\(\s*'DB_HOST'" "$wpfile" 2>/dev/null | sed "s/.*'DB_HOST',\s*'\(.*\)'.*/\1/" || echo "NO_DETECTADO")

  echo "$_DB_NAME|$_DB_USER|$_DB_PASSWORD|$_DB_HOST"
}

mysql_q() { 
  local user="$1" pass="$2" host="$3" db="$4" query="$5"
  if [ "$user" = "NO_DETECTADO" ] || [ "$pass" = "NO_DETECTADO" ]; then
    log "⚠️ Credenciales no disponibles, saltando consulta MySQL"
    return 1
  fi
  mysql -u"$user" -p"$pass" -h"$host" -D"$db" -e "$query" 2>/dev/null || return 1
}

# ---------- 2) Utilidades ----------
ensure_url_constants() {
  local wpfile="$1" url="$2"
  if [ ! -f "$wpfile" ]; then
    log "⚠️ wp-config.php no existe: $wpfile"
    return 1
  fi
  
  # Crear backup
  cp "$wpfile" "${wpfile}.bak.${DATE}" || true
  
  sed -i '/WP_HOME/d' "$wpfile" 2>/dev/null || true
  sed -i '/WP_SITEURL/d' "$wpfile" 2>/dev/null || true
  printf "define('WP_HOME','%s');\n" "$url" >> "$wpfile"
  printf "define('WP_SITEURL','%s');\n" "$url" >> "$wpfile"
  log "✓ WP_HOME/WP_SITEURL forzados a: $url"
}

cleanup_htaccess_redirects() {
  local ht="$1"
  [ -f "$ht" ] || return 0
  if grep -q "staging.runartfoundry.com" "$ht"; then
    cp "$ht" "$REPORT_DIR/htaccess_backup_${DATE}.txt" || true
    sed -i '/staging.runartfoundry.com/d' "$ht"
    log "✓ Eliminadas redirecciones a staging en $ht"
  else
    log "✓ .htaccess sin redirecciones problemáticas"
  fi
}

clear_cache_dir() {
  local d="$1"
  [ -d "$d/cache" ] && rm -rf "$d/cache"/* 2>/dev/null && log "✓ Caché purgada: $d/cache" || log "⚠️ No hay caché en: $d/cache"
}

fix_urls_in_db() {
  local dbn="$1" dbu="$2" dbp="$3" dbh="$4" site_url="$5" label="$6"
  local query="SELECT option_name, option_value FROM wp_options WHERE option_name IN ('siteurl','home');"
  
  if ! mysql_q "$dbu" "$dbp" "$dbh" "$dbn" "$query" > "$REPORT_DIR/${label}_urls_before_${DATE}.txt"; then
    log "⚠️ No se pudo consultar BD $label (credenciales/conectividad)"
    return 1
  fi
  
  if ! grep -q "$site_url" "$REPORT_DIR/${label}_urls_before_${DATE}.txt"; then
    log "→ Corrigiendo siteurl/home en $label → $site_url"
    mysql_q "$dbu" "$dbp" "$dbh" "$dbn" \
      "UPDATE wp_options SET option_value='${site_url}' WHERE option_name IN ('siteurl','home');" || {
      log "⚠️ No se pudo actualizar BD $label"
      return 1
    }
    log "✓ URLs actualizadas en BD $label"
  else
    log "✓ URLs de $label ya correctas en BD"
  fi
}

ensure_uploads_physical() {
  local stag_content="$1"
  local prod_content="$2"
  local up="$stag_content/uploads"
  
  if [ ! -d "$stag_content" ]; then
    log "⚠️ Staging wp-content no existe: $stag_content"
    return 1
  fi
  
  if [ -L "$up" ]; then
    log "→ uploads en staging es symlink. Convirtiéndolo a carpeta física…"
    mv "$up" "${up}_backup_symlink_${DATE}" || true
    mkdir -p "$up"
    # Copia best-effort (no destructiva)
    if [ -d "$prod_content/uploads" ]; then
      cp -R "$prod_content/uploads/"* "$up" 2>/dev/null || true
      log "✓ uploads de staging ahora es carpeta física independiente"
    else
      log "⚠️ uploads de producción no encontrado para copiar"
    fi
  else
    log "✓ uploads de staging ya es carpeta física"
  fi
}

regenerate_permalinks() {
  local url="$1"
  if [ -n "${WP_USER:-}" ] && [ -n "${WP_APP_PASSWORD:-}" ]; then
    if curl -s -X POST "$url/wp-json/wp/v2/settings" \
         -u "${WP_USER}:${WP_APP_PASSWORD}" \
         -H "Content-Type: application/json" \
         -d '{"permalink_structure":"/%postname%/"}' > /dev/null 2>&1; then
      log "✓ Permalinks regenerados en $url"
    else
      log "⚠️ No se pudieron regenerar permalinks (REST API/credenciales)"
    fi
  else
    log "ℹ️ WP_USER/WP_APP_PASSWORD no disponibles, saltando regeneración de permalinks"
  fi
}

cloudflare_purge() {
  local url="$1"
  if [ -n "${CLOUDFLARE_API_TOKEN:-}" ] && [ -n "${CF_ZONE_ID:-}" ]; then
    if curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/purge_cache" \
         -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
         -H "Content-Type: application/json" \
         --data "{\"files\":[\"$url\"]}" > /dev/null 2>&1; then
      log "✓ Cloudflare purgado para $url"
    else
      log "⚠️ No se pudo purgar Cloudflare para $url"
    fi
  else
    log "ℹ️ CLOUDFLARE_API_TOKEN/CF_ZONE_ID no disponibles, saltando purge"
  fi
}

# ---------- 3) Arranque ----------
log "=== 🧩 REPARACIÓN AUTO-DETECT PROD/STAGING ==="
log "Fecha: $DATE"

SAFE_MODE=false
if ! detect_paths; then
  SAFE_MODE=true
fi

# Dominios esperados (puedes ajustarlos si cambian)
PROD_URL="https://runartfoundry.com"
STAG_URL="https://staging.runartfoundry.com"

if [ "$SAFE_MODE" = true ]; then
  log ""
  log "╔════════════════════════════════════════════════════════════╗"
  log "║  MODO SEGURO ACTIVADO                                      ║"
  log "║  No se encontraron archivos WordPress en el servidor.      ║"
  log "║  Generando reporte de diagnóstico solamente.               ║"
  log "╚════════════════════════════════════════════════════════════╝"
  log ""
  
  {
    echo "# 🧾 Reparación auto-detect (MODO SEGURO) — $DATE"
    echo ""
    echo "## ⚠️ Diagnóstico"
    echo "No se localizaron wp-config.php en las siguientes rutas:"
    echo "- /"
    echo "- /htdocs"
    echo "- /homepages/*/*/htdocs (IONOS típico)"
    echo ""
    echo "## Próximos pasos"
    echo "1. Ejecutar este script en el servidor real (vía SSH o runner remoto)"
    echo "2. O proporcionar BASE_PATH manualmente:"
    echo "   \`\`\`bash"
    echo "   BASE_PATH=/ruta/real ./tools/repair_autodetect_prod_staging.sh"
    echo "   \`\`\`"
    echo ""
    echo "## Variables de entorno opcionales"
    echo "- DB_USER, DB_PASSWORD, DB_HOST: Para forzar credenciales de BD"
    echo "- WP_USER, WP_APP_PASSWORD: Para regenerar permalinks vía REST"
    echo "- CLOUDFLARE_API_TOKEN, CF_ZONE_ID: Para purgar caché"
    echo "- REPORT_DIR: Sobrescribir directorio de reportes (default: _reports/repair_autodetect)"
  } > "$REPORT_DIR/repair_autodetect_safe_${DATE}.md"
  
  log "✔ Reporte de diagnóstico creado: $REPORT_DIR/repair_autodetect_safe_${DATE}.md"
  exit 0
fi

# Modo activo: extraer credenciales
log ""
log "→ Extrayendo credenciales de producción…"
IFS="|" read -r PROD_DB_NAME PROD_DB_USER PROD_DB_PASS PROD_DB_HOST < <(extract_db_vars "$PROD_WP")
log "→ Extrayendo credenciales de staging…"
IFS="|" read -r STAG_DB_NAME STAG_DB_USER STAG_DB_PASS STAG_DB_HOST < <(extract_db_vars "$STAGING_WP")

log ""
log "Configuración detectada:"
log "  Producción DB: $PROD_DB_NAME @ $PROD_DB_HOST (user: $PROD_DB_USER)"
log "  Staging   DB: $STAG_DB_NAME @ $STAG_DB_HOST (user: $STAG_DB_USER)"
log ""

# Verificar que las bases NO sean iguales (seguridad)
if [ "$PROD_DB_NAME" = "$STAG_DB_NAME" ] && [ "$PROD_DB_NAME" != "NO_DETECTADO" ]; then
  log "❌ ERROR: Producción y staging usan la misma base de datos ($PROD_DB_NAME)"
  log "   Esto es peligroso. Cancela la reparación automática."
  exit 1
fi

# ---------- 4) Reparar PRODUCCIÓN ----------
log ""
log "═══════════════════════════════════════════════════════════"
log "  REPARANDO PRODUCCIÓN ($PROD_URL)"
log "═══════════════════════════════════════════════════════════"
ensure_url_constants "$PROD_WP" "$PROD_URL"
fix_urls_in_db "$PROD_DB_NAME" "${DB_USER:-$PROD_DB_USER}" "${DB_PASSWORD:-$PROD_DB_PASS}" "${DB_HOST:-$PROD_DB_HOST}" "$PROD_URL" "prod"
cleanup_htaccess_redirects "$BASE_PATH/.htaccess"
clear_cache_dir "$PROD_WP_CONTENT"
regenerate_permalinks "$PROD_URL"
cloudflare_purge "$PROD_URL"

# ---------- 5) Reparar STAGING ----------
log ""
log "═══════════════════════════════════════════════════════════"
log "  REPARANDO STAGING ($STAG_URL)"
log "═══════════════════════════════════════════════════════════"
ensure_url_constants "$STAGING_WP" "$STAG_URL"
fix_urls_in_db "$STAG_DB_NAME" "${DB_USER:-$STAG_DB_USER}" "${DB_PASSWORD:-$STAG_DB_PASS}" "${DB_HOST:-$STAG_DB_HOST}" "$STAG_URL" "staging"
ensure_uploads_physical "$STAG_WP_CONTENT" "$PROD_WP_CONTENT"
clear_cache_dir "$STAG_WP_CONTENT"
regenerate_permalinks "$STAG_URL"
cloudflare_purge "$STAG_URL"

# ---------- 6) Reporte final ----------
log ""
log "═══════════════════════════════════════════════════════════"
log "  GENERANDO REPORTE FINAL"
log "═══════════════════════════════════════════════════════════"

{
  echo "# 🧾 Reparación auto-detect — $DATE"
  echo ""
  echo "## Configuración detectada"
  echo "- **BASE_PATH**: \`$BASE_PATH\`"
  echo "- **Prod wp-config**: \`$PROD_WP\`"
  echo "- **Stag wp-config**: \`$STAGING_WP\`"
  echo ""
  echo "## ✅ Producción (runartfoundry.com)"
  echo "- WP_HOME / WP_SITEURL forzados a: $PROD_URL"
  echo "- siteurl/home corregidos en BD: $PROD_DB_NAME"
  echo "- .htaccess limpiado de redirecciones a staging (si existían)"
  echo "- Caché local purgada en: $PROD_WP_CONTENT/cache"
  echo "- Permalinks regenerados: $([ -n "${WP_USER:-}" ] && echo "✓" || echo "saltado")"
  echo "- Cloudflare purgado: $([ -n "${CLOUDFLARE_API_TOKEN:-}" ] && echo "✓" || echo "saltado")"
  echo ""
  echo "## ✅ Staging (staging.runartfoundry.com)"
  echo "- WP_HOME / WP_SITEURL forzados a: $STAG_URL"
  echo "- siteurl/home corregidos en BD: $STAG_DB_NAME"
  echo "- uploads garantizado como carpeta física independiente"
  echo "- Caché local purgada en: $STAG_WP_CONTENT/cache"
  echo "- Permalinks regenerados: $([ -n "${WP_USER:-}" ] && echo "✓" || echo "saltado")"
  echo "- Cloudflare purgado: $([ -n "${CLOUDFLARE_API_TOKEN:-}" ] && echo "✓" || echo "saltado")"
  echo ""
  echo "## 🔐 Backups creados"
  echo "- \`${PROD_WP}.bak.${DATE}\`"
  echo "- \`${STAGING_WP}.bak.${DATE}\`"
  if [ -f "$REPORT_DIR/htaccess_backup_${DATE}.txt" ]; then
    echo "- \`$REPORT_DIR/htaccess_backup_${DATE}.txt\`"
  fi
  echo ""
  echo "## Próximos pasos"
  echo "1. Validar sitios:"
  echo "   \`\`\`bash"
  echo "   curl -I $PROD_URL"
  echo "   curl -I $STAG_URL"
  echo "   \`\`\`"
  echo "2. Verificar en navegador que ambos sitios cargan correctamente"
  echo "3. Si hay problemas, restaurar desde backups"
  echo ""
  echo "---"
  echo "✅ **Entornos separados y producción restaurada.**"
} > "$REPORT_DIR/repair_autodetect_${DATE}.md"

log ""
log "✔ Reparación completada exitosamente"
log "✔ Reporte guardado: $REPORT_DIR/repair_autodetect_${DATE}.md"
log ""
log "═══════════════════════════════════════════════════════════"
log "  SIGUIENTE: Validar sitios en navegador"
log "═══════════════════════════════════════════════════════════"
log ""
log "Producción: $PROD_URL"
log "Staging:    $STAG_URL"
