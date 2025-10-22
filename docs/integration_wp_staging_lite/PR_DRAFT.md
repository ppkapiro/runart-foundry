# PR Draft — WP Staging Lite — Integración local (Fases B–E)

## Alcance
- MU-plugin `wp-staging-lite` con endpoints REST (`/status`, `/trigger` deshabilitado) y shortcode `[briefing_hub]`.
- Workflows de GitHub Actions:
  - `receive_repository_dispatch.yml` (wp_content_published, rebuild, sync_menus)
  - `post_build_status.yml` (genera docs/status.json post build)
- Validación local con scripts de simulación y evidencia en `docs/ops/logs/`.

Incluye cierre de Fase D (E2E local) y Fase E (seguridad, rollback y paquete de entrega).

## Evidencias
- Endpoints: `GET /wp-json/briefing/v1/status` → 200; `POST /wp-json/briefing/v1/trigger` → 501
- Shortcode (ruta técnica): `/?briefing_hub=1&status_url=http://localhost:10010/wp-json/briefing/v1/status` → render OK
- Workflows (simulados):
  - repo_dispatch → `docs/ops/logs/run_repository_dispatch_*.log`
  - post_build_status → `docs/status.json` y copia en `mu-plugins/wp-staging-lite/status.json`
- Detalle: `docs/integration_wp_staging_lite/TESTS_PLUGIN_LOCAL.md`, `TESTS_WORKFLOWS_LOCAL.md`
- E2E local: `docs/integration_wp_staging_lite/TESTS_E2E_LOCAL.md`

## Seguridad (E1)
- Revisión rápida repo-wide: sin secretos reales. `/trigger` deshabilitado (501). Workflows en modo dry-run.
- Documento: `docs/integration_wp_staging_lite/REVIEW_SEGURIDAD.md` (recomendaciones de hardening incluidas).

## Rollback (E2)
- Procedimiento documentado para retirar plugin y workflows con señales de éxito.
- Documento: `docs/integration_wp_staging_lite/ROLLBACK_PLAN.md`.

## Paquete de entrega (E3)
 - ZIP con: MU-plugin, 2 workflows, scripts de simulación/validación y documentación relevante.
 - Artefacto local: `_dist/wp-staging-lite_delivery_20251022T182542Z.zip` (≈25 KB)
   - SHA256: `fd75524f84fac4afff01283b5404344fa9a7b80495022cec8af50c59e5b39f6f`
 - Ruta del paquete para handoff: `docs/integration_wp_staging_lite/ENTREGA_RUNART/WP_Staging_Lite_RunArt_v1.0.zip`
## Resumen ejecutivo y criterios (E4)
- Resumen: `docs/integration_wp_staging_lite/EXECUTIVE_SUMMARY.md`
- Criterios de aceptación final: `docs/integration_wp_staging_lite/CRITERIOS_ACEPTACION_FINAL.md`

## Handoff (E5)
- Mensaje de handoff: `docs/integration_wp_staging_lite/HANDOFF_MESSAGE.md`
- Plan de pruebas en staging: `docs/integration_wp_staging_lite/ACCEPTANCE_TEST_PLAN_STAGING.md`
- TODO de staging: `docs/integration_wp_staging_lite/TODO_STAGING_TASKS.md`

 

## Checklist
- [x] Sin secrets reales
- [x] Reversión simple (eliminar workflows + plugin)
- [x] Documentación y evidencias listas

> Nota: Listo para revisión. Merge gated por aprobación del equipo y pruebas en entorno real (si aplica).

<!-- Actualizado tras completar Fases D y E -->
