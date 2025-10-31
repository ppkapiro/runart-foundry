#!/bin/bash
# Inicializar estructura IA-Visual en staging IONOS
# Uso: bash tools/init_staging_iavisual_structure.sh

STAGING_ROOT="/homepages/7/d958591985/htdocs/staging"

echo "🚀 Inicializando estructura IA-Visual en staging..."

# 1. Crear source of truth (Layer 2)
mkdir -p "$STAGING_ROOT/wp-content/runart-data/assistants/rewrite"
chmod 755 "$STAGING_ROOT/wp-content/runart-data"
chmod 755 "$STAGING_ROOT/wp-content/runart-data/assistants"
chmod 755 "$STAGING_ROOT/wp-content/runart-data/assistants/rewrite"

# 2. Copiar dataset desde plugin
cp -r "$STAGING_ROOT/wp-content/plugins/runart-ia-visual-unified/data/assistants/rewrite/"* \
     "$STAGING_ROOT/wp-content/runart-data/assistants/rewrite/"

# 3. Crear estructura de colas
mkdir -p "$STAGING_ROOT/wp-content/uploads/runart-jobs"/{approved,rejected,queued,logs,enriched}
chmod -R 755 "$STAGING_ROOT/wp-content/uploads/runart-jobs"

# 4. Crear estructura de backups
mkdir -p "$STAGING_ROOT/wp-content/uploads/runart-backups/ia-visual"/{daily,full,monthly}
chmod -R 755 "$STAGING_ROOT/wp-content/uploads/runart-backups"

echo "✅ Estructura creada:"
ls -la "$STAGING_ROOT/wp-content/runart-data/assistants/rewrite/"
echo ""
echo "✅ Colas creadas:"
ls -la "$STAGING_ROOT/wp-content/uploads/runart-jobs/"
echo ""
echo "✅ Backups creados:"
ls -la "$STAGING_ROOT/wp-content/uploads/runart-backups/ia-visual/"

echo "🎯 Verificando con endpoint..."
curl -s "https://staging.runartfoundry.com/wp-json/runart/v1/data-scan" | python3 -m json.tool
