#!/usr/bin/env bash
#
# Diagnóstico completo de permisos para el entorno STAGING
# RunArt Foundry — F10-d Verificación de permisos y lectura/escritura
#
# Propósito:
#   - Verificar variables de entorno READ_ONLY y DRY_RUN
#   - Comprobar existencia y permisos de rutas críticas para plugin IA-Visual
#   - Detectar usuario PHP/web server (www-data, nginx, etc.)
#   - Validar capacidad de lectura en data/assistants/rewrite/
#   - Validar capacidad de escritura en wp-content/uploads/runart-jobs/
#   - Generar log detallado para diagnóstico
#
# Uso:
#   bash tools/diagnose_staging_permissions.sh
#

set -euo pipefail

# ==============================================================================
# Configuración
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TIMESTAMP=$(date -u +"%Y%m%dT%H%M%SZ")
LOG_FILE="$PROJECT_ROOT/logs/staging_permissions_${TIMESTAMP}.log"
ENV_CHECK_LOG="$PROJECT_ROOT/logs/env_check_staging.log"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ==============================================================================
# Funciones de utilidad
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

# ==============================================================================
# Inicialización
# ==============================================================================

mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$ENV_CHECK_LOG")"

log_section "🔍 DIAGNÓSTICO DE PERMISOS — STAGING RUNART FOUNDRY"
log "Timestamp: $TIMESTAMP"
log "Project root: $PROJECT_ROOT"
log "Log file: $LOG_FILE"

# ==============================================================================
# 1. Verificación de variables de entorno
# ==============================================================================

log_section "1️⃣ VERIFICACIÓN DE VARIABLES DE ENTORNO"

READ_ONLY="${READ_ONLY:-}"
DRY_RUN="${DRY_RUN:-}"

if [[ -z "$READ_ONLY" ]]; then
    log_warning "READ_ONLY no está definida en el entorno"
    READ_ONLY="0"
else
    log_info "READ_ONLY=$READ_ONLY"
fi

if [[ -z "$DRY_RUN" ]]; then
    log_warning "DRY_RUN no está definida en el entorno"
    DRY_RUN="0"
else
    log_info "DRY_RUN=$DRY_RUN"
fi

# Guardar en env_check_staging.log
{
    echo "# Environment Check — Staging RunArt Foundry"
    echo "# Timestamp: $TIMESTAMP"
    echo "READ_ONLY=$READ_ONLY"
    echo "DRY_RUN=$DRY_RUN"
} > "$ENV_CHECK_LOG"

log_success "Variables de entorno documentadas en: $ENV_CHECK_LOG"

# ==============================================================================
# 2. Detección de usuario web server
# ==============================================================================

log_section "2️⃣ DETECCIÓN DE USUARIO WEB SERVER"

WEB_USER=""

# Intentar detectar usuario desde procesos corriendo
if command -v ps >/dev/null 2>&1; then
    # Buscar procesos de Apache
    APACHE_USER=$(ps aux | grep -E '(apache2|httpd)' | grep -v grep | grep -v root | head -1 | awk '{print $1}' || echo "")
    if [[ -n "$APACHE_USER" ]]; then
        WEB_USER="$APACHE_USER"
        log_info "Usuario Apache detectado: $WEB_USER"
    fi
    
    # Buscar procesos de nginx
    if [[ -z "$WEB_USER" ]]; then
        NGINX_USER=$(ps aux | grep nginx | grep -v grep | grep -v root | head -1 | awk '{print $1}' || echo "")
        if [[ -n "$NGINX_USER" ]]; then
            WEB_USER="$NGINX_USER"
            log_info "Usuario nginx detectado: $WEB_USER"
        fi
    fi
    
    # Buscar procesos PHP-FPM
    if [[ -z "$WEB_USER" ]]; then
        PHP_FPM_USER=$(ps aux | grep php-fpm | grep -v grep | grep -v root | head -1 | awk '{print $1}' || echo "")
        if [[ -n "$PHP_FPM_USER" ]]; then
            WEB_USER="$PHP_FPM_USER"
            log_info "Usuario PHP-FPM detectado: $WEB_USER"
        fi
    fi
fi

# Fallback: www-data es el más común
if [[ -z "$WEB_USER" ]]; then
    WEB_USER="www-data"
    log_warning "No se pudo detectar usuario web server, usando fallback: $WEB_USER"
fi

log_success "Usuario web server determinado: $WEB_USER"

# ==============================================================================
# 3. Verificación de rutas críticas — Data JSON
# ==============================================================================

log_section "3️⃣ VERIFICACIÓN DE RUTAS CRÍTICAS — DATA JSON"

CRITICAL_PATHS=(
    "$PROJECT_ROOT/data/assistants/rewrite"
    "$PROJECT_ROOT/data/assistants/rewrite/index.json"
    "$PROJECT_ROOT/data/assistants/rewrite/page_42.json"
    "$PROJECT_ROOT/data/assistants/rewrite/page_43.json"
    "$PROJECT_ROOT/data/assistants/rewrite/page_44.json"
)

ALL_PATHS_OK=true

for path in "${CRITICAL_PATHS[@]}"; do
    if [[ -e "$path" ]]; then
        # Verificar tipo
        if [[ -d "$path" ]]; then
            TYPE="directorio"
        elif [[ -f "$path" ]]; then
            TYPE="archivo"
        else
            TYPE="otro"
        fi
        
        # Verificar permisos
        PERMS=$(stat -c "%a" "$path" 2>/dev/null || stat -f "%A" "$path" 2>/dev/null || echo "???")
        OWNER=$(stat -c "%U" "$path" 2>/dev/null || stat -f "%Su" "$path" 2>/dev/null || echo "???")
        GROUP=$(stat -c "%G" "$path" 2>/dev/null || stat -f "%Sg" "$path" 2>/dev/null || echo "???")
        
        # Verificar si es legible
        if [[ -r "$path" ]]; then
            log_success "$(basename "$path") — $TYPE, permisos: $PERMS, owner: $OWNER:$GROUP, legible: SÍ"
        else
            log_error "$(basename "$path") — $TYPE, permisos: $PERMS, owner: $OWNER:$GROUP, legible: NO"
            ALL_PATHS_OK=false
        fi
    else
        log_error "$(basename "$path") — NO EXISTE"
        ALL_PATHS_OK=false
    fi
done

if $ALL_PATHS_OK; then
    log_success "Todas las rutas críticas de data/ están OK"
else
    log_warning "Algunas rutas críticas tienen problemas"
fi

# ==============================================================================
# 4. Verificación de rutas del plugin
# ==============================================================================

log_section "4️⃣ VERIFICACIÓN DE RUTAS DEL PLUGIN"

# Asumir ubicación típica de plugins en WordPress
WP_CONTENT_DIR="$PROJECT_ROOT/wp-content"
PLUGIN_DIR="$WP_CONTENT_DIR/plugins/runart-wpcli-bridge"
PLUGIN_DATA_DIR="$PLUGIN_DIR/data/assistants/rewrite"

if [[ -d "$PLUGIN_DATA_DIR" ]]; then
    log_info "Directorio de datos del plugin encontrado: $PLUGIN_DATA_DIR"
    
    PLUGIN_PATHS=(
        "$PLUGIN_DATA_DIR/index.json"
        "$PLUGIN_DATA_DIR/page_42.json"
        "$PLUGIN_DATA_DIR/page_43.json"
        "$PLUGIN_DATA_DIR/page_44.json"
    )
    
    for path in "${PLUGIN_PATHS[@]}"; do
        if [[ -f "$path" ]]; then
            PERMS=$(stat -c "%a" "$path" 2>/dev/null || stat -f "%A" "$path" 2>/dev/null || echo "???")
            if [[ -r "$path" ]]; then
                log_success "$(basename "$path") en plugin — legible, permisos: $PERMS"
            else
                log_warning "$(basename "$path") en plugin — NO legible, permisos: $PERMS"
            fi
        else
            log_warning "$(basename "$path") — NO EXISTE en plugin"
        fi
    done
else
    log_warning "Directorio de datos del plugin NO encontrado: $PLUGIN_DATA_DIR"
    log_info "El plugin intentará leer desde otras ubicaciones (repo o wp-content/runart-data)"
fi

# ==============================================================================
# 5. Verificación de directorio de escritura — wp-content/uploads
# ==============================================================================

log_section "5️⃣ VERIFICACIÓN DE DIRECTORIO DE ESCRITURA"

UPLOADS_DIR="$WP_CONTENT_DIR/uploads"
RUNART_JOBS_DIR="$UPLOADS_DIR/runart-jobs"

if [[ ! -d "$UPLOADS_DIR" ]]; then
    log_error "Directorio de uploads NO existe: $UPLOADS_DIR"
else
    PERMS=$(stat -c "%a" "$UPLOADS_DIR" 2>/dev/null || stat -f "%A" "$UPLOADS_DIR" 2>/dev/null || echo "???")
    OWNER=$(stat -c "%U" "$UPLOADS_DIR" 2>/dev/null || stat -f "%Su" "$UPLOADS_DIR" 2>/dev/null || echo "???")
    GROUP=$(stat -c "%G" "$UPLOADS_DIR" 2>/dev/null || stat -f "%Sg" "$UPLOADS_DIR" 2>/dev/null || echo "???")
    
    if [[ -w "$UPLOADS_DIR" ]]; then
        log_success "Directorio uploads es escribible — permisos: $PERMS, owner: $OWNER:$GROUP"
    else
        log_warning "Directorio uploads NO es escribible — permisos: $PERMS, owner: $OWNER:$GROUP"
    fi
fi

if [[ ! -d "$RUNART_JOBS_DIR" ]]; then
    log_warning "Directorio runart-jobs NO existe: $RUNART_JOBS_DIR"
    log_info "Intentando crear directorio..."
    
    if mkdir -p "$RUNART_JOBS_DIR" 2>/dev/null; then
        log_success "Directorio runart-jobs creado exitosamente"
    else
        log_error "No se pudo crear directorio runart-jobs (permisos insuficientes)"
    fi
else
    PERMS=$(stat -c "%a" "$RUNART_JOBS_DIR" 2>/dev/null || stat -f "%A" "$RUNART_JOBS_DIR" 2>/dev/null || echo "???")
    OWNER=$(stat -c "%U" "$RUNART_JOBS_DIR" 2>/dev/null || stat -f "%Su" "$RUNART_JOBS_DIR" 2>/dev/null || echo "???")
    GROUP=$(stat -c "%G" "$RUNART_JOBS_DIR" 2>/dev/null || stat -f "%Sg" "$RUNART_JOBS_DIR" 2>/dev/null || echo "???")
    
    if [[ -w "$RUNART_JOBS_DIR" ]]; then
        log_success "Directorio runart-jobs es escribible — permisos: $PERMS, owner: $OWNER:$GROUP"
    else
        log_error "Directorio runart-jobs NO es escribible — permisos: $PERMS, owner: $OWNER:$GROUP"
    fi
fi

# ==============================================================================
# 6. Prueba de escritura controlada (si READ_ONLY=0)
# ==============================================================================

log_section "6️⃣ PRUEBA DE ESCRITURA CONTROLADA"

if [[ "$READ_ONLY" == "1" ]]; then
    log_warning "READ_ONLY=1 — Omitiendo prueba de escritura"
    log_info "Ejecutar con READ_ONLY=0 para habilitar prueba de escritura"
else
    log_info "READ_ONLY=0 — Ejecutando prueba de escritura"
    
    if [[ -d "$RUNART_JOBS_DIR" ]]; then
        TEST_FILE="$RUNART_JOBS_DIR/test_write_${TIMESTAMP}.json"
        TEST_CONTENT='{"test":"ok","timestamp":"'$TIMESTAMP'"}'
        
        if echo "$TEST_CONTENT" > "$TEST_FILE" 2>/dev/null; then
            log_success "Prueba de escritura exitosa: $TEST_FILE"
            
            # Verificar contenido
            if [[ -f "$TEST_FILE" ]]; then
                READ_CONTENT=$(cat "$TEST_FILE")
                if [[ "$READ_CONTENT" == "$TEST_CONTENT" ]]; then
                    log_success "Contenido verificado correctamente"
                else
                    log_error "Contenido no coincide con lo esperado"
                fi
                
                # Limpiar archivo de prueba
                rm -f "$TEST_FILE"
                log_info "Archivo de prueba eliminado"
            fi
        else
            log_error "No se pudo escribir archivo de prueba (permisos insuficientes)"
        fi
    else
        log_error "Directorio runart-jobs no existe, omitiendo prueba de escritura"
    fi
fi

# ==============================================================================
# 7. Recomendaciones
# ==============================================================================

log_section "7️⃣ RECOMENDACIONES"

log_info "Basado en el diagnóstico:"
echo "" | tee -a "$LOG_FILE"

if [[ "$READ_ONLY" == "1" ]]; then
    log_warning "⚠ RECOMENDACIÓN 1: Temporalmente deshabilitar READ_ONLY para pruebas:"
    echo "   export READ_ONLY=0" | tee -a "$LOG_FILE"
fi

if [[ "$DRY_RUN" == "1" ]]; then
    log_warning "⚠ RECOMENDACIÓN 2: Temporalmente deshabilitar DRY_RUN para pruebas:"
    echo "   export DRY_RUN=0" | tee -a "$LOG_FILE"
fi

if [[ ! $ALL_PATHS_OK ]]; then
    log_warning "⚠ RECOMENDACIÓN 3: Ajustar permisos de rutas críticas:"
    echo "   sudo chown -R $WEB_USER:$WEB_USER $PROJECT_ROOT/data/assistants/rewrite/" | tee -a "$LOG_FILE"
    echo "   sudo chmod -R 755 $PROJECT_ROOT/data/assistants/rewrite/" | tee -a "$LOG_FILE"
fi

if [[ -d "$UPLOADS_DIR" ]] && [[ ! -w "$UPLOADS_DIR" ]]; then
    log_warning "⚠ RECOMENDACIÓN 4: Ajustar permisos de directorio uploads:"
    echo "   sudo chown -R $WEB_USER:$WEB_USER $UPLOADS_DIR" | tee -a "$LOG_FILE"
    echo "   sudo chmod -R 755 $UPLOADS_DIR" | tee -a "$LOG_FILE"
fi

if [[ ! -d "$PLUGIN_DATA_DIR" ]] || [[ ! -f "$PLUGIN_DATA_DIR/index.json" ]]; then
    log_warning "⚠ RECOMENDACIÓN 5: Copiar JSONs a ubicación del plugin:"
    echo "   mkdir -p $PLUGIN_DATA_DIR" | tee -a "$LOG_FILE"
    echo "   cp -r $PROJECT_ROOT/data/assistants/rewrite/*.json $PLUGIN_DATA_DIR/" | tee -a "$LOG_FILE"
fi

# ==============================================================================
# 8. Resumen final
# ==============================================================================

log_section "8️⃣ RESUMEN FINAL"

log "Variables de entorno:"
log "  - READ_ONLY: $READ_ONLY"
log "  - DRY_RUN: $DRY_RUN"
log ""
log "Usuario web server: $WEB_USER"
log ""
log "Rutas críticas: $(if $ALL_PATHS_OK; then echo "OK"; else echo "PROBLEMAS DETECTADOS"; fi)"
log ""
log "Directorio de escritura:"
if [[ -d "$RUNART_JOBS_DIR" ]] && [[ -w "$RUNART_JOBS_DIR" ]]; then
    log "  - wp-content/uploads/runart-jobs/: ESCRIBIBLE"
elif [[ -d "$RUNART_JOBS_DIR" ]]; then
    log "  - wp-content/uploads/runart-jobs/: NO ESCRIBIBLE"
else
    log "  - wp-content/uploads/runart-jobs/: NO EXISTE"
fi

log ""
log_success "Diagnóstico completado. Ver log completo en: $LOG_FILE"

# ==============================================================================
# Fin
# ==============================================================================

exit 0
