---
status: active
owner: reinaldo.capiro
updated: 2025-10-23
audience: internal
tags: [briefing, runart, ops]
---

# Plan de Switch Cloudflare Pages → `apps/briefing`

## Objetivo

Migrar el build canónico de Cloudflare Pages desde la carpeta de compatibilidad `briefing/` hacia `apps/briefing/` sin interrumpir previews ni despliegues de producción. El plan contempla validaciones previas, ejecución escalonada y un rollback inmediato.

## Estado actual — 2025-10-06

- ✅ Pre-checks locales completados (`make build`, `make lint-docs`, `make test-env`) — evidencia en `audits/env_check.log` (2025-10-06T13:49Z).
- ✅ Documentación y plantillas sincronizadas (`README.md`, `apps/briefing/README_briefing.md`, `.github/pull_request_template.md`).
- ⚠️ Pendiente ejecutar cambio en Cloudflare Pages (esta PR) y eliminar la capa `briefing/` tras el smoke test en producción.

## Prerrequisitos (T-3 días)

1. **Código**
   - `apps/briefing` es la única fuente de contenido; la capa `briefing/` sólo contiene wrappers (Makefile, mkdocs.yml, wrangler.toml delegados).
   - `tools/check_env.py` y `tools/lint_docs.py` operativos (verificados con `make lint-docs`).
   - Documentación actualizada (`docs/architecture/000_overview.md`, `010_inventory.md`, `050_make_targets.md`).
2. **CI/CD**
   - Workflows vigentes (`ci.yml`, `briefing_deploy.yml`) en verde tras ejecutar `make build MODULE=apps/briefing`.
   - Pipeline de promoción (`promote_inbox*`) probado apuntando a `apps/briefing/`.
3. **Observabilidad**
   - `audits/env_check.log` limpio tras `make test-env` y `make test-env-preview`.
   - Último deploy exitoso anotado en `STATUS.md`.
4. **Accesos**
   - Token de API Cloudflare (`CF_API_TOKEN`) y `CF_ACCOUNT_ID` válidos.
   - Acceso verificado a Cloudflare Pages y Access (para modificar reglas si es necesario).

## Checklist T-0 (previa al switch)

| Paso | Acción | Responsable | Evidencia |
|------|--------|-------------|-----------|
| 1 | Congelar merges a `main` (comunicar en Slack) | Producto/DevOps | Mensaje fijado |
| 2 | Ejecutar `make clean build test` en `apps/briefing` | DevOps | Log local adjunto |
| 3 | Ejecutar `make lint-docs` en la raíz | DevOps | Log en comentario de PR |
| 4 | Ejecutar `PREVIEW_URL=<url> make test-env-preview` | QA | `audits/env_check.log` con timestamp |
| 5 | Validar `make build` dentro de `briefing/` (wrapper) | QA | Confirma que sigue delegando |
| 6 | Crear backup del proyecto Pages (`wrangler pages project list --json`) | DevOps | JSON adjunto |

## Preparación de la rama y PR

1. Crear rama `switch/apps-briefing` a partir de `main` y actualizar `STATUS.md` con la bandera 🟢 para `apps/briefing` una vez que los smokes estén listos.
2. Commits sugeridos:
   - `chore: point workflows to apps briefing` → actualiza los paths en `.github/workflows/ci.yml`, `briefing_deploy.yml` y cualquier workflow auxiliar que dispare builds de MkDocs.
   - `chore: update pages build config` → modifica `briefing/wrangler.toml` (alias) y documenta en `docs/architecture/040_ci_shared.md` el nuevo comando (`make build MODULE=apps/briefing`).
   - `docs: switch execution playbook` → incorpora evidencia en `audits/2025-10-06_cloudflare_switch/` y enlaza el resumen en `README.md`/`STATUS.md`.
3. Asegurar que la PR incluya checklist con los pasos de esta guía y adjuntar logs de `make lint-docs` y `make test-env-preview`.
4. Solicitar revisión a responsables de DevOps y QA antes de tocar Cloudflare Pages.

## Ejecución del switch

1. **Actualizar CI**
   - Modificar triggers de workflows para observar `apps/briefing/**` en lugar de `briefing/**` (ver `docs/architecture/040_ci_shared.md`).
   - Ajustar comandos a `make build MODULE=apps/briefing` y `make test MODULE=apps/briefing`.
2. **Actualizar proyecto Pages**
   - `Build command`: `make build MODULE=apps/briefing`.
   - `Build output`: `apps/briefing/site`.
   - Verificar variables de entorno/kv bindings se mantienen.
3. **Verificar previews**
   - Lanzar una PR dummy para generar preview.
   - Validar banner PREVIEW, `data-env="preview"` y `/api/whoami`.
4. **Verificar producción**
   - Ejecutar `PROD_URL=<dom> make test-env-prod`.
   - Correr smokes: `bash apps/briefing/scripts/smoke_arq3.sh` y `smoke_exports.sh`.
5. **Desmantelar compatibilidad (opcional F+1)**
   - Cuando se confirme estabilidad (>48h), convertir `briefing/` en alias mínimo (README + referencias) o eliminar siguiendo `[075_cleanup_briefing.md](075_cleanup_briefing.md)`.

### Evidencias obligatorias

| Tipo | Descripción | Destino |
|------|-------------|---------|
| Captura Cloudflare Pages | Pantalla de configuración con el nuevo comando/output | `audits/2025-10-06_cloudflare_switch/cf_pages_config.png` |
| Log preview | Resultado de `make test-env-preview` apuntando a la nueva URL | `audits/2025-10-06_cloudflare_switch/test_env_preview.log` |
| Log producción | Resultado de `make test-env-prod` tras el deploy | `audits/2025-10-06_cloudflare_switch/test_env_prod.log` |
| Smoke scripts | Salida de `smoke_arq3.sh` y `smoke_exports.sh` | `audits/2025-10-06_cloudflare_switch/smokes/` |
| Diff artefactos | `diff -qr briefing/site apps/briefing/site` ejecutado post-deploy | `audits/2025-10-06_cloudflare_switch/diff_sites.txt` |
| Nota de cierre | Resumen en `STATUS.md` (enlace a la carpeta de auditoría) | `STATUS.md` sección “Últimos hitos” |

## Rollback inmediato (T+15 min)

1. Restaurar configuraciones de Pages:
   - `Build command`: `make build` (dentro de `briefing/`).
   - `Build output`: `briefing/site`.
2. Revertir commits de workflows que apuntan a `apps/briefing` (mantener PR abierta con cambios revertidos para seguimiento).
3. Reejecutar `make build` en `briefing/` y lanzar deploy manual si el pipeline tarda.
4. Verificar endpoints (`/api/inbox`, `/api/decisiones`) con smoke scripts desde `briefing/scripts/`.
5. Registrar incidente menor en `INCIDENTS.md` con motivo del rollback.

## Señales de éxito

- Despliegues automáticos y previews utilizan `apps/briefing/site`.
- `make test-env` registra `source=apps/briefing` en `audits/env_check.log`.
- Workflows (`ci.yml`, `briefing_deploy.yml`) muestran rutas nuevas en logs.
- Cloudflare Access mantiene reglas sin cambios.
- No se detectan diferencias sustanciales entre assets generados (`diff -qr briefing/site apps/briefing/site`).

## Seguimiento posterior

- A las 24h: ejecutar nuevamente smoke tests y registrar resultados en `_reports/`.
- Actualizar `docs/architecture/070_risks.md` eliminando el riesgo asociado al switch.
- Notificar a stakeholders y cerrar congelamiento de merges.
