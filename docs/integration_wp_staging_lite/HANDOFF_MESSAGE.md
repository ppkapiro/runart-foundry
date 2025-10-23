# Handoff — WP Staging Lite · RunArt Foundry

Fecha: 2025-10-22

## Qué integra este PR (3 bullets)
- MU‑plugin `wp-staging-lite`: endpoint `GET /wp-json/briefing/v1/status`, `POST /trigger` deshabilitado (501) por defecto y shortcode `[briefing_hub]`.
- Workflows CI: `receive_repository_dispatch.yml` (evidencia de eventos) y `post_build_status.yml` (genera `docs/status.json`).
- Documentación completa: seguridad, rollback, orquestador, pruebas locales (plugin/workflows/E2E) y paquete ZIP de entrega.

## Qué debe hacer el equipo en staging real (6–8 bullets)
1. Copiar el MU‑plugin a `wp-content/mu-plugins/` (loader + carpeta `wp-staging-lite/`).
2. Añadir los workflows al repo (ajustar `NOMBRE_DEL_WORKFLOW_DE_BUILD` si aplica en `post_build_status.yml`).
3. Configurar secrets mínimos (ver `SECRETS_REFERENCE.md`).
4. Ejecutar el workflow de build y verificar que `docs/status.json` se genere/actualice correctamente.
5. Validar `GET /wp-json/briefing/v1/status` (HTTP 200, JSON válido con `last_update`).
6. Crear página “Hub” en WP con `[briefing_hub]` y validar render “Estado general: OK”.
7. Disparar `repository_dispatch` con tipo `wp_content_published` y verificar log en `docs/ops/logs/`.
8. (Opcional) Habilitar `POST /trigger` con token/permiso estricto (ver recomendaciones de `REVIEW_SEGURIDAD.md`).

## Criterios de aceptación (corto)
- [ ] `/status` → 200 (con `last_update`) y shortcode render OK.
- [ ] `post_build_status` genera `docs/status.json` (o artefacto equivalente) y WP lo refleja.
- [ ] `repository_dispatch` deja evidencia en `docs/ops/logs/`.
- [ ] `/trigger` permanece deshabilitado (501) salvo habilitación explícita y protegida.

## Contacto y soporte
- Soporte técnico: equipo RunArt Foundry (canal interno) 
- Documentos guía: `EXECUTIVE_SUMMARY.md`, `CRITERIOS_ACEPTACION_FINAL.md`, `ROLLBACK_PLAN.md`, `REVIEW_SEGURIDAD.md`.
