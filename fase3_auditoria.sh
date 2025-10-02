#!/bin/bash
# ======================================================================
# Objetivo del Código (Fase 3 - AUDITORÍA sobre snapshot local)
# Correr auditorías de Performance, SEO básico, Accesibilidad y Seguridad
# utilizando el snapshot existente en: mirror/raw/${RUN_DATE}/
# Generar reportes en: audits/
# ======================================================================

set -euo pipefail

# -----------------------------
# 0) Variables y carpetas base
# -----------------------------
RUN_DATE="$(date +%F)"
BASE_DIR="$PWD"
SNAP_ROOT="$BASE_DIR/mirror/raw/${RUN_DATE}"
SITE_DIR="${SNAP_ROOT}/site_static"
AUDITS_DIR="$BASE_DIR/audits"
REPORT_MD="${AUDITS_DIR}/${RUN_DATE}_auditoria_integral.md"
LH_DIR="${AUDITS_DIR}/lighthouse"
AXE_DIR="${AUDITS_DIR}/axe"
SEO_DIR="${AUDITS_DIR}/seo"
SEC_DIR="${AUDITS_DIR}/security"
INV_DIR="${AUDITS_DIR}/inventory"

mkdir -p "$AUDITS_DIR" "$LH_DIR" "$AXE_DIR" "$SEO_DIR" "$SEC_DIR" "$INV_DIR"

echo "[INFO] RUN_DATE: $RUN_DATE"
echo "[INFO] SNAP_ROOT: $SNAP_ROOT"
echo "[INFO] SITE_DIR : $SITE_DIR"
echo "[INFO] AUDITS   : $AUDITS_DIR"

# Validaciones mínimas
test -d "$SITE_DIR" || { echo "[ERROR] No existe ${SITE_DIR}. Asegúrate de correr la Fase 2."; exit 1; }

# ---------------------------------------------------------
# 1) Servir el snapshot localmente (http://127.0.0.1:8080)
# ---------------------------------------------------------
# Requisitos: Node+npx. Instala Node LTS si no existe.
if ! command -v npx >/dev/null 2>&1; then
  echo "[INFO] Instalando NVM + Node LTS..."
  export NVM_DIR="$HOME/.nvm"
  if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  fi
  . "$NVM_DIR/nvm.sh"
  nvm install --lts
  nvm use --lts
fi

# Instalar servidor estático (http-server) y utilidades CLI necesarias
echo "[INFO] Instalando dependencias CLI locales (http-server, lighthouse, axe-core/cli, htmlhint)..."
mkdir -p "$BASE_DIR/.tools"
cd "$BASE_DIR/.tools"
npm init -y >/dev/null 2>&1 || true
npm install --no-audit --no-fund http-server@14 lighthouse@12 @axe-core/cli@4 htmlhint@1 > /dev/null

# Detectar archivo de entrada (index)
cd "$SITE_DIR"
ENTRY_FILE="$( ( [ -f index.html ] && echo "index.html" ) || find . -maxdepth 3 -name 'index.html' | head -n1 )"
test -n "${ENTRY_FILE:-}" || { echo "[ERROR] No se encontró index.html en ${SITE_DIR}."; exit 1; }
ENTRY_URL_PATH="$(dirname "$ENTRY_FILE" | sed 's#^\./##' )"
ENTRY_URL_PATH="${ENTRY_URL_PATH#/}" # normalizar
LOCAL_PORT=8080
LOCAL_URL="http://127.0.0.1:${LOCAL_PORT}/${ENTRY_URL_PATH:+${ENTRY_URL_PATH}/}"

echo "[INFO] ENTRY_FILE: $ENTRY_FILE"
echo "[INFO] ENTRY_URL : $LOCAL_URL"

# Levantar server en background si no está ya en uso
cd "$SITE_DIR"
if ! lsof -i :${LOCAL_PORT} >/dev/null 2>&1; then
  npx http-server -p ${LOCAL_PORT} -c-1 --silent & 
  SERVER_PID=$!
  echo "$SERVER_PID" > "$AUDITS_DIR/http_server_${RUN_DATE}.pid"
  sleep 2
else
  echo "[WARN] Puerto ${LOCAL_PORT} en uso. Usando servidor existente."
  SERVER_PID=""
fi

# -------------------------------------------
# 2) Auditoría de Performance (Lighthouse)
# -------------------------------------------
cd "$BASE_DIR"
LH_MOBILE_HTML="${LH_DIR}/${RUN_DATE}_lighthouse_mobile.html"
LH_DESKTOP_HTML="${LH_DIR}/${RUN_DATE}_lighthouse_desktop.html"
LH_JSON="${LH_DIR}/${RUN_DATE}_lighthouse_mobile.json"

echo "[INFO] Ejecutando Lighthouse (MOBILE y DESKTOP) sobre: $LOCAL_URL"
npx lighthouse "$LOCAL_URL" \
  --quiet --max-wait-for-load=60000 \
  --only-categories=performance,seo,accessibility,best-practices \
  --preset=experimental --form-factor=mobile --screenEmulation.mobile=true \
  --chrome-flags="--headless --no-sandbox --disable-gpu --disable-dev-shm-usage" \
  --output=html --output=json \
  --output-path="$LH_DIR/${RUN_DATE}_lighthouse_mobile" > /dev/null

npx lighthouse "$LOCAL_URL" \
  --quiet --max-wait-for-load=60000 \
  --only-categories=performance,seo,accessibility,best-practices \
  --preset=experimental --form-factor=desktop --screenEmulation.mobile=false \
  --chrome-flags="--headless --no-sandbox --disable-gpu --disable-dev-shm-usage" \
  --output=html \
  --output-path="$LH_DIR/${RUN_DATE}_lighthouse_desktop" > /dev/null

# Normalizar nombres
[ -f "$LH_DIR/${RUN_DATE}_lighthouse_mobile.report.html" ] && mv "$LH_DIR/${RUN_DATE}_lighthouse_mobile.report.html" "$LH_MOBILE_HTML" || true
[ -f "$LH_DIR/${RUN_DATE}_lighthouse_desktop.report.html" ] && mv "$LH_DIR/${RUN_DATE}_lighthouse_desktop.report.html" "$LH_DESKTOP_HTML" || true
[ -f "$LH_DIR/${RUN_DATE}_lighthouse_mobile.report.json" ] && mv "$LH_DIR/${RUN_DATE}_lighthouse_mobile.report.json" "$LH_JSON" || true

# -------------------------------------------
# 3) Accesibilidad (axe-core CLI)
# -------------------------------------------
AXE_JSON="${AXE_DIR}/${RUN_DATE}_axe.json"
AXE_CSV="${AXE_DIR}/${RUN_DATE}_axe.csv"

echo "[INFO] Ejecutando @axe-core/cli sobre: $LOCAL_URL"
npx @axe-core/cli "$LOCAL_URL" --save "$AXE_JSON" --timeout 60000 --chromeOptions='{"args": ["--headless", "--no-sandbox", "--disable-gpu", "--disable-dev-shm-usage"]}' > /dev/null || true

# Convertir JSON de axe a CSV simple (id,impact,help,url,selector)
python3 - <<'PY' "$AXE_JSON" "$AXE_CSV"
import json,sys,csv,os
j = sys.argv[1]; c = sys.argv[2]
if not os.path.exists(j): sys.exit(0)
data = json.load(open(j))
rows=[]
for v in data.get("violations", []):
  for n in v.get("nodes", []):
    rows.append({
      "id": v.get("id",""),
      "impact": v.get("impact",""),
      "help": v.get("help",""),
      "url": v.get("helpUrl",""),
      "selector": "; ".join(n.get("target",[]))
    })
with open(c,"w",newline="",encoding="utf-8") as f:
  w=csv.DictWriter(f,fieldnames=["id","impact","help","url","selector"])
  w.writeheader(); w.writerows(rows)
PY

# -------------------------------------------
# 4) SEO básico (meta tags, títulos, links rotos)
# -------------------------------------------
# 4.1 Validación HTML básica con htmlhint (resultado en texto)
echo "[INFO] Ejecutando htmlhint sobre site_static..."
npx htmlhint "$SITE_DIR/**/*.html" --format unix > "${SEO_DIR}/${RUN_DATE}_htmlhint.txt" || true

# 4.2 Detección de páginas sin <meta name="description">
echo "[INFO] Buscando páginas sin meta description..."
DESC_TXT="${SEO_DIR}/${RUN_DATE}_sin_meta_description.txt"
: > "$DESC_TXT"
find "$SITE_DIR" -type f -name "*.html" | while read -r f; do
  if ! grep -qi '<meta[^>]*name=["'\'']description["'\'']' "$f"; then
    echo "${f#${SITE_DIR}/}" >> "$DESC_TXT"
  fi
done

# 4.3 Detección de múltiples <h1> por página (heurística)
echo "[INFO] Buscando páginas con múltiples <h1>..."
H1_TXT="${SEO_DIR}/${RUN_DATE}_multiples_h1.txt"
: > "$H1_TXT"
find "$SITE_DIR" -type f -name "*.html" | while read -r f; do
  c=$(grep -oi "<h1[^>]*>" "$f" | wc -l | tr -d ' ')
  [ "${c:-0}" -gt 1 ] && echo "${f#${SITE_DIR}/} => ${c} h1" >> "$H1_TXT"
done

# 4.4 Chequeo simple de enlaces rotos internos (solo href local)
# Mapear href y probar archivo/relativo; esto es heurístico para estáticos.
echo "[INFO] Heurística de enlaces internos (posibles rotos)..."
BROKEN_TXT="${SEO_DIR}/${RUN_DATE}_posibles_enlaces_rotos.txt"
: > "$BROKEN_TXT"
python3 - <<'PY' "$SITE_DIR" "$BROKEN_TXT"
import os,sys,re,html
root=sys.argv[1]; out=sys.argv[2]
href_re=re.compile(r'href=["\']([^"\']+)["\']',re.I)
candidates=[]
for base,_,files in os.walk(root):
  for fn in files:
    if not fn.lower().endswith(".html"): continue
    p=os.path.join(base,fn)
    txt=open(p,'rb').read().decode('utf-8','ignore')
    for m in href_re.finditer(txt):
      href=html.unescape(m.group(1)).strip()
      if href.startswith('#') or href.startswith('mailto:') or href.startswith('tel:') or href.startswith('http'): 
        continue
      # normalizar relativo
      target=os.path.normpath(os.path.join(base,href))
      if not os.path.exists(target):
        candidates.append((os.path.relpath(p,root), href))
open(out,'w',encoding='utf-8').write("\n".join(f"{p} => {h}" for p,h in sorted(set(candidates))))
PY

# -------------------------------------------
# 5) Inventario (plugins/temas) + imágenes pesadas
# -------------------------------------------
WP_CONTENT_DIR="$SNAP_ROOT/wp-content"
PLUG_TXT="${INV_DIR}/${RUN_DATE}_plugins.txt"
THEM_TXT="${INV_DIR}/${RUN_DATE}_themes.txt"
IMG_TXT="${INV_DIR}/${RUN_DATE}_imagenes_pesadas.txt"

echo "[INFO] Inventariando plugins y temas..."
: > "$PLUG_TXT"; : > "$THEM_TXT"
if [ -d "$WP_CONTENT_DIR/plugins" ]; then
  for p in "$WP_CONTENT_DIR/plugins"/*; do
    [ -d "$p" ] || continue
    main_file=$(grep -ril "Plugin Name:" "$p" --include="*.php" | head -n1 || true)
    if [ -n "${main_file:-}" ]; then
      name=$(grep -i "Plugin Name:" "$main_file" | head -n1 | sed 's/.*Plugin Name:\s*//I')
      vers=$(grep -i "Version:" "$main_file" | head -n1 | sed 's/.*Version:\s*//I')
      echo "$(basename "$p") | ${name:-?} | ${vers:-?}" >> "$PLUG_TXT"
    else
      echo "$(basename "$p") | (sin header detectable)" >> "$PLUG_TXT"
    fi
  done
else
  echo "[WARN] No existe $WP_CONTENT_DIR/plugins" | tee -a "$PLUG_TXT"
fi

if [ -d "$WP_CONTENT_DIR/themes" ]; then
  for t in "$WP_CONTENT_DIR/themes"/*; do
    [ -d "$t" ] || continue
    style="$t/style.css"
    if [ -f "$style" ]; then
      name=$(grep -i "Theme Name:" "$style" | head -n1 | sed 's/.*Theme Name:\s*//I')
      vers=$(grep -i "Version:" "$style" | head -n1 | sed 's/.*Version:\s*//I')
      echo "$(basename "$t") | ${name:-?} | ${vers:-?}" >> "$THEM_TXT"
    else
      echo "$(basename "$t") | (sin style.css)" >> "$THEM_TXT"
    fi
  done
else
  echo "[WARN] No existe $WP_CONTENT_DIR/themes" | tee -a "$THEM_TXT"
fi

echo "[INFO] Buscando imágenes pesadas (> 500KB) en uploads/..."
if [ -d "$WP_CONTENT_DIR/uploads" ]; then
  find "$WP_CONTENT_DIR/uploads" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) -size +500k \
    -exec du -h {} \; | sort -hr > "$IMG_TXT" || true
else
  echo "[WARN] No existe $WP_CONTENT_DIR/uploads" | tee -a "$IMG_TXT"
fi

# -------------------------------------------
# 6) Seguridad (heurísticas offline)
# -------------------------------------------
SUS_TXT="${SEC_DIR}/${RUN_DATE}_archivos_sospechosos.txt"
PERM_TXT="${SEC_DIR}/${RUN_DATE}_permisos_wp-content.txt"

echo "[INFO] Escaneo heurístico de archivos sospechosos en wp-content..."
: > "$SUS_TXT"
if [ -d "$WP_CONTENT_DIR" ]; then
  # Búsqueda de patrones comunes de webshell/obfuscación
  grep -Ril --include="*.php" -E "(base64_decode\(|gzinflate\(|eval\(|system\(|shell_exec\(|passthru\()" "$WP_CONTENT_DIR" 2>/dev/null | head -n 200 > "$SUS_TXT" || true
else
  echo "[WARN] No existe $WP_CONTENT_DIR" | tee -a "$SUS_TXT"
fi

echo "[INFO] Listando permisos de archivos y carpetas (muestra)..."
( cd "$WP_CONTENT_DIR" && find . -maxdepth 2 -printf "%m %y %p\n" | sort ) > "$PERM_TXT" 2>/dev/null || echo "[WARN] No fue posible listar permisos" | tee -a "$PERM_TXT"

# -------------------------------------------
# 7) Consolidación de Reporte en Markdown
# -------------------------------------------
echo "[INFO] Generando reporte consolidado: $REPORT_MD"
{
  echo "# Auditoría Integral – RUN Art Foundry"
  echo "- Fecha: ${RUN_DATE}"
  echo ""
  echo "## Entradas"
  echo "- Snapshot servido desde: \`${SITE_DIR}\` → ${LOCAL_URL}"
  echo "- wp-content: \`${WP_CONTENT_DIR}\`"
  echo ""
  echo "## Resultados Clave"
  echo "- Lighthouse (Mobile): $( [ -f "$LH_MOBILE_HTML" ] && echo "[HTML] ${LH_MOBILE_HTML##$BASE_DIR/}" || echo "No generado" )"
  echo "- Lighthouse (Desktop): $( [ -f "$LH_DESKTOP_HTML" ] && echo "[HTML] ${LH_DESKTOP_HTML##$BASE_DIR/}" || echo "No generado" )"
  echo "- axe-core: $( [ -f "$AXE_JSON" ] && echo "${AXE_JSON##$BASE_DIR/}" || echo "No generado" ), CSV: $( [ -f "$AXE_CSV" ] && echo "${AXE_CSV##$BASE_DIR/}" || echo "No generado" )"
  echo "- HTMLHint: ${SEO_DIR}/${RUN_DATE}_htmlhint.txt"
  echo "- Páginas sin meta description: ${SEO_DIR}/${RUN_DATE}_sin_meta_description.txt"
  echo "- Páginas con múltiples H1: ${SEO_DIR}/${RUN_DATE}_multiples_h1.txt"
  echo "- Posibles enlaces rotos: ${SEO_DIR}/${RUN_DATE}_posibles_enlaces_rotos.txt"
  echo "- Inventario Plugins: ${INV_DIR}/${RUN_DATE}_plugins.txt"
  echo "- Inventario Temas: ${INV_DIR}/${RUN_DATE}_themes.txt"
  echo "- Imágenes pesadas (>500KB): ${INV_DIR}/${RUN_DATE}_imagenes_pesadas.txt"
  echo "- Sospechosos (patrones peligrosos): ${SEC_DIR}/${RUN_DATE}_archivos_sospechosos.txt"
  echo "- Permisos (muestra): ${SEC_DIR}/${RUN_DATE}_permisos_wp-content.txt"
  echo ""
  echo "## Observaciones Iniciales"
  echo "- Revise resultados de Lighthouse para LCP/CLS/TBT y priorice imágenes y JS."
  echo "- Atender violaciones de axe-core con impacto 'critical' y 'serious' primero."
  echo "- Corregir páginas sin meta description y casos con múltiples H1."
  echo "- Optimizar o sustituir imágenes pesadas detectadas."
  echo "- Revisar archivos marcados como 'sospechosos' (pueden ser falsos positivos)."
  echo ""
  echo "## Próximos Pasos"
  echo "1. Completar **db_dump.sql** vía phpMyAdmin y montar un entorno de staging."
  echo "2. Re-ejecutar Lighthouse tras optimizaciones (imágenes, minificación, lazy-load)."
  echo "3. Implementar mejoras de accesibilidad (etiquetas, contraste, foco visible)."
  echo "4. Endurecer seguridad (actualizar plugins/temas, permisos, WAF)."
  echo "5. Consolidar informe final y plan de remediación por prioridad/impacto."
} > "$REPORT_MD"

echo "[INFO] Reporte listo: $REPORT_MD"

# -------------------------------------------
# 8) Apagar servidor local (opcional)
# -------------------------------------------
if [ -n "${SERVER_PID:-}" ] && ps -p "$SERVER_PID" >/dev/null 2>&1; then
  echo "[INFO] Apagando servidor local (PID $SERVER_PID)..."
  kill "$SERVER_PID" || true
fi

echo ""
echo "======================================================================"
echo " AUDITORÍA Fase 3 COMPLETADA (snapshot local)"
echo " - Reporte: ${REPORT_MD}"
echo " - Carpetas: ${LH_DIR} ${AXE_DIR} ${SEO_DIR} ${SEC_DIR} ${INV_DIR}"
echo "======================================================================"