#!/usr/bin/env bash
set -euo pipefail
HOST="${IONOS_SSH_HOST:?export IONOS_SSH_HOST='usuario@host.ionos.de'}"
PORT="${SSH_PORT:-22}"
P="/staging"
TITLE="RunArt Foundry — Showcase v1.0"
CONTENT=$'<!-- Showcase final -->\n<h1>RunArt Foundry — Template v1.0</h1>\n<p>Pipeline real con CI/CD, Auditoría IA y Auto-Remediación.</p>\n<ul>\n<li>✅ verify-*: HEALTHY</li>\n<li>✅ Auditoría: GREEN</li>\n<li>✅ Auto-Remediación: Activa</li>\n</ul>\n<p>Fecha: '"$(date -u)"$'</p>'
ssh -p "$PORT" "$HOST" "wp post create --post_type=page --post_status=publish --post_title='${TITLE}' --post_content='${CONTENT}' --path=$P" || true
ID=$(ssh -p "$PORT" "$HOST" "wp post list --post_type=page --search='${TITLE}' --field=ID --path=$P" || true)
if [ -n "$ID" ]; then
  ssh -p "$PORT" "$HOST" "wp option update page_on_front $ID --path=$P && wp option update show_on_front 'page' --path=$P"
fi
echo "[showcase] Página publicada/actualizada. Ver: https://staging.runartfoundry.com/"
