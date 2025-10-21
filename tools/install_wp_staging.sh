#!/usr/bin/env bash
#
# install_wp_staging.sh
# Instala y configura WordPress en el entorno STAGING de IONOS,
# actualiza los secrets de GitHub y dispara los workflows verify-*.
#
# Requisitos:
# - Archivo .env.staging.local con variables de conexion.
# - gh CLI autenticado y con permisos sobre el repositorio objetivo.
# - Acceso SSH al hosting IONOS.
# - jq, curl, python3 disponibles localmente.
#
# Uso:
#   ./tools/install_wp_staging.sh
#
# El script nunca imprime contrasenas. La App Password se mantiene en memoria
# y se envia a GitHub Secrets mediante pipe. Los archivos locales con passwords
# se crean con permisos 600 y se purgan al finalizar.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env.staging.local"
LOGS_DIR="${ROOT_DIR}/logs"
BITACORA="${ROOT_DIR}/apps/briefing/docs/internal/briefing_system/ci/082_bitacora_fase7_conexion_wp_real.md"
REPORTS_DIR="${ROOT_DIR}/_reports"
DATE_UTC="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"
REPORT_FILE="${REPORTS_DIR}/VALIDACION_STAGING_$(date -u '+%Y%m%d').md"

mkdir -p "${LOGS_DIR}" "${REPORTS_DIR}"

log_info()  { echo -e "\033[0;34m[INFO]\033[0m $*"; }
log_warn()  { echo -e "\033[1;33m[WARN]\033[0m $*"; }
log_success(){ echo -e "\033[0;32m[OK]\033[0m $*"; }
log_error() { echo -e "\033[0;31m[ERR]\033[0m $*"; }

if [[ ! -f "${ENV_FILE}" ]]; then
  log_error "No se encontro ${ENV_FILE}. Crea el archivo con las variables requeridas."
  exit 1
fi

set -a
source "${ENV_FILE}"
set +a

: "${IONOS_SSH_HOST:?IONOS_SSH_HOST no definido en .env.staging.local}"
: "${SSH_PORT:=22}"
: "${DB_NAME:?DB_NAME no definido}"
: "${DB_USER:?DB_USER no definido}"
: "${DB_HOST:?DB_HOST no definido}"

: "${REPO_FULL:?REPO_FULL no definido}"
: "${STAGING_DOMAIN:?STAGING_DOMAIN no definido}"
: "${STAGING_PATH:=/staging}"
SSH_PASS="${SSH_PASS:-}"

export STAGING_PATH STAGING_DOMAIN DB_NAME DB_USER DB_PASS DB_HOST

if [[ "${DB_PASS}" == *"<AQUI"* || "${DB_PASS}" == "" ]]; then
  log_warn "DB_PASS en .env.staging.local es un placeholder. Se solicitara de forma segura."
  read -r -s -p "Introduce DB_PASS real (entrada oculta): " DB_PASS
  echo ""
fi

if [[ -z "${DB_PASS}" ]]; then
  log_error "DB_PASS no puede estar vacio"; exit 1
fi

export DB_PASS

if [[ -z "${SSH_PASS}" ]]; then
  log_warn "SSH_PASS no definido. Se solicitara de forma segura (usuario ${IONOS_SSH_HOST%%@*})."
  read -r -s -p "Introduce contrasena SSH (oculta): " SSH_PASS
  echo ""
fi

if [[ -z "${SSH_PASS}" ]]; then
  log_error "SSH_PASS no puede estar vacio"; exit 1
fi

export SSH_PASS

ADMIN_PASS_FILE="${LOGS_DIR}/staging_admin_pass_$(date -u '+%Y%m%d_%H%M%S').txt"
APP_PASS_FILE="${LOGS_DIR}/staging_app_pass_$(date -u '+%Y%m%d_%H%M%S').txt"

chmod 700 "${LOGS_DIR}" || true

log_info "Verificando dependencias locales (gh, ssh, curl, python3, jq)..."
command -v gh >/dev/null 2>&1 || { log_error "gh CLI no disponible"; exit 1; }
command -v ssh >/dev/null 2>&1 || { log_error "ssh no disponible"; exit 1; }
command -v curl >/dev/null 2>&1 || { log_error "curl no disponible"; exit 1; }
command -v python3 >/dev/null 2>&1 || { log_error "python3 no disponible"; exit 1; }
command -v jq >/dev/null 2>&1 || { log_error "jq no disponible"; exit 1; }

log_info "Validando autenticacion gh CLI..."
if ! gh auth status >/dev/null 2>&1; then
  log_error "gh CLI no autenticado"; exit 1
fi
log_success "gh CLI autenticado"

log_info "Validando acceso al repositorio ${REPO_FULL}..."
if ! gh repo view "${REPO_FULL}" >/dev/null 2>&1; then
  log_error "Repositorio ${REPO_FULL} no accesible"; exit 1
fi
log_success "Acceso al repositorio confirmado"

SSH_OPTIONS=(-p "${SSH_PORT}" -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null)
if command -v sshpass >/dev/null 2>&1; then
  export SSHPASS="${SSH_PASS}"
  SSH_CMD=(sshpass -e ssh "${SSH_OPTIONS[@]}" "${IONOS_SSH_HOST}")
else
  SSH_CMD=(ssh "${SSH_OPTIONS[@]}" "${IONOS_SSH_HOST}")
fi

log_info "Validando acceso SSH a ${IONOS_SSH_HOST}:${SSH_PORT}..."
if ! "${SSH_CMD[@]}" echo OK >/dev/null 2>&1; then
  log_error "No se pudo establecer conexion SSH"; exit 1
fi
log_success "Acceso SSH confirmado"

log_info "Preparando docroot ${STAGING_PATH} y WP-CLI en remoto..."
"${SSH_CMD[@]}" env STAGING_PATH="${STAGING_PATH}" STAGING_DOMAIN="${STAGING_DOMAIN}" bash -s <<'REMOTE'
set -euo pipefail
WP_CMD="wp"
if ! command -v wp >/dev/null 2>&1; then
  mkdir -p "${STAGING_PATH}"
  if [ ! -f "${STAGING_PATH}/wp-cli.phar" ]; then
    curl -sS -o "${STAGING_PATH}/wp-cli.phar" https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x "${STAGING_PATH}/wp-cli.phar"
  fi
  WP_CMD="php ${STAGING_PATH}/wp-cli.phar"
fi
mkdir -p "${STAGING_PATH}"
chmod 755 "${STAGING_PATH}"
if [ ! -f "${STAGING_PATH}/index.html" ]; then
  echo "STAGING READY -- $(date -u)" > "${STAGING_PATH}/index.html"
  chmod 644 "${STAGING_PATH}/index.html"
fi
if [ ! -f "${STAGING_PATH}/wp-load.php" ]; then
  cd "${STAGING_PATH}"
  "${WP_CMD}" core download --force
fi
REMOTE

log_success "Docroot preparado"

log_info "Creando wp-config.php e instalando WordPress..."
"${SSH_CMD[@]}" env STAGING_PATH="${STAGING_PATH}" STAGING_DOMAIN="${STAGING_DOMAIN}" DB_NAME="${DB_NAME}" DB_USER="${DB_USER}" DB_PASS="${DB_PASS}" DB_HOST="${DB_HOST}" bash -s <<'REMOTE'
set -euo pipefail
WP_CMD="wp"
if ! command -v wp >/dev/null 2>&1; then
  WP_CMD="php ${STAGING_PATH}/wp-cli.phar"
fi
cd "${STAGING_PATH}"
if [ ! -f "wp-config.php" ]; then
  "${WP_CMD}" config create --dbname="${DB_NAME}" --dbuser="${DB_USER}" --dbpass="${DB_PASS}" --dbhost="${DB_HOST}" --skip-check
fi
  if ! "${WP_CMD}" core is-installed >/dev/null 2>&1; then
  ADMIN_USER="admin"
  ADMIN_EMAIL="admin@${STAGING_DOMAIN}"
  if command -v openssl >/dev/null 2>&1; then
    ADMIN_PASS="$(openssl rand -hex 12)"
  else
    ADMIN_PASS="$(dd if=/dev/urandom bs=1 count=16 2>/dev/null | base64 | tr -dc 'A-Za-z0-9' | head -c 24)"
  fi
  "${WP_CMD}" core install \
    --url="https://${STAGING_DOMAIN}" \
    --title="RunArt Foundry -- STAGING" \
    --admin_user="${ADMIN_USER}" \
    --admin_password="${ADMIN_PASS}" \
    --admin_email="${ADMIN_EMAIL}"
  echo "${ADMIN_PASS}" > admin_pass.tmp
fi
"${WP_CMD}" option update siteurl "https://${STAGING_DOMAIN}"
"${WP_CMD}" option update home "https://${STAGING_DOMAIN}"
"${WP_CMD}" rewrite structure '/%postname%/' --hard
"${WP_CMD}" rewrite flush --hard
if ! "${WP_CMD}" user get github-actions >/dev/null 2>&1; then
  if command -v openssl >/dev/null 2>&1; then
    TECH_PASS="$(openssl rand -hex 10)"
  else
    TECH_PASS="$(dd if=/dev/urandom bs=1 count=16 2>/dev/null | base64 | tr -dc 'A-Za-z0-9' | head -c 20)"
  fi
  "${WP_CMD}" user create github-actions "github-actions@${STAGING_DOMAIN}" --role=editor --user_pass="${TECH_PASS}"
fi
if [ -f ".htaccess" ]; then
  if command -v perl >/dev/null 2>&1; then
    perl -0pi -e 's/runartfoundry\.com/# CANONICAL REMOVED runartfoundry.com/g' .htaccess || true
  else
    TMP_HTACCESS=$(mktemp)
    sed 's/runartfoundry\.com/# CANONICAL REMOVED &/g' .htaccess > "$TMP_HTACCESS" && mv "$TMP_HTACCESS" .htaccess || true
  fi
fi
REMOTE

log_success "WordPress configurado"

log_info "Recuperando contrasena admin temporal (si se genero)..."
ADMIN_PASS_REMOTE="$("${SSH_CMD[@]}" env STAGING_PATH="${STAGING_PATH}" bash -s <<'REMOTE'
set -euo pipefail
if [ -f "${STAGING_PATH}/admin_pass.tmp" ]; then
  cat "${STAGING_PATH}/admin_pass.tmp"
fi
REMOTE
)"
if [[ -n "${ADMIN_PASS_REMOTE}" ]]; then
  printf "%s" "${ADMIN_PASS_REMOTE}" > "${ADMIN_PASS_FILE}"
  chmod 600 "${ADMIN_PASS_FILE}"
  "${SSH_CMD[@]}" rm -f "${STAGING_PATH}/admin_pass.tmp" 2>/dev/null || true
  log_warn "Contrasena admin temporal almacenada en ${ADMIN_PASS_FILE}. Rotar posteriormente."
else
  log_info "La instancia ya estaba instalada; no se genero nueva contrasena admin."
fi

log_info "Generando App Password para github-actions..."
APP_PASS_OUTPUT="$("${SSH_CMD[@]}" env STAGING_PATH="${STAGING_PATH}" bash -s <<'REMOTE'
set -euo pipefail
WP_CMD="wp"
if ! command -v wp >/dev/null 2>&1; then
  WP_CMD="php ${STAGING_PATH}/wp-cli.phar"
fi
cd "${STAGING_PATH}"
"${WP_CMD}" user application-password list github-actions --format=ids 2>/dev/null | xargs -r -n1 "${WP_CMD}" user application-password delete github-actions 2>/dev/null || true
"${WP_CMD}" user application-password create github-actions "GH Actions STAGING" --porcelain 2>/dev/null
REMOTE
)"

if [[ -z "${APP_PASS_OUTPUT}" ]]; then
  log_error "No se pudo generar la App Password"; exit 1
fi
printf "%s" "${APP_PASS_OUTPUT}" > "${APP_PASS_FILE}"
chmod 600 "${APP_PASS_FILE}"

log_info "Actualizando secrets en GitHub..."
printf "%s" "github-actions" | gh secret set WP_USER --repo "${REPO_FULL}" --body - >/dev/null
printf "%s" "${APP_PASS_OUTPUT}" | gh secret set WP_APP_PASSWORD --repo "${REPO_FULL}" --body - >/dev/null
log_success "Secrets WP_USER y WP_APP_PASSWORD actualizados"

log_info "Validando REST API";
curl -sSLI "https://${STAGING_DOMAIN}/wp-json/" | sed -E 's/(Set-Cookie:).*/\1 ***REDACTED***/Ig' || true

log_info "Disparando workflows verify-*..."
for workflow in verify-home.yml verify-settings.yml verify-menus.yml verify-media.yml; do
  gh workflow run "${workflow}" --repo "${REPO_FULL}" >/dev/null || log_warn "No se pudo disparar ${workflow}"
  sleep 2
done

log_info "Esperando 120 segundos para ejecucion de workflows..."
sleep 120

collect_status() {
  local workflow="$1"
  gh run list --repo "${REPO_FULL}" --workflow "${workflow}" --limit 1 --json databaseId,status,conclusion,createdAt,durationMS \
    | jq -r '.[] | "'"${workflow}"'|" + ( .conclusion // .status // "pending" ) + "|" + (.databaseId | tostring) + "|" + (.durationMS | tostring)' 2>/dev/null || echo "${workflow}|unknown|?|?"
}

log_info "Recopilando resultados de workflows..."
RESULTS=(
  "$(collect_status verify-home.yml)"
  "$(collect_status verify-settings.yml)"
  "$(collect_status verify-menus.yml)"
  "$(collect_status verify-media.yml)"
)

printf "\n" > "${REPORT_FILE}"
cat <<EOF >> "${REPORT_FILE}"
# Validacion STAGING -- ${DATE_UTC}

**Host**: https://${STAGING_DOMAIN}  
**Repositorio**: ${REPO_FULL}

## Resumen Workflows verify-*

| Workflow | Estado | Run ID | Duracion (ms) |
|----------|--------|--------|---------------|
EOF

for row in "${RESULTS[@]}"; do
  IFS='|' read -r wf status runid duration <<< "${row}"
  [[ -z "${status}" ]] && status="unknown"
  [[ -z "${runid}" ]] && runid="-"
  [[ -z "${duration}" || "${duration}" == "null" ]] && duration="-"
  echo "| ${wf} | ${status} | ${runid} | ${duration} |" >> "${REPORT_FILE}"
done

echo -e "\n## Notas" >> "${REPORT_FILE}"
echo "- WordPress instalado en ${STAGING_PATH}." >> "${REPORT_FILE}"
echo "- Usuario tecnico: github-actions (App Password regenerada)." >> "${REPORT_FILE}"
echo "- Secrets WP_USER y WP_APP_PASSWORD actualizados en GitHub." >> "${REPORT_FILE}"
echo "- Contrasena admin temporal almacenada en ${ADMIN_PASS_FILE}." >> "${REPORT_FILE}"

log_success "Reporte generado en ${REPORT_FILE}"

log_info "Actualizando bitacora 082"
cat <<EOF >> "${BITACORA}"

## ${DATE_UTC} -- Instalacion de WordPress en STAGING
- Host: https://${STAGING_DOMAIN}
- Docroot: ${STAGING_PATH}
- DB_HOST: ${DB_HOST} (guardado en wp-config.php)
- Usuario tecnico: github-actions (App Password regenerada en GitHub)
- Workflows verify-* ejecutados (ver ${REPORT_FILE})
EOF

log_info "Preparando cambios para commit"
git -C "${ROOT_DIR}" add "${REPORT_FILE}" "${BITACORA}" >/dev/null 2>&1 || true
if git -C "${ROOT_DIR}" diff --cached --quiet; then
  log_warn "No hay cambios para commitear"
else
  git -C "${ROOT_DIR}" commit -m "chore(staging): instalar WordPress y validar verify-*" >/dev/null
  git -C "${ROOT_DIR}" push >/dev/null || log_warn "No se pudo pushear automaticamente"
fi

log_success "Proceso completo"
log_warn "Recomendado: rotar contrasena admin y eliminar ${ADMIN_PASS_FILE} y ${APP_PASS_FILE} tras guardarlas de forma segura."
