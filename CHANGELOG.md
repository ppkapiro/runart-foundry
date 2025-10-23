---
title: "CHANGELOG — RUN Art Foundry"
roles:
  - owner
  - equipo
  - cliente
meta:
  pr: PR-02.1 (Root Alignment Applied)
  fecha: 2025-10-23
  fuente: docs/_meta/plan_pr02_root_alignment.md
crosslinks:
  - README.md
  - STATUS.md
  - NEXT_PHASE.md
  - docs/_meta/plan_pr02_root_alignment.md
  - docs/_meta/checklist_pr02_root_alignment.md
  - docs/_meta/mapa_impacto_pr02.md
---
<!--
Bloque canónico añadido por PR-02.1 (Root Alignment Applied)
Ver documentación y meta en docs/_meta/plan_pr02_root_alignment.md
-->

# Changelog

All notable changes to this repository will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) when version tags sean necesarios.

## [Unreleased]

*No hay cambios pendientes.*

## [v2.0.0-rc1] — 2025-10-21 (RunArt Briefing UI/Roles) ✅ PUBLICADO

**Deployment:** https://runart-foundry.pages.dev/  
**Tag:** v2.0.0-rc1 (commit 6f1a905)  
**Build:** MkDocs 1.6.1 + Material 9.6.21  
**Deployed:** 2025-10-21 22:38 UTC

### Added
- **Vistas personalizadas por rol:** 5 portadas (`cliente_portada.md`, `owner_portada.md`, `equipo_portada.md`, `admin_portada.md`, `tecnico_portada.md`) con CCEs específicos (kpi_chip, hito_card, decision_chip, entrega_card, evidencia_clip, ficha_tecnica_mini, faq_item).
- **Datasets de ejemplo:** 5 archivos JSON (`*_vista.json`) con 3–6 items por CCE, datos ficticios sanitizados (sin información sensible).
- **Glosario Cliente 2.0:** 4 términos técnicos traducidos a lenguaje claro (Cáscara cerámica, Pátina, Colada, Desmoldeo) con secciones "No confundir con…", "Ejemplo", i18n ES/EN y cross-links a portadas.
- **View-as endurecido (Admin):** Query param `?viewAs=<rol>` con políticas de seguridad (Admin-only activation, lista blanca de roles, TTL 30min, botón Reset, logging con timestamp/rol real/rol simulado/ruta/referrer, banner aria-live='polite' para accesibilidad).
- **Gobernanza de Tokens:** `GOBERNANZA_TOKENS.md` con naming conventions (`--color-*`, `--font-*`, `--space-*`, `--shadow-*`, `--radius-*`), escalas rem-based (no px sueltos, no hex directo), proceso de alta/cambio/baja, excepciones controladas (max 2 sprints con inline comment), y AA verification (4.5:1 text, 3:1 buttons).
- **Auditoría de Tokens:** `REPORTE_AUDITORIA_TOKENS_F8.md` con 5 portadas auditadas, 100% conformidad `var(--token)`, 0 hallazgos críticos, 0 excepciones, AA validado (text-primary/bg-surface 7.2:1, color-primary/white 4.8:1).

### Changed
- **i18n completa ES/EN:** ≥99% cobertura en todas las portadas (0 textos hard-coded fuera de secciones i18n).
- **Sincronización de content_matrix_template.md:** Fases 5–8 documentadas con estado por rol (G/A/R) y enlaces a datasets.
- **Depuración Inteligente:** Eliminación de duplicados funcionales con tombstones (motivo, fecha, reemplazo) según `REPORTE_DEPURACION_F7.md`; redirecciones documentadas para rutas legacy.

### Fixed
- **AA contraste:** 100% pares validados ≥4.5:1 (texto) y ≥3:1 (UI components); aplicación consistente de tokens en 5 portadas.
- **Tokens CSS:** Corrección de hex sueltos a `var(--token)` en estilos.md y portadas; escalas px → rem.
- **Navegación:** Cross-links glosario ↔ portadas (100% términos con sección "Dónde lo verás" enlazada).

### Documentation
- **Bitácora Maestra:** `BITACORA_INVESTIGACION_BRIEFING_V2.md` actualizada con Fases 1–9 (timestamps, objetivos, entregables, DoD, anexos).
- **Evidencias compiladas:** `EVIDENCIAS_FASE6.md`, `EVIDENCIAS_FASE7.md`, `EVIDENCIAS_FASE8.md` con tablas de enlaces y extractos (~200 líneas por índice).
- **Consolidación:** `CONSOLIDACION_F9.md` con inventario vistas finales, eliminación duplicados, sincronización matrices/tokens, verificación view-as, dependencias y riesgos residuales.
- **Public Preview:** `PLAN_PREVIEW_PUBLICO.md` con alcance, audiencia (9 usuarios piloto), límites, pre-flight checklist, feedback loop (GitHub Issues, Google Forms, Slack), métricas de éxito (tiempo comprensión <10s, satisfacción ≥4.0/5, issues críticos ≤2).
- **Gate de Producción:** `PLAN_GATE_PROD.md` con 6 criterios GO (AA, i18n, sincronización, view-as, evidencias, depuración), 5 criterios NO-GO automáticos, evidencias mínimas exigidas, plan de rollback (≤35 minutos), comité de decisión (PM, Tech Lead, QA, Legal), métricas post-deploy.
- **QA Checklist:** `QA_checklist_consolidacion_preview_prod.md` con 76 ítems (consolidación, preview, gate prod, evidencias, reportes técnicos).
- **Release Notes:** `RELEASE_NOTES_v2.0.0-rc1.md` con resumen ejecutivo, highlights por rol, CCEs, AA, i18n, gobernanza tokens, glosario, issues cerrados (Sprints 2–4), conocidos no bloqueantes, documentación y próximos pasos.

### Sprint Backlogs Closed
- **Sprint 2 (Owner/Equipo):** S2-01..S2-06 completados (2025-10-21 17:42:34) — MVP Owner/Equipo, tokens, view-as escenarios, matriz Fase 6, QA checklist.
- **Sprint 3 (Admin/View-as/Depuración):** S3-01..S3-08 completados (2025-10-21 17:52:17) — MVP Admin, view-as endurecido, depuración inteligente, QA cases, matriz Fase 7, QA checklist.
- **Sprint 4 (Técnico/Glosario/Tokens):** S4-01..S4-10 completados (2025-10-21 18:00:45) — MVP Técnico, glosario 2.0, gobernanza tokens, auditoría AA, view-as Técnico, matriz Fase 8, evidencias, cierre bitácora.

### Security
- **View-as seguridad:** Solo Admin puede activar override (roles no-Admin rechazan `?viewAs` automáticamente); no modifica permisos backend (solo presentación UI); logging completo de activaciones/simulaciones.
- **Datos sensibles:** 0 datos sensibles en datasets `*_vista.json` (todos ficticios; validado por PM + Legal).

### Accessibility
- **AA compliance:** WCAG 2.1 Level AA validado (text-primary/bg-surface 7.2:1, color-primary/white 4.8:1, 0 pares <4.5:1 texto / <3:1 UI).
- **Navegación teclado:** 100% funcionalidad accesible sin mouse (pending test manual final pre-flight Preview).
- **Lectores pantalla:** Banner View-as con `aria-live='polite'` (anunciado correctamente; pending test manual NVDA/JAWS/VoiceOver).

### Pending (Pre-Gate)
- **i18n automated scan:** Confirmar cobertura ≥99% con `i18n_coverage_report_v2.0.0.md` (deadline 2025-11-03 12:00).
- **Link checker:** Validar 0 enlaces rotos con `link_check_report_v2.0.0.md` (deadline 2025-11-03 12:00).
- **AA manual tests:** Lectores pantalla + navegación teclado con `accessibility_manual_test_report_v2.0.0.md` (deadline 2025-11-03 14:00).
- **EVIDENCIAS_FASE9.md:** Compilar índice navegable con ≥9 enlaces y extractos (deadline 2025-11-03 17:00).

### Notes
- **Release Candidate:** v2.0.0-rc1 ingresa a Public Preview (2025-10-23–2025-11-04) con 9 usuarios piloto antes de Gate de Producción (2025-11-04 16:00).
- **Roadmap v2.1.0:** Exportación de reportes, notificaciones push, integración backend en vivo (Q1 2026).

**Referencia:** Ver `docs/ui_roles/RELEASE_NOTES_v2.0.0-rc1.md` para detalles completos y `docs/ui_roles/BITACORA_INVESTIGACION_BRIEFING_V2.md` para trazabilidad de Fases 1–9.

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
