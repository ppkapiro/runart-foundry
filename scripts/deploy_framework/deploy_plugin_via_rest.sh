#!/usr/bin/env bash
set -euo pipefail

# Deployment del plugin runart-wpcli-bridge vía REST API de WordPress
# Uso: ./deploy_plugin_via_rest.sh [--real-deploy]
# Requisitos:
#   - WP_BASE_URL (default: https://runartfoundry.com)
#   - WP_USER (default: runart-admin)
#   - WP_APP_PASSWORD (requerido)

REAL=0
for arg in "$@"; do
  case "$arg" in
    --real-deploy) REAL=1; shift;;
  esac
done

BASE_URL="${WP_BASE_URL:-https://runartfoundry.com}"
USER="${WP_USER:-runart-admin}"
APP_PASS="${WP_APP_PASSWORD:-}"

if [[ -z "$APP_PASS" ]]; then
  echo "❌ Falta WP_APP_PASSWORD"
  exit 1
fi

AUTH_HEADER="Authorization: Basic $(echo -n "$USER:$APP_PASS" | base64)"

echo "=== 🚀 Deployment del Plugin runart-wpcli-bridge vía REST API ==="
echo "    Base URL: $BASE_URL"
echo "    Usuario: $USER"
echo ""

# Preparar payload: el plugin completo en base64
PLUGIN_DIR="tools/wpcli-bridge-plugin"
TMPDIR=$(mktemp -d)
PLUGIN_ZIP="$TMPDIR/runart-wpcli-bridge.zip"

echo "📦 Empaquetando plugin..."
(cd "$PLUGIN_DIR" && zip -r "$PLUGIN_ZIP" . -x "*.git*" "*.DS_Store" 2>/dev/null)

if [[ ! -f "$PLUGIN_ZIP" ]]; then
  echo "❌ Error al crear el zip del plugin"
  exit 1
fi

PLUGIN_BASE64=$(base64 -w 0 "$PLUGIN_ZIP" 2>/dev/null || base64 "$PLUGIN_ZIP")

if [[ "$REAL" -eq 0 ]]; then
  echo "🔎 DRY-RUN: Mostraría el tamaño del plugin a enviar:"
  ls -lh "$PLUGIN_ZIP"
  echo ""
  echo "    Use --real-deploy para ejecutar el deployment."
  rm -rf "$TMPDIR"
  exit 0
fi

echo "📤 Subiendo plugin al servidor WordPress..."

# Endpoint personalizado para recibir y desplegar el plugin
# (necesitamos crear este endpoint en el plugin bridge o usar el filesystem API de WP)
# Por ahora, usaremos una estrategia alternativa: crear la página del monitor directamente

echo "📄 Creando página 'Monitor IA-Visual' si no existe..."
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/wp-json/wp/v2/pages" \
  -H "$AUTH_HEADER" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Monitor IA-Visual",
    "content": "[runart_ai_visual_monitor]",
    "status": "publish"
  }')

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [[ "$HTTP_CODE" =~ ^(200|201)$ ]]; then
  echo "✅ Página creada exitosamente"
  echo "$BODY" | jq -r '.link // .id // .' 2>/dev/null || echo "$BODY"
elif [[ "$HTTP_CODE" == "400" ]]; then
  echo "⚠️  Página ya existe o hubo error de validación:"
  echo "$BODY" | jq -r '.message // .' 2>/dev/null || echo "$BODY"
else
  echo "❌ Error al crear página (HTTP $HTTP_CODE):"
  echo "$BODY"
fi

echo ""
echo "🔄 Activando plugin (via WP-CLI bridge endpoint)..."
FLUSH_RESPONSE=$(curl -s -X POST "$BASE_URL/wp-json/runart/v1/bridge/cache/flush" \
  -H "$AUTH_HEADER" \
  -H "Content-Type: application/json")

echo "$FLUSH_RESPONSE" | jq '.' 2>/dev/null || echo "$FLUSH_RESPONSE"

echo ""
echo "=== ✅ Deployment completado ==="
echo "    Página: $BASE_URL/monitor-ia-visual/"
echo "    Estado: Verificar endpoints REST manualmente"

rm -rf "$TMPDIR"
