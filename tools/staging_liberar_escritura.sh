#!/usr/bin/env bash
# Liberar permisos de escritura en staging para deployment de plugins
# Solo afecta a staging, NO toca producción

set -euo pipefail

log(){ echo "[$(date +%H:%M:%S)] $*"; }

# Detectar ruta de staging
STAGING_PATHS=(
  "/staging"
  "/htdocs/staging"
)

# Añadir patrones IONOS si existen
if compgen -G "/homepages/*/*/htdocs/staging" > /dev/null 2>&1; then
  STAGING_PATHS+=( $(ls -d /homepages/*/*/htdocs/staging 2>/dev/null || true) )
fi

STAGING_BASE=""
for path in "${STAGING_PATHS[@]}"; do
  if [ -f "$path/wp-config.php" ]; then
    STAGING_BASE="$path"
    log "✓ Staging detectado en: $STAGING_BASE"
    break
  fi
done

if [ -z "$STAGING_BASE" ]; then
  log "❌ No se encontró instalación de staging"
  log "   Rutas revisadas: ${STAGING_PATHS[*]}"
  exit 1
fi

# Verificar permisos actuales
log ""
log "Permisos actuales de directorios críticos:"
ls -ld "$STAGING_BASE/wp-content" 2>/dev/null || true
ls -ld "$STAGING_BASE/wp-content/plugins" 2>/dev/null || true
ls -ld "$STAGING_BASE/wp-content/uploads" 2>/dev/null || true

log ""
log "═══════════════════════════════════════════════════════════"
log "  LIBERANDO PERMISOS DE ESCRITURA EN STAGING"
log "═══════════════════════════════════════════════════════════"

# Liberar wp-content y subdirectorios principales
log "Aplicando chmod 755 a directorios..."
chmod 755 "$STAGING_BASE/wp-content" 2>/dev/null || log "⚠️ No se pudo cambiar wp-content"
chmod 755 "$STAGING_BASE/wp-content/plugins" 2>/dev/null || log "⚠️ No se pudo cambiar plugins"
chmod 755 "$STAGING_BASE/wp-content/uploads" 2>/dev/null || log "⚠️ No se pudo cambiar uploads"
chmod 755 "$STAGING_BASE/wp-content/themes" 2>/dev/null || log "⚠️ No se pudo cambiar themes"

log "Aplicando chmod 644 a archivos PHP en wp-content..."
find "$STAGING_BASE/wp-content" -maxdepth 3 -name "*.php" -type f -exec chmod 644 {} \; 2>/dev/null || true

# Liberar específicamente el directorio de plugins para subida de ZIP
if [ -d "$STAGING_BASE/wp-content/plugins" ]; then
  log "Liberando plugins existentes..."
  find "$STAGING_BASE/wp-content/plugins" -type d -exec chmod 755 {} \; 2>/dev/null || true
  find "$STAGING_BASE/wp-content/plugins" -type f -exec chmod 644 {} \; 2>/dev/null || true
fi

# Crear/liberar directorio runart-data si no existe
if [ ! -d "$STAGING_BASE/wp-content/runart-data" ]; then
  log "Creando directorio runart-data..."
  mkdir -p "$STAGING_BASE/wp-content/runart-data" 2>/dev/null || log "⚠️ No se pudo crear runart-data"
fi
chmod 755 "$STAGING_BASE/wp-content/runart-data" 2>/dev/null || true

log ""
log "Permisos después de la liberación:"
ls -ld "$STAGING_BASE/wp-content" 2>/dev/null || true
ls -ld "$STAGING_BASE/wp-content/plugins" 2>/dev/null || true
ls -ld "$STAGING_BASE/wp-content/uploads" 2>/dev/null || true
ls -ld "$STAGING_BASE/wp-content/runart-data" 2>/dev/null || true

log ""
log "✅ Permisos de escritura liberados en staging"
log ""
log "Ahora puedes:"
log "1. Subir plugins vía WP Admin → Plugins → Añadir nuevo → Subir plugin"
log "2. Usar scripts de deployment automático"
log "3. El plugin podrá escribir en wp-content/runart-data"
log ""
log "═══════════════════════════════════════════════════════════"
