#!/usr/bin/env bash
set -euo pipefail
OUT_DIR="_dist"
PKG_NAME="runart-foundry-template_v1.0_$(date +%Y%m%d_%H%M%S).tar.gz"
mkdir -p "$OUT_DIR"

# Lista de exclusiones (NO SECRETOS / NO LOGS / NO ARTEFACTOS)
EXCLUDES=(
  --exclude-vcs
  --exclude=".git*"
  --exclude=".env*"
  --exclude=".DS_Store"
  --exclude="node_modules"
  --exclude="logs"
  --exclude="_reports/*"
  --exclude="_dist/*"
  --exclude=".vscode"
  --exclude=".idea"
  --exclude="**/evidencia_*"
  --exclude="**/*_summary.txt"
  --exclude="**/staging_dns_check.log"
  --exclude="**/staging_http_fix_*"
  --exclude="**/audit_latest.*"
)

# Archivo README de la plantilla
cat > "$OUT_DIR/README_TEMPLATE.md" <<'MD'
# RunArt Foundry — Template v1.0
Incluye CI/CD verify-*, monitor (F8), auditoría IA + auto-remediación (F9), y bitácora de ejemplo.
## Pasos rápidos
1. Configure GitHub Variables/Secrets (WP_BASE_URL, WP_USER, WP_APP_PASSWORD)
2. Ejecute verify-* y audit-and-remediate
3. Publique MVP en staging (scripts incluidos)
MD

# Crear paquete desde raíz del repo (.) con exclusiones
tar czf "$OUT_DIR/$PKG_NAME" \
  "${EXCLUDES[@]}" \
  --transform='s,^\.,runart-foundry-template/,' \
  .

echo "[OK] Paquete: $OUT_DIR/$PKG_NAME"
shasum -a 256 "$OUT_DIR/$PKG_NAME" > "$OUT_DIR/$PKG_NAME.sha256"
echo "[OK] SHA256: $(cat "$OUT_DIR/$PKG_NAME.sha256")"
