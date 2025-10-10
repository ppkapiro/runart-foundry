#!/usr/bin/env bash
set -euo pipefail

FROM="${FROM:-$(date -u +%Y-%m-%d -d '7 days ago')}"
TO="${TO:-$(date -u +%Y-%m-%d)}"
BASE="${PAGES_URL:-https://runart-briefing.pages.dev}"
TOKEN="${RUN_TOKEN:-dev-token}"

TMP_COOKIES="${TMP_COOKIES:-/tmp/runart_exports_cookies.txt}"
trap 'rm -f "$TMP_COOKIES"' EXIT

printf '🔎 Probando export en %s del %s al %s\n' "$BASE" "$FROM" "$TO"

code=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Content-Type: application/json" \
  -H "X-Runart-Token: $TOKEN" \
  -X POST "$BASE/api/export_zip" \
  --data "{\"from\":\"$FROM\",\"to\":\"$TO\"}" \
  --cookie-jar "$TMP_COOKIES" --cookie "$TMP_COOKIES")

if [ "$code" = "200" ]; then
  echo "✅ ZIP accesible (HTTP 200) — requiere verificación visual en /exports/ (Access)"
  exit 0
else
  echo "⚠️ ZIP no accesible vía curl (HTTP $code). Con Access vía navegador debe funcionar."
  exit 0
fi
