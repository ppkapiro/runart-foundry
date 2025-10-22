# Acceptance Test Plan — Staging Real (WP Staging Lite)

Fecha: 2025-10-22

## Preparación
- Instalar MU‑plugin en `wp-content/mu-plugins/` (loader + carpeta del plugin).
- Copiar workflows `receive_repository_dispatch.yml` y `post_build_status.yml`.
- Configurar secrets requeridos por los workflows si aplica (ver `SECRETS_REFERENCE.md`).

## Pruebas
1) Endpoints básicos
- [ ] `GET /wp-json/` responde 200
- [ ] `GET /wp-json/briefing/v1/status` responde 200 con JSON válido
- [ ] `POST /wp-json/briefing/v1/trigger` responde 501 (deshabilitado)

2) status.json
- [ ] Ejecutar el workflow de build requerido (ajustar nombre si aplica)
- [ ] Confirmar que `docs/status.json` se genera/actualiza
- [ ] Validar que `/briefing/v1/status` refleja `last_update` de `status.json`

3) Hub (shortcode)
- [ ] Crear página “Hub” en WP con `[briefing_hub]`
- [ ] Verificar render con “Estado general: OK”

4) repository_dispatch
- [ ] Disparar un evento `repository_dispatch` tipo `wp_content_published`
- [ ] Confirmar evidencia en `docs/ops/logs/run_repository_dispatch_*.log`

## Evidencias a adjuntar
- URLs de endpoints y capturas de pantalla de la página “Hub”
- Extractos de `docs/status.json` y logs en `docs/ops/logs/`

## Rollback
- Seguir `ROLLBACK_PLAN.md` en caso de revertir: eliminar MU‑plugin y workflows; validar ausencia de `briefing/v1` en `/wp-json`.
