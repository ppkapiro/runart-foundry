# Pruebas Locales — Workflows (Fase C)

Tabla de pruebas y evidencias para workflows locales.

| Fecha (UTC) | Evento | Método de disparo | Resultado | Evidencia |
|---|---|---|---|---|
| 2025-10-22T17:56:50Z | repository_dispatch/wp_content_published | scripts/simulate_repository_dispatch.sh | Log creado | docs/ops/logs/run_repository_dispatch_20251022T175650Z.log |
| 2025-10-22T17:56:50Z | post_build_status (simulado) | scripts/simulate_post_build_status.sh | status.json generado y copiado a sitio | docs/status.json; mu-plugins/wp-staging-lite/status.json |

## Verificación en WordPress local

- GET /wp-json/briefing/v1/status → HTTP 200, refleja last_update: 2025-10-22T17:56:50Z
- Shortcode `[briefing_hub]` (ruta técnica):
  - http://localhost:10010/?briefing_hub=1&status_url=http://localhost:10010/wp-json/briefing/v1/status
  - Render: “Estado general: OK” + lista de servicios

## Notas
- Sin despliegos reales ni pushes remotos. Placeholders mantenidos en workflows.
