#!/usr/bin/env bash
#
# load_staging_credentials.sh
# Carga credenciales de STAGING en GitHub vía gh CLI
# para que los workflows verify-* en MAIN puedan ejecutarse.
#
# Requisitos:
# - gh CLI autenticado: `gh auth status`
# - Permisos para gestionar variables/secrets del repo
# - Usuario de WP y App Password de STAGING a mano
# - URL de staging: https://staging.runartfoundry.com
#
# Uso:
#   ./tools/load_staging_credentials.sh [REPO_FULL]
#
# Ejemplo:
#   ./tools/load_staging_credentials.sh RunArtFoundry/runart-foundry

set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}ℹ${NC} $*"; }
log_success() { echo -e "${GREEN}✅${NC} $*"; }
log_warning() { echo -e "${YELLOW}⚠️${NC} $*"; }
log_error() { echo -e "${RED}❌${NC} $*"; }

# ==============================================================================
# 1) Detectar repositorio
# ==============================================================================

REPO_FULL="${1:-}"

if [[ -z "$REPO_FULL" ]]; then
  # Intentar detectar del git remoto
  if git rev-parse --git-dir > /dev/null 2>&1; then
    REPO_FULL=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")
  fi
fi

if [[ -z "$REPO_FULL" ]]; then
  log_error "No se pudo detectar el repositorio. Usa: $0 <owner/repo>"
  log_info "Ejemplo: $0 RunArtFoundry/runart-foundry"
  exit 1
fi

log_info "Repositorio objetivo: $REPO_FULL"

# ==============================================================================
# 2) Verificar gh CLI autenticado
# ==============================================================================

log_info "Verificando autenticación gh CLI..."
if ! gh auth status > /dev/null 2>&1; then
  log_error "No estás autenticado en gh CLI"
  log_info "Ejecuta: gh auth login"
  exit 1
fi
log_success "gh CLI autenticado"

# ==============================================================================
# 3) Verificar acceso al repositorio
# ==============================================================================

log_info "Verificando acceso al repositorio..."
if ! gh repo view "$REPO_FULL" > /dev/null 2>&1; then
  log_error "No se puede acceder al repositorio: $REPO_FULL"
  log_info "Verifica que el nombre sea correcto y tengas permisos"
  exit 1
fi
log_success "Acceso al repositorio confirmado"

# ==============================================================================
# 4) Configurar WP_BASE_URL (variable pública)
# ==============================================================================

WP_BASE_URL_VALUE="https://staging.runartfoundry.com"
log_info "Configurando variable WP_BASE_URL=${WP_BASE_URL_VALUE}"

if gh variable set WP_BASE_URL --body "$WP_BASE_URL_VALUE" --repo "$REPO_FULL" 2>&1; then
  log_success "Variable WP_BASE_URL configurada"
else
  log_error "No se pudo configurar WP_BASE_URL"
  exit 1
fi

# ==============================================================================
# 5) Configurar WP_USER (secret)
# ==============================================================================

echo ""
log_info "Introduce WP_USER (usuario técnico de WordPress para STAGING):"
read -r WP_USER_INPUT

if [[ -z "$WP_USER_INPUT" ]]; then
  log_error "WP_USER no puede estar vacío"
  exit 1
fi

log_info "Configurando secret WP_USER (valor oculto)..."
if printf "%s" "$WP_USER_INPUT" | gh secret set WP_USER --repo "$REPO_FULL" 2>&1; then
  log_success "Secret WP_USER configurado"
else
  log_error "No se pudo configurar WP_USER"
  exit 1
fi

# ==============================================================================
# 6) Configurar WP_APP_PASSWORD (secret)
# ==============================================================================

echo ""
log_info "Introduce WP_APP_PASSWORD (App Password de STAGING - entrada oculta):"
stty -echo 2>/dev/null || true
read -r WP_APP_PASSWORD_INPUT
stty echo 2>/dev/null || true
echo ""

if [[ -z "$WP_APP_PASSWORD_INPUT" ]]; then
  log_error "WP_APP_PASSWORD no puede estar vacío"
  exit 1
fi

log_info "Configurando secret WP_APP_PASSWORD (valor oculto)..."
if printf "%s" "$WP_APP_PASSWORD_INPUT" | gh secret set WP_APP_PASSWORD --repo "$REPO_FULL" 2>&1; then
  log_success "Secret WP_APP_PASSWORD configurado"
else
  log_error "No se pudo configurar WP_APP_PASSWORD"
  exit 1
fi

# ==============================================================================
# 7) Configurar WP_ENV (variable opcional para claridad)
# ==============================================================================

log_info "Configurando variable WP_ENV=staging (opcional)..."
gh variable set WP_ENV --body "staging" --repo "$REPO_FULL" 2>/dev/null || true

# ==============================================================================
# 8) Verificar configuración (sin revelar valores)
# ==============================================================================

echo ""
log_info "Verificando variables y secrets en el repositorio..."

echo -e "\n${BLUE}Variables:${NC}"
if gh variable list --repo "$REPO_FULL" 2>/dev/null | grep -E "WP_BASE_URL|WP_ENV"; then
  log_success "Variables verificadas"
else
  log_warning "No se encontraron algunas variables"
fi

echo -e "\n${BLUE}Secrets:${NC}"
if gh secret list --repo "$REPO_FULL" 2>/dev/null | grep -E "WP_USER|WP_APP_PASSWORD"; then
  log_success "Secrets verificados"
else
  log_warning "No se encontraron algunos secrets"
fi

# ==============================================================================
# 9) Registro en logs (sin secretos)
# ==============================================================================

LOGS_DIR="logs"
mkdir -p "$LOGS_DIR"
LOG_FILE="$LOGS_DIR/gh_credentials_setup_staging_$(date -u +%Y%m%d_%H%M%S).log"

{
  echo "=== CARGA CREDENCIALES STAGING (GitHub CLI) ==="
  echo "Timestamp: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
  echo "Repo: $REPO_FULL"
  echo "WP_BASE_URL: $WP_BASE_URL_VALUE"
  echo "WP_USER: **** (oculto)"
  echo "WP_APP_PASSWORD: **** (oculto)"
  echo "WP_ENV: staging"
  echo "Status: SUCCESS"
} > "$LOG_FILE"

log_success "Log guardado en: $LOG_FILE"

# ==============================================================================
# 10) Mensaje final con instrucciones
# ==============================================================================

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                  ✅ CREDENCIALES CARGADAS                     ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
log_success "Configuración completada en $REPO_FULL"
echo ""
log_info "Variables configuradas:"
echo "  • WP_BASE_URL = $WP_BASE_URL_VALUE"
echo "  • WP_ENV = staging"
echo ""
log_info "Secrets configurados:"
echo "  • WP_USER = **** (oculto)"
echo "  • WP_APP_PASSWORD = **** (oculto)"
echo ""
log_info "Próximos pasos:"
echo "  1. Los workflows verify-* en MAIN ahora tienen acceso a estas credenciales"
echo "  2. Puedes ejecutarlos manualmente desde GitHub Actions"
echo "  3. También se ejecutarán automáticamente en cada push/PR"
echo ""
log_info "Si algún workflow falla, verifica:"
echo "  • Usuario WP tiene permisos de lectura adecuados"
echo "  • App Password es válida y no ha sido revocada"
echo "  • WP_BASE_URL apunta exactamente a https://staging.runartfoundry.com"
echo ""
log_info "Para ejecutar un workflow manualmente:"
echo "  gh workflow run verify-home.yml"
echo "  gh workflow run verify-settings.yml"
echo "  gh workflow run verify-menus.yml"
echo "  gh workflow run verify-media.yml"
echo ""
