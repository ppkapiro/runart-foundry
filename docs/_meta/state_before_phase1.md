# Estado del repositorio antes de Fase 1 (modelo 3 capas)

Fecha de captura: 2025-10-23T14:08:27-04:00
Rama activa: main

Este documento captura el estado actual de la documentación antes de crear la nueva estructura de carpetas (live / archive / _meta). No se ha movido ni modificado ningún archivo existente; solo se registran observaciones.

## Resumen de la carpeta `docs/`

Subcarpetas principales detectadas:
- `adr/`
- `architecture/`
- `auditoria/`
- `ci/`
- `i18n/`
- `integration_wp_staging_lite/`
- `internal/`
- `ops/`
- `seo/`
- `seo_preparado/`
- `ui_roles/`
- `ux/`
- `_artifacts/` (artefactos auxiliares)

Archivos relevantes en `docs/` (muestra):
- `README.md`
- `DEPLOY_RUNBOOK.md`
- `DEPLOY_PROD_CHECKLIST.md`
- `CHECKLIST_EJECUTIVA_FASE7.md`
- `PR_INTEGRATION_FINAL.md`
- `HANDOFF_FASE10.md`
- `FASE7_INDEX_20251020.md`
- `FLOWCHART_FASE7.md`
- `cloudflare_repo_fs_overview.md`
- `theme_migration_plan.md`

Número de archivos Markdown detectados dentro de `docs/`: 596

Archivo clave localizado (bitácora):
- `docs/ui_roles/BITACORA_INVESTIGACION_BRIEFING_V2.md`

## Archivos destacados a nivel repositorio (raíz)
- `README.md`
- `STATUS.md`
- `NEXT_PHASE.md`
- `CHANGELOG.md`

## Observaciones sobre duplicados o placeholders
- Se observan múltiples documentos versionados por fecha (p. ej., `*_2025-10-**.md`) y reportes por fases. No se detectan duplicados exactos por nombre en la muestra revisada, pero existen variantes por fecha/versión que deberán consolidarse en fases posteriores.
- Existen plantillas y README de referencia que actúan como placeholders para flujos/pipelines y documentación operativa.

## Nota metodológica
- Este diagnóstico se genera "antes" de introducir la nueva estructura. Su ubicación en `docs/_meta/` es solo para mantener el registro trazable dentro del repositorio.
- Próximas fases realizarán la migración lógica (clasificación a `live/` y `archive/`) sin pérdida de histórico.
