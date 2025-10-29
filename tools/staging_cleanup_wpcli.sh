#!/bin/bash

# LIMPIEZA REAL STAGING usando WP-CLI remoto
# Elimina contenido usando WP-CLI directamente en el servidor

STAGING_URL="https://staging.runartfoundry.com"
LOG_FILE="logs/staging_cleanup_wpcli_$(date +%Y%m%d_%H%M%S).log"

echo "🚀 LIMPIEZA REAL STAGING con WP-CLI - RunArt Foundry" | tee -a "$LOG_FILE"
echo "=====================================================" | tee -a "$LOG_FILE"
echo "URL: $STAGING_URL" | tee -a "$LOG_FILE"
echo "Fecha: $(date)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Función para ejecutar comandos WP-CLI remotos
execute_wpcli() {
    local cmd="$1"
    local description="$2"
    
    echo "🔧 $description" | tee -a "$LOG_FILE"
    echo "   Comando: wp $cmd" | tee -a "$LOG_FILE"
    
    # Crear archivo temporal con el comando
    local temp_script="/tmp/wpcli_cmd_$$.php"
    cat > "$temp_script" << EOF
<?php
// WP-CLI execution script
\$cmd = '$cmd';
\$wp_cli_path = '/tmp/wp-cli.phar';

// Download WP-CLI if not exists
if (!file_exists(\$wp_cli_path)) {
    file_put_contents(\$wp_cli_path, file_get_contents('https://raw.githubusercontent.com/wp-cli/wp-cli/v2.8.1/utils/wp-cli.phar'));
    chmod(\$wp_cli_path, 0755);
}

// Execute WP-CLI command
\$output = shell_exec("cd /homepages/7/d958591985/htdocs/staging && php \$wp_cli_path \$cmd 2>&1");
echo \$output;
?>
EOF

    # Subir y ejecutar el script temporalmente
    local result=$(curl -s -F "script=@$temp_script" "$STAGING_URL/wp-admin/admin-ajax.php?action=exec_temp_script" 2>/dev/null || echo "Error ejecutando comando")
    
    echo "   Resultado: $result" | tee -a "$LOG_FILE"
    rm -f "$temp_script"
    
    return 0
}

# Función alternativa: usar URLs especiales para WP-CLI
execute_wpcli_url() {
    local cmd="$1"
    local description="$2"
    
    echo "🔧 $description" | tee -a "$LOG_FILE"
    echo "   Comando: wp $cmd" | tee -a "$LOG_FILE"
    
    # Codificar comando en base64 para URL
    local encoded_cmd=$(echo "cd /homepages/7/d958591985/htdocs/staging && php wp-cli.phar $cmd" | base64 -w0)
    
    # Ejecutar via URL especial
    local result=$(curl -s "$STAGING_URL/wp-content/themes/generatepress_child/wpcli-exec.php?cmd=$encoded_cmd" 2>/dev/null || echo "URL method not available")
    
    echo "   Resultado: $result" | tee -a "$LOG_FILE"
    
    return 0
}

# Método simple: eliminar via SQL directo si es posible
delete_content_direct() {
    echo "🗑️  ELIMINACIÓN DIRECTA DE CONTENIDO" | tee -a "$LOG_FILE"
    
    # Obtener todos los IDs para eliminar forzadamente
    local all_post_ids=$(curl -s "$STAGING_URL/wp-json/wp/v2/posts?per_page=100" | jq -r '.[].id' 2>/dev/null | tr '\n' ' ')
    local all_page_ids=$(curl -s "$STAGING_URL/wp-json/wp/v2/pages?per_page=100" | jq -r '.[] | select(.slug != "sample-page" and .slug != "privacy-policy") | .id' 2>/dev/null | tr '\n' ' ')
    local all_media_ids=$(curl -s "$STAGING_URL/wp-json/wp/v2/media?per_page=100" | jq -r '.[].id' 2>/dev/null | tr '\n' ' ')
    
    echo "Posts a eliminar: $all_post_ids" | tee -a "$LOG_FILE"
    echo "Páginas a eliminar: $all_page_ids" | tee -a "$LOG_FILE"  
    echo "Medios a eliminar: $all_media_ids" | tee -a "$LOG_FILE"
    
    # Intentar WP-CLI commands
    if [[ -n "$all_post_ids" ]]; then
        execute_wpcli_url "post delete $all_post_ids --force" "Eliminando posts con WP-CLI"
    fi
    
    if [[ -n "$all_page_ids" ]]; then
        execute_wpcli_url "post delete $all_page_ids --force" "Eliminando páginas con WP-CLI"
    fi
    
    if [[ -n "$all_media_ids" ]]; then
        execute_wpcli_url "post delete $all_media_ids --force" "Eliminando medios con WP-CLI"
    fi
}

# Verificar acceso
echo "🔍 Verificando acceso a staging..."
if curl -s -I "$STAGING_URL" | grep -q "200"; then
    echo "✅ Staging accesible"
else
    echo "❌ Staging no accesible"
    exit 1
fi

# Verificar WP-CLI disponible
echo "🔍 Verificando WP-CLI en staging..."
if curl -s -I "$STAGING_URL/wp-cli.phar" | grep -q "200"; then
    echo "✅ WP-CLI disponible en staging"
else
    echo "❌ WP-CLI no encontrado"
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
    echo "✅ STAGING YA ESTÁ LIMPIO"
    exit 0
fi

echo "🚀 INICIANDO LIMPIEZA CON WP-CLI..."
echo ""

# Ejecutar limpieza directa
delete_content_direct

# Verificar resultado final
echo ""
echo "🔍 VERIFICACIÓN FINAL:"
final_posts=$(curl -s "$STAGING_URL/wp-json/wp/v2/posts" | jq 'length' 2>/dev/null || echo "error")
final_pages=$(curl -s "$STAGING_URL/wp-json/wp/v2/pages" | jq 'length' 2>/dev/null || echo "error")
final_media=$(curl -s "$STAGING_URL/wp-json/wp/v2/media" | jq 'length' 2>/dev/null || echo "error")

echo "- Posts restantes: $final_posts" | tee -a "$LOG_FILE"
echo "- Páginas restantes: $final_pages" | tee -a "$LOG_FILE"
echo "- Medios restantes: $final_media" | tee -a "$LOG_FILE"

# Verificar Polylang
polylang_check=$(curl -s "$STAGING_URL/wp-json/pll/v1/languages" | jq -r 'length' 2>/dev/null || echo "0")
echo "- Idiomas Polylang: $polylang_check" | tee -a "$LOG_FILE"

if [[ "$polylang_check" == "2" ]]; then
    echo "✅ Polylang preservado correctamente (ES/EN)" | tee -a "$LOG_FILE"
else
    echo "⚠️  Verificar configuración Polylang" | tee -a "$LOG_FILE"
fi

echo ""
if [[ "$final_posts" == "0" && "$final_pages" -le "2" && "$final_media" == "0" ]]; then
    echo "✅ LIMPIEZA COMPLETADA EXITOSAMENTE" | tee -a "$LOG_FILE"
    echo "🎯 STAGING LISTO PARA FASE 2 i18n" | tee -a "$LOG_FILE"
else
    echo "⚠️  LIMPIEZA PARCIAL - Contenido restante detectado" | tee -a "$LOG_FILE"
    echo "💡 Puede requerir acceso directo al servidor" | tee -a "$LOG_FILE"
fi

echo ""
echo "📄 Log completo: $LOG_FILE"
echo "🎯 SIGUIENTE PASO: Desplegar Fase 2 i18n"
echo "   ./docs/i18n/DEPLOY_FASE2_STAGING.md"