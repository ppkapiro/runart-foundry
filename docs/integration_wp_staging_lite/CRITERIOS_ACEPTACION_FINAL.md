# Criterios de Aceptación Final — WP Staging Lite (Fase E4)

Fecha: 2025-10-22

## Criterios funcionales
- [ ] Endpoint `GET /wp-json/briefing/v1/status` responde 200 con JSON válido.
  - Dado que existe `wp-content/mu-plugins/wp-staging-lite/status.json`, entonces su contenido se refleja en la respuesta (campos `general.ok`, `last_update`).
  - Si no existe el archivo, se devuelve un JSON mínimo de fallback sin errores.
- [ ] Endpoint `POST /wp-json/briefing/v1/trigger` devuelve 501 por defecto (deshabilitado), sin efectos colaterales.
- [ ] Shortcode `[briefing_hub]` renderiza el estado “OK” cuando `status.json` lo indica; soporta override de URL vía filtro.

## Criterios de integración CI
- [ ] Workflow `post_build_status.yml` genera `docs/status.json` tras las corridas target (simulado localmente).
- [ ] Workflow `receive_repository_dispatch.yml` registra un archivo de evidencia en `docs/ops/logs/` (
  `run_repository_dispatch_*.log`) al recibir un evento `repository_dispatch` (simulado localmente).

## Criterios de seguridad
- [ ] No existen secretos reales versionados (tokens/keys). Referencias a `Authorization` solo como ejemplo o variables.
- [ ] `/trigger` permanece deshabilitado; cualquier habilitación futura debe incluir `permission_callback` estricto (cap admin o firma HMAC/nonce) y control de logging.

## Criterios de reversibilidad
- [ ] Plan de rollback probado en seco: eliminación del loader y carpeta del MU‑plugin y retirada de workflows deja `/wp-json` sin `briefing/v1`.
- [ ] Evidencias y documentación permanecen accesibles (orquestador, tests y logs).

## Criterios de entrega
- [ ] Paquete ZIP está disponible: `_dist/wp-staging-lite_delivery_20251022T182542Z.zip`.
  - SHA256 coincide con el publicado: `fd75524f84fac4afff01283b5404344fa9a7b80495022cec8af50c59e5b39f6f`.
- [ ] Documentación clave presente: `ORQUESTADOR_DE_INTEGRACION.md`, `TESTS_*`, `REVIEW_SEGURIDAD.md`, `ROLLBACK_PLAN.md`, `PR_DRAFT.md`.

## Resultado esperado
Al cumplir todos los ítems, el PR puede aprobarse y proceder a una validación en entorno staging con `/trigger` deshabilitado por defecto.
