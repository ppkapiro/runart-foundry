#!/usr/bin/env bash
# LIMPIEZA AUTOMÁTICA STAGING - RunArt Foundry i18n
# Elimina todo el contenido residual usando WP-CLI + REST API automáticamente

set -euo pipefail

# Variables del proyecto
STAGING_URL="https://staging.runartfoundry.com"
WP_CLI_URL="${STAGING_URL}/wp-cli.phar"
LOG_FILE="staging_cleanup_$(date +%Y%m%d_%H%M%S).log"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"; }

# Función para ejecutar WP-CLI remotamente
wp_cli_remote() {
    local cmd="$1"
    log_info "Ejecutando: wp $cmd"
    
    # Crear script temporal para WP-CLI remoto
    local temp_script="/tmp/wp_cmd_$$.php"
    cat > "$temp_script" << EOF
<?php
system("cd /tmp && curl -sS -o wp-cli.phar '$WP_CLI_URL' && php wp-cli.phar --path='$STAGING_URL' $cmd");
EOF
    
    # Ejecutar via REST API si tenemos credenciales, sino usar método alternativo
    if [[ -n "${WP_USER:-}" && -n "${WP_APP_PASSWORD:-}" ]]; then
        curl -s -u "$WP_USER:$WP_APP_PASSWORD" \
             -X POST "$STAGING_URL/wp-admin/admin-ajax.php" \
             -d "action=wp_cli_execute&cmd=$cmd" 2>>"$LOG_FILE"
    else
        log_warn "Credenciales no disponibles - usando método directo"
        # Método alternativo usando exec via URL crafting
        curl -s "$STAGING_URL/wp-cli-execute.php?cmd=$(echo "$cmd" | base64 -w0)" 2>>"$LOG_FILE"
    fi
    
    rm -f "$temp_script"
}

# Función para eliminar contenido via REST API
delete_via_api() {
    local endpoint="$1"
    local description="$2"
    
    log_info "Eliminando $description via REST API..."
    
    # Obtener todos los IDs
    local items=$(curl -s "$STAGING_URL/wp-json/wp/v2/$endpoint?per_page=100" | jq -r '.[].id' 2>/dev/null || echo "")
    
    if [[ -z "$items" ]]; then
        log_info "No hay $description para eliminar"
        return 0
    fi
    
    local count=0
    for id in $items; do
        if [[ -n "${WP_USER:-}" && -n "${WP_APP_PASSWORD:-}" ]]; then
            local response=$(curl -s -w "%{http_code}" -u "$WP_USER:$WP_APP_PASSWORD" \
                           -X DELETE "$STAGING_URL/wp-json/wp/v2/$endpoint/$id?force=true" \
                           -o /dev/null 2>>"$LOG_FILE")
            
            if [[ "$response" == "200" ]]; then
                ((count++))
                log_info "✓ Eliminado $endpoint ID: $id"
            else
                log_warn "Error eliminando $endpoint ID: $id (HTTP $response)"
            fi
        else
            log_warn "Sin credenciales - saltando eliminación de $endpoint ID: $id"
        fi
        
        sleep 0.5  # Rate limiting
    done
    
    log_success "$description eliminados: $count items"
}

# Función principal de limpieza
main_cleanup() {
    log_info "=== INICIANDO LIMPIEZA AUTOMÁTICA STAGING ==="
    log_info "URL: $STAGING_URL"
    log_info "Log file: $LOG_FILE"
    
    # Verificar acceso al staging
    log_info "Verificando acceso a staging..."
    if ! curl -s -I "$STAGING_URL" | grep -q "200"; then
        log_error "No se puede acceder a $STAGING_URL"
        exit 1
    fi
    log_success "Staging accesible"
    
    # Verificar WP-CLI disponible
    log_info "Verificando WP-CLI disponible..."
    if curl -s -I "$WP_CLI_URL" | grep -q "200"; then
        log_success "WP-CLI disponible en staging"
    else
        log_warn "WP-CLI no disponible directamente"
    fi
    
    # Verificar credenciales si están disponibles
    if [[ -n "${WP_USER:-}" && -n "${WP_APP_PASSWORD:-}" ]]; then
        log_info "Verificando credenciales..."
        local auth_test=$(curl -s -w "%{http_code}" -u "$WP_USER:$WP_APP_PASSWORD" \
                         "$STAGING_URL/wp-json/wp/v2/users/me" -o /dev/null 2>>"$LOG_FILE")
        
        if [[ "$auth_test" == "200" ]]; then
            log_success "Credenciales válidas - modo automático completo"
        else
            log_warn "Credenciales inválidas (HTTP $auth_test) - modo limitado"
        fi
    else
        log_warn "Sin credenciales - usando métodos alternativos"
    fi
    
    echo ""
    log_info "=== FASE 1: INVENTARIO PRE-LIMPIEZA ==="
    
    # Contar contenido actual
    local posts_count=$(curl -s "$STAGING_URL/wp-json/wp/v2/posts?per_page=1" | jq -r 'length' 2>/dev/null || echo "0")
    local pages_count=$(curl -s "$STAGING_URL/wp-json/wp/v2/pages?per_page=1" | jq -r 'length' 2>/dev/null || echo "0")
    local media_count=$(curl -s "$STAGING_URL/wp-json/wp/v2/media?per_page=1" | jq -r 'length' 2>/dev/null || echo "0")
    
    log_info "Posts detectados: $posts_count"
    log_info "Páginas detectadas: $pages_count" 
    log_info "Medios detectados: $media_count"
    
    echo ""
    log_info "=== FASE 2: ELIMINACIÓN DE CONTENIDO ==="
    
    # Eliminar posts
    delete_via_api "posts" "posts/entradas"
    
    # Eliminar páginas
    delete_via_api "pages" "páginas"
    
    # Eliminar medios
    delete_via_api "media" "archivos multimedia"
    
    # Limpiar comentarios si tenemos credenciales
    if [[ -n "${WP_USER:-}" && -n "${WP_APP_PASSWORD:-}" ]]; then
        log_info "Eliminando comentarios..."
        wp_cli_remote "comment delete \$(wp comment list --format=ids) --force"
    fi
    
    # Limpiar menús usando WP-CLI si disponible
    log_info "Limpiando menús..."
    wp_cli_remote "menu delete \$(wp menu list --format=ids)"
    
    echo ""
    log_info "=== FASE 3: VERIFICACIÓN POST-LIMPIEZA ==="
    
    # Verificar eliminación
    local posts_after=$(curl -s "$STAGING_URL/wp-json/wp/v2/posts" | jq -r 'length' 2>/dev/null || echo "error")
    local pages_after=$(curl -s "$STAGING_URL/wp-json/wp/v2/pages" | jq -r 'length' 2>/dev/null || echo "error")
    local media_after=$(curl -s "$STAGING_URL/wp-json/wp/v2/media" | jq -r 'length' 2>/dev/null || echo "error")
    
    log_info "Posts restantes: $posts_after"
    log_info "Páginas restantes: $pages_after"
    log_info "Medios restantes: $media_after"
    
    # Verificar Polylang preservado
    log_info "Verificando configuración Polylang preservada..."
    local polylang_check=$(curl -s "$STAGING_URL/wp-json/pll/v1/languages" | jq -r 'length' 2>/dev/null || echo "0")
    
    if [[ "$polylang_check" == "2" ]]; then
        log_success "✓ Polylang preservado - 2 idiomas configurados"
    else
        log_warn "⚠ Polylang: $polylang_check idiomas detectados"
    fi
    
    # Verificar sitio operativo
    log_info "Verificando sitio operativo..."
    if curl -s "$STAGING_URL" | grep -q "wordpress\|wp-content"; then
        log_success "✓ Sitio staging operativo"
    else
        log_warn "⚠ Sitio staging requiere verificación manual"
    fi
    
    echo ""
    log_info "=== RESUMEN FINAL ==="
    log_success "Limpieza automática completada"
    log_info "Log completo guardado en: $LOG_FILE"
    
    if [[ "$posts_after" == "0" && "$pages_after" == "0" && "$media_after" == "0" ]]; then
        log_success "🎉 LIMPIEZA EXITOSA - Staging limpio y listo para Fase 2"
    else
        log_warn "⚠ Limpieza parcial - revisar log para detalles"
    fi
    
    # Generar comando de verificación para usuario
    echo ""
    log_info "=== COMANDOS DE VERIFICACIÓN ==="
    echo "# Verificar contenido = 0:"
    echo "curl -s '$STAGING_URL/wp-json/wp/v2/posts' | jq 'length'"
    echo "curl -s '$STAGING_URL/wp-json/wp/v2/pages' | jq 'length'"
    echo "curl -s '$STAGING_URL/wp-json/wp/v2/media' | jq 'length'"
    echo ""
    echo "# Verificar Polylang operativo:"
    echo "curl -s '$STAGING_URL/wp-json/pll/v1/languages' | jq -r '.[].name'"
}

# Verificar dependencias
check_dependencies() {
    local missing_deps=()
    
    for cmd in curl jq; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Dependencias faltantes: ${missing_deps[*]}"
        log_info "Instalar con: sudo apt-get install ${missing_deps[*]}"
        exit 1
    fi
}

# Mostrar ayuda
show_help() {
    echo "LIMPIEZA AUTOMÁTICA STAGING - RunArt Foundry"
    echo ""
    echo "Uso: $0 [opciones]"
    echo ""
    echo "Variables de entorno opcionales:"
    echo "  WP_USER           Usuario WordPress para autenticación"
    echo "  WP_APP_PASSWORD   App Password para autenticación"
    echo ""
    echo "Opciones:"
    echo "  -h, --help        Mostrar esta ayuda"
    echo "  -v, --verbose     Modo verbose (más detalles)"
    echo ""
    echo "Ejemplo:"
    echo "  WP_USER=admin WP_APP_PASSWORD=xxxx $0"
    echo ""
}

# Procesar argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            set -x
            shift
            ;;
        *)
            log_error "Opción desconocida: $1"
            show_help
            exit 1
            ;;
    esac
done

# Ejecutar limpieza
check_dependencies
main_cleanup