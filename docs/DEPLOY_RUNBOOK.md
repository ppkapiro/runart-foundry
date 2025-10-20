# Deploy Runbook — Verificaciones, Alertas e Intervención Rápida

## Verificaciones programadas
- Verify Home (`verify-home.yml`): cada 6h + manual. Comprueba settings `show_on_front/page_on_front` y front ES/EN (200).
- Verify Menus (`verify-menus.yml`): cada 12h + manual. Compara conteos con manifiesto y localizaciones.
- Verify Media (`verify-media.yml`): diario + manual. Verifica existencia por manifiesto y asignaciones featured (placeholder).
- Verify Settings (`verify-settings.yml`): cada 24h + manual. Valida timezone, permalink y start_of_week.

Cada verificación sube un artifact `*_summary.txt` y, si requiere atención, abre/actualiza un Issue por área. Al volver a OK, cierra el Issue.

## Alertas e Incidentes
- Etiquetas: `monitoring`, `incident`, y `area:<home|menus|media|settings>`.
- Título: `Alerta verificación <área> — <YYYY-MM-DD HH:MMZ>`.
- Cuerpo: resumen del job + checklist de acciones mínimas.

## Run Repair (plan/apply)
- `run-repair.yml` permite disparar la reparación por área (plan o apply). En apply intenta llamar al workflow homólogo:
  - home → set-home.yml
  - menus → publish-prod-menu.yml
  - media → upload-media.yml
  - settings → site-settings.yml

## Rotación y Limpieza
- Rotación de token: `rotate-app-password.yml` (manual, con validación `users/me`).
- Limpieza incremental: `cleanup-test-resources.yml` diario (placeholder; ajustar según entorno).

## Variables y secretos
- Definir `vars.WP_BASE_URL` y `secrets.WP_USER`/`WP_APP_PASSWORD` en el repo u organización.

## Notas
- Mantener logs mínimos; nunca exponer secretos.
- Si la API de menús/medios difiere por plugins, adaptar los endpoints en los workflows y documentar en el summary.
