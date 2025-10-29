#!/usr/bin/env bash
# Script de actualización de secretos en GitHub Actions
# Ejecutar desde la raíz del repo
set -euo pipefail

echo "🔧 Actualizando secretos de GitHub Actions a estándar RUNART..."
echo

# Cargar valores actuales de local
ENV_FILE="$HOME/.runart/env"
if [ ! -f "$ENV_FILE" ]; then
  echo "❌ No se encontró $ENV_FILE"
  exit 1
fi
. "$ENV_FILE"

# 1) Eliminar duplicados y legacy
echo "🗑️  Eliminando secretos duplicados y legacy..."
gh secret remove CF_ACCOUNT_ID || true
gh secret remove CF_API_TOKEN || true
gh secret remove RUNART_ROLES_KV_PREVIEW || true
gh secret remove RUNART_ROLES_KV_PROD || true
gh secret remove CF_LOG_EVENTS_ID || true
gh secret remove CF_LOG_EVENTS_PREVIEW_ID || true
gh secret remove CLOUDFLARE_PROJECT_NAME || true

# 2) Renombrar ACCESS tokens (añadir sufijo _PREVIEW)
echo "🔄 Renombrando ACCESS tokens..."
# Obtener valores actuales antes de eliminar
ACCESS_ID_OLD=$(gh secret list | grep "^ACCESS_CLIENT_ID\s" | awk '{print $1}' || echo "")
ACCESS_SECRET_OLD=$(gh secret list | grep "^ACCESS_CLIENT_SECRET\s" | awk '{print $1}' || echo "")

if [ -n "$ACCESS_ID_OLD" ]; then
  echo "  Copiando ACCESS_CLIENT_ID → ACCESS_CLIENT_ID_PREVIEW"
  echo -n "$ACCESS_CLIENT_ID" | gh secret set ACCESS_CLIENT_ID_PREVIEW
  gh secret remove ACCESS_CLIENT_ID || true
fi

if [ -n "$ACCESS_SECRET_OLD" ]; then
  echo "  Copiando ACCESS_CLIENT_SECRET → ACCESS_CLIENT_SECRET_PREVIEW"
  echo -n "$ACCESS_CLIENT_SECRET" | gh secret set ACCESS_CLIENT_SECRET_PREVIEW
  gh secret remove ACCESS_CLIENT_SECRET || true
fi

# 3) Crear NAMESPACE_ID_RUNART_ROLES_PREVIEW con ID correcto de preview
echo "➕ Creando NAMESPACE_ID_RUNART_ROLES_PREVIEW..."
NAMESPACE_PREVIEW="7d80b07de98e4d9b9d5fd85516901ef6"
echo -n "$NAMESPACE_PREVIEW" | gh secret set NAMESPACE_ID_RUNART_ROLES_PREVIEW

# 4) Verificar secretos estándar
echo
echo "✅ Secretos actualizados. Lista actual:"
gh secret list | grep -E "CLOUDFLARE_|ACCESS_|NAMESPACE_"

echo
echo "🎯 Secretos estándar RUNART:"
echo "  1. CLOUDFLARE_API_TOKEN"
echo "  2. CLOUDFLARE_ACCOUNT_ID"
echo "  3. NAMESPACE_ID_RUNART_ROLES_PREVIEW"
echo "  4. ACCESS_CLIENT_ID_PREVIEW"
echo "  5. ACCESS_CLIENT_SECRET_PREVIEW"
echo
echo "✅ Normalización completada."
