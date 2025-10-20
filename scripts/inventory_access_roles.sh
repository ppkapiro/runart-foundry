#!/usr/bin/env bash
# === RUNART | INVENTARIO DE ACCESOS Y ROLES (Access + KV) ====================
set -euo pipefail

REPO="/home/pepe/work/runartfoundry"
OUT_DIR="${REPO}/docs/internal/security/evidencia"
TS="$(date -u +%Y%m%d_%H%M)"
REPORT="${OUT_DIR}/ROLES_ACCESS_REPORT_${TS}.md"

mkdir -p "$OUT_DIR"

# Cargar credenciales si existen
if [ -f ~/.runart/env ]; then
  echo "🔐 Cargando credenciales desde ~/.runart/env..."
  # Cargar línea por línea para evitar problemas con export
  while IFS='=' read -r key value; do
    # Ignorar comentarios y líneas vacías
    [[ "$key" =~ ^#.*$ ]] && continue
    [[ -z "$key" ]] && continue
    # Remover comillas del valor si existen
    value="${value%\"}"
    value="${value#\"}"
    value="${value%\'}"
    value="${value#\'}"
    # Exportar la variable
    export "$key=$value"
  done < ~/.runart/env
fi

# Validar variables requeridas
echo "🔍 Validando credenciales..."
MISSING_VARS=()
for var in CLOUDFLARE_API_TOKEN CLOUDFLARE_ACCOUNT_ID; do
  if [ -z "${!var:-}" ]; then
    MISSING_VARS+=("$var")
  else
    echo "  ✓ $var configurado"
  fi
done

if [ ${#MISSING_VARS[@]} -gt 0 ]; then
  echo
  echo "❌ Variables faltantes: ${MISSING_VARS[*]}"
  echo
  echo "📖 Para configurar CLOUDFLARE_API_TOKEN:"
  echo "   1. Ve a https://dash.cloudflare.com/profile/api-tokens"
  echo "   2. Crea un token con permisos:"
  echo "      - Account.Cloudflare Access: Read"
  echo "      - Account.Workers KV Storage: Read"
  echo "   3. Agrega a ~/.runart/env:"
  echo "      CLOUDFLARE_API_TOKEN=tu_token_aqui"
  echo
  echo "   O ejecuta: scripts/runart_env_setup.sh"
  exit 1
fi
echo

# --- Helper: curl CF API seguro ---
cfget() {
  local url="$1"
  curl -sS -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
       -H "Content-Type: application/json" "$url"
}

# 0) Descubrir App de Access por dominio (RUN Briefing)
APP_DOMAIN="runart-foundry.pages.dev"
echo "🔍 Buscando aplicación Access para ${APP_DOMAIN}..."
APPS_JSON="$(cfget "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/access/apps")"
APP_ID="$(echo "$APPS_JSON" | jq -r --arg d "$APP_DOMAIN" '.result[] | select(.domain==$d) | .id' | head -n1)"
APP_NAME="$(echo "$APPS_JSON" | jq -r --arg d "$APP_DOMAIN" '.result[] | select(.domain==$d) | .name' | head -n1)"

if [ -z "${APP_ID}" ] || [ "${APP_ID}" = "null" ]; then
  echo "❌ No encontré la app de Access para dominio ${APP_DOMAIN}. Revisa el dashboard."
  exit 1
fi

echo "✅ App encontrada: ${APP_NAME} (ID: ${APP_ID})"

# 1) Obtener policies de la app (Include/Require/Exclude)
echo "📋 Obteniendo policies..."
POL_JSON="$(cfget "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/access/apps/${APP_ID}/policies")"

# 2) Obtener grupos de Access (para expandir definiciones)
echo "👥 Obteniendo grupos de Access..."
GRP_JSON="$(cfget "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/access/groups")"

# 3) Obtener service tokens existentes (para nombrarlos)
echo "🔑 Obteniendo service tokens..."
TOK_JSON="$(cfget "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/access/service_tokens")"

# 4) Volcar KV de roles (email -> rol) desde el namespace de preview
# Usar el preview_id de RUNART_ROLES del wrangler.toml
NS="${NAMESPACE_ID_RUNART_ROLES_PREVIEW:-7d80b07de98e4d9b9d5fd85516901ef6}"
echo "📦 Obteniendo keys de KV namespace ${NS}..."
KV_KEYS_JSON="$(cfget "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/storage/kv/namespaces/${NS}/keys?limit=1000")"
EMAIL_KEYS="$(echo "$KV_KEYS_JSON" | jq -r '.result[].name' 2>/dev/null || true)"

# 5) Armar el reporte Markdown
echo "📝 Generando reporte..."
{
  echo "# RunArt Foundry — Inventario de Acceso y Roles"
  echo "_Generado: ${TS} UTC_"
  echo
  echo "## Aplicación protegida"
  echo "- **App:** ${APP_NAME}"
  echo "- **Dominio:** ${APP_DOMAIN}"
  echo "- **App ID:** \`${APP_ID}\`"
  echo
  echo "## Policies (orden de evaluación)"
  # Listar policies con detalle
  echo "$POL_JSON" | jq -r '
    .result
    | sort_by(.precedence) 
    | to_entries[]
    | "\n### " + (.key|tostring) + ". " + .value.name + "  \n- **Action:** " + .value.decision
      + "  \n- **Precedence:** " + (.value.precedence|tostring)
      + "  \n- **Include:** " 
      + ( .value.include // [] | map(
            (if .email then "email=" + (.email|join(",")) else "" end) +
            (if .email_domain then (if length>0 then (if .email then "," else "" end) else "" end) + "domain=" + (.email_domain|join(",")) else "" end) +
            (if .group then (if (.email or .email_domain) then "," else "" end) + "group=" + (.group.id // .group|tostring) else "" end) +
            (if .service_token then (if (.email or .email_domain or .group) then "," else "" end) + "service_token=" + (.service_token.id // .service_token|tostring) else "" end)
          ) | join("; ")
        )
      + "  \n- **Require:** " 
      + ( .value.require // [] | map(
            (if .login_method then "login=" + (.login_method|join(",")) else "" end) +
            (if .geo then (if .login_method then "," else "" end) + "geo=" + (.geo|join(",")) else "" end)
          ) | join("; ")
        )
      + "  \n- **Exclude:** " 
      + ( .value.exclude // [] | map(
            (if .service_token then "service_token=" + (.service_token.id // .service_token|tostring) else "" end) +
            (if .email then (if .service_token then "," else "" end) + "email=" + (.email|join(",")) else "" end) 
          ) | join("; ")
        )
  '
  echo
  echo "## Grupos de Access (definiciones)"
  GROUPS_COUNT=$(echo "$GRP_JSON" | jq -r '.result | length')
  if [ "$GROUPS_COUNT" -eq 0 ]; then
    echo "_No hay grupos configurados._"
  else
    echo "$GRP_JSON" | jq -r '
      .result[] | 
      "### " + .name + "  \n- **Group ID:** \`" + .id + "\`  \n- **Include:** " +
      ( .include // [] | map(
          (if .email then "email=" + (.email|join(",")) else "" end) +
          (if .email_domain then (if .email then "," else "" end) + "domain=" + (.email_domain|join(",")) else "" end)
        ) | join("; ")
      ) + "  \n- **Exclude:** " +
      ( .exclude // [] | map(
          (if .email then "email=" + (.email|join(",")) else "" end)
        ) | join("; ")
      ) + "\n"
    '
  fi
  echo
  echo "## Service Tokens"
  TOKENS_COUNT=$(echo "$TOK_JSON" | jq -r '.result | length')
  if [ "$TOKENS_COUNT" -eq 0 ]; then
    echo "_No hay service tokens configurados._"
  else
    echo "$TOK_JSON" | jq -r '.result[] | "- **" + .name + "**  \n  - ID: \`" + .id + "\`  \n  - Expires: " + (.expires_at // "never") + "  \n  - Created: " + .created_at'
  fi
  echo
  echo "## KV — Roles por email (namespace preview)"
  echo "- **Namespace ID:** \`${NS}\`"
  echo
  if [ -z "${EMAIL_KEYS}" ]; then
    echo "_No hay claves en el namespace de roles._"
  else
    echo "| Email (key) | Rol (valor) |"
    echo "|-------------|-------------|"
    # Iterar los keys y leer su valor
    while IFS= read -r k; do
      # URL encode del key para la API
      k_encoded="$(echo -n "$k" | jq -sRr @uri)"
      v="$(cfget "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/storage/kv/namespaces/${NS}/values/${k_encoded}" 2>/dev/null || echo "error")"
      # Limitar a 200 chars por si es JSON grande y escapar pipes
      vv="$(printf "%s" "$v" | sed 's/|/\\|/g' | cut -c1-200)"
      echo "| ${k} | \`${vv}\` |"
    done <<< "${EMAIL_KEYS}"
  fi
  echo
  echo "## Resumen operativo"
  echo
  echo "### Control de acceso (Access)"
  echo "- **Quién puede entrar:** Ver Policies arriba (emails, dominios, grupos y service tokens en Include/Require)."
  echo "- **Quién es bloqueado:** Ver Exclude en policies."
  echo "- **Orden de evaluación:** Por precedence (menor = más prioritario)."
  echo
  echo "### Asignación de roles (KV)"
  echo "- **Qué rol obtiene cada correo:** Ver la tabla **KV — Roles por email**."
  echo "- **Rol por defecto:** Si un email no aparece en KV, el backend asigna según lógica del worker."
  echo "- **Roles disponibles:** \`owner\`, \`team\`, \`client\`, \`client_admin\`, \`visitor\`"
  echo
  echo "### Próximos pasos"
  echo "1. Revisar que las policies reflejen la intención de seguridad"
  echo "2. Validar que los emails en KV tienen roles correctos"
  echo "3. Auditar service tokens activos (rotar si están comprometidos)"
  echo "4. Verificar que no hay grupos vacíos o sin uso"
} > "${REPORT}"

echo "✅ Informe generado: ${REPORT}"
echo
echo "📄 Primeras líneas del reporte:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
head -n 80 "${REPORT}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "💡 Ver reporte completo: cat ${REPORT}"
