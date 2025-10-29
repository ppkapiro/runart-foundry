# Revisión de Seguridad — WP Staging Lite (Fase E1)

Fecha: 2025-10-22

## Alcance

- MU-plugin `wp-staging-lite` (REST `/status` y `/trigger` deshabilitado por defecto, shortcode `[briefing_hub]`).
- Workflows locales: `receive_repository_dispatch.yml` y `post_build_status.yml` (plantillas de prueba sin llamadas externas activas por defecto).
- Scripts de simulación y validación local.

## Hallazgos (rápido, repo-wide)

- Escaneo de patrones sensibles (claves/Tokens/privkeys): sin coincidencias reales. Solo referencias documentales y variables de entorno en scripts (p.ej. `${CLOUDFLARE_API_TOKEN}`) — OK.
- Headers `Authorization:` aparecen en:
  - Documentación interna (ejemplos, no secretos reales).
  - Scripts `tools/repair_*` y `staging_isolation_audit.sh` usan variables de entorno — esperado.
  - Filtro de redacción ya presente en `tools/fase7_collect_evidence.sh` (redacta `Authorization:`) — OK.
- Endpoint `/briefing/v1/trigger` responde `501` por defecto — confirmado.

### Evidencias

- Trigger (local): `POST /wp-json/briefing/v1/trigger` → HTTP 501, payload con mensaje “Trigger deshabilitado…”.
- Status (local): `GET /wp-json/briefing/v1/status` → HTTP 200, datos desde `status.json` si existe, fallback JSON mínimo — OK.

## Evaluación de workflows

- `receive_repository_dispatch.yml` — solo registra payload en evidencia (`docs/ops/logs/`). No contiene secretos codificados. Uso de `GITHUB_TOKEN` implícito estándar.
- `post_build_status.yml` — genera `docs/status.json` y (opcional) sube artefacto. Sin llamadas a APIs externas; no usa secretos.

Estado: ambos workflows son plantillas de validación local seguras por defecto.

## Recomendaciones para producción

1. MU-plugin
   - Mantener `/trigger` deshabilitado salvo que se proteja con un `permission_callback` estricto (capabilities de admin o firma HMAC). Añadir nonce si se expone en UI.
   - Registrar errores con `error_log` solo en entornos de desarrollo; en producción usar un logger que omita datos sensibles.
   - Asegurar que `status.json` no contenga secretos; mantenerlo con información operativa mínima.

2. Workflows
   - Cualquier token de GitHub/Cloudflare: definir exclusivamente vía `Secrets` del repositorio/org. Nunca commitear valores.
   - Añadir paso de redacción de logs cuando se impriman cabeceras (`Authorization`, `x-api-key`, etc.).
   - Limitar triggers a ramas específicas (`branches:`) para evitar ejecuciones no deseadas.

3. Evidencias/Registros
   - Conservar el filtro de redacción de `tools/fase7_collect_evidence.sh` y aplicarlo a carpetas de logs antes de archivar.
   - Evitar incluir dumps de cabeceras completas en documentación pública.

## Checklist (Fase E1)

- [x] Sin secretos reales en el repo.
- [x] `/trigger` deshabilitado (HTTP 501).
- [x] Workflows en modo seguro/dry-run.
- [x] Recomendaciones de endurecimiento listadas.

Resultado: PASS (apto para empaquetado y PR Draft con notas de seguridad).
