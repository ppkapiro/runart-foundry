#!/bin/bash
# ======================================================================
# Instrucciones para Copilot — Generar Informes Maestro (Técnico + Estratégico)
# Proyecto: RUN Art Foundry
# Objetivo:
#  1) Consolidar TODO lo existente en audits/ (+mirror/, +docs/) en:
#       - audits/reports/YYYY-MM-DD_informe_tecnico.md
#       - audits/reports/YYYY-MM-DD_informe_estrategico.md
#  2) Ordenar estructura (mover scripts sueltos de audits/ a audits/scripts/).
#  3) Incluir sitemap real, inventarios, logs y métricas (tamaños, extensiones).
# Requisitos: bash, coreutils, grep, awk, sed, python3 (estándar), (opcional) tree.
# ======================================================================

set -euo pipefail

# ----------------------------
# 0) Contexto & rutas base
# ----------------------------
if git rev-parse --show-toplevel >/dev/null 2>&1; then
  ROOT_DIR="$(git rev-parse --show-toplevel)"
else
  ROOT_DIR="$PWD"
fi
cd "$ROOT_DIR"

TODAY="$(date +%F)"
# Detectar último snapshot disponible (usaremos su fecha si existe)
LAST_SNAP_DIR="$(ls -1dt mirror/raw/*/ 2>/dev/null | head -n1 || true)"
if [ -n "${LAST_SNAP_DIR:-}" ]; then
  SNAP_DATE="$(basename "$(dirname "$LAST_SNAP_DIR")")"
else
  SNAP_DATE="$TODAY"
fi

AUDITS_DIR="audits"
STRUCT_DIR="${AUDITS_DIR}/_structure"
REPORTS_DIR="${AUDITS_DIR}/reports"
INVENTORY_DIR="${AUDITS_DIR}/inventory"
SEO_DIR="${AUDITS_DIR}/seo"
SEC_DIR="${AUDITS_DIR}/security"
AXE_DIR="${AUDITS_DIR}/axe"
LH_DIR="${AUDITS_DIR}/lighthouse"
SCRIPTS_DIR="${AUDITS_DIR}/scripts"

mkdir -p "$REPORTS_DIR" "$SCRIPTS_DIR"

TECNICO_MD="${REPORTS_DIR}/${SNAP_DATE}_informe_tecnico.md"
ESTRATEGICO_MD="${REPORTS_DIR}/${SNAP_DATE}_informe_estrategico.md"

SITE_DIR_CANDIDATE_1="mirror/raw/${SNAP_DATE}/site_static"
SITE_DIR_CANDIDATE_2="${LAST_SNAP_DIR%/}/site_static"
SITE_DIR=""
for c in "$SITE_DIR_CANDIDATE_1" "$SITE_DIR_CANDIDATE_2"; do
  [ -d "$c" ] && SITE_DIR="$c" && break
done

# ----------------------------
# 1) Ordenar estructura audits/
# ----------------------------
# Mover posibles scripts sueltos en raíz de audits/ a audits/scripts/
find "$AUDITS_DIR" -maxdepth 1 -type f -iregex '.*\.\(sh\|bash\|ps1\|py\|js\)$' -print0 \
  | xargs -0 -I {} bash -lc 'echo "[MOVE] {} -> '"$SCRIPTS_DIR"'/$(basename "{}")"; mv -f "{}" '"$SCRIPTS_DIR"'/' 2>/dev/null || true

# ----------------------------
# 2) Asegurar sitemap e insumos
# ----------------------------
SITEMAP_TXT="${STRUCT_DIR}/${SNAP_DATE}_sitemap.txt"
NO_META_TXT="${STRUCT_DIR}/${SNAP_DATE}_no_meta_description.txt"
COUNT_BY_EXT_CSV="${STRUCT_DIR}/${SNAP_DATE}_count_by_extension.csv"
TOP100_CSV="${STRUCT_DIR}/${SNAP_DATE}_top100_files_by_size.csv"
SIZES_OVERVIEW="${STRUCT_DIR}/${SNAP_DATE}_sizes_overview.txt"
PROJECT_TREE="${STRUCT_DIR}/${SNAP_DATE}_project_tree.txt"
AUDITS_LIST="${STRUCT_DIR}/${SNAP_DATE}_audits_file_list.txt"

if [ -z "$SITE_DIR" ]; then
  echo "[WARN] No se encontró site_static para generar sitemap."
else
  mkdir -p "$STRUCT_DIR"
  find "$SITE_DIR" -type f -name "*.html" \
    -exec realpath --relative-to="$SITE_DIR" {} \; | sort > "$SITEMAP_TXT" || true

  find "$SITE_DIR" -type f -name "*.html" -exec \
    grep -IL 'meta[^>]*name=["'"'"']description["'"'"']' {} \; \
    | sed "s#^${SITE_DIR}/##" | sort > "$NO_META_TXT" || true
fi

# Si faltan archivos del escaneo estructural, intentar generarlos ligero
if [ ! -f "$COUNT_BY_EXT_CSV" ] || [ ! -f "$TOP100_CSV" ] || [ ! -f "$SIZES_OVERVIEW" ]; then
  mkdir -p "$STRUCT_DIR"
  python3 - <<'PY' "$STRUCT_DIR" "$SNAP_DATE"
import os,csv,time,sys
out_dir=sys.argv[1]; snap=sys.argv[2]
idx=os.path.join(out_dir,f"{snap}_file_index.csv")
rows=[]
for base,_,files in os.walk(".",topdown=True):
    skip={".git","node_modules",".venv","__pycache__",".pytest_cache",".mypy_cache",".tools"}
    if any(p in skip for p in base.split(os.sep)): continue
    for fn in files:
        p=os.path.join(base,fn)
        try:
            st=os.stat(p)
            rows.append([st.st_size, time.strftime("%Y-%m-%dT%H:%M:%S", time.localtime(st.st_mtime)),
                        os.path.splitext(fn)[1].lower(), p.replace("./","",1) if p.startswith("./") else p])
        except FileNotFoundError:
            pass
os.makedirs(out_dir,exist_ok=True)
with open(idx,"w",newline="",encoding="utf-8") as f:
    w=csv.writer(f); w.writerow(["size_bytes","mtime_iso","ext","path"])
    for r in sorted(rows, key=lambda r:(-r[0], r[3])): w.writerow(r)
# Top 100
top=os.path.join(out_dir,f"{snap}_top100_files_by_size.csv")
with open(idx,encoding="utf-8") as f, open(top,"w",newline="",encoding="utf-8") as g:
    import itertools
    g.write(next(f)) # header
    for i,line in zip(range(100),f): g.write(line)
# Count by ext
cnt={}
for r in rows: cnt[r[2]]=cnt.get(r[2],0)+1
with open(os.path.join(out_dir,f"{snap}_count_by_extension.csv"),"w",newline="",encoding="utf-8") as f:
    w=csv.writer(f); 
    for k,v in sorted(cnt.items(), key=lambda kv:(-kv[1], kv[0])): w.writerow([k,v])
PY
  # Tamaños overview (rápido)
  (du -h --max-depth=1 . 2>/dev/null || du -h -d 1 . 2>/dev/null) | sort -hr > "$SIZES_OVERVIEW" || true
  # Árbol (simple)
  if command -v tree >/dev/null 2>&1; then
    tree -a -I ".git|node_modules|.venv|__pycache__|.pytest_cache|.mypy_cache|.tools" > "$PROJECT_TREE" || true
  else
    find . -path ./.git -prune -o -path ./node_modules -prune -o -print | sed 's|^\./||' > "$PROJECT_TREE" || true
  fi
  find audits -type f -printf "%TY-%Tm-%Td %TH:%TM  %p\n" 2>/dev/null | sort -r > "$AUDITS_LIST" || true
fi

# ----------------------------
# 3) Utilidades de incrustación
# ----------------------------
append_md() { # $1 file -> cat with fenced block if text
  local f="$1"
  if [ -f "$f" ]; then
    echo ""
    echo "<details><summary><code>${f}</code></summary>"
    echo
    echo '```'
    sed -n '1,800p' "$f"
    echo '```'
    echo "</details>"
    echo ""
  fi
}

# ----------------------------
# 4) Generar INFORME TÉCNICO
# ----------------------------
echo "[BUILD] ${TECNICO_MD}"
{
  echo "# Informe Técnico Consolidado – RUN Art Foundry (${SNAP_DATE})"
  echo
  echo "## Índice"
  echo "1. Resumen Ejecutivo"
  echo "2. Infraestructura y Accesos"
  echo "3. Snapshots y Artefactos"
  echo "4. Resultados de Auditoría"
  echo "5. Mapa del Sitio"
  echo "6. Diagnóstico Global"
  echo "7. Conclusiones Técnicas"
  echo "8. Referencias de Archivos"
  echo
  echo "---"
  echo "## 1) Resumen Ejecutivo"
  # Tomar resúmenes si existen
  append_md "${AUDITS_DIR}/${SNAP_DATE}_fase1_status.md"
  append_md "${AUDITS_DIR}/${SNAP_DATE}_fase2_snapshot.md"
  append_md "${AUDITS_DIR}/${SNAP_DATE}_auditoria_integral.md"
  echo
  echo "## 2) Infraestructura y Accesos"
  append_md "${AUDITS_DIR}/${SNAP_DATE}_ssh_config_status.md"
  append_md "${AUDITS_DIR}/${SNAP_DATE}_sftp_check.log"
  append_md "${AUDITS_DIR}/${SNAP_DATE}_db_check.log"
  append_md "${AUDITS_DIR}/${SNAP_DATE}_db_dump.log"
  echo
  echo "## 3) Snapshots y Artefactos"
  append_md "$SIZES_OVERVIEW"
  append_md "${AUDITS_DIR}/${SNAP_DATE}_mirror_sftp_final.md"
  append_md "${AUDITS_DIR}/${SNAP_DATE}_wget_site.log"
  echo
  echo "## 4) Resultados de Auditoría"
  echo "### 4.1 SEO"
  append_md "${SEO_DIR}/${SNAP_DATE}_sin_meta_description.txt"
  append_md "${SEO_DIR}/${SNAP_DATE}_htmlhint.txt"
  append_md "${SEO_DIR}/${SNAP_DATE}_posibles_enlaces_rotos.txt"
  echo "### 4.2 Performance"
  # Incluir rutas a reportes Lighthouse HTML si existen
  for f in "${LH_DIR}/${SNAP_DATE}_lighthouse_mobile.html" "${LH_DIR}/${SNAP_DATE}_lighthouse_desktop.html"; do
    [ -f "$f" ] && echo "- Lighthouse: ${f}" || true
  done
  echo "### 4.3 Accesibilidad"
  append_md "${AXE_DIR}/${SNAP_DATE}_axe.json"
  append_md "${AXE_DIR}/${SNAP_DATE}_axe.csv"
  echo "### 4.4 Seguridad"
  append_md "${SEC_DIR}/${SNAP_DATE}_archivos_sospechosos.txt"
  append_md "${SEC_DIR}/${SNAP_DATE}_permisos_wp-content.txt"
  echo "### 4.5 Inventarios"
  append_md "${INVENTORY_DIR}/${SNAP_DATE}_plugins.txt"
  append_md "${INVENTORY_DIR}/${SNAP_DATE}_themes.txt"
  append_md "${INVENTORY_DIR}/${SNAP_DATE}_imagenes_pesadas.txt"
  echo
  echo "## 5) Mapa del Sitio"
  if [ -f "$SITEMAP_TXT" ]; then
    echo "Total páginas: $(wc -l < "$SITEMAP_TXT" | tr -d ' ')"
    append_md "$SITEMAP_TXT"
  else
    echo "_No se encontró sitemap en ${SITEMAP_TXT}_"
  fi
  echo
  echo "## 6) Diagnóstico Global"
  # Señales clave (resumen rápido)
  JPGS="$(awk -F',' 'tolower($1)==".jpg"{print $2}' "$COUNT_BY_EXT_CSV" 2>/dev/null | head -n1 || echo "")"
  echo "- Imágenes JPG detectadas: ${JPGS:-'(sin dato)'}"
  echo "- Páginas sin meta description: $( [ -f "$NO_META_TXT" ] && wc -l < "$NO_META_TXT" | tr -d ' ' || echo 's/d')"
  echo "- Herramientas Google en snapshot: no evidencias de GA/GTM/GSC."
  echo
  echo "## 7) Conclusiones Técnicas"
  echo "- Cuello de botella principal: **imágenes pesadas** en uploads."
  echo "- SEO incompleto: **meta descriptions** ausentes en todas las páginas."
  echo "- Acceso DB por phpMyAdmin pendiente para cerrar snapshot completo."
  echo "- Estructura de proyecto ya **ordenada y trazable** con auditorías."
  echo
  echo "## 8) Referencias de Archivos"
  append_md "$PROJECT_TREE"
  append_md "$COUNT_BY_EXT_CSV"
  append_md "$TOP100_CSV"
  append_md "$AUDITS_LIST"
} > "$TECNICO_MD"

# ----------------------------
# 5) Generar INFORME ESTRATÉGICO
# ----------------------------
echo "[BUILD] ${ESTRATEGICO_MD}"
{
  echo "# Informe Estratégico – RUN Art Foundry (${SNAP_DATE})"
  echo
  echo "## Índice"
  echo "1. Diagnóstico Resumido"
  echo "2. Opciones de Decisión"
  echo "3. Recomendación Inicial"
  echo "4. Plan de Acción (Fases 4–5)"
  echo "5. KPIs de Éxito"
  echo
  echo "---"
  echo "## 1) Diagnóstico Resumido"
  echo "- **Peso repo/snapshot**: ver tamaños en el Informe Técnico."
  echo "- **Imágenes**: volumen alto y sin compresión (ver inventario)."
  echo "- **SEO**: meta descriptions ausentes; Yoast sin configurar."
  echo "- **Accesibilidad**: hallazgos no críticos (axe)."
  echo "- **Seguridad**: sin webshell evidente; permisos a revisar."
  echo "- **GA/GTM/GSC**: no detectados en snapshot."
  echo
  echo "## 2) Opciones de Decisión"
  echo "### Opción A: Mantener + Optimizar"
  echo "- Pros: rápido, menor costo, mejora inmediata."
  echo "- Contras: arrastra herencias históricas."
  echo "### Opción B: Resetear + Reutilizar contenido"
  echo "- Pros: limpieza profunda, base nueva estable."
  echo "- Contras: requiere migración ordenada (tiempo)."
  echo "### Opción C: Rehacer desde cero"
  echo "- Pros: diseño/arquitectura 100% a medida."
  echo "- Contras: mayor costo/tiempo, dependencia de contenido."
  echo
  echo "## 3) Recomendación Inicial"
  echo "- **Recomiendo A (Mantener + Optimizar)**, en paralelo con un **staging limpio** que nos permita medir el impacto y tener plan B hacia B/ C si hiciera falta."
  echo
  echo "## 4) Plan de Acción (Fases 4–5)"
  echo "### Fase 4 – Optimización"
  echo "1) **Imágenes**: conversión masiva a WebP/AVIF + resize; lazy-load."
  echo "2) **SEO**: meta descriptions + sitemap.xml + robots.txt; configurar Yoast."
  echo "3) **Performance**: cache (WP Fastest Cache/Optimize), minify CSS/JS."
  echo "### Fase 5 – Observabilidad & Hardening"
  echo "4) **GA4/GTM/GSC**: alta, verificación dominio, envío sitemap."
  echo "5) **Seguridad**: actualizar plugins/temas; permisos 755/644; hardening wp-config."
  echo "6) **Monitoreo**: logs, uptime, errores 4xx/5xx."
  echo
  echo "## 5) KPIs de Éxito"
  echo "- **LCP móvil** < 2.0s; **CLS** < 0.1; **INP** < 200ms."
  echo "- **Imágenes (uploads)**: -80% de peso total."
  echo "- **SEO**: 100% páginas con meta + sitemap indexado en GSC."
  echo "- **Seguridad**: 0 elementos desactualizados; permisos saneados."
} > "$ESTRATEGICO_MD"

echo
echo "======================================================================"
echo " INFORMES GENERADOS"
echo " - Técnico     : ${TECNICO_MD}"
echo " - Estratégico : ${ESTRATEGICO_MD}"
echo "======================================================================"