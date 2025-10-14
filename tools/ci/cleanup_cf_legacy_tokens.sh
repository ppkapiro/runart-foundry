#!/bin/bash
# Script: cleanup_cf_legacy_tokens.sh
# Propósito: Eliminar tokens CF_API_TOKEN legacy después del período de validación
# Uso: ./cleanup_cf_legacy_tokens.sh [--dry-run]
# Requisitos: GitHub CLI (gh) autenticado con permisos de admin

set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuración
REPO="RunArtFoundry/runart-foundry"
SECRET_NAME="CF_API_TOKEN"
ENVIRONMENTS=("preview" "production")
DRY_RUN=false

# Procesar argumentos
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
    echo -e "${YELLOW}🔍 Modo DRY-RUN activado - No se ejecutarán cambios${NC}"
fi

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Cloudflare Legacy Token Cleanup - CF_API_TOKEN           ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Verificar que gh CLI está instalado y autenticado
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ ERROR: GitHub CLI (gh) no está instalado${NC}"
    echo "Instalar desde: https://cli.github.com/"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    echo -e "${RED}❌ ERROR: GitHub CLI no está autenticado${NC}"
    echo "Ejecutar: gh auth login"
    exit 1
fi

echo -e "${BLUE}ℹ️  Repository: ${REPO}${NC}"
echo -e "${BLUE}ℹ️  Secret a eliminar: ${SECRET_NAME}${NC}"
echo ""

# Función para verificar existencia de secret
check_secret_exists() {
    local env=$1
    local exists=false
    
    if [[ "$env" == "repo" ]]; then
        if gh secret list --repo "$REPO" | grep -q "^${SECRET_NAME}"; then
            exists=true
        fi
    else
        if gh secret list --env "$env" --repo "$REPO" 2>/dev/null | grep -q "^${SECRET_NAME}"; then
            exists=true
        fi
    fi
    
    echo "$exists"
}

# Función para eliminar secret
remove_secret() {
    local env=$1
    local env_display=$2
    
    echo -e "${YELLOW}🔍 Verificando ${env_display}...${NC}"
    
    if [[ $(check_secret_exists "$env") == "true" ]]; then
        echo -e "   ✅ Secret encontrado en ${env_display}"
        
        if [[ "$DRY_RUN" == true ]]; then
            echo -e "   ${BLUE}[DRY-RUN] Se eliminaría: gh secret remove ${SECRET_NAME}${NC}"
        else
            echo -e "   🗑️  Eliminando secret..."
            if [[ "$env" == "repo" ]]; then
                gh secret remove "$SECRET_NAME" --repo "$REPO"
            else
                gh secret remove "$SECRET_NAME" --env "$env" --repo "$REPO"
            fi
            echo -e "   ${GREEN}✅ Secret eliminado exitosamente${NC}"
        fi
    else
        echo -e "   ℹ️  Secret no encontrado en ${env_display} (ya eliminado o nunca existió)"
    fi
    echo ""
}

# Paso 1: Verificación de seguridad
echo "═══════════════════════════════════════════════════════════"
echo "Paso 1: Verificación de Seguridad"
echo "═══════════════════════════════════════════════════════════"
echo ""

echo -e "${YELLOW}⚠️  ADVERTENCIA: Esta operación eliminará permanentemente CF_API_TOKEN${NC}"
echo -e "${YELLOW}⚠️  Asegúrate de que todos los workflows usan CLOUDFLARE_API_TOKEN${NC}"
echo ""

# Verificar que CLOUDFLARE_API_TOKEN existe en todos los environments
echo "🔍 Verificando que CLOUDFLARE_API_TOKEN existe en todos los environments..."
CANONICAL_EXISTS_REPO=$(gh secret list --repo "$REPO" | grep -q "^CLOUDFLARE_API_TOKEN" && echo "true" || echo "false")
CANONICAL_EXISTS_PREVIEW=$(gh secret list --env preview --repo "$REPO" 2>/dev/null | grep -q "^CLOUDFLARE_API_TOKEN" && echo "true" || echo "false")
CANONICAL_EXISTS_PROD=$(gh secret list --env production --repo "$REPO" 2>/dev/null | grep -q "^CLOUDFLARE_API_TOKEN" && echo "true" || echo "false")

if [[ "$CANONICAL_EXISTS_REPO" == "true" ]] || [[ "$CANONICAL_EXISTS_PREVIEW" == "true" ]] || [[ "$CANONICAL_EXISTS_PROD" == "true" ]]; then
    echo -e "${GREEN}✅ CLOUDFLARE_API_TOKEN encontrado - Seguro proceder${NC}"
else
    echo -e "${RED}❌ ERROR: CLOUDFLARE_API_TOKEN no encontrado en ningún environment${NC}"
    echo -e "${RED}   No es seguro eliminar CF_API_TOKEN - Abortando${NC}"
    exit 1
fi
echo ""

# Paso 2: Listado de secrets a eliminar
echo "═══════════════════════════════════════════════════════════"
echo "Paso 2: Inventario de Secrets a Eliminar"
echo "═══════════════════════════════════════════════════════════"
echo ""

SECRETS_TO_REMOVE=()

if [[ $(check_secret_exists "repo") == "true" ]]; then
    SECRETS_TO_REMOVE+=("Repository level")
fi

for env in "${ENVIRONMENTS[@]}"; do
    if [[ $(check_secret_exists "$env") == "true" ]]; then
        SECRETS_TO_REMOVE+=("Environment: $env")
    fi
done

if [[ ${#SECRETS_TO_REMOVE[@]} -eq 0 ]]; then
    echo -e "${GREEN}✅ No se encontraron secrets CF_API_TOKEN para eliminar${NC}"
    echo "   La limpieza ya fue completada anteriormente"
    exit 0
fi

echo "Secrets encontrados para eliminación:"
for item in "${SECRETS_TO_REMOVE[@]}"; do
    echo "  - $item"
done
echo ""

# Paso 3: Confirmación (solo en modo no dry-run)
if [[ "$DRY_RUN" == false ]]; then
    echo "═══════════════════════════════════════════════════════════"
    echo "Paso 3: Confirmación"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo -e "${RED}⚠️  Esta acción es IRREVERSIBLE${NC}"
    echo -e "${YELLOW}¿Estás seguro de que deseas eliminar CF_API_TOKEN?${NC}"
    read -p "Escribe 'DELETE' para confirmar: " confirmation
    
    if [[ "$confirmation" != "DELETE" ]]; then
        echo -e "${YELLOW}❌ Operación cancelada por el usuario${NC}"
        exit 0
    fi
    echo ""
fi

# Paso 4: Eliminación
echo "═══════════════════════════════════════════════════════════"
echo "Paso 4: Eliminación de Secrets Legacy"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Eliminar a nivel de repositorio
remove_secret "repo" "Repository level"

# Eliminar en cada environment
for env in "${ENVIRONMENTS[@]}"; do
    remove_secret "$env" "Environment: $env"
done

# Paso 5: Verificación final
echo "═══════════════════════════════════════════════════════════"
echo "Paso 5: Verificación Final"
echo "═══════════════════════════════════════════════════════════"
echo ""

if [[ "$DRY_RUN" == false ]]; then
    echo "🔍 Verificando que todos los secrets fueron eliminados..."
    VERIFICATION_FAILED=false
    
    if [[ $(check_secret_exists "repo") == "true" ]]; then
        echo -e "${RED}❌ ERROR: Secret aún existe a nivel de repositorio${NC}"
        VERIFICATION_FAILED=true
    fi
    
    for env in "${ENVIRONMENTS[@]}"; do
        if [[ $(check_secret_exists "$env") == "true" ]]; then
            echo -e "${RED}❌ ERROR: Secret aún existe en environment: $env${NC}"
            VERIFICATION_FAILED=true
        fi
    done
    
    if [[ "$VERIFICATION_FAILED" == true ]]; then
        echo -e "${RED}❌ Verificación fallida - Algunos secrets no fueron eliminados${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Verificación exitosa - Todos los secrets CF_API_TOKEN eliminados${NC}"
else
    echo -e "${BLUE}[DRY-RUN] Verificación omitida en modo dry-run${NC}"
fi
echo ""

# Paso 6: Actualización de documentación
echo "═══════════════════════════════════════════════════════════"
echo "Paso 6: Próximos Pasos"
echo "═══════════════════════════════════════════════════════════"
echo ""

if [[ "$DRY_RUN" == false ]]; then
    echo "📋 Tareas post-eliminación:"
    echo "  1. Actualizar github_secrets_inventory.md"
    echo "  2. Marcar como 'Eliminado' en legacy_cleanup_plan.md"
    echo "  3. Registrar eliminación en monitoring_log.md"
    echo "  4. Actualizar runbook_cf_tokens.md"
    echo "  5. Cerrar milestone 'Audit-First Cloudflare Tokens v1.0'"
    echo ""
    echo -e "${GREEN}✅ Limpieza de tokens legacy completada exitosamente${NC}"
else
    echo -e "${BLUE}ℹ️  Para ejecutar la eliminación real, ejecuta:${NC}"
    echo -e "${BLUE}   ./cleanup_cf_legacy_tokens.sh${NC}"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "                    Operación Finalizada"
echo "═══════════════════════════════════════════════════════════"
