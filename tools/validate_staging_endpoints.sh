#!/usr/bin/env bash
#
# Validación de endpoints REST del plugin IA-Visual
# RunArt Foundry — F10-d Verificación de endpoints
#
# Propósito:
#   - Probar endpoint /wp-json/runart/content/enriched-list
#   - Probar endpoint /wp-json/runart/content/enriched?page_id=page_42
#   - Verificar que la página Panel Editorial IA-Visual carga correctamente
#   - Documentar resultados para diagnóstico
#
# Uso:
#   bash tools/validate_staging_endpoints.sh [STAGING_URL] [WP_USER] [WP_PASSWORD]
#
# Argumentos:
#   STAGING_URL    URL del sitio staging (ej: https://staging.runartfoundry.com)
#   WP_USER        Usuario de WordPress con permisos de administrador
#   WP_PASSWORD    Contraseña del usuario
#
# Nota: Si no se proporcionan credenciales, solo se probarán endpoints públicos
#

set -euo pipefail

# ==============================================================================
# Configuración
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TIMESTAMP=$(date -u +"%Y%m%dT%H%M%SZ")
LOG_FILE="$PROJECT_ROOT/logs/staging_endpoints_${TIMESTAMP}.log"

# Parámetros
STAGING_URL="${1:-https://staging.runartfoundry.com}"
WP_USER="${2:-}"
WP_PASSWORD="${3:-}"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
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

log_endpoint() {
    echo -e "${CYAN}🌐${NC} $1" | tee -a "$LOG_FILE"
}

log_json() {
    echo -e "${MAGENTA}📄${NC} JSON Response:" | tee -a "$LOG_FILE"
    if command -v jq >/dev/null 2>&1; then
        echo "$1" | jq '.' 2>/dev/null | tee -a "$LOG_FILE" || echo "$1" | tee -a "$LOG_FILE"
    else
        echo "$1" | tee -a "$LOG_FILE"
    fi
}

# ==============================================================================
# Inicialización
# ==============================================================================

mkdir -p "$(dirname "$LOG_FILE")"

log_section "🌐 VALIDACIÓN DE ENDPOINTS REST — STAGING"
log "Timestamp: $TIMESTAMP"
log "Staging URL: $STAGING_URL"

if [[ -n "$WP_USER" ]] && [[ -n "$WP_PASSWORD" ]]; then
    log_info "Credenciales proporcionadas, se probarán endpoints autenticados"
else
    log_warning "No se proporcionaron credenciales, solo endpoints públicos"
fi

# Verificar que curl está disponible
if ! command -v curl >/dev/null 2>&1; then
    log_error "curl no está instalado. Instalar: sudo apt-get install curl"
    exit 1
fi

# ==============================================================================
# 1. Obtener nonce de WordPress (si tenemos credenciales)
# ==============================================================================

WP_NONCE=""

if [[ -n "$WP_USER" ]] && [[ -n "$WP_PASSWORD" ]]; then
    log_section "1️⃣ AUTENTICACIÓN — OBTENER NONCE"
    
    log_info "Obteniendo nonce de WordPress REST API..."
    
    # Intentar obtener nonce desde la página de inicio
    RESPONSE=$(curl -s -c /tmp/cookies_staging_${TIMESTAMP}.txt \
        -u "$WP_USER:$WP_PASSWORD" \
        "$STAGING_URL/wp-json/" 2>/dev/null || echo "")
    
    if [[ -n "$RESPONSE" ]]; then
        # Intentar extraer nonce (esto es complejo sin usar la UI)
        # Por ahora, usaremos autenticación básica
        log_success "Autenticación básica configurada"
    else
        log_warning "No se pudo obtener respuesta de la API"
    fi
fi

# ==============================================================================
# 2. Probar endpoint: /wp-json/runart/content/enriched-list
# ==============================================================================

log_section "2️⃣ ENDPOINT: /wp-json/runart/content/enriched-list"

ENDPOINT_LIST="$STAGING_URL/wp-json/runart/content/enriched-list"
log_endpoint "GET $ENDPOINT_LIST"

if [[ -n "$WP_USER" ]] && [[ -n "$WP_PASSWORD" ]]; then
    RESPONSE_LIST=$(curl -s -w "\n%{http_code}" \
        -u "$WP_USER:$WP_PASSWORD" \
        "$ENDPOINT_LIST" 2>/dev/null)
else
    RESPONSE_LIST=$(curl -s -w "\n%{http_code}" "$ENDPOINT_LIST" 2>/dev/null)
fi

# Separar body y status code
HTTP_CODE_LIST=$(echo "$RESPONSE_LIST" | tail -1)
BODY_LIST=$(echo "$RESPONSE_LIST" | sed '$d')

log_info "HTTP Status: $HTTP_CODE_LIST"

if [[ "$HTTP_CODE_LIST" == "200" ]]; then
    log_success "Endpoint accesible (HTTP 200)"
    
    # Verificar si hay datos
    if echo "$BODY_LIST" | grep -q '"ok":true'; then
        log_success "Respuesta válida (ok: true)"
        
        # Contar items
        ITEMS_COUNT=$(echo "$BODY_LIST" | grep -o '"items":\[' | wc -l || echo "0")
        if [[ "$ITEMS_COUNT" -gt 0 ]]; then
            # Intentar extraer el total
            TOTAL=$(echo "$BODY_LIST" | grep -o '"total":[0-9]*' | grep -o '[0-9]*' || echo "unknown")
            log_success "Contenidos encontrados: $TOTAL"
        else
            log_warning "No se encontraron contenidos (items: [])"
        fi
        
        log_json "$BODY_LIST"
    else
        log_warning "Respuesta inesperada"
        log_json "$BODY_LIST"
    fi
elif [[ "$HTTP_CODE_LIST" == "401" ]] || [[ "$HTTP_CODE_LIST" == "403" ]]; then
    log_error "Error de autenticación (HTTP $HTTP_CODE_LIST)"
    log_info "Proporciona credenciales válidas como argumentos del script"
else
    log_error "Error en endpoint (HTTP $HTTP_CODE_LIST)"
    log_json "$BODY_LIST"
fi

# ==============================================================================
# 3. Probar endpoints individuales
# ==============================================================================

log_section "3️⃣ ENDPOINTS: /wp-json/runart/content/enriched?page_id=..."

PAGE_IDS=("page_42" "page_43" "page_44")

for PAGE_ID in "${PAGE_IDS[@]}"; do
    log_info "Probando: $PAGE_ID"
    
    ENDPOINT_PAGE="$STAGING_URL/wp-json/runart/content/enriched?page_id=$PAGE_ID"
    log_endpoint "GET $ENDPOINT_PAGE"
    
    if [[ -n "$WP_USER" ]] && [[ -n "$WP_PASSWORD" ]]; then
        RESPONSE_PAGE=$(curl -s -w "\n%{http_code}" \
            -u "$WP_USER:$WP_PASSWORD" \
            "$ENDPOINT_PAGE" 2>/dev/null)
    else
        RESPONSE_PAGE=$(curl -s -w "\n%{http_code}" "$ENDPOINT_PAGE" 2>/dev/null)
    fi
    
    HTTP_CODE_PAGE=$(echo "$RESPONSE_PAGE" | tail -1)
    BODY_PAGE=$(echo "$RESPONSE_PAGE" | sed '$d')
    
    if [[ "$HTTP_CODE_PAGE" == "200" ]]; then
        if echo "$BODY_PAGE" | grep -q '"ok":true'; then
            log_success "$PAGE_ID — Datos encontrados (HTTP 200)"
            
            # Verificar si tiene visual_references
            if echo "$BODY_PAGE" | grep -q '"visual_references"'; then
                log_success "  └─ visual_references presentes"
            else
                log_warning "  └─ sin visual_references"
            fi
        else
            log_warning "$PAGE_ID — Respuesta sin datos (ok: false)"
        fi
    elif [[ "$HTTP_CODE_PAGE" == "404" ]]; then
        log_error "$PAGE_ID — No encontrado (HTTP 404)"
    else
        log_error "$PAGE_ID — Error (HTTP $HTTP_CODE_PAGE)"
    fi
done

# ==============================================================================
# 4. Probar página Panel Editorial IA-Visual
# ==============================================================================

log_section "4️⃣ PÁGINA: Panel Editorial IA-Visual"

PAGE_URL="$STAGING_URL/en/panel-editorial-ia-visual/"
log_endpoint "GET $PAGE_URL"

if [[ -n "$WP_USER" ]] && [[ -n "$WP_PASSWORD" ]]; then
    RESPONSE_PANEL=$(curl -s -w "\n%{http_code}" \
        -u "$WP_USER:$WP_PASSWORD" \
        "$PAGE_URL" 2>/dev/null)
else
    RESPONSE_PANEL=$(curl -s -w "\n%{http_code}" "$PAGE_URL" 2>/dev/null)
fi

HTTP_CODE_PANEL=$(echo "$RESPONSE_PANEL" | tail -1)
BODY_PANEL=$(echo "$RESPONSE_PANEL" | sed '$d')

if [[ "$HTTP_CODE_PANEL" == "200" ]]; then
    log_success "Página accesible (HTTP 200)"
    
    # Verificar que contiene el shortcode/componente
    if echo "$BODY_PANEL" | grep -q "runart-editorial-panel"; then
        log_success "Componente del panel encontrado en la página"
    elif echo "$BODY_PANEL" | grep -q "Panel Editorial IA-Visual"; then
        log_success "Título del panel encontrado en la página"
    else
        log_warning "No se detectó el componente del panel en el HTML"
    fi
    
    # Verificar que carga scripts de REST
    if echo "$BODY_PANEL" | grep -q "wp-json/runart/content"; then
        log_success "Referencias a endpoints REST encontradas"
    else
        log_warning "No se detectaron referencias a endpoints REST"
    fi
else
    log_error "Error al acceder a la página (HTTP $HTTP_CODE_PANEL)"
fi

# ==============================================================================
# 5. Diagnóstico de paths
# ==============================================================================

log_section "5️⃣ DIAGNÓSTICO DE PATHS (desde plugin)"

log_info "Verificando desde qué ubicación el plugin lee los datos..."

# Probar endpoint con diagnóstico extendido
ENDPOINT_DIAG="$STAGING_URL/wp-json/runart/content/enriched?page_id=page_42"

if [[ -n "$WP_USER" ]] && [[ -n "$WP_PASSWORD" ]]; then
    RESPONSE_DIAG=$(curl -s \
        -u "$WP_USER:$WP_PASSWORD" \
        "$ENDPOINT_DIAG" 2>/dev/null)
else
    RESPONSE_DIAG=$(curl -s "$ENDPOINT_DIAG" 2>/dev/null)
fi

# Buscar metadata de source/paths
if echo "$RESPONSE_DIAG" | grep -q '"source"'; then
    SOURCE=$(echo "$RESPONSE_DIAG" | grep -o '"source":"[^"]*"' | cut -d'"' -f4 || echo "unknown")
    log_info "Source detectado: $SOURCE"
fi

if echo "$RESPONSE_DIAG" | grep -q '"paths_tried"'; then
    log_info "Plugin intentó leer desde múltiples ubicaciones (ver metadata)"
    
    if command -v jq >/dev/null 2>&1; then
        PATHS=$(echo "$RESPONSE_DIAG" | jq -r '.meta.paths_tried[]?' 2>/dev/null || echo "")
        if [[ -n "$PATHS" ]]; then
            log_info "Paths intentados:"
            echo "$PATHS" | while read -r path; do
                log "  - $path"
            done
        fi
    fi
fi

# ==============================================================================
# 6. Resumen
# ==============================================================================

log_section "6️⃣ RESUMEN"

log "Endpoints probados:"
log "  - /wp-json/runart/content/enriched-list: HTTP $HTTP_CODE_LIST"
log "  - /wp-json/runart/content/enriched?page_id=page_42: (ver log)"
log "  - Página Panel Editorial: HTTP $HTTP_CODE_PANEL"
log ""

if [[ "$HTTP_CODE_LIST" == "200" ]] && [[ "$HTTP_CODE_PANEL" == "200" ]]; then
    log_success "✅ Validación exitosa — endpoints funcionando correctamente"
else
    log_warning "⚠ Algunos endpoints presentan problemas — revisar log para detalles"
fi

log ""
log_info "Log completo guardado en: $LOG_FILE"

# Limpiar cookies temporales
rm -f /tmp/cookies_staging_${TIMESTAMP}.txt 2>/dev/null || true

# ==============================================================================
# Fin
# ==============================================================================

exit 0
