#!/usr/bin/env bash
# cache:purgar-paginas — OPCIONAL
# Invalida o purga caché de páginas conocidas si se detecta mezcla EN/ES servida por caché.
# No usa secretos ni proveedores externos; depende de que exista WP-CLI accesible en el entorno remoto/local.

set -euo pipefail

ROUTES=(
  "/" "/en/" "/es/"
  "/en/about/" "/es/about/"
  "/en/services/" "/es/services/"
  "/en/projects/" "/es/projects/"
  "/en/blog/" "/es/blog-2/"
  "/en/contact/" "/es/contacto/"
)

WP="wp"  # ajustar si se requiere ruta absoluta

if ! command -v "$WP" >/dev/null 2>&1; then
  echo "[WARN] WP-CLI no disponible en este entorno. Este script es una plantilla."
  echo "       Alternativa: Purga manual en plugin de caché o tocar URLs con ?v=now para bypass/warm."
  exit 0
fi

for r in "${ROUTES[@]}"; do
  echo "[cache] Purga de: $r"
  # Plugins comunes exponen comandos para purga; si no existen, fallback a cache flush general
  $WP cache flush || true
  # Warm-cache opcional
  curl -sS -o /dev/null -m 20 "${BASE_URL:-https://staging.runartfoundry.com}$r?v=$(date +%s)" || true
  sleep 0.3
done

echo "[cache] Finalizado"
