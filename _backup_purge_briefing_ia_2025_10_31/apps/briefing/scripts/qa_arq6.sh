#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BRIEFING_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
MKDOCS_FILE="${BRIEFING_ROOT}/mkdocs.yml"
OVERRIDES_FILE="${BRIEFING_ROOT}/overrides/main.html"

run_step() {
  local description="$1"
  echo "[QA] ${description}"
}

run_step "Build MkDocs (make venv && make build)"
(
  cd "${BRIEFING_ROOT}" && make venv && make build
)

run_step "Verificar navegación Dashboards/KPIs"
grep -q 'Dashboards' "${MKDOCS_FILE}"
grep -q 'KPIs (cliente)' "${MKDOCS_FILE}"

grep -q 'Herramientas' "${MKDOCS_FILE}"
grep -q 'Exportaciones (MF)' "${MKDOCS_FILE}"

run_step "Verificar archivos clave de documentación"
required_files=(
  "${BRIEFING_ROOT}/docs/editor/index.md"
  "${BRIEFING_ROOT}/docs/inbox/index.md"
  "${BRIEFING_ROOT}/docs/dashboards/cliente.md"
  "${BRIEFING_ROOT}/docs/exports/index.md"
)
for file in "${required_files[@]}"; do
  if [[ ! -f "${file}" ]]; then
    echo "Archivo faltante: ${file}" >&2
    exit 1
  fi
done

run_step "Verificar patrones de roles en overrides/main.html"
grep -q '\^/editor/' "${OVERRIDES_FILE}"
grep -q '\^/exports/' "${OVERRIDES_FILE}"

run_step "Verificar accesibilidad mínima en editor e inbox"
grep -Eq 'role="status"|aria-live' "${BRIEFING_ROOT}/docs/editor/index.md"
grep -Eq 'role="status"|aria-live' "${BRIEFING_ROOT}/docs/inbox/index.md"

echo "QA ARQ-6 OK"
