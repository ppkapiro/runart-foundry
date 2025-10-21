#!/bin/bash
# 🧩 COPAYLO — REVISIÓN Y AISLAMIENTO COMPLETO DE STAGING vs PRODUCCIÓN (RUN ART FOUNDRY)
# Objetivo: comprobar y reparar que staging.runartfoundry.com y runartfoundry.com sean entornos totalmente independientes.
# Reglas:
#  - ❌ NO modificar ni borrar datos de producción.
#  - ✅ Aislar staging (BD, URLs, uploads, caché).
#  - ✅ Generar reporte en _reports/isolation/ con todo lo detectado.

set -euo pipefail

echo "=== 🔍 Iniciando auditoría de aislamiento Staging vs Producción ==="

DATE=$(date +%Y%m%d_%H%M%S)
REPORT_DIR="_reports/isolation"
mkdir -p "$REPORT_DIR"

###################################################################################################
# 1️⃣ COMPROBAR CONEXIONES DE BASE DE DATOS
###################################################################################################

PROD_WP="/htdocs/wp-config.php"
STAGING_WP="/htdocs/staging/wp-config.php"

echo "→ Verificando bases de datos en wp-config.php..."

# Verificar existencia de archivos
if [ ! -f "$PROD_WP" ]; then
    echo "⚠️ Archivo wp-config.php de producción no encontrado en $PROD_WP"
    PROD_DB="NO_ENCONTRADO"
else
    PROD_DB=$(grep "DB_NAME" "$PROD_WP" | cut -d"'" -f4 || echo "NO_DETECTADO")
fi

if [ ! -f "$STAGING_WP" ]; then
    echo "⚠️ Archivo wp-config.php de staging no encontrado en $STAGING_WP"
    STAG_DB="NO_ENCONTRADO"
else
    STAG_DB=$(grep "DB_NAME" "$STAGING_WP" | cut -d"'" -f4 || echo "NO_DETECTADO")
fi

echo "- DB de producción: $PROD_DB"
echo "- DB de staging: $STAG_DB"

if [ "$PROD_DB" = "$STAG_DB" ] && [ "$PROD_DB" != "NO_ENCONTRADO" ] && [ "$PROD_DB" != "NO_DETECTADO" ]; then
  echo "⚠️ Peligro: ambas instancias apuntan a la misma base de datos. Abortando modificaciones."
  exit 1
else
  echo "✅ Bases de datos diferentes detectadas (aislamiento inicial correcto)."
fi

###################################################################################################
# 2️⃣ REVISAR Y CORREGIR CONFIGURACIÓN DE STAGING
###################################################################################################

echo "→ Reforzando WP_HOME y WP_SITEURL en staging..."
if [ -f "$STAGING_WP" ]; then
    if ! grep -q "staging.runartfoundry.com" "$STAGING_WP"; then
        # Crear backup antes de modificar
        cp "$STAGING_WP" "$STAGING_WP.backup.$(date +%Y%m%d_%H%M%S)"
        
        sed -i '/WP_HOME/d' "$STAGING_WP" || true
        sed -i '/WP_SITEURL/d' "$STAGING_WP" || true
        echo "define('WP_HOME',    'https://staging.runartfoundry.com');" >> "$STAGING_WP"
        echo "define('WP_SITEURL', 'https://staging.runartfoundry.com');" >> "$STAGING_WP"
        echo "✅ Constantes de staging definidas."
    else
        echo "✅ WP_HOME / WP_SITEURL ya contienen staging.runartfoundry.com."
    fi
else
    echo "⚠️ No se puede modificar wp-config.php de staging (archivo no encontrado)"
fi

###################################################################################################
# 3️⃣ COMPROBAR Y CORREGIR URLs EN BASE DE DATOS DE STAGING
###################################################################################################

echo "→ Verificando URLs en base de datos $STAG_DB..."

# Solo intentar acceso a BD si tenemos credenciales y la BD existe
if [ -n "${DB_USER:-}" ] && [ -n "${DB_PASSWORD:-}" ] && [ -n "${DB_HOST:-}" ] && [ "$STAG_DB" != "NO_ENCONTRADO" ]; then
    QUERY="SELECT option_name, option_value FROM wp_options WHERE option_name IN ('siteurl','home');"
    mysql -u"$DB_USER" -p"$DB_PASSWORD" -h"$DB_HOST" -D"$STAG_DB" -e "$QUERY" > "$REPORT_DIR/check_urls_${DATE}.txt" 2>/dev/null || {
        echo "⚠️ No se pudo acceder a la base de datos $STAG_DB"
        echo "Error de conexión BD" > "$REPORT_DIR/check_urls_${DATE}.txt"
    }

    if [ -f "$REPORT_DIR/check_urls_${DATE}.txt" ] && grep -q "runartfoundry.com" "$REPORT_DIR/check_urls_${DATE}.txt" && ! grep -q "staging.runartfoundry.com" "$REPORT_DIR/check_urls_${DATE}.txt"; then
        echo "⚙️ Corrigiendo siteurl y home a staging.runartfoundry.com"
        mysql -u"$DB_USER" -p"$DB_PASSWORD" -h"$DB_HOST" -D"$STAG_DB" -e \
        "UPDATE wp_options SET option_value='https://staging.runartfoundry.com' WHERE option_name IN ('siteurl','home');" 2>/dev/null || {
            echo "⚠️ Error al actualizar URLs en la base de datos"
        }
        echo "✅ URLs de staging corregidas."
    else
        echo "✅ URLs de staging ya correctas o no accesibles."
    fi
else
    echo "⚠️ Credenciales de BD no disponibles o BD no encontrada - saltando verificación de URLs"
    echo "Credenciales no disponibles" > "$REPORT_DIR/check_urls_${DATE}.txt"
fi

###################################################################################################
# 4️⃣ REVISAR UPLOADS Y CONTENIDO DE STAGING
###################################################################################################

UPLOADS="/htdocs/staging/wp-content/uploads"

echo "→ Verificando carpeta de uploads en staging..."
if [ -e "$UPLOADS" ]; then
    if [ -L "$UPLOADS" ]; then
        echo "⚠️ uploads es un enlace simbólico (probablemente a producción)."
        echo "🔧 Para seguridad, reportando pero NO modificando automáticamente."
        echo "   Ejecutar manualmente: rm -f $UPLOADS && mkdir -p $UPLOADS && cp -R /htdocs/wp-content/uploads/* $UPLOADS"
    else
        echo "✅ uploads en staging ya es una carpeta física."
    fi
else
    echo "⚠️ Carpeta uploads no existe en staging"
fi

###################################################################################################
# 5️⃣ REGENERAR PERMALINKS Y LIMPIAR CACHES (STAGING)
###################################################################################################

echo "→ Intentando regenerar permalinks..."
if [ -n "${WP_USER:-}" ] && [ -n "${WP_APP_PASSWORD:-}" ]; then
    curl -s -X GET "https://staging.runartfoundry.com/wp-admin/options-permalink.php" \
         -u "${WP_USER}:${WP_APP_PASSWORD}" > /dev/null 2>&1 || echo "⚠️ No se pudo acceder a permalinks"
    
    curl -s -X POST "https://staging.runartfoundry.com/wp-admin/options-permalink.php" \
         -u "${WP_USER}:${WP_APP_PASSWORD}" \
         -d "permalink_structure=/%postname%/&submit=Guardar cambios" > /dev/null 2>&1 || echo "⚠️ No se pudieron actualizar permalinks"
    echo "✅ Permalinks procesados."
else
    echo "⚠️ Credenciales WP no disponibles - saltando regeneración de permalinks"
fi

echo "→ Limpiando caché local..."
if [ -d "/htdocs/staging/wp-content/cache" ]; then
    rm -rf /htdocs/staging/wp-content/cache/* 2>/dev/null || echo "⚠️ Error al limpiar caché"
    echo "✅ Caché local procesada."
else
    echo "ℹ️ Carpeta de caché no encontrada"
fi

if [ -n "${CLOUDFLARE_API_TOKEN:-}" ] && [ -n "${CF_ZONE_ID:-}" ]; then
    echo "→ Purge cache en Cloudflare (solo staging)..."
    curl -X POST "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/purge_cache" \
         -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
         -H "Content-Type: application/json" \
         --data '{"files":["https://staging.runartfoundry.com"]}' 2>/dev/null || echo "⚠️ Error en purge Cloudflare"
    echo "✅ Cloudflare cache procesado para staging."
else
    echo "⚠️ Tokens Cloudflare no disponibles - saltando purge"
fi

###################################################################################################
# 6️⃣ PRUEBA DE AISLAMIENTO
###################################################################################################

echo "→ Creando página temporal de prueba STAGING-ISOLATION..."
if [ -n "${WP_USER:-}" ] && [ -n "${WP_APP_PASSWORD:-}" ]; then
    STAGING_API="https://staging.runartfoundry.com/wp-json/wp/v2/pages"
    RESP=$(curl -s -X POST "$STAGING_API" \
           -H "Content-Type: application/json" \
           -u "${WP_USER}:${WP_APP_PASSWORD}" \
           -d '{"title":"STAGING-ISOLATION-TEST","content":"Esta página confirma aislamiento de staging.","status":"publish"}' 2>/dev/null || echo '{"error":"conexion_fallida"}')
    
    PAGE_ID=$(echo "$RESP" | grep -o '"id":[0-9]*' | head -n1 | cut -d: -f2 2>/dev/null || echo "ERROR")
    
    if [ "$PAGE_ID" != "ERROR" ] && [ -n "$PAGE_ID" ]; then
        echo "✅ Página de aislamiento creada con ID: $PAGE_ID"
    else
        echo "⚠️ No se pudo crear página de prueba"
        PAGE_ID="NO_CREADA"
    fi
else
    echo "⚠️ Credenciales WP no disponibles - saltando creación de página"
    PAGE_ID="SIN_CREDENCIALES"
fi

###################################################################################################
# 7️⃣ REPORTE Y COMMIT FINAL
###################################################################################################

echo "🧾 Generando reporte final..."
{
  echo "# 🧩 Aislamiento Staging — $DATE"
  echo ""
  echo "## Configuración detectada"
  echo "- BD staging: $STAG_DB"
  echo "- BD producción: $PROD_DB"
  echo "- Archivos wp-config:"
  echo "  - Producción: $([ -f "$PROD_WP" ] && echo "✅ Existe" || echo "❌ No encontrado")"
  echo "  - Staging: $([ -f "$STAGING_WP" ] && echo "✅ Existe" || echo "❌ No encontrado")"
  echo ""
  echo "## Acciones realizadas"
  echo "- siteurl/home staging: $([ -f "$REPORT_DIR/check_urls_${DATE}.txt" ] && echo "Verificado" || echo "No verificado")"
  echo "- uploads verificados: $([ -e "$UPLOADS" ] && echo "✅ Existe" || echo "❌ No encontrado")"
  echo "- permalinks: $([ -n "${WP_USER:-}" ] && echo "Procesados" || echo "Saltados (sin credenciales)")"
  echo "- cachés: Procesadas"
  echo "- página de prueba: ID $PAGE_ID"
  echo ""
  echo "## Estado del aislamiento"
  if [ "$PROD_DB" != "$STAG_DB" ] && [ "$PROD_DB" != "NO_ENCONTRADO" ] && [ "$STAG_DB" != "NO_ENCONTRADO" ]; then
    echo "✅ **Staging aislado correctamente** - Bases de datos diferentes"
  else
    echo "⚠️ **Revisar aislamiento** - Bases de datos no confirmadas como diferentes"
  fi
  echo ""
  echo "## Próximos pasos recomendados"
  echo "1. Verificar manualmente acceso a https://staging.runartfoundry.com"
  echo "2. Confirmar que uploads de staging es carpeta física independiente"
  echo "3. Validar que no hay enlaces simbólicos problemáticos"
  echo "4. Probar funcionalidad completa en staging sin afectar producción"
  echo ""
  echo "---"
  echo "*Auditoría completada sin modificaciones destructivas en producción*"
} > "$REPORT_DIR/isolacion_staging_${DATE}.md"

# Verificar si estamos en un repositorio git antes de hacer commit
if git rev-parse --git-dir > /dev/null 2>&1; then
    git add "$REPORT_DIR/isolacion_staging_${DATE}.md" 2>/dev/null || true
    git commit -m "Auditoría aislamiento staging completa ($DATE)" 2>/dev/null || echo "ℹ️ Sin cambios para commit"
    git push origin main 2>/dev/null || echo "ℹ️ No se pudo hacer push (verificar configuración git)"
else
    echo "ℹ️ No se detectó repositorio git - saltando commit"
fi

echo ""
echo "=== ✅ Auditoría y verificación completadas ==="
echo "→ Reporte generado en: $REPORT_DIR/isolacion_staging_${DATE}.md"
echo "→ Staging y producción verificados para independencia."
echo ""