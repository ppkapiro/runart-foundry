#!/usr/bin/env bash
set -euo pipefail
# Setup inicial para nuevos sitios Local - configura URLs y despliega plugin
# Usage: bash tools/setup_local_wp_config.sh

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "═══════════════════════════════════════════════════════"
echo "  Setup Local WordPress - WP Staging Lite Integration"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Este script:"
echo "  1. Aplica fix de URLs (WP_HOME/WP_SITEURL)"
echo "  2. Vincula/copia el plugin MU al sitio Local"
echo "  3. Valida la instalación"
echo ""

# Paso 1: Fix URLs
echo "▶ Paso 1/3: Aplicando fix de URLs..."
bash "$REPO_ROOT/tools/fix_local_wp_urls.sh" || {
  echo "❌ Error en fix de URLs. Abortando."
  exit 1
}
echo ""

# Paso 2: Vincular plugin
echo "▶ Paso 2/3: Vinculando plugin MU..."
bash "$REPO_ROOT/scripts/wp_staging_local_link.sh" || {
  echo "❌ Error al vincular plugin. Abortando."
  exit 1
}
echo ""

# Paso 3: Validar instalación
echo "▶ Paso 3/3: Validando instalación..."
bash "$REPO_ROOT/scripts/wp_staging_local_validate.sh" || {
  echo "⚠️  La validación reportó problemas. Revisa el output anterior."
}
echo ""

echo "═══════════════════════════════════════════════════════"
echo "✅ Setup completado"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Puedes acceder al sitio y verificar:"
echo "  - Frontend: Abre el sitio en Local"
echo "  - REST API: curl http://localhost:PORT/wp-json/briefing/v1/status"
echo ""
echo "Documentación:"
echo "  - Troubleshooting: docs/integration_wp_staging_lite/TROUBLESHOOTING.md"
echo "  - Tests locales: docs/integration_wp_staging_lite/TESTS_PLUGIN_LOCAL.md"
