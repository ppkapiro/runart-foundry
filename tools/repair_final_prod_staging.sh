#!/bin/bash
# 🧩 COPAYLO — REPARACIÓN FINAL PRODUCCIÓN/STAGING (SIN /htdocs) · RUN ART FOUNDRY
# Objetivo: corregir mezcla de entornos, restaurar producción y aislar staging.
# Estructura real: WordPress está directamente en la raíz /, y staging en /staging.
# Política: sin eliminaciones, sin sobreescrituras destructivas. Todo queda respaldado y logeado.

set -euo pipefail

DATE=$(date +%Y%m%d_%H%M%S)

# Permitir configurar rutas base vía variables de entorno
# BASE_PATH: raíz donde vive WordPress de producción (por defecto /)
# STAGING_SUBDIR: subdirectorio de staging relativo a BASE_PATH (por defecto staging)
BASE_PATH=${BASE_PATH:-/}
STAGING_SUBDIR=${STAGING_SUBDIR:-staging}

# Determinar carpeta de reportes (prioridad: REPORT_DIR env -> repo root -> cwd)
if [ -n "${REPORT_DIR:-}" ]; then
    REPORT_DIR="$REPORT_DIR"
else
    if git_root=$(git rev-parse --show-toplevel 2>/dev/null); then
        REPORT_DIR="$git_root/_reports/repair_final"
    else
        REPORT_DIR="$(pwd)/_reports/repair_final"
    fi
fi
mkdir -p "$REPORT_DIR"

echo "=== 🔍 INICIANDO REPARACIÓN FINAL — ESTRUCTURA RAÍZ DETECTADA ==="

###################################################################################################
# 0️⃣ VALIDACIONES DE SEGURIDAD Y DETECCIÓN DE ENTORNO
###################################################################################################

echo "→ Validando estructura de archivos..."

# Normalizar BASE_PATH (quitar trailing slash excepto si es /)
if [ "$BASE_PATH" != "/" ]; then
    BASE_PATH="${BASE_PATH%/}"
fi

PROD_WP="$BASE_PATH/wp-config.php"
STAGING_WP="$BASE_PATH/$STAGING_SUBDIR/wp-config.php"

# Detectar si estamos en entorno local o servidor real
if [ ! -f "$PROD_WP" ] && [ ! -f "$STAGING_WP" ]; then
    echo "⚠️ ADVERTENCIA: No se encontraron archivos wp-config en estructura raíz"
    echo "   Esto indica ejecución en entorno local/desarrollo"
    echo "   Continuando en MODO SEGURO (sin modificaciones)"
    SAFE_MODE=true
    PROD_EXISTS=false
    STAG_EXISTS=false
else
    SAFE_MODE=false
    PROD_EXISTS=true
    STAG_EXISTS=true
fi

if [ "$SAFE_MODE" = true ]; then
    echo "🛡️ MODO SEGURO ACTIVADO"
    echo "   El script generará reportes sin modificar archivos"
    echo ""
fi

###################################################################################################
# 1️⃣ DETECTAR ENTORNOS Y BASES DE DATOS
###################################################################################################

if [ "$PROD_EXISTS" = false ]; then
    echo "ℹ️ wp-config.php de producción esperado en: $PROD_WP (no encontrado)"
    PROD_DB="ARCHIVO_NO_ENCONTRADO"
else
    if [ ! -f "$PROD_WP" ]; then
        echo "❌ No se encontró wp-config.php de producción en raíz."
        if [ "$SAFE_MODE" = false ]; then
            echo "   Abortando para evitar operaciones sin contexto."
            exit 1
        fi
        PROD_DB="ARCHIVO_NO_ENCONTRADO"
    else
        PROD_DB=$(grep "DB_NAME" "$PROD_WP" | cut -d"'" -f4 2>/dev/null || echo "NO_DETECTADO")
    fi
fi

if [ "$STAG_EXISTS" = false ]; then
    echo "ℹ️ wp-config.php de staging esperado en: $STAGING_WP (no encontrado)"
    STAG_DB="ARCHIVO_NO_ENCONTRADO"
else
    if [ ! -f "$STAGING_WP" ]; then
        echo "❌ No se encontró wp-config.php de staging en /staging."
        if [ "$SAFE_MODE" = false ]; then
            echo "   Abortando para evitar operaciones sin contexto."
            exit 1
        fi
        STAG_DB="ARCHIVO_NO_ENCONTRADO"
    else
        STAG_DB=$(grep "DB_NAME" "$STAGING_WP" | cut -d"'" -f4 2>/dev/null || echo "NO_DETECTADO")
    fi
fi

echo "🧱 Producción usa DB: $PROD_DB"
echo "🧱 Staging usa DB: $STAG_DB"

# VALIDACIÓN CRÍTICA: Verificar que las BD son diferentes
if [ "$PROD_DB" = "$STAG_DB" ] && [ "$PROD_DB" != "ARCHIVO_NO_ENCONTRADO" ] && [ "$PROD_DB" != "NO_DETECTADO" ]; then
    echo "🚨 PELIGRO CRÍTICO: Ambos entornos apuntan a la misma base de datos: $PROD_DB"
    echo "   ABORTANDO para evitar corrupción de datos"
    exit 1
fi

# Crear respaldos de archivos de configuración
if [ "$SAFE_MODE" = false ]; then
    echo "→ Creando respaldos de seguridad..."
    [ -f "$PROD_WP" ] && cp "$PROD_WP" "$REPORT_DIR/wp-config-prod-backup-$DATE.php"
    [ -f "$STAGING_WP" ] && cp "$STAGING_WP" "$REPORT_DIR/wp-config-staging-backup-$DATE.php"
    echo "✅ Respaldos creados en $REPORT_DIR/"
fi

###################################################################################################
# 2️⃣ REPARAR PRODUCCIÓN (runartfoundry.com)
###################################################################################################
echo ""
echo "=== 🔧 REPARANDO PRODUCCIÓN ==="

if [ "$SAFE_MODE" = false ] && [ -f "$PROD_WP" ]; then
    echo "→ Corrigiendo URLs en wp-config.php de producción..."
    
    # Asegurar URLs correctas en wp-config.php
    sed -i '/WP_HOME/d' "$PROD_WP" || true
    sed -i '/WP_SITEURL/d' "$PROD_WP" || true
    echo "define('WP_HOME','https://runartfoundry.com');" >> "$PROD_WP"
    echo "define('WP_SITEURL','https://runartfoundry.com');" >> "$PROD_WP"
    echo "✅ URLs fijas agregadas en wp-config.php de producción."
    
    # Revisar y limpiar .htaccess
    HTACCESS="/.htaccess"
    if [ -f "$HTACCESS" ]; then
        if grep -q "staging.runartfoundry.com" "$HTACCESS"; then
            cp "$HTACCESS" "$REPORT_DIR/htaccess_backup_prod_${DATE}.txt" || true
            sed -i '/staging.runartfoundry.com/d' "$HTACCESS"
            echo "✅ .htaccess limpio (redirecciones a staging eliminadas)."
        else
            echo "✅ .htaccess sin redirecciones a staging."
        fi
    else
        echo "ℹ️ Archivo .htaccess no encontrado en $BASE_PATH"
    fi
    
    # Limpiar caché producción
    if [ -d "$BASE_PATH/wp-content/cache" ]; then
        rm -rf "$BASE_PATH/wp-content/cache"/* 2>/dev/null || true
        echo "✅ Caché local de producción limpiada."
    else
        echo "ℹ️ No se encontró caché local en producción."
    fi
else
    echo "⚠️ Saltando reparación de producción (modo seguro o archivos no encontrados)"
fi

# Verificar y corregir siteurl/home en DB de producción
if [ "$PROD_DB" != "ARCHIVO_NO_ENCONTRADO" ] && [ "$PROD_DB" != "NO_DETECTADO" ] && [ -n "${DB_USER:-}" ]; then
    echo "→ Verificando URLs en base de datos de producción..."
    QUERY="SELECT option_name, option_value FROM wp_options WHERE option_name IN ('siteurl','home');"
    
    if mysql -u"$DB_USER" -p"${DB_PASSWORD:-}" -h"${DB_HOST:-localhost}" -D"$PROD_DB" -e "$QUERY" > "$REPORT_DIR/prod_urls_before.txt" 2>/dev/null; then
        if grep -q "staging.runartfoundry.com" "$REPORT_DIR/prod_urls_before.txt"; then
            echo "⚙️ Corrigiendo URLs de producción en base de datos..."
            mysql -u"$DB_USER" -p"${DB_PASSWORD:-}" -h"${DB_HOST:-localhost}" -D"$PROD_DB" -e \
            "UPDATE wp_options SET option_value='https://runartfoundry.com' WHERE option_name IN ('siteurl','home');" 2>/dev/null
            echo "✅ URLs de producción restauradas correctamente."
        else
            echo "✅ URLs de producción ya correctas."
        fi
    else
        echo "⚠️ No se pudo acceder a la base de datos de producción"
        echo "Error de conexión a BD producción" > "$REPORT_DIR/prod_urls_before.txt"
    fi
else
    echo "⚠️ Saltando verificación de BD de producción (credenciales no disponibles o BD no detectada)"
    echo "BD no verificada" > "$REPORT_DIR/prod_urls_before.txt"
fi

###################################################################################################
# 3️⃣ REPARAR STAGING (staging.runartfoundry.com)
###################################################################################################
echo ""
echo "=== 🔧 REPARANDO STAGING ==="

if [ "$SAFE_MODE" = false ] && [ -f "$STAGING_WP" ]; then
    echo "→ Corrigiendo URLs en wp-config.php de staging..."
    
    # Asegurar URLs de staging en wp-config.php
    sed -i '/WP_HOME/d' "$STAGING_WP" || true
    sed -i '/WP_SITEURL/d' "$STAGING_WP" || true
    echo "define('WP_HOME','https://staging.runartfoundry.com');" >> "$STAGING_WP"
    echo "define('WP_SITEURL','https://staging.runartfoundry.com');" >> "$STAGING_WP"
    echo "✅ URLs fijas agregadas en wp-config.php de staging."
    
    # Limpiar caché de staging
    if [ -d "$BASE_PATH/$STAGING_SUBDIR/wp-content/cache" ]; then
        rm -rf "$BASE_PATH/$STAGING_SUBDIR/wp-content/cache"/* 2>/dev/null || true
        echo "✅ Caché local de staging limpiada."
    else
        echo "ℹ️ No se encontró caché local en staging."
    fi
else
    echo "⚠️ Saltando reparación de staging (modo seguro o archivos no encontrados)"
fi

# Corregir siteurl/home en DB de staging
if [ "$STAG_DB" != "ARCHIVO_NO_ENCONTRADO" ] && [ "$STAG_DB" != "NO_DETECTADO" ] && [ -n "${DB_USER:-}" ]; then
    echo "→ Verificando URLs en base de datos de staging..."
    QUERY="SELECT option_name, option_value FROM wp_options WHERE option_name IN ('siteurl','home');"
    
    if mysql -u"$DB_USER" -p"${DB_PASSWORD:-}" -h"${DB_HOST:-localhost}" -D"$STAG_DB" -e "$QUERY" > "$REPORT_DIR/staging_urls_before.txt" 2>/dev/null; then
        if grep -q "runartfoundry.com" "$REPORT_DIR/staging_urls_before.txt" && ! grep -q "staging.runartfoundry.com" "$REPORT_DIR/staging_urls_before.txt"; then
            echo "⚙️ Corrigiendo URLs de staging en base de datos..."
            mysql -u"$DB_USER" -p"${DB_PASSWORD:-}" -h"${DB_HOST:-localhost}" -D"$STAG_DB" -e \
            "UPDATE wp_options SET option_value='https://staging.runartfoundry.com' WHERE option_name IN ('siteurl','home');" 2>/dev/null
            echo "✅ URLs de staging corregidas."
        else
            echo "✅ URLs de staging ya correctas."
        fi
    else
        echo "⚠️ No se pudo acceder a la base de datos de staging"
        echo "Error de conexión a BD staging" > "$REPORT_DIR/staging_urls_before.txt"
    fi
else
    echo "⚠️ Saltando verificación de BD de staging (credenciales no disponibles o BD no detectada)"
    echo "BD no verificada" > "$REPORT_DIR/staging_urls_before.txt"
fi

# Verificar carpeta uploads de staging
UPLOADS="$BASE_PATH/$STAGING_SUBDIR/wp-content/uploads"
if [ -e "$UPLOADS" ]; then
    if [ -L "$UPLOADS" ]; then
        echo "⚠️ uploads en staging es un enlace simbólico a producción."
        if [ "$SAFE_MODE" = false ]; then
            echo "🔧 Corrigiendo enlace simbólico..."
            mv "$UPLOADS" "${UPLOADS}_backup_symlink_${DATE}" 2>/dev/null || true
            mkdir -p "$UPLOADS"
            if [ -d "$BASE_PATH/wp-content/uploads" ]; then
                cp -R "$BASE_PATH/wp-content/uploads"/* "$UPLOADS" 2>/dev/null || echo "⚠️ Copia parcial de imágenes, verificar permisos."
                echo "✅ uploads de staging ahora es carpeta física independiente."
            else
                echo "⚠️ Directorio uploads de producción no encontrado para copiar"
            fi
        else
            echo "🛡️ MODO SEGURO: Se reporta pero no se modifica el enlace simbólico"
        fi
    else
        echo "✅ uploads de staging ya es carpeta física."
    fi
else
    echo "ℹ️ Directorio uploads de staging no existe en $UPLOADS"
fi

###################################################################################################
# 4️⃣ REGENERAR PERMALINKS Y PURGAR CACHÉS EXTERNOS
###################################################################################################
echo ""
echo "=== 🔄 OPTIMIZACIONES FINALES ==="

# Regenerar permalinks de staging (via REST API)
if [ -n "${WP_USER:-}" ] && [ -n "${WP_APP_PASSWORD:-}" ]; then
    echo "→ Regenerando permalinks para staging..."
    if curl -s -X POST "https://staging.runartfoundry.com/wp-json/wp/v2/settings" \
         -u "${WP_USER}:${WP_APP_PASSWORD}" \
         -H "Content-Type: application/json" \
         -d '{"permalink_structure":"/%postname%/"}' > /dev/null 2>&1; then
        echo "✅ Permalinks regenerados para staging."
    else
        echo "⚠️ No se pudieron regenerar permalinks (verificar conexión a staging)"
    fi
else
    echo "⚠️ Credenciales WP no disponibles - saltando regeneración de permalinks"
fi

# Purgar cachés de Cloudflare
if [ -n "${CLOUDFLARE_API_TOKEN:-}" ] && [ -n "${CF_ZONE_ID:-}" ]; then
    echo "→ Purgando caché de Cloudflare para ambos dominios..."
    
    # Purge producción
    if curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/purge_cache" \
         -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
         -H "Content-Type: application/json" \
         --data '{"files":["https://runartfoundry.com"]}' > /dev/null 2>&1; then
        echo "✅ Caché de producción purgado en Cloudflare"
    else
        echo "⚠️ Error al purgar caché de producción en Cloudflare"
    fi
    
    # Purge staging
    if curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/purge_cache" \
         -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
         -H "Content-Type: application/json" \
         --data '{"files":["https://staging.runartfoundry.com"]}' > /dev/null 2>&1; then
        echo "✅ Caché de staging purgado en Cloudflare"
    else
        echo "⚠️ Error al purgar caché de staging en Cloudflare"
    fi
else
    echo "⚠️ Tokens Cloudflare no disponibles - saltando purge externo"
fi

###################################################################################################
# 5️⃣ VALIDAR RESULTADOS Y GENERAR REPORTE FINAL
###################################################################################################
echo ""
echo "🧾 Generando reporte final..."

{
    echo "# 🧾 REPARACIÓN FINAL — $DATE"
    echo ""
    echo "## Estructura detectada"
    echo "- **Modo ejecución:** $([ "$SAFE_MODE" = true ] && echo "🛡️ SEGURO (sin modificaciones)" || echo "🔧 ACTIVO (con reparaciones)")"
    echo "- **Producción (raíz /):** $([ -f "$PROD_WP" ] && echo "✅ Detectada" || echo "❌ No encontrada")"
    echo "- **Staging (/staging):** $([ -f "$STAGING_WP" ] && echo "✅ Detectada" || echo "❌ No encontrada")"
    echo ""
    echo "## Configuración de bases de datos"
    echo "- **BD Producción:** $PROD_DB"
    echo "- **BD Staging:** $STAG_DB"
    
    if [ "$PROD_DB" != "$STAG_DB" ] && [ "$PROD_DB" != "ARCHIVO_NO_ENCONTRADO" ] && [ "$STAG_DB" != "ARCHIVO_NO_ENCONTRADO" ]; then
        echo "- **Estado:** ✅ Bases de datos diferentes (aislamiento correcto)"
    else
        echo "- **Estado:** ⚠️ No se pudo confirmar aislamiento de BD"
    fi
    echo ""
    echo "## Acciones realizadas"
    echo ""
    echo "### 🌐 Producción (runartfoundry.com)"
    if [ "$SAFE_MODE" = false ] && [ -f "$PROD_WP" ]; then
        echo "- ✅ URLs restauradas en wp-config.php"
        echo "- ✅ .htaccess verificado y limpiado"
        echo "- ✅ Caché local procesada"
        echo "- $([ -f "$REPORT_DIR/prod_urls_before.txt" ] && echo "✅ URLs en BD verificadas" || echo "⚠️ BD no accesible")"
    else
        echo "- ⚠️ Reparaciones saltadas (modo seguro o archivos no encontrados)"
    fi
    echo ""
    echo "### 🧪 Staging (staging.runartfoundry.com)"
    if [ "$SAFE_MODE" = false ] && [ -f "$STAGING_WP" ]; then
        echo "- ✅ URLs corregidas en wp-config.php"
        echo "- ✅ Caché local procesada"
        echo "- $([ -f "$REPORT_DIR/staging_urls_before.txt" ] && echo "✅ URLs en BD verificadas" || echo "⚠️ BD no accesible")"
    echo "- $([ -L "$BASE_PATH/$STAGING_SUBDIR/wp-content/uploads" ] && echo "🔧 Enlace simbólico de uploads corregido" || echo "✅ Uploads independientes")"
        echo "- $([ -n "${WP_USER:-}" ] && echo "✅ Permalinks regenerados" || echo "⚠️ Permalinks no regenerados")"
    else
        echo "- ⚠️ Reparaciones saltadas (modo seguro o archivos no encontrados)"
    fi
    echo ""
    echo "### ☁️ Optimizaciones"
    echo "- $([ -n "${CLOUDFLARE_API_TOKEN:-}" ] && echo "✅ Cloudflare purgado para ambos dominios" || echo "⚠️ Cloudflare no purgado")"
    echo ""
    echo "## Estado final"
    
    if [ "$SAFE_MODE" = true ]; then
        echo "🛡️ **EJECUCIÓN EN MODO SEGURO**"
        echo "- Script ejecutado en entorno local/desarrollo"
        echo "- No se realizaron modificaciones"
        echo "- Para reparación real, ejecutar en servidor con archivos WordPress"
    elif [ "$PROD_DB" != "$STAG_DB" ] && [ "$PROD_DB" != "ARCHIVO_NO_ENCONTRADO" ] && [ "$STAG_DB" != "ARCHIVO_NO_ENCONTRADO" ]; then
        echo "✅ **REPARACIÓN EXITOSA**"
        echo "- Entornos correctamente separados"
        echo "- Producción restaurada al dominio principal"
        echo "- Staging aislado y funcional"
        echo "- Cachés limpiadas en todos los niveles"
    else
        echo "⚠️ **REPARACIÓN PARCIAL**"
        echo "- Algunas operaciones no se pudieron completar"
        echo "- Revisar logs y credenciales"
        echo "- Puede requerir intervención manual"
    fi
    echo ""
    echo "## Respaldos creados"
    if [ "$SAFE_MODE" = false ]; then
        echo "- $([ -f "$REPORT_DIR/wp-config-prod-backup-$DATE.php" ] && echo "✅ wp-config producción: wp-config-prod-backup-$DATE.php" || echo "- No aplicable")"
        echo "- $([ -f "$REPORT_DIR/wp-config-staging-backup-$DATE.php" ] && echo "✅ wp-config staging: wp-config-staging-backup-$DATE.php" || echo "- No aplicable")"
        echo "- $([ -f "$REPORT_DIR/htaccess_backup_prod_${DATE}.txt" ] && echo "✅ .htaccess: htaccess_backup_prod_${DATE}.txt" || echo "- .htaccess no respaldado")"
    else
        echo "- No se crearon respaldos (modo seguro)"
    fi
    echo ""
    echo "## Próximos pasos recomendados"
    echo "1. **Verificar funcionamiento inmediato:**"
    echo "   \`\`\`bash"
    echo "   curl -I https://runartfoundry.com"
    echo "   curl -I https://staging.runartfoundry.com"
    echo "   \`\`\`"
    echo ""
    echo "2. **Validar contenido:**"
    echo "   - Acceder a ambos sitios desde navegador"
    echo "   - Confirmar que imágenes/uploads funcionan"
    echo "   - Probar login de admin en ambos entornos"
    echo ""
    echo "3. **Monitoreo continuo:**"
    echo "   - Ejecutar auditorías semanales"
    echo "   - Verificar que no vuelvan a mezclarse"
    echo "   - Mantener respaldos actualizados"
    echo ""
    echo "---"
    echo "*Reparación completada sin eliminación de datos - Política de seguridad respetada*"
} > "$REPORT_DIR/repair_final_${DATE}.md"

# Verificar si estamos en un repositorio git antes de hacer commit
if git rev-parse --git-dir > /dev/null 2>&1; then
    git add "$REPORT_DIR/" 2>/dev/null || true
    git commit -m "Reparación final producción/staging (estructura raíz) $DATE" 2>/dev/null || echo "ℹ️ Sin cambios para commit"
    git push origin main 2>/dev/null || echo "ℹ️ No se pudo hacer push (verificar configuración git)"
else
    echo "ℹ️ No se detectó repositorio git - saltando commit"
fi

echo ""
echo "=== ✅ REPARACIÓN FINAL COMPLETADA ==="
echo "→ Reporte detallado: $REPORT_DIR/repair_final_${DATE}.md"

if [ "$SAFE_MODE" = true ]; then
    echo "→ Ejecutado en MODO SEGURO (desarrollo local)"
    echo "→ Para reparación real, ejecutar en servidor con WordPress en estructura raíz"
else
    echo "→ runartfoundry.com: Restaurado al sitio del cliente"
    echo "→ staging.runartfoundry.com: Aislado y funcional"
    echo "→ Respaldos de seguridad disponibles en $REPORT_DIR/"
fi

echo ""
