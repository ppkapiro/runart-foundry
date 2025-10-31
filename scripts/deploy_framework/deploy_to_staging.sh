#!/usr/bin/env bash
set -euo pipefail

# Deployment controlado a STAGING (RunArt Base v2)
# Uso: ./deploy_to_staging.sh --branch feat/ai-visual-implementation [--real-deploy]
# Requisitos:
#   - STAGING_SSH (usuario@host)
#   - STAGING_PATH (/var/www/html)
#   - WP_CLI_PATH (ruta a wp, ej: /usr/local/bin/wp)
#   - El plugin será desplegado en wp-content/plugins/runart-wpcli-bridge

BRANCH=""
REAL=0
for arg in "$@"; do
  case "$arg" in
    --branch)
      shift; BRANCH="$1"; shift;;
    --real-deploy)
      REAL=1; shift;;
  esac
done

if [[ -z "$BRANCH" ]]; then
  echo "❌ Debe indicar --branch <nombre>"; exit 1;
fi

if [[ -z "${STAGING_SSH:-}" || -z "${STAGING_PATH:-}" ]]; then
  echo "❌ Faltan variables STAGING_SSH o STAGING_PATH"
  exit 1
fi

PLUGIN_DIR_REMOTE="$STAGING_PATH/wp-content/plugins/runart-wpcli-bridge"

# Preparar paquete temporal del plugin y docs necesarios
TMPDIR=$(mktemp -d)
mkdir -p "$TMPDIR/plugin" "$TMPDIR/docs" "$TMPDIR/reports"

# Exportar plugin y docs desde la rama indicada
git fetch origin "$BRANCH"
# Empaquetar solo el plugin y docs/bitácora
rsync -a tools/wpcli-bridge-plugin/ "$TMPDIR/plugin/"
rsync -a docs/ai/ "$TMPDIR/docs/ai/" || true
rsync -a _reports/BITACORA_AUDITORIA_V2.md "$TMPDIR/reports/" || true

if [[ "$REAL" -eq 0 ]]; then
  echo "🔎 DRY-RUN: Mostraría archivos a copiar al remoto:"
  find "$TMPDIR" -maxdepth 3 -type f | sed "s|$TMPDIR/||g"
  echo "Use --real-deploy para ejecutar copia y activación."
  exit 0
fi

set -x
# Crear directorio destino y copiar
ssh "$STAGING_SSH" "mkdir -p '$PLUGIN_DIR_REMOTE'"
rsync -av "$TMPDIR/plugin/" "$STAGING_SSH:$PLUGIN_DIR_REMOTE/"
# Activar plugin (dispara hook de activación para crear la página)
ssh "$STAGING_SSH" "cd '$STAGING_PATH' && wp plugin activate runart-wpcli-bridge || true"
set +x

echo "✅ Deployment finalizado (plugin actualizado)."
