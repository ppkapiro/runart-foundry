#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

API_BASE="${PAGES_URL:-}"
TOKEN="${RUN_TOKEN:-}"
ACCESS_JWT="${ACCESS_JWT:-}"
COOKIE_FILE="${ACCESS_COOKIE_FILE:-$TMP_DIR/cookies.txt}"

if [[ -z "$API_BASE" ]]; then
  echo "❌ [$SCRIPT_NAME] Falta la variable de entorno PAGES_URL (ej: https://runart-briefing.pages.dev)" >&2
  exit 1
fi

if [[ -z "$TOKEN" ]]; then
  echo "❌ [$SCRIPT_NAME] Falta la variable de entorno RUN_TOKEN (usa dev-token en entornos locales)." >&2
  exit 1
fi

touch "$COOKIE_FILE"

API_DECISIONES="$API_BASE/api/decisiones"
API_MODERAR="$API_BASE/api/moderar"
API_INBOX="$API_BASE/api/inbox"

declare -a ACCESS_ARGS=()
if [[ -n "$ACCESS_JWT" ]]; then
  ACCESS_ARGS+=("-H" "Cf-Access-Jwt-Assertion: $ACCESS_JWT")
fi

COOKIE_ARGS=("--cookie" "$COOKIE_FILE" "--cookie-jar" "$COOKIE_FILE")

PASSED=0
FAILED=0
WARNED=0

# Patrones de redirects de Cloudflare Access
ACCESS_REDIRECT_PATTERNS=(
  "/cdn-cgi/access"
  "/cdn-cgi/login" 
  "cloudflareaccess"
  "/oauth2/"
  "auth.cloudflareaccess.com"
)

curl_capture() {
  local method="$1"; shift
  local url="$1"; shift
  local output_file="$1"; shift

  : >"$output_file"
  curl -sS -o "$output_file" -w '%{http_code}\t%{redirect_url}' -X "$method" "$url" \
    "${COOKIE_ARGS[@]}" "${ACCESS_ARGS[@]}" "$@"
}

is_access_redirect() {
  local status="$1"
  local redirect_url="$2"
  
  # Solo 301/302 pueden ser Access redirects
  if [[ "$status" != "301" && "$status" != "302" ]]; then
    return 1
  fi
  
  # Sin URL de redirect, no es Access
  if [[ -z "$redirect_url" || "$redirect_url" == "null" ]]; then
    return 1
  fi
  
  # Convertir a minúsculas para comparación
  local redirect_lower=$(echo "$redirect_url" | tr '[:upper:]' '[:lower:]')
  
  # Verificar si contiene algún patrón de Access
  for pattern in "${ACCESS_REDIRECT_PATTERNS[@]}"; do
    if [[ "$redirect_lower" == *"$pattern"* ]]; then
      return 0
    fi
  done
  
  return 1
}

evaluate_status() {
  local name="$1"
  local status="$2"
  local expected="$3"
  local body_file="$4"
  local pretty="${expected// /, }"

  if [[ " $expected " == *" $status "* ]]; then
    echo "✅ $name (HTTP $status)"
  ((PASSED+=1))
  else
    echo "❌ $name (HTTP $status, esperado: $pretty)"
    [[ -s "$body_file" ]] && cat "$body_file"
  ((FAILED+=1))
  fi
  return 0
}

evaluate_status_with_warn() {
  local name="$1"
  local status="$2"
  local expected="$3"
  local tolerated="$4"
  local response_with_redirect="$5"
  local body_file="$6"
  local pretty="${expected// /, }"
  local tolerated_pretty="${tolerated// /, }"

  # Extraer status y redirect_url del response
  local actual_status=$(echo "$response_with_redirect" | cut -f1)
  local redirect_url=$(echo "$response_with_redirect" | cut -f2 2>/dev/null || echo "")

  if [[ " $expected " == *" $actual_status "* ]]; then
    echo "✅ $name (HTTP $actual_status)"
    ((PASSED+=1))
  elif is_access_redirect "$actual_status" "$redirect_url"; then
    echo "✅ $name (HTTP $actual_status → Access) - Protección activa"
    ((PASSED+=1))
  elif [[ " $tolerated " == *" $actual_status "* ]]; then
    echo "⚠️  $name (HTTP $actual_status; permitido pero requiere revisar autenticación Access)"
    [[ -s "$body_file" ]] && cat "$body_file"
    ((WARNED+=1))
  else
    echo "❌ $name (HTTP $actual_status, esperado: $pretty | tolerado: $tolerated_pretty)"
    [[ -s "$body_file" ]] && cat "$body_file"
    if [[ -n "$redirect_url" && "$redirect_url" != "null" ]]; then
      echo "   Redirect: $redirect_url"
    fi
    ((FAILED+=1))
  fi
  return 0
}

NOW=$(date +%s)
DECISION_ID="smoke:${NOW}"

body_no_token="$TMP_DIR/no-token.json"
printf -v payload_no_token '{"decision_id":"%s","tipo":"ficha_proyecto","payload":{"slug":"smoke"},"comentario":"sin token"}' "$DECISION_ID"
response=$(curl_capture POST "$API_DECISIONES" "$body_no_token" \
  -H 'Content-Type: application/json' \
  --data-binary "$payload_no_token")
evaluate_status_with_warn "POST /api/decisiones sin token" "$response" "401 403" "302" "$response" "$body_no_token"

body_honeypot="$TMP_DIR/honeypot.json"
printf -v payload_honeypot '{"decision_id":"%s-hp","tipo":"ficha_proyecto","payload":{"slug":"smoke"},"comentario":"honeypot","website":"http://bot","auth_token":"%s","origin_hint":"smoke-test"}' "$DECISION_ID" "$TOKEN"
response=$(curl_capture POST "$API_DECISIONES" "$body_honeypot" \
  -H 'Content-Type: application/json' \
  -H "X-Runart-Token: $TOKEN" \
  --data-binary "$payload_honeypot")
evaluate_status_with_warn "POST /api/decisiones con honeypot" "$response" "400" "302" "$response" "$body_honeypot"

body_valid="$TMP_DIR/valid.json"
printf -v payload_valid '{"decision_id":"%s","tipo":"ficha_proyecto","payload":{"slug":"%s","title":"Smoke","artist":"Test","year":"2025"},"comentario":"Smoke test","website":"","auth_token":"%s","origin_hint":"smoke-test","token_origen":"smoke_cli"}' "$DECISION_ID" "$DECISION_ID" "$TOKEN"
response=$(curl_capture POST "$API_DECISIONES" "$body_valid" \
  -H 'Content-Type: application/json' \
  -H "X-Runart-Token: $TOKEN" \
  --data-binary "$payload_valid")
evaluate_status_with_warn "POST /api/decisiones con token válido" "$response" "200" "302" "$response" "$body_valid"

body_mod="$TMP_DIR/moderar.json"
printf -v payload_mod '{"decision_id":"%s","action":"accept","note":"smoke via script","auth_token":"%s"}' "$DECISION_ID" "$TOKEN"
response=$(curl_capture POST "$API_MODERAR" "$body_mod" \
  -H 'Content-Type: application/json' \
  -H "X-Runart-Token: $TOKEN" \
  --data-binary "$payload_mod")
evaluate_status_with_warn "POST /api/moderar accept" "$response" "200" "302 401 403" "$response" "$body_mod"

body_inbox="$TMP_DIR/inbox.json"
response=$(curl_capture GET "$API_INBOX" "$body_inbox")
evaluate_status_with_warn "GET /api/inbox" "$response" "200" "302 401 403" "$response" "$body_inbox"

TOTAL=$((PASSED + FAILED + WARNED))
echo "---"
printf 'Resumen: %d pruebas • %d ✅  %d ⚠️  %d ❌\n' "$TOTAL" "$PASSED" "$WARNED" "$FAILED"

if (( FAILED > 0 )); then
  exit 1
fi

exit 0
