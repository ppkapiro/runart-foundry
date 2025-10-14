#!/usr/bin/env bash
# Script optimizado para smoke tests en producción con Cloudflare Access
# Reconoce redirects 301/302 hacia Access como comportamiento esperado (PASS)

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# Variables de configuración
API_BASE="${PAGES_URL:-}"
TOKEN="${RUN_TOKEN:-}"
ACCESS_JWT="${ACCESS_JWT:-}"
COOKIE_FILE="${ACCESS_COOKIE_FILE:-$TMP_DIR/cookies.txt}"

# Validación de parámetros obligatorios
if [[ -z "$API_BASE" ]]; then
  echo "❌ [$SCRIPT_NAME] Falta la variable de entorno PAGES_URL (ej: https://runart-foundry.pages.dev)" >&2
  exit 1
fi

if [[ -z "$TOKEN" ]]; then
  echo "❌ [$SCRIPT_NAME] Falta la variable de entorno RUN_TOKEN (usa dev-token en entornos locales)." >&2
  exit 1
fi

touch "$COOKIE_FILE"

# Endpoints a probar
API_DECISIONES="$API_BASE/api/decisiones"
API_MODERAR="$API_BASE/api/moderar"
API_INBOX="$API_BASE/api/inbox"
API_WHOAMI="$API_BASE/api/whoami"
ROOT_URL="$API_BASE/"

# Configuración de Access
declare -a ACCESS_ARGS=()
if [[ -n "$ACCESS_JWT" ]]; then
  ACCESS_ARGS+=("-H" "Cf-Access-Jwt-Assertion: $ACCESS_JWT")
fi

COOKIE_ARGS=("--cookie" "$COOKIE_FILE" "--cookie-jar" "$COOKIE_FILE")

# Contadores
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

evaluate_production_status() {
  local name="$1"
  local status="$2"
  local expected="$3"
  local redirect_url="$4"
  local body_file="$5"
  local pretty="${expected// /, }"

  # Si el status es exactamente el esperado, es PASS directo
  if [[ " $expected " == *" $status "* ]]; then
    echo "✅ $name (HTTP $status)"
    ((PASSED+=1))
    return 0
  fi

  # Si es un redirect de Access, es PASS (comportamiento esperado en producción)
  if is_access_redirect "$status" "$redirect_url"; then
    echo "✅ $name (HTTP $status → Access) - Protección activa"
    ((PASSED+=1))
    return 0
  fi

  # Cualquier otra cosa es FAIL
  echo "❌ $name (HTTP $status, esperado: $pretty)"
  if [[ -s "$body_file" ]]; then
    echo "   Respuesta: $(cat "$body_file")"
  fi
  if [[ -n "$redirect_url" && "$redirect_url" != "null" ]]; then
    echo "   Redirect: $redirect_url"
  fi
  ((FAILED+=1))
  return 0
}

echo "🔍 Ejecutando smoke tests para producción con Cloudflare Access"
echo "📍 Base URL: $API_BASE"
echo "🔐 Access JWT: ${ACCESS_JWT:+configurado}${ACCESS_JWT:-no configurado}"
echo ""

# Configuración de expectativas por entorno
SMOKE_ALLOW_MISSING_WHOAMI="${SMOKE_ALLOW_MISSING_WHOAMI:-0}"
SMOKE_ALLOW_MISSING_INBOX="${SMOKE_ALLOW_MISSING_INBOX:-0}"
EXPECTED_WHOAMI="200"
EXPECTED_INBOX="200"
if [[ "${RUNART_ENV:-}" == "preview" || "$SMOKE_ALLOW_MISSING_WHOAMI" == "1" ]]; then
  EXPECTED_WHOAMI="200 404"
fi
if [[ "${RUNART_ENV:-}" == "preview" || "$SMOKE_ALLOW_MISSING_INBOX" == "1" ]]; then
  EXPECTED_INBOX="200 404"
fi

# Test 1: Página raíz (debe redirigir a Access si no hay sesión)
echo "🧪 Test 1: Página raíz"
body_root="$TMP_DIR/root.html"
response=$(curl_capture GET "$ROOT_URL" "$body_root")
status=$(echo "$response" | cut -f1)
redirect_url=$(echo "$response" | cut -f2)
evaluate_production_status "GET /" "$status" "200" "$redirect_url" "$body_root"

# Test 2: API whoami (200 en prod; en preview puede no existir → 404 permitido)
echo ""
echo "🧪 Test 2: API whoami"
body_whoami="$TMP_DIR/whoami.json"
response=$(curl_capture GET "$API_WHOAMI" "$body_whoami")
status=$(echo "$response" | cut -f1)
redirect_url=$(echo "$response" | cut -f2)
evaluate_production_status "GET /api/whoami" "$status" "$EXPECTED_WHOAMI" "$redirect_url" "$body_whoami"

# Test 3: API inbox (200 en prod; en preview puede no existir → 404 permitido)
echo ""
echo "🧪 Test 3: API inbox"
body_inbox="$TMP_DIR/inbox.json"
response=$(curl_capture GET "$API_INBOX" "$body_inbox")
status=$(echo "$response" | cut -f1)
redirect_url=$(echo "$response" | cut -f2)
evaluate_production_status "GET /api/inbox" "$status" "$EXPECTED_INBOX" "$redirect_url" "$body_inbox"

# Test 4: API decisiones sin token (debe redirigir a Access o devolver 401; en preview tolera 405)
echo ""
echo "🧪 Test 4: API decisiones sin token"
NOW=$(date +%s)
DECISION_ID="smoke:${NOW}"
body_no_token="$TMP_DIR/no-token.json"
printf -v payload_no_token '{"decision_id":"%s","tipo":"ficha_proyecto","payload":{"slug":"smoke"},"comentario":"sin token"}' "$DECISION_ID"
response=$(curl_capture POST "$API_DECISIONES" "$body_no_token" \
  -H 'Content-Type: application/json' \
  --data-binary "$payload_no_token")
status=$(echo "$response" | cut -f1)
redirect_url=$(echo "$response" | cut -f2)
EXPECTED_DECISIONES_NO_TOKEN="401 403"
if [[ "${RUNART_ENV:-}" == "preview" ]]; then EXPECTED_DECISIONES_NO_TOKEN="401 403 405"; fi
evaluate_production_status "POST /api/decisiones sin token" "$status" "$EXPECTED_DECISIONES_NO_TOKEN" "$redirect_url" "$body_no_token"

# Test 5: API decisiones con token pero sin sesión Access (en preview tolera 405)
echo ""
echo "🧪 Test 5: API decisiones con token sin sesión Access"
body_with_token="$TMP_DIR/with-token.json"
printf -v payload_with_token '{"decision_id":"%s","tipo":"ficha_proyecto","payload":{"slug":"%s","title":"Smoke","artist":"Test","year":"2025"},"comentario":"Smoke test producción","website":"","auth_token":"%s","origin_hint":"smoke-production","token_origen":"smoke_production"}' "$DECISION_ID" "$DECISION_ID" "$TOKEN"
response=$(curl_capture POST "$API_DECISIONES" "$body_with_token" \
  -H 'Content-Type: application/json' \
  -H "X-Runart-Token: $TOKEN" \
  --data-binary "$payload_with_token")
status=$(echo "$response" | cut -f1)
redirect_url=$(echo "$response" | cut -f2)
EXPECTED_DECISIONES_WITH_TOKEN="200"
if [[ "${RUNART_ENV:-}" == "preview" ]]; then EXPECTED_DECISIONES_WITH_TOKEN="200 405"; fi
evaluate_production_status "POST /api/decisiones con token" "$status" "$EXPECTED_DECISIONES_WITH_TOKEN" "$redirect_url" "$body_with_token"

# Resumen final
TOTAL=$((PASSED + FAILED + WARNED))
echo ""
echo "📊 === RESUMEN ==="
printf 'Total: %d pruebas • %d ✅ PASS • %d ⚠️ WARN • %d ❌ FAIL\n' "$TOTAL" "$PASSED" "$WARNED" "$FAILED"

if (( PASSED == TOTAL )); then
  echo ""
  echo "🎉 Todos los tests pasaron. Cloudflare Access está funcionando correctamente."
  echo "💡 Los redirects 30x hacia Access indican que la protección está activa."
  exit 0
elif (( FAILED == 0 )); then
  echo ""
  echo "⚠️  Algunos tests generaron warnings. Revisar configuración."
  exit 0
else
  echo ""
  echo "❌ Hay tests fallidos. Revisar configuración de Access o endpoints."
  exit 1
fi