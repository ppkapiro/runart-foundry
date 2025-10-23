#!/usr/bin/env bash
set -euo pipefail
# Fix WordPress URL configuration in Local sites to prevent redirect loops
# Usage: bash tools/fix_local_wp_urls.sh

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONF="$REPO_ROOT/docs/integration_wp_staging_lite/local_site.env"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  WordPress Local URL Fix - Prevent Redirect Loops${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""

# Verificar que existe local_site.env
if [ ! -f "$CONF" ]; then
  echo -e "${RED}❌ Error: No se encontró $CONF${NC}"
  echo "Crea el archivo con:"
  echo "  WP_PUBLIC_PATH=\"/mnt/c/Users/USER/Local Sites/SITE/app/public\""
  echo "  BASE_URL=\"http://localhost:PORT\""
  exit 1
fi

# Cargar configuración
# shellcheck disable=SC1090
source "$CONF"

WP_PUBLIC_PATH=${WP_PUBLIC_PATH:-${LOCAL_SITE_PATH:-}}
if [ -z "${WP_PUBLIC_PATH}" ]; then
  echo -e "${RED}❌ Error: WP_PUBLIC_PATH no definido en $CONF${NC}"
  exit 1
fi

if [ -z "${BASE_URL:-}" ]; then
  echo -e "${RED}❌ Error: BASE_URL no definido en $CONF${NC}"
  exit 1
fi

WP_CONFIG="${WP_PUBLIC_PATH}/wp-config.php"

if [ ! -f "$WP_CONFIG" ]; then
  echo -e "${RED}❌ Error: No se encontró wp-config.php en${NC}"
  echo "   $WP_CONFIG"
  exit 1
fi

echo -e "📍 Sitio Local detectado:"
echo "   WP_PUBLIC_PATH: $WP_PUBLIC_PATH"
echo "   BASE_URL: $BASE_URL"
echo "   wp-config.php: $WP_CONFIG"
echo ""

# Verificar si ya tiene las constantes
if grep -q "WP_HOME.*${BASE_URL}" "$WP_CONFIG" && grep -q "WP_SITEURL.*${BASE_URL}" "$WP_CONFIG"; then
  echo -e "${YELLOW}⚠️  Las constantes WP_HOME y WP_SITEURL ya están configuradas correctamente.${NC}"
  echo ""
  echo "Constantes actuales:"
  grep -A1 "WP_HOME\|WP_SITEURL" "$WP_CONFIG" | head -4
  echo ""
  echo -e "${GREEN}✅ No se requiere acción.${NC}"
  exit 0
fi

# Crear backup
BACKUP="${WP_CONFIG}.backup_$(date +%Y%m%d_%H%M%S)"
echo "→ Creando backup de wp-config.php..."
cp "$WP_CONFIG" "$BACKUP"
echo -e "  ${GREEN}✓${NC} Backup: $BACKUP"
echo ""

# Verificar si ya existen las constantes (pero con valores incorrectos)
if grep -q "define.*WP_HOME" "$WP_CONFIG" || grep -q "define.*WP_SITEURL" "$WP_CONFIG"; then
  echo -e "${YELLOW}⚠️  Detectadas definiciones existentes de WP_HOME/WP_SITEURL.${NC}"
  echo "   Las eliminaremos y agregaremos nuevas con el valor correcto."
  echo ""
  
  # Eliminar líneas existentes de WP_HOME y WP_SITEURL
  sed -i.tmp "/define.*['\"]WP_HOME['\"]/d" "$WP_CONFIG"
  sed -i.tmp "/define.*['\"]WP_SITEURL['\"]/d" "$WP_CONFIG"
  # Eliminar posible comentario de bloque anterior
  sed -i.tmp "/URL Configuration - Auto-fixed/d" "$WP_CONFIG"
  rm -f "${WP_CONFIG}.tmp"
fi

echo "→ Insertando constantes WP_HOME y WP_SITEURL..."

# Insertar constantes antes de "That's all, stop editing"
awk -v base_url="$BASE_URL" '
/\/\* That'\''s all, stop editing! Happy publishing\. \*\// {
    print "/* URL Configuration - Auto-fixed to prevent redirect loops */"
    print "define( '\''WP_HOME'\'', '\''" base_url "'\'' );"
    print "define( '\''WP_SITEURL'\'', '\''" base_url "'\'' );"
    print ""
}
{ print }
' "$WP_CONFIG" > "${WP_CONFIG}.tmp"

mv "${WP_CONFIG}.tmp" "$WP_CONFIG"

echo -e "  ${GREEN}✓${NC} Constantes insertadas correctamente"
echo ""

# Verificar resultado
echo "→ Verificando configuración aplicada:"
grep -B1 -A3 "URL Configuration" "$WP_CONFIG" || {
  echo -e "${RED}❌ Error: No se pudieron insertar las constantes${NC}"
  echo "Restaurando backup..."
  mv "$BACKUP" "$WP_CONFIG"
  exit 1
}

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Configuración aplicada exitosamente${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""
echo "Próximos pasos:"
echo "  1. Recarga el sitio en tu navegador"
echo "  2. Verifica con: curl -I ${BASE_URL}/"
echo "  3. Debe devolver HTTP 200 OK (sin redirecciones)"
echo ""
echo "Si necesitas revertir:"
echo "  cp \"$BACKUP\" \"$WP_CONFIG\""
