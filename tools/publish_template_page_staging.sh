#!/usr/bin/env bash
set -euo pipefail
HOST="${IONOS_SSH_HOST:?export IONOS_SSH_HOST='usuario@host.ionos.de'}"
PORT="${SSH_PORT:-22}"
P="/staging"
TITLE="RunArt Foundry — Template v1.0"
CONTENT="<h1>RunArt Foundry — Template v1.0</h1><p>Plantilla base con CI/CD, auditoría IA y auto-remediación activa. Fecha: $(date -u)</p><p>Repositorio listo para replicar proyectos con verificación y seguridad continua.</p>"

echo "[publish] Publicando página de presentación en STAGING…"
ssh -p "$PORT" "$HOST" "wp post create --post_type=page --post_status=publish --post_title='${TITLE}' --post_content='${CONTENT}' --path=$P" || true
# Opcional: ponerla como front page
ID=$(ssh -p "$PORT" "$HOST" "wp post list --post_type=page --search='${TITLE}' --field=ID --path=$P" || true)
if [ -n "$ID" ]; then
  ssh -p "$PORT" "$HOST" "wp option update page_on_front $ID --path=$P && wp option update show_on_front 'page' --path=$P"
fi
echo "[publish] Listo. Verifica en https://staging.runartfoundry.com/"
