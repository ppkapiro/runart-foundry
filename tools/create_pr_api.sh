#!/usr/bin/env bash
set -euo pipefail
# Script para crear PR usando la API de GitHub directamente

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PR_BODY_FILE="$REPO_ROOT/docs/integration_wp_staging_lite/PR_BODY_REMOTE.md"

echo "=== GitHub API PR Creation ==="
echo ""

# Verificar que el archivo del cuerpo existe
if [ ! -f "$PR_BODY_FILE" ]; then
    echo "❌ Error: No se encuentra $PR_BODY_FILE"
    exit 1
fi

# Leer el token de GitHub
GITHUB_TOKEN=$(gh auth token 2>/dev/null || echo "")
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: No se puede obtener token de GitHub"
    exit 1
fi

# Leer el cuerpo del PR
PR_BODY=$(cat "$PR_BODY_FILE")

# Crear payload JSON
PAYLOAD=$(cat << EOF
{
  "title": "WP Staging Lite — Integración local validada (Fases B–E)",
  "body": $(echo "$PR_BODY" | jq -R -s .),
  "head": "ppkapiro:feature/wp-staging-lite-integration",
  "base": "main",
  "draft": true,
  "maintainer_can_modify": true
}
EOF
)

echo "→ Creando PR usando GitHub API..."
echo "  Repo: RunArtFoundry/runart-foundry"
echo "  Head: ppkapiro:feature/wp-staging-lite-integration"
echo "  Base: main"
echo "  Draft: true"
echo ""

# Crear PR con API
RESPONSE=$(curl -s -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Content-Type: application/json" \
  "https://api.github.com/repos/RunArtFoundry/runart-foundry/pulls" \
  -d "$PAYLOAD")

# Verificar respuesta
if echo "$RESPONSE" | jq -e '.html_url' >/dev/null 2>&1; then
    PR_URL=$(echo "$RESPONSE" | jq -r '.html_url')
    PR_NUMBER=$(echo "$RESPONSE" | jq -r '.number')
    echo "✅ PR creado exitosamente:"
    echo "  URL: $PR_URL"
    echo "  Número: #$PR_NUMBER"
    echo ""
    
    # Guardar URL para usar en siguientes pasos
    echo "$PR_URL" > /tmp/pr_url.txt
    echo "$PR_NUMBER" > /tmp/pr_number.txt
    
    exit 0
else
    echo "❌ Error al crear PR:"
    echo "$RESPONSE" | jq -r '.message // .error // .' 2>/dev/null || echo "$RESPONSE"
    
    # Si falla, mostrar URL de compare manual
    echo ""
    echo "🔗 URL de compare manual para crear PR:"
    echo "https://github.com/RunArtFoundry/runart-foundry/compare/main...ppkapiro:feature/wp-staging-lite-integration?expand=1"
    echo ""
    echo "📋 Cuerpo del PR preparado:"
    echo "---"
    cat "$PR_BODY_FILE"
    echo "---"
    
    exit 1
fi