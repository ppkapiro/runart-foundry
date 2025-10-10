#!/bin/bash
# ======================================================================
# Fase 3 - AUDITORÍA simplificada sobre snapshot local
# Versión sin Lighthouse para compatibilidad con WSL
# ======================================================================

set -euo pipefail

# Variables base
RUN_DATE="$(date +%F)"
BASE_DIR="$PWD"
SNAP_ROOT="$BASE_DIR/mirror/raw/${RUN_DATE}"
SITE_DIR="${SNAP_ROOT}/site_static"
WP_CONTENT_DIR="$SNAP_ROOT/wp-content"
AUDITS_DIR="$BASE_DIR/audits"
REPORT_MD="${AUDITS_DIR}/${RUN_DATE}_auditoria_integral.md"
SEO_DIR="${AUDITS_DIR}/seo"
SEC_DIR="${AUDITS_DIR}/security"
INV_DIR="${AUDITS_DIR}/inventory"

mkdir -p "$AUDITS_DIR" "$SEO_DIR" "$SEC_DIR" "$INV_DIR"

echo "========================================="
echo " AUDITORÍA INTEGRAL - RUN Art Foundry"
echo " Fecha: $RUN_DATE"
echo "========================================="
echo "[INFO] SNAP_ROOT: $SNAP_ROOT"
echo "[INFO] SITE_DIR : $SITE_DIR"
echo "[INFO] WP_CONTENT: $WP_CONTENT_DIR"
echo "[INFO] AUDITS   : $AUDITS_DIR"

# Validaciones
test -d "$SITE_DIR" || { echo "[ERROR] No existe ${SITE_DIR}. Ejecuta la Fase 2 primero."; exit 1; }

# ===================================
# 1) AUDITORÍA SEO BÁSICA
# ===================================
echo ""
echo "[INFO] === AUDITORÍA SEO BÁSICA ==="

# 1.1 Conteo de páginas HTML
HTML_COUNT=$(find "$SITE_DIR" -name "*.html" | wc -l)
echo "[INFO] Páginas HTML encontradas: $HTML_COUNT"

# 1.2 Páginas sin meta description
echo "[INFO] Buscando páginas sin meta description..."
DESC_TXT="${SEO_DIR}/${RUN_DATE}_sin_meta_description.txt"
: > "$DESC_TXT"
find "$SITE_DIR" -type f -name "*.html" | while read -r f; do
  if ! grep -qi '<meta[^>]*name=["'\'']description["'\'']' "$f"; then
    echo "${f#${SITE_DIR}/}" >> "$DESC_TXT"
  fi
done
SIN_DESC=$(cat "$DESC_TXT" | wc -l)
echo "[INFO] Páginas sin meta description: $SIN_DESC"

# 1.3 Páginas con múltiples H1
echo "[INFO] Buscando páginas con múltiples <h1>..."
H1_TXT="${SEO_DIR}/${RUN_DATE}_multiples_h1.txt"
: > "$H1_TXT"
MULT_H1=0
find "$SITE_DIR" -type f -name "*.html" 2>/dev/null | while read -r f; do
  c=$(grep -c -i "<h1" "$f" 2>/dev/null | tr -d '\n\r' || echo "0")
  c_clean=$(echo "$c" | tr -d ' \n\r')
  if [ "${c_clean:-0}" -gt 1 ] 2>/dev/null; then
    echo "${f#${SITE_DIR}/} => ${c_clean} h1" >> "$H1_TXT"
  fi
done
MULT_H1=$(cat "$H1_TXT" | wc -l)
echo "[INFO] Páginas con múltiples H1: $MULT_H1"

# 1.4 Análisis de títulos
echo "[INFO] Analizando títulos de páginas..."
TITLES_TXT="${SEO_DIR}/${RUN_DATE}_titulos.txt"
: > "$TITLES_TXT"
find "$SITE_DIR" -type f -name "*.html" 2>/dev/null | head -20 | while read -r f; do
  title=$(grep -o "<title[^>]*>[^<]*</title>" "$f" 2>/dev/null | sed 's/<[^>]*>//g' | head -n1 | tr -d '\n\r')
  title_len=${#title}
  echo "${f#${SITE_DIR}/} | [$title_len chars] $title" >> "$TITLES_TXT" 2>/dev/null
done

# ===================================
# 2) INVENTARIO WORDPRESS
# ===================================
echo ""
echo "[INFO] === INVENTARIO WORDPRESS ==="

PLUG_TXT="${INV_DIR}/${RUN_DATE}_plugins.txt"
THEM_TXT="${INV_DIR}/${RUN_DATE}_themes.txt"
IMG_TXT="${INV_DIR}/${RUN_DATE}_imagenes_pesadas.txt"

# 2.1 Inventario de plugins
echo "[INFO] Inventariando plugins..."
: > "$PLUG_TXT"
if [ -d "$WP_CONTENT_DIR/plugins" ]; then
  plugin_count=0
  for p in "$WP_CONTENT_DIR/plugins"/*; do
    [ -d "$p" ] || continue
    plugin_count=$((plugin_count + 1))
    main_file=$(find "$p" -name "*.php" -exec grep -l "Plugin Name:" {} \; 2>/dev/null | head -n1 || true)
    if [ -n "${main_file:-}" ]; then
      name=$(grep -i "Plugin Name:" "$main_file" | head -n1 | sed 's/.*Plugin Name:\s*//I' | sed 's/\*\///g' | tr -d '\r')
      vers=$(grep -i "Version:" "$main_file" | head -n1 | sed 's/.*Version:\s*//I' | sed 's/\*\///g' | tr -d '\r')
      echo "$(basename "$p") | ${name:-?} | ${vers:-?}" >> "$PLUG_TXT"
    else
      echo "$(basename "$p") | (sin header detectable)" >> "$PLUG_TXT"
    fi
  done
  echo "[INFO] Plugins encontrados: $plugin_count"
else
  echo "[WARN] No existe $WP_CONTENT_DIR/plugins" | tee -a "$PLUG_TXT"
fi

# 2.2 Inventario de temas
echo "[INFO] Inventariando temas..."
: > "$THEM_TXT"
if [ -d "$WP_CONTENT_DIR/themes" ]; then
  theme_count=0
  for t in "$WP_CONTENT_DIR/themes"/*; do
    [ -d "$t" ] || continue
    theme_count=$((theme_count + 1))
    style="$t/style.css"
    if [ -f "$style" ]; then
      name=$(grep -i "Theme Name:" "$style" | head -n1 | sed 's/.*Theme Name:\s*//I' | tr -d '\r')
      vers=$(grep -i "Version:" "$style" | head -n1 | sed 's/.*Version:\s*//I' | tr -d '\r')
      echo "$(basename "$t") | ${name:-?} | ${vers:-?}" >> "$THEM_TXT"
    else
      echo "$(basename "$t") | (sin style.css)" >> "$THEM_TXT"
    fi
  done
  echo "[INFO] Temas encontrados: $theme_count"
else
  echo "[WARN] No existe $WP_CONTENT_DIR/themes" | tee -a "$THEM_TXT"
fi

# 2.3 Imágenes pesadas
echo "[INFO] Buscando imágenes pesadas (> 500KB)..."
if [ -d "$WP_CONTENT_DIR/uploads" ]; then
  find "$WP_CONTENT_DIR/uploads" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) -size +500k \
    -exec du -h {} \; 2>/dev/null | sort -hr > "$IMG_TXT" || true
  IMG_COUNT=$(cat "$IMG_TXT" | wc -l)
  echo "[INFO] Imágenes > 500KB: $IMG_COUNT"
else
  echo "[WARN] No existe $WP_CONTENT_DIR/uploads" | tee -a "$IMG_TXT"
fi

# ===================================
# 3) AUDITORÍA DE SEGURIDAD
# ===================================
echo ""
echo "[INFO] === AUDITORÍA DE SEGURIDAD ==="

SUS_TXT="${SEC_DIR}/${RUN_DATE}_archivos_sospechosos.txt"
PERM_TXT="${SEC_DIR}/${RUN_DATE}_permisos_wp-content.txt"

# 3.1 Archivos sospechosos (patrones de webshell)
echo "[INFO] Escaneando archivos sospechosos..."
: > "$SUS_TXT"
if [ -d "$WP_CONTENT_DIR" ]; then
  # Búsqueda de patrones peligrosos
  grep -Ril --include="*.php" -E "(base64_decode\(|gzinflate\(|eval\(|system\(|shell_exec\(|passthru\()" "$WP_CONTENT_DIR" 2>/dev/null | head -n 50 > "$SUS_TXT" || true
  SUS_COUNT=$(cat "$SUS_TXT" | wc -l)
  echo "[INFO] Archivos con patrones sospechosos: $SUS_COUNT"
else
  echo "[WARN] No existe $WP_CONTENT_DIR" | tee -a "$SUS_TXT"
fi

# 3.2 Análisis de permisos
echo "[INFO] Analizando permisos..."
if [ -d "$WP_CONTENT_DIR" ]; then
  ( cd "$WP_CONTENT_DIR" && find . -maxdepth 3 -printf "%m %y %p\n" | sort ) > "$PERM_TXT" 2>/dev/null || echo "[WARN] No fue posible listar permisos" | tee -a "$PERM_TXT"
fi

# ===================================
# 4) ESTADÍSTICAS GENERALES
# ===================================
echo ""
echo "[INFO] === ESTADÍSTICAS GENERALES ==="

# Tamaños de directorios
if [ -d "$WP_CONTENT_DIR" ]; then
  UPLOADS_SIZE=$(du -sh "$WP_CONTENT_DIR/uploads" 2>/dev/null | cut -f1 || echo "N/A")
  PLUGINS_SIZE=$(du -sh "$WP_CONTENT_DIR/plugins" 2>/dev/null | cut -f1 || echo "N/A")
  THEMES_SIZE=$(du -sh "$WP_CONTENT_DIR/themes" 2>/dev/null | cut -f1 || echo "N/A")
  TOTAL_WP_SIZE=$(du -sh "$WP_CONTENT_DIR" 2>/dev/null | cut -f1 || echo "N/A")
  
  echo "[INFO] Uploads: $UPLOADS_SIZE"
  echo "[INFO] Plugins: $PLUGINS_SIZE"
  echo "[INFO] Themes: $THEMES_SIZE"
  echo "[INFO] Total wp-content: $TOTAL_WP_SIZE"
fi

STATIC_SIZE=$(du -sh "$SITE_DIR" 2>/dev/null | cut -f1 || echo "N/A")
echo "[INFO] Sitio estático: $STATIC_SIZE"

# ===================================
# 5) REPORTE CONSOLIDADO
# ===================================
echo ""
echo "[INFO] === GENERANDO REPORTE CONSOLIDADO ==="

{
  echo "# Auditoría Integral – RUN Art Foundry"
  echo "**Fecha:** $RUN_DATE"
  echo ""
  echo "## 📊 Resumen Ejecutivo"
  echo ""
  echo "| Métrica | Valor |"
  echo "|---------|-------|"
  echo "| Páginas HTML | $HTML_COUNT |"
  echo "| Sin meta description | $SIN_DESC |"
  echo "| Múltiples H1 | $MULT_H1 |"
  echo "| Plugins instalados | ${plugin_count:-0} |"
  echo "| Temas instalados | ${theme_count:-0} |"
  echo "| Imágenes > 500KB | ${IMG_COUNT:-0} |"
  echo "| Archivos sospechosos | ${SUS_COUNT:-0} |"
  echo ""
  echo "## 📂 Tamaños de Directorios"
  echo ""
  echo "| Directorio | Tamaño |"
  echo "|------------|--------|"
  echo "| Sitio estático | $STATIC_SIZE |"
  echo "| wp-content total | ${TOTAL_WP_SIZE:-N/A} |"
  echo "| uploads/ | ${UPLOADS_SIZE:-N/A} |"
  echo "| plugins/ | ${PLUGINS_SIZE:-N/A} |"
  echo "| themes/ | ${THEMES_SIZE:-N/A} |"
  echo ""
  echo "## 📋 Archivos de Detalle"
  echo ""
  echo "### SEO"
  echo "- 📄 **Títulos de páginas:** \`${TITLES_TXT##$BASE_DIR/}\`"
  echo "- ❌ **Sin meta description:** \`${DESC_TXT##$BASE_DIR/}\`"
  echo "- ⚠️ **Múltiples H1:** \`${H1_TXT##$BASE_DIR/}\`"
  echo ""
  echo "### Inventario WordPress"
  echo "- 🔌 **Plugins:** \`${PLUG_TXT##$BASE_DIR/}\`"
  echo "- 🎨 **Temas:** \`${THEM_TXT##$BASE_DIR/}\`"
  echo "- 🖼️ **Imágenes pesadas:** \`${IMG_TXT##$BASE_DIR/}\`"
  echo ""
  echo "### Seguridad"
  echo "- 🚨 **Archivos sospechosos:** \`${SUS_TXT##$BASE_DIR/}\`"
  echo "- 🔒 **Permisos:** \`${PERM_TXT##$BASE_DIR/}\`"
  echo ""
  echo "## 🎯 Prioridades de Acción"
  echo ""
  echo "### Alta Prioridad"
  if [ "${SUS_COUNT:-0}" -gt 0 ]; then
    echo "- 🚨 **CRÍTICO:** Se encontraron $SUS_COUNT archivos con patrones sospechosos - revisar inmediatamente"
  fi
  if [ "${SIN_DESC:-0}" -gt 5 ]; then
    echo "- 📝 **SEO:** $SIN_DESC páginas sin meta description - impacta posicionamiento"
  fi
  if [ "${IMG_COUNT:-0}" -gt 10 ]; then
    echo "- ⚡ **Performance:** $IMG_COUNT imágenes > 500KB - optimizar para velocidad"
  fi
  echo ""
  echo "### Media Prioridad"
  if [ "${MULT_H1:-0}" -gt 0 ]; then
    echo "- 📝 **SEO:** $MULT_H1 páginas con múltiples H1 - corregir estructura"
  fi
  echo "- 🔄 **Mantenimiento:** Actualizar plugins y temas según inventario"
  echo ""
  echo "## 📅 Próximos Pasos"
  echo ""
  echo "1. **Completar base de datos:** Exportar \`dbs10646556\` vía phpMyAdmin"
  echo "2. **Auditoría Performance:** Instalar Lighthouse en entorno compatible"
  echo "3. **Remediación Seguridad:** Revisar archivos marcados como sospechosos"
  echo "4. **Optimización SEO:** Agregar meta descriptions faltantes"
  echo "5. **Optimización Imágenes:** Comprimir imágenes > 500KB"
  echo ""
  echo "---"
  echo "*Reporte generado automáticamente el $(date '+%Y-%m-%d %H:%M:%S')*"
} > "$REPORT_MD"

echo ""
echo "======================================================================"
echo " ✅ AUDITORÍA FASE 3 COMPLETADA"
echo "======================================================================"
echo " 📊 Reporte principal: ${REPORT_MD##$BASE_DIR/}"
echo " 📁 Carpetas de detalle:"
echo "   - SEO: ${SEO_DIR##$BASE_DIR/}"
echo "   - Seguridad: ${SEC_DIR##$BASE_DIR/}"
echo "   - Inventario: ${INV_DIR##$BASE_DIR/}"
echo ""
echo " 🎯 HALLAZGOS PRINCIPALES:"
echo "   - $HTML_COUNT páginas HTML analizadas"
echo "   - $SIN_DESC páginas sin meta description"
echo "   - ${plugin_count:-0} plugins, ${theme_count:-0} temas"
echo "   - ${IMG_COUNT:-0} imágenes > 500KB"
echo "   - ${SUS_COUNT:-0} archivos con patrones sospechosos"
echo "======================================================================"