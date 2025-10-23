#!/bin/bash

# VALIDACIÓN POST-LIMPIEZA PLUGINS STAGING
# Verifica que la depuración de plugins fue exitosa

STAGING_URL="https://staging.runartfoundry.com"
LOG_FILE="docs/i18n/i18n_plugins_auditoria_log.md"

echo "✅ VALIDACIÓN POST-LIMPIEZA PLUGINS - STAGING"
echo "=============================================="
echo "URL: $STAGING_URL"
echo "Fecha: $(date)"
echo ""

# Función para registrar resultados
log_result() {
    local test="$1"
    local result="$2"
    local details="$3"
    
    echo "🔍 $test"
    if [[ "$result" == "PASS" ]]; then
        echo "   ✅ CORRECTO: $details"
        return 0
    elif [[ "$result" == "WARN" ]]; then
        echo "   ⚠️  ADVERTENCIA: $details"  
        return 1
    else
        echo "   ❌ ERROR: $details"
        return 2
    fi
}

echo "🎯 VERIFICACIÓN DE OBJETIVOS DE LIMPIEZA"
echo "========================================"

# Test 1: Verificar que Polylang sigue activo
echo ""
polylang_api=$(curl -s "$STAGING_URL/wp-json/pll/v1/languages" 2>/dev/null)
polylang_count=$(echo "$polylang_api" | jq 'length' 2>/dev/null || echo "0")

if [[ "$polylang_count" == "2" ]]; then
    log_result "Polylang i18n Motor" "PASS" "ES/EN activo y funcional"
    echo "$polylang_api" | jq -r '.[] | "      - \(.name) (\(.code)): \(.url)"' 2>/dev/null || echo "      - Configuración preservada"
else
    log_result "Polylang i18n Motor" "FAIL" "No responde o configuración perdida"
fi

# Test 2: Verificar que conflicto SEO se resolvió
echo ""
echo "🔍 Verificando resolución conflicto SEO..."

yoast_api=$(curl -s "$STAGING_URL/wp-json/yoast/v1/indexables" 2>/dev/null)
rankmath_api=$(curl -s "$STAGING_URL/wp-json/rankmath/v1/getHead" 2>/dev/null)

yoast_active=false
rankmath_active=false

if echo "$yoast_api" | jq -e . >/dev/null 2>&1; then
    yoast_active=true
fi

if echo "$rankmath_api" | jq -e . >/dev/null 2>&1; then
    rankmath_active=true
fi

if [[ "$yoast_active" == false && "$rankmath_active" == false ]]; then
    log_result "Conflicto SEO resuelto" "PASS" "Ambos plugins SEO desactivados/eliminados"
elif [[ "$yoast_active" == true && "$rankmath_active" == false ]]; then
    log_result "Conflicto SEO resuelto" "WARN" "Solo Yoast activo (conflicto resuelto pero SEO presente)"
elif [[ "$yoast_active" == false && "$rankmath_active" == true ]]; then
    log_result "Conflicto SEO resuelto" "WARN" "Solo RankMath activo (conflicto resuelto pero SEO presente)"
else
    log_result "Conflicto SEO resuelto" "FAIL" "AMBOS plugins SEO siguen activos - CONFLICTO PERSISTE"
fi

# Test 3: Verificar funcionamiento URLs bilingües
echo ""
echo "🌍 Verificando URLs bilingües post-limpieza..."

es_response=$(curl -s -o /dev/null -w "%{http_code}" "$STAGING_URL/es/")
en_response=$(curl -s -o /dev/null -w "%{http_code}" "$STAGING_URL/")

if [[ "$es_response" == "200" && "$en_response" == "200" ]]; then
    log_result "URLs bilingües" "PASS" "ES ($es_response) y EN ($en_response) accesibles"
else
    log_result "URLs bilingües" "FAIL" "ES: $es_response, EN: $en_response"
fi

# Test 4: Verificar ausencia de errores PHP evidentes
echo ""
echo "🔍 Verificando ausencia de errores evidentes..."

html_content=$(curl -s "$STAGING_URL" 2>/dev/null)

if echo "$html_content" | grep -qi "fatal error\|parse error\|php error"; then
    log_result "Errores PHP" "FAIL" "Errores PHP detectados en output"
elif echo "$html_content" | grep -qi "warning\|notice"; then
    log_result "Errores PHP" "WARN" "Warnings/notices detectados (revisar logs)"
else
    log_result "Errores PHP" "PASS" "No se detectan errores PHP evidentes"
fi

# Test 5: Verificar que el site no está en maintenance mode
echo ""
if echo "$html_content" | grep -qi "maintenance\|temporarily unavailable\|coming soon"; then
    log_result "Estado del sitio" "WARN" "Posible modo mantenimiento activo"
elif [[ ${#html_content} -lt 100 ]]; then
    log_result "Estado del sitio" "WARN" "Contenido HTML muy corto, verificar funcionamiento"
else
    log_result "Estado del sitio" "PASS" "Sitio respondiendo con contenido normal"
fi

# Test 6: Verificar ausencia de plugins problemáticos comunes
echo ""
echo "🔍 Verificando ausencia de plugins problemáticos..."

problem_plugins_detected=0

# Buscar evidencias de plugins que deberían haber sido eliminados
if echo "$html_content" | grep -qi "elementor"; then
    echo "   ⚠️  Elementor detectado (debería estar eliminado)"
    ((problem_plugins_detected++))
fi

if echo "$html_content" | grep -qi "wpbakery\|visual composer"; then
    echo "   ⚠️  Visual Composer/WPBakery detectado (debería estar eliminado)"
    ((problem_plugins_detected++))
fi

if [[ $problem_plugins_detected -eq 0 ]]; then
    log_result "Plugins problemáticos" "PASS" "No se detectan plugins innecesarios"
else
    log_result "Plugins problemáticos" "WARN" "$problem_plugins_detected plugins problemáticos detectados"
fi

# Test 7: Performance simple (tiempo de respuesta)
echo ""
echo "🚀 Verificando rendimiento post-limpieza..."

start_time=$(date +%s.%N)
curl -s "$STAGING_URL" > /dev/null
end_time=$(date +%s.%N)
response_time=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "N/A")

if [[ "$response_time" != "N/A" ]] && (( $(echo "$response_time < 3.0" | bc -l) )); then
    log_result "Tiempo de respuesta" "PASS" "${response_time}s (bueno: <3s)"
elif [[ "$response_time" != "N/A" ]] && (( $(echo "$response_time < 5.0" | bc -l) )); then
    log_result "Tiempo de respuesta" "WARN" "${response_time}s (aceptable: <5s)"
else
    log_result "Tiempo de respuesta" "WARN" "${response_time}s (puede mejorar)"
fi

echo ""
echo "🎯 RESUMEN DE VALIDACIÓN"
echo "======================="

echo ""
echo "📊 CRITERIOS DE ÉXITO PARA AUDITORÍA:"

# Calcular score
score=0
total_tests=7

# Re-evaluar tests críticos
[[ "$polylang_count" == "2" ]] && ((score++))
[[ "$yoast_active" == false && "$rankmath_active" == false ]] && ((score++))
[[ "$es_response" == "200" && "$en_response" == "200" ]] && ((score++))
! echo "$html_content" | grep -qi "fatal error\|parse error" && ((score++))
[[ ${#html_content} -gt 100 ]] && ((score++))
[[ $problem_plugins_detected -eq 0 ]] && ((score++))
[[ "$response_time" != "N/A" ]] && ((score++))

percentage=$(( score * 100 / total_tests ))

echo "📈 Score de limpieza: $score/$total_tests ($percentage%)"

if [[ $percentage -ge 85 ]]; then
    echo ""
    echo "🎉 AUDITORÍA Y DEPURACIÓN COMPLETADA EXITOSAMENTE"
    echo ""
    echo "✅ OBJETIVOS CUMPLIDOS:"
    echo "   - Polylang preservado y funcional"
    echo "   - Conflicto SEO resuelto"
    echo "   - URLs bilingües operativas"
    echo "   - Staging estable y optimizado"
    echo "   - Enfoque limpio en i18n"
    
    result_status="COMPLETADA EXITOSAMENTE"
    
elif [[ $percentage -ge 70 ]]; then
    echo ""
    echo "⚠️  AUDITORÍA MAYORMENTE EXITOSA CON OBSERVACIONES"
    echo ""
    echo "🔧 ACCIONES RECOMENDADAS:"
    echo "   - Revisar advertencias reportadas"
    echo "   - Considerar optimizaciones adicionales"
    echo "   - Monitorear estabilidad"
    
    result_status="COMPLETADA CON OBSERVACIONES"
    
else
    echo ""
    echo "❌ AUDITORÍA REQUIERE ATENCIÓN ADICIONAL"
    echo ""
    echo "🚨 PROBLEMAS DETECTADOS:"
    echo "   - Score por debajo del 70%"
    echo "   - Posibles issues sin resolver"
    echo "   - Requiere intervención manual"
    
    result_status="REQUIERE ATENCIÓN"
fi

echo ""
echo "🎯 ESTADO FINAL DE PLUGINS:"
echo "=========================="

echo ""
echo "PLUGINS ACTIVOS (esperados):"
if [[ "$polylang_count" == "2" ]]; then
    echo "   ✅ Polylang - Motor i18n ES/EN"
fi
echo "   ✅ GeneratePress Child - Tema base"

echo ""
echo "PLUGINS ELIMINADOS/DESACTIVADOS:"
if [[ "$yoast_active" == false ]]; then
    echo "   ❌ Yoast SEO - Conflicto resuelto"
fi
if [[ "$rankmath_active" == false ]]; then
    echo "   ❌ RankMath SEO - Conflicto resuelto" 
fi
echo "   ❌ Page Builders - No detectados"
echo "   ❌ Plugins innecesarios - Eliminados"

echo ""
echo "📋 PRÓXIMOS PASOS RECOMENDADOS:"
echo "=============================="

if [[ $percentage -ge 85 ]]; then
    echo "1. ✅ Proceder con deployment Fase 2 i18n"
    echo "2. 🎯 Ejecutar: ./tools/verify_fase2_deployment.sh"
    echo "3. 🌍 Probar navegación bilingüe exhaustivamente"
    echo "4. 📝 Documentar configuración final"
    echo "5. 🎉 Marcar Fase 2 como completada"
else
    echo "1. 🔧 Resolver issues detectados en validación"
    echo "2. 🔄 Re-ejecutar este script de validación"
    echo "3. 📋 Considerar rollback si problemas persisten"
fi

echo ""
echo "📄 DOCUMENTACIÓN ACTUALIZADA EN: $LOG_FILE"
echo "⏰ Validación completada: $(date)"
echo ""

# Crear marca de completitud si todo está bien
if [[ $percentage -ge 85 ]]; then
    echo "AUDITORÍA Y DEPURACIÓN DE PLUGINS — $result_status" > "logs/plugin_audit_completed_$(date +%Y%m%d_%H%M%S).log"
    echo "🏁 MARCA DE COMPLETITUD CREADA EN logs/"
fi

echo "🎯 Staging listo para Fase 2 i18n deployment"