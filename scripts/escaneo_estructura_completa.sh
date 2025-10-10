#!/bin/bash
# ======================================================================
# Escaneo de Estructura desde la RAÍZ del proyecto (descubrimiento total)
# Objetivo: entender distribución completa de carpetas/archivos, tamaños,
# inventarios y artefactos clave para que Copilot (y tú) tengan el mapa.
# Salida: todo queda en audits/_structure/ y un resumen Markdown.
# ======================================================================

set -euo pipefail

# 0) Determinar raíz del repo/proyecto
if git rev-parse --show-toplevel >/dev/null 2>&1; then
  ROOT_DIR="$(git rev-parse --show-toplevel)"
else
  ROOT_DIR="$PWD"
fi
cd "$ROOT_DIR"

RUN_DATE="$(date +%F)"
OUT_DIR="audits/_structure"
mkdir -p "$OUT_DIR"

echo "[INFO] Raíz del proyecto: $ROOT_DIR"
echo "[INFO] Carpeta de salida: $OUT_DIR"

# 1) Inventario de directorios de primer y segundo nivel (con tamaños)
#    (rápido y suficiente para tener la foto grande)
{
  echo "=== TAMAÑOS (nivel 1) ==="
  du -h -d 1 . 2>/dev/null | sort -hr || du -h --max-depth=1 . 2>/dev/null | sort -hr
  echo
  echo "=== TAMAÑOS (nivel 2) ==="
  du -h -d 2 . 2>/dev/null | sort -hr || du -h --max-depth=2 . 2>/dev/null | sort -hr
} > "${OUT_DIR}/${RUN_DATE}_sizes_overview.txt"

# 2) Árbol del proyecto (si 'tree' existe usamos tree, si no, fallback con find)
if command -v tree >/dev/null 2>&1; then
  tree -a -I ".git|node_modules|.venv|__pycache__|.pytest_cache|.mypy_cache|.DS_Store" \
       > "${OUT_DIR}/${RUN_DATE}_project_tree.txt"
else
  echo "[WARN] 'tree' no disponible; usando 'find' como alternativa."
  find . -path ./.git -prune -o -path ./node_modules -prune -o -print \
    | sed 's|^\./||' \
    > "${OUT_DIR}/${RUN_DATE}_project_tree.txt"
fi

# 3) Índice de archivos (CSV) con tamaño, fecha, extensión y ruta
#    Útil para filtrar por tipos, ordenar por peso, etc.
python3 - <<'PY' "${OUT_DIR}/${RUN_DATE}_file_index.csv"
import os, csv, time, sys
out = sys.argv[1]
rows=[]
for base, _, files in os.walk(".", topdown=True):
    if any(part in {".git","node_modules",".venv","__pycache__",".pytest_cache",".mypy_cache"} for part in base.split(os.sep)):
        continue
    for fn in files:
        p=os.path.join(base,fn)
        try:
            st=os.stat(p)
            ext=(os.path.splitext(fn)[1].lower() or "")
            rows.append({
              "size_bytes": st.st_size,
              "mtime_iso": time.strftime("%Y-%m-%dT%H:%M:%S", time.localtime(st.st_mtime)),
              "ext": ext,
              "path": p.replace("./","",1) if p.startswith("./") else p
            })
        except FileNotFoundError:
            pass
with open(out,"w",newline="",encoding="utf-8") as f:
    w=csv.DictWriter(f, fieldnames=["size_bytes","mtime_iso","ext","path"])
    w.writeheader(); w.writerows(sorted(rows, key=lambda r: (-r["size_bytes"], r["path"])))
PY

# 4) Top archivos más pesados (para atacar rápido)
(head -n 101 "${OUT_DIR}/${RUN_DATE}_file_index.csv" | sed -n '1p;2,$p' > /dev/null) || true
awk -F',' 'NR==1 || NR<=101 {print}' "${OUT_DIR}/${RUN_DATE}_file_index.csv" \
  > "${OUT_DIR}/${RUN_DATE}_top100_files_by_size.csv"

# 5) Conteo por extensión (para ver la composición del repo)
awk -F',' 'NR>1{cnt[$3]++} END{for (k in cnt) printf "%s,%d\n", k, cnt[k]}' \
  "${OUT_DIR}/${RUN_DATE}_file_index.csv" \
  | sort -t',' -k2,2nr \
  > "${OUT_DIR}/${RUN_DATE}_count_by_extension.csv"

# 6) Foto de carpetas clave si existen (mirror/, audits/, docs/, source/, scripts/)
for d in mirror audits docs source scripts; do
  if [ -d "$d" ]; then
    {
      echo "=== ${d}/ (nivel 1) ==="
      du -h -d 1 "$d" 2>/dev/null | sort -hr || du -h --max-depth=1 "$d" 2>/dev/null | sort -hr
      echo
      echo "=== Estructura de ${d}/ ==="
      find "$d" -maxdepth 3 -type d | sed 's|^\./||'
      echo
    } > "${OUT_DIR}/${RUN_DATE}_${d}_overview.txt"
  fi
done

# 7) Mapa del sitio (si existe snapshot estático)
SITE_DIR="mirror/raw/${RUN_DATE}/site_static"
if [ ! -d "$SITE_DIR" ]; then
  # fallback: usar el último snapshot disponible
  LAST_SNAP="$(ls -1dt mirror/raw/*/ 2>/dev/null | head -n1 || true)"
  if [ -n "$LAST_SNAP" ] && [ -d "${LAST_SNAP}/site_static" ]; then
    SITE_DIR="${LAST_SNAP}/site_static"
  fi
fi

if [ -d "$SITE_DIR" ]; then
  find "$SITE_DIR" -type f -name "*.html" \
    -exec realpath --relative-to="$SITE_DIR" {} \; | sort \
    > "${OUT_DIR}/${RUN_DATE}_sitemap.txt"

  # Páginas sin meta description
  find "$SITE_DIR" -type f -name "*.html" -exec \
    grep -IL 'meta[^>]*name=["'"'"']description["'"'"']' {} \; \
    | sed "s#^${SITE_DIR}/##" | sort \
    > "${OUT_DIR}/${RUN_DATE}_no_meta_description.txt"
else
  echo "[WARN] No se encontró snapshot estático en ${SITE_DIR}. Saltando sitemap." \
    | tee "${OUT_DIR}/${RUN_DATE}_sitemap_WARN.txt"
fi

# 8) Estado de AUDITS existente (qué hay y dónde)
{
  echo "=== LISTADO de archivos en audits/ ==="
  find audits -type f -printf "%TY-%Tm-%Td %TH:%TM  %p\n" | sort -r
} > "${OUT_DIR}/${RUN_DATE}_audits_file_list.txt"

# 9) Detección de scripts en ubicaciones "no deseadas" (p.ej., raíz de audits/)
#    para ordenar luego (solo listamos, NO movemos nada todavía)
{
  echo "=== POSIBLES SCRIPTS EN RAÍZ DE audits/ ==="
  ls -1 audits 2>/dev/null | grep -Ei '\.(sh|bash|ps1|py|js)$' || echo "(no se detectaron)"
} > "${OUT_DIR}/${RUN_DATE}_audits_root_scripts.txt"

# 10) Resumen Markdown para lectura humana (para abrir rápido en VSCode)
SUMMARY="${OUT_DIR}/${RUN_DATE}_resumen_estructura.md"
{
  echo "# Resumen de Estructura del Proyecto"
  echo "- Fecha: ${RUN_DATE}"
  echo "- Raíz: \`${ROOT_DIR}\`"
  echo
  echo "## Archivos generados"
  echo "- **Tamaños globales**: \`${OUT_DIR}/${RUN_DATE}_sizes_overview.txt\`"
  echo "- **Árbol del proyecto**: \`${OUT_DIR}/${RUN_DATE}_project_tree.txt\`"
  echo "- **Índice de archivos (CSV)**: \`${OUT_DIR}/${RUN_DATE}_file_index.csv\`"
  echo "- **Top 100 por tamaño (CSV)**: \`${OUT_DIR}/${RUN_DATE}_top100_files_by_size.csv\`"
  echo "- **Conteo por extensión (CSV)**: \`${OUT_DIR}/${RUN_DATE}_count_by_extension.csv\`"
  echo "- **mirror/**: \`${OUT_DIR}/${RUN_DATE}_mirror_overview.txt\` (si existe)"
  echo "- **audits/**: \`${OUT_DIR}/${RUN_DATE}_audits_overview.txt\` (si existe) y \`${OUT_DIR}/${RUN_DATE}_audits_file_list.txt\`"
  echo "- **docs/**: \`${OUT_DIR}/${RUN_DATE}_docs_overview.txt\` (si existe)"
  echo "- **source/**: \`${OUT_DIR}/${RUN_DATE}_source_overview.txt\` (si existe)"
  echo "- **scripts/**: \`${OUT_DIR}/${RUN_DATE}_scripts_overview.txt\` (si existe)"
  if [ -d "$SITE_DIR" ]; then
    echo "- **Sitemap (TXT)**: \`${OUT_DIR}/${RUN_DATE}_sitemap.txt\`"
    echo "- **Pág. sin meta description**: \`${OUT_DIR}/${RUN_DATE}_no_meta_description.txt\`"
  else
    echo "- **Sitemap**: no generado (no se encontró \`${SITE_DIR}\`)."
  fi
  echo
  echo "## Observaciones rápidas"
  echo "- Usa los CSV para filtrar y priorizar archivos pesados o tipos específicos."
  echo "- Revisa \`${OUT_DIR}/${RUN_DATE}_audits_root_scripts.txt\` para ver scripts sueltos en audits/."
  echo "- Abre \`${OUT_DIR}/${RUN_DATE}_sizes_overview.txt\` para detectar directorios con mayor peso."
} > "$SUMMARY"

echo
echo "======================================================================"
echo " ESCANEO COMPLETO DE ESTRUCTURA FINALIZADO"
echo " - Revisa: ${SUMMARY}"
echo " - Salidas en: ${OUT_DIR}"
echo "======================================================================"