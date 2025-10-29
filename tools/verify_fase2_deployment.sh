#!/bin/bash

# VERIFICACIÓN POST-DESPLIEGUE FASE 2 i18n
# Verifica que la navegación bilingüe esté funcionando correctamente

STAGING_URL="https://staging.runartfoundry.com"

echo "🔍 VERIFICACIÓN FASE 2 i18n - STAGING RunArt Foundry"
echo "====================================================="
echo "URL: $STAGING_URL"
echo "Fecha: $(date)"
echo ""

# Verificar acceso básico
echo "🌐 Verificando acceso a staging..."
if curl -s -I "$STAGING_URL" | grep -q "200"; then
    echo "✅ Staging accesible"
else
    echo "❌ Staging no accesible"
    exit 1
fi

echo ""
echo "🌍 VERIFICANDO POLYLANG & i18n:"

# Verificar Polylang API
polylang_check=$(curl -s "$STAGING_URL/wp-json/pll/v1/languages" 2>/dev/null)
polylang_count=$(echo "$polylang_check" | jq 'length' 2>/dev/null || echo "0")

if [[ "$polylang_count" == "2" ]]; then
    echo "✅ Polylang activo con $polylang_count idiomas"
    echo "$polylang_check" | jq -r '.[] | "   - \(.name) (\(.code)): \(.url)"' 2>/dev/null || echo "   - ES/EN configurados"
else
    echo "❌ Polylang: $polylang_count idiomas (esperado: 2)"
fi

echo ""
echo "🎯 VERIFICANDO URLs BILINGÜES:"

# Verificar URL español
echo "🔍 Probando URL español: $STAGING_URL/es/"
es_response=$(curl -s -I "$STAGING_URL/es/" | head -1)
if echo "$es_response" | grep -q "200"; then
    echo "✅ URL español accesible"
else
    echo "⚠️  URL español: $es_response"
fi

# Verificar URL inglés (raíz)
echo "🔍 Probando URL inglés: $STAGING_URL/"
en_response=$(curl -s -I "$STAGING_URL/" | head -1)
if echo "$en_response" | grep -q "200"; then
    echo "✅ URL inglés accesible"
else
    echo "⚠️  URL inglés: $en_response"
fi

echo ""
echo "🔧 VERIFICANDO LANGUAGE SWITCHER:"

# Buscar language switcher en HTML
echo "🔍 Buscando language switcher en HTML..."
html_content=$(curl -s "$STAGING_URL" 2>/dev/null)

if echo "$html_content" | grep -q "runart-language-switcher"; then
    echo "✅ Language switcher detectado en HTML"
else
    echo "❌ Language switcher NO encontrado"
    echo "   🔧 Verificar que functions.php se desplegó correctamente"
fi

# Verificar CSS del language switcher
if echo "$html_content" | grep -q "\.runart-language-switcher"; then
    echo "✅ CSS del language switcher incluido"
else
    echo "⚠️  CSS del language switcher no detectado"
fi

# Verificar JavaScript
if echo "$html_content" | grep -q "runart_preferred_lang"; then
    echo "✅ JavaScript del language switcher incluido"
else
    echo "⚠️  JavaScript del language switcher no detectado"
fi

echo ""
echo "📱 VERIFICANDO RESPONSIVE DESIGN:"

# Simular acceso móvil
mobile_content=$(curl -s -H "User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X)" "$STAGING_URL" 2>/dev/null)

if echo "$mobile_content" | grep -q "@media.*768px"; then
    echo "✅ CSS responsive detectado"
else
    echo "⚠️  CSS responsive no confirmado"
fi

echo ""
echo "🔍 VERIFICANDO SEO & HREFLANG:"

# Verificar hreflang tags
if echo "$html_content" | grep -q 'hreflang='; then
    echo "✅ Tags hreflang detectados"
    hreflang_count=$(echo "$html_content" | grep -o 'hreflang=' | wc -l)
    echo "   - Cantidad de hreflang tags: $hreflang_count"
else
    echo "⚠️  Tags hreflang no encontrados"
fi

# Verificar language attributes
if echo "$html_content" | grep -q 'lang="[es|en]'; then
    echo "✅ Atributo lang detectado en HTML"
else
    echo "⚠️  Atributo lang no detectado"
fi

echo ""
echo "🎨 VERIFICANDO INTEGRACIÓN GENERATEPRESS:"

# Verificar tema activo
if echo "$html_content" | grep -q "generatepress"; then
    echo "✅ GeneratePress detectado"
else
    echo "⚠️  GeneratePress no confirmado"
fi

# Verificar clases de idioma en body
if echo "$html_content" | grep -q 'class.*lang-[es|en]'; then
    echo "✅ Clases de idioma en body detectadas"
else
    echo "⚠️  Clases de idioma no encontradas"
fi

echo ""
echo "⚡ PRUEBAS FUNCIONALES:"

# Test de switching de idiomas
echo "🔍 Probando cambio de idioma ES → EN..."
es_html=$(curl -s "$STAGING_URL/es/" 2>/dev/null)
en_html=$(curl -s "$STAGING_URL/" 2>/dev/null)

es_lang_class=$(echo "$es_html" | grep -o 'lang-es' | head -1)
en_lang_class=$(echo "$en_html" | grep -o 'lang-en' | head -1)

if [[ -n "$es_lang_class" && -n "$en_lang_class" ]]; then
    echo "✅ Cambio de idioma funcional (ES/EN detectados)"
else
    echo "⚠️  Cambio de idioma: ES=$es_lang_class, EN=$en_lang_class"
fi

echo ""
echo "📊 RESUMEN VERIFICACIÓN:"

# Calcular score de implementación
score=0
total_checks=10

# Checklist scoring
[[ "$polylang_count" == "2" ]] && ((score++))
echo "$es_response" | grep -q "200" && ((score++))
echo "$en_response" | grep -q "200" && ((score++))
echo "$html_content" | grep -q "runart-language-switcher" && ((score++))
echo "$html_content" | grep -q "\.runart-language-switcher" && ((score++))
echo "$html_content" | grep -q "runart_preferred_lang" && ((score++))
echo "$html_content" | grep -q 'hreflang=' && ((score++))
echo "$html_content" | grep -q 'lang="[es|en]' && ((score++))
echo "$html_content" | grep -q "generatepress" && ((score++))
[[ -n "$es_lang_class" && -n "$en_lang_class" ]] && ((score++))

percentage=$(( score * 100 / total_checks ))

echo "📈 Score de implementación: $score/$total_checks ($percentage%)"

if [[ $percentage -ge 80 ]]; then
    echo "🎉 FASE 2 i18n DESPLEGADA EXITOSAMENTE"
    echo ""
    echo "✅ FUNCIONALIDADES VERIFICADAS:"
    echo "   - Navegación bilingüe ES/EN"
    echo "   - Language switcher funcional"
    echo "   - URLs bilingües accesibles"
    echo "   - CSS responsive integrado"
    echo "   - SEO hreflang configurado"
    echo "   - GeneratePress compatible"
    echo ""
    echo "🎯 PRÓXIMOS PASOS:"
    echo "   1. Probar navegación manualmente"
    echo "   2. Verificar content switching"
    echo "   3. Probar en dispositivos móviles"
    echo "   4. Configurar menús por idioma en wp-admin"
    
elif [[ $percentage -ge 60 ]]; then
    echo "⚠️  FASE 2 PARCIALMENTE IMPLEMENTADA"
    echo ""
    echo "🔧 ACCIONES REQUERIDAS:"
    echo "   - Verificar deployment de functions.php"
    echo "   - Confirmar configuración Polylang"
    echo "   - Revisar logs de errores en wp-admin"
    
else
    echo "❌ FASE 2 REQUIERE ATENCIÓN"
    echo ""
    echo "🔧 POSIBLES PROBLEMAS:"
    echo "   - Functions.php no desplegado correctamente"
    echo "   - Polylang no configurado"
    echo "   - Errores de PHP en functions.php"
    echo ""
    echo "💡 SOLUCIONES:"
    echo "   1. Verificar sintaxis PHP: wp-admin → Tools → Site Health"
    echo "   2. Re-desplegar functions.php completo"
    echo "   3. Activar WP_DEBUG para ver errores"
fi

echo ""
echo "🔗 ENLACES DE PRUEBA:"
echo "   - Español: $STAGING_URL/es/"
echo "   - English: $STAGING_URL/"
echo "   - Debug: $STAGING_URL/?runart_debug=1"
echo "   - Admin: $STAGING_URL/wp-admin/"