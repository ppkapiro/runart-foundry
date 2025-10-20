#!/usr/bin/env bash
set -euo pipefail
HOST="${IONOS_SSH_HOST:?export IONOS_SSH_HOST='usuario@host.ionos.de'}"
PORT="${SSH_PORT:-22}"
P="/staging"
ssh -p "$PORT" "$HOST" "printf 'User-agent: *\nDisallow: /\n' > ${P}/robots.txt && chmod 644 ${P}/robots.txt"
echo "[privacy] robots.txt anti-index creado en ${P}/robots.txt"
