# WP Staging Lite — Integración local validada (Fases B–E)

## Alcance
- MU‑plugin (status + shortcode Hub): `wp-staging-lite` con `GET /wp-json/briefing/v1/status` y `POST /trigger` (deshabilitado por defecto, 501).
- Workflows: `receive_repository_dispatch.yml` (evidencias) y `post_build_status.yml` (genera `docs/status.json`).
- Pruebas locales B–D y cierre E: seguridad, rollback y paquete de entrega.

## Enlaces
- Orquestador: `docs/integration_wp_staging_lite/ORQUESTADOR_DE_INTEGRACION.md`
- Resumen ejecutivo: `docs/integration_wp_staging_lite/EXECUTIVE_SUMMARY.md`
- Criterios de aceptación: `docs/integration_wp_staging_lite/CRITERIOS_ACEPTACION_FINAL.md`
- Plan de rollback: `docs/integration_wp_staging_lite/ROLLBACK_PLAN.md`
- Revisión de seguridad: `docs/integration_wp_staging_lite/REVIEW_SEGURIDAD.md`
- Paquete ZIP (handoff): `docs/integration_wp_staging_lite/ENTREGA_RUNART/WP_Staging_Lite_RunArt_v1.0.zip`
- Evidencias: `docs/integration_wp_staging_lite/TESTS_PLUGIN_LOCAL.md`, `TESTS_WORKFLOWS_LOCAL.md`, `TESTS_E2E_LOCAL.md` y logs en `docs/ops/logs/`
- Handoff: `docs/integration_wp_staging_lite/HANDOFF_MESSAGE.md`
- Acceptance test plan (staging): `docs/integration_wp_staging_lite/ACCEPTANCE_TEST_PLAN_STAGING.md`
- TODO staging tasks: `docs/integration_wp_staging_lite/TODO_STAGING_TASKS.md`

## Checklist PR
- [ ] Sin secrets reales
- [ ] Trigger POST deshabilitado por defecto
- [ ] Rollback validado
- [ ] Listo para pruebas en staging real

> Nota: No mergear hasta coordinar ventana de pruebas con el equipo.