#!/usr/bin/env bash
#
# append_bitacora.sh — Añade entrada a la Bitácora Iterativa
#
# Uso:
#   bash tools/log/append_bitacora.sh "Título" "Descripción" ["Branch"] ["PR"] ["Commit"]
#
# Ejemplo:
#   bash tools/log/append_bitacora.sh "F2: Inventario completado" "200+ imágenes catalogadas" "feat/content-audit-v2-phase2" "#78" "abc1234"
#

set -euo pipefail

# Parámetros
TITULO="${1:-}"
DESCRIPCION="${2:-}"
BRANCH="${3:-}"
PR="${4:-}"
COMMIT="${5:-}"

# Archivo bitácora
BITACORA="_reports/BITACORA_AUDITORIA_V2.md"

# Validaciones
if [[ -z "$TITULO" ]]; then
  echo "❌ Error: Falta parámetro TITULO"
  echo "Uso: bash $0 \"Título\" \"Descripción\" [\"Branch\"] [\"PR\"] [\"Commit\"]"
  exit 1
fi

if [[ ! -f "$BITACORA" ]]; then
  echo "❌ Error: No se encuentra $BITACORA"
  exit 1
fi

# Generar timestamp ISO8601
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Construir entrada
ENTRADA="### $TIMESTAMP — $TITULO"
[[ -n "$BRANCH" ]] && ENTRADA+="\n**Branch:** \`$BRANCH\`"
[[ -n "$PR" ]] && ENTRADA+="\n**PR:** $PR"
[[ -n "$COMMIT" ]] && ENTRADA+="\n**Commit:** \`$COMMIT\`"
ENTRADA+="\n**Autor:** $(git config user.name || echo "Unknown")"
ENTRADA+="\n\n**Resumen:**\n$DESCRIPCION"
ENTRADA+="\n\n**Resultado:** 🔄 En progreso\n\n---"

# Encontrar línea de inserción (después de "## Eventos (Registro Cronológico Inverso)")
MARKER="## Eventos (Registro Cronológico Inverso)"
LINEA=$(grep -n "^$MARKER" "$BITACORA" | head -1 | cut -d: -f1)

if [[ -z "$LINEA" ]]; then
  echo "❌ Error: No se encontró el marcador '$MARKER' en $BITACORA"
  exit 1
fi

# Insertar después del marcador + 1 línea vacía
LINEA_INSERT=$((LINEA + 2))

# Backup temporal
cp "$BITACORA" "$BITACORA.bak"

# Insertar entrada
{
  head -n "$LINEA_INSERT" "$BITACORA"
  echo -e "$ENTRADA"
  tail -n +$((LINEA_INSERT + 1)) "$BITACORA"
} > "$BITACORA.tmp"

mv "$BITACORA.tmp" "$BITACORA"

echo "✅ Entrada añadida a $BITACORA:"
echo ""
echo -e "$ENTRADA"
echo ""
echo "💡 Recuerda actualizar el 'Resultado' manualmente si es necesario"
echo "💡 Para commitear: git add $BITACORA && git commit -m 'docs: update bitácora ($TITULO)'"

# Limpiar backup
rm -f "$BITACORA.bak"
