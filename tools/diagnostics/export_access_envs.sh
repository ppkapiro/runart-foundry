#!/usr/bin/env bash

###############################################################################
# Export Access Environment Variables
#
# Helper para exportar variables de entorno de forma segura sin mostrarlas
# en el historial de bash ni en la consola.
###############################################################################

set -eo pipefail

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  RUNART | Configuración de Variables de Entorno (Access)"
echo "════════════════════════════════════════════════════════════"
echo ""

# Función para pedir variable con read -s si no existe
prompt_if_missing() {
  local var_name="$1"
  local var_value="${!var_name}"
  
  if [ -z "$var_value" ]; then
    echo -n "🔑 Ingresa $var_name: "
    read -s var_value
    echo ""
    export "$var_name=$var_value"
    echo "   ✅ $var_name configurado (${#var_value} caracteres)"
  else
    echo "   ✅ $var_name ya configurado (${#var_value} caracteres)"
  fi
}

# Verificar cada variable requerida
prompt_if_missing "CLOUDFLARE_API_TOKEN"
prompt_if_missing "CLOUDFLARE_ACCOUNT_ID"
prompt_if_missing "ACCESS_CLIENT_ID_PREVIEW"
prompt_if_missing "ACCESS_CLIENT_SECRET_PREVIEW"

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  ✅ Todas las variables de entorno están configuradas"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Ahora puedes ejecutar:"
echo "  npm run access:deepcheck"
echo ""
