#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Uso: $0 <PR_NUMBER>" >&2
  exit 1
fi

PR_NUMBER="$1"
OWNER_REPO="$(git config --get remote.origin.url | sed -E 's#(git@|https://)github.com[:/](.+)\.git#\2#')"
echo "[i] Consultando checks del PR #$PR_NUMBER en $OWNER_REPO ..."

gh pr view "$PR_NUMBER" --json headRefOid -q '.headRefOid' > /tmp/prsha.txt
SHA="$(cat /tmp/prsha.txt)"

gh api "repos/$OWNER_REPO/commits/$SHA/check-runs" -H "Accept: application/vnd.github+json" \
  | jq -r '.check_runs[].name' \
  | tr '[:upper:]' '[:lower:]' \
  | grep -E "(cloudflare pages|pages preview|deploy preview)" \
  && echo "OK: Pages Preview detectado" \
  || { echo "ERROR: No se detectó Pages Preview"; exit 1; }
