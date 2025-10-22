#!/usr/bin/env bash
set -euo pipefail
# Vincula (symlink) o copia el MU-plugin al sitio Local.
# Configuración en docs/integration_wp_staging_lite/local_site.env
# Variables usadas:
#   WP_PUBLIC_PATH=/ruta/absoluta/a/app/public (preferido)
#   LOCAL_SITE_PATH=/path/to/local/app/public (alias histórico)
#   MODE=link|copy (por defecto link)
# Salida: registra acciones en docs/integration_wp_staging_lite/TESTS_PLUGIN_LOCAL.md

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONF="$REPO_ROOT/docs/integration_wp_staging_lite/local_site.env"
TESTS="$REPO_ROOT/docs/integration_wp_staging_lite/TESTS_PLUGIN_LOCAL.md"
PLUGIN_SRC="$REPO_ROOT/wp-content/mu-plugins/wp-staging-lite"
LOADER_SRC="$REPO_ROOT/wp-content/mu-plugins/wp-staging-lite.php"
MU_ROOT_DST=""
MODE="link"

if [ ! -f "$CONF" ]; then
  echo "❌ Falta archivo de configuración: $CONF"
  echo "LOCAL_SITE_PATH=/ruta/al/app/public" > "$CONF"
  echo "MODE=link" >> "$CONF"
  echo "Edita el archivo y reintenta." >&2
  exit 1
fi
# shellcheck disable=SC1090
source "$CONF"
# Permitir ambas variables: WP_PUBLIC_PATH (preferida) o LOCAL_SITE_PATH (alias)
WP_PUBLIC_PATH=${WP_PUBLIC_PATH:-${LOCAL_SITE_PATH:-}}
if [ -z "${WP_PUBLIC_PATH}" ]; then
  echo "❌ Debe definir WP_PUBLIC_PATH (o LOCAL_SITE_PATH) en $CONF" >&2
  exit 1
fi
MODE=${MODE:-link}
MU_ROOT_DST="$WP_PUBLIC_PATH/wp-content/mu-plugins"

mkdir -p "$MU_ROOT_DST"

echo "→ Vinculando plugin al sitio local"
echo "  SRC: $PLUGIN_SRC"
echo "  DST: $MU_ROOT_DST/wp-staging-lite"
echo "  MODE solicitado: $MODE"

MODE_USED="$MODE"
case "$MODE" in
  link)
    if [ -e "$MU_ROOT_DST/wp-staging-lite" ] || [ -L "$MU_ROOT_DST/wp-staging-lite" ]; then
      echo "  • Eliminando destino existente (link o carpeta)"
      rm -rf "$MU_ROOT_DST/wp-staging-lite"
    fi
    if ln -s "$PLUGIN_SRC" "$MU_ROOT_DST/wp-staging-lite" 2>/dev/null; then
      MODE_USED="link"
    else
      echo "  ⚠️ Falló symlink; intentando copia (fallback)"
      rsync -a --delete "$PLUGIN_SRC/" "$MU_ROOT_DST/wp-staging-lite/"
      MODE_USED="copy"
    fi
    ;;
  copy)
    if [ -L "$MU_ROOT_DST/wp-staging-lite" ] || [ -e "$MU_ROOT_DST/wp-staging-lite" ] ; then
      echo "  • Preparando destino para copia (eliminando link/carpeta existente)"
      rm -rf "$MU_ROOT_DST/wp-staging-lite"
    fi
    rsync -a --delete "$PLUGIN_SRC/" "$MU_ROOT_DST/wp-staging-lite/"
    MODE_USED="copy"
    ;;
  *)
    echo "❌ MODE inválido: $MODE (usar link|copy)" >&2
    exit 2
    ;;
esac

# Verificación de estructura de WP en destino
if [ ! -d "$WP_PUBLIC_PATH/wp-admin" ] || [ ! -d "$WP_PUBLIC_PATH/wp-content" ] || [ ! -d "$WP_PUBLIC_PATH/wp-includes" ]; then
  echo "❌ WP_PUBLIC_PATH no parece ser un sitio WP válido: $WP_PUBLIC_PATH" >&2
  echo "   Faltan directorios wp-admin/wp-content/wp-includes" >&2
  exit 3
fi

# Asegurar loader en mu-plugins root del sitio
if [ -f "$LOADER_SRC" ]; then
  # Limpiar loader previo si es un symlink incompatible
  if [ -L "$MU_ROOT_DST/wp-staging-lite.php" ] || [ -e "$MU_ROOT_DST/wp-staging-lite.php" ]; then
    rm -f "$MU_ROOT_DST/wp-staging-lite.php"
  fi
  case "$MODE_USED" in
    link)
      ln -sf "$LOADER_SRC" "$MU_ROOT_DST/wp-staging-lite.php"
      ;;
    copy)
      cp -f "$LOADER_SRC" "$MU_ROOT_DST/wp-staging-lite.php"
      ;;
  esac
else
  echo "⚠️ No se encontró loader en repo: $LOADER_SRC"
fi

{
  echo "\n### $(date '+%Y-%m-%d %H:%M:%S') — Vinculación del MU-plugin"
  echo "- Método: $MODE_USED"
  echo "- Origen plugin: $PLUGIN_SRC"
  echo "- Origen loader: $LOADER_SRC"
  echo "- Destino plugin: $MU_ROOT_DST/wp-staging-lite"
  echo "- Destino loader: $MU_ROOT_DST/wp-staging-lite.php"
} >> "$TESTS"

echo "✅ Vinculación realizada. Reinicia el sitio en Local si es necesario."
