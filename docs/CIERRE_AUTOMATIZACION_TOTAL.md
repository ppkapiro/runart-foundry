# Cierre Automatización Total — Verificación Integral + Alertas (v0.5.1)

Fecha de activación: 2025-10-20 (UTC)

## Workflows de verificación
- `.github/workflows/verify-home.yml` — cada 6h + manual
- `.github/workflows/verify-menus.yml` — cada 12h + manual
- `.github/workflows/verify-media.yml` — diario + manual
- `.github/workflows/verify-settings.yml` — cada 24h + manual

Todos generan un resumen compacto como artifact y crean/actualizan un único Issue por área cuando se requiere atención; los Issues se cierran automáticamente al volver a OK.

## Run Repair
- `.github/workflows/run-repair.yml` — manual con inputs `area` y `mode={plan,apply}`. En `apply` invoca el workflow homólogo si existe y sube un resumen con el enlace del run.

## Mantenimiento
- `.github/workflows/rotate-app-password.yml` — rotación manual del Application Password; valida `/wp-json/wp/v2/users/me` y sube resumen.
- `.github/workflows/cleanup-test-resources.yml` — limpieza diaria incrementada (placeholder); sube resumen.

## Variables y secretos
- `vars.WP_BASE_URL` — URL base del WP (sin slash final).
- `secrets.WP_USER`, `secrets.WP_APP_PASSWORD` — credenciales. No se exponen en logs.

## Notas
- Logs mínimos, sin HTML ni payloads; solo status/campos clave/conteos.
- Fallo de job únicamente cuando hay HTTP inesperado o drift/invariante rota.
- Control de drift por hash añadido en menús/medios (si el manifiesto existe).