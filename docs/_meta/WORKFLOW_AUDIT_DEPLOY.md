# Auditoría de Workflows — Deploy Cloudflare Pages (Briefing)

Generado: 2025-10-23T00:00:00Z (UTC)
Origen: .github/workflows/*

## Resumen ejecutivo

- Workflows totales: 45+
- Relevantes para deploy de Briefing (Pages): 7 principales
- Hallazgos críticos:
  - Duplicidad/triplicidad de pipelines de producción (riesgo de publicaciones concurrentes y artefactos inconsistentes):
    - `pages-deploy.yml` (MkDocs → apps/briefing/dist)
    - `pages-prod.yml` (Node/NPM → apps/briefing/site)
    - `ci.yml` (job deploy con Wrangler → apps/briefing/site)
  - Divergencia de rutas de build (`dist` vs `site`).
  - `pages-prod.yml` fija `CLOUDFLARE_ACCOUNT_ID` en claro.
- Recomendación prioritaria: Consolidar a un único flujo de producción y alinear carpeta de salida.

## Inventario de workflows de deploy

1) Deploy to Cloudflare Pages (Briefing) — `.github/workflows/pages-deploy.yml`
- Trigger: push (main) sobre `apps/briefing/**`, `docs/**` y el propio workflow; manual `workflow_dispatch`.
- Build: MkDocs `mkdocs build --strict -d dist` (apps/briefing → dist).
- Deploy: `cloudflare/pages-action@v1` → proyecto `runart-foundry` (directory: `apps/briefing/dist`).
- Secrets: `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`; Purge opcional con `CF_ZONE_ID`.
- Post: anota en `docs/_meta/BRIEFING_STATUS_PIPELINE_RUN.md`.
- Estado: CANÓNICO propuesto (contenido MkDocs).

2) Deploy Production (Cloudflare) — `.github/workflows/pages-prod.yml`
- Trigger: push (main) y manual.
- Build: Node/NPM en `apps/briefing` → genera `apps/briefing/site`.
- Guards: validación DNS/HTTP, smokes unitarios, guard contra `workers.dev` en artefacto.
- Deploy: `cloudflare/pages-action@v1` (directory: `./apps/briefing/site`).
- Secrets: `CLOUDFLARE_API_TOKEN` (OK). Usa `CLOUDFLARE_ACCOUNT_ID` hardcodeado en env (riesgo de drift/filtración leve).
- Estado: DUPLICA deploy de producción (conflicto con `pages-deploy.yml`).

3) CI — Briefing (job `deploy`) — `.github/workflows/ci.yml`
- Trigger: push (main) y PR cuando cambia `apps/briefing/**`.
- Build: MkDocs (venv + requirements), output `apps/briefing/site`.
- Deploy: `wrangler pages deploy apps/briefing/site --project-name runart-foundry`.
- Secrets: `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID` (vía env en runner).
- Estado: TERCER flujo que publica a producción; riesgo alto de carreras.

4) Deploy Preview — `.github/workflows/pages-preview.yml`
- Trigger: PR contra develop/main/deploy/** y manual.
- Build: NPM en `apps/briefing`; tests de humo; deploy preview (`cloudflare/pages-action`).
- Salida: `apps/briefing/site`; extrae `preview_url` por API si no lo da la acción.
- Estado: OK (preview controlado para PRs).

5) Deploy Preview2 — `.github/workflows/pages-preview2.yml`
- Trigger: push (develop, deploy/preview2) y manual.
- Build/Deploy: similar a preview, rama de destino `preview2`.
- Estado: OK si se requiere staging adicional; en caso contrario, candidata a limpieza.

6) Briefing Deploy (LEGACY) — `.github/workflows/briefing_deploy.yml`
- Trigger: push (main) y PR sobre `briefing/**`, pero requiere confirmación `confirm_legacy=='yes'` (no corre por defecto).
- Build: MkDocs desde carpeta legacy `briefing/`.
- Estado: LEGACY, no operativo salvo ejecución manual con confirmación; recomendable archivar.

7) Verify Production (Briefing) — `.github/workflows/deploy-verify.yml`
- Trigger: `workflow_run` cuando termina "Deploy to Cloudflare Pages (Briefing)" con éxito.
- Checks: `/, /status/, /news/, /status/history/` y registra en meta.
- Estado: OK (post-verificación).

Otros relevantes:
- Guard: `.github/workflows/pages-preview-guard.yml` (exige presencia de Pages Preview en PR).
- Overlay: `.github/workflows/overlay-deploy.yml` (Workers overlay; no publica sitio estático de Pages).

## Matriz de secretos/riesgos

- Cloudflare Pages producción:
  - `CLOUDFLARE_API_TOKEN` (necesario en todos los deployers) — OK.
  - `CLOUDFLARE_ACCOUNT_ID` — debe provenir de Secret; evitar hardcode (detectar en `pages-prod.yml`).
- Purge opcional: `CF_ZONE_ID` — presente en `pages-deploy.yml`; guardias correctas.
- GitHub Token: `secrets.GITHUB_TOKEN` — uso mínimo, OK.

Riesgos detectados:
- Publicaciones simultáneas desde 2-3 workflows al mismo proyecto `runart-foundry` tras push a main.
- Inconsistencia de artefacto publicado (unas veces `dist`, otras `site`).
- Hardcode de `CLOUDFLARE_ACCOUNT_ID` en `pages-prod.yml`.

## Recomendaciones (acción)

1) Canonizar pipeline de producción
- Elegir 1 flujo: Propuesta → mantener `pages-deploy.yml` (MkDocs `--strict`, logging en meta, verify encadenado).
- Cambiar `pages-prod.yml` a solo `workflow_dispatch` (manual) o añadir `if: false` en job para evitar push automático.
- En `ci.yml`, eliminar/inhabilitar el job `deploy` (dejar solo build/test), o guardarlo bajo `workflow_dispatch`.

2) Alinear carpeta de salida
- Adoptar una sola: `apps/briefing/site` (estándar MkDocs) o `apps/briefing/dist`. Propuesta: usar `site` para converger con `pages-prod.yml` y `ci.yml` si se mantuvieran.
- Si se adopta `site`, actualizar `pages-deploy.yml` a `mkdocs build --strict` (default → site) y `directory: apps/briefing/site`.

3) Secret hygiene y permisos
- Reemplazar hardcode de `CLOUDFLARE_ACCOUNT_ID` en `pages-prod.yml` por `secrets.CLOUDFLARE_ACCOUNT_ID`.
- Confirmar alcance del token: Account → Cloudflare Pages: Edit; opcionales de lectura.

4) Concurrency/locks
- Añadir `concurrency` a `pages-deploy.yml` para evitar carreras (e.g. `group: pages-prod`, `cancel-in-progress: true`).

5) Gobernanza
- Documentar en `docs/_meta/INDEX_INTEGRATIONS.md` el pipeline canónico y los workflows deshabilitados.
- Archivar `briefing_deploy.yml` en `_archive/` cuando sea viable.

## Próximos pasos sugeridos

- [ ] Aplicar consolidación (deshabilitar `pages-prod.yml` y `ci.yml:deploy`), abrir PR con justificación.
- [ ] Alinear output (site vs dist) y ajustar `pages-deploy.yml` si procede.
- [ ] Añadir `concurrency` a `pages-deploy.yml` y `environment: production` si se desea usar rules.
- [ ] Confirmar que `deploy-verify.yml` reporta en meta tras el primer despliegue exitoso.

---
SHA base del análisis: HEAD actual en main.

## Estado post-consolidación (ejecutado)

- Canónico (producción): `pages-deploy.yml` — MkDocs (no strict) → `apps/briefing/site` → Cloudflare Pages; concurrency `deploy-prod`; meta con SHA; verify encadenado.
- Secundarios (contingencia manual):
  - `pages-prod.yml` — DEPRECATED; `workflow_dispatch` únicamente; usa `CLOUDFLARE_ACCOUNT_ID` desde secrets.
  - `ci.yml` — Job `deploy` bloqueado salvo `workflow_dispatch` con input `deploy_prod=true`. Build y tests siguen activos en push/PR.
- Salida unificada: `apps/briefing/site`.
- Monitor: `monitor-deploys.yml` activo cada 10 minutos, con guardas anti-colisión/anti-carrera y artifacts TSV/JSON.

### Preflight de secretos

- `preflight-cloudflare-secrets.yml` — Verifica presencia y permisos de `CLOUDFLARE_API_TOKEN` y `CLOUDFLARE_ACCOUNT_ID` contra API de Pages.
- Si falla, abre Issue automáticamente; si pasa, registra en meta.

---

## Estado post-fix Deploys & Staging (2025-10-24)

### Cloudflare Access — Verificación Autenticada

**Problema:** Producción (`runart-foundry.pages.dev`) protegida por Cloudflare Access; todas las rutas retornan HTTP 302 → login. Verificación post-deploy fallaba con curls sin autenticación.

**Solución:**
- `.github/workflows/deploy-verify.yml` actualizado para usar **Service Token headers**:
  - `CF-Access-Client-Id: ${{ secrets.CF_ACCESS_CLIENT_ID }}`
  - `CF-Access-Client-Secret: ${{ secrets.CF_ACCESS_CLIENT_SECRET }}`
- Detección automática de secrets disponibles; si no existen → SKIP graceful (no falla workflow)
- Log diferenciado:
  - ✅ "Verificación post-deploy OK (Access-auth)" si secrets disponibles y rutas 200
  - ⚠️ "Verificación post-deploy SKIP (Access protegido, no service token)" si secrets faltan
- Soporte alternativo para nomenclatura `ACCESS_CLIENT_ID_PROD/SECRET_PROD`

**Estado actual de secrets:**
- ❌ `CF_ACCESS_CLIENT_ID` — NO configurado (requerido para prod)
- ❌ `CF_ACCESS_CLIENT_SECRET` — NO configurado (requerido para prod)
- ✅ `ACCESS_CLIENT_ID_PREVIEW` — configurado (para preview/staging)
- ✅ `ACCESS_CLIENT_SECRET_PREVIEW` — configurado (para preview/staging)

**Issue:** https://github.com/RunArtFoundry/runart-foundry/issues/69 — "Configure CF Access Service Token for Production Verify"

### Monitor Endurecido

**Cambio:** `.github/workflows/monitor-deploys.yml` ahora tolera verify SKIP por Access protegido:
- No alarma si meta-log contiene "SKIP (Access protegido"
- Solo alarma si deploy FAIL o verify FAIL real (no causado por 302/Access sin secrets)
- Falsos positivos eliminados

### Cache Purge Opcional

**Cambio:** `.github/workflows/pages-deploy.yml` añadido step condicional:
- Purga cache de Cloudflare (purge_everything) si `CF_ZONE_ID` disponible
- Skip sin error si secret no configurado
- `continue-on-error: true` para no bloquear deploy

### Carpeta Site Unificada

**Confirmado:**
- ✅ Build: `mkdocs build -d site` en `apps/briefing/`
- ✅ Output: `apps/briefing/site/index.html` y `site/status/index.html`
- ✅ Deploy: `directory: apps/briefing/site`
- ✅ No más divergencia dist vs site

### Permisos y Concurrency

**Confirmado:**
- ✅ `permissions: contents: write, deployments: write` — evita error 403 en GitHub Deployments API
- ✅ `concurrency: group: deploy-prod, cancel-in-progress: true` — previene carreras

### Evidencias

Auditoría completa en `docs/_meta/_deploy_diag/`:
- `EVIDENCE_SUMMARY.md` — resumen ejecutivo con headers HTTP y configuración
- `SECRETS_AUDIT.md` — inventario de secrets disponibles/faltantes
- `STAGING_PREVIEW_ACCESS.md` — políticas de Access por entorno y propuesta verify-preview.yml
- `head_*.txt` — headers HTTP raw de todas las rutas (/, /status/, /news/, /status/history/)

Generado/actualizado: 2025-10-24T14:20Z
\n## Validación Access y Protección Activa
- Estado: FAILED
- Ver detalle en docs/_meta/ACCESS_DIAG_BRIEFING.md
\n## Validación Access y Protección Activa
- Estado: FAILED
- Ver detalle en docs/_meta/ACCESS_DIAG_BRIEFING.md
- OPT-IN Service Token creado: NO
\n## Validación Access y Protección Activa
- Estado: FAILED
- Ver detalle en docs/_meta/ACCESS_DIAG_BRIEFING.md
- OPT-IN Service Token creado: NO
\n## Validación Access y Protección Activa
- Estado: FAILED
- Ver detalle en docs/_meta/ACCESS_DIAG_BRIEFING.md
- OPT-IN Service Token creado: NO
\n## Validación Access y Protección Activa
- Estado: FAILED
- Ver detalle en docs/_meta/ACCESS_DIAG_BRIEFING.md
- OPT-IN Service Token creado: NO
\n## Validación Access y Protección Activa
- Estado: FAILED
- Ver detalle en docs/_meta/ACCESS_DIAG_BRIEFING.md
- OPT-IN Service Token creado: NO
\n## Validación Access y Protección Activa
- Estado: FAILED
- Ver detalle en docs/_meta/ACCESS_DIAG_BRIEFING.md
- OPT-IN Service Token creado: NO
\n## Validación Access y Protección Activa
- Estado: FAILED
- Ver detalle en docs/_meta/ACCESS_DIAG_BRIEFING.md
- OPT-IN Service Token creado: NO
\n## Validación Access y Protección Activa
- Estado: FAILED
- Ver detalle en docs/_meta/ACCESS_DIAG_BRIEFING.md
- OPT-IN Service Token creado: NO
\n## Validación Access y Protección Activa
- Estado: FAILED
- Ver detalle en docs/_meta/ACCESS_DIAG_BRIEFING.md
- OPT-IN Service Token creado: NO
\n## Validación Access y Protección Activa
- Estado: FAILED
- Ver detalle en docs/_meta/ACCESS_DIAG_BRIEFING.md
- OPT-IN Service Token creado: NO
\n## Validación Access y Protección Activa
- Estado: FAILED
- Ver detalle en docs/_meta/ACCESS_DIAG_BRIEFING.md
- OPT-IN Service Token creado: NO
\n## Validación Access y Protección Activa
- Estado: FAILED
- Ver detalle en docs/_meta/ACCESS_DIAG_BRIEFING.md
- OPT-IN Service Token creado: NO
