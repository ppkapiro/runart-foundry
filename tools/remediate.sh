#!/usr/bin/env bash
set -euo pipefail
ACTION="${1:-}"
echo "[remediate] ACTION=$ACTION"
case "$ACTION" in
  retry_verify)
    gh workflow run verify-home.yml || true
    gh workflow run verify-settings.yml || true
    gh workflow run verify-menus.yml || true
    gh workflow run verify-media.yml || true
    ;;
  rotate_app_password_if_persistent)
    bash tools/rotate_wp_app_password.sh || true
    ;;
  flush_cache)
    # Si WP-CLI disponible en staging:
    ssh -p ${SSH_PORT:-22} "$IONOS_SSH_HOST" "wp cache flush --path=/staging || true"
    ;;
  sync_menus)
    # placeholder: aquí invocarías endpoint/CLI que regenere menús con manifest
    echo "[remediate] menus sync (placeholder no destructivo)"
    ;;
  sync_media)
    # placeholder: reintento de sync media contra manifest
    echo "[remediate] media sync (placeholder no destructivo)"
    ;;
  *)
    echo "[remediate] acción no reconocida"
    exit 0
    ;;
esac
