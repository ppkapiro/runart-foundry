#!/usr/bin/env bash
#
# Post-procesador de artefactos del workflow run_canary_diagnostics.yml (Bash version)
#
# PROPÓSITO:
#   Descarga el artefacto RESUMEN de la última ejecución exitosa del workflow
#   de diagnóstico canary y copia el RESUMEN_*.md a la carpeta de evidencia.
#
# REQUISITOS:
#   - GitHub CLI (gh) autenticado
#   - jq (para parsear JSON)
#
# USO:
#   bash tools/diagnostics/postprocess_canary_summary.sh
#
# SALIDA:
#   - Archivo RESUMEN copiado a: docs/internal/security/evidencia/RESUMEN_PREVIEW_YYYYMMDD_HHMM.md
#   - Imprime run_id, status, y ruta del RESUMEN guardado
#
# CÓDIGOS DE SALIDA:
#   0 - Éxito
#   1 - Error

set -euo pipefail

echo "═══════════════════════════════════════════════════════════════════"
echo "  RUNART | Post-procesador de RESUMEN Canary Diagnostics"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

# 1. Buscar la última ejecución exitosa del workflow
echo "🔍 Buscando última ejecución exitosa de run_canary_diagnostics.yml..."
run_json=$(gh run list \
    --workflow=run_canary_diagnostics.yml \
    --status=success \
    --limit=1 \
    --json databaseId,conclusion,createdAt,displayTitle)

if [ -z "$run_json" ] || [ "$run_json" == "[]" ]; then
    echo "❌ ERROR: No se encontró ningún run exitoso del workflow"
    echo "   Asegúrate de que el workflow haya corrido al menos una vez con éxito"
    exit 1
fi

run_id=$(echo "$run_json" | jq -r '.[0].databaseId')
conclusion=$(echo "$run_json" | jq -r '.[0].conclusion')
created_at=$(echo "$run_json" | jq -r '.[0].createdAt')
title=$(echo "$run_json" | jq -r '.[0].displayTitle')

echo "✅ Run encontrado:"
echo "   • Run ID: $run_id"
echo "   • Conclusión: $conclusion"
echo "   • Fecha: $created_at"
echo "   • Título: $title"
echo ""

# 2. Crear directorio temporal para descarga
temp_dir="./_tmp/canary_artifacts_$(date +%Y%m%d%H%M%S)"
mkdir -p "$temp_dir"
echo "📁 Directorio temporal: $temp_dir"
echo ""

# 3. Descargar artefactos del run
echo "📡 Descargando artefactos del run $run_id..."
if ! gh run download "$run_id" --dir "$temp_dir"; then
    echo "❌ ERROR: Fallo al descargar artefactos"
    exit 1
fi

echo "✅ Artefactos descargados"
echo ""

# 4. Buscar archivo RESUMEN_*.md
resumen_file=$(find "$temp_dir" -type f -name "RESUMEN_*.md" | head -n 1)

if [ -z "$resumen_file" ]; then
    echo "❌ ERROR: No se encontró ningún archivo RESUMEN_*.md en los artefactos"
    echo "   Archivos descargados:"
    find "$temp_dir" -type f | while read -r f; do echo "   • $f"; done
    exit 1
fi

echo "✅ RESUMEN encontrado: $(basename "$resumen_file")"
echo ""

# 5. Crear directorio de evidencia si no existe
evidencia_dir="docs/internal/security/evidencia"
mkdir -p "$evidencia_dir"

# 6. Copiar RESUMEN con timestamp
timestamp=$(date +%Y%m%d_%H%M)
target_filename="RESUMEN_PREVIEW_${timestamp}.md"
target_path="${evidencia_dir}/${target_filename}"

cp "$resumen_file" "$target_path"
echo "✅ RESUMEN copiado a: $target_path"
echo ""

# 7. Mostrar contenido del RESUMEN (primeras 50 líneas)
echo "📄 Contenido del RESUMEN (primeras 50 líneas):"
echo "───────────────────────────────────────────────────────────────────"
head -n 50 "$target_path"
echo "───────────────────────────────────────────────────────────────────"
echo ""

# 8. Limpiar directorio temporal
rm -rf "$temp_dir"
echo "🗑️  Directorio temporal eliminado"
echo ""

# 9. Salida final
echo "═══════════════════════════════════════════════════════════════════"
echo "✅ POST-PROCESAMIENTO EXITOSO"
echo "   • Run ID: $run_id"
echo "   • RESUMEN guardado en: $target_path"
echo "   • Listo para agregar al changelog de secretos"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
exit 0
