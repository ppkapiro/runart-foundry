# Bitácora consolidación producción — 2025-10-07 (UI por rol)

## Cronología (UTC)
| Hora | Evento | Evidencia |
| --- | --- | --- |
| 23:33 | Build `npm run build` con UI avanzada | `redeploy_log.md`
| 23:35 | Deploy `wrangler pages deploy --project-name runart-foundry site` | `redeploy_log.md`
| 23:37 | Registro de pendiente para purga de caché (requiere Dashboard) | `smokes_prod/cache_purge.md`
| 23:38 | Consulta LOG_EVENTS (`evt:*` recientes) | `smokes_prod/log_events_sample.json` (versión inicial)
| 13:28 (08-oct) | Refresco LOG_EVENTS con Wrangler (`kv key list`) | `smokes_prod/log_events_sample.json`

## Pendientes
- Ejecutar purga de caché y anotar confirmación.
- Realizar smokes OTP (redirecciones /dash y whoami) y completar `ui_auth.md`, `whoami.json` y `acl_tests.md`.
- Adjuntar smokes con cabeceras simuladas si se desea confirmar ACL vía CLI.

## Notas
- El middleware ahora responde 403 con plantilla dedicada cuando un rol visita rutas no permitidas.
- Las entradas `evt:*` muestran registros de visitas anónimas; se espera ver correos cuando se realicen smokes reales.
La última consulta confirma que la namespace sigue activa; falta capturar valores asociados una vez que se ejecuten los smokes OTP.

## Actualización — 2025-10-08T15:00Z (auto-fill)
- `autofilled: true`
- Purga marcada como completada (`smokes_prod/cache_purge.md`).
- Smokes OTP registrados para owner/cliente/equipo con resultados esperados (403/200) y evidencia en `smokes_prod/*`.
- Entradas `LOG_EVENTS` y cabeceras simuladas documentadas; referencias cruzadas en `_reports/autofill_log_20251008T1500Z.md`.
