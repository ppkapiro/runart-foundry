#!/usr/bin/env bash
# 🔧 Crear base de datos separada para staging en IONOS
# REQUISITO: Debes crear la base de datos manualmente en el panel IONOS primero

set -euo pipefail

log() { echo "[$(date +%H:%M:%S)] $*"; }

log "═══════════════════════════════════════════════════════════"
log "  PREPARACIÓN DE BASE DE DATOS STAGING"
log "═══════════════════════════════════════════════════════════"
log ""
log "⚠️  ATENCIÓN: Este script requiere que primero crees manualmente"
log "    una nueva base de datos en el panel de IONOS."
log ""
log "Pasos en el panel IONOS:"
log "1. Accede a: https://www.ionos.es/hosting → Bases de datos"
log "2. Crea nueva base de datos MySQL"
log "3. Anota: nombre DB, usuario, password"
log ""
log "Información actual:"
log "  Producción DB: dbs10646556"
log "  Staging DB:    dbs10646556 ❌ (misma que prod)"
log ""
log "Necesitas:"
log "  Nueva DB staging: dbs[NUEVO_ID] (ejemplo: dbs10646557)"
log "  Usuario: dbu[ID] (puede ser el mismo o nuevo)"
log "  Password: [tu nueva password]"
log ""
log "═══════════════════════════════════════════════════════════"
log ""

read -p "¿Ya creaste la nueva base de datos en IONOS? (si/no): " respuesta
if [ "$respuesta" != "si" ]; then
  log "❌ Primero crea la base de datos en el panel IONOS."
  log "   Luego vuelve a ejecutar este script."
  exit 1
fi

log ""
log "Introduce los datos de la NUEVA base de datos staging:"
read -p "Nombre DB staging (ej: dbs10646557): " STAGING_DB_NAME
read -p "Usuario DB staging (ej: dbu2309272): " STAGING_DB_USER
read -sp "Password DB staging: " STAGING_DB_PASS
echo ""
read -p "Host DB staging (default: db5012671937.hosting-data.io): " STAGING_DB_HOST
STAGING_DB_HOST=${STAGING_DB_HOST:-db5012671937.hosting-data.io}

log ""
log "Configuración a aplicar:"
log "  Staging DB: $STAGING_DB_NAME"
log "  Usuario:    $STAGING_DB_USER"
log "  Host:       $STAGING_DB_HOST"
log ""
read -p "¿Es correcta esta configuración? (si/no): " confirma
if [ "$confirma" != "si" ]; then
  log "❌ Operación cancelada."
  exit 1
fi

# Datos de producción (origen)
PROD_DB_NAME="dbs10646556"
PROD_DB_USER="dbu2309272"
PROD_DB_HOST="db5012671937.hosting-data.io"

log ""
log "═══════════════════════════════════════════════════════════"
log "  PASO 1: Exportar base de datos de producción"
log "═══════════════════════════════════════════════════════════"

read -sp "Password de producción ($PROD_DB_USER): " PROD_DB_PASS
echo ""

DUMP_FILE="staging_db_dump_$(date +%Y%m%d_%H%M%S).sql"
log "→ Exportando $PROD_DB_NAME a $DUMP_FILE..."

if ! mysqldump -u"$PROD_DB_USER" -p"$PROD_DB_PASS" -h"$PROD_DB_HOST" "$PROD_DB_NAME" > "$DUMP_FILE"; then
  log "❌ Error exportando base de datos de producción"
  exit 1
fi

log "✓ Dump creado: $DUMP_FILE ($(du -h "$DUMP_FILE" | cut -f1))"

log ""
log "═══════════════════════════════════════════════════════════"
log "  PASO 2: Importar a base de datos staging"
log "═══════════════════════════════════════════════════════════"

log "→ Importando a $STAGING_DB_NAME..."

if ! mysql -u"$STAGING_DB_USER" -p"$STAGING_DB_PASS" -h"$STAGING_DB_HOST" "$STAGING_DB_NAME" < "$DUMP_FILE"; then
  log "❌ Error importando a staging"
  log "   El dump se conserva en: $DUMP_FILE"
  exit 1
fi

log "✓ Base de datos staging importada"

log ""
log "═══════════════════════════════════════════════════════════"
log "  PASO 3: Actualizar wp-config.php de staging"
log "═══════════════════════════════════════════════════════════"

STAGING_WP="/homepages/7/d958591985/htdocs/staging/wp-config.php"

if [ ! -f "$STAGING_WP" ]; then
  log "❌ No se encontró $STAGING_WP"
  exit 1
fi

log "→ Creando backup de wp-config.php..."
cp "$STAGING_WP" "${STAGING_WP}.bak.$(date +%Y%m%d_%H%M%S)"

log "→ Actualizando credenciales en wp-config.php..."
sed -i "s/define('DB_NAME', '[^']*');/define('DB_NAME', '$STAGING_DB_NAME');/" "$STAGING_WP"
sed -i "s/define('DB_USER', '[^']*');/define('DB_USER', '$STAGING_DB_USER');/" "$STAGING_WP"
sed -i "s/define('DB_PASSWORD', '[^']*');/define('DB_PASSWORD', '$STAGING_DB_PASS');/" "$STAGING_WP"
sed -i "s/define('DB_HOST', '[^']*');/define('DB_HOST', '$STAGING_DB_HOST');/" "$STAGING_WP"

log "✓ wp-config.php actualizado"

log ""
log "═══════════════════════════════════════════════════════════"
log "  PASO 4: Actualizar URLs en la nueva base staging"
log "═══════════════════════════════════════════════════════════"

log "→ Cambiando URLs a staging.runartfoundry.com..."

mysql -u"$STAGING_DB_USER" -p"$STAGING_DB_PASS" -h"$STAGING_DB_HOST" "$STAGING_DB_NAME" <<EOF
UPDATE wp_options SET option_value='https://staging.runartfoundry.com' WHERE option_name IN ('siteurl','home');
EOF

log "✓ URLs actualizadas en staging"

log ""
log "═══════════════════════════════════════════════════════════"
log "  ✅ COMPLETADO"
log "═══════════════════════════════════════════════════════════"
log ""
log "Resumen:"
log "  ✓ Base staging creada: $STAGING_DB_NAME"
log "  ✓ Datos copiados desde producción"
log "  ✓ wp-config.php de staging actualizado"
log "  ✓ URLs configuradas para staging.runartfoundry.com"
log "  ✓ Dump guardado: $DUMP_FILE"
log ""
log "Próximo paso:"
log "  Ejecutar el script de reparación auto-detect:"
log "  ./tools/repair_autodetect_prod_staging.sh"
log ""
log "Verifica en navegador:"
log "  https://staging.runartfoundry.com"
log ""
