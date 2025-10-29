# Normalización de Referencias de Tema — 2025-10-29

Objetivo: Alinear documentación y scripts al canon “RunArt Base” (runart-base) en modo solo lectura, sin tocar el servidor.

## Alcance

- Documentación y reportes: actualizar referencias y fijar canon.
- Scripts locales: forzar THEME_SLUG=runart-base y congelar despliegues (READ_ONLY=1, DRY_RUN=1).
- CI: añadir guardas para evitar deployments accidentales y exigir etiqueta para cambios de media.

## Cambios realizados (archivos y motivo)

1) tools/staging_env_loader.sh
- Forzado THEME_SLUG="runart-base" (canon) y export de THEME_PATH.
- Defaults READ_ONLY=1; SKIP_SSH soportado para CI/documentación.
- Guía actualizada con ruta canónica de WP y tema.

2) tools/deploy_wp_ssh.sh
- CI-GUARD: DRY-RUN-CAPABLE añadido.
- Defaults READ_ONLY=1 y DRY_RUN=1.
- rsync añade automáticamente `--dry-run` si READ_ONLY/DRY_RUN están activos.
- Operaciones de cambio (backup, rewrite/cache/publish) se omiten con READ_ONLY=1.
- Resumen incluye flags READ_ONLY/DRY_RUN.

3) _reports/IONOS_STAGING_THEME_CHECK_20251029.md
- Reorientado a canon RunArt Base, conservando evidencia actual del child.
- Añadidas rutas canónicas y verificaciones para `runart-base`.

4) docs/Deployment_Master.md
- Nota breve de gobernanza del tema en Staging (canon, solo lectura y enlace a reporte).

5) .github/workflows/guard-deploy-readonly.yml (nuevo)
- dryrun-guard: valida defaults READ_ONLY/DRY_RUN y marcador CI-GUARD en el deploy script.
- media-guard: exige etiqueta `media-review` cuando el PR toca `wp-content/uploads/`, `runmedia/` o `content/media/`.

## Estado

- Canon fijado: `runart-base`.
- Modo operación: Solo lectura (no despliegues efectivos) hasta aprobación.
- CI actualizado: guardas activas en PRs (main/develop).

## Próximos pasos (no ejecutados)

- (Opcional) Añadir una guía rápida “Cambio de Child→Base” para alinear el activo en ventana de mantenimiento (requiere SSH y aprobación).
- Validar CI en PR de documentación (esperado: checks en verde).
