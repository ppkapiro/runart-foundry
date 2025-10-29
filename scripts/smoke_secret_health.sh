#!/usr/bin/env bash
# Script de validación de salud de secretos para CI/CD
# Falla si cualquier secreto/configuración es inválida
set -euo pipefail

echo "🔒 RUNART Secret Health Check — $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
echo

ERRORS=0

# 1) Verificar presencia de secretos requeridos
echo "1️⃣ Verificando presencia de secretos..."
for var in CLOUDFLARE_API_TOKEN CLOUDFLARE_ACCOUNT_ID NAMESPACE_ID_RUNART_ROLES_PREVIEW ACCESS_CLIENT_ID_PREVIEW ACCESS_CLIENT_SECRET_PREVIEW; do
  if [ -z "${!var:-}" ]; then
    echo "  ❌ $var: FALTA"
    ((ERRORS++))
  else
    echo "  ✅ $var: presente"
  fi
done
echo

# 2) Verificar token Cloudflare
echo "2️⃣ Verificando token Cloudflare..."
if [ -n "${CLOUDFLARE_API_TOKEN:-}" ]; then
  VERIFY_RESULT=$(curl -fsS -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    "https://api.cloudflare.com/client/v4/user/tokens/verify" | jq -r '.result.status // "error"')
  
  if [ "$VERIFY_RESULT" = "active" ]; then
    echo "  ✅ Token válido y activo"
  else
    echo "  ❌ Token inválido o inactivo (status: $VERIFY_RESULT)"
    ((ERRORS++))
  fi
else
  echo "  ⏭️  Token no configurado, saltando"
fi
echo

# 3) Verificar cuenta accesible
echo "3️⃣ Verificando cuenta Cloudflare..."
if [ -n "${CLOUDFLARE_API_TOKEN:-}" ] && [ -n "${CLOUDFLARE_ACCOUNT_ID:-}" ]; then
  ACCOUNT_CHECK=$(curl -fsS -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID" | jq -r '.success // false')
  
  if [ "$ACCOUNT_CHECK" = "true" ]; then
    echo "  ✅ Cuenta accesible"
  else
    echo "  ❌ Cuenta no accesible o sin permisos"
    ((ERRORS++))
  fi
else
  echo "  ⏭️  Credenciales incompletas, saltando"
fi
echo

# 4) Verificar namespace KV
echo "4️⃣ Verificando namespace KV preview..."
if [ -n "${CLOUDFLARE_API_TOKEN:-}" ] && [ -n "${CLOUDFLARE_ACCOUNT_ID:-}" ] && [ -n "${NAMESPACE_ID_RUNART_ROLES_PREVIEW:-}" ]; then
  NS_CHECK=$(curl -fsS -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/storage/kv/namespaces" | \
    jq -r ".result[] | select(.id == \"$NAMESPACE_ID_RUNART_ROLES_PREVIEW\") | .id // empty")
  
  if [ -n "$NS_CHECK" ]; then
    echo "  ✅ Namespace preview existe"
  else
    echo "  ❌ Namespace preview no encontrado"
    ((ERRORS++))
  fi
else
  echo "  ⏭️  Credenciales incompletas, saltando"
fi
echo

# 5) Probar PUT/GET en KV (sonda)
echo "5️⃣ Probando operaciones KV (sonda)..."
if [ -n "${CLOUDFLARE_API_TOKEN:-}" ] && [ -n "${CLOUDFLARE_ACCOUNT_ID:-}" ] && [ -n "${NAMESPACE_ID_RUNART_ROLES_PREVIEW:-}" ]; then
  PROBE_KEY="__health_check_$(date +%s)__"
  PROBE_VALUE="ok"
  
  # PUT
  PUT_RESULT=$(curl -fsS -w "%{http_code}" -o /dev/null -X PUT \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: text/plain" \
    --data "$PROBE_VALUE" \
    "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/storage/kv/namespaces/$NAMESPACE_ID_RUNART_ROLES_PREVIEW/values/$PROBE_KEY")
  
  if [ "$PUT_RESULT" = "200" ]; then
    echo "  ✅ PUT exitoso"
  else
    echo "  ❌ PUT falló (HTTP $PUT_RESULT)"
    ((ERRORS++))
  fi
  
  # GET
  GET_RESULT=$(curl -fsS -w "\n%{http_code}" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/storage/kv/namespaces/$NAMESPACE_ID_RUNART_ROLES_PREVIEW/values/$PROBE_KEY" | tail -1)
  
  if [ "$GET_RESULT" = "200" ]; then
    echo "  ✅ GET exitoso"
  else
    echo "  ❌ GET falló (HTTP $GET_RESULT)"
    ((ERRORS++))
  fi
  
  # DELETE (limpieza)
  curl -fsS -X DELETE \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/storage/kv/namespaces/$NAMESPACE_ID_RUNART_ROLES_PREVIEW/values/$PROBE_KEY" >/dev/null 2>&1 || true
else
  echo "  ⏭️  Credenciales incompletas, saltando"
fi
echo

# 6) Verificar Access service token
echo "6️⃣ Verificando Access service token..."
if [ -n "${ACCESS_CLIENT_ID_PREVIEW:-}" ] && [ -n "${ACCESS_CLIENT_SECRET_PREVIEW:-}" ]; then
  ACCESS_CHECK=$(curl -fsS -w "%{http_code}" -o /dev/null -I \
    -H "CF-Access-Client-Id: $ACCESS_CLIENT_ID_PREVIEW" \
    -H "CF-Access-Client-Secret: $ACCESS_CLIENT_SECRET_PREVIEW" \
    -H "User-Agent: runart-ci/health-check" \
    "https://runart-foundry.pages.dev/api/whoami")
  
  if [ "$ACCESS_CHECK" = "200" ]; then
    echo "  ✅ Service token autorizado (HTTP 200)"
  elif [ "$ACCESS_CHECK" = "302" ]; then
    echo "  ⚠️  Service token no autorizado (HTTP 302 - redirect a login)"
    echo "     → Revisar policy de Access para incluir este token"
    # No incrementar ERRORS aquí, es warning no bloqueante
  else
    echo "  ❌ Error inesperado (HTTP $ACCESS_CHECK)"
    ((ERRORS++))
  fi
else
  echo "  ⏭️  Access tokens no configurados, saltando"
fi
echo

# Resumen
echo "═══════════════════════════════════════════════════════"
if [ $ERRORS -eq 0 ]; then
  echo "✅ Secret Health Check PASSED"
  echo "   Todos los secretos y configuraciones son válidos."
  exit 0
else
  echo "❌ Secret Health Check FAILED"
  echo "   Errores detectados: $ERRORS"
  echo "   Revisar logs arriba para detalles."
  exit 1
fi
