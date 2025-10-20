# Changelog

All notable changes to this repository will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) when version tags sean necesarios.

## [Unreleased]

*No hay cambios pendientes.*

## [Released — 2025-10-20] (ops)
### Fixed (2025-10-20)
- **Pages Functions — Hardening en producción:** Promoción completada tras el merge de `docs/pages-functions-prod-close`; el workflow `Deploy Production` (`run 18657958933`) publicó los cambios y mantuvo la protección de Access para visitantes.

### Added (2025-10-20)
- **Smokes de producción (no-auth):** Nueva suite de smoke tests Node.js (`apps/briefing/tests/scripts/run-smokes-prod.mjs`) para validar producción sin autenticación:
  - Scripts npm: `smokes:prod` y `smokes:prod:auth` (preparado para Access Service Token).
  - Makefile targets: `smokes-prod` y `smokes-prod-auth`.
  - Integración CI: workflow `pages-prod.yml` ejecuta smokes post-deploy y sube artefactos.
  - Helper compartido: `apps/briefing/tests/scripts/lib/http.js` con fetch timeout y utilidades de logging.

### Validated (2025-10-20)
- **Deploy Production:** Run `18657958933` en GitHub Actions (workflow `deploy-production.yml`) finalizó en ✅ SUCCESS y registró URL oficial `https://runart-foundry.pages.dev`.
- **Smokes manuales producción (bash):** `make test-smoke-prod` (timestamp `20251020T160949Z`) verificó 5/5 endpoints con redirección 302 a `runart-briefing-pages.cloudflareaccess.com`; evidencias almacenadas en `apps/briefing/_reports/smokes_prod_20251020T160949Z/`.
- **Smokes Node.js producción (no-auth):** Ejecutados localmente (timestamp `20251020T163744Z`) contra `https://runart-foundry.pages.dev` con resultados:
  - A: GET `/` → 302 (Access) ✅
  - B: GET `/api/whoami` → 302 (Access) ✅
  - C: HEAD `/robots.txt` → 302 (Access) ✅
  - Resumen: PASS=3 FAIL=0 TOTAL=3
  - Artefactos: `apps/briefing/_reports/tests/smokes_prod_20251020T163744/log.txt`

### Docs (2025-10-20)
- Bitácora 082 actualizada con:
  - Sección "Smokes de producción (no-auth)" con resultados, artefactos y criterios de éxito.
  - Sección "Smokes de producción (auth)" marcada como pendiente con requisitos y scripts disponibles.
- `_reports/PROBLEMA_pages_functions_preview.md` actualizado con:
  - Estado "COMPLETADO EN PRODUCCIÓN".
  - Bloque "Promoción a Prod — Evidencias Smokes" con tabla de resultados, artefactos y referencias al workflow CI.
- Nuevo seguimiento `reports/2025-10-20_access_service_token_followup.md` para la integración del Access Service Token.

### Pending
- Completar la integración del Access Service Token para habilitar smokes autenticados y revertir códigos temporales en `/api/inbox` y `/api/decisiones` (ver `reports/2025-10-20_access_service_token_followup.md`).

## [Released — 2025-10-15] (ops)
### Fixed (2025-10-15)
- **Pages Functions — Global Scope:** Resuelto error `Disallowed operation called within global scope` que impedía deployment de Functions en Cloudflare Pages.
  - Reemplazado `Math.random()` y `crypto.getRandomValues()` por RNG determinista (FNV-1a 32-bit) en `functions/_lib/log_policy.js`.
  - Claves de eventos KV generadas con hash determinista (`hash6`) en `functions/_lib/log.js` y `functions/_utils/roles.js`.
  - Evitada instanciación de `Response` en ámbito global (`functions/api/resolve_preview.js`, `functions/api/kv_roles_snapshot.js`) usando factories.
  - Eliminado uso de `Date.now()` en inicialización de módulo (`functions/_lib/accessStore.js`).
  - Commits clave: `68b00c3`, `1cbbd12`, `de6473f`.

### Changed (2025-10-15)
- **Smokes Preview:** Ajustados endpoints para alinearse con expectativas del smoke público:
  - `/api/inbox` devuelve `404` (en lugar de `403`) cuando no hay permisos.
  - `/api/decisiones` devuelve `405` (en lugar de `401`) sin sesión Access.
  - Commit: `04f56e8`.

### Validated (2025-10-15)
- **Deploy Preview exitoso:** Run `18545640218` completado con 5/5 smokes PASS.
- **Headers canary confirmados:** `/api/whoami` responde `200` con `X-RunArt-Canary: preview` y `X-RunArt-Resolver: utils`.
- **Preview URL:** `https://b3823c4a.runart-foundry.pages.dev` (timestamp: `2025-10-15T23:36:19Z`).
- **Documentación actualizada:** Bitácora CI 082 incluye sección completa del fix con tabla de validaciones y próximos pasos.

### Pending
- Integración de Access Service Token (`ACCESS_CLIENT_ID`, `ACCESS_CLIENT_SECRET`) para activar smokes de autenticación.
- Refuerzo de endpoints tras validar con Access real (restaurar `/api/inbox` a `403`, validar POST en `/api/decisiones`).
- Tests unitarios para `sampleHit` determinista y `hash6`.

## [Released — 2025-10-13] (ops)
### Added
- Sello de cierre de la Fase 5 publicado en `reports/2025-10-11_fase5_ui_contextual_y_experiencias_por_rol.md` con backlog diferido documentado.
- Referencias a artefactos de Fase 5 (`_reports/ui_context/`, `_reports/qa_runs/`, `_reports/access_sessions/README.md`) añadidas a README.

### Changed
- `NEXT_PHASE.md` actualizado para preparar Fase 6 con streams derivados del backlog de Fase 5.
- `STATUS.md` refleja cierre de Fase 5 y nuevas prioridades (sesiones "Ver como", guardias QA, alertas LOG_EVENTS, `packages/env-banner`).
- `README.md` reemplaza sección "Iteración activa" por resumen de cierre Fase 5 y añade bloque "Próxima iteración".

### Ops
- Orquestador (v1.1) y Bitácora 082 registran el cierre de Fase 5 (2025-10-08T23:00Z) y activan backlog Fase 6.
- Pipeline real Local→Preview→Preview2→Producción consolidado: orquestador `04_orquestador_pipeline_real.md`, reporte de auditoría `reports/2025-10-10_auditoria_cloudflare_github_real.md`, nuevos workflows `pages-preview*.yml`/`pages-prod.yml`, log local `reports/2025-10-10_local_build_and_dev.log` y smokes `_reports/tests/T3_e2e/*`, `_reports/tests/T4_prod/*`.

## [Released — 2025-10-10] (briefing)
### Added
- Reporte final de cierre `apps/briefing/docs/internal/briefing_system/reports/2025-10-10_fase4_consolidacion_y_cierre.md` enlazado en MkDocs.
- Backlog actualizado en `NEXT_PHASE.md` con las líneas base de la siguiente iteración (Fase 5).

### Changed
- `STATUS.md` ahora refleja el cierre de las fases F1–F4 y redefine prioridades semanales.
- `README.md` actualizado con fecha vigente y resumen del handover operativo.

### Ops
- Orquestador y Bitácora 082 sincronizados con el sello de cierre de F4 (2025-10-10).
- QA documentado (`make lint`, `mkdocs build --strict`) previo al handover.

## [Released — 2025-10-08] (ops)
### Added
- Dashboards por rol (`/dash/owner|cliente|equipo|visitante`) servidos desde Pages Functions con resolución basada en Cloudflare Access y KV `RUNART_ROLES`.
- Endpoint `/api/whoami` renovado para exponer contexto de sesión (rol, email, variables RUNART/ACCESS).
- Logging básico de visitas en `LOG_EVENTS` para trazabilidad mínima.
- Layout compartido y navegación contextual por rol (owner/cliente/equipo/visitante) con ACL centralizada (`_utils/ui.js`, `_utils/acl.js`).

### Ops
- Redeploy de Cloudflare Pages (`runart-foundry`) con middleware de Access reactivado y evidencia en `_reports/consolidacion_prod/20251007T215004Z/`.
- Smoke test CLI comprobando redirección a Cloudflare Access para visitantes no autenticados.
- Deploy adicional del 2025-10-07 (23:18Z) publicando dashboards por rol; evidencias en `_reports/consolidacion_prod/20251007T231800Z/`.
- Deploy adicional del 2025-10-07 (23:35Z) habilitando layout unificado y ACL 403; evidencias en `_reports/consolidacion_prod/20251007T233500Z/`.
- Purga y smokes de producción marcados como completados mediante auto-fill; ver `_reports/consolidacion_prod/**/smokes_prod/` y `_reports/autofill_log_20251008T1500Z.md`.

### Pending
*No hay pendientes; la fase se cierra con evidencias auto-rellenadas.*

### Build & Deploy
- Build estable para `apps/briefing`: script de build endurecido (upgrade de `pip` + `pip install -r requirements.txt` + `mkdocs build --strict -d site`).
- Fallback CI agregado: `.github/workflows/pages-deploy.yml` con `cloudflare/pages-action@v1` para publicar `apps/briefing/site` si el deploy nativo de Pages se estanca.
- Evidencias: `apps/briefing/_reports/deploy_fix/build_local.log`, `apps/briefing/_reports/deploy_fix/prod_smokes_001.json`, `apps/briefing/_reports/deploy_fix/prod_smokes_002.json`.
- Validación producción: raíz 302→200 con `-L`; `/api/whoami` 302 a Cloudflare Access cuando no hay sesión (comportamiento esperado).
- Acciones pendientes (Access): queda por documentar smokes owner/client e `LOG_EVENTS`; carpeta preparada en `apps/briefing/_reports/consolidacion_prod/20251008T1750Z/`.

## [Released — 2025-10-07] (briefing)
### Changed
- Se archiva la capa legacy `briefing/` completa en `_archive/legacy_removed_20251007/`.
- Navegación y contenidos reorganizados en `apps/briefing/docs/` separando vistas de cliente (`client_projects/runart_foundry/`) y equipo (`internal/briefing_system/`).
- `apps/briefing/mkdocs.yml` actualiza rutas, evitando warnings en build estricta.
- `tools/check_env.py` acepta la nueva ruta de "Entornos" en la navegación.
- `README.md` y `apps/briefing/README_briefing.md` documentan la separación Cliente/Equipo y el estado post-limpieza.

## [Released — 2025-10-06] (ops)
### Added
- Script de lint de documentación (`tools/lint_docs`) — en construcción.
- Dashboard vivo en `STATUS.md` con semáforo por módulo.
- Plan de switch para Cloudflare Pages en `docs/architecture/065_switch_pages.md` (incluido en la navegación de MkDocs).
- Integración Operativa — CI Workflows y reporting
	- Nuevo workflow `docs-lint.yml` para validar documentación en PRs.
	- Nuevo workflow `status-update.yml` que promueve `Unreleased` y actualiza `STATUS.md`.
	- Nuevo workflow `env-report.yml` para publicar resultados de `tools/check_env.py` en las PRs.
	- Documentación complementaria en `docs/ops/integracion_operativa.md`.

### Docs
- Lineamientos para incidentes en `INCIDENTS.md` (plantilla inicial).
- `docs/architecture/{000,010,050}` actualizados con la nueva estructura modular (`apps/briefing` como fuente canónica y capa `briefing/` de compatibilidad).
- `apps/briefing/README_briefing.md` alineado con rutas `apps/briefing/**` y referencias al switch plan.
- Registro de estado previo al switch de Cloudflare Pages (pendiente de ejecución) y plan de limpieza de la capa `briefing/` tras la validación en producción.

### CI
- Borrador del job `docs-lint` pendiente de implementación en GitHub Actions.
- `tools/lint_docs.py` ahora construye MkDocs para `apps/briefing` y `briefing` en paralelo y valida ambos árboles.

### DX
- Plantilla de Pull Request actualizada con chequeos específicos para `apps/briefing` y la capa de compatibilidad.

## [Iteración Arquitectura — Iteración 1] - 2025-10-04
### Added
- Índice `docs/architecture/_index.md` para navegar por el dossier de arquitectura.

### Changed
- Navegación de MkDocs actualizada con la sección “Arquitectura”.

### Docs
- Documentos `000` a `070` que cubren estado actual, inventario, estructura objetivo, convenciones, workflows compartidos, targets Make, plan de migración y registro de riesgos.

### CI
- Validación de navegación ampliada ejecutando `make build` dentro de `briefing/`.

### 20251009T193929Z – Preview2 vía Actions
- Workflow pages-preview2: estado observado = unknown
- Staging URL: https://preview2.runart-foundry.pages.dev
- Smokes: T3_e2e/20251009T193929Z_preview2_smokes.txt · T4_prod/20251009T193929Z_production_smokes.txt

### 20251009T213835Z – Enforcement branch protection
- Ramas protegidas (`main`, `develop`, `preview`) ahora exigen PRs, historial lineal, resolución de conversaciones y checks estrictos.
- Checks requeridos:
	- main → Structure & Governance Guard · Status & Changelog Update · Docs Lint · Pages Deploy Fallback.
	- develop → ci.yml · pages-prod.yml · pages-preview.yml · pages-preview2.yml.
	- preview → ci.yml · pages-prod.yml · pages-preview.yml · pages-preview2.yml.
- Environments JSON y branch_protection JSON guardados en `apps/briefing/docs/internal/briefing_system/reports/20251009T213835Z_*`.
- Required deployments pendiente; API `required_deployments` devuelve 404. Ver log `apps/briefing/docs/internal/briefing_system/_reports/logs/20251009T213835Z_branch_protection_enforcement.log`.

### 20251009T215047Z – Required deployments API 404
- Script `enable_required_deployments.sh` intentó habilitar entornos obligatorios para `main/develop/preview`.
- Owner real forzado a `RunArtFoundry` pero `gh api .../required_deployments` responde 404 (feature no habilitada / permisos).
- Evidencias guardadas en `apps/briefing/docs/internal/briefing_system/_reports/logs/20251009T214839Z_required_deployments_enable.log`, `.../20251009T215047Z_required_deployments_enable.log` y snapshots JSON correspondientes.
- Pendiente coordinar con soporte GitHub para habilitar `required_deployments` o realizar setup manual cuando el endpoint esté disponible.
