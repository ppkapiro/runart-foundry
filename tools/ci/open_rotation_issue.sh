#!/bin/bash
# Script para crear issue automático de rotación de tokens
# Uso: ./open_rotation_issue.sh [token_name] [days_until_expiry]

set -euo pipefail

TOKEN_NAME="${1:-CLOUDFLARE_API_TOKEN}"
DAYS_UNTIL="${2:-30}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOKENS_CONFIG="$SCRIPT_DIR/../../security/credentials/cloudflare_tokens.json"

echo "🔄 CREADOR DE ISSUES DE ROTACIÓN"
echo "================================"
echo "Token: $TOKEN_NAME"
echo "Días hasta expiración: $DAYS_UNTIL"
echo ""

# Verificar dependencias
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI no encontrado"
    echo "Instalar: https://cli.github.com/"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "❌ jq no encontrado"
    echo "Instalar: sudo apt-get install jq"
    exit 1
fi

# Verificar autenticación GitHub CLI
if ! gh auth status &>/dev/null; then
    echo "❌ No autenticado en GitHub CLI"  
    echo "Ejecutar: gh auth login"
    exit 1
fi

# Leer configuración de token
if [ ! -f "$TOKENS_CONFIG" ]; then
    echo "❌ Archivo de configuración no encontrado: $TOKENS_CONFIG"
    exit 1
fi

TOKEN_INFO=$(jq -r ".tokens[\"$TOKEN_NAME\"] // empty" "$TOKENS_CONFIG")
if [ -z "$TOKEN_INFO" ]; then
    echo "❌ Token $TOKEN_NAME no encontrado en configuración"
    exit 1
fi

# Extraer información del token
LAST_ROTATED=$(echo "$TOKEN_INFO" | jq -r '.last_rotated // "unknown"')
ROTATION_DAYS=$(echo "$TOKEN_INFO" | jq -r '.rotation_days // 180')
NEXT_ROTATION=$(echo "$TOKEN_INFO" | jq -r '.next_rotation // "unknown"')
STATUS=$(echo "$TOKEN_INFO" | jq -r '.status // "unknown"')

echo "📊 Información del token:"
echo "  • Última rotación: $LAST_ROTATED"
echo "  • Días entre rotaciones: $ROTATION_DAYS" 
echo "  • Próxima rotación: $NEXT_ROTATION"
echo "  • Estado: $STATUS"
echo ""

# Generar contenido del issue
ISSUE_TITLE="🔄 Rotación de Token: $TOKEN_NAME (${DAYS_UNTIL}d restantes)"
ISSUE_BODY="## 🔄 Rotación de Token Programada

**Token:** \`$TOKEN_NAME\`  
**Días restantes:** $DAYS_UNTIL  
**Próxima rotación:** $NEXT_ROTATION  
**Estado actual:** $STATUS

### 📋 Checklist de Rotación

#### Preparación
- [ ] Verificar que token actual sigue funcionando
- [ ] Revisar workflows que usan este token
- [ ] Confirmar scopes requeridos actualizados

#### Rotación
- [ ] Ir a [Cloudflare Dashboard > API Tokens](https://dash.cloudflare.com/profile/api-tokens)
- [ ] Crear nuevo token con scopes mínimos:
  - \`com.cloudflare.api.account.zone:read\`
  - \`com.cloudflare.edge.worker.script:read\`
  - \`com.cloudflare.edge.worker.kv:edit\`
  - \`com.cloudflare.api.account.zone.page:edit\`
- [ ] Actualizar GitHub secret \`$TOKEN_NAME\`
- [ ] Ejecutar workflow de verificación: \`gh workflow run ci_cloudflare_tokens_verify.yml\`

#### Validación Post-Rotación
- [ ] Confirmar que verificación de scopes pasa
- [ ] Ejecutar deploy de prueba en preview
- [ ] Ejecutar deploy de prueba en producción
- [ ] Actualizar \`last_rotated\` en \`security/credentials/cloudflare_tokens.json\`

#### Limpieza
- [ ] Revocar token anterior en Cloudflare Dashboard
- [ ] Documentar rotación en commit message
- [ ] Cerrar este issue

### ⚠️ Scopes Requeridos

| Scope | Justificación |
|-------|---------------|
| \`zone:read\` | Verificación de dominios Pages |
| \`worker.script:read\` | Validación de Workers |
| \`worker.kv:edit\` | Gestión de KV namespaces |
| \`zone.page:edit\` | Deploy y gestión de Pages |

### 🚨 En Caso de Problemas

1. **Token no funciona:** Verificar scopes y recursos en Dashboard
2. **Deploy falla:** Usar token legacy temporalmente mientras se corrige
3. **Scopes insuficientes:** Añadir permisos mínimos necesarios

### 📁 Archivos Relacionados

- \`security/credentials/cloudflare_tokens.json\` - Configuración y política
- \`tools/ci/check_cf_scopes.sh\` - Script de verificación
- \`.github/workflows/ci_cloudflare_tokens_verify.yml\` - Workflow de verificación

---
**Creado automáticamente:** $(date -u +%Y-%m-%dT%H:%M:%SZ)  
**Configuración:** $TOKENS_CONFIG"

# Verificar si ya existe un issue similar abierto
echo "🔍 Verificando issues existentes..."

EXISTING_ISSUES=$(gh issue list --label "rotation,tokens,cloudflare" --state open --json number,title --jq ".[] | select(.title | contains(\"$TOKEN_NAME\")) | .number")

if [ -n "$EXISTING_ISSUES" ]; then
    echo "⚠️  Issues de rotación existentes encontrados:"
    echo "$EXISTING_ISSUES" | while read -r issue_num; do
        echo "  • Issue #$issue_num"
    done
    echo ""
    echo "¿Crear nuevo issue de todas formas? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "❌ Cancelado por el usuario"
        exit 0
    fi
fi

# Crear el issue
echo "📝 Creando issue de rotación..."

ISSUE_URL=$(gh issue create \
    --title "$ISSUE_TITLE" \
    --body "$ISSUE_BODY" \
    --label "rotation,tokens,cloudflare,maintenance" \
    --assignee "@me")

if [ $? -eq 0 ]; then
    echo "✅ Issue creado exitosamente: $ISSUE_URL"
    echo ""
    echo "📋 Próximos pasos:"
    echo "1. Seguir checklist en el issue"
    echo "2. Ejecutar rotación antes de $NEXT_ROTATION"
    echo "3. Actualizar cloudflare_tokens.json tras rotación"
else
    echo "❌ Error creando issue"
    exit 1
fi