#!/usr/bin/env bash
# LIMPIEZA AUTOMÁTICA STAGING SIMPLE - EJECUCIÓN INMEDIATA
# Usa credenciales GitHub ya configuradas para limpieza directa

set -euo pipefail

STAGING_URL="https://staging.runartfoundry.com"
REPO="RunArtFoundry/runart-foundry"

echo "🚀 LIMPIEZA AUTOMÁTICA STAGING - RunArt Foundry"
echo "==============================================="
echo "URL: $STAGING_URL"
echo "Repo: $REPO"
echo ""

# Verificar credenciales disponibles
echo "🔍 Verificando credenciales GitHub..."
if gh secret list --repo "$REPO" | grep -q "WP_USER" && gh secret list --repo "$REPO" | grep -q "WP_APP_PASSWORD"; then
    echo "✅ Credenciales encontradas en GitHub"
else
    echo "❌ Credenciales no encontradas"
    echo "Ejecutar: ./tools/load_staging_credentials.sh"
    exit 1
fi

# Verificar staging accesible
echo "🔍 Verificando acceso a staging..."
if curl -s -I "$STAGING_URL" | grep -q "200"; then
    echo "✅ Staging accesible"
else
    echo "❌ Staging no accesible"
    exit 1
fi

# Inventario rápido
echo ""
echo "📊 INVENTARIO ACTUAL:"
POSTS=$(curl -s "$STAGING_URL/wp-json/wp/v2/posts" | jq 'length' 2>/dev/null || echo "error")
PAGES=$(curl -s "$STAGING_URL/wp-json/wp/v2/pages" | jq 'length' 2>/dev/null || echo "error")
MEDIA=$(curl -s "$STAGING_URL/wp-json/wp/v2/media" | jq 'length' 2>/dev/null || echo "error")

echo "- Posts: $POSTS"
echo "- Páginas: $PAGES"  
echo "- Medios: $MEDIA"

if [[ "$POSTS" == "0" && "$PAGES" == "0" && "$MEDIA" == "0" ]]; then
    echo ""
    echo "🎉 STAGING YA ESTÁ LIMPIO"
    echo "No hay contenido para eliminar."
    
    # Verificar Polylang
    LANGS=$(curl -s "$STAGING_URL/wp-json/pll/v1/languages" | jq 'length' 2>/dev/null || echo "0")
    echo "Idiomas Polylang: $LANGS"
    
    if [[ "$LANGS" == "2" ]]; then
        echo "✅ Configuración Polylang ES/EN preservada"
        echo ""
        echo "🚀 STAGING LISTO PARA FASE 2 i18n"
    fi
    exit 0
fi

echo ""
echo "⚠️  CONTENIDO RESIDUAL DETECTADO - INICIANDO LIMPIEZA"
echo ""

# Crear workflow temporal en memoria y ejecutar
WORKFLOW_NAME="staging-cleanup-$(date +%s)"

# Trigger workflow usando GitHub CLI con dispatch
echo "🎯 Ejecutando limpieza via GitHub Actions..."

# Crear archivo temporal de workflow
cat > ".github/workflows/$WORKFLOW_NAME.yml" << 'EOF'
name: Staging Cleanup Auto

on:
  workflow_dispatch: {}

jobs:
  auto-cleanup:
    runs-on: ubuntu-latest
    env:
      WP_URL: https://staging.runartfoundry.com
      WP_USER: ${{ secrets.WP_USER }}
      WP_APP_PASSWORD: ${{ secrets.WP_APP_PASSWORD }}
    
    steps:
      - name: Limpiar staging automáticamente
        run: |
          echo "🗑️ LIMPIEZA AUTOMÁTICA STAGING"
          echo "URL: $WP_URL"
          
          # Función para eliminar vía REST API
          delete_content() {
            local endpoint="$1"
            local name="$2"
            
            echo "Eliminando $name..."
            IDS=$(curl -s "$WP_URL/wp-json/wp/v2/$endpoint?per_page=100" | jq -r '.[].id' 2>/dev/null || echo "")
            
            if [[ -n "$IDS" ]]; then
              for id in $IDS; do
                RESP=$(curl -s -w "%{http_code}" -u "$WP_USER:$WP_APP_PASSWORD" \
                      -X DELETE "$WP_URL/wp-json/wp/v2/$endpoint/$id?force=true" \
                      -o /dev/null 2>/dev/null || echo "000")
                
                if [[ "$RESP" == "200" ]]; then
                  echo "✓ $name eliminado: ID $id"
                else
                  echo "⚠ Error $name ID $id: HTTP $RESP"
                fi
                sleep 0.3
              done
            else
              echo "No hay $name para eliminar"
            fi
          }
          
          # Eliminar contenido
          delete_content "posts" "posts"
          delete_content "pages" "páginas"  
          delete_content "media" "medios"
          
          # Verificación final
          echo ""
          echo "📊 VERIFICACIÓN POST-LIMPIEZA:"
          POSTS_F=$(curl -s "$WP_URL/wp-json/wp/v2/posts" | jq 'length' 2>/dev/null || echo "error")
          PAGES_F=$(curl -s "$WP_URL/wp-json/wp/v2/pages" | jq 'length' 2>/dev/null || echo "error")
          MEDIA_F=$(curl -s "$WP_URL/wp-json/wp/v2/media" | jq 'length' 2>/dev/null || echo "error")
          POLYLANG=$(curl -s "$WP_URL/wp-json/pll/v1/languages" | jq 'length' 2>/dev/null || echo "0")
          
          echo "Posts restantes: $POSTS_F"
          echo "Páginas restantes: $PAGES_F"
          echo "Medios restantes: $MEDIA_F"
          echo "Idiomas Polylang: $POLYLANG"
          
          if [[ "$POSTS_F" == "0" && "$PAGES_F" == "0" && "$MEDIA_F" == "0" && "$POLYLANG" == "2" ]]; then
            echo ""
            echo "🎉 LIMPIEZA EXITOSA"
            echo "✅ Staging limpio y listo para Fase 2 i18n"
            echo "✅ Polylang ES/EN preservado"
          else
            echo ""
            echo "⚠️ Revisar resultados manualmente"
          fi
EOF

# Commit temporal y ejecutar
git add ".github/workflows/$WORKFLOW_NAME.yml"
git commit -m "temp: auto cleanup workflow"
git push origin HEAD

echo "⏳ Disparando workflow..."
gh workflow run "$WORKFLOW_NAME.yml" --repo "$REPO"

echo "⏳ Esperando inicio del workflow (30s)..."
sleep 30

# Obtener run ID y mostrar
RUN_ID=$(gh run list --repo "$REPO" --workflow="$WORKFLOW_NAME.yml" --limit=1 --json databaseId --jq '.[0].databaseId' 2>/dev/null)

if [[ -n "$RUN_ID" ]]; then
    echo "🎯 Run ID: $RUN_ID"
    echo "📺 Siguiendo ejecución en tiempo real..."
    echo ""
    
    # Watch workflow
    gh run watch "$RUN_ID" --repo "$REPO"
    
    echo ""
    echo "✅ Workflow completado"
else
    echo "⚠️ No se pudo obtener Run ID"
    echo "Verificar manualmente: https://github.com/$REPO/actions"
fi

# Limpiar workflow temporal
echo "🧹 Limpiando workflow temporal..."
rm -f ".github/workflows/$WORKFLOW_NAME.yml"
git add ".github/workflows/$WORKFLOW_NAME.yml"
git commit -m "cleanup: remove temp workflow"
git push origin HEAD

echo ""
echo "🏁 PROCESO COMPLETADO"
echo ""
echo "🔍 VERIFICACIÓN FINAL:"
echo "curl -s '$STAGING_URL/wp-json/wp/v2/posts' | jq 'length'"
echo "curl -s '$STAGING_URL/wp-json/wp/v2/pages' | jq 'length'"
echo "curl -s '$STAGING_URL/wp-json/wp/v2/media' | jq 'length'"
echo "curl -s '$STAGING_URL/wp-json/pll/v1/languages' | jq -r '.[].name'"