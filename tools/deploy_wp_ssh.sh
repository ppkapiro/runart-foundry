#!/usr/bin/env bash
# RunArt Foundry - Controlled SSH deployment via WP-CLI
# CI-GUARD: DRY-RUN-CAPABLE (este script soporta DRY_RUN y READ_ONLY por defecto)
set -euo pipefail

#------------------------------------------------------------------------------
# Configuration & Guardrails
#------------------------------------------------------------------------------
ENVIRONMENT="${1:-staging}"             # staging | prod
# Guardas por defecto: NO efectuar cambios en servidores si no hay aprobación explícita
READ_ONLY="${READ_ONLY:-1}"              # 1 = no modifica servidor (freeze)
DRY_RUN="${DRY_RUN:-1}"                  # 1 = rsync con --dry-run
PROMOTE_TO_PROD=${PROMOTE_TO_PROD:-false}
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORTS_DIR="${ROOT_DIR}/_reports"
ARTIFACTS_DIR="${ROOT_DIR}/_artifacts"
LOG_JSON="${REPORTS_DIR}/WP_SSH_DEPLOY_LOG.json"
REPORT_MD="${REPORTS_DIR}/WP_SSH_DEPLOY.md"
PAGES_JSON="${REPORTS_DIR}/WP_PAGES_STATUS.json"
SMOKE_MD="${REPORTS_DIR}/SMOKE_STAGING.md"
SMOKE_ARTIFACT_DIR="${ARTIFACTS_DIR}/screenshots_staging"
ENV_MD="${REPORTS_DIR}/WP_ENV_CHECKLIST.md"
mkdir -p "${REPORTS_DIR}" "${ARTIFACTS_DIR}" "${SMOKE_ARTIFACT_DIR}"

#------------------------------------------------------------------------------
# Required environment variables (secrets/vars)
#------------------------------------------------------------------------------
required_env=(
  WP_SSH_HOST
  WP_SSH_USER
  WP_SSH_PASS
  WP_BASE_PATH
  WP_URL_STAGING
  THEME_SLUG
)

if [[ "${ENVIRONMENT}" == "prod" || "${PROMOTE_TO_PROD}" == "true" ]]; then
  required_env+=(WP_URL_PROD WP_BASE_PATH_PROD)
fi

for var in "${required_env[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "[ERROR] Missing required env var: ${var}" >&2
    exit 1
  fi
done

#------------------------------------------------------------------------------
# Helper functions
#------------------------------------------------------------------------------
log_info()  { echo "[INFO]  $*"; }
log_warn()  { echo "[WARN]  $*" >&2; }
log_error() { echo "[ERROR] $*" >&2; }

init_log_file() {
  if [[ ! -f "${LOG_JSON}" ]]; then
    printf '[]' >"${LOG_JSON}"
  fi
}

append_log() {
  local step="$1"; shift
  local status="$1"; shift
  local message="$1"; shift
  local meta="${1:-}" 
  local now
  now="$(date -u +%FT%TZ)"
  jq --arg step "${step}" \
     --arg status "${status}" \
     --arg message "${message}" \
     --arg time "${now}" \
     --arg meta "${meta}" \
      '. += [{"timestamp":$time,"step":$step,"status":$status,"message":$message,"meta_raw":$meta}]' \
     "${LOG_JSON}" >"${LOG_JSON}.tmp" || {
       echo "[ERROR] Failed to append log entry (meta=${meta})" >&2
       rm -f "${LOG_JSON}.tmp"
       return 1
     }
  mv "${LOG_JSON}.tmp" "${LOG_JSON}"
}

run_ssh() {
  local cmd="$1"
  local retries=3
  local attempt=1
  export SSHPASS="${WP_SSH_PASS}"
  while (( attempt <= retries )); do
    if sshpass -e ssh -o StrictHostKeyChecking=no "${WP_SSH_USER}@${WP_SSH_HOST}" "${cmd}"; then
      return 0
    fi
    attempt=$((attempt+1))
    sleep $((attempt * 2))
  done
  return 1
}

run_wp() {
  local command="$1"
  local path="$2"
  run_ssh "cd ${path} && wp --allow-root ${command}"
}

rsync_theme() {
  local env_label="$1"
  local local_dir="${ROOT_DIR}/wp-content/themes/${THEME_SLUG}"
  local remote_dir="$2"
  local include_file
  include_file="$(mktemp)"
  local exclude_file
  exclude_file="$(mktemp)"

  IFS=',' read -ra includes <<< "${SYNC_INCLUDE:-assets/**,templates/**,*.php,*.css}"
  IFS=',' read -ra excludes <<< "${SYNC_EXCLUDE:-.git,node_modules,*.map,_artifacts,_reports}"

  for pattern in "${excludes[@]}"; do
    pattern="${pattern// /}"
    [[ -z "${pattern}" ]] && continue
    echo "- ${pattern}" >>"${exclude_file}"
  done
  for pattern in "${includes[@]}"; do
    pattern="${pattern// /}"
    [[ -z "${pattern}" ]] && continue
    echo "+ ${pattern}" >>"${include_file}"
  done
  echo "- *" >>"${include_file}"

  export SSHPASS="${WP_SSH_PASS}"
  if [[ "${READ_ONLY}" == "1" ]]; then
    log_warn "READ_ONLY=1: Backup remoto omitido (solo documentación)."
    append_log "backup" "skip" "READ_ONLY: backup omitido" '{}'
  else
    log_info "Backing up remote theme directory"
    run_ssh "cd ${remote_dir%/*} && tar -czf /tmp/${THEME_SLUG}_backup_${TIMESTAMP}.tgz ${THEME_SLUG}" \
      && append_log "backup" "ok" "Theme backup created" "{\"path\":\"/tmp/${THEME_SLUG}_backup_${TIMESTAMP}.tgz\"}" \
      || append_log "backup" "warn" "Theme backup failed" '{}'
  fi

  log_info "Syncing theme files via rsync (DRY_RUN=${DRY_RUN}, READ_ONLY=${READ_ONLY})"
  # CI-GUARD: el comando rsync incluye soporte para --dry-run cuando DRY_RUN=1
  local rsync_flags=( -av )
  if [[ "${DRY_RUN}" == "1" || "${READ_ONLY}" == "1" ]]; then
    rsync_flags+=( --dry-run )
  fi
  if [[ "${READ_ONLY}" == "1" ]]; then
    log_warn "READ_ONLY=1: Se realizará rsync en modo --dry-run (sin cambios)."
  fi

  if sshpass -e rsync "${rsync_flags[@]}" \
    --rsync-path="mkdir -p ${remote_dir} && rsync" \
    --rsh="ssh -o StrictHostKeyChecking=no" \
    --filter="merge ${exclude_file}" \
    --filter="merge ${include_file}" \
    "${local_dir}/" "${WP_SSH_USER}@${WP_SSH_HOST}:${remote_dir}/"; then
    append_log "rsync_${env_label}" "ok" "Theme synchronized" "{\"remote_dir\":\"${remote_dir}\"}"
  else
    append_log "rsync_${env_label}" "error" "Theme synchronization failed" '{}'
    rm -f "${include_file}" "${exclude_file}"
    return 1
  fi
  rm -f "${include_file}" "${exclude_file}"
  return 0
}

collect_pages() {
  local path="$1"
  run_ssh "cd ${path} && wp post list --post_type=page --fields=ID,post_title,post_status,post_name --format=json --allow-root"
}

ensure_page_published() {
  local path="$1"
  local slug="$2"
  local response
  response="$(run_ssh "cd ${path} && wp post list --post_type=page --name=${slug} --allow-root --fields=ID,post_status --format=json")"
  if [[ -z "${response}" || "${response}" == "[]" ]]; then
    append_log "publish_${slug}" "warn" "Page not found" "{}"
    return
  fi
  local status
  status="$(echo "${response}" | jq -r '.[0].post_status')"
  local id
  id="$(echo "${response}" | jq -r '.[0].ID')"
  if [[ "${status}" != "publish" ]]; then
    log_info "Publishing page ${slug} (ID ${id})"
    if run_wp "post update ${id} --post_status=publish" "${path}"; then
      append_log "publish_${slug}" "ok" "Page published" "{\"id\":${id}}"
    else
      append_log "publish_${slug}" "error" "Failed to publish page" "{\"id\":${id}}"
    fi
  else
    append_log "publish_${slug}" "skip" "Already published" "{\"id\":${id}}"
  fi
}

run_smoke_tests() {
  local base_url="$1"
  local output_md="$2"
  local urls=(
    "/en/home/"
    "/en/about/"
    "/en/services/"
    "/en/projects/"
    "/en/contact/"
    "/en/blog/"
    "/es/inicio/"
    "/es/sobre-nosotros/"
    "/es/servicios/"
    "/es/projects/"
    "/es/contacto/"
    "/es/blog-2/"
  )
  local ts
  ts="$(date +%s)"
  {
    echo "# Smoke Test (${base_url})"
    echo "Fecha UTC: $(date -u +%F' '%T)"
    echo ""
    echo "| URL | HTTP | H1 | Date | Cache-Control | ETag |"
    echo "| --- | --- | --- | --- | --- | --- |"
  } >"${output_md}"

  for path in "${urls[@]}"; do
    local target="${base_url}${path}?v=${ts}"
    local headers_file
    headers_file="$(mktemp)"
    local body_file
    body_file="$(mktemp)"
  local code
  code="$(curl -sSL -D "${headers_file}" -o "${body_file}" -w '%{http_code}' "${target}" || true)"
  code="${code//$'\n'/}"
    local date_hdr
  date_hdr="$(grep -i '^Date:' "${headers_file}" | tail -n1 | cut -d' ' -f2- | tr -d '\r' || true)"
    local cache_hdr
  cache_hdr="$(grep -i '^Cache-Control:' "${headers_file}" | tail -n1 | cut -d' ' -f2- | tr -d '\r' || true)"
    local etag_hdr
  etag_hdr="$(grep -i '^ETag:' "${headers_file}" | tail -n1 | cut -d' ' -f2- | tr -d '\r' || true)"
    local h1
  h1="$(grep -o '<h1[^>]*>[^<]*</h1>' "${body_file}" 2>/dev/null | head -n1 | sed -e 's/<[^>]*>//g' -e 's/^ *//g' -e 's/ *$//g' || true)"
    h1=${h1:-"(sin H1)"}
    printf '| %s | %s | %s | %s | %s | %s |
' "${path}" "${code:-NA}" "${h1}" "${date_hdr:-NA}" "${cache_hdr:-NA}" "${etag_hdr:-NA}" >>"${output_md}"
    rm -f "${headers_file}" "${body_file}"
  done
}

#------------------------------------------------------------------------------
# Main deployment flow (staging)
#------------------------------------------------------------------------------
init_log_file
append_log "start" "ok" "Deployment script initiated" "{\"env\":\"${ENVIRONMENT}\"}"

REMOTE_PATH_STAGING="${WP_BASE_PATH}"
REMOTE_URL_STAGING="${WP_URL_STAGING}"
REMOTE_THEME_DIR_STAGING="${REMOTE_PATH_STAGING}/wp-content/themes/${THEME_SLUG}"

log_info "Validating SSH connectivity"
if run_ssh "echo connected" >/dev/null; then
  append_log "ssh_check" "ok" "SSH connectivity verified" '{}'
else
  append_log "ssh_check" "error" "SSH connectivity failed" '{}'
  exit 1
fi

log_info "Validating WordPress core"
if run_wp "core is-installed" "${REMOTE_PATH_STAGING}" >/dev/null; then
  append_log "wp_core" "ok" "WordPress detected" '{}'
else
  append_log "wp_core" "error" "wp core is-installed failed" '{}'
  exit 1
fi

SITE_URL="$(run_wp "option get siteurl" "${REMOTE_PATH_STAGING}" 2>/dev/null || echo "")"
append_log "wp_siteurl" "ok" "Site URL detected" "{\"siteurl\":\"${SITE_URL}\"}"

CORE_VERSION="$(run_wp "core version" "${REMOTE_PATH_STAGING}" 2>/dev/null | tr -d '\r' || echo "")"
PHP_VERSION="$(run_wp "eval 'echo phpversion();'" "${REMOTE_PATH_STAGING}" 2>/dev/null | tr -d '\r' || echo "")"
THEME_LIST_JSON="$(run_wp "theme list --fields=name,status,version --format=json" "${REMOTE_PATH_STAGING}" 2>/dev/null || echo "[]")"
PLUGIN_LIST_JSON="$(run_wp "plugin list --status=active --fields=name,version --format=json" "${REMOTE_PATH_STAGING}" 2>/dev/null || echo "[]")"
CLI_VERSION="$(run_wp "cli version" "${REMOTE_PATH_STAGING}" 2>/dev/null | tr -d '\r' || echo "")"
ACTIVE_STYLESHEET="$(run_wp "option get stylesheet" "${REMOTE_PATH_STAGING}" 2>/dev/null | tr -d '\r' || echo "")"

log_info "Collecting page status (before)"
PAGES_BEFORE="$(collect_pages "${REMOTE_PATH_STAGING}")"
echo "${PAGES_BEFORE}" | jq '.' > "${PAGES_JSON}.tmp"

log_info "Synchronizing theme files"
rsync_theme "staging" "${REMOTE_THEME_DIR_STAGING}" || exit 1

if [[ "${READ_ONLY}" == "1" ]]; then
  log_warn "READ_ONLY=1: Mantenimiento WP-CLI omitido (rewrite/cache/publish)."
  append_log "rewrite_flush" "skip" "READ_ONLY: omitido" '{}'
  append_log "cache_flush" "skip" "READ_ONLY: omitido" '{}'
else
  log_info "Running WP-CLI maintenance"
  run_wp "rewrite flush --hard" "${REMOTE_PATH_STAGING}" && append_log "rewrite_flush" "ok" "Permalinks flushed" '{}'
  run_wp "cache flush" "${REMOTE_PATH_STAGING}" && append_log "cache_flush" "ok" "Cache flushed" '{}'

  REQUIRED_SLUGS=(services servicios blog blog-2 home inicio about sobre-nosotros contact contacto)
  for slug in "${REQUIRED_SLUGS[@]}"; do
    ensure_page_published "${REMOTE_PATH_STAGING}" "${slug}"
  done
fi

log_info "Collecting page status (after)"
PAGES_AFTER="$(collect_pages "${REMOTE_PATH_STAGING}")"
before_json="$(echo "${PAGES_BEFORE:-[]}" | jq -c '.' 2>/dev/null || echo '[]')"
after_json="$(echo "${PAGES_AFTER:-[]}" | jq -c '.' 2>/dev/null || echo '[]')"
jq -n --arg timestamp "${TIMESTAMP}" \
  --arg env "staging" \
  --argjson before "${before_json}" \
  --argjson after "${after_json}" \
  '{"timestamp":$timestamp,"environment":$env,"before":$before,"after":$after}' \
      > "${PAGES_JSON}"
append_log "pages_snapshot" "ok" "Page status captured" '{}'

log_info "Executing smoke tests (staging)"
run_smoke_tests "${REMOTE_URL_STAGING}" "${SMOKE_MD}"
append_log "smoke_tests" "ok" "Smoke tests executed" "{\"report\":\"${SMOKE_MD##${ROOT_DIR}/}\"}"

# Environment checklist
ACTIVE_THEME_LINE="$(echo "${THEME_LIST_JSON}" | jq -r '.[] | select(.status=="active") | "- " + .name + " (" + .version + ")"' 2>/dev/null || echo "- NA")"
ACTIVE_THEME_LINE="${ACTIVE_THEME_LINE:-"- NA"}"
if [[ "${ACTIVE_THEME_LINE}" == "- NA" && -n "${ACTIVE_STYLESHEET}" ]]; then
  ACTIVE_THEME_LINE="- ${ACTIVE_STYLESHEET} (stylesheet option)"
fi
ACTIVE_PLUGINS_TABLE="$(echo "${PLUGIN_LIST_JSON}" | jq -r '.[] | "| " + .name + " | " + .version + " |"' 2>/dev/null || echo "| (sin plugins activos) | - |")"
{
  echo "# WP Environment Checklist (${TIMESTAMP})"
  echo "- Site URL: ${SITE_URL:-NA}"
  echo "- WordPress core: ${CORE_VERSION:-NA}"
  echo "- PHP version: ${PHP_VERSION:-NA}"
  echo "- WP-CLI: ${CLI_VERSION:-NA}"
  echo ""
  echo "## Active Theme"
  echo "${ACTIVE_THEME_LINE}"
  echo ""
  echo "## Active Plugins"
  echo "| Plugin | Version |"
  echo "| --- | --- |"
  echo "${ACTIVE_PLUGINS_TABLE}"
} >"${ENV_MD}"
append_log "env_checklist" "ok" "Environment checklist updated" "{\"report\":\"${ENV_MD##${ROOT_DIR}/}\"}"

#------------------------------------------------------------------------------
# Markdown deployment summary
#------------------------------------------------------------------------------
{
  echo "# WP SSH Deployment (${TIMESTAMP})"
  echo "Environment: staging"
  echo ""
  echo "## Resumen"
  echo "- Host: ${WP_SSH_HOST}"
  echo "- Ruta base: ${REMOTE_PATH_STAGING}"
  echo "- Tema: ${THEME_SLUG}"
  echo "- READ_ONLY: ${READ_ONLY}"
  echo "- DRY_RUN: ${DRY_RUN}"
  echo "- Archivo log JSON: ${LOG_JSON##${ROOT_DIR}/}"
  echo "- Smoke test: ${SMOKE_MD##${ROOT_DIR}/}"
  echo ""
  echo "## Páginas publicadas"
  for slug in "${REQUIRED_SLUGS[@]}"; do
    status_value="$(echo "${PAGES_AFTER}" | jq -r ".[] | select(.post_name==\"${slug}\") | .post_status" 2>/dev/null || echo "NA")"
    echo "- ${slug}: ${status_value:-NA}"
  done
  echo ""
  echo "## Acciones ejecutadas"
  echo "- rsync controlado (backup previo, filtros)"
  echo "- wp rewrite flush --hard"
  echo "- wp cache flush"
  echo "- Publicación de páginas críticas (si aplicó)"
  echo "- Smoke test EN/ES"
} >"${REPORT_MD}"

log_info "Deployment finished"
append_log "finish" "ok" "Deployment completed" '{}'

exit 0
