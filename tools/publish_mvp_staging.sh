#!/usr/bin/env bash
set -euo pipefail
HOST="$IONOS_SSH_HOST"
P="/staging"
echo "[mvp] Creando página MVP en STAGING…"
ssh -p ${SSH_PORT:-22} "$HOST" "wp post create --post_type=page --post_status=publish --post_title='RunArt Foundry — Preview' --post_content='<h1>RunArt Foundry</h1><p>Staging listo. Auditoría F9 activa.</p>' --path=$P"
ssh -p ${SSH_PORT:-22} "$HOST" "wp option update show_on_front 'page' --path=$P"
HOME_ID=$(ssh -p ${SSH_PORT:-22} "$HOST" "wp post list --post_type=page --name=runart-foundry-preview --field=ID --path=$P" || true)
if [ -n "$HOME_ID" ]; then
  ssh -p ${SSH_PORT:-22} "$HOST" "wp option update page_on_front $HOME_ID --path=$P"
fi
echo "[mvp] Publicado. Verifica en https://staging.runartfoundry.com/"
