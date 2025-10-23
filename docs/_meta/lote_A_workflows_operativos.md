---
generated_by: copilot
phase: post_revision_v2
date: 2025-10-23T14:31:24-04:00
repo: runart-foundry
branch: main
---

# Lote A — Workflows operativos (.github/workflows)

Listado y propósito de alto nivel (derivado del nombre del archivo):

- .github/workflows/audit-and-remediate.yml — Auditoría y remediación automatizada.
- .github/workflows/auto-merge-on-label.yml — Auto-merge según etiqueta.
- .github/workflows/auto-open-pr-on-deploy-branches.yml — Abrir PRs en ramas de despliegue.
- .github/workflows/auto_translate_content.yml — Traducción automática de contenido.
- .github/workflows/briefing_deploy.yml — Despliegue del micrositio Briefing.
- .github/workflows/build-wpcli-bridge.yml — Build del bridge WP-CLI.
- .github/workflows/change-password.yml — Cambio/rotación de contraseñas.
- .github/workflows/ci.yml — Integración continua general.
- .github/workflows/cleanup-test-resources.yml — Limpieza de recursos de prueba.
- .github/workflows/debug-auth.yml — Diagnóstico de autenticación.
- .github/workflows/docs-lint.yml — Lint y validación de documentación.
- .github/workflows/env-report.yml — Reporte de entorno.
- .github/workflows/grant-admin-access.yml — Conceder acceso admin (controlado).
- .github/workflows/healthcheck.yml — Chequeos de salud.
- .github/workflows/install-wpcli-bridge.yml — Instalación del bridge WP-CLI.
- .github/workflows/overlay-deploy.yml — Despliegue de overlays.
- .github/workflows/pages-deploy.yml — Deploy de Pages.
- .github/workflows/pages-preview-guard.yml — Guardia/protección de previews de Pages.
- .github/workflows/pages-preview.yml — Previsualización de Pages.
- .github/workflows/pages-preview2.yml — Variante de previsualización de Pages.
- .github/workflows/pages-prod.yml — Deploy de Pages a producción.
- .github/workflows/post_build_status.yml — Publicar estado tras build.
- .github/workflows/publish-mvp-rest.yml — Publicar MVP (REST).
- .github/workflows/receive_repository_dispatch.yml — Gestión de repository_dispatch.
- .github/workflows/release-template.yml — Plantilla de release.
- .github/workflows/rotate-app-password.yml — Rotar App Password.
- .github/workflows/rotate-reminder.yml — Recordatorio de rotaciones.
- .github/workflows/run-repair.yml — Reparaciones automatizadas.
- .github/workflows/run_canary_diagnostics.yml — Diagnósticos canarios.
- .github/workflows/run_canary_smokes.yml — Smokes canarios.
- .github/workflows/smoke-tests.yml — Smoke tests.
- .github/workflows/staging-cleanup-1761167538.yml — Limpieza de recursos en staging.
- .github/workflows/status-update.yml — Actualización de status.
- .github/workflows/structure-guard.yml — Guardia de estructura y gobernanza.
- .github/workflows/sync_status.yml — Sincronización de estado.
- .github/workflows/verify-home.yml — Verificación de home.
- .github/workflows/verify-media.yml — Verificación de media.
- .github/workflows/verify-menus.yml — Verificación de menús.
- .github/workflows/verify-settings.yml — Verificación de ajustes.
- .github/workflows/verify-staging.yml — Verificación de staging.
- .github/workflows/weekly-health-report.yml — Reporte semanal de salud.
- .github/workflows/wpcli-bridge-maintenance.yml — Mantenimiento del bridge WP-CLI.
- .github/workflows/wpcli-bridge-rewrite-maintenance.yml — Mantenimiento de reescrituras en bridge WP-CLI.
- .github/workflows/wpcli-bridge.yml — Workflow principal de bridge WP-CLI.

## Convenciones sugeridas
- Naming consistente por dominio (docs-, pages-, verify-, rotate-, run-...).
- Encabezado con propósito, inputs y owners en cada workflow (comentarios YAML).
- Etiquetas de auditoría (p. ej., `audited: true`, `owner:`) y anotaciones de contacto.
