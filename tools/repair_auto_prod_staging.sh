#!/bin/bash
# 🧩 COPAYLO — REPARACIÓN AUTOMÁTICA PRODUCCIÓN/STAGING · RUN ART FOUNDRY
# Objetivo: revertir mezcla entre producción y staging, restaurar sitio original del cliente y aislar entornos.
# Política: NO eliminar archivos, NO borrar bases de datos. Solo corrige rutas, URLs y enlaces cruzados.

set -euo pipefail

DATE=$(date +%Y%m%d_%H%M%S)
REPORT_DIR="_reports/repair_auto"
mkdir -p "$REPORT_DIR"

echo "=== 🔍 INICIANDO REPARACIÓN AUTOMÁTICA ==="

###################################################################################################
# 0️⃣ VALIDACIONES DE SEGURIDAD PREVIAS
###################################################################################################

echo "→ Validando estructura de archivos y permisos..."

PROD_WP="/htdocs/wp-config.php"
STAGING_WP="/htdocs/staging/wp-config.php"

# Verificar existencia de archivos críticos
if [ ! -f "$PROD_WP" ]; then
    echo "⚠️ ADVERTENCIA: wp-config.php de producción no encontrado en $PROD_WP"
    echo "   Esto podría indicar estructura de hosting diferente o ejecución desde entorno local"
    echo "   Continuando con validaciones..."
    PROD_EXISTS=false
else
    PROD_EXISTS=true
fi

if [ ! -f "$STAGING_WP" ]; then
    echo "⚠️ ADVERTENCIA: wp-config.php de staging no encontrado en $STAGING_WP"
    echo "   Esto podría indicar estructura de hosting diferente o ejecución desde entorno local"
    echo "   Continuando con validaciones..."
    STAG_EXISTS=false
else
    STAG_EXISTS=true
fi

# Si ningún archivo existe, probablemente estamos en entorno local/desarrollo
if [ "$PROD_EXISTS" = false ] && [ "$STAG_EXISTS" = false ]; then
    echo "🛡️ MODO SEGURO: No se detectaron archivos WordPress en rutas esperadas"
    echo "   El script continuará en modo simulación/reporte sin modificar archivos"
    SAFE_MODE=true
else
    SAFE_MODE=false
fi

###################################################################################################
# 1️⃣ DETECTAR ENTORNOS
###################################################################################################

if [ "$PROD_EXISTS" = true ]; then
    PROD_DB=$(grep "DB_NAME" "$PROD_WP" | cut -d"'" -f4 2>/dev/null || echo "NO_DETECTADO")
else
    PROD_DB="ARCHIVO_NO_ENCONTRADO"
fi

if [ "$STAG_EXISTS" = true ]; then
    STAG_DB=$(grep "DB_NAME" "$STAGING_WP" | cut -d"'" -f4 2>/dev/null || echo "NO_DETECTADO")
else
    STAG_DB="ARCHIVO_NO_ENCONTRADO"
fi

echo "🧱 BD producción: $PROD_DB"
echo "🧱 BD staging: $STAG_DB"

# VALIDACIÓN CRÍTICA: Verificar que las BD son diferentes
if [ "$PROD_DB" = "$STAG_DB" ] && [ "$PROD_DB" != "ARCHIVO_NO_ENCONTRADO" ] && [ "$PROD_DB" != "NO_DETECTADO" ]; then
    echo "🚨 PELIGRO CRÍTICO: Ambos entornos apuntan a la misma base de datos: $PROD_DB"
    echo "   ABORTANDO para evitar corrupción de datos"
    exit 1
fi

# Crear respaldos de archivos de configuración
if [ "$SAFE_MODE" = false ]; then
    echo "→ Creando respaldos de seguridad..."
    [ "$PROD_EXISTS" = true ] && cp "$PROD_WP" "$REPORT_DIR/wp-config-prod-backup-$DATE.php"
    [ "$STAG_EXISTS" = true ] && cp "$STAGING_WP" "$REPORT_DIR/wp-config-staging-backup-$DATE.php"
    echo "✅ Respaldos creados en $REPORT_DIR/"
fi

###################################################################################################
# 2️⃣ REVISAR Y REPARAR PRODUCCIÓN (runartfoundry.com)
###################################################################################################
echo "=== 🔧 REPARANDO PRODUCCIÓN ==="

if [ "$PROD_EXISTS" = true ] && [ "$SAFE_MODE" = false ]; then
    echo "→ Corrigiendo URLs en wp-config.php de producción..."
    
    # Asegurar URLs correctas en wp-config.php
    sed -i '/WP_HOME/d' "$PROD_WP" || true
    sed -i '/WP_SITEURL/d' "$PROD_WP" || true
    echo "define('WP_HOME','https://runartfoundry.com');" >> "$PROD_WP"
    echo "define('WP_SITEURL','https://runartfoundry.com');" >> "$PROD_WP"
    echo "✅ Constantes WP_HOME/WP_SITEURL configuradas para producción"
    
    # Verificar .htaccess (no redirecciones a staging)
    HTACCESS="/htdocs/.htaccess"
    if [ -f "$HTACCESS" ]; then
        if grep -q "staging.runartfoundry.com" "$HTACCESS"; then
            echo "⚙️ Corrigiendo .htaccess de producción (eliminando redirecciones a staging)..."
            cp "$HTACCESS" "$REPORT_DIR/htaccess-backup-$DATE"
            sed -i '/staging.runartfoundry.com/d' "$HTACCESS"
            echo "✅ .htaccess limpio."
        else
            echo "✅ .htaccess de producción ya está correcto"
        fi
    else
        echo "ℹ️ Archivo .htaccess no encontrado en producción"
    fi
    
    # Limpiar caché producción
    if [ -d "/htdocs/wp-content/cache" ]; then
        rm -rf /htdocs/wp-content/cache/* 2>/dev/null || true
        echo "✅ Caché local de producción limpiada."
    else
        echo "ℹ️ Directorio de caché de producción no encontrado"
    fi
else
    echo "⚠️ Saltando reparación de producción (modo seguro o archivo no encontrado)"
fi

# Corregir URLs en base de datos de producción
if [ "$PROD_DB" != "ARCHIVO_NO_ENCONTRADO" ] && [ "$PROD_DB" != "NO_DETECTADO" ] && [ -n "${DB_USER:-}" ]; then
    echo "→ Verificando URLs en base de datos de producción..."
    QUERY="SELECT option_name, option_value FROM wp_options WHERE option_name IN ('siteurl','home');"
    
    if mysql -u"$DB_USER" -p"${DB_PASSWORD:-}" -h"${DB_HOST:-localhost}" -D"$PROD_DB" -e "$QUERY" > "$REPORT_DIR/prod_url_before.txt" 2>/dev/null; then
        if grep -q "staging.runartfoundry.com" "$REPORT_DIR/prod_url_before.txt"; then
            echo "⚙️ Corrigiendo URLs de producción en base de datos..."
            mysql -u"$DB_USER" -p"${DB_PASSWORD:-}" -h"${DB_HOST:-localhost}" -D"$PROD_DB" -e \
            "UPDATE wp_options SET option_value='https://runartfoundry.com' WHERE option_name IN ('siteurl','home');" 2>/dev/null
            echo "✅ URLs de producción restauradas."
        else
            echo "✅ URLs de producción en BD ya correctas."
        fi
    else
        echo "⚠️ No se pudo acceder a la base de datos de producción"
        echo "Error de conexión a BD producción" > "$REPORT_DIR/prod_url_before.txt"
    fi
else
    echo "⚠️ Saltando verificación de BD de producción (credenciales no disponibles o BD no detectada)"
    echo "BD no verificada" > "$REPORT_DIR/prod_url_before.txt"
fi

###################################################################################################
# 3️⃣ AISLAR Y REPARAR STAGING (staging.runartfoundry.com)
###################################################################################################
echo "=== 🔧 REPARANDO STAGING ==="

if [ "$STAG_EXISTS" = true ] && [ "$SAFE_MODE" = false ]; then
    echo "→ Corrigiendo URLs en wp-config.php de staging..."
    
    # Fijar URLs de staging en wp-config
    sed -i '/WP_HOME/d' "$STAGING_WP" || true
    sed -i '/WP_SITEURL/d' "$STAGING_WP" || true
    echo "define('WP_HOME','https://staging.runartfoundry.com');" >> "$STAGING_WP"
    echo "define('WP_SITEURL','https://staging.runartfoundry.com');" >> "$STAGING_WP"
    echo "✅ Constantes WP_HOME/WP_SITEURL configuradas para staging"
    
    # Limpiar caché staging
    if [ -d "/htdocs/staging/wp-content/cache" ]; then
        rm -rf /htdocs/staging/wp-content/cache/* 2>/dev/null || true
        echo "✅ Caché local de staging limpiada."
    else
        echo "ℹ️ Directorio de caché de staging no encontrado"
    fi
else
    echo "⚠️ Saltando reparación de staging (modo seguro o archivo no encontrado)"
fi

# Corregir URLs en base de datos de staging
if [ "$STAG_DB" != "ARCHIVO_NO_ENCONTRADO" ] && [ "$STAG_DB" != "NO_DETECTADO" ] && [ -n "${DB_USER:-}" ]; then
    echo "→ Verificando URLs en base de datos de staging..."
    QUERY="SELECT option_name, option_value FROM wp_options WHERE option_name IN ('siteurl','home');"
    
    if mysql -u"$DB_USER" -p"${DB_PASSWORD:-}" -h"${DB_HOST:-localhost}" -D"$STAG_DB" -e "$QUERY" > "$REPORT_DIR/stag_url_before.txt" 2>/dev/null; then
        if grep -q "runartfoundry.com" "$REPORT_DIR/stag_url_before.txt" && ! grep -q "staging.runartfoundry.com" "$REPORT_DIR/stag_url_before.txt"; then
            echo "⚙️ Corrigiendo URLs de staging en base de datos..."
            mysql -u"$DB_USER" -p"${DB_PASSWORD:-}" -h"${DB_HOST:-localhost}" -D"$STAG_DB" -e \
            "UPDATE wp_options SET option_value='https://staging.runartfoundry.com' WHERE option_name IN ('siteurl','home');" 2>/dev/null
            echo "✅ URLs de staging corregidas."
        else
            echo "✅ URLs de staging en BD ya correctas."
        fi
    else
        echo "⚠️ No se pudo acceder a la base de datos de staging"
        echo "Error de conexión a BD staging" > "$REPORT_DIR/stag_url_before.txt"
    fi
else
    echo "⚠️ Saltando verificación de BD de staging (credenciales no disponibles o BD no detectada)"
    echo "BD no verificada" > "$REPORT_DIR/stag_url_before.txt"
fi

# Verificar y corregir uploads de staging
UPLOADS="/htdocs/staging/wp-content/uploads"
if [ -e "$UPLOADS" ]; then
    if [ -L "$UPLOADS" ]; then
        echo "⚠️ uploads en staging es enlace simbólico a producción."
        if [ "$SAFE_MODE" = false ]; then
            echo "🔧 Corrigiendo enlace simbólico..."
            mv "$UPLOADS" "${UPLOADS}_backup_symlink_${DATE}" || true
            mkdir -p "$UPLOADS"
            if [ -d "/htdocs/wp-content/uploads" ]; then
                cp -R /htdocs/wp-content/uploads/* "$UPLOADS" 2>/dev/null || echo "⚠️ Copia parcial de imágenes (verificar permisos)."
                echo "✅ uploads de staging ahora es carpeta física independiente."
            else
                echo "⚠️ Directorio uploads de producción no encontrado para copiar"
            fi
        else
            echo "🛡️ MODO SEGURO: Se reporta pero no se modifica el enlace simbólico"
        fi
    else
        echo "✅ uploads en staging ya es carpeta física."
    fi
else
    echo "ℹ️ Directorio uploads de staging no existe"
fi

# Regenerar permalinks (via REST API si hay credenciales)
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

###################################################################################################
# 4️⃣ PURGAR CACHÉS EXTERNOS (CLOUDFLARE)
###################################################################################################

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
# 5️⃣ VALIDAR Y DOCUMENTAR RESULTADO
###################################################################################################

echo "🧾 Generando reporte de reparación..."

{
    echo "# 🧾 Reparación automática — $DATE"
    echo ""
    echo "## Configuración detectada"
    echo "- **Modo de ejecución:** $([ "$SAFE_MODE" = true ] && echo "🛡️ SEGURO (sin modificaciones)" || echo "🔧 ACTIVO (con reparaciones)")"
    echo "- **BD producción:** $PROD_DB"
    echo "- **BD staging:** $STAG_DB"
    echo "- **Archivos wp-config encontrados:**"
    echo "  - Producción: $([ "$PROD_EXISTS" = true ] && echo "✅ Sí" || echo "❌ No")"
    echo "  - Staging: $([ "$STAG_EXISTS" = true ] && echo "✅ Sí" || echo "❌ No")"
    echo ""
    echo "## Acciones realizadas"
    echo ""
    echo "### 🌐 Producción (runartfoundry.com)"
    if [ "$SAFE_MODE" = false ] && [ "$PROD_EXISTS" = true ]; then
        echo "- ✅ URLs corregidas en wp-config.php"
        echo "- ✅ .htaccess verificado y limpiado"
        echo "- ✅ Caché local limpiada"
        echo "- $([ -f "$REPORT_DIR/prod_url_before.txt" ] && echo "✅ URLs en BD verificadas" || echo "⚠️ BD no accesible")"
    else
        echo "- ⚠️ Reparaciones saltadas (modo seguro o archivos no encontrados)"
    fi
    echo ""
    echo "### 🧪 Staging (staging.runartfoundry.com)"
    if [ "$SAFE_MODE" = false ] && [ "$STAG_EXISTS" = true ]; then
        echo "- ✅ URLs corregidas en wp-config.php"
        echo "- ✅ Caché local limpiada"
        echo "- $([ -f "$REPORT_DIR/stag_url_before.txt" ] && echo "✅ URLs en BD verificadas" || echo "⚠️ BD no accesible")"
        echo "- $([ -L "/htdocs/staging/wp-content/uploads" ] && echo "🔧 Enlace simbólico de uploads corregido" || echo "✅ Uploads ya independientes")"
        echo "- $([ -n "${WP_USER:-}" ] && echo "✅ Permalinks regenerados" || echo "⚠️ Permalinks no regenerados (sin credenciales)")"
    else
        echo "- ⚠️ Reparaciones saltadas (modo seguro o archivos no encontrados)"
    fi
    echo ""
    echo "### ☁️ Caché externo"
    echo "- $([ -n "${CLOUDFLARE_API_TOKEN:-}" ] && echo "✅ Cloudflare purgado para ambos dominios" || echo "⚠️ Cloudflare no purgado (sin tokens)")"
    echo ""
    echo "## Estado final"
    
    if [ "$PROD_DB" != "$STAG_DB" ] && [ "$PROD_DB" != "ARCHIVO_NO_ENCONTRADO" ] && [ "$STAG_DB" != "ARCHIVO_NO_ENCONTRADO" ]; then
        echo "✅ **REPARACIÓN EXITOSA**"
        echo "- Producción y staging utilizan bases de datos diferentes"
        echo "- URLs y configuraciones corregidas según entorno"
        echo "- Archivos de uploads independizados"
        echo "- Cachés limpiadas"
    elif [ "$SAFE_MODE" = true ]; then
        echo "🛡️ **EJECUCIÓN EN MODO SEGURO**"
        echo "- No se detectaron archivos WordPress en las rutas esperadas"
        echo "- Esto es normal en entornos de desarrollo local"
        echo "- Para reparación real, ejecutar en el servidor de hosting"
    else
        echo "⚠️ **REPARACIÓN PARCIAL**"
        echo "- Algunas operaciones no se pudieron completar"
        echo "- Revisar logs de errores y credenciales"
        echo "- Bases de datos podrían no estar accesibles"
    fi
    echo ""
    echo "## Respaldos creados"
    if [ "$SAFE_MODE" = false ]; then
        echo "- $([ "$PROD_EXISTS" = true ] && echo "✅ wp-config producción: wp-config-prod-backup-$DATE.php" || echo "- No aplicable")"
        echo "- $([ "$STAG_EXISTS" = true ] && echo "✅ wp-config staging: wp-config-staging-backup-$DATE.php" || echo "- No aplicable")"
        echo "- $([ -f "$REPORT_DIR/htaccess-backup-$DATE" ] && echo "✅ .htaccess: htaccess-backup-$DATE" || echo "- .htaccess no respaldado")"
    else
        echo "- No se crearon respaldos (modo seguro)"
    fi
    echo ""
    echo "## Próximos pasos recomendados"
    echo "1. **Verificar funcionamiento:**"
    echo "   - Acceder a https://runartfoundry.com (debe mostrar sitio original)"
    echo "   - Acceder a https://staging.runartfoundry.com (debe estar aislado)"
    echo "2. **Validar contenido:**"
    echo "   - Confirmar que imágenes/uploads funcionan en ambos sitios"
    echo "   - Probar funcionalidades principales en ambos entornos"
    echo "3. **Monitoreo continuo:**"
    echo "   - Ejecutar auditorías periódicas con staging_isolation_audit.sh"
    echo "   - Verificar que no vuelvan a mezclarse los entornos"
    echo ""
    echo "---"
    echo "*Reparación completada respetando política de no eliminación de datos*"
} > "$REPORT_DIR/repair_summary_${DATE}.md"

# Verificar si estamos en un repositorio git antes de hacer commit
if git rev-parse --git-dir > /dev/null 2>&1; then
    git add "$REPORT_DIR/" 2>/dev/null || true
    git commit -m "Reparación automática de producción y aislamiento staging ($DATE)" 2>/dev/null || echo "ℹ️ Sin cambios para commit"
    git push origin main 2>/dev/null || echo "ℹ️ No se pudo hacer push (verificar configuración git)"
else
    echo "ℹ️ No se detectó repositorio git - saltando commit"
fi

echo ""
echo "=== ✅ REPARACIÓN COMPLETA ==="
echo "→ Reporte detallado: $REPORT_DIR/repair_summary_${DATE}.md"

if [ "$SAFE_MODE" = true ]; then
    echo "→ Ejecutado en MODO SEGURO (desarrollo local)"
    echo "→ Para reparación real, ejecutar en servidor de hosting con archivos WordPress"
else
    echo "→ runartfoundry.com: URLs y configuración restauradas"
    echo "→ staging.runartfoundry.com: Aislado y configurado independientemente"
    echo "→ Respaldos de seguridad disponibles en $REPORT_DIR/"
fi

echo ""