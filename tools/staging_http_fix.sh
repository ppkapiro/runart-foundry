#!/usr/bin/env bash
set -euo pipefail

# ================== CONFIG ==================
STAGING_HOST="staging.runartfoundry.com"
STAGING_PATH="/homepages/7/d958591985/htdocs/staging"
IONOS_SSH_HOST="${IONOS_SSH_HOST:-}"
SSH_PORT="${SSH_PORT:-22}"
BITACORA="apps/briefing/docs/internal/briefing_system/ci/082_bitacora_fase7_conexion_wp_real.md"
LOG="logs/staging_http_fix_$(date +%Y%m%d_%H%M%S).log"

# ================== HELPERS ==================
say()  { echo -e "$*" | tee -a "$LOG"; }
hr()   { say "\n------------------------------------------------------------\n"; }
sshx() {
  if [[ -n "${IONOS_SSH_PASS:-}" ]]; then
    sshpass -p "$IONOS_SSH_PASS" ssh -p "$SSH_PORT" "$IONOS_SSH_HOST" "$@"
  else
    ssh -p "$SSH_PORT" "$IONOS_SSH_HOST" "$@"
  fi
}

need_ssh() {
  if [[ -z "$IONOS_SSH_HOST" ]]; then
    say "❌ Falta IONOS_SSH_HOST. Exporta: export IONOS_SSH_HOST='usuario@host' (y opcional SSH_PORT)."
    exit 1
  fi
}

backup_file() {
  local f="$1"
  local ts; ts="$(date +%Y%m%d_%H%M%S)"
  sshx "if [ -f '$f' ]; then cp -p '$f' '${f}.bak.${ts}'; fi"
}

ensure_test_index() {
  sshx "mkdir -p '$STAGING_PATH'"
  sshx "echo 'STAGING READY — $(date -u) — ${STAGING_HOST} — ${STAGING_PATH}' > '${STAGING_PATH}/index.html'"
  sshx "chmod 644 '${STAGING_PATH}/index.html'"
}

curl_head() {
  local url="$1"
  say "\n[HTTP] curl -I $url"
  curl -sSLI "$url" | sed -E 's/(Set-Cookie:).*/\1 ***REDACTED***/Ig' | tee -a "$LOG"
}

detect_redirect_target() {
  curl -sSLI "$1" | awk '/^Location:/ {print $2}' | tail -n 1 | tr -d '\r'
}

has_wp_cli() {
  sshx "command -v wp >/dev/null 2>&1" && return 0 || return 1
}

# ================== FASE 1: VALIDACIÓN HTTP ==================
hr
say "▶️ Fase 1 — Validación HTTP/HTTPS inicial"
ensure_test_index
curl_head "http://${STAGING_HOST}/index.html"
curl_head "https://${STAGING_HOST}/index.html"

REDIR_HTTP="$(detect_redirect_target "http://${STAGING_HOST}/")"
REDIR_HTTPS="$(detect_redirect_target "https://${STAGING_HOST}/")"

say "\nLocation (HTTP):  ${REDIR_HTTP:-<sin redirección>}"
say "Location (HTTPS): ${REDIR_HTTPS:-<sin redirección>}"

# ================== FASE 2: CORRECCIÓN .htaccess ==================
hr
say "▶️ Fase 2 — Revisar/corregir .htaccess en ${STAGING_PATH}"
need_ssh

backup_file "${STAGING_PATH}/.htaccess"

sshx "if [ -f '${STAGING_PATH}/.htaccess' ]; then \
        sed -i -E \"s#(runartfoundry\\.com)#\\#\\#FORCED-REDIR-REMOVED \\1#g\" '${STAGING_PATH}/.htaccess'; \
      fi"

sshx "if [ ! -f '${STAGING_PATH}/.htaccess' ]; then cat > '${STAGING_PATH}/.htaccess' <<'HTE'
# Clean WordPress .htaccess for staging (no canonical host force)
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
# pass everything to index.php
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
HTE
fi"

# ================== FASE 3: CORRECCIÓN wp-config.php ==================
hr
say "▶️ Fase 3 — Ajustar WP_HOME/WP_SITEURL en wp-config.php"
backup_file "${STAGING_PATH}/wp-config.php"

sshx "if [ -f '${STAGING_PATH}/wp-config.php' ]; then \
        if grep -q 'runartfoundry.com' '${STAGING_PATH}/wp-config.php'; then \
           sed -i \"s#https://runartfoundry.com#https://${STAGING_HOST}#g\" '${STAGING_PATH}/wp-config.php'; \
        fi; \
        if ! grep -q \"define('WP_HOME'\" '${STAGING_PATH}/wp-config.php'; then \
           echo \"define('WP_HOME','https://${STAGING_HOST}');\" >> '${STAGING_PATH}/wp-config.php'; \
        fi; \
        if ! grep -q \"define('WP_SITEURL'\" '${STAGING_PATH}/wp-config.php'; then \
           echo \"define('WP_SITEURL','https://${STAGING_HOST}');\" >> '${STAGING_PATH}/wp-config.php'; \
        fi; \
      else \
        echo '⚠️ No existe wp-config.php en ${STAGING_PATH}. Solo .htaccess corregido y index.html de prueba.' >> /dev/stderr; \
      fi"

# ================== FASE 4: WP-CLI (si disponible) ==================
hr
say "▶️ Fase 4 — Ajustes vía WP-CLI (si está instalado en el servidor)"
if has_wp_cli; then
  say "[WP-CLI] Detectado. Corrigiendo opciones y URLs internas…"
  sshx "cd '${STAGING_PATH}' && \
        wp option get siteurl || true; \
        wp option get home || true; \
        wp option update siteurl 'https://${STAGING_HOST}' || true; \
        wp option update home   'https://${STAGING_HOST}' || true; \
        wp search-replace 'https://runartfoundry.com' 'https://${STAGING_HOST}' --all-tables --precise --report-changed-only || true"
else
  say "[WP-CLI] No disponible. Saltando cambios en BD. (Si redirige aún, ajusta siteurl/home vía phpMyAdmin)"
fi

# ================== FASE 5: RE-PRUEBA HTTP ==================
hr
say "▶️ Fase 5 — Revalidación HTTP/HTTPS tras cambios"
curl_head "http://${STAGING_HOST}/index.html"
curl_head "https://${STAGING_HOST}/index.html"
curl_head "https://${STAGING_HOST}/wp-json/" || true

REDIR_HTTP2="$(detect_redirect_target "http://${STAGING_HOST}/")"
REDIR_HTTPS2="$(detect_redirect_target "https://${STAGING_HOST}/")"
say "\nLocation (HTTP)  post-fix: ${REDIR_HTTP2:-<sin redirección>}"
say "Location (HTTPS) post-fix: ${REDIR_HTTPS2:-<sin redirección>}"

# ================== CRITERIOS DE ÉXITO ==================
hr
SUCCESS=1
[[ -n "${REDIR_HTTP2}"  ]] && [[ "${REDIR_HTTP2}"  =~ runartfoundry\.com ]] && SUCCESS=0
[[ -n "${REDIR_HTTPS2}" ]] && [[ "${REDIR_HTTPS2}" =~ runartfoundry\.com ]] && SUCCESS=0

if [[ $SUCCESS -eq 1 ]]; then
  say "✅ STAGING INDEPENDIENTE: sin redirección a runartfoundry.com. HTTP/HTTPS OK."
else
  say "⚠️ AÚN REDIRIGE a runartfoundry.com. Revisa: .htaccess (reglas), wp-config (WP_HOME/WP_SITEURL), DB siteurl/home (phpMyAdmin)."
fi

# ================== SALIDA RESUMEN PARA BITÁCORA ==================
hr
say "Resumen corto para bitácora:"
SUMMARY=$(cat <<TXT
- Host: ${STAGING_HOST}
- Docroot: ${STAGING_PATH}
- HTTP Location final:  ${REDIR_HTTP2:-<sin redirección>}
- HTTPS Location final: ${REDIR_HTTPS2:-<sin redirección>}
- WP-CLI: $(if has_wp_cli; then echo "sí"; else echo "no"; fi)
TXT
)
say "$SUMMARY"

echo "$SUMMARY" > "logs/_staging_http_fix_summary.txt"

exit 0
