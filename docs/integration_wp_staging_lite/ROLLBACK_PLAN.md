# Plan de Rollback — WP Staging Lite (Fase E2)

Fecha: 2025-10-22

## Objetivo
Revertir de forma rápida y segura la integración de WP Staging Lite (plugin + workflows) dejando el sistema en el estado previo, con señales claras de éxito.

## Alcance del rollback
- MU-plugin `wp-staging-lite` (loader raíz y carpeta del subplugin).
- Workflows: `receive_repository_dispatch.yml` y `post_build_status.yml`.
- Artefactos auxiliares: `status.json` dentro del plugin, si existe.

## Pasos (orden recomendado)

1) Desactivar/eliminar MU-plugin
- Eliminar archivo loader en `wp-content/mu-plugins/wp-staging-lite.php`.
- Eliminar carpeta `wp-content/mu-plugins/wp-staging-lite/`.
- (Opcional) Ajustes WP → Enlaces Permanentes → Guardar (flush de reglas).
- Señal de éxito: `GET /wp-json/briefing/v1/status` → 404/`route_not_found`.

2) Retirar workflows
- Opción A (temporal): comentar la clave `on:` en los YAML para desactivar triggers.
- Opción B (definitiva): eliminar `.github/workflows/receive_repository_dispatch.yml` y `post_build_status.yml`.
- Señal de éxito: no se generan nuevos logs en `docs/ops/logs/` por eventos de CI.

3) Limpiar artefactos
- Eliminar `wp-content/mu-plugins/wp-staging-lite/status.json` (si fue copiado por pruebas).
- (Opcional) Eliminar `docs/status.json` si no se requiere como evidencia histórica.

4) Revertir rama o cambios Git
- Si la integración está en una rama: cerrar PR y eliminar rama `feature/wp-staging-lite-integration`.
- Si fue mergeada: usar `git revert` sobre los commits de integración (consolidar en un revert único si es posible).
- Señal de éxito: `git log` sin cambios activos de la integración; CI estable.

## Verificaciones post-rollback
- `/wp-json` responde sin el namespace `briefing/v1`.
- Páginas con `[briefing_hub]` muestran mensaje de shortcode no reconocido (o se retiran). 
- Workflows afectados dejan de ejecutar.
- No existen llamadas ni logs residuales del sistema de integración.

## Notas y riesgos
- Caché/OPcache: en entornos con caché agresiva, puede requerirse invalidación o reinicio de PHP-FPM.
- Evidencias: preservar `docs/integration_wp_staging_lite/TESTS_*` y `docs/ops/logs/` en caso de auditorías.
- Permisos: si se habilitó `/trigger` en algún entorno, asegurarse de dejarlo deshabilitado antes de retirar el plugin.

## Tiempo estimado
10–20 minutos (dependiendo del acceso al servidor WP y del repositorio CI).
