#!/bin/bash
# Script de prueba básico para Lighthouse en WSL

set -euo pipefail

# Variables
RUN_DATE="$(date +%F)"
BASE_DIR="$PWD"
SNAP_ROOT="$BASE_DIR/mirror/raw/${RUN_DATE}"
SITE_DIR="${SNAP_ROOT}/site_static"
AUDITS_DIR="$BASE_DIR/audits"
LH_DIR="${AUDITS_DIR}/lighthouse"

mkdir -p "$LH_DIR"

echo "[INFO] Verificando estructura..."
echo "SITE_DIR: $SITE_DIR"
test -d "$SITE_DIR" || { echo "[ERROR] No existe ${SITE_DIR}"; exit 1; }

# Verificar que tenemos las herramientas necesarias
cd "$BASE_DIR/.tools"
export PATH="$BASE_DIR/.tools/node_modules/.bin:$PATH"

# Iniciar servidor HTTP simple en background
cd "$SITE_DIR"
echo "[INFO] Iniciando servidor HTTP en puerto 8080..."
python3 -m http.server 8080 &
SERVER_PID=$!
echo "$SERVER_PID" > "$AUDITS_DIR/http_server_${RUN_DATE}.pid"
sleep 3

# Verificar que el servidor está funcionando
curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8080/ || echo "Error al conectar al servidor local"

echo "[INFO] Ejecutando Lighthouse básico..."
cd "$BASE_DIR"

# Ejecutar Lighthouse con puppeteer
CHROME_PATH="$BASE_DIR/.tools/node_modules/puppeteer/.local-chromium/linux-*/chrome-linux/chrome"
CHROME_EXECUTABLE=$(ls $CHROME_PATH 2>/dev/null | head -n1)

if [ -n "$CHROME_EXECUTABLE" ]; then
  echo "[INFO] Usando Chrome de Puppeteer: $CHROME_EXECUTABLE"
  npx lighthouse http://127.0.0.1:8080/ \
    --chrome-flags="--headless --no-sandbox --disable-gpu --disable-dev-shm-usage --disable-web-security" \
    --chrome-path="$CHROME_EXECUTABLE" \
    --quiet --max-wait-for-load=30000 \
    --only-categories=performance \
    --output=html \
    --output-path="$LH_DIR/${RUN_DATE}_lighthouse_test.html"
else
  echo "[WARN] No se encontró Chrome de Puppeteer, usando Chrome del sistema"
  npx lighthouse http://127.0.0.1:8080/ \
    --chrome-flags="--headless --no-sandbox --disable-gpu --disable-dev-shm-usage --disable-web-security" \
    --quiet --max-wait-for-load=30000 \
    --only-categories=performance \
    --output=html \
    --output-path="$LH_DIR/${RUN_DATE}_lighthouse_test.html"
fi

echo "[INFO] Apagando servidor..."
kill $SERVER_PID || true

echo "[INFO] Prueba completada. Reporte en: $LH_DIR/${RUN_DATE}_lighthouse_test.html"