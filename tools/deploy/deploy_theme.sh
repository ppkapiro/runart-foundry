#!/usr/bin/env bash

# ==============================================================================
# RunArt Foundry — Theme Deployment Script
# ==============================================================================
# Propósito: Deployment seguro y auditado del tema RunArt Base
# Versión: 1.0.0
# Última actualización: 2025-01-29
# ==============================================================================

set -euo pipefail

# ==============================================================================
# CI-GUARD: Validación de Seguridad
# ==============================================================================
# Este script está protegido por CI guards. Modificaciones a defaults
# READ_ONLY/DRY_RUN activarán validación en GitHub Actions.
# ==============================================================================

# ------------------------------------------------------------------------------
# Configuración y Defaults
# ------------------------------------------------------------------------------

# Security-First: Todo es simulación por defecto
readonly DEFAULT_READ_ONLY=1
readonly DEFAULT_DRY_RUN=1
readonly DEFAULT_REAL_DEPLOY=0
readonly DEFAULT_SKIP_SSH=1
readonly DEFAULT_TARGET="staging"
readonly DEFAULT_THEME_DIR="runart-base"

# Cargar valores de entorno o usar defaults
READ_ONLY="${READ_ONLY:-${DEFAULT_READ_ONLY}}"
DRY_RUN="${DRY_RUN:-${DEFAULT_DRY_RUN}}"
REAL_DEPLOY="${REAL_DEPLOY:-${DEFAULT_REAL_DEPLOY}}"
SKIP_SSH="${SKIP_SSH:-${DEFAULT_SKIP_SSH}}"
TARGET="${TARGET:-${DEFAULT_TARGET}}"
THEME_DIR="${THEME_DIR:-${DEFAULT_THEME_DIR}}"

# Variables adicionales
ROLLBACK_ON_FAIL="${ROLLBACK_ON_FAIL:-1}"
BACKUP_RETENTION="${BACKUP_RETENTION:-7}"
LOG_LEVEL="${LOG_LEVEL:-INFO}"
SMOKE_TESTS="${SMOKE_TESTS:-1}"

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
REPORTS_DIR="${WORKSPACE_ROOT}/_reports/deploy_logs"
BACKUPS_DIR="${REPORTS_DIR}/backups"
ROLLBACKS_DIR="${REPORTS_DIR}/rollbacks"

# Timestamp para logs
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
LOG_FILE="${REPORTS_DIR}/DEPLOY_${REAL_DEPLOY:+REAL_}${DRY_RUN:+DRYRUN_}${TIMESTAMP}.md"

# Colores para output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# ------------------------------------------------------------------------------
# Funciones de Logging
# ------------------------------------------------------------------------------

log() {
    local level="$1"
    shift
    local message="$*"
    local color="${NC}"
    
    case "${level}" in
        ERROR)   color="${RED}" ;;
        SUCCESS) color="${GREEN}" ;;
        WARN)    color="${YELLOW}" ;;
        INFO)    color="${BLUE}" ;;
    esac
    
    echo -e "${color}[${level}]${NC} ${message}" | tee -a "${LOG_FILE}"
}

# ------------------------------------------------------------------------------
# Función: Inicializar Reporte
# ------------------------------------------------------------------------------

init_report() {
    mkdir -p "${REPORTS_DIR}" "${BACKUPS_DIR}" "${ROLLBACKS_DIR}"
    
    cat > "${LOG_FILE}" << EOF
# Deployment Report — RunArt Base

**Timestamp:** ${TIMESTAMP}  
**User:** $(whoami)@$(hostname)  
**Mode:** $([ "${REAL_DEPLOY}" -eq 1 ] && echo "REAL DEPLOYMENT" || echo "SIMULATION")  
**Target:** ${TARGET}  
**Theme:** ${THEME_DIR}

---

## Configuration

\`\`\`bash
READ_ONLY=${READ_ONLY}
DRY_RUN=${DRY_RUN}
REAL_DEPLOY=${REAL_DEPLOY}
SKIP_SSH=${SKIP_SSH}
TARGET=${TARGET}
THEME_DIR=${THEME_DIR}
ROLLBACK_ON_FAIL=${ROLLBACK_ON_FAIL}
BACKUP_RETENTION=${BACKUP_RETENTION}
LOG_LEVEL=${LOG_LEVEL}
SMOKE_TESTS=${SMOKE_TESTS}
\`\`\`

---

## Execution Log

EOF
    
    log INFO "Reporte inicializado: ${LOG_FILE}"
}

# ------------------------------------------------------------------------------
# Función: Validaciones Pre-Deployment
# ------------------------------------------------------------------------------

validate_config() {
    log INFO "Validando configuración..."
    
    # Validación 1: Tema debe ser runart-base
    if [ "${THEME_DIR}" != "runart-base" ]; then
        log ERROR "THEME_DIR debe ser 'runart-base'. Actual: '${THEME_DIR}'"
        log ERROR "Ver docs/deploy/DEPLOY_FRAMEWORK.md para justificación del canon"
        exit 1
    fi
    
    # Validación 2: REAL_DEPLOY=1 solo permite staging
    if [ "${REAL_DEPLOY}" -eq 1 ] && [ "${TARGET}" = "production" ]; then
        log ERROR "Deployment real a producción bloqueado"
        log ERROR "Producción requiere:"
        log ERROR "  - Label 'maintenance-window' en PR"
        log ERROR "  - Issue con DEPLOY_ROLLOUT_PLAN.md completado"
        log ERROR "  - Ejecución manual por Admin"
        log ERROR "Ver docs/deploy/DEPLOY_FRAMEWORK.md para procedimiento completo"
        exit 1
    fi
    
    # Validación 3: Si REAL_DEPLOY=1, debe tener READ_ONLY=0 y DRY_RUN=0
    if [ "${REAL_DEPLOY}" -eq 1 ]; then
        if [ "${READ_ONLY}" -ne 0 ] || [ "${DRY_RUN}" -ne 0 ]; then
            log ERROR "REAL_DEPLOY=1 requiere READ_ONLY=0 y DRY_RUN=0"
            log ERROR "Configuración actual: READ_ONLY=${READ_ONLY}, DRY_RUN=${DRY_RUN}"
            exit 1
        fi
    fi
    
    # Validación 4: Verificar que directorio del tema existe
    local theme_path="${WORKSPACE_ROOT}/${THEME_DIR}"
    if [ ! -d "${theme_path}" ]; then
        log ERROR "Directorio del tema no encontrado: ${theme_path}"
        exit 1
    fi
    
    log SUCCESS "Validación de configuración: OK"
}

# ------------------------------------------------------------------------------
# Función: Validar SSH
# ------------------------------------------------------------------------------

validate_ssh() {
    if [ "${SKIP_SSH}" -eq 1 ]; then
        log INFO "SKIP_SSH=1: Omitiendo validación SSH (CI mode)"
        return 0
    fi
    
    log INFO "Validando acceso SSH..."
    
    # Cargar variables de entorno si existen
    if [ -f ~/.runart_staging_env ]; then
        # shellcheck source=/dev/null
        source ~/.runart_staging_env
    fi
    
    # Verificar variables requeridas
    if [ -z "${STAGING_HOST:-}" ] || [ -z "${STAGING_USER:-}" ]; then
        log ERROR "Variables STAGING_HOST y STAGING_USER requeridas"
        log ERROR "Crear archivo ~/.runart_staging_env con:"
        log ERROR "  export STAGING_HOST='access958591985.webspace-data.io'"
        log ERROR "  export STAGING_USER='u111876951'"
        log ERROR "  export STAGING_WP_PATH='/homepages/7/d958591985/htdocs/staging'"
        log ERROR "  export SSH_KEY_PATH='\$HOME/.ssh/id_rsa_ionos'"
        exit 1
    fi
    
    # Verificar SSH key si está especificada
    if [ -n "${SSH_KEY_PATH:-}" ]; then
        if [ ! -f "${SSH_KEY_PATH}" ]; then
            log ERROR "SSH key no encontrada: ${SSH_KEY_PATH}"
            log ERROR "Generar key con:"
            log ERROR "  ssh-keygen -t rsa -b 4096 -f ${SSH_KEY_PATH}"
            log ERROR "  ssh-copy-id -i ${SSH_KEY_PATH} ${STAGING_USER}@${STAGING_HOST}"
            exit 1
        fi
    fi
    
    # Test conexión SSH
    if ! ssh -o BatchMode=yes -o ConnectTimeout=10 "${STAGING_USER}@${STAGING_HOST}" "echo 'SSH OK'" &>/dev/null; then
        log ERROR "Conexión SSH fallida: ${STAGING_USER}@${STAGING_HOST}"
        log ERROR "Verificar:"
        log ERROR "  - SSH key copiada al servidor (ssh-copy-id)"
        log ERROR "  - Credenciales correctas"
        log ERROR "  - Servidor accesible"
        exit 1
    fi
    
    log SUCCESS "Validación SSH: OK"
}

# ------------------------------------------------------------------------------
# Función: Generar Backup Pre-Deployment
# ------------------------------------------------------------------------------

generate_backup() {
    if [ "${REAL_DEPLOY}" -ne 1 ]; then
        log INFO "Modo simulación: Omitiendo generación de backup"
        return 0
    fi
    
    log INFO "Generando backup pre-deploy..."
    
    local backup_name="${TARGET}_${TIMESTAMP}.tar.gz"
    local backup_path="${BACKUPS_DIR}/${backup_name}"
    local checksum_path="${backup_path}.sha256"
    
    # Generar tarball del tema actual en servidor
    # shellcheck source=/dev/null
    source ~/.runart_staging_env
    
    local remote_theme_path="${STAGING_WP_PATH}/wp-content/themes/${THEME_DIR}"
    
    log INFO "Creando tarball en servidor..."
    ssh "${STAGING_USER}@${STAGING_HOST}" \
        "cd ${STAGING_WP_PATH}/wp-content/themes && tar -czf ~/backup_${TIMESTAMP}.tar.gz ${THEME_DIR}/"
    
    log INFO "Descargando backup..."
    scp "${STAGING_USER}@${STAGING_HOST}:~/backup_${TIMESTAMP}.tar.gz" "${backup_path}"
    
    log INFO "Generando checksum..."
    sha256sum "${backup_path}" > "${checksum_path}"
    
    log INFO "Limpiando backup remoto..."
    ssh "${STAGING_USER}@${STAGING_HOST}" "rm -f ~/backup_${TIMESTAMP}.tar.gz"
    
    log SUCCESS "Backup guardado: ${backup_path}"
    log INFO "Checksum: $(cat "${checksum_path}")"
    
    # Cleanup: Eliminar backups antiguos
    log INFO "Limpiando backups antiguos (retención: ${BACKUP_RETENTION} días)..."
    find "${BACKUPS_DIR}" -name "*.tar.gz" -mtime +${BACKUP_RETENTION} -delete
    find "${BACKUPS_DIR}" -name "*.sha256" -mtime +${BACKUP_RETENTION} -delete
    
    echo "BACKUP_PATH=${backup_path}" >> "${LOG_FILE}"
    echo "BACKUP_CHECKSUM=$(cat "${checksum_path}")" >> "${LOG_FILE}"
}

# ------------------------------------------------------------------------------
# Función: Ejecutar Rsync (Simulación o Real)
# ------------------------------------------------------------------------------

execute_rsync() {
    log INFO "Ejecutando rsync..."
    
    # shellcheck source=/dev/null
    source ~/.runart_staging_env
    
    local theme_path="${WORKSPACE_ROOT}/${THEME_DIR}/"
    local remote_path="${STAGING_USER}@${STAGING_HOST}:${STAGING_WP_PATH}/wp-content/themes/${THEME_DIR}/"
    
    local rsync_args=(
        -avz
        --delete
        --exclude='.git*'
        --exclude='node_modules'
        --exclude='.DS_Store'
        --exclude='*.log'
    )
    
    # Añadir --dry-run si DRY_RUN=1
    if [ "${DRY_RUN}" -eq 1 ]; then
        rsync_args+=(--dry-run)
        log INFO "Modo DRY_RUN: Rsync con --dry-run"
    fi
    
    log INFO "Origen: ${theme_path}"
    log INFO "Destino: ${remote_path}"
    
    # Ejecutar rsync y capturar output
    local rsync_output
    if rsync_output=$(rsync "${rsync_args[@]}" "${theme_path}" "${remote_path}" 2>&1); then
        log SUCCESS "Rsync completado exitosamente"
        
        # Contar archivos modificados
        local files_changed
        files_changed=$(echo "${rsync_output}" | grep -c "^[<>ch]" || echo "0")
        log INFO "Archivos modificados: ${files_changed}"
        
        # Guardar output completo en log
        {
            echo ""
            echo "### Rsync Output"
            echo '```'
            echo "${rsync_output}"
            echo '```'
        } >> "${LOG_FILE}"
    else
        log ERROR "Rsync fallido con exit code $?"
        log ERROR "Output: ${rsync_output}"
        return 1
    fi
}

# ------------------------------------------------------------------------------
# Función: Ejecutar Comandos WP-CLI
# ------------------------------------------------------------------------------

execute_wpcli() {
    if [ "${REAL_DEPLOY}" -ne 1 ]; then
        log INFO "Modo simulación: Omitiendo comandos WP-CLI"
        log INFO "Comandos que se ejecutarían:"
        log INFO "  - wp theme activate ${THEME_DIR}"
        log INFO "  - wp cache flush"
        log INFO "  - wp rewrite flush"
        return 0
    fi
    
    log INFO "Ejecutando comandos WP-CLI en servidor remoto..."
    
    # shellcheck source=/dev/null
    source ~/.runart_staging_env
    
    # Comando 1: Activar tema
    log INFO "Activando tema: ${THEME_DIR}"
    if ssh "${STAGING_USER}@${STAGING_HOST}" "cd ${STAGING_WP_PATH} && wp theme activate ${THEME_DIR}"; then
        log SUCCESS "Tema activado"
    else
        log ERROR "Falló activación de tema"
        return 1
    fi
    
    # Comando 2: Limpiar cache
    log INFO "Limpiando cache..."
    if ssh "${STAGING_USER}@${STAGING_HOST}" "cd ${STAGING_WP_PATH} && wp cache flush"; then
        log SUCCESS "Cache limpiado"
    else
        log WARN "Falló limpieza de cache (puede ser normal si no hay cache plugin)"
    fi
    
    # Comando 3: Flush rewrite rules
    log INFO "Flushing rewrite rules..."
    if ssh "${STAGING_USER}@${STAGING_HOST}" "cd ${STAGING_WP_PATH} && wp rewrite flush"; then
        log SUCCESS "Rewrite rules actualizadas"
    else
        log WARN "Falló flush de rewrite rules"
    fi
}

# ------------------------------------------------------------------------------
# Función: Smoke Tests
# ------------------------------------------------------------------------------

run_smoke_tests() {
    if [ "${SMOKE_TESTS}" -ne 1 ]; then
        log INFO "SMOKE_TESTS=0: Omitiendo smoke tests"
        return 0
    fi
    
    log INFO "Ejecutando smoke tests..."
    
    local base_url
    if [ "${TARGET}" = "staging" ]; then
        base_url="https://staging.runartfoundry.com"
    else
        base_url="https://runartfoundry.com"
    fi
    
    local test_urls=(
        "${base_url}/"
        "${base_url}/about/"
        "${base_url}/contact/"
        "${base_url}/es/"
    )
    
    local failed=0
    for url in "${test_urls[@]}"; do
        log INFO "Testing: ${url}"
        if curl -sL -o /dev/null -w "%{http_code}" --max-time 10 "${url}" | grep -q "^200$"; then
            log SUCCESS "  → 200 OK"
        else
            log ERROR "  → FAILED (no 200 OK)"
            ((failed++))
        fi
    done
    
    if [ ${failed} -gt 0 ]; then
        log ERROR "Smoke tests: ${failed} tests fallidos"
        return 1
    fi
    
    log SUCCESS "Smoke tests: Todos pasados"
    return 0
}

# ------------------------------------------------------------------------------
# Función: Rollback (si falla deployment)
# ------------------------------------------------------------------------------

execute_rollback() {
    if [ "${ROLLBACK_ON_FAIL}" -ne 1 ]; then
        log WARN "ROLLBACK_ON_FAIL=0: Omitiendo rollback automático"
        return 0
    fi
    
    log WARN "Ejecutando rollback automático..."
    
    # Buscar backup más reciente
    local latest_backup
    latest_backup=$(find "${BACKUPS_DIR}" -name "${TARGET}_*.tar.gz" -type f -printf '%T@ %p\n' | sort -rn | head -1 | cut -d' ' -f2-)
    
    if [ -z "${latest_backup}" ]; then
        log ERROR "No se encontró backup para rollback"
        return 1
    fi
    
    log INFO "Backup a restaurar: ${latest_backup}"
    
    # Ejecutar script de rollback si existe
    local rollback_script="${SCRIPT_DIR}/../rollback_staging.sh"
    if [ -f "${rollback_script}" ]; then
        bash "${rollback_script}" --backup="${latest_backup}" --target="${TARGET}"
        return $?
    else
        log ERROR "Script de rollback no encontrado: ${rollback_script}"
        log INFO "Rollback manual requerido siguiendo docs/deploy/DEPLOY_ROLLBACK.md"
        return 1
    fi
}

# ------------------------------------------------------------------------------
# Función: Generar Reporte Final
# ------------------------------------------------------------------------------

finalize_report() {
    local status="$1"
    local duration="$2"
    
    {
        echo ""
        echo "---"
        echo ""
        echo "## Results Summary"
        echo ""
        echo "**Status:** ${status}"
        echo "**Duration:** ${duration} seconds"
        echo "**Timestamp:** ${TIMESTAMP}"
        
        if [ "${REAL_DEPLOY}" -eq 1 ]; then
            echo "**Backup:** ${BACKUPS_DIR}/${TARGET}_${TIMESTAMP}.tar.gz"
        fi
        
        echo ""
        echo "---"
        echo ""
        echo "## Next Steps"
        echo ""
        if [ "${status}" = "SUCCESS" ]; then
            echo "- [ ] Verificar sitio manualmente: https://$([ "${TARGET}" = "staging" ] && echo "staging." || echo "")runartfoundry.com"
            echo "- [ ] Monitorear logs de servidor por 10 minutos"
            echo "- [ ] Documentar deployment en issue correspondiente"
        else
            echo "- [ ] Revisar logs de errores en este reporte"
            echo "- [ ] Investigar causa raíz del fallo"
            if [ "${ROLLBACK_ON_FAIL}" -eq 1 ]; then
                echo "- [ ] Verificar que rollback completó exitosamente"
            else
                echo "- [ ] Ejecutar rollback manual si es necesario"
            fi
            echo "- [ ] Crear post-mortem issue siguiendo docs/deploy/DEPLOY_ROLLBACK.md"
        fi
        
        echo ""
        echo "---"
        echo ""
        echo "**Reporte generado por:** tools/deploy/deploy_theme.sh v1.0.0"
    } >> "${LOG_FILE}"
    
    log INFO "Reporte final guardado: ${LOG_FILE}"
}

# ------------------------------------------------------------------------------
# Función Principal
# ------------------------------------------------------------------------------

main() {
    local start_time
    start_time=$(date +%s)
    
    # Banner
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║       RunArt Foundry — Theme Deployment Script              ║"
    echo "║       Version 1.0.0 | Security-First Deployment             ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Inicializar reporte
    init_report
    
    # Imprimir configuración
    log INFO "Modo: $([ "${REAL_DEPLOY}" -eq 1 ] && echo "REAL DEPLOYMENT" || echo "SIMULATION")"
    log INFO "Target: ${TARGET}"
    log INFO "Theme: ${THEME_DIR}"
    log INFO "READ_ONLY=${READ_ONLY} | DRY_RUN=${DRY_RUN} | REAL_DEPLOY=${REAL_DEPLOY}"
    
    # Validaciones
    validate_config || exit 1
    validate_ssh || exit 1
    
    # Backup (solo si REAL_DEPLOY=1)
    if [ "${REAL_DEPLOY}" -eq 1 ]; then
        generate_backup || { log ERROR "Falló generación de backup"; exit 1; }
    fi
    
    # Deployment
    if ! execute_rsync; then
        log ERROR "Falló rsync"
        [ "${REAL_DEPLOY}" -eq 1 ] && execute_rollback
        finalize_report "FAILED" "$(($(date +%s) - start_time))"
        exit 1
    fi
    
    if ! execute_wpcli; then
        log ERROR "Falló ejecución de WP-CLI"
        [ "${REAL_DEPLOY}" -eq 1 ] && execute_rollback
        finalize_report "FAILED" "$(($(date +%s) - start_time))"
        exit 1
    fi
    
    # Smoke tests
    if ! run_smoke_tests; then
        log ERROR "Falló smoke tests"
        [ "${REAL_DEPLOY}" -eq 1 ] && execute_rollback
        finalize_report "FAILED (smoke tests)" "$(($(date +%s) - start_time))"
        exit 1
    fi
    
    # Éxito
    local duration=$(($(date +%s) - start_time))
    log SUCCESS "Deployment completado exitosamente en ${duration} segundos"
    finalize_report "SUCCESS" "${duration}"
    
    echo ""
    echo -e "${GREEN}✅ Deployment SUCCESS${NC}"
    echo -e "   Reporte: ${LOG_FILE}"
    echo -e "   Duración: ${duration}s"
    echo ""
}

# ------------------------------------------------------------------------------
# Entry Point
# ------------------------------------------------------------------------------

main "$@"
