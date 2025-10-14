#!/bin/bash
# Lista secrets de GitHub (solo nombres, nunca valores)
# Uso: ./list_github_secrets.sh [repo] [environment]

set -euo pipefail

REPO="${1:-ppkapiro/runart-foundry}"
ENVIRONMENT="${2:-}"

echo "🔍 INVENTARIO DE SECRETS GITHUB"
echo "================================"
echo "Repositorio: $REPO"
echo "Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

# Verificar si GitHub CLI está disponible
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) no encontrado"
    echo "Instalar: https://cli.github.com/"
    exit 1
fi

# Verificar autenticación
if ! gh auth status &>/dev/null; then
    echo "❌ No autenticado en GitHub CLI"
    echo "Ejecutar: gh auth login"
    exit 1
fi

echo "✅ GitHub CLI disponible y autenticado"
echo ""

# Función para listar secrets de repo
list_repo_secrets() {
    echo "📦 SECRETS DE REPOSITORIO"
    echo "------------------------"
    
    if gh secret list -R "$REPO" --json name,updatedAt 2>/dev/null; then
        echo "✅ Secrets de repositorio listados exitosamente"
    else
        echo "❌ Error listando secrets de repositorio"
        echo "Posibles causas: permisos insuficientes o repo inexistente"
    fi
    echo ""
}

# Función para listar secrets de environment
list_environment_secrets() {
    local env="$1"
    echo "🌍 SECRETS DE ENVIRONMENT: $env"
    echo "-------------------------------"
    
    if gh secret list -R "$REPO" --env "$env" --json name,updatedAt 2>/dev/null; then
        echo "✅ Secrets del environment '$env' listados exitosamente"
    else
        echo "❌ Error listando secrets del environment '$env'"
        echo "Posibles causas: environment no existe o permisos insuficientes"
    fi
    echo ""
}

# Función para listar todos los environments
list_all_environments() {
    echo "🌐 DETECTANDO ENVIRONMENTS"
    echo "-------------------------"
    
    # Intentar listar environments (requiere permisos admin)
    if gh api "repos/$REPO/environments" --jq '.environments[].name' 2>/dev/null; then
        echo "✅ Environments detectados arriba"
    else
        echo "⚠️ No se pudieron listar environments automáticamente"
        echo "Environments comunes a verificar manualmente:"
        echo "  - preview"
        echo "  - production"
        echo "  - staging"
    fi
    echo ""
}

# Ejecutar según parámetros
if [ -n "$ENVIRONMENT" ]; then
    # Listar secrets de environment específico
    list_environment_secrets "$ENVIRONMENT"
else
    # Listar todo: repo + environments detectados
    list_repo_secrets
    list_all_environments
    
    # Intentar environments comunes
    for env in preview production staging; do
        if gh secret list -R "$REPO" --env "$env" --json name 2>/dev/null | jq -e '.[] | length > 0' >/dev/null 2>&1; then
            list_environment_secrets "$env"
        fi
    done
fi

echo "📊 RESUMEN"
echo "----------"
echo "Para obtener más detalles de un environment específico:"
echo "  $0 $REPO preview"
echo "  $0 $REPO production"
echo ""
echo "Para verificar scopes de tokens Cloudflare:"
echo "  ./check_cf_scopes.sh"