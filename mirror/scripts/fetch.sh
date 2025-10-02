#!/usr/bin/env bash
# fetch.sh - Plantilla para capturar snapshots del sitio del cliente
# 
# ⚠️ ESTE SCRIPT ES UNA PLANTILLA COMENTADA - NO EJECUTAR DIRECTAMENTE
# 
# Propósito: Documentar el proceso de captura de snapshots para:
#   1. Base de datos (mysqldump vía SSH)
#   2. Contenido estático (wget --mirror)
#   3. wp-content (rsync/sftp)
#
# Uso:
#   1. Descomentar las secciones necesarias
#   2. Configurar variables de entorno (.env)
#   3. Ejecutar manualmente: ./mirror/scripts/fetch.sh
#
# Requisitos:
#   - Acceso SSH/SFTP al servidor del cliente
#   - Credenciales en .env (NO subir a Git)
#   - Tools: ssh, rsync, wget, mysql

set -e

# ═══════════════════════════════════════════════════════════
# CONFIGURACIÓN
# ═══════════════════════════════════════════════════════════

# Fecha de captura (ISO 8601)
SNAPSHOT_DATE=$(date +%Y-%m-%d)
SNAPSHOT_TIME=$(date +%Y-%m-%dT%H:%M:%SZ)

# Directorios
MIRROR_DIR="mirror/raw/${SNAPSHOT_DATE}"
mkdir -p "${MIRROR_DIR}"

# Variables de entorno (configurar en .env)
# DB_HOST="localhost"
# DB_NAME="wordpress"
# DB_USER="wp_user"
# DB_PASS="secure_password"
# SSH_HOST="example.com"
# SSH_USER="webuser"
# SSH_PORT="22"
# REMOTE_WP_PATH="/var/www/html"
# SITE_URL="https://example.com"

# ═══════════════════════════════════════════════════════════
# PASO 1: CAPTURAR BASE DE DATOS
# ═══════════════════════════════════════════════════════════

# echo "📦 [1/3] Capturing database..."

# Opción A: Dump directo (si tienes acceso MySQL remoto)
# mysqldump -h "${DB_HOST}" -u "${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" \
#   --single-transaction \
#   --quick \
#   --lock-tables=false \
#   > "${MIRROR_DIR}/db_dump.sql"

# Opción B: Dump vía SSH (más común)
# ssh -p "${SSH_PORT}" "${SSH_USER}@${SSH_HOST}" \
#   "mysqldump -u ${DB_USER} -p'${DB_PASS}' ${DB_NAME} --single-transaction" \
#   > "${MIRROR_DIR}/db_dump.sql"

# Comprimir si es grande (>10 MB)
# if [ -f "${MIRROR_DIR}/db_dump.sql" ]; then
#   SIZE=$(stat -c%s "${MIRROR_DIR}/db_dump.sql" 2>/dev/null || stat -f%z "${MIRROR_DIR}/db_dump.sql")
#   if [ $SIZE -gt 10485760 ]; then
#     echo "   Compressing database dump..."
#     gzip "${MIRROR_DIR}/db_dump.sql"
#   fi
# fi

# ═══════════════════════════════════════════════════════════
# PASO 2: CAPTURAR CONTENIDO ESTÁTICO (HTML)
# ═══════════════════════════════════════════════════════════

# echo "🌐 [2/3] Mirroring static site..."

# wget \
#   --mirror \
#   --page-requisites \
#   --no-parent \
#   --convert-links \
#   --adjust-extension \
#   --no-check-certificate \
#   --reject="*.zip,*.tar.gz,*.pdf" \
#   --directory-prefix="${MIRROR_DIR}/site_static" \
#   "${SITE_URL}"

# ═══════════════════════════════════════════════════════════
# PASO 3: CAPTURAR wp-content (SFTP/rsync)
# ═══════════════════════════════════════════════════════════

# echo "📂 [3/3] Syncing wp-content..."

# Opción A: rsync vía SSH (recomendado, incremental)
# rsync -avz \
#   --progress \
#   --exclude='cache/*' \
#   --exclude='backup*' \
#   --exclude='*.log' \
#   -e "ssh -p ${SSH_PORT}" \
#   "${SSH_USER}@${SSH_HOST}:${REMOTE_WP_PATH}/wp-content/" \
#   "${MIRROR_DIR}/wp-content/"

# Opción B: SFTP (si rsync no está disponible)
# sftp -P "${SSH_PORT}" "${SSH_USER}@${SSH_HOST}" <<EOF
# cd ${REMOTE_WP_PATH}
# lcd ${MIRROR_DIR}
# get -r wp-content
# bye
# EOF

# ═══════════════════════════════════════════════════════════
# PASO 4: ACTUALIZAR index.json
# ═══════════════════════════════════════════════════════════

# echo "📝 Updating index.json..."

# Calcular tamaños
# DB_SIZE=$(stat -c%s "${MIRROR_DIR}/db_dump.sql"* 2>/dev/null || echo 0)
# STATIC_SIZE=$(du -sb "${MIRROR_DIR}/site_static" | cut -f1)
# WP_SIZE=$(du -sb "${MIRROR_DIR}/wp-content" | cut -f1)
# TOTAL_SIZE=$((DB_SIZE + STATIC_SIZE + WP_SIZE))

# Actualizar index.json (manualmente o con jq)
# jq ".snapshots += [{
#   \"id\": \"${SNAPSHOT_DATE}\",
#   \"captured_at\": \"${SNAPSHOT_TIME}\",
#   \"method\": \"ssh + wget + rsync\",
#   \"size_bytes\": ${TOTAL_SIZE},
#   \"components\": {
#     \"database\": {\"size_bytes\": ${DB_SIZE}},
#     \"static_site\": {\"size_bytes\": ${STATIC_SIZE}},
#     \"wp_content\": {\"size_bytes\": ${WP_SIZE}}
#   },
#   \"external_location\": {
#     \"provider\": \"local\",
#     \"access_instructions\": \"mirror/raw/${SNAPSHOT_DATE}/ (gitignored)\"
#   }
# }]" mirror/index.json > mirror/index.json.tmp
# mv mirror/index.json.tmp mirror/index.json

# ═══════════════════════════════════════════════════════════
# PASO 5: CHECKSUM Y VERIFICACIÓN
# ═══════════════════════════════════════════════════════════

# echo "🔐 Calculating checksums..."

# sha256sum "${MIRROR_DIR}/db_dump.sql"* > "${MIRROR_DIR}/checksums.txt"
# find "${MIRROR_DIR}/wp-content" -type f -exec sha256sum {} \; >> "${MIRROR_DIR}/checksums.txt"

# ═══════════════════════════════════════════════════════════
# RESUMEN
# ═══════════════════════════════════════════════════════════

# echo ""
# echo "✅ Snapshot captured successfully!"
# echo "   Date: ${SNAPSHOT_DATE}"
# echo "   Location: ${MIRROR_DIR}"
# echo "   Total size: $(du -sh ${MIRROR_DIR} | cut -f1)"
# echo ""
# echo "📋 Next steps:"
# echo "   1. Review captured files in ${MIRROR_DIR}"
# echo "   2. Update mirror/index.json with metadata"
# echo "   3. Upload to external storage if size > 100 MB"
# echo "   4. Commit only index.json to Git (NOT raw files)"
# echo ""

# ═══════════════════════════════════════════════════════════
# NOTAS
# ═══════════════════════════════════════════════════════════

# - Este script es una PLANTILLA. Descomenta y ajusta según necesidad.
# - NUNCA hardcodear credenciales. Usar .env (gitignored).
# - Los datos en mirror/raw/ están en .gitignore.
# - Para automatizar, considerar un cron job o GitHub Actions con secrets.
# - Limitar retención: borrar snapshots antiguos >30 días localmente.

echo "ℹ️  This is a TEMPLATE script. Uncomment and configure before use."
echo "📖 See mirror/README.md for instructions."
exit 0
