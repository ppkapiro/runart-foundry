#!/bin/bash

# LIMPIEZA DIRECTA STAGING - Sin credenciales
# Elimina contenido directamente usando REST API público

STAGING_URL="https://staging.runartfoundry.com"
LOG_FILE="logs/staging_cleanup_direct_$(date +%Y%m%d_%H%M%S).log"

echo "🚀 LIMPIEZA DIRECTA STAGING - RunArt Foundry" | tee -a "$LOG_FILE"
echo "===============================================" | tee -a "$LOG_FILE"
echo "URL: $STAGING_URL" | tee -a "$LOG_FILE"
echo "Fecha: $(date)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Función para eliminar posts
delete_posts() {
    echo "🗑️  Eliminando posts..." | tee -a "$LOG_FILE"
    local post_ids=$(curl -s "$STAGING_URL/wp-json/wp/v2/posts?per_page=100" | jq -r '.[].id' 2>/dev/null)
    
    if [[ -n "$post_ids" ]]; then
        echo "Posts encontrados: $(echo "$post_ids" | wc -l)" | tee -a "$LOG_FILE"
        while IFS= read -r post_id; do
            echo "  - Eliminando post ID: $post_id" | tee -a "$LOG_FILE"
            curl -s -X DELETE "$STAGING_URL/wp-json/wp/v2/posts/$post_id?force=true" >> "$LOG_FILE" 2>&1
        done <<< "$post_ids"
    else
        echo "No se encontraron posts" | tee -a "$LOG_FILE"
    fi
}

# Función para eliminar páginas (excepto páginas del sistema)
delete_pages() {
    echo "🗑️  Eliminando páginas..." | tee -a "$LOG_FILE"
    local page_ids=$(curl -s "$STAGING_URL/wp-json/wp/v2/pages?per_page=100" | jq -r '.[] | select(.slug != "sample-page" and .slug != "privacy-policy") | .id' 2>/dev/null)
    
    if [[ -n "$page_ids" ]]; then
        echo "Páginas encontradas: $(echo "$page_ids" | wc -l)" | tee -a "$LOG_FILE"
        while IFS= read -r page_id; do
            echo "  - Eliminando página ID: $page_id" | tee -a "$LOG_FILE"
            curl -s -X DELETE "$STAGING_URL/wp-json/wp/v2/pages/$page_id?force=true" >> "$LOG_FILE" 2>&1
        done <<< "$page_ids"
    else
        echo "No se encontraron páginas para eliminar" | tee -a "$LOG_FILE"
    fi
}

# Función para eliminar medios
delete_media() {
    echo "🗑️  Eliminando medios..." | tee -a "$LOG_FILE"
    local media_ids=$(curl -s "$STAGING_URL/wp-json/wp/v2/media?per_page=100" | jq -r '.[].id' 2>/dev/null)
    
    if [[ -n "$media_ids" ]]; then
        echo "Medios encontrados: $(echo "$media_ids" | wc -l)" | tee -a "$LOG_FILE"
        while IFS= read -r media_id; do
            echo "  - Eliminando medio ID: $media_id" | tee -a "$LOG_FILE"
            curl -s -X DELETE "$STAGING_URL/wp-json/wp/v2/media/$media_id?force=true" >> "$LOG_FILE" 2>&1
        done <<< "$media_ids"
    else
        echo "No se encontraron medios" | tee -a "$LOG_FILE"
    fi
}

# Función para verificar resultado
verify_cleanup() {
    echo "" | tee -a "$LOG_FILE"
    echo "🔍 VERIFICACIÓN POST-LIMPIEZA:" | tee -a "$LOG_FILE"
    
    local posts_remaining=$(curl -s "$STAGING_URL/wp-json/wp/v2/posts" | jq 'length' 2>/dev/null || echo "error")
    local pages_remaining=$(curl -s "$STAGING_URL/wp-json/wp/v2/pages" | jq 'length' 2>/dev/null || echo "error")
    local media_remaining=$(curl -s "$STAGING_URL/wp-json/wp/v2/media" | jq 'length' 2>/dev/null || echo "error")
    
    echo "- Posts restantes: $posts_remaining" | tee -a "$LOG_FILE"
    echo "- Páginas restantes: $pages_remaining" | tee -a "$LOG_FILE"
    echo "- Medios restantes: $media_remaining" | tee -a "$LOG_FILE"
    
    # Verificar Polylang
    local polylang_check=$(curl -s "$STAGING_URL/wp-json/pll/v1/languages" | jq -r 'length' 2>/dev/null || echo "0")
    echo "- Idiomas Polylang: $polylang_check" | tee -a "$LOG_FILE"
    
    if [[ "$polylang_check" == "2" ]]; then
        echo "✅ Polylang preservado correctamente (ES/EN)" | tee -a "$LOG_FILE"
    else
        echo "⚠️  Verificar configuración Polylang" | tee -a "$LOG_FILE"
    fi
}

# EJECUCIÓN PRINCIPAL
echo "🔍 Verificando acceso a staging..."
if curl -s -I "$STAGING_URL" | grep -q "200"; then
    echo "✅ Staging accesible"
else
    echo "❌ Staging no accesible"
    exit 1
fi

echo ""
echo "📊 INVENTARIO INICIAL:"
initial_posts=$(curl -s "$STAGING_URL/wp-json/wp/v2/posts" | jq 'length' 2>/dev/null || echo "error")
initial_pages=$(curl -s "$STAGING_URL/wp-json/wp/v2/pages" | jq 'length' 2>/dev/null || echo "error")
initial_media=$(curl -s "$STAGING_URL/wp-json/wp/v2/media" | jq 'length' 2>/dev/null || echo "error")

echo "- Posts: $initial_posts"
echo "- Páginas: $initial_pages"
echo "- Medios: $initial_media"
echo ""

if [[ "$initial_posts" == "0" && "$initial_pages" -le "2" && "$initial_media" == "0" ]]; then
    echo "✅ STAGING YA ESTÁ LIMPIO - No es necesaria limpieza"
    exit 0
fi

echo "🚀 INICIANDO LIMPIEZA DIRECTA..."
echo ""

# Ejecutar limpieza
delete_posts
sleep 2
delete_pages  
sleep 2
delete_media

# Verificar resultado
verify_cleanup

echo ""
echo "✅ LIMPIEZA COMPLETADA"
echo "📄 Log completo: $LOG_FILE"
echo ""
echo "🎯 SIGUIENTE PASO: Desplegar Fase 2 i18n"
echo "   ./docs/i18n/DEPLOY_FASE2_STAGING.md"