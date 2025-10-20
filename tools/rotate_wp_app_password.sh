#!/usr/bin/env bash
set -euo pipefail
# Rotación solo en STAGING; no imprime secretos.
echo "[rotate] Rotando App Password (staging)…"
NEW=$(python3 - <<'PY'
import secrets,string
print(''.join(secrets.choice(string.ascii_letters+string.digits) for _ in range(24)))
PY
)
# Actualiza secreto en GitHub (no imprime valor):
gh secret set WP_APP_PASSWORD --body "$NEW"
echo "[rotate] WP_APP_PASSWORD actualizado en GitHub Secrets (staging)."
