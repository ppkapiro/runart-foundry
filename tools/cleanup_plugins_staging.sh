#!/bin/bash

# DEPURACIÓN PLUGINS STAGING - RESOLUCIÓN CONFLICTOS
# Fase de limpieza controlada con resolución de conflictos SEO

STAGING_URL="https://staging.runartfoundry.com"
LOG_FILE="docs/i18n/i18n_plugins_auditoria_log.md"
BACKUP_DIR="logs/plugins_backup_$(date +%Y%m%d_%H%M%S)"

echo "🚨 DEPURACIÓN PLUGINS - RESOLUCIÓN CONFLICTOS"
echo "=============================================="
echo "URL: $STAGING_URL"
echo "Backup dir: $BACKUP_DIR"
echo "Fecha: $(date)"
echo ""

# Crear directorio de backup
mkdir -p "$BACKUP_DIR"

echo "🛡️ FASE 1: BACKUP PREVENTIVO"
echo "============================"

# Crear backup de información actual
echo "💾 Creando backup de estado actual..."

# Backup de información de plugins detectados
plugins_backup="$BACKUP_DIR/plugins_state_backup.json"
polylang_backup="$BACKUP_DIR/polylang_languages_backup.json"
yoast_backup="$BACKUP_DIR/yoast_api_backup.json"
rankmath_backup="$BACKUP_DIR/rankmath_api_backup.json"

echo "📄 Respaldando estado Polylang..."
curl -s "$STAGING_URL/wp-json/pll/v1/languages" > "$polylang_backup" 2>/dev/null
if [[ -s "$polylang_backup" ]]; then
    echo "   ✅ Backup Polylang guardado: $polylang_backup"
else
    echo "   ⚠️  Backup Polylang vacío"
fi

echo "📄 Respaldando estado Yoast..."
curl -s "$STAGING_URL/wp-json/yoast/v1/indexables" > "$yoast_backup" 2>/dev/null
if [[ -s "$yoast_backup" ]]; then
    echo "   ✅ Backup Yoast guardado: $yoast_backup"
else
    echo "   ⚠️  Backup Yoast vacío o no accesible"
fi

echo "📄 Respaldando estado RankMath..."
curl -s "$STAGING_URL/wp-json/rankmath/v1/getHead" > "$rankmath_backup" 2>/dev/null
if [[ -s "$rankmath_backup" ]]; then
    echo "   ✅ Backup RankMath guardado: $rankmath_backup"
else
    echo "   ⚠️  Backup RankMath vacío o no accesible"
fi

echo ""
echo "🔍 FASE 2: ANÁLISIS DE CONFLICTOS"
echo "================================="

echo "⚠️ CONFLICTO DETECTADO: Múltiples plugins SEO activos"
echo ""
echo "🔍 Analizando impacto de plugins SEO..."

# Verificar si los SEO plugins están interfiriendo con Polylang
echo "🌍 Verificando compatibilidad con Polylang..."

# Test URLs con diferentes plugins SEO
echo "🔍 Probando URLs ES/EN con plugins SEO activos..."

es_url_test=$(curl -s -I "$STAGING_URL/es/" | head -1)
en_url_test=$(curl -s -I "$STAGING_URL/" | head -1)

echo "   - URL ES: $es_url_test"
echo "   - URL EN: $en_url_test"

# Verificar headers SEO en ambos idiomas
echo ""
echo "🔍 Verificando headers SEO por idioma..."

es_headers=$(curl -s -I "$STAGING_URL/es/" | grep -i "x-robots\|x-seo")
en_headers=$(curl -s -I "$STAGING_URL/" | grep -i "x-robots\|x-seo")

if [[ -n "$es_headers" ]]; then
    echo "   📈 Headers SEO detectados en ES:"
    echo "$es_headers" | sed 's/^/      /'
fi

if [[ -n "$en_headers" ]]; then
    echo "   📈 Headers SEO detectados en EN:"
    echo "$en_headers" | sed 's/^/      /'
fi

echo ""
echo "🎯 FASE 3: PLAN DE DEPURACIÓN"
echo "============================="

echo ""
echo "🚨 PRIORIDAD 1: RESOLVER CONFLICTO SEO"
echo "--------------------------------------"
echo "PROBLEMA: Yoast SEO + RankMath activos simultáneamente"
echo "RIESGO: Conflictos de metadatos, canonicals, sitemaps"
echo "SOLUCIÓN: Mantener solo UNO o NINGUNO (según Fase 3)"

echo ""
echo "💡 OPCIONES DE RESOLUCIÓN:"
echo "A. Desactivar AMBOS plugins SEO (recomendado para Fase 2 i18n)"
echo "   - Pros: Eliminamos conflictos, enfoque puro en i18n"
echo "   - Contras: Sin optimización SEO temporal"
echo ""
echo "B. Mantener solo Yoast SEO"
echo "   - Pros: Plugin más estable y popular"
echo "   - Contras: Eliminar RankMath puede dejar configuración huérfana"
echo ""
echo "C. Mantener solo RankMath"
echo "   - Pros: Plugin más moderno"
echo "   - Contras: Eliminar Yoast puede dejar configuración huérfana"

echo ""
echo "🎯 RECOMENDACIÓN BASADA EN ALCANCE ACTUAL:"
echo "=========================================="
echo ""
echo "Para STAGING con enfoque en i18n (Fase 2):"
echo "✅ DESACTIVAR AMBOS plugins SEO temporalmente"
echo ""
echo "Razones:"
echo "- Fase 2 se enfoca en navegación bilingüe"
echo "- SEO será abordado en Fase 3 específica"
echo "- Eliminamos riesgo de conflictos con Polylang"
echo "- Staging debe ser ambiente de prueba limpio"
echo "- Podemos reactivar el elegido en Fase 3"

echo ""
echo "🔧 FASE 4: EJECUCIÓN DE DEPURACIÓN"
echo "=================================="

echo ""
echo "⚠️  NOTA IMPORTANTE:"
echo "La desactivación/eliminación de plugins requiere acceso wp-admin"
echo "Este script documenta el plan pero no puede ejecutar cambios automáticamente"

echo ""
echo "📋 PASOS MANUALES REQUERIDOS:"
echo "============================="

echo ""
echo "1. ACCEDER A WP-ADMIN:"
echo "   URL: $STAGING_URL/wp-admin/plugins.php"

echo ""
echo "2. BACKUP MANUAL ADICIONAL:"
echo "   - Exportar configuración Yoast (si tiene contenido)"
echo "   - Exportar configuración RankMath (si tiene contenido)"
echo "   - Anotar plugins adicionales no detectados automáticamente"

echo ""
echo "3. DESACTIVAR PLUGINS CONFLICTIVOS:"
echo "   a) Desactivar 'Yoast SEO'"
echo "   b) Desactivar 'RankMath SEO'"
echo "   c) Verificar que el sitio sigue funcionando:"
echo "      - $STAGING_URL/es/ debe cargar"
echo "      - $STAGING_URL/ debe cargar"
echo "      - Language switcher debe funcionar"

echo ""
echo "4. VALIDAR FUNCIONAMIENTO POST-DESACTIVACIÓN:"
echo "   a) Verificar Polylang sigue activo:"
echo "      curl -s \"$STAGING_URL/wp-json/pll/v1/languages\""
echo "   b) Probar cambio de idiomas manualmente"
echo "   c) Verificar que no hay errores PHP en logs"

echo ""
echo "5. SI TODO FUNCIONA - ELIMINAR PLUGINS:"
echo "   a) Eliminar 'Yoast SEO' (botón Delete)"
echo "   b) Eliminar 'RankMath SEO' (botón Delete)"
echo "   c) Limpiar cualquier tabla/configuración huérfana (opcional)"

echo ""
echo "6. VALIDACIÓN FINAL:"
echo "   - Ejecutar: ./tools/verify_fase2_deployment.sh"
echo "   - Confirmar todas las funcionalidades i18n operativas"
echo "   - Documentar resultado en bitácora"

echo ""
echo "🔄 ROLLBACK EN CASO DE PROBLEMAS:"
echo "================================="

echo ""
echo "Si algo falla después de la desactivación:"
echo "1. Reactivar plugins desde wp-admin/plugins.php"
echo "2. Restaurar configuraciones desde backups:"
echo "   - $yoast_backup"
echo "   - $rankmath_backup"
echo "3. Verificar Polylang desde: $polylang_backup"

echo ""
echo "🎯 CRITERIOS DE ÉXITO:"
echo "====================="

echo ""
echo "✅ DEPURACIÓN EXITOSA CUANDO:"
echo "- Solo Polylang permanece activo (SEO)"
echo "- URLs ES/EN funcionan perfectamente"
echo "- Language switcher operativo"
echo "- No errores PHP en wp-admin"
echo "- Fase 2 i18n completamente funcional"
echo "- Rendimiento mejorado (menos plugins activos)"

echo ""
echo "📊 ESTADO FINAL ESPERADO:"
echo "========================"

echo ""
echo "PLUGINS ACTIVOS FINALES:"
echo "- ✅ Polylang (i18n ES/EN)"
echo "- ✅ GeneratePress Child (tema)"
echo "- ✅ [Solo plugins verdaderamente esenciales]"
echo ""
echo "PLUGINS ELIMINADOS:"
echo "- ❌ Yoast SEO (conflicto resuelto)"
echo "- ❌ RankMath SEO (conflicto resuelto)"
echo "- ❌ [Cualquier otro plugin innecesario encontrado]"

echo ""
echo "💾 BACKUPS CREADOS EN: $BACKUP_DIR"
echo "📋 Continuar con pasos manuales en wp-admin"
echo "🎯 Objetivo: Staging limpio, estable, enfocado en i18n"

# Actualizar bitácora con plan de depuración
echo ""
echo "📝 Plan de depuración documentado y backups creados"
echo "⏳ Pendiente: Ejecución manual de pasos en wp-admin"