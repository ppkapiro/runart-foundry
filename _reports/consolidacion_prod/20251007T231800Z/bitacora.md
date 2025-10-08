# Bitácora consolidación producción — 2025-10-07 (segunda corrida)

## Resumen
- Objetivo: publicar dashboards por rol, intentar purga de caché y preparar smokes.
- Resultado: deploy exitoso, purga pendiente de ejecución manual, smokes autenticados no realizados por falta de OTP/conectividad, evidencia KV obtenida.

## Cronología (UTC)
| Hora | Acción | Evidencia |
| --- | --- | --- |
| 23:16 | Build local `npm run build` | `redeploy_log.md`
| 23:18 | Deploy `wrangler pages deploy --project-name runart-foundry site` | `redeploy_log.md`
| 23:20 | Registro de pendiente para purga de caché (requiere Dashboard/UI) | `smokes_prod/cache_purge.md`
| 23:21 | Intento de smokes CLI (sin DNS) | `smokes_prod/simulated_headers.md`, `smokes_prod/whoami.json`
| 23:23 | Consulta de LOG_EVENTS vía Wrangler | `smokes_prod/log_events_sample.json`

## Pendientes críticos
- Ejecutar purga de caché vía Dashboard/API y adjuntar confirmación.
- Realizar smokes autenticados con OTP y capturar evidencias (`ui_auth.md`, `whoami.json`).

## Observaciones
- El entorno automatizado carece de resolución DNS externa; repetir smokes desde equipo con salida a Internet.
- LOG_EVENTS muestra datos históricos; esperar nuevas entradas `visit` tras primeras sesiones reales.
