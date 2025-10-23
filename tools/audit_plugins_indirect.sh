#!/bin/bash

# AUDITORÍA PLUGINS - MÉTODO INDIRECTO
# Detecta plugins usando métodos alternativos sin requerir wp-admin

STAGING_URL="https://staging.runartfoundry.com"

echo "🔍 AUDITORÍA PLUGINS - MÉTODO INDIRECTO"
echo "======================================="
echo "URL: $STAGING_URL"
echo ""

# Función para verificar plugin específico
check_plugin() {
    local plugin_name="$1"
    local check_method="$2"
    local expected_response="$3"
    
    echo "🔍 Verificando $plugin_name..."
    
    case "$check_method" in
        "api")
            response=$(curl -s "$STAGING_URL/wp-json/$expected_response" 2>/dev/null)
            if echo "$response" | jq -e . >/dev/null 2>&1; then
                echo "   ✅ $plugin_name: ACTIVO (API responde)"
                if [[ "$plugin_name" == "Polylang" ]]; then
                    # Obtener detalles de idiomas
                    echo "$response" | jq -r '.[] | "      - \(.name) (\(.code)): \(.url)"' 2>/dev/null || echo "      - Configurado correctamente"
                fi
                return 0
            else
                echo "   ❌ $plugin_name: INACTIVO o no instalado"
                return 1
            fi
            ;;
        "url")
            status_code=$(curl -s -o /dev/null -w "%{http_code}" "$STAGING_URL/$expected_response")
            if [[ "$status_code" == "200" ]]; then
                echo "   ✅ $plugin_name: Archivos presentes (URL accesible)"
                return 0
            else
                echo "   ❌ $plugin_name: No detectado ($status_code)"
                return 1
            fi
            ;;
        "header")
            headers=$(curl -s -I "$STAGING_URL" | grep -i "$expected_response")
            if [[ -n "$headers" ]]; then
                echo "   ✅ $plugin_name: Detectado en headers"
                echo "      $headers"
                return 0
            else
                echo "   ❌ $plugin_name: No detectado en headers"
                return 1
            fi
            ;;
    esac
}

echo "🔌 VERIFICANDO PLUGINS ESENCIALES:"
echo "=================================="

# Verificar Polylang (IMPRESCINDIBLE)
polylang_active=0
check_plugin "Polylang" "api" "pll/v1/languages" && polylang_active=1

echo ""

# Verificar otros plugins comunes por sus endpoints conocidos
echo "🔍 VERIFICANDO PLUGINS ADICIONALES:"
echo "==================================="

# SEO Plugins
check_plugin "Yoast SEO" "api" "yoast/v1/indexables"
yoast_status=$?

check_plugin "RankMath" "api" "rankmath/v1/getHead"  
rankmath_status=$?

# Cache plugins (por headers específicos)
check_plugin "Cache Plugin" "header" "x-cache\|x-rocket\|x-litespeed"
cache_status=$?

echo ""

# Verificar archivos específicos de plugins conocidos
echo "🔍 VERIFICANDO ARCHIVOS DE PLUGINS:"
echo "==================================="

# Archivos típicos de plugins comunes
plugin_files=(
    "wp-content/plugins/polylang/polylang.php"
    "wp-content/plugins/wordpress-seo/wp-seo.php"
    "wp-content/plugins/seo-by-rank-math/rank-math.php"
    "wp-content/plugins/wp-rocket/wp-rocket.php"
    "wp-content/plugins/elementor/elementor.php"
    "wp-content/plugins/contact-form-7/wp-contact-form-7.php"
)

for plugin_file in "${plugin_files[@]}"; do
    plugin_name=$(basename "$plugin_file" .php)
    status_code=$(curl -s -o /dev/null -w "%{http_code}" "$STAGING_URL/$plugin_file")
    
    if [[ "$status_code" == "200" ]]; then
        echo "   ✅ $plugin_name: Archivo principal encontrado"
    elif [[ "$status_code" == "403" ]]; then
        echo "   ⚠️  $plugin_name: Archivo existe pero protegido (probable instalado)"
    else
        echo "   ❌ $plugin_name: No encontrado ($status_code)"
    fi
done

echo ""

# Verificar MU-plugins (más difícil de detectar)
echo "🔍 VERIFICANDO MU-PLUGINS:"
echo "=========================="

# Los MU-plugins son más difíciles de detectar externamente
# Pero podemos buscar evidencias específicas del proyecto

# Verificar endpoints específicos del proyecto RunArt Foundry
project_endpoints=(
    "wp-json/runart/v1/status"
    "wp-json/briefing/v1/status"  
    "wp-content/mu-plugins/runart-endpoints.php"
)

for endpoint in "${project_endpoints[@]}"; do
    status_code=$(curl -s -o /dev/null -w "%{http_code}" "$STAGING_URL/$endpoint")
    
    if [[ "$status_code" == "200" ]]; then
        echo "   ✅ MU-plugin proyecto: Endpoint $endpoint activo"
    elif [[ "$status_code" == "403" ]]; then
        echo "   ⚠️  MU-plugin proyecto: $endpoint protegido (posible instalado)"
    else
        echo "   ❌ MU-plugin proyecto: $endpoint no encontrado"
    fi
done

echo ""

# Resumen y clasificación
echo "📊 RESUMEN DE DETECCIÓN:"
echo "========================"

echo ""
echo "🟢 CONFIRMADOS ACTIVOS:"
if [[ $polylang_active -eq 1 ]]; then
    echo "   ✅ Polylang - IMPRESCINDIBLE (Motor i18n ES/EN)"
fi

echo ""
echo "🟡 DETECTADOS (requieren verificación manual):"
# Aquí listaríamos plugins que mostraron evidencias indirectas

echo ""
echo "🔴 NO DETECTADOS (probablemente no instalados):"
echo "   - Elementor/Page Builders"
echo "   - Contact Form 7"
echo "   - WP Rocket (cache)"

echo ""

# Crear plan de acción basado en detección
echo "🎯 PLAN DE ACCIÓN BASADO EN DETECCIÓN:"
echo "======================================"

echo ""
echo "FASE 1: BACKUP PREVENTIVO"
echo "- Crear backup de base de datos staging"
echo "- Respaldar directorio wp-content/plugins"
echo "- Documentar estado actual"

echo ""
echo "FASE 2: CLASIFICACIÓN DEFINITIVA"
echo "- Acceder a wp-admin/plugins.php para lista completa"
echo "- Verificar dependencias y shortcodes en uso"
echo "- Confirmar plugins realmente necesarios"

echo ""
echo "FASE 3: DEPURACIÓN CONTROLADA"
echo "A. MANTENER (no tocar):"
if [[ $polylang_active -eq 1 ]]; then
    echo "   ✅ Polylang - Motor i18n confirmado activo"
fi
echo "   ✅ GeneratePress Child - Tema base"

echo ""
echo "B. EVALUAR (desactivar temporalmente y probar):"
if [[ $yoast_status -eq 0 ]] || [[ $rankmath_status -eq 0 ]]; then
    echo "   📈 Plugin SEO detectado - Evaluar si se usa en Fase 3"
fi
if [[ $cache_status -eq 0 ]]; then
    echo "   ⚡ Plugin Cache detectado - Verificar configuración"
fi

echo ""
echo "C. ELIMINAR (candidatos seguros):"
echo "   🏗️  Page Builders (Elementor, etc.) - No detectados"
echo "   📦 Importers/Migrators - Posiblemente ya utilizados"
echo "   🛒 E-commerce plugins - Fuera de alcance i18n"

echo ""
echo "💡 SIGUIENTE ACCIÓN RECOMENDADA:"
echo "1. Crear backup preventivo completo"
echo "2. Acceder a wp-admin para inventario detallado"
echo "3. Desactivar plugins no esenciales uno por uno"
echo "4. Validar funcionamiento después de cada cambio"

echo ""
echo "⚠️  CRITERIO DE SEGURIDAD:"
echo "- NO tocar Polylang (confirmado esencial)"
echo "- NO eliminar hasta confirmar que no hay shortcodes activos"
echo "- Probar sitio ES/EN después de cada cambio"
echo "- Rollback inmediato si algo falla"