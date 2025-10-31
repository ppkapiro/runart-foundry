---
# Auditoría Cloudflare & GitHub Secrets (Real)
**Fecha:** 2025-10-09
**Versión:** 1.0
**Estado:** in-progress

## Alcance
Verificar la existencia y consistencia de los secretos requeridos para los despliegues Local → Preview → Preview2 → Producción.

## Matriz de secretos requeridos
| Nombre | Ubicación esperada | Estado | Notas |
| --- | --- | --- | --- |
| CLOUDFLARE_API_TOKEN | GitHub Actions · Cloudflare Pages | Observado en workflows (`pages-*`) | Requiere verificación en panel (no accesible desde repo). |
| CLOUDFLARE_ACCOUNT_ID | GitHub Actions · Cloudflare Pages | Observado en workflows (`pages-*`) | Confirmar valor real en secrets. |
| CF_PROJECT_NAME | GitHub Actions | Definido como constante `runart-foundry` | Sugiere crear secret solo si se desea parametrizar. |
| RUNART_ENV | GitHub Actions | No referenciado directamente en workflows nuevos | Considerar añadir secret si se utilizará dinámicamente. |
| ACCESS_ADMINS | GitHub Actions · Cloudflare Vars | Definido en `wrangler.toml` | Validar sincronización con Cloudflare Pages. |
| ACCESS_EQUIPO_DOMAINS | GitHub Actions · Cloudflare Vars | Definido en `wrangler.toml` | Confirmar lista vigente. |
| ACCESS_TEST_MODE | GitHub Actions · Cloudflare Vars | Presente en `env.preview.vars`, `env.preview2.vars` | Requiere confirmación en panel. |
| KV_DECISIONES | GitHub Actions | No referenciado directamente | Mapear con `kv_namespaces` (IDs placeholders para preview2). |
| KV_LOG_EVENTS | GitHub Actions | No referenciado directamente | Ídem anterior. |
| KV_RUNART_ROLES | GitHub Actions | No referenciado directamente | Ídem anterior. |

## Pendientes
1. Validar desde GitHub (`Settings > Secrets and variables > Actions`) que `CLOUDFLARE_API_TOKEN` y `CLOUDFLARE_ACCOUNT_ID` estén cargados.
2. Confirmar en Cloudflare Pages los IDs reales de `DECISIONES`, `LOG_EVENTS`, `RUNART_ROLES` para staging (`preview2`).
3. Registrar `RUNART_ENV` y variables ACCESS como secrets si se requiere diferenciación por entorno.

## Próximos pasos
- Actualizar este informe a **completed** tras validar en paneles externos.
- Sustituir los placeholders de `wrangler.toml` con los IDs confirmados.
---
