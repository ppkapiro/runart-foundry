---
# Plan de Despliegue Real — Local → Preview → CloudFed Preview2 → Producción  
**Fecha:** 2025-10-09  
**Versión:** 1.0  
**Autor:** Agente Maestro / Copilot  
**Estado:** EN EJECUCIÓN  
---

## 1. Objetivo
Establecer un pipeline de despliegue **100 % automatizado** desde el entorno local hasta producción,
pasando por los entornos intermedios **Preview (Cloudflare Pages)** y **Preview2 (CloudFed/staging)**.
Garantizar que cada push o PR genere su respectivo deploy, validación y gates QA antes de promoción final.

## 2. Contexto actual
- Local, Preview y Producción operativos.  
- Falta `[env.preview2]` en wrangler.toml y workflows dedicados para staging y producción.  
- Secrets configurados en GitHub pero no unificados en todos los workflows.  
- Sin triggers de rollback/backup.

## 3. Checklist técnico de entornos

| Etapa | Descripción | Requerido | Estado actual |
|-------|--------------|------------|----------------|
| Local | Desarrollo y test con `wrangler pages dev` | ✅ | OK |
| Preview | Cloudflare Pages (PRs / deploy/*) | ✅ | OK |
| Preview2 (CloudFed) | Staging / demostración | ✅ | ❌ Falta |
| Producción | Branch main → Cloudflare Pages | ✅ | Parcial (sin workflow dedicado) |

### Variables principales
`CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`, `CF_PROJECT_NAME`,  
`RUNART_ENV`, `ACCESS_ADMINS`, `ACCESS_EQUIPO_DOMAINS`, `ACCESS_TEST_MODE`,  
`ACCESS_DEV_OVERRIDE`, `KV_DECISIONES`, `KV_LOG_EVENTS`, `KV_RUNART_ROLES`.

## 4. Workflows requeridos

| Workflow | Propósito | Branch / Trigger | Acciones | Secrets |
|-----------|------------|------------------|-----------|----------|
| **pages-preview.yml** | Deploy automático Preview | PR / push a deploy/* | Build + Deploy a Cloudflare Pages Preview | `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`, `CF_PROJECT_NAME` |
| **pages-preview2.yml** | Deploy staging CloudFed | PR / merge a develop | Build + Deploy a CloudFed Pages (staging) | mismos + `CF_PROJECT_NAME_STAGING` |
| **pages-prod.yml** | Deploy Producción | push a main | Build + Deploy a Cloudflare Pages main | mismos |
| **rollback.yml** | Reversión post-deploy | manual_dispatch | Restaurar versión previa desde artefactos | `GITHUB_TOKEN` |

## 5. Configuración wrangler.toml
Agregar bloques:
```toml
[env.preview2]
name = "runart-foundry-preview2"
vars = { RUNART_ENV = "preview2", ACCESS_TEST_MODE = "1" }
kv_namespaces = [
  { binding = "DECISIONES", id = "kv_decisiones_preview2" },
  { binding = "LOG_EVENTS", id = "kv_logs_preview2" },
  { binding = "RUNART_ROLES", id = "kv_roles_preview2" }
]
````

> Actualización 2025-10-09T19:21Z: IDs reales aplicados en `wrangler.toml` (`05a286b6941b4e1fb94727201d2bfa06`, `5c809442ad5a4a5cb4bcca714c70fabf`, `3d40c644267b4d93aa58c6a471eb5f22`).

Confirmar `[env.production]` tiene los mismos bindings con IDs reales de producción.

## 6. Integración GitHub ↔ Cloudflare

* Verificar proyecto Cloudflare Pages “runart-foundry”.
* Crear segundo proyecto “runart-foundry-preview2” (CloudFed staging).
* Vincular ambos a este repositorio con tokens y account ID válidos.
* Añadir secrets a GitHub para ambos entornos.

## 7. Gates y QA

* **Preview:** E2E + smokes automáticos (workflow `ci.yml`).
* **Preview2:** Validación QA manual o automática (workflow `pages-preview2.yml`).
* **Producción:** Post-deploy smokes (`pages-prod.yml`).
* **Rollback:** accionable vía workflow manual.

## 8. Riesgos y mitigaciones

| Riesgo                    | Nivel | Mitigación                                        |
| ------------------------- | ----- | ------------------------------------------------- |
| Falta de entorno staging  | Alto  | Crear `[env.preview2]` + workflow correspondiente |
| Tokens incompletos        | Medio | Unificar secrets en GitHub repo                   |
| Ausencia de rollback      | Medio | Agregar workflow rollback.yml                     |
| Desincronización wrangler | Bajo  | Actualizar con IDs reales en todas las secciones  |

## 9. Criterios de aceptación

1. Todos los workflows (preview, preview2, prod) existen y se ejecutan sin error.
2. wrangler.toml actualizado con bloques `[env.preview2]` y `[env.production]`.
3. Variables y tokens unificados entre GitHub y Cloudflare.
4. Deploy Preview y Producción visibles y accesibles.
5. Bitácora 082 actualizada con cada despliegue.

## 10. Sello de creación

```
DONE: true  
CREATED_AT: 2025-10-09T13:00:00Z  
NEXT: 04_orquestador_pipeline_real.md  
```
