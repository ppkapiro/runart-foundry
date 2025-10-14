#!/bin/bash
# Verificador de scopes de tokens Cloudflare
# Wrapper que inyecta secrets desde environment y ejecuta verificación
# Uso: ./check_cf_scopes.sh [environment]

set -euo pipefail

ENVIRONMENT="${1:-repo}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFY_SCRIPT="$SCRIPT_DIR/../security/cf_token_verify.mjs"

echo "🔒 VERIFICACIÓN DE SCOPES CLOUDFLARE"
echo "==================================="
echo "Environment: $ENVIRONMENT"
echo "Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

# Verificar que el script de verificación existe
if [ ! -f "$VERIFY_SCRIPT" ]; then
    echo "❌ Script de verificación no encontrado: $VERIFY_SCRIPT"
    exit 1
fi

# Verificar Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js no encontrado"
    echo "Instalar Node.js v18+ para continuar"
    exit 1
fi

# Función para verificar token específico
verify_token() {
    local token_name="$1"
    local token_value="$2"
    
    echo "🔍 Verificando $token_name..."
    
    if [ -z "$token_value" ]; then
        echo "❌ Token $token_name no está configurado"
        return 1
    fi
    
    # Ejecutar verificación (sin imprimir el token)
    local result_file
    result_file=$(mktemp)
    
    if CF_API_TOKEN="$token_value" node "$VERIFY_SCRIPT" > "$result_file" 2>/dev/null; then
        echo "✅ $token_name: Verificación exitosa"
        
        # Mostrar resumen de scopes
        if command -v jq &> /dev/null; then
            local compliance
            compliance=$(jq -r '.scopes.compliance // "UNKNOWN"' "$result_file")
            local missing_count
            missing_count=$(jq -r '.scopes.summary.missing // 0' "$result_file")
            local extra_count
            extra_count=$(jq -r '.scopes.summary.extra // 0' "$result_file")
            
            echo "  • Compliance: $compliance"
            echo "  • Scopes faltantes: $missing_count"
            echo "  • Scopes extra: $extra_count"
            
            if [ "$missing_count" -gt 0 ]; then
                echo "  • Scopes requeridos faltantes:"
                jq -r '.scopes.missing[]?' "$result_file" | sed 's/^/    - /'
            fi
        fi
    else
        local exit_code=$?
        echo "❌ $token_name: Verificación falló (código $exit_code)"
        
        if [ -s "$result_file" ] && command -v jq &> /dev/null; then
            local error
            error=$(jq -r '.token.error // "Desconocido"' "$result_file" 2>/dev/null || echo "Error de parsing")
            echo "  • Error: $error"
        fi
        
        rm -f "$result_file"
        return $exit_code
    fi
    
    rm -f "$result_file"
    return 0
}

# Obtener tokens según environment
case "$ENVIRONMENT" in
    "repo"|"repository")
        echo "📦 Verificando tokens de repositorio..."
        
        # Verificar si estamos en GitHub Actions
        if [ -n "${GITHUB_ACTIONS:-}" ]; then
            # En GitHub Actions, usar secrets directamente
            verify_token "CLOUDFLARE_API_TOKEN" "${CLOUDFLARE_API_TOKEN:-}"
            cloudflare_result=$?
            
            verify_token "CF_API_TOKEN (legacy)" "${CF_API_TOKEN:-}"
            legacy_result=$?
            
        else
            # En ambiente local, intentar desde variables de entorno
            verify_token "CLOUDFLARE_API_TOKEN" "${CLOUDFLARE_API_TOKEN:-}"
            cloudflare_result=$?
            
            verify_token "CF_API_TOKEN (legacy)" "${CF_API_TOKEN:-}"
            legacy_result=$?
        fi
        ;;
    
    "preview")
        echo "🌍 Verificando tokens para environment Preview..."
        # En este proyecto, preview usa tokens de repo
        verify_token "CLOUDFLARE_API_TOKEN (preview)" "${CLOUDFLARE_API_TOKEN:-}"
        cloudflare_result=$?
        legacy_result=0  # No verificar legacy en preview
        ;;
    
    "production")
        echo "🌍 Verificando tokens para environment Production..."
        # En este proyecto, production usa tokens de repo  
        verify_token "CLOUDFLARE_API_TOKEN (production)" "${CLOUDFLARE_API_TOKEN:-}"
        cloudflare_result=$?
        legacy_result=0  # No verificar legacy en production
        ;;
    
    *)
        echo "❌ Environment no reconocido: $ENVIRONMENT"
        echo "Environments válidos: repo, preview, production"
        exit 1
        ;;
esac

echo ""
echo "📊 RESUMEN DE VERIFICACIÓN"
echo "========================="

if [ $cloudflare_result -eq 0 ]; then
    echo "✅ CLOUDFLARE_API_TOKEN: OK"
else
    echo "❌ CLOUDFLARE_API_TOKEN: FALLÓ"
fi

if [ "$ENVIRONMENT" = "repo" ] || [ "$ENVIRONMENT" = "repository" ]; then
    if [ $legacy_result -eq 0 ]; then
        echo "✅ CF_API_TOKEN (legacy): OK"
    else
        echo "❌ CF_API_TOKEN (legacy): FALLÓ"
    fi
fi

echo ""

# Código de salida general
if [ $cloudflare_result -ne 0 ]; then
    echo "🚨 ACCIÓN REQUERIDA: Token canónico falló verificación"
    exit $cloudflare_result
elif [ "$ENVIRONMENT" = "repo" ] && [ $legacy_result -ne 0 ]; then
    echo "⚠️  TOKEN LEGACY FALLÓ: Migración a canónico recomendada"
    exit 0  # No fallar por token legacy, solo advertir
else
    echo "✅ VERIFICACIÓN COMPLETADA: Todos los tokens funcionan correctamente"
    exit 0
fi