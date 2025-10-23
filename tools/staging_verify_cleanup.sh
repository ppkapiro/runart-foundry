#!/bin/bash

# VERIFICAR ESTADO DE LIMPIEZA STAGING
# Verifica si staging está listo para Fase 2 i18n

STAGING_URL="https://staging.runartfoundry.com"

echo "🔍 VERIFICANDO ESTADO STAGING - RunArt Foundry"
echo "=============================================="
echo "URL: $STAGING_URL"
echo "Fecha: $(date)"
echo ""

# Verificar acceso
echo "🌐 Verificando acceso a staging..."
if curl -s -I "$STAGING_URL" | grep -q "200"; then
    echo "✅ Staging accesible"
else
    echo "❌ Staging no accesible"
    exit 1
fi

echo ""
echo "📊 INVENTARIO ACTUAL:"

# Verificar contenido
posts_count=$(curl -s "$STAGING_URL/wp-json/wp/v2/posts" | jq 'length' 2>/dev/null || echo "error")
pages_count=$(curl -s "$STAGING_URL/wp-json/wp/v2/pages" | jq 'length' 2>/dev/null || echo "error")
media_count=$(curl -s "$STAGING_URL/wp-json/wp/v2/media" | jq 'length' 2>/dev/null || echo "error")

echo "- Posts: $posts_count"
echo "- Páginas: $pages_count"
echo "- Medios: $media_count"

# Verificar Polylang
echo ""
echo "🌍 Verificando Polylang:"
polylang_check=$(curl -s "$STAGING_URL/wp-json/pll/v1/languages" 2>/dev/null)
polylang_count=$(echo "$polylang_check" | jq 'length' 2>/dev/null || echo "0")

if [[ "$polylang_count" == "2" ]]; then
    echo "✅ Polylang activo con $polylang_count idiomas"
    echo "$polylang_check" | jq -r '.[] | "   - \(.name) (\(.code)): \(.url)"' 2>/dev/null || echo "   - Configuración detectada"
else
    echo "⚠️  Polylang: $polylang_count idiomas detectados"
    if [[ "$polylang_count" == "0" ]]; then
        echo "❌ Polylang no está activo o configurado"
    fi
fi

# Estado general
echo ""
echo "🎯 ESTADO PARA FASE 2 i18n:"

if [[ "$posts_count" == "0" && "$pages_count" -le "2" && "$media_count" == "0" && "$polylang_count" == "2" ]]; then
    echo "✅ STAGING LISTO PARA FASE 2"
    echo ""
    echo "🚀 SIGUIENTE PASO:"
    echo "   cd /home/pepe/work/runartfoundry"
    echo "   ./docs/i18n/DEPLOY_FASE2_STAGING.md"
    echo ""
    echo "📋 DEPLOYMENT INCLUYE:"
    echo "   ✅ Navegación bilingüe ES/EN"
    echo "   ✅ Language switcher automático"
    echo "   ✅ Menús contextuales por idioma"
    echo "   ✅ Integration con GeneratePress Child"
    
elif [[ "$polylang_count" != "2" ]]; then
    echo "❌ POLYLANG NO CONFIGURADO CORRECTAMENTE"
    echo ""
    echo "🔧 ACCIÓN REQUERIDA:"
    echo "   1. Activar plugin Polylang en wp-admin"
    echo "   2. Configurar idiomas ES/EN"
    echo "   3. Volver a ejecutar este script"
    
else
    echo "⚠️  LIMPIEZA PENDIENTE"
    echo ""
    echo "📋 CONTENIDO A ELIMINAR:"
    if [[ "$posts_count" != "0" ]]; then
        echo "   - $posts_count posts"
    fi
    if [[ "$pages_count" -gt "2" ]]; then
        echo "   - $(($pages_count - 2)) páginas extras"
    fi
    if [[ "$media_count" != "0" ]]; then
        echo "   - $media_count archivos media"
    fi
    
    echo ""
    echo "🔧 OPCIONES DE LIMPIEZA:"
    echo "   1. Manual: ./docs/i18n/LIMPIEZA_MANUAL_STAGING.md"
    echo "   2. Con credenciales: ./tools/staging_cleanup_auth.sh"
    echo ""
    echo "⏱️  Tiempo estimado: 5-10 minutos"
fi

echo ""
echo "📊 DETALLES TÉCNICOS:"
echo "   - WordPress: $(curl -s "$STAGING_URL/wp-json" | jq -r '.namespaces[]' 2>/dev/null | grep wp/v2 > /dev/null && echo "✅ API funcional" || echo "⚠️ API issues")"
echo "   - REST API: $(curl -s -I "$STAGING_URL/wp-json/wp/v2" | grep -q "200" && echo "✅ Accesible" || echo "❌ No accesible")"
echo "   - Polylang API: $(curl -s -I "$STAGING_URL/wp-json/pll/v1" | grep -q "200" && echo "✅ Funcional" || echo "❌ No disponible")"

# Mostrar algunos posts específicos si existen
if [[ "$posts_count" -gt "0" && "$posts_count" != "error" ]]; then
    echo ""
    echo "📝 MUESTRA DE CONTENIDO ACTUAL:"
    curl -s "$STAGING_URL/wp-json/wp/v2/posts?per_page=3" | jq -r '.[] | "   - \(.title.rendered) (ID: \(.id))"' 2>/dev/null | head -3
    if [[ "$posts_count" -gt "3" ]]; then
        echo "   - ... y $(($posts_count - 3)) posts más"
    fi
fi