#!/usr/bin/env bash
set -euo pipefail
umask 077

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

ENV_FILE="$HOME/.runart/env"
[ -f "$ENV_FILE" ] && . "$ENV_FILE"

missing=()
for v in CLOUDFLARE_API_TOKEN ACCESS_CLIENT_ID ACCESS_CLIENT_SECRET CLOUDFLARE_ACCOUNT_ID NAMESPACE_ID_RUNART_ROLES_PREVIEW; do
  [ -z "${!v:-}" ] && missing+=("$v")
done

if [ "${#missing[@]}" -gt 0 ]; then
  echo "⚠️  Faltan variables: ${missing[*]}"
  echo "Abriendo asistente de configuración…"
  "$ROOT/scripts/runart_env_setup.sh"
  . "$ENV_FILE"
fi

for v in CLOUDFLARE_API_TOKEN ACCESS_CLIENT_ID ACCESS_CLIENT_SECRET CLOUDFLARE_ACCOUNT_ID NAMESPACE_ID_RUNART_ROLES_PREVIEW; do
  [ -z "${!v:-}" ] && { echo "❌ Sigue faltando $v. Aborta."; exit 1; }
done

command -v jq >/dev/null 2>&1 || { sudo apt-get update -y >/dev/null 2>&1 && sudo apt-get install -y jq >/dev/null 2>&1; }
command -v gh >/dev/null 2>&1 || { echo "❌ Falta GitHub CLI (gh)"; exit 1; }

TS="$(date -u +%Y%m%dT%H%M%SZ)"
LOG="phase2_fix_${TS}.log"
echo "# RUNART Fase2 — ${TS} (ES)" | tee "$LOG"

ACC_ID="$CLOUDFLARE_ACCOUNT_ID"
NS_PREVIEW="$NAMESPACE_ID_RUNART_ROLES_PREVIEW"

echo "🆔 Account: $ACC_ID" | tee -a "$LOG"
echo "📦 Namespace preview: $NS_PREVIEW" | tee -a "$LOG"

cat > /tmp/runart_roles_preview.json <<'JSON'
{
  "ppcapiro@gmail.com": "owner",
  "officemagerhealthkendall@gmail.com": "team",
  "musicmanagercuba@gmail.com": "client_admin",
  "shop.artmarketpremium@gmail.com": "client"
}
JSON

cat > /tmp/canary_whitelist_preview.json <<'JSON'
[
  "ppcapiro@gmail.com",
  "officemagerhealthkendall@gmail.com",
  "musicmanagercuba@gmail.com",
  "shop.artmarketpremium@gmail.com"
]
JSON

echo "🌱 PUT RUNART_ROLES…" | tee -a "$LOG"
curl -fsS -X PUT \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: text/plain" \
  --data "$(jq -c . /tmp/runart_roles_preview.json)" \
  "https://api.cloudflare.com/client/v4/accounts/$ACC_ID/storage/kv/namespaces/$NS_PREVIEW/values/RUNART_ROLES" | jq . | tee -a "$LOG"

echo "🌱 PUT CANARY_ROLE_RESOLVER_EMAILS…" | tee -a "$LOG"
curl -fsS -X PUT \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: text/plain" \
  --data "$(jq -c . /tmp/canary_whitelist_preview.json)" \
  "https://api.cloudflare.com/client/v4/accounts/$ACC_ID/storage/kv/namespaces/$NS_PREVIEW/values/CANARY_ROLE_RESOLVER_EMAILS" | jq . | tee -a "$LOG"

echo "🔎 GET RUNART_ROLES:" | tee -a "$LOG"
curl -fsS -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  "https://api.cloudflare.com/client/v4/accounts/$ACC_ID/storage/kv/namespaces/$NS_PREVIEW/values/RUNART_ROLES" | jq . | tee -a "$LOG"

echo "🔎 GET CANARY_ROLE_RESOLVER_EMAILS:" | tee -a "$LOG"
curl -fsS -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  "https://api.cloudflare.com/client/v4/accounts/$ACC_ID/storage/kv/namespaces/$NS_PREVIEW/values/CANARY_ROLE_RESOLVER_EMAILS" | jq . | tee -a "$LOG"

HOST="https://runart-foundry.pages.dev"
echo "🌐 Probar Access contra ${HOST}/api/whoami…" | tee -a "$LOG"
curl -sI "${HOST}/api/whoami" \
  -H "User-Agent: runart-ci/diag" \
  -H "CF-Access-Client-Id: ${ACCESS_CLIENT_ID}" \
  -H "CF-Access-Client-Secret: ${ACCESS_CLIENT_SECRET}" | sed -n '1,20p' | tee -a "$LOG"

echo "🚀 Disparando workflow de diagnóstico…" | tee -a "$LOG"
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
gh workflow run ".github/workflows/run_canary_diagnostics.yml" \
  --ref "$BRANCH" \
  -f preview_host="" \
  -f owner="ppcapiro@gmail.com" \
  -f team="officemagerhealthkendall@gmail.com" \
  -f client_admin="musicmanagercuba@gmail.com" \
  -f client="shop.artmarketpremium@gmail.com" \
  -f control_legacy="runartfoundry@gmail.com"

echo "⏳ Esperando 10s para que el workflow se registre…" | tee -a "$LOG"
sleep 10
RUN_ID=$(gh run list --workflow="run_canary_diagnostics.yml" --branch="$BRANCH" --limit=1 --json databaseId --jq '.[0].databaseId')

echo "🆔 Run ID: $RUN_ID" | tee -a "$LOG"
gh run watch "$RUN_ID" --exit-status

OUT_DIR="ci_artifacts/diag_${RUN_ID}"
mkdir -p "$OUT_DIR"
gh run download "$RUN_ID" --dir "$OUT_DIR" || true

RESUMEN="$(ls -1 "$OUT_DIR"/apps/briefing/_reports/roles_canary_preview/RESUMEN_*.md 2>/dev/null | tail -n 1 || true)"
echo "📘 RESUMEN: ${RESUMEN:-<no encontrado>}" | tee -a "$LOG"
[ -n "$RESUMEN" ] && sed -n '1,200p' "$RESUMEN" || echo "⚠️ No se encontró RESUMEN (revisa logs del run)."

echo "✅ Fase 2 finalizada."
