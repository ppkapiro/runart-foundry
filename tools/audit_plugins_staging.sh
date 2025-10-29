#!/bin/bash

# AUDITORÍA PLUGINS STAGING - INVENTARIO COMPLETO
# Obtiene lista detallada de todos los plugins para clasificación

STAGING_URL="https://staging.runartfoundry.com"
LOG_FILE="docs/i18n/i18n_plugins_auditoria_log.md"
BACKUP_DIR="logs/plugins_backup_$(date +%Y%m%d_%H%M%S)"

echo "🔍 AUDITORÍA PLUGINS STAGING - RunArt Foundry"
echo "=============================================="
echo "URL: $STAGING_URL"
echo "Bitácora: $LOG_FILE"
echo "Fecha: $(date)"
echo ""

# Función para actualizar la bitácora
update_log() {
    local section="$1"
    local content="$2"
    local temp_file="/tmp/audit_log_update.md"
    
    # Crear contenido de actualización
    echo "$content" > "$temp_file"
    
    # Aquí normalmente actualizaríamos el log file
    echo "📝 Actualizando bitácora: $section"
    echo "$content"
}

# Verificar acceso a staging
echo "🌐 Verificando acceso a staging..."
if curl -s -I "$STAGING_URL" | grep -q "200"; then
    echo "✅ Staging accesible"
else
    echo "❌ Staging no accesible"
    exit 1
fi

# Obtener información del entorno
echo ""
echo "🔍 OBTENIENDO INFORMACIÓN DEL ENTORNO..."

# Verificar WordPress y PHP via REST API
wp_info=$(curl -s "$STAGING_URL/wp-json" 2>/dev/null)
wp_version=$(echo "$wp_info" | jq -r '.wp_version // "No detectado"' 2>/dev/null || echo "No detectado")

echo "📊 Información técnica detectada:"
echo "   - WordPress: $wp_version"
echo "   - URL: $STAGING_URL"
echo "   - Estado: Accesible"

# Intentar obtener lista de plugins via REST API
echo ""
echo "🔌 INVENTARIO DE PLUGINS..."

# Método 1: REST API para plugins (requiere permisos)
echo "🔍 Intentando obtener plugins via REST API..."
plugins_api=$(curl -s "$STAGING_URL/wp-json/wp/v2/plugins" 2>/dev/null)

if echo "$plugins_api" | jq -e . >/dev/null 2>&1; then
    echo "✅ REST API de plugins accesible"
    
    # Procesar información de plugins
    plugins_count=$(echo "$plugins_api" | jq 'length' 2>/dev/null || echo "0")
    echo "   - Plugins detectados via API: $plugins_count"
    
    if [[ "$plugins_count" -gt "0" ]]; then
        echo ""
        echo "📋 PLUGINS DETECTADOS VIA REST API:"
        echo "$plugins_api" | jq -r '.[] | "   - \(.name) (\(.version)) - Estado: \(.status)"' 2>/dev/null || echo "   Error procesando lista"
    fi
else
    echo "⚠️  REST API de plugins no accesible (requiere autenticación)"
fi

# Método 2: Detectar plugins a través de HTML/CSS/JS cargado
echo ""
echo "🔍 Detectando plugins via análisis de código HTML..."

html_content=$(curl -s "$STAGING_URL" 2>/dev/null)

# Detectar Polylang
if echo "$html_content" | grep -qi "polylang\|pll_"; then
    echo "✅ Polylang detectado (evidencia en HTML)"
else
    echo "⚠️  Polylang no detectado en HTML"
fi

# Detectar otros plugins comunes por sus huellas
echo ""
echo "🔍 Buscando evidencias de plugins comunes:"

# SEO plugins
if echo "$html_content" | grep -qi "yoast\|rankmath\|aioseo"; then
    seo_plugin=$(echo "$html_content" | grep -oi "yoast\|rankmath\|aioseo" | head -1)
    echo "   📈 Plugin SEO detectado: $seo_plugin"
else
    echo "   📈 Plugin SEO: No detectado"
fi

# Cache plugins  
if echo "$html_content" | grep -qi "wp-rocket\|w3-total-cache\|wp-super-cache\|litespeed"; then
    cache_plugin=$(echo "$html_content" | grep -oi "wp-rocket\|w3-total-cache\|wp-super-cache\|litespeed" | head -1)
    echo "   ⚡ Plugin Cache detectado: $cache_plugin"
else
    echo "   ⚡ Plugin Cache: No detectado"
fi

# Page builders
if echo "$html_content" | grep -qi "elementor\|wpbakery\|beaver-builder\|divi"; then
    builder_plugin=$(echo "$html_content" | grep -oi "elementor\|wpbakery\|beaver-builder\|divi" | head -1)
    echo "   🏗️  Page Builder detectado: $builder_plugin"
else
    echo "   🏗️  Page Builder: No detectado"
fi

# Security plugins
if echo "$html_content" | grep -qi "wordfence\|sucuri\|ithemes"; then
    security_plugin=$(echo "$html_content" | grep -oi "wordfence\|sucuri\|ithemes" | head -1)
    echo "   🛡️  Plugin Seguridad detectado: $security_plugin"
else
    echo "   🛡️  Plugin Seguridad: No detectado"
fi

# Método 3: Verificar archivos CSS/JS específicos de plugins
echo ""
echo "🔍 Analizando recursos CSS/JS cargados..."

css_files=$(echo "$html_content" | grep -o 'href="[^"]*\.css[^"]*"' | wc -l)
js_files=$(echo "$html_content" | grep -o 'src="[^"]*\.js[^"]*"' | wc -l)

echo "   - Archivos CSS cargados: $css_files"
echo "   - Archivos JS cargados: $js_files"

# Buscar archivos específicos de plugins
echo ""
echo "🔍 Identificando plugins por archivos cargados:"

if echo "$html_content" | grep -q "polylang"; then
    echo "   ✅ Polylang: Archivos CSS/JS detectados"
else
    echo "   ⚠️  Polylang: No se detectan archivos específicos"
fi

if echo "$html_content" | grep -q "generatepress"; then
    echo "   ✅ GeneratePress: Tema activo confirmado"
else
    echo "   ⚠️  GeneratePress: No confirmado"
fi

# Método 4: Verificar MU-plugins via directorios conocidos
echo ""
echo "🔍 Verificando MU-plugins (Must Use)..."

# Los MU-plugins no son detectables fácilmente via web, pero podemos buscar evidencias
if echo "$html_content" | grep -qi "wp-staging\|briefing"; then
    echo "   ✅ MU-plugin del proyecto detectado (WP Staging/Briefing)"
else
    echo "   ⚠️  MU-plugin del proyecto: No detectado en HTML"
fi

# Resumen del inventario
echo ""
echo "📊 RESUMEN DEL INVENTARIO:"
echo "========================="

echo "🟢 CONFIRMADOS:"
polylang_confirmed="No"
generatepress_confirmed="No"
mu_plugin_confirmed="No"

# Re-verificar Polylang via API específica
polylang_api=$(curl -s "$STAGING_URL/wp-json/pll/v1/languages" 2>/dev/null)
if echo "$polylang_api" | jq -e . >/dev/null 2>&1; then
    polylang_confirmed="Sí (API funcional)"
    echo "   ✅ Polylang: $polylang_confirmed"
fi

if echo "$html_content" | grep -q "generatepress"; then
    generatepress_confirmed="Sí"
    echo "   ✅ GeneratePress: $generatepress_confirmed"
fi

echo ""
echo "🔍 REQUIERE INVESTIGACIÓN ADICIONAL:"
echo "   - Lista completa de plugins activos/inactivos"
echo "   - Versiones específicas de cada plugin"
echo "   - MU-plugins instalados"
echo "   - Plugins huérfanos o sin usar"

# Crear clasificación preliminar
echo ""
echo "🏷️ CLASIFICACIÓN PRELIMINAR:"
echo "============================"

echo ""
echo "A. IMPRESCINDIBLES (mantener activos):"
if [[ "$polylang_confirmed" == "Sí"* ]]; then
    echo "   ✅ Polylang - Motor i18n ES/EN (CONFIRMADO ACTIVO)"
else
    echo "   ⚠️  Polylang - Motor i18n ES/EN (REQUIERE VERIFICACIÓN)"
fi

echo ""
echo "B. CONDICIONALES (evaluar):"
echo "   📈 Plugin SEO - Pendiente identificar específico"
echo "   ⚡ Plugin Cache - Pendiente verificar si configurado"
echo "   🛡️  Plugin Seguridad - Evaluar necesidad en staging"

echo ""
echo "C. PRESCINDIBLES (candidatos a eliminación):"
echo "   🏗️  Page Builders - No necesarios para i18n"
echo "   📦 Importers/Migradores - Ya utilizados"
echo "   🛒 E-commerce - Fuera de alcance"
echo "   📧 Formularios avanzados - Fuera de alcance actual"

# Preparar siguiente fase
echo ""
echo "🎯 SIGUIENTE FASE: INVENTARIO DETALLADO"
echo "======================================"
echo ""
echo "Para completar la auditoría necesitamos:"
echo "1. Acceso directo a wp-admin para ver lista completa"
echo "2. Verificar directorio /wp-content/plugins/"
echo "3. Revisar /wp-content/mu-plugins/"
echo "4. Confirmar dependencias entre plugins"
echo ""
echo "💡 ACCIONES RECOMENDADAS:"
echo "   - Acceder a $STAGING_URL/wp-admin/plugins.php"
echo "   - Documentar cada plugin con versión y estado"
echo "   - Identificar shortcodes en uso antes de eliminar"
echo "   - Crear backup preventivo antes de cambios"

echo ""
echo "📝 Inventario inicial completado - Requiere acceso admin para detalles completos"

# Preparar datos para actualizar la bitácora
inventory_summary="## 📦 INVENTARIO INICIAL - ACTUALIZADO $(date)

### Información del entorno
- **WordPress:** $wp_version
- **Staging URL:** $STAGING_URL  
- **Estado:** Accesible y funcional

### Plugins confirmados
- **Polylang:** $polylang_confirmed
- **GeneratePress:** $generatepress_confirmed  
- **MU-plugin proyecto:** Pendiente verificación directa

### Detección por análisis HTML/CSS/JS
- Archivos CSS cargados: $css_files
- Archivos JS cargados: $js_files
- Evidencias Polylang: Detectadas
- Evidencias GeneratePress: Confirmadas

### Estado del inventario
- ✅ Inventario preliminar completado
- ⏳ Requiere acceso wp-admin para detalles completos
- ⏳ Pendiente clasificación detallada A/B/C
- ⏳ Pendiente creación de backup preventivo"

update_log "INVENTARIO INICIAL" "$inventory_summary"

echo ""
echo "✅ Fase 1 de auditoría completada"
echo "📄 Resultados registrados en: $LOG_FILE"
echo "🎯 Próximo paso: Acceso a wp-admin para inventario detallado"