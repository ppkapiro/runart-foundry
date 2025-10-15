#!/usr/bin/env bash
set -euo pipefail

# Ubicación de apps/briefing
BRIEFING_DIR="$(dirname "$0")/../../apps/briefing"
EVID_DIR="$(dirname "$0")/../../docs/internal/security/evidencia"
mkdir -p "$EVID_DIR"

# Ejecutar npm scripts desde apps/briefing
HOST_JSON=$(cd "$BRIEFING_DIR" && npm run diag:host | awk '/^{/{flag=1} flag; /}/{flag=0}')
BRANCH=$(echo "$HOST_JSON" | jq -r '.branch')
HOST_BRANCH=$(echo "$HOST_JSON" | jq -r '.host_branch')
BRANCH_DNS_OK=$(echo "$HOST_JSON" | jq -r '.branch_dns_ok')
BASE_HOST="runart-foundry.pages.dev"
DATE_UTC=$(date -u +%Y%m%d_%H%M)

# Verificar host base
TARGET_HOST="$BASE_HOST"
LOG_BASE="$EVID_DIR/VERIFICACION_LOCAL_BASE_${DATE_UTC}.log"
set +e
ACCESS_CLIENT_ID_PREVIEW="$ACCESS_CLIENT_ID_PREVIEW" ACCESS_CLIENT_SECRET_PREVIEW="$ACCESS_CLIENT_SECRET_PREVIEW" TARGET_HOST="$TARGET_HOST" bash "$(dirname "$0")/verify_whoami_with_token.sh" | tee "$LOG_BASE"
BASE_OK=${PIPESTATUS[0]}
set -e

# Verificar host de rama si DNS OK
BRANCH_OK=2
if [[ "$BRANCH_DNS_OK" == "true" ]]; then
  TARGET_HOST="$HOST_BRANCH"
  LOG_BRANCH="$EVID_DIR/VERIFICACION_LOCAL_BRANCH_${DATE_UTC}.log"
  set +e
  ACCESS_CLIENT_ID_PREVIEW="$ACCESS_CLIENT_ID_PREVIEW" ACCESS_CLIENT_SECRET_PREVIEW="$ACCESS_CLIENT_SECRET_PREVIEW" TARGET_HOST="$TARGET_HOST" bash "$(dirname "$0")/verify_whoami_with_token.sh" | tee "$LOG_BRANCH"
  BRANCH_OK=${PIPESTATUS[0]}
  set -e
else
  # Intentar registro automático si hay API keys
  if [[ -n "$CLOUDFLARE_API_TOKEN" && -n "$CLOUDFLARE_ACCOUNT_ID" ]]; then
    if (cd "$BRIEFING_DIR" && BASE_HOST="$BASE_HOST" TARGET_HOST="$HOST_BRANCH" npm run cf:register-branch); then
      sleep 30
      # Reintentar DNS
      HOST_JSON=$(cd "$BRIEFING_DIR" && npm run diag:host | awk '/^{/{flag=1} flag; /}/{flag=0}')
      BRANCH_DNS_OK=$(echo "$HOST_JSON" | jq -r '.branch_dns_ok')
      if [[ "$BRANCH_DNS_OK" == "true" ]]; then
        TARGET_HOST="$HOST_BRANCH"
        LOG_BRANCH="$EVID_DIR/VERIFICACION_LOCAL_BRANCH_${DATE_UTC}.log"
    set +e
    ACCESS_CLIENT_ID_PREVIEW="$ACCESS_CLIENT_ID_PREVIEW" ACCESS_CLIENT_SECRET_PREVIEW="$ACCESS_CLIENT_SECRET_PREVIEW" TARGET_HOST="$TARGET_HOST" bash "$(dirname "$0")/verify_whoami_with_token.sh" | tee "$LOG_BRANCH"
    BRANCH_OK=${PIPESTATUS[0]}
    set -e
      else
        bash "$(dirname "$0")/open_branch_preview_issue.sh" "$BRANCH" "$HOST_BRANCH" "$HOST_JSON"
        BRANCH_OK=3
      fi
    else
      bash "$(dirname "$0")/open_branch_preview_issue.sh" "$BRANCH" "$HOST_BRANCH" "Registro automático fallido: Cloudflare Access rechazó autenticación"
      BRANCH_OK=3
    fi
  else
    bash "$(dirname "$0")/open_branch_preview_issue.sh" "$BRANCH" "$HOST_BRANCH" "$HOST_JSON"
    BRANCH_OK=3
  fi
fi

# Resumen final
if [[ "$BASE_OK" == "0" && ( "$BRANCH_OK" == "0" || "$BRANCH_OK" == "2" ) ]]; then
  echo "BASE: OK | BRANCH: ${BRANCH_OK}"; exit 0
else
  echo "BASE: $BASE_OK | BRANCH: $BRANCH_OK"; exit 1
fi
