# PR Draft — WP Staging Lite — Integración local (Fases B & C)

## Alcance
- MU-plugin `wp-staging-lite` con endpoints REST (`/status`, `/trigger` deshabilitado) y shortcode `[briefing_hub]`.
- Workflows de GitHub Actions:
  - `receive_repository_dispatch.yml` (wp_content_published, rebuild, sync_menus)
  - `post_build_status.yml` (genera docs/status.json post build)
- Validación local con scripts de simulación y evidencia en `docs/ops/logs/`.

## Evidencias
- Endpoints: `GET /wp-json/briefing/v1/status` → 200; `POST /wp-json/briefing/v1/trigger` → 501
- Shortcode (ruta técnica): `/?briefing_hub=1&status_url=http://localhost:10010/wp-json/briefing/v1/status` → render OK
- Workflows (simulados):
  - repo_dispatch → `docs/ops/logs/run_repository_dispatch_*.log`
  - post_build_status → `docs/status.json` y copia en `mu-plugins/wp-staging-lite/status.json`
- Detalle: `docs/integration_wp_staging_lite/TESTS_PLUGIN_LOCAL.md`, `TESTS_WORKFLOWS_LOCAL.md`

## Checklist
- [x] Sin secrets reales
- [x] Reversión simple (eliminar workflows + plugin)
- [x] Documentación y evidencias listas

> Nota: Mantener como “Draft” hasta completar Fase D.
