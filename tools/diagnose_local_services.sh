#!/usr/bin/env bash
set -euo pipefail
# Diagnóstico completo de servicios de Local

echo "═══════════════════════════════════════════════════════"
echo "  Diagnóstico de Local - runart-staging-local"
echo "═══════════════════════════════════════════════════════"
echo ""

echo "1. Verificando respuesta HTTP..."
if curl.exe -I http://localhost:10010/ 2>&1 | grep -q "HTTP/1.1 200"; then
    echo "✅ HTTP responde correctamente"
else
    echo "❌ HTTP no responde o error"
    curl.exe -I http://localhost:10010/ 2>&1 | head -5
fi
echo ""

echo "2. Verificando MySQL..."
WP_CONFIG="/mnt/c/Users/pepec/Local Sites/runart-staging-local/app/public/wp-config.php"
if [ -f "$WP_CONFIG" ]; then
    DB_HOST=$(grep "DB_HOST" "$WP_CONFIG" | cut -d"'" -f4)
    DB_NAME=$(grep "DB_NAME" "$WP_CONFIG" | cut -d"'" -f4)
    echo "  Host BD: $DB_HOST"
    echo "  Nombre BD: $DB_NAME"
else
    echo "❌ No se encuentra wp-config.php"
fi
echo ""

echo "3. Verificando archivos críticos..."
WP_DIR="/mnt/c/Users/pepec/Local Sites/runart-staging-local/app/public"
if [ -f "$WP_DIR/wp-config.php" ]; then
    echo "✅ wp-config.php existe"
else
    echo "❌ wp-config.php no existe"
fi

if [ -f "$WP_DIR/index.php" ]; then
    echo "✅ index.php existe"
else
    echo "❌ index.php no existe"
fi

if [ -d "$WP_DIR/wp-content/mu-plugins" ]; then
    echo "✅ mu-plugins existe"
    ls -la "$WP_DIR/wp-content/mu-plugins/" | grep wp-staging-lite || echo "  ⚠️ wp-staging-lite no encontrado"
else
    echo "❌ mu-plugins no existe"
fi
echo ""

echo "4. Test simple de PHP..."
echo '<?php echo "PHP funciona"; ?>' > /tmp/test.php
if php /tmp/test.php 2>&1 | grep -q "PHP funciona"; then
    echo "✅ PHP básico funciona"
else
    echo "❌ PHP tiene problemas"
fi
rm -f /tmp/test.php
echo ""

echo "═══════════════════════════════════════════════════════"
echo "INSTRUCCIONES:"
echo ""
echo "Si ves errores arriba:"
echo "1. Para el sitio en Local (botón Stop)"
echo "2. Cierra Local completamente"
echo "3. Abre Local de nuevo"
echo "4. Inicia el sitio (botón Start)"
echo "5. Espera a que TODOS los servicios estén verdes"
echo "6. Usa: http://localhost:10010"
echo ""
echo "Si sigue fallando, comparte la salida de este diagnóstico."
echo "═══════════════════════════════════════════════════════"