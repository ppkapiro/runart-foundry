---
# D2 — Configuración wrangler.toml
**Fecha:** 2025-10-09
**Versión:** 1.0
**Estado:** completed

## Objetivo
Alinear `wrangler.toml` con los entornos definidos.

## Acciones
- Añadir `[env.preview2]` y verificar `[env.production]`.
- Confirmar bindings KV (`DECISIONES`, `LOG_EVENTS`, `RUNART_ROLES`).
- Documentar IDs reales o placeholders si faltan.

## Evidencia
- `wrangler.toml` incluye bindings globales `DECISIONES`, `LOG_EVENTS`, `RUNART_ROLES` con `preview_id` definidos.
- Se añadió `[env.preview2]` con `vars` y `kv_namespaces` (IDs placeholders: `kv_decisiones_preview2`, `kv_logs_preview2`, `kv_roles_preview2`).
- Se creó `[env.production.vars]` para dejar explícito el `RUNART_ENV = "production"` y las restricciones de acceso.
- **Limitación (resuelta 2025-10-09T19:21Z):** IDs reales aplicados (`05a286b6941b4e1fb94727201d2bfa06`, `5c809442ad5a4a5cb4bcca714c70fabf`, `3d40c644267b4d93aa58c6a471eb5f22`).
- Recomendación: sincronizar los IDs con Cloudflare y validar que `ORIGIN_ALLOWED` y `RUNART_ENV` correspondan a cada entorno.

## Sello de cierre
```
DONE: true
CLOSED_AT: 2025-10-09T13:45:00Z
SUMMARY: D2 completado con hallazgos: pendiente crear bloque env.preview2 y confirmar IDs KV.
NEXT: D3
```
---
