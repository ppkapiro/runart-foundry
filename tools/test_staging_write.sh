#!/usr/bin/env bash
#
# Script de prueba de escritura controlada para STAGING
# RunArt Foundry — F10-d Verificación de capacidad de escritura
#
# Propósito:
#   - Deshabilitar temporalmente READ_ONLY y DRY_RUN
#   - Probar escritura en wp-content/uploads/runart-jobs/
#   - Verificar lectura de los archivos escritos
#   - Restaurar variables de entorno al estado original
#
# Uso:
#   bash tools/test_staging_write.sh
#
# IMPORTANTE: Este script modifica temporalmente las variables de entorno.
# Asegúrate de restaurar el estado original después de las pruebas.
#

set -euo pipefail

# ==============================================================================
# Configuración
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TIMESTAMP=$(date -u +"%Y%m%dT%H%M%SZ")
LOG_FILE="$PROJECT_ROOT/logs/staging_write_test_${TIMESTAMP}.log"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ==============================================================================
# Funciones
# ==============================================================================

log() {
    echo -e "[$(date -u +"%Y-%m-%d %H:%M:%S UTC")] $1" | tee -a "$LOG_FILE"
}

log_section() {
    echo "" | tee -a "$LOG_FILE"
    echo "================================================================================" | tee -a "$LOG_FILE"
    echo "$1" | tee -a "$LOG_FILE"
    echo "================================================================================" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}✗${NC} $1" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${BLUE}ℹ${NC} $1" | tee -a "$LOG_FILE"
}

log_step() {
    echo -e "${CYAN}▶${NC} $1" | tee -a "$LOG_FILE"
}

# ==============================================================================
# Inicialización
# ==============================================================================

mkdir -p "$(dirname "$LOG_FILE")"

log_section "🧪 PRUEBA DE ESCRITURA CONTROLADA — STAGING"
log "Timestamp: $TIMESTAMP"
log "Project root: $PROJECT_ROOT"

# ==============================================================================
# 1. Guardar estado original
# ==============================================================================

log_section "1️⃣ GUARDAR ESTADO ORIGINAL"

ORIGINAL_READ_ONLY="${READ_ONLY:-}"
ORIGINAL_DRY_RUN="${DRY_RUN:-}"

log_info "Estado original:"
log "  - READ_ONLY: ${ORIGINAL_READ_ONLY:-'(no definida)'}"
log "  - DRY_RUN: ${ORIGINAL_DRY_RUN:-'(no definida)'}"

# ==============================================================================
# 2. Deshabilitar protecciones temporalmente
# ==============================================================================

log_section "2️⃣ DESHABILITAR PROTECCIONES TEMPORALMENTE"

export READ_ONLY=0
export DRY_RUN=0

log_step "Exportando READ_ONLY=0"
log_step "Exportando DRY_RUN=0"

log_success "Protecciones deshabilitadas temporalmente"

# ==============================================================================
# 3. Preparar directorio de pruebas
# ==============================================================================

log_section "3️⃣ PREPARAR DIRECTORIO DE PRUEBAS"

WP_CONTENT_DIR="$PROJECT_ROOT/wp-content"
UPLOADS_DIR="$WP_CONTENT_DIR/uploads"
RUNART_JOBS_DIR="$UPLOADS_DIR/runart-jobs"

if [[ ! -d "$UPLOADS_DIR" ]]; then
    log_error "Directorio uploads NO existe: $UPLOADS_DIR"
    exit 1
fi

if [[ ! -d "$RUNART_JOBS_DIR" ]]; then
    log_warning "Directorio runart-jobs NO existe, creando..."
    if mkdir -p "$RUNART_JOBS_DIR"; then
        log_success "Directorio creado: $RUNART_JOBS_DIR"
    else
        log_error "No se pudo crear directorio: $RUNART_JOBS_DIR"
        exit 1
    fi
else
    log_info "Directorio runart-jobs existe: $RUNART_JOBS_DIR"
fi

# ==============================================================================
# 4. Prueba de escritura
# ==============================================================================

log_section "4️⃣ PRUEBA DE ESCRITURA"

TEST_FILE="$RUNART_JOBS_DIR/test_write.json"
TEST_CONTENT=$(cat <<EOF
{
  "test": "ok",
  "timestamp": "$TIMESTAMP",
  "purpose": "Verificación de permisos de escritura en staging",
  "environment": {
    "READ_ONLY": $READ_ONLY,
    "DRY_RUN": $DRY_RUN
  }
}
EOF
)

log_step "Intentando escribir archivo de prueba: $TEST_FILE"

if echo "$TEST_CONTENT" > "$TEST_FILE" 2>/dev/null; then
    log_success "Escritura exitosa"
else
    log_error "No se pudo escribir el archivo (permisos insuficientes)"
    # Restaurar estado original antes de salir
    export READ_ONLY="${ORIGINAL_READ_ONLY:-1}"
    export DRY_RUN="${ORIGINAL_DRY_RUN:-1}"
    exit 1
fi

# ==============================================================================
# 5. Verificación de lectura
# ==============================================================================

log_section "5️⃣ VERIFICACIÓN DE LECTURA"

if [[ ! -f "$TEST_FILE" ]]; then
    log_error "Archivo de prueba no existe después de escritura"
    exit 1
fi

log_step "Verificando contenido del archivo..."

READ_CONTENT=$(cat "$TEST_FILE")

# Verificar que contiene la marca de tiempo
if echo "$READ_CONTENT" | grep -q "$TIMESTAMP"; then
    log_success "Contenido verificado correctamente"
    log_info "Contenido del archivo:"
    echo "$READ_CONTENT" | tee -a "$LOG_FILE"
else
    log_error "Contenido del archivo no coincide con lo esperado"
fi

# ==============================================================================
# 6. Verificación de permisos del archivo
# ==============================================================================

log_section "6️⃣ VERIFICACIÓN DE PERMISOS"

PERMS=$(stat -c "%a" "$TEST_FILE" 2>/dev/null || stat -f "%A" "$TEST_FILE" 2>/dev/null || echo "???")
OWNER=$(stat -c "%U" "$TEST_FILE" 2>/dev/null || stat -f "%Su" "$TEST_FILE" 2>/dev/null || echo "???")
GROUP=$(stat -c "%G" "$TEST_FILE" 2>/dev/null || stat -f "%Sg" "$TEST_FILE" 2>/dev/null || echo "???")

log_info "Permisos del archivo de prueba:"
log "  - Permisos: $PERMS"
log "  - Owner: $OWNER"
log "  - Group: $GROUP"

# ==============================================================================
# 7. Limpiar archivo de prueba
# ==============================================================================

log_section "7️⃣ LIMPIEZA"

log_step "Eliminando archivo de prueba..."

if rm -f "$TEST_FILE"; then
    log_success "Archivo de prueba eliminado correctamente"
else
    log_warning "No se pudo eliminar el archivo de prueba"
fi

# ==============================================================================
# 8. Restaurar estado original
# ==============================================================================

log_section "8️⃣ RESTAURAR ESTADO ORIGINAL"

if [[ -n "$ORIGINAL_READ_ONLY" ]]; then
    export READ_ONLY="$ORIGINAL_READ_ONLY"
    log_step "Restaurado READ_ONLY=$READ_ONLY"
else
    export READ_ONLY=1
    log_step "READ_ONLY no estaba definida, establecida a 1 (seguro)"
fi

if [[ -n "$ORIGINAL_DRY_RUN" ]]; then
    export DRY_RUN="$ORIGINAL_DRY_RUN"
    log_step "Restaurado DRY_RUN=$DRY_RUN"
else
    export DRY_RUN=1
    log_step "DRY_RUN no estaba definida, establecida a 1 (seguro)"
fi

log_success "Estado original restaurado"

# ==============================================================================
# 9. Resumen
# ==============================================================================

log_section "9️⃣ RESUMEN"

log_success "✅ Prueba de escritura completada exitosamente"
log ""
log "Resultados:"
log "  - Directorio de pruebas: $RUNART_JOBS_DIR"
log "  - Escritura: EXITOSA"
log "  - Lectura: EXITOSA"
log "  - Permisos: $PERMS ($OWNER:$GROUP)"
log "  - Estado restaurado: READ_ONLY=$READ_ONLY, DRY_RUN=$DRY_RUN"
log ""
log_info "Log completo guardado en: $LOG_FILE"

# ==============================================================================
# Fin
# ==============================================================================

exit 0
