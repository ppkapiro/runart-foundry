#!/usr/bin/env bash
# Wrapper para ejecutar smoke tests en producción con configuración optimizada
# Activa automáticamente el manejo correcto de redirects de Cloudflare Access

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Variables de entorno para configurar run-smokes.mjs
export SMOKES_ALLOW_302="1"
export SMOKES_RETRIES="${SMOKES_RETRIES:-2}"
export SMOKES_RETRY_DELAY_MS="${SMOKES_RETRY_DELAY_MS:-500}"

# URL base - detectar si es producción automáticamente
BASEURL="${1:-${PREVIEW_URL:-${CF_PAGES_URL:-}}}"

if [[ -z "$BASEURL" ]]; then
  echo "❌ Uso: $0 <base-url>"
  echo "   Ejemplo: $0 https://runart-foundry.pages.dev"
  echo "   O define PREVIEW_URL o CF_PAGES_URL"
  exit 1
fi

# Detectar si es un entorno de producción con Access
HOSTNAME=$(echo "$BASEURL" | sed 's|^https\?://||' | cut -d'/' -f1)
IS_PRODUCTION=0

if [[ "$HOSTNAME" == *.pages.dev ]] || [[ "$HOSTNAME" == *runart* ]]; then
  IS_PRODUCTION=1
fi

echo "🔍 Ejecutando smoke tests para: $BASEURL"
echo "🏭 Entorno detectado: $([ $IS_PRODUCTION -eq 1 ] && echo "Producción (Access esperado)" || echo "Desarrollo")"
echo "🔐 Configuración: ALLOW_302=1, RETRIES=${SMOKES_RETRIES}, DELAY=${SMOKES_RETRY_DELAY_MS}ms"
echo ""

# Cambiar al directorio del proyecto para que los imports relativos funcionen
cd "$PROJECT_ROOT"

# Ejecutar el runner de smoke tests con las banderas correctas
if command -v node >/dev/null 2>&1; then
  exec node tests/scripts/run-smokes.mjs \
    --baseURL="$BASEURL" \
    --allow-access-redirects \
    --no-follow
else
  echo "❌ Node.js no está instalado. Instalarlo o usar smoke_production.sh directamente."
  exit 1
fi