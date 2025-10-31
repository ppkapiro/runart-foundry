#!/usr/bin/env bash
#
# Script de ajuste de permisos para entorno STAGING
# RunArt Foundry — F10-d Corrección de permisos
#
# Propósito:
#   - Ajustar permisos de data/assistants/rewrite/ para lectura del plugin
#   - Ajustar permisos de wp-content/uploads/ para escritura
#   - Crear directorio runart-jobs/ si no existe
#   - Copiar JSONs al plugin si es necesario
#
# Uso:
#   bash tools/fix_staging_permissions.sh [--web-user=USER] [--dry-run]
#
# Opciones:
#   --web-user=USER    Usuario del web server (default: auto-detect, fallback: www-data)
#   --dry-run          Solo mostrar comandos sin ejecutarlos
#

set -euo pipefail

# ==============================================================================
# Configuración
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TIMESTAMP=$(date -u +"%Y%m%dT%H%M%SZ")
LOG_FILE="$PROJECT_ROOT/logs/staging_permissions_fix_${TIMESTAMP}.log"

# Parámetros por defecto
DRY_RUN=false
WEB_USER=""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ==============================================================================
# Parsear argumentos
# ==============================================================================

for arg in "$@"; do
    case $arg in
        --web-user=*)
            WEB_USER="${arg#*=}"
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            echo "Uso: $0 [--web-user=USER] [--dry-run]"
            exit 1
            ;;
    esac
done

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

log_cmd() {
    echo -e "${CYAN}▶${NC} $1" | tee -a "$LOG_FILE"
}

run_cmd() {
    local cmd="$1"
    log_cmd "$cmd"
    
    if $DRY_RUN; then
        log_warning "[DRY-RUN] Comando no ejecutado"
        return 0
    fi
    
    if eval "$cmd"; then
        log_success "Comando ejecutado exitosamente"
        return 0
    else
        log_error "Error al ejecutar comando (código: $?)"
        return 1
    fi
}

# ==============================================================================
# Inicialización
# ==============================================================================

mkdir -p "$(dirname "$LOG_FILE")"

log_section "🔧 AJUSTE DE PERMISOS — STAGING"
log "Timestamp: $TIMESTAMP"
log "Project root: $PROJECT_ROOT"

if $DRY_RUN; then
    log_warning "MODO DRY-RUN: Los comandos se mostrarán pero NO se ejecutarán"
fi

# ==============================================================================
# 1. Detectar usuario web server
# ==============================================================================

log_section "1️⃣ DETECTAR USUARIO WEB SERVER"

if [[ -z "$WEB_USER" ]]; then
    # Auto-detectar
    if command -v ps >/dev/null 2>&1; then
        # Buscar Apache
        APACHE_USER=$(ps aux | grep -E '(apache2|httpd)' | grep -v grep | grep -v root | head -1 | awk '{print $1}' || echo "")
        if [[ -n "$APACHE_USER" ]]; then
            WEB_USER="$APACHE_USER"
            log_info "Usuario Apache detectado: $WEB_USER"
        fi
        
        # Buscar nginx
        if [[ -z "$WEB_USER" ]]; then
            NGINX_USER=$(ps aux | grep nginx | grep -v grep | grep -v root | head -1 | awk '{print $1}' || echo "")
            if [[ -n "$NGINX_USER" ]]; then
                WEB_USER="$NGINX_USER"
                log_info "Usuario nginx detectado: $WEB_USER"
            fi
        fi
        
        # Buscar PHP-FPM
        if [[ -z "$WEB_USER" ]]; then
            PHP_FPM_USER=$(ps aux | grep php-fpm | grep -v grep | grep -v root | head -1 | awk '{print $1}' || echo "")
            if [[ -n "$PHP_FPM_USER" ]]; then
                WEB_USER="$PHP_FPM_USER"
                log_info "Usuario PHP-FPM detectado: $WEB_USER"
            fi
        fi
    fi
    
    # Fallback
    if [[ -z "$WEB_USER" ]]; then
        WEB_USER="www-data"
        log_warning "No se pudo detectar usuario web server, usando fallback: $WEB_USER"
    fi
else
    log_info "Usuario web server especificado manualmente: $WEB_USER"
fi

log_success "Usuario web server: $WEB_USER"

# ==============================================================================
# 2. Verificar que el usuario existe
# ==============================================================================

log_section "2️⃣ VERIFICAR USUARIO"

if id "$WEB_USER" >/dev/null 2>&1; then
    log_success "Usuario $WEB_USER existe en el sistema"
else
    log_error "Usuario $WEB_USER NO existe en el sistema"
    exit 1
fi

# ==============================================================================
# 3. Ajustar permisos de data/assistants/rewrite/
# ==============================================================================

log_section "3️⃣ AJUSTAR PERMISOS DE DATA/ASSISTANTS/REWRITE/"

DATA_DIR="$PROJECT_ROOT/data/assistants/rewrite"

if [[ -d "$DATA_DIR" ]]; then
    log_info "Directorio encontrado: $DATA_DIR"
    
    # Cambiar owner (requiere sudo si no somos el owner)
    if [[ $(stat -c "%U" "$DATA_DIR" 2>/dev/null || stat -f "%Su" "$DATA_DIR" 2>/dev/null) != "$WEB_USER" ]]; then
        log_info "Ajustando owner a $WEB_USER:$WEB_USER"
        run_cmd "sudo chown -R $WEB_USER:$WEB_USER '$DATA_DIR'"
    else
        log_info "Owner ya es $WEB_USER, omitiendo chown"
    fi
    
    # Ajustar permisos (755 para directorios, 644 para archivos)
    log_info "Ajustando permisos de lectura"
    run_cmd "sudo chmod -R 755 '$DATA_DIR'"
    run_cmd "sudo find '$DATA_DIR' -type f -exec chmod 644 {} +"
    
    log_success "Permisos ajustados para $DATA_DIR"
else
    log_warning "Directorio NO existe: $DATA_DIR"
fi

# ==============================================================================
# 4. Ajustar permisos de wp-content/uploads/
# ==============================================================================

log_section "4️⃣ AJUSTAR PERMISOS DE WP-CONTENT/UPLOADS/"

WP_CONTENT_DIR="$PROJECT_ROOT/wp-content"
UPLOADS_DIR="$WP_CONTENT_DIR/uploads"

if [[ -d "$UPLOADS_DIR" ]]; then
    log_info "Directorio encontrado: $UPLOADS_DIR"
    
    # Cambiar owner
    if [[ $(stat -c "%U" "$UPLOADS_DIR" 2>/dev/null || stat -f "%Su" "$UPLOADS_DIR" 2>/dev/null) != "$WEB_USER" ]]; then
        log_info "Ajustando owner a $WEB_USER:$WEB_USER"
        run_cmd "sudo chown -R $WEB_USER:$WEB_USER '$UPLOADS_DIR'"
    else
        log_info "Owner ya es $WEB_USER, omitiendo chown"
    fi
    
    # Ajustar permisos (775 para permitir escritura)
    log_info "Ajustando permisos de escritura"
    run_cmd "sudo chmod -R 775 '$UPLOADS_DIR'"
    
    log_success "Permisos ajustados para $UPLOADS_DIR"
else
    log_error "Directorio NO existe: $UPLOADS_DIR"
    log_info "Creando directorio..."
    run_cmd "sudo mkdir -p '$UPLOADS_DIR'"
    run_cmd "sudo chown $WEB_USER:$WEB_USER '$UPLOADS_DIR'"
    run_cmd "sudo chmod 775 '$UPLOADS_DIR'"
fi

# ==============================================================================
# 5. Crear directorio runart-jobs/
# ==============================================================================

log_section "5️⃣ CREAR DIRECTORIO RUNART-JOBS/"

RUNART_JOBS_DIR="$UPLOADS_DIR/runart-jobs"

if [[ ! -d "$RUNART_JOBS_DIR" ]]; then
    log_info "Creando directorio: $RUNART_JOBS_DIR"
    run_cmd "sudo mkdir -p '$RUNART_JOBS_DIR'"
    run_cmd "sudo chown $WEB_USER:$WEB_USER '$RUNART_JOBS_DIR'"
    run_cmd "sudo chmod 775 '$RUNART_JOBS_DIR'"
    log_success "Directorio creado y configurado"
else
    log_info "Directorio ya existe: $RUNART_JOBS_DIR"
    
    # Verificar y ajustar permisos
    if [[ $(stat -c "%U" "$RUNART_JOBS_DIR" 2>/dev/null || stat -f "%Su" "$RUNART_JOBS_DIR" 2>/dev/null) != "$WEB_USER" ]]; then
        run_cmd "sudo chown $WEB_USER:$WEB_USER '$RUNART_JOBS_DIR'"
    fi
    
    run_cmd "sudo chmod 775 '$RUNART_JOBS_DIR'"
    log_success "Permisos verificados/ajustados"
fi

# ==============================================================================
# 6. Copiar JSONs al plugin si es necesario
# ==============================================================================

log_section "6️⃣ VERIFICAR JSONSS EN EL PLUGIN"

PLUGIN_DIR="$WP_CONTENT_DIR/plugins/runart-wpcli-bridge"
PLUGIN_DATA_DIR="$PLUGIN_DIR/data/assistants/rewrite"

if [[ ! -d "$PLUGIN_DIR" ]]; then
    log_warning "Plugin NO está instalado en: $PLUGIN_DIR"
    log_info "El plugin usará los JSONs desde el repositorio o wp-content/runart-data"
else
    log_info "Plugin encontrado: $PLUGIN_DIR"
    
    # Verificar si existen los JSONs en el plugin
    if [[ ! -f "$PLUGIN_DATA_DIR/index.json" ]]; then
        log_warning "JSONs NO encontrados en el plugin"
        log_info "Copiando JSONs desde el repositorio al plugin..."
        
        if [[ -d "$DATA_DIR" ]]; then
            run_cmd "sudo mkdir -p '$PLUGIN_DATA_DIR'"
            run_cmd "sudo cp -r '$DATA_DIR'/*.json '$PLUGIN_DATA_DIR/'"
            run_cmd "sudo chown -R $WEB_USER:$WEB_USER '$PLUGIN_DATA_DIR'"
            run_cmd "sudo chmod -R 644 '$PLUGIN_DATA_DIR'/*.json"
            log_success "JSONs copiados al plugin"
        else
            log_error "Directorio fuente NO existe: $DATA_DIR"
        fi
    else
        log_success "JSONs ya están presentes en el plugin"
    fi
fi

# ==============================================================================
# 7. Resumen
# ==============================================================================

log_section "7️⃣ RESUMEN"

log "Ajustes realizados:"
log "  - Usuario web server: $WEB_USER"
log "  - data/assistants/rewrite/: permisos ajustados para lectura"
log "  - wp-content/uploads/: permisos ajustados para escritura"
log "  - wp-content/uploads/runart-jobs/: creado/verificado"

if [[ -d "$PLUGIN_DATA_DIR" ]] && [[ -f "$PLUGIN_DATA_DIR/index.json" ]]; then
    log "  - JSONs en el plugin: OK"
else
    log "  - JSONs en el plugin: usar ubicaciones alternativas"
fi

log ""
if $DRY_RUN; then
    log_warning "MODO DRY-RUN: Ningún comando fue ejecutado realmente"
    log_info "Ejecuta sin --dry-run para aplicar los cambios"
else
    log_success "✅ Ajustes de permisos completados"
fi

log ""
log_info "Log completo guardado en: $LOG_FILE"

# ==============================================================================
# Fin
# ==============================================================================

exit 0
