#!/usr/bin/env bash
#
# staging_env_loader.sh
# Carga y valida variables de entorno para Staging (IONOS).
# Lee desde ~/.runart_staging_env (NO versionado por seguridad).
#
# Variables requeridas:
# - IONOS_SSH_HOST: hostname o IP del servidor staging
# - IONOS_SSH_USER: usuario SSH
# - IONOS_SSH_KEY: ruta a clave privada SSH (o IONOS_SSH_PASS si usa password)
# - SSH_PORT: puerto SSH (default: 22)
# - STAGING_WP_PATH: ruta absoluta a la instalación WordPress en staging
#
# Uso:
#   source tools/staging_env_loader.sh
#   # Variables disponibles tras validación exitosa
#
# Exit codes:
#   0 - OK, variables cargadas y validadas
#   1 - Archivo de entorno no encontrado
#   2 - Variables requeridas faltantes
#   3 - Validación de acceso SSH fallida

set -euo pipefail

readonly ENV_FILE="${HOME}/.runart_staging_env"
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

# Colores para output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

log_error() {
    echo -e "${RED}✗ ERROR:${NC} $*" >&2
}

log_success() {
    echo -e "${GREEN}✓${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $*"
}

log_info() {
    echo "ℹ $*"
}

show_setup_guide() {
    cat >&2 <<'EOF'

╔══════════════════════════════════════════════════════════════════════════════╗
║                    Staging Environment Setup Guide                           ║
╚══════════════════════════════════════════════════════════════════════════════╝

El archivo de configuración de staging NO existe o está incompleto.

1. Crea el archivo: ~/.runart_staging_env

2. Añade las siguientes variables (ajusta los valores reales):

   # IONOS Staging Server
   export IONOS_SSH_HOST="your-staging-hostname.ionos.com"
   export IONOS_SSH_USER="your-ssh-user"
   export IONOS_SSH_KEY="${HOME}/.ssh/ionos_staging_rsa"
   # O si usas password: export IONOS_SSH_PASS="your-password"
   export SSH_PORT="22"
   
    # WordPress Installation
    export STAGING_WP_PATH="/homepages/7/d958591985/htdocs/staging"
    # Canon del tema (solo lectura): RunArt Base
    export THEME_SLUG="runart-base"
   
   # Optional: Database credentials (if needed for WP-CLI)
   # export STAGING_DB_HOST="localhost"
   # export STAGING_DB_NAME="staging_db"
   # export STAGING_DB_USER="staging_user"
   # export STAGING_DB_PASS="staging_pass"

3. Asegura los permisos:
   
   chmod 600 ~/.runart_staging_env

4. Si usas clave SSH, verifica permisos:
   
   chmod 600 ~/.ssh/ionos_staging_rsa

5. Vuelve a ejecutar este script:
   
   source tools/staging_env_loader.sh

Nota de seguridad:
  - NO versiones ~/.runart_staging_env en Git
  - Mantén los permisos restringidos (600)
  - Usa claves SSH en lugar de passwords cuando sea posible

EOF
}

validate_ssh_key() {
    local key_path="$1"
    
    if [[ ! -f "${key_path}" ]]; then
        log_error "Clave SSH no encontrada: ${key_path}"
        return 1
    fi
    
    local perms
    perms=$(stat -c "%a" "${key_path}" 2>/dev/null || stat -f "%OLp" "${key_path}" 2>/dev/null)
    
    if [[ "${perms}" != "600" ]] && [[ "${perms}" != "400" ]]; then
        log_warn "Permisos de clave SSH deberían ser 600 o 400 (actual: ${perms})"
        log_info "Ejecuta: chmod 600 ${key_path}"
    fi
    
    return 0
}

test_ssh_connection() {
    log_info "Probando conexión SSH a ${IONOS_SSH_USER}@${IONOS_SSH_HOST}:${SSH_PORT}..."
    
    local ssh_opts=(-o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new -p "${SSH_PORT}")
    
    if [[ -n "${IONOS_SSH_KEY:-}" ]]; then
        ssh_opts+=(-i "${IONOS_SSH_KEY}")
    fi
    
    if ssh "${ssh_opts[@]}" "${IONOS_SSH_USER}@${IONOS_SSH_HOST}" "echo 'SSH OK'" &>/dev/null; then
        log_success "Conexión SSH establecida correctamente"
        return 0
    else
        log_error "No se pudo establecer conexión SSH"
        log_info "Verifica: host, usuario, clave SSH, puerto y permisos"
        return 1
    fi
}

main() {
    log_info "Cargando configuración de Staging desde: ${ENV_FILE}"
    
    # Check if env file exists
    if [[ ! -f "${ENV_FILE}" ]]; then
        log_error "Archivo de configuración no encontrado: ${ENV_FILE}"
        show_setup_guide
        return 1
    fi
    
    # Check permissions
    local env_perms
    env_perms=$(stat -c "%a" "${ENV_FILE}" 2>/dev/null || stat -f "%OLp" "${ENV_FILE}" 2>/dev/null)
    if [[ "${env_perms}" != "600" ]]; then
        log_warn "Permisos de ${ENV_FILE} deberían ser 600 (actual: ${env_perms})"
        log_info "Ejecuta: chmod 600 ${ENV_FILE}"
    fi
    
    # Load environment file
    # shellcheck source=/dev/null
    source "${ENV_FILE}"
    
    # Validate required variables
    local missing_vars=()
    
    [[ -z "${IONOS_SSH_HOST:-}" ]] && missing_vars+=("IONOS_SSH_HOST")
    [[ -z "${IONOS_SSH_USER:-}" ]] && missing_vars+=("IONOS_SSH_USER")
    [[ -z "${STAGING_WP_PATH:-}" ]] && missing_vars+=("STAGING_WP_PATH")
    
    # SSH authentication: key or password required
    if [[ -z "${IONOS_SSH_KEY:-}" ]] && [[ -z "${IONOS_SSH_PASS:-}" ]]; then
        missing_vars+=("IONOS_SSH_KEY or IONOS_SSH_PASS")
    fi
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        log_error "Variables requeridas faltantes:"
        for var in "${missing_vars[@]}"; do
            echo "  - ${var}" >&2
        done
        show_setup_guide
        return 2
    fi
    
    # Enforce canonical theme and read-only defaults
    # Nota: THEME_SLUG forzado a runart-base (canon). Si estaba definido distinto, se ignora.
    if [[ -n "${THEME_SLUG:-}" && "${THEME_SLUG}" != "runart-base" ]]; then
        log_warn "THEME_SLUG=${THEME_SLUG} detectado; se forzará a 'runart-base' (canon)."
    fi
    export THEME_SLUG="runart-base"
    export READ_ONLY="${READ_ONLY:-1}"
    export SSH_PORT="${SSH_PORT:-22}"
    export THEME_PATH="${STAGING_WP_PATH%/}/wp-content/themes/${THEME_SLUG}"
    
    # Validate SSH key if provided
    if [[ -n "${IONOS_SSH_KEY:-}" ]]; then
        validate_ssh_key "${IONOS_SSH_KEY}" || return 2
    fi
    
    # Test SSH connection (solo si no se deshabilita explícitamente)
    if [[ "${SKIP_SSH:-0}" != "1" ]]; then
        if ! test_ssh_connection; then
            return 3
        fi
    else
        log_warn "Validación SSH omitida por SKIP_SSH=1 (modo documentación/CI)."
    fi
    
    # Success summary
    log_success "Configuración de Staging validada correctamente"
    echo ""
    echo "Variables cargadas:"
    echo "  IONOS_SSH_HOST:   ${IONOS_SSH_HOST}"
    echo "  IONOS_SSH_USER:   ${IONOS_SSH_USER}"
    echo "  SSH_PORT:         ${SSH_PORT}"
    echo "  STAGING_WP_PATH:  ${STAGING_WP_PATH}"
    echo "  THEME_SLUG:       ${THEME_SLUG} (canon)"
    echo "  THEME_PATH:       ${THEME_PATH}"
    echo "  READ_ONLY:        ${READ_ONLY}"
    echo "  Auth method:      $(if [[ -n "${IONOS_SSH_KEY:-}" ]]; then echo "SSH Key"; else echo "Password"; fi)"
    echo ""
    
    return 0
}

# Execute only if sourced (not executed directly)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: Este script debe ser 'source'd, no ejecutado directamente."
    echo "Uso: source ${SCRIPT_NAME}"
    exit 1
else
    main "$@"
fi
