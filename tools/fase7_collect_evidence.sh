#!/usr/bin/env bash
set -euo pipefail

# === Configuración ===
ROOT_DIR="$(git rev-parse --show-toplevel)"
TEMPLATES_DIR="$ROOT_DIR/apps/briefing/docs/internal/briefing_system/integrations/wp_real/_templates"
OUT_REPO="$TEMPLATES_DIR/evidencia_repo_remotes.txt"
OUT_LOCAL="$TEMPLATES_DIR/evidencia_local_mirror.txt"
OUT_SERVER="$TEMPLATES_DIR/evidencia_server_versions.txt"
OUT_REST="$TEMPLATES_DIR/evidencia_rest_sample.txt"

# Variables opcionales (el owner puede exportarlas en su shell antes de ejecutar)
: "${WP_LOCAL_MIRROR_DIR:="$ROOT_DIR/mirror"}"                 # Ruta donde el owner descargó el mirror local
: "${WP_BASE_PROBE_URL:="https://runalfondry.com"}"           # URL base para curl de /wp-json/
: "${WP_SSH_HOST:=""}"                                        # ej: "user@host" o "user@host -p 22"
: "${WP_SSH_PORT:=22}"

mkdir -p "$TEMPLATES_DIR"

timestamp() { date +"%Y-%m-%d %H:%M:%S %Z"; }

write_header() {
  local f="$1"; local title="$2"
  {
    echo "=== $title ==="
    echo "Fecha de captura: $(timestamp)"
    echo
  } > "$f"
}

append_section() {
  local f="$1"; local title="$2"
  {
    echo
    echo "== $title =="
  } >> "$f"
}

sanitize() {
  # Elimina posibles tokens/headers sensibles si accidentalmente aparecen
  sed -E \
    -e 's/(Authorization:.*)/Authorization: *** REDACTED ***/Ig' \
    -e 's/(Set-Cookie:.*)/Set-Cookie: *** REDACTED ***/Ig' \
    -e 's/(Cookie:.*)/Cookie: *** REDACTED ***/Ig' \
    -e 's/(Password:.*)/Password: *** REDACTED ***/Ig' \
    -e 's/(passwd|secret|token|key|apikey|app_password)=([^[:space:]]+)/\1=***REDACTED***/Ig'
}

# --- Evidencia: Repo (git remotes / branch / workflows) ---
write_header "$OUT_REPO" "INVENTARIO REPO (Remotes / Branch / Workflows)"
{
  echo "Directorio raíz del repo: $ROOT_DIR"
  echo
  echo "git remote -v:"
  git -C "$ROOT_DIR" remote -v || true
  echo
  echo "Branch actual:"
  git -C "$ROOT_DIR" rev-parse --abbrev-ref HEAD || true
  echo
  echo "Workflows detectados en .github/workflows:"
  ls -1 "$ROOT_DIR/.github/workflows" 2>/dev/null || echo "(no workflows encontrados)"
} | sanitize >> "$OUT_REPO"

# --- Evidencia: Local mirror ---
write_header "$OUT_LOCAL" "INVENTARIO LOCAL (Mirror)"
{
  echo "Ruta local del mirror: $WP_LOCAL_MIRROR_DIR"
  if [ -d "$WP_LOCAL_MIRROR_DIR" ]; then
    echo
    echo "Estadísticas:"
    du -sh "$WP_LOCAL_MIRROR_DIR" 2>/dev/null || true
    echo
    echo "Listado alto nivel:"
    if command -v tree >/dev/null 2>&1; then
      tree -L 2 "$WP_LOCAL_MIRROR_DIR" | head -n 500
    else
      find "$WP_LOCAL_MIRROR_DIR" -maxdepth 2 -mindepth 1 -printf "%y %p\n" 2>/dev/null | head -n 500
    fi
  else
    echo
    echo "(PENDIENTE) No existe la ruta $WP_LOCAL_MIRROR_DIR"
  fi
} | sanitize >> "$OUT_LOCAL"

# --- Evidencia: SSH / Server versions ---
write_header "$OUT_SERVER" "INFORMACIÓN DEL SERVIDOR (SSH)"
if [ -n "$WP_SSH_HOST" ]; then
  SSH_CMD="ssh -p $WP_SSH_PORT $WP_SSH_HOST"
  append_section "$OUT_SERVER" "SO y kernel (uname -a)"
  $SSH_CMD 'uname -a 2>/dev/null || echo "(sin uname)"' | sanitize >> "$OUT_SERVER" || true

  append_section "$OUT_SERVER" "PHP (php -v)"
  $SSH_CMD 'php -v 2>/dev/null || echo "(sin php -v)"' | sanitize >> "$OUT_SERVER" || true

  append_section "$OUT_SERVER" "Servidor Web (nginx -v | apachectl -v)"
  $SSH_CMD 'nginx -v 2>&1 || apachectl -v 2>&1 || echo "(sin nginx/apache)"' | sanitize >> "$OUT_SERVER" || true

  append_section "$OUT_SERVER" "Base de datos (mysql -V)"
  $SSH_CMD 'mysql -V 2>/dev/null || echo "(sin mysql -V)"' | sanitize >> "$OUT_SERVER" || true
else
  echo "(PENDIENTE) SSH no configurado (exporta WP_SSH_HOST y WP_SSH_PORT para habilitarlo)" >> "$OUT_SERVER"
fi

# --- Evidencia: REST ---
write_header "$OUT_REST" "VERIFICACIÓN REST API"
{
  echo "Endpoint base:"
  echo "GET $WP_BASE_PROBE_URL/wp-json/"
  echo
  curl -sS -i "$WP_BASE_PROBE_URL/wp-json/" | head -n 100 || echo "(fallo curl)"
  echo
  echo "Endpoint users/me (sin credenciales, se espera 401):"
  echo "GET $WP_BASE_PROBE_URL/wp-json/wp/v2/users/me"
  curl -sS -i "$WP_BASE_PROBE_URL/wp-json/wp/v2/users/me" | head -n 50 || echo "(fallo curl)"
} | sanitize >> "$OUT_REST"

echo "OK: evidencias escritas en:"
echo " - $OUT_REPO"
echo " - $OUT_LOCAL"
echo " - $OUT_SERVER"
echo " - $OUT_REST"
