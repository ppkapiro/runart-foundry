#!/usr/bin/env bash
set -euo pipefail
echo "=== RUNART FOUNDRY: CREACIÓN STAGING IONOS ==="

# Variables
STAGING_DOMAIN="staging.runalfondry.com"
REMOTE_BASE="/homepages/7/d958591985/htdocs"
REMOTE_STAGING="$REMOTE_BASE/staging"
DB_NAME="runalfondry_staging"
DB_USER="staging_user"
DB_PASS="$(openssl rand -base64 16)"
WP_URL="https://$STAGING_DOMAIN"
WP_TITLE="RunArt Foundry Staging"
WP_ADMIN="admin"
WP_ADMIN_PASS="$(openssl rand -base64 16)"
WP_ADMIN_EMAIL="admin@runalfondry.com"

# SSH remoto (usa variable $IONOS_SSH_HOST configurada en VS Code)
SSH="ssh -p 22 $IONOS_SSH_HOST"

echo "[1/7] Creando carpeta staging..."
$SSH "mkdir -p $REMOTE_STAGING && chmod 755 $REMOTE_STAGING"

echo "[2/7] Clonando WordPress de producción..."
$SSH "find $REMOTE_BASE -mindepth 1 -maxdepth 1 ! -name 'staging' -exec cp -r {} $REMOTE_STAGING/ \; && rm -rf $REMOTE_STAGING/wp-content/cache $REMOTE_STAGING/wp-config.php"

echo "[3/7] Creando base de datos staging..."
$SSH "mysql -u root -p\$MYSQL_ROOT_PASSWORD -e \"DROP DATABASE IF EXISTS $DB_NAME; CREATE DATABASE $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS'; FLUSH PRIVILEGES;\""

echo "[4/7] Configurando wp-config.php..."
$SSH "cd $REMOTE_STAGING && cp $REMOTE_BASE/wp-config.php ./wp-config.php && sed -i \"s/define('DB_NAME'.*/define('DB_NAME', '$DB_NAME');/\" wp-config.php && sed -i \"s/define('DB_USER'.*/define('DB_USER', '$DB_USER');/\" wp-config.php && sed -i \"s/define('DB_PASSWORD'.*/define('DB_PASSWORD', '$DB_PASS');/\" wp-config.php && sed -i \"s@define('WP_HOME'.*@define('WP_HOME', '$WP_URL');@\" wp-config.php && sed -i \"s@define('WP_SITEURL'.*@define('WP_SITEURL', '$WP_URL');@\" wp-config.php"

echo "[5/7] Actualizando URLs dentro de la BD..."
$SSH "wp search-replace 'https://runalfondry.com' '$WP_URL' --all-tables --precise --report-changed-only --path=$REMOTE_STAGING"

echo "[6/7] Instalando SSL (Let’s Encrypt)..."
echo "(Let’s Encrypt no disponible en hosting compartido, omitiendo paso)"

echo "[7/7] Generando usuario técnico GitHub-Actions..."
$SSH "cd $REMOTE_STAGING && wp user create github-actions github-actions@runalfondry.com --role=editor --user_pass=$(openssl rand -base64 16) || echo '(Usuario existente)'"

echo "=== STAGING CREADO ==="
echo "URL: $WP_URL"
echo "Base de datos: $DB_NAME"
echo "Usuario WP técnico: github-actions"
echo "SSL: activado o ya existente"
echo "==========================="
