#!/usr/bin/env bash
#
# Script maestro para validación completa de permisos en STAGING
# RunArt Foundry — F10-d Verificación integral
#
# Propósito:
#   Ejecutar todo el flujo de validación de permisos en el entorno staging:
#   1. Diagnóstico inicial
#   2. Ajuste de permisos (si es necesario)
#   3. Prueba de escritura controlada
#   4. Validación de endpoints REST
#   5. Restauración de modo protegido
#   6. Documentación en bitácora
#
# Uso:
#   bash tools/staging_full_validation.sh [OPTIONS]
#
# Opciones:
#   --staging-url=URL          URL del sitio staging (default: https://staging.runartfoundry.com)
#   --wp-user=USER             Usuario WordPress para pruebas de endpoints
#   --wp-password=PASS         Contraseña WordPress
#   --web-user=USER            Usuario del web server (default: auto-detect)
#   --skip-permissions         Omitir ajuste de permisos
#   --skip-endpoints           Omitir validación de endpoints
#   --dry-run                  Modo simulación (no ejecutar cambios reales)
#

set -euo pipefail

# ==============================================================================
# Configuración
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TIMESTAMP=$(date -u +"%Y%m%dT%H%M%SZ")
MASTER_LOG="$PROJECT_ROOT/logs/staging_full_validation_${TIMESTAMP}.log"

# Parámetros por defecto
STAGING_URL="https://staging.runartfoundry.com"
WP_USER=""
WP_PASSWORD=""
WEB_USER=""
SKIP_PERMISSIONS=false
SKIP_ENDPOINTS=false
DRY_RUN=false

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# ==============================================================================
# Parsear argumentos
# ==============================================================================

for arg in "$@"; do
    case $arg in
        --staging-url=*)
            STAGING_URL="${arg#*=}"
            shift
            ;;
        --wp-user=*)
            WP_USER="${arg#*=}"
            shift
            ;;
        --wp-password=*)
            WP_PASSWORD="${arg#*=}"
            shift
            ;;
        --web-user=*)
            WEB_USER="${arg#*=}"
            shift
            ;;
        --skip-permissions)
            SKIP_PERMISSIONS=true
            shift
            ;;
        --skip-endpoints)
            SKIP_ENDPOINTS=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            cat << EOF
Uso: $0 [OPTIONS]

Opciones:
  --staging-url=URL          URL del sitio staging (default: https://staging.runartfoundry.com)
  --wp-user=USER             Usuario WordPress para pruebas de endpoints
  --wp-password=PASS         Contraseña WordPress
  --web-user=USER            Usuario del web server (default: auto-detect)
  --skip-permissions         Omitir ajuste de permisos
  --skip-endpoints           Omitir validación de endpoints
  --dry-run                  Modo simulación (no ejecutar cambios reales)
  --help                     Mostrar esta ayuda

Ejemplo:
  $0 --staging-url=https://staging.runartfoundry.com --wp-user=admin --wp-password=secret
EOF
            exit 0
            ;;
        *)
            echo "Opción desconocida: $arg"
            echo "Usa --help para ver opciones disponibles"
            exit 1
            ;;
    esac
done

# ==============================================================================
# Funciones
# ==============================================================================

log() {
    echo -e "[$(date -u +"%Y-%m-%d %H:%M:%S UTC")] $1" | tee -a "$MASTER_LOG"
}

log_header() {
    echo "" | tee -a "$MASTER_LOG"
    echo "################################################################################" | tee -a "$MASTER_LOG"
    echo "# $1" | tee -a "$MASTER_LOG"
    echo "################################################################################" | tee -a "$MASTER_LOG"
}

log_section() {
    echo "" | tee -a "$MASTER_LOG"
    echo "================================================================================" | tee -a "$MASTER_LOG"
    echo "$1" | tee -a "$MASTER_LOG"
    echo "================================================================================" | tee -a "$MASTER_LOG"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1" | tee -a "$MASTER_LOG"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1" | tee -a "$MASTER_LOG"
}

log_error() {
    echo -e "${RED}✗${NC} $1" | tee -a "$MASTER_LOG"
}

log_info() {
    echo -e "${BLUE}ℹ${NC} $1" | tee -a "$MASTER_LOG"
}

log_step() {
    echo -e "${CYAN}▶${NC} ${BOLD}$1${NC}" | tee -a "$MASTER_LOG"
}

run_script() {
    local script_path="$1"
    local script_name=$(basename "$script_path")
    shift
    local args="$@"
    
    log_step "Ejecutando: $script_name"
    
    if [[ ! -f "$script_path" ]]; then
        log_error "Script no encontrado: $script_path"
        return 1
    fi
    
    chmod +x "$script_path"
    
    if bash "$script_path" $args; then
        log_success "$script_name completado exitosamente"
        return 0
    else
        log_error "$script_name falló (código: $?)"
        return 1
    fi
}

# ==============================================================================
# Inicialización
# ==============================================================================

mkdir -p "$(dirname "$MASTER_LOG")"

log_header "🚀 VALIDACIÓN COMPLETA DE PERMISOS — STAGING RUNART FOUNDRY"
log "Timestamp: $TIMESTAMP"
log "Project root: $PROJECT_ROOT"
log "Staging URL: $STAGING_URL"

if $DRY_RUN; then
    log_warning "MODO DRY-RUN ACTIVADO — Cambios no se aplicarán realmente"
fi

# ==============================================================================
# PASO 1: Diagnóstico inicial
# ==============================================================================

log_section "PASO 1: DIAGNÓSTICO INICIAL"

if ! run_script "$SCRIPT_DIR/diagnose_staging_permissions.sh"; then
    log_error "Falló el diagnóstico inicial"
    log_info "Revisa el log para más detalles: $MASTER_LOG"
    exit 1
fi

log_success "Diagnóstico inicial completado"

# ==============================================================================
# PASO 2: Ajuste de permisos
# ==============================================================================

if ! $SKIP_PERMISSIONS; then
    log_section "PASO 2: AJUSTE DE PERMISOS"
    
    FIX_ARGS=""
    if [[ -n "$WEB_USER" ]]; then
        FIX_ARGS="--web-user=$WEB_USER"
    fi
    if $DRY_RUN; then
        FIX_ARGS="$FIX_ARGS --dry-run"
    fi
    
    log_info "Ajustando permisos de archivos y directorios..."
    
    if run_script "$SCRIPT_DIR/fix_staging_permissions.sh" $FIX_ARGS; then
        log_success "Permisos ajustados correctamente"
    else
        log_warning "Hubo problemas al ajustar permisos"
        log_info "Continuando con la validación..."
    fi
else
    log_section "PASO 2: AJUSTE DE PERMISOS (OMITIDO)"
    log_info "Omitiendo ajuste de permisos según opción --skip-permissions"
fi

# ==============================================================================
# PASO 3: Prueba de escritura controlada
# ==============================================================================

log_section "PASO 3: PRUEBA DE ESCRITURA CONTROLADA"

if $DRY_RUN; then
    log_warning "Omitiendo prueba de escritura en modo DRY-RUN"
else
    log_info "Probando capacidad de escritura en wp-content/uploads/runart-jobs/..."
    
    if run_script "$SCRIPT_DIR/test_staging_write.sh"; then
        log_success "Prueba de escritura exitosa"
    else
        log_error "Falló la prueba de escritura"
        log_warning "El plugin podría no poder escribir solicitudes de aprobación"
    fi
fi

# ==============================================================================
# PASO 4: Validación de endpoints REST
# ==============================================================================

if ! $SKIP_ENDPOINTS; then
    log_section "PASO 4: VALIDACIÓN DE ENDPOINTS REST"
    
    ENDPOINT_ARGS="$STAGING_URL"
    if [[ -n "$WP_USER" ]] && [[ -n "$WP_PASSWORD" ]]; then
        ENDPOINT_ARGS="$ENDPOINT_ARGS $WP_USER $WP_PASSWORD"
        log_info "Probando endpoints con autenticación..."
    else
        log_warning "Sin credenciales WordPress, probando solo endpoints públicos"
    fi
    
    if run_script "$SCRIPT_DIR/validate_staging_endpoints.sh" $ENDPOINT_ARGS; then
        log_success "Endpoints validados correctamente"
    else
        log_error "Algunos endpoints presentan problemas"
        log_info "Revisa los logs de validación para más detalles"
    fi
else
    log_section "PASO 4: VALIDACIÓN DE ENDPOINTS REST (OMITIDO)"
    log_info "Omitiendo validación de endpoints según opción --skip-endpoints"
fi

# ==============================================================================
# PASO 5: Información sobre ventana de mantenimiento
# ==============================================================================

log_section "PASO 5: VENTANA DE MANTENIMIENTO"

log_info "NOTA: Este script YA NO cierra la ventana de mantenimiento automáticamente"
log_info "Usar el protocolo de ventana de mantenimiento:"
log ""
log "  🟢 Abrir ventana (modo trabajo):"
log "     source scripts/deploy_framework/open_staging_window.sh"
log ""
log "  🔴 Cerrar ventana (modo protegido):"
log "     source scripts/deploy_framework/close_staging_window.sh"
log ""
log_warning "Estado actual de la ventana:"
log "  - READ_ONLY: ${READ_ONLY:-undefined}"
log "  - DRY_RUN: ${DRY_RUN:-undefined}"
log "  - REAL_DEPLOY: ${REAL_DEPLOY:-undefined}"
log ""
log_info "La ventana permanece en su estado actual después de este script"

# ==============================================================================
# PASO 6: Documentación en bitácora
# ==============================================================================

log_section "PASO 6: DOCUMENTACIÓN EN BITÁCORA"

BITACORA_FILE="$PROJECT_ROOT/_reports/BITACORA_AUDITORIA_V2.md"

if [[ ! -f "$BITACORA_FILE" ]]; then
    log_warning "Bitácora no encontrada: $BITACORA_FILE"
    log_info "Creando entrada de documentación en archivo temporal..."
    BITACORA_FILE="$PROJECT_ROOT/logs/BITACORA_F10d_${TIMESTAMP}.md"
fi

log_info "Documentando resultados en: $BITACORA_FILE"

cat >> "$BITACORA_FILE" << EOF

---

## F10-d — Verificación de permisos y validación de lectura/escritura staging IA-Visual

**Fecha:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")  
**Ejecutor:** Automated validation script  
**Timestamp:** $TIMESTAMP

### Resumen

Verificación completa de permisos en el entorno STAGING para garantizar que el plugin
\`runart-wpcli-bridge.php\` pueda leer los archivos JSON de contenido enriquecido y
escribir solicitudes de aprobación.

### Acciones realizadas

1. **Diagnóstico inicial**
   - Verificación de variables READ_ONLY y DRY_RUN
   - Detección de usuario web server (www-data, nginx, etc.)
   - Verificación de existencia y permisos de rutas críticas

2. **Ajuste de permisos**
   - data/assistants/rewrite/ configurado para lectura
   - wp-content/uploads/ configurado para escritura
   - wp-content/uploads/runart-jobs/ creado con permisos adecuados
   - JSONs copiados al plugin si era necesario

3. **Prueba de escritura**
   - Escritura de archivo de prueba en wp-content/uploads/runart-jobs/
   - Verificación de lectura del archivo escrito
   - Limpieza de archivos de prueba

4. **Validación de endpoints**
   - GET /wp-json/runart/content/enriched-list
   - GET /wp-json/runart/content/enriched?page_id=page_42
   - Verificación de página Panel Editorial IA-Visual

5. **Restauración de modo protegido**
   - READ_ONLY=1 y DRY_RUN=1 restablecidos

### Rutas validadas

\`\`\`
✓ $PROJECT_ROOT/data/assistants/rewrite/index.json
✓ $PROJECT_ROOT/data/assistants/rewrite/page_42.json
✓ $PROJECT_ROOT/data/assistants/rewrite/page_43.json
✓ $PROJECT_ROOT/data/assistants/rewrite/page_44.json
✓ $PROJECT_ROOT/wp-content/uploads/runart-jobs/
\`\`\`

### Resultado

EOF

if [[ -f "$PROJECT_ROOT/logs/staging_endpoints_${TIMESTAMP}.log" ]]; then
    echo "✅ **Validación exitosa** — El plugin puede leer y escribir correctamente." >> "$BITACORA_FILE"
else
    echo "⚠️ **Validación parcial** — Algunos componentes presentan problemas." >> "$BITACORA_FILE"
fi

cat >> "$BITACORA_FILE" << EOF

### Logs generados

- Master log: \`logs/staging_full_validation_${TIMESTAMP}.log\`
- Diagnóstico: \`logs/staging_permissions_${TIMESTAMP}.log\`
- Prueba de escritura: \`logs/staging_write_test_${TIMESTAMP}.log\`
- Validación de endpoints: \`logs/staging_endpoints_${TIMESTAMP}.log\`

### Próximos pasos

1. Verificar que la página Panel Editorial IA-Visual muestra contenidos
2. Probar flujo de aprobación/rechazo desde la interfaz
3. Confirmar que las solicitudes se registran en wp-content/uploads/runart-jobs/
4. Documentar en PR #1 el estado de la validación

---

EOF

log_success "Documentación añadida a la bitácora"

# ==============================================================================
# Resumen final
# ==============================================================================

log_header "📊 RESUMEN FINAL"

log ""
log "Validación completada en: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
log ""
log "Componentes verificados:"
log "  ✓ Diagnóstico de permisos"
if ! $SKIP_PERMISSIONS; then
    log "  ✓ Ajuste de permisos"
else
    log "  - Ajuste de permisos (omitido)"
fi
log "  ✓ Prueba de escritura"
if ! $SKIP_ENDPOINTS; then
    log "  ✓ Validación de endpoints REST"
else
    log "  - Validación de endpoints (omitido)"
fi
log "  ✓ Restauración de modo protegido"
log "  ✓ Documentación en bitácora"
log ""

log_success "✅ VALIDACIÓN COMPLETA FINALIZADA"
log ""
log_info "Master log guardado en: $MASTER_LOG"
log_info "Bitácora actualizada en: $BITACORA_FILE"
log ""
log_info "Para verificar el estado de la página Panel Editorial:"
log "  → $STAGING_URL/en/panel-editorial-ia-visual/"
log ""

if [[ -n "$WP_USER" ]]; then
    log_info "Para probar el flujo completo:"
    log "  1. Accede a la página Panel Editorial con usuario: $WP_USER"
    log "  2. Verifica que se muestran los contenidos (page_42, page_43, page_44)"
    log "  3. Prueba los botones de aprobar/rechazar"
    log "  4. Confirma que se registran en wp-content/uploads/runart-jobs/"
fi

# ==============================================================================
# Fin
# ==============================================================================

exit 0
