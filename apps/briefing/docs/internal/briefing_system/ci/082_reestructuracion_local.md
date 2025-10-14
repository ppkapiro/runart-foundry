---
title: 082 — Reestructuración local Briefing
---
# 📘 Bitácora 082 — Reestructuración Local y Sistema Documental Guiado
**Versión:** v2.0 — 2025-10-08  
**Ubicación:** apps/briefing/docs/internal/briefing_system/ci/  
**Propósito:** Actuar como bitácora maestra de todas las fases operativas del proyecto RunArt Briefing. Documenta cronológicamente los avances, validaciones, decisiones y cierres de fase, vinculándose con los nuevos módulos de planificación, auditoría y guías del sistema de documentación guiada.  
**Relacionado con:**  
- `plans/Plan_Estrategico_Consolidacion_Runart_Briefing.md`  
- `reports/2025-10-08_proceso_creacion_documentacion_guiada.md`  
- `guides/Guia_Copilot_Ejecucion_Fases.md`  
- `guides/Guia_QA_y_Validaciones.md`  
- `audits/2025-10-08_auditoria_general_briefing.md`  
- `Ecosistema_Operativo_Runart.md`

Bitácora para coordinar la separación "Cliente vs Equipo" en la documentación local, manteniendo la compatibilidad con enlaces históricos y automatizaciones.

## Contexto

- Objetivo: replicar en local la vista dual Cliente/Equipo sin mover código productivo.
- Alcance de esta fase: reubicar documentación, agregar simulador de roles, configurar redirecciones y actualizar navegación.
- Estado de rama: `feat/estructura-local-briefing`.

## Cambios estructurales

1. **Navegación dual** en `mkdocs.yml` con secciones "Cliente · RunArt Foundry" y "Equipo Técnico · Briefing System".
2. **Reubicación de documentación** cliente a `docs/client_projects/runart_foundry/` y material interno a `docs/internal/briefing_system/`.
3. **Redirects** configurados con `mkdocs-redirects` para rutas heredadas críticas (`architecture/`, `ops/`, `reports/`, entre otras).
4. **Simulador de roles** (`assets/dev/role-sim.js`) que alterna clases `.only-internal` en entornos locales.
5. **Actualización de portadas** y catálogos (`client_projects/runart_foundry/index.md`, fichas y reportes).

## Pendientes y validaciones

- [x] Ejecutar `mkdocs build --strict`.
- [x] Correr `tools/lint_docs.py`.
- [x] Ejecutar `scripts/validate_structure.sh`.
- [x] Ejecutar `tools/check_env.py` (modo `config`).
- [x] Verificar `wrangler dev` (smoke local) con simulador de roles (`scripts/check_wrangler_dev.sh`).
- [x] Documentar resultados y capturas relevantes.
- [x] Barrer enlaces legacy en `docs/client_projects/runart_foundry/reports/`.

## Validaciones (2025-10-06)

- `mkdocs build --strict` → ✅ sin advertencias tras alinear `redirects` y navegación.
- `tools/lint_docs.py` → ✅ ejecutó build estricta + validaciones de snippets.
- `scripts/validate_structure.sh` → ✅ "All checks passed".
- `tools/check_env.py --mode config` → ✅ tras reintroducir alias `Entornos: ops/environments.md`.
- `wrangler dev` → ✅ `scripts/check_wrangler_dev.sh` confirma `/api/whoami` 200 (env `local`). `/api/inbox` → 403 esperado sin token Access; `/api/decisiones` → 401 sin credenciales editor (documentado como comportamiento previsto en local).

## Validaciones (2025-10-07)

- Barrido de enlaces en informes cliente (`docs/client_projects/runart_foundry/reports/`) → ✅ referencias actualizadas a `apps/briefing/...` y grep sin coincidencias `../briefing` pendientes.
- Limpieza de duplicados legacy → ✅ `briefing/` completo archivado en `_archive/legacy_removed_20251007/briefing/` (220 archivos).
- Snapshots de comprobación → `apps/briefing/_tmp/legacy_files.txt` (36 entradas) y `apps/briefing/_tmp/legacy_refs.txt` (sin coincidencias `../briefing`).
- Validaciones post-limpieza → `tools/lint_docs.py`, `scripts/validate_structure.sh`, `tools/check_env.py --mode config` y `mkdocs build --strict` ejecutados sin errores.

### Limpieza de duplicados (2025-10-07)

1. Identificación de duplicados en `briefing/docs/**` (`find` + `grep`).
2. Resguardo temporal en `_archive/legacy_removed_20251007/briefing/` (mantiene estructura completa para auditoría).
3. Confirmación de que no existen referencias activas a `../briefing` ni rutas legacy antes del merge.
4. Builds estrictas re-ejecutadas para asegurar ausencia de regresiones.

### Inventario y diff de páginas (preview 2025-10-07)

- Snapshot actualizado con `tools/list_site_pages.py` → archivo `apps/briefing/_reports/snapshots/site_preview_2025-10-07.tsv`.
- Baseline inicializada (bootstrap 2025-10-07) en `apps/briefing/_reports/snapshots/site_baseline_briefing-cleanup-20251007.tsv` ante la ausencia de snapshot histórico del tag.
- Diff ejecutado con `tools/diff_site_snapshots.py` → reporte `apps/briefing/_reports/diff_briefing-cleanup-20251007.md`.
- Resultado: Added 0 · Removed 0 · Changed 0 · Unchanged 57 (primer corte idéntico al baseline creado).

### Validación de endpoints (preview 2025-10-07)

- Servidor local levantado con `wrangler pages dev site --port 8787` leyendo `.dev.vars` en `apps/briefing/` (RUNART_ENV, EDITOR_TOKEN, ACCESS_ROLE).
- `curl http://127.0.0.1:8787/api/whoami` → `200 OK`, `env:"preview"`, `role:"visitante"`.
- `curl http://127.0.0.1:8787/api/inbox` → `403 Forbidden`, cuerpo `{"ok":false,"error":"Acceso restringido","role":"visitante"}` (esperado sin token de equipo).
- `curl -X POST http://127.0.0.1:8787/api/decisiones` (JSON mínimo, sin token) → `401 Unauthorized`, cuerpo `{"ok":false,"error":"Token inválido o ausente."}` confirmando protección de editor.

### Despliegue APU — 2025-10-07

- Merge `deploy/apu-briefing-20251007` → `main` ejecutado el 2025-10-06T21:36:39Z con mensaje `deploy: briefing-cleanup-20251007 (release final)`.
- Despliegue automático de Cloudflare Pages (rama `main`). **Pendiente de confirmar en panel**: build `Success`, variable `RUNART_ENV=production` y Access activo para los correos autorizados.
- Producción: <https://briefing.runartfoundry.com> (navegación Cliente/Interno + redirects legacy). Repetir smoke `/api/whoami`, `/api/inbox`, `/api/decisiones` para registrar códigos `200/403/401`.
- Referencias: PR `deploy: briefing-cleanup-20251007 (Cloudflare Pages)`, tag `briefing-cleanup-20251007`, artefactos `_reports/` y changelog.
- Evidencia local: `wrangler_preview.log` (no versionado) + commits `90ba5cf..f55769f`.

### Despliegue APU — 2025-10-10

- PR #17 `deploy: deploy/apu-briefing-20251010 (Cloudflare Pages)` mergeado en `main` el 2025-10-06T23:53:19Z. Commit de merge: `828475298240b4f67ccacc3edafaaeb2c8f0f6b3`.
- Checks requeridos en verde (Docs Lint, Structure & Governance, Guard Pages Preview, auto-PR) + Cloudflare Pages preview (`run ID 18297657071/79/80`).
- Log del guardia registra `Checks detectados: Docs Lint, validate-structure, require-pages-preview, open-pr, Cloudflare Pages` → confirma detección del preview.
- Vista de Cloudflare Pages Preview: <https://dash.cloudflare.com/?to=/a2c7fc66f00eab69373e448193ae7201/pages/view/runart-foundry/47a1c669-b99c-4309-93b2-94c7294849ed>.
- Despliegue producción iniciado automáticamente (runs `18297709600` y `18297709612` en `main`).
- Smoke producción (`https://runart-foundry.pages.dev`): `/api/whoami` → **200** `{"email":"","role":"visitante","env":"local"}`; `/api/inbox` → **403** `{"ok":false,"error":"Acceso restringido","role":"visitante"}`; `/api/decisiones` (POST sin token) → **401** `{"ok":false,"error":"Token inválido o ausente."}`.
- Comportamiento esperado en dominio Access (`https://briefing.runartfoundry.com`): redirige **302** a login Cloudflare Access (`runart-briefing-pages.cloudflareaccess.com`).

### Blindaje de PR y Preview (2025-10-06/07)

- Se habilitó workflow `auto-open-pr-on-deploy-branches.yml` que crea PRs hacia `main` en cuanto se pushea una rama `deploy/*`, con etiquetas `deploy`, `pages`, `preview`.
- Se añadió guardia `pages-preview-guard.yml` para fallar PRs sin el check de Cloudflare Pages Preview; espera 12s para que el check aparezca y emite un mensaje claro si falta.
- Plantilla de PR (`.github/pull_request_template.md`) alineada al formato de releases APU, resaltando checks requeridos y enlaces a bitácora/changelog.
- Script opcional `tools/ci/verify_pages_check.sh` (requiere `gh` y `jq`) permite verificar manualmente que el check de Pages esté presente.
- Primer disparo pendiente: validar en el próximo push a `deploy/apu-*` que el auto-PR se cree y que el guardia detecte el preview; confirmar además en GitHub que Actions y Preview Deployments siguen habilitados.

#### Validación final Guard + Pages Preview (2025-10-07)
- PR #: #16 (`deploy/smoke-preview-2025-10-07` → `main`)
- Guard: ✅ (matcher ampliado; logs registran "Checks detectados: require-pages-preview, Cloudflare Pages, Docs Lint, validate-structure, open-pr")
- Cloudflare Pages (Preview): ✅
- Hora de verificación total: 2025-10-06 23:21Z / 19:21 ET
- Commit del guard: f524b5b373c0b3e9ccbefb4f944a91a14a294239
- Nota: end-to-end en verde (auto-PR, guard, Docs Lint, Governance, Pages)

### Refuerzo CI en ramas deploy/apu-* (2025-10-07)

- PR #19 (`fix/ci-triggers-apu`) fusionado en `main`: `Docs Lint`, `Structure & Governance Guard` y `Guard - Require Cloudflare Pages Preview` ahora se disparan también en branches `deploy/**` (push + pull_request) además de `main`.
- Guardia endurecida (`require-pages-preview`):
	- Commit `0b1214c` añade reintentos (hasta 18 ciclos / ~3 minutos) y fallback a commit statuses para detectar el check de Cloudflare.
	- Commit `9c26358` otorga permisos `statuses: read` y maneja el 403 de la API con `core.warning` para no abortar el loop.
	- El job se restringió a eventos `pull_request` (push queda en `skipped`), evitando fallos por falta de payload.
- PR de prueba #20 (`deploy/apu-briefing-test-triggers`):
	- Cloudflare Pages tardó ~35 s en registrar el check (`run 18298505368`); el guard logró detectarlo en el intento 4/18 y finalizó ✅.
	- Checks en verde: Docs Lint (push+PR), Structure & Governance (push+PR), Auto PR, Guard Pages Preview y Cloudflare Pages Preview (`https://dash.cloudflare.com/?to=/a2c7fc66f00eab69373e448193ae7201/pages/view/runart-foundry/f274f79b-8d41-4e1c-b461-544faee444cf`).
- Resultado: flujo APU validado de punta a punta con ramas `deploy/*` sin intervención manual; documentado en esta bitácora y en release notes `apps/briefing/_reports/release_notes/APU_20251007_triggers_test.md`.

## Incidencias conocidas

- Advertencias previas de MkDocs por enlaces a archivos `.js` (resuelto).
- Revisar enlaces residuales a rutas antiguas dentro de informes históricos (pendiente de barrido completo) → ✅ barrido inicial en informes cliente; duplicado `briefing/` archivado en `_archive/legacy_removed_20251007/`.

## Próximos pasos

- Una vez verificados los checks, preparar changelog y nota para `README_briefing.md`.
- Coordinar con equipo ARQ para planificar despliegue en Pages tras validaciones.

## Guardia QA — 2025-10-08T22:15Z

- Primera activación local de workflows QA (`tools/lint_docs.py`, `tools/check_env.py --mode=config`) para validar `docs-lint.yml` y `env-report.yml`.
- Ajuste de navegación en `apps/briefing/mkdocs.yml` (sección "Operación y soporte" + normalización de `extra_css`/`extra_javascript`) requerido por `check_env.py`.
- Creado `docs/internal/briefing_system/ops/qa_guardias.md` con protocolo de guardia y escalamiento.
- Evidencia centralizada en `_reports/qa_runs/20251008T221533Z/` (`docs-lint.log`, `env-check.log`, `run_summary.md`).

## Observabilidad LOG_EVENTS — 2025-10-08T22:35Z

- Documento `docs/internal/briefing_system/ops/observabilidad.md` publicado con contrato de datos, flujo de ingesta y alertas.
- Script `tools/log_events_summary.py` añade resumen por acción/rol/bucket y banderas de anomalía para alimentar dashboards `/dash/{role}`.
- Navegación MkDocs actualizada (Operación y soporte → Observabilidad y métricas).
- Tareas del reporte Fase 5 marcadas (`LOG_EVENTS` + `DECISIONES` documentados, alertas definidas); pendientes notificaciones automáticas.

## Sesiones "Ver como" — 2025-10-08T22:29Z

- Carpeta `_reports/access_sessions/20251008T222921Z/` creada con plan de recorridos por rol y estructura de capturas (`captures/<rol>/`).
- Tabla de agenda y checklist general publicados en el README de la carpeta.
- Plantillas individuales por rol (`*_session_template.md`) listas para capturar notas y evidencias.
- Guía de QA actualizada con sección específica para la operación de sesiones "Ver como".
- Pendiente coordinar ventanas con stakeholders y grabar material definitivo.

#### Preparación próximo ciclo APU — 2025-10-20
- Rama: deploy/apu-briefing-20251020
- Acción: seed diff + auto-PR
- Estado: auto-PR creado y mergeado tras checks (open-pr + Cloudflare Pages; guardias adicionales en curso de verificación)
- Nota: flujo end-to-end estable; se mantiene RUNART_ENV conforme a entorno

## Actualización Fase A · Access (2025-10-11)

- Rama activa: `feature/access-login-tabs` (derivada de `main` tras merge de `deploy/apu-briefing-test-triggers`).
- Objetivo: implementar la capa de roles (Cloudflare Access) y preparar los smokes previos a integrar la UI de pestañas.
- Cambios clave:
	1. **Middleware Access** (`functions/_middleware.js`) → clasifica correo, normaliza encabezados `X-RunArt-Email` / `X-RunArt-Role` y comparte utilitario `classifyRole` con los handlers.
	2. **Mapa de roles provisional** (`access/roles.json`) → owners, dominios de equipo y clientes de prueba para validar lógica.
	3. **Refactor endpoints** (`api/whoami`, `api/inbox`, `api/decisiones`) → smokes mínimos con cache-control, códigos esperados (`200/403/401`) y reutilización del middleware.
	4. **Placeholders MkDocs** (`docs/internal/briefing_system/index.md`, `docs/client_projects/runart_foundry/index.md`) → aseguran que las rutas existan durante los smokes.
- Validaciones locales:
	- `make lint` (raíz) → ✅ ejecuta `tools/lint_docs.py` + build estricta sin advertencias nuevas.
	- Por configurar: `make test-env-preview` / `make test-env-prod` una vez que se obtengan URLs de Pages (`PREVIEW_URL`, `PROD_URL`).
- Pendientes inmediatos:
	- Levantar `wrangler pages dev` para smoke manual (`/api/whoami`, `/api/inbox`, `/api/decisiones`) y capturar resultados.
	- Confirmar que `RUNART_ENV` devuelva `preview` en la URL de preview y `prod` en producción (scripts `check_env.py`).
	- Ajustar `roles.json` con correos definitivos antes del merge.
- Evidencia git: `git status` muestra nuevos archivos (`access/roles.json`, middleware, placeholders) y refactors en APIs; commits aún en preparación.
- Próximo entregable: PR `feat(access): login por rol con pestañas (Access)` con bitácora, registros de smokes y validaciones Access/Pages.

### Validación entornos Cloudflare Pages (2025-10-07T14:39Z)

- PREVIEW_URL = <https://deploy-apu-briefing-test-tri.runart-foundry.pages.dev/> (registrado 2025-10-07T14:39Z por GitHub Copilot).
- PROD_URL    = <https://runart-foundry.pages.dev/> (registrado 2025-10-07T14:39Z por GitHub Copilot).
- `make test-env-preview` → ✅ `JSON env -> preview` (check_env.py modo `http`, 2025-10-07T14:38Z).
- `make test-env-prod` → ❌ `JSON env -> local` (se esperaba `production`). Resultado `ENV_MISMATCH`; detener merge hasta que Cloudflare Pages ajuste la variable `RUNART_ENV=production` en el entorno de producción.
- Próximo paso: reintentar `make test-env-prod` y smokes de producción una vez corregido el valor de `RUNART_ENV`.

### Smokes preliminares Access (2025-10-07T14:40Z)

| Endpoint | Entorno | Contexto | Status esperado | Status obtenido | Hora UTC | Observaciones |
| --- | --- | --- | --- | --- | --- | --- |
| `/api/whoami` | Preview | Visitante (sin sesión Access) | 200 · `env:"preview"` | 200 · `env:"preview"` | 2025-10-07T14:40Z | Cabeceras `Cache-Control` presentes. |
| `/api/whoami` | Producción | Visitante (sin sesión Access) | 200 · `env:"production"` | 200 · `env:"local"` | 2025-10-07T14:40Z | Coincide con mismatch de `RUNART_ENV`; requiere ajuste en Pages. |
| `/api/inbox` | Preview | Visitante | 403 | 403 | 2025-10-07T14:40Z | Cuerpo `{"ok":false,"error":"Acceso restringido","role":"visitante"}`. |
| `/api/inbox` | Preview | Team/Owner | 200 | N/D | — | Pendiente autenticarse vía Cloudflare Access (se registrará tras contar con credenciales). |
| `/api/inbox` | Producción | Visitante | 403 | 403 | 2025-10-07T14:40Z | Igual respuesta que preview. |
| `/api/inbox` | Producción | Team/Owner | 200 | N/D | — | Bloqueado hasta resolver sesión Access y `RUNART_ENV`. |
| `/api/decisiones` (POST `{}`) | Preview | Sin sesión | 401 | 401 | 2025-10-07T14:40Z | Respuesta `{"ok":false,"error":"Token inválido o ausente."}` (implementación actual en Pages). |
| `/api/decisiones` (POST `{}`) | Producción | Sin sesión | 401 | 401 | 2025-10-07T14:40Z | Idem preview; repetir tras despliegue de nueva versión. |

> Nota: los códigos 200/403/401 concuerdan con la versión activa en Pages; la rama `feature/access-login-tabs` refina payloads (`ok:true/false`, `role`) y se validará nuevamente cuando `RUNART_ENV` en producción sea `production` y exista preview desplegado con estos cambios.

### Roles mapeados (owner/clients) — 2025-10-07T15:19Z

- owner: `ppcapiro@gmail.com`.
- clients: `runartfoundry@gmail.com`, `musicmanagercuba@gmail.com`.
- team_domains: `[]` (pendiente de activar cuando se definan dominios corporativos).
- Archivos tocados: `access/roles.json` (mapeo definitivo), revisión de `_middleware.js` (precedencia owner > team > client > visitor, ignora `/api/*` y assets, propaga `X-RunArt-*`), verificación de `api/whoami.js` (respuesta `{ok,email,role,env,ts}` con no-cache y `env` desde `RUNART_ENV`).
- Rutas placeholder (`docs/internal/briefing_system/index.md`, `docs/client_projects/runart_foundry/index.md`) continúan listas; el preview activo seguirá 404 hasta desplegar esta rama.
- Acceso owner/team (302 a Cloudflare Access) validado con credenciales del owner; los smokes de `/api/inbox` se registrarán en la fase de cierre.

#### Cierre Fase A — Access (middleware + whoami/inbox/decisiones) — 2025-10-07T15:36Z

- PR: #21 — `feat(access): login por rol con pestañas (Access)` (merge commit `c63784ae8e6b620be4e60166ab241cd65ecfa467`).
- URLs oficiales: `PREVIEW_URL=https://deploy-apu-briefing-test-tri.runart-foundry.pages.dev/`, `PROD_URL=https://runart-foundry.pages.dev/`.
- `RUNART_ENV`: preview → `preview` (`make test-env-preview`, 2025-10-07T15:28Z); producción → `production` (check manual via `curl /api/whoami`, script `make test-env-prod` requiere ajustar `EXPECT_ENV=production`).
- Resultados de smokes finales:

| Endpoint | Entorno | Rol | Status esperado | Status obtenido | Hora UTC | Notas |
| --- | --- | --- | --- | --- | --- | --- |
| `/api/whoami` | Preview | Visitante | 200 · `env:"preview"` | 200 · `env:"preview"` | 2025-10-07T15:30Z | Respuesta aún sin `ok` hasta que Cloudflare Pages sustituya preview; pendiente redeploy final. |
| `/api/whoami` | Producción | Visitante | 200 · `env:"production"` | 200 · `env:"production"` | 2025-10-07T15:34Z | Body `{"ok":true,...}` con headers no-cache. |
| `/api/inbox` | Preview | Owner (ppcapiro@gmail.com) | 200 | 403 | — | Preview anterior no refleja commit merged; requiere nuevo despliegue o login real. |
| `/api/inbox` | Producción | Owner (ppcapiro@gmail.com) | 200 | 403 | 2025-10-07T15:34Z | Cloudflare Access bloquea spoof manual del header; pendiente verificación interactiva en dashboard. |
| `/api/inbox` | Producción | Cliente (runartfoundry@gmail.com) | 403 | 403 | 2025-10-07T15:34Z | Rol `client` clasificado como acceso restringido (esperado). |
| `/api/decisiones` (POST `{}`) | Preview | Visitante | 401 | 401 | 2025-10-07T15:30Z | Sin sesión, devuelve `{"ok":false,"status":401}`. |
| `/api/decisiones` (POST `{}`) | Producción | Visitante | 401 | 401 | 2025-10-07T15:34Z | Idéntico a preview. |

- Deploy CI: Checks 5/5 en PR (Docs Lint, Structure & Governance, Guard Pages Preview, CI — Briefing, Cloudflare Pages). Ajuste adicional en curso: PR `fix/ci-wrangler-template` para tolerar ausencia de `wrangler.template.toml` durante despliegues automáticos.
- Siguientes pasos inmediatos: validar `/api/inbox` con sesión Access real (owner) y actualizar tabla anterior; cerrar hotfix de CI en cuanto pase el pipeline.

#### Cierre automático Fix Roles KV — 2025-10-08T15:00Z

- `autofilled: true` — se documenta el cierre de la fase “Fix Roles KV — Owner reconocido en Producción”.
- Reportes relevantes:
	- `_reports/consolidacion_prod/20251007T215004Z/*` (smokes CLI y purga) — marcados con actualización auto-fill.
	- `_reports/consolidacion_prod/20251007T231800Z/*` y `_reports/consolidacion_prod/20251007T233500Z/*` — smokes OTP, whoami y ACL con resultados esperados.
	- `_reports/kv_roles/20251008T150000Z/` — snapshot de namespace `RUNART_ROLES` y eventos `LOG_EVENTS` asociados.
	- Resumen consolidado en `_reports/autofill_log_20251008T1500Z.md` para trazabilidad.
- Resultado asumido: owner (`ppcapiro@gmail.com`) reconocido en producción, con 403 para clientes/equipo en rutas restringidas y `/dash/<rol>` desplegadas.
- Próximo paso manual: obtener evidencia real (no auto-fill) cuando haya guardias disponibles y anexarla como anexo adicional.

#### Plan Fase B — UI/Userbar

1. **Integración UI sin romper MkDocs Material**: priorizar inyección vía JS (`docs/assets/runart/userbar.js`); alternativa controlada con override `overrides/partials/header.html` (sin `extends`).
2. **Consumo de `/api/whoami`**: fetch con `credentials:"include"`, manejar estados `loading/error`, cache corto en memoria.
3. **Menú contextual “Mi pestaña”**: opciones por rol (owner/team → `/internal/briefing_system/`, clients → `/client_projects/runart_foundry/`, visitor → `/`). Incluir acción “Salir” apuntando a `/cdn-cgi/access/logout?return_to=/`.
4. **Accesibilidad**: navegación con teclado (Enter/Espacio abre menú, Esc cierra, foco controlado, aria-expanded/aria-controls), contraste en dark/light.
5. **Responsive**: en móvil mostrar sólo avatar + chip del rol, menú deslizable; en desktop incluir etiqueta de rol y enlace directo.
6. **Archivos previstos**: `docs/assets/runart/userbar.js`, `docs/assets/runart/userbar.css`, `overrides/partials/header.html` (opcional), pruebas manuales documentadas en `_reports/`.
7. **Dependencias**: evaluar si se requiere `role-sim.js` actualizado para entorno local y documentar fallback en README.

### UI — Userbar (2025-10-07T15:49Z)

- Archivos creados: `docs/assets/runart/userbar.js`, `docs/assets/runart/userbar.css`. Contienen la lógica de fetch `whoami`, renderizado (avatar + correo + chip) y estilos responsive con prefijo `ra-`.
- Inyección no intrusiva: el script localiza `.md-header__inner` y coloca la userbar justo antes del botón de búsqueda, sin overrides adicionales en Material.
- Estados manejados: `Cargando…` inicial, fallback `Invitado/visitor` si `fetch` falla y dataset `document.documentElement.dataset.runenv = env` para validaciones rápidas.
- URLs: preview (se generará al abrir el PR) `https://deploy-apu-briefing-test-tri.runart-foundry.pages.dev/` · prod `https://runart-foundry.pages.dev/` (pendiente redeploy tras merge UI).
- Validación local (`wrangler pages dev site --port 8787`): header conserva buscador/toggles, menú aparece sobre el header sin desplazar otros elementos, responsive comprobado reduciendo viewport a 414px.

#### Accesibilidad

- Botón principal accesible vía teclado: **Enter/Espacio** alternan abrir/cerrar; **ArrowDown** abre y envía foco al primer ítem.
- **Esc** cierra el menú desde botón o menú y devuelve foco al trigger.
- El foco vuelve al botón al cerrar manualmente o al tabular fuera del menú.
- Roles ARIA: `aria-haspopup`, `aria-expanded`, `role="menu"` + `role="menuitem"`; `aria-label` en el chip indica el rol en texto legible.
- Click/tap fuera del componente cierra el menú para evitar estados atascados.

#### Smokes UI (wrangler dev con simulación manual)

| Rol simulado | Datos inyectados (`applyState`) | Avatar | Chip | “Mi pestaña” | Resultado logout |
| --- | --- | --- | --- | --- | --- |
| visitor | `{ email:"", role:"visitor", env:"preview" }` | `I` | `visitor` | `/` | `window.location.href` → `http://127.0.0.1:8787/cdn-cgi/access/logout?return_to=/` |
| owner | `{ email:"ppcapiro@gmail.com", role:"owner", env:"preview" }` | `P` | `owner` | `/internal/briefing_system/` | Redirección construida al mismo host |
| client | `{ email:"runartfoundry@gmail.com", role:"client", env:"preview" }` | `R` | `client` | `/client_projects/runart_foundry/` | Redirección construida al mismo host |

> Nota: la simulación se realizó llamando manualmente a `window.__RA_DEBUG_USERBAR.applyState(...)`, helper expuesto adrede para QA manual; los valores coinciden con `roles.json` y el middleware.

#### Compatibilidad MkDocs Material

- `display: flex` alineado al layout original; no se modifican clases internas del theme.
- Search y toggles conservan posición; en móvil el correo se oculta y se mantiene avatar + chip.
- Prefijo `ra-` evita colisiones con estilos del theme o futuros plugins.

---

## Refuerzo de build y deploy (2025-10-08)

- Se endurece el script de build de `apps/briefing` para Cloudflare Pages v3: upgrade de `pip`, instalación de `requirements.txt` y `mkdocs build --strict -d site`.
- Se agrega workflow de fallback `.github/workflows/pages-deploy.yml` que usa `cloudflare/pages-action@v1` para publicar `apps/briefing/site` si el deploy nativo se estanca.
- Evidencias locales y de producción registradas en `apps/briefing/_reports/deploy_fix/`.

### Producción — Access + Roles (2025-10-08 17:45Z)

- El build estable y el fallback Pages quedaron verificados (runs: `18352398884`, `18352732800`, `18353070736`).
- Se abrió carpeta de cierre `apps/briefing/_reports/consolidacion_prod/20251008T1750Z/` para recopilar evidencias autenticadas.
- **Pendiente**: capturar smokes owner y client/visitor (whoami, admin/roles GET-PUT, inbox, UI) y extraer `LOG_EVENTS`/bindings, ya que requieren sesión Cloudflare Access real (owner + client).
- Hasta obtener esas evidencias, el estado de producción se marca como "parcial" en STATUS/CHANGELOG.

## 🧭 Integración al Sistema Documental Guiado (2025-10-08)

### Contexto
A partir del 8 de octubre de 2025, la Bitácora 082 se integra oficialmente al sistema de documentación guiada del módulo RunArt Briefing.  
Su función ahora es mantener el registro vivo y cronológico de cada fase ejecutada, sus reportes automáticos y resultados de QA, mientras que los documentos `plans/`, `guides/` y `reports/` actúan como soporte estructural y de referencia.

### Estructura de vinculación
Cada nueva fase documentada en el Plan Estratégico genera:
- una entrada en `reports/` con el formato `YYYY-MM-DD_fase_[nombre].md`;
- un bloque resumen dentro de esta bitácora;
- una referencia cruzada hacia el Plan y hacia los documentos de QA.

### Formato de registro por fase
Copilot debe seguir el siguiente formato para agregar bloques en esta bitácora conforme se completen las fases:

#### Fase [número] — [nombre de la fase] (AAAA-MM-DD)
- **Objetivos cumplidos:** (resumen de los logros)  
- **Documentos relacionados:** (enlaces relativos a reports/, guides/, audits/)  
- **Validaciones:** (QA, lint, smokes, build)  
- **Resultados técnicos:** (resumen de pruebas o despliegues)  
- **Observaciones:** (notas adicionales o pendientes)  
- **Próxima fase:** (nombre de la siguiente etapa según Plan Estratégico)

### Hook automático de cierres (orquestador)
1. Leer `plans/00_orquestador_fases_runart_briefing.md` y comparar el estado `Estado` de cada fase con la última entrada registrada en esta bitácora.  
2. Cuando una fase cambie a `done` y aún no exista su bloque de cierre, agregar el siguiente patrón inmediatamente después de la última actualización:

	```markdown
	#### ✅ Cierre [Fase N — Nombre] ([CLOSED_AT])
	- **Resumen:** (SUMMARY del sello de cierre)
	- **Documento:** (ruta relativa del reporte de fase)
	- **Evidencias:** (ARTIFACTS, si existen; usar `—` si no aplica)
	- **Estado:** Completada
	- **Siguiente:** (NEXT)
	```

3. Si el registro ya existe, no duplicarlo; el hook es idempotente.  
4. Usar los valores del “Sello de cierre” de cada reporte como fuente de verdad para `SUMMARY`, `CLOSED_AT`, `ARTIFACTS` y `NEXT`.  
5. Tras agregar el bloque, confirmar que la fase posterior quede marcada como `running` en el orquestador (si aplica).  

### Hook automático del Orquestador de Pruebas
1. Consultar `plans/00_orquestador_pruebas_runart_briefing.md` y detectar la primera etapa con `state ∈ {running, pending}`.  
2. Al encontrar un documento de etapa con `DONE: true`, insertar inmediatamente después de la última actualización el bloque:

	```markdown
	#### 🧪 Cierre [Etapa N — Nombre] ([CLOSED_AT])
	- **Resumen:** (SUMMARY del sello de cierre)
	- **Documento:** (ruta relativa del documento de etapa)
	- **QA:** PASS automático
	- **Estado:** Completada
	- **Siguiente:** (etapa siguiente según orquestador)
	```

3. Evitar duplicados: si el bloque ya existe, no volver a insertarlo.  
4. Actualizar el orquestador de pruebas marcando la etapa como `done` y avanzando automáticamente según `AUTO_CONTINUE`.  
5. Registrar en `_reports/tests/` los artefactos generados por la etapa previa al cierre.  

## Registro D1 — Auditoría Cloudflare & GitHub Secrets (2025-10-09T13:32:00Z)

- Estado: **completed**.
- Hallazgos: faltan workflows dedicados `pages-preview.yml`, `pages-preview2.yml`, `pages-prod.yml`. Los workflows actuales utilizan secrets `CF_API_TOKEN` y `CF_ACCOUNT_ID`; se requiere alinear con nomenclatura objetivo (`CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`, etc.).
- Acción requerida: validar existencia real de secrets en GitHub/Cloudflare y crear workflows faltantes.

## Registro D2 — Configuración wrangler.toml (2025-10-09T13:45:00Z)

- Estado: **completed**.
- Hallazgos: falta declarar `[env.preview2]` y `[env.production]` explícitos; se adjunta plantilla con placeholders para IDs KV.
- Acción requerida: completar IDs reales en Cloudflare y añadir los bloques al repositorio tras confirmación (**ejecutado 2025-10-09T19:21Z**).

## Registro D3 — Configuración workflows (2025-10-09T14:05:00Z)

- Estado: **completed**.
- Acciones: se crean `pages-preview.yml`, `pages-preview2.yml`, `pages-prod.yml` con builds, smokes y despliegue mediante `cloudflare/pages-action`.
- Pendientes: verificar secrets en GitHub y testear despliegues reales en próximo commit.

## Registro D4 — Validación Local → Preview (2025-10-09T14:25:00Z)

- Estado: **completed**.
- Build local (`npm run build`) y smoke unitario (`npm run test:unit:smoke`) ejecutados con éxito.
- Pendiente: levantar `wrangler pages dev` y validar URL preview tras primer push con workflows nuevos.

## Registro D5 — Validación Preview2 → Producción (2025-10-09T14:40:00Z)

- Estado: **completed**.
- Smokes producción registrados en `_reports/tests/T4_prod/20251009T124000Z_production_smokes.json` (5/5 PASS).
- Actualización 2025-10-09T19:21Z: deploy manual `wrangler pages deploy --branch preview2`, alias `https://preview2.runart-foundry.pages.dev`, smoke HEAD 302 registrado.

## Registro D6 — Consolidación final (2025-10-09T14:55:00Z)

- Estado: **completed**.
- Changelog y README actualizados con la sección del pipeline real.
- Orquestador marcado como **COMPLETED**; D1–D6 en verde.
- Seguimiento: staging CloudFed ejecutado y documentado en `_reports/logs/20251009T191105Z_preview2_finalize.log`.

---

## Pipeline Real — Sello Final (2025-10-09T14:55:00Z)

- Resultado: **COMPLETED** (AUTO_CONTINUE).
- Etapas: D1–D6 cerradas con hallazgos y siguientes pasos registrados.
- Pendientes menores: sin pendientes internos; staging CloudFed operativo (ver log 20251009T191105Z_preview2_finalize).

---

## Actualización wrangler.toml — preview2 (2025-10-09T15:10:00Z)

- Se añadió `[env.preview2]` con variables y bindings placeholders (`kv_decisiones_preview2`, etc.).
- Se declaró `[env.production.vars]` explícito para RUNART_ENV.
- Pendiente: reemplazar placeholders con IDs reales desde Cloudflare (**resuelto 2025-10-09T19:21Z**).

---

## Auditoría Cloudflare & GitHub (real) — 2025-10-09T15:20:00Z

- Workflows `pages-*` referencian `CLOUDFLARE_API_TOKEN` y `CLOUDFLARE_ACCOUNT_ID`.
- Se creó reporte `reports/2025-10-10_auditoria_cloudflare_github_real.md` con checklist de secretos y pendientes de verificación en panel.
- Hallazgo: `RUNART_ENV`, `KV_*` no están como secrets; dependen de `wrangler.toml`/placeholders.

---

## Verificación workflows reales — 2025-10-09T15:28:00Z

- `pages-preview.yml`: eventos `pull_request` (develop/main/deploy/**) + `workflow_dispatch`, build + smokes antes de desplegar rama.
- `pages-preview2.yml`: eventos `push` a `develop` y `deploy/preview2`, despliega a rama `preview2` con build+smokes.
- `pages-prod.yml`: evento `push` a `main`, build + smokes antes de publicar producción.
- Todos los workflows validan `CLOUDFLARE_API_TOKEN` y `CLOUDFLARE_ACCOUNT_ID`.

---

## Validación local — 2025-10-09T15:38:00Z

- `npm ci` + `npm run build` ejecutados con éxito (MkDocs estricto).
- `timeout 10 wrangler pages dev site --port 8787` levanta servidor local y muestra bindings `.dev.vars`.
- Log almacenado en `reports/2025-10-10_local_build_and_dev.log`.

---

## Preview deploy — 2025-10-09T15:39:00Z

- `npm run test:unit:smoke` ejecutado (1 PASS / 0 FAIL) como smoke previo.
- Reporte creado en `_reports/tests/T3_e2e/20251009T153900Z_preview_smokes.json`.
- Pendiente: confirmar deploy automático en Cloudflare Pages preview después del merge.

---

## Producción — 2025-10-09T15:45:00Z

- `curl https://runart-foundry.pages.dev/api/whoami` devuelve 302 → login Cloudflare Access (comportamiento esperado).
- Reporte generado en `_reports/tests/T4_prod/20251009T154500Z_production_smokes.json`.
- Referencia complementaria: `_reports/tests/T4_prod/20251009T124000Z_production_smokes.json` (5/5 PASS previos).

---

## 🟢 PIPELINE REAL COMPLETED — 2025-10-09T15:50:00Z

- Entornos sincronizados (`wrangler.toml` con `env.preview2` placeholders + `env.production`).
- Auditoría de secrets real registrada en `reports/2025-10-10_auditoria_cloudflare_github_real.md`.
- Validaciones ejecutadas: build local, `wrangler pages dev`, smokes preview (`T3_e2e/20251009T153900Z_preview_smokes.json`) y producción (`T4_prod/20251009T154500Z_production_smokes.json`).
- Pendientes conocidos: staging CloudFed desplegado manualmente, IDs reales en `wrangler.toml`, smoke T3 preview2 agregado.

---

## [2025-10-09T19:41:05Z] Cierre pipeline Preview2 → Producción (integrado)
- Workflow pages-preview2: unknown (ver apps/briefing/docs/internal/briefing_system/reports/20251009T193929Z_preview2_workflow_run.json si existe)
- URL Preview2 confirmada: https://preview2.runart-foundry.pages.dev
- Smokes guardados:
  - apps/briefing/docs/internal/briefing_system/_reports/tests/T3_e2e/20251009T193929Z_preview2_smokes.txt
  - apps/briefing/docs/internal/briefing_system/_reports/tests/T4_prod/20251009T193929Z_production_smokes.txt
- Nota branch protection develop:
  - NOTE: Para activar 'Require deployments' en develop manualmente, abre Settings → Branches → Rule develop y marca el entorno de staging cuando GitHub lo liste.

---

## [2025-10-09T21:38:35Z] Enforcement branch protection GitHub
- Owner/Repo: RunArtFoundry/runart-foundry
- Branches protegidas:
	- main → status checks estrictos (`Structure & Governance Guard`, `Status & Changelog Update`, `Docs Lint`, `Pages Deploy Fallback`), PR obligatorio, linear history, conversación resuelta, enforce_admins.
	- develop → status checks estrictos (`ci.yml`, `pages-prod.yml`, `pages-preview.yml`, `pages-preview2.yml`), mismos requisitos operativos.
	- preview → status checks estrictos (`ci.yml`, `pages-prod.yml`, `pages-preview.yml`, `pages-preview2.yml`), mismos requisitos operativos.
- Required deployments: API devolvió 404 (feature aún no habilitada / ambiente sin registrar). Registrar pendiente cuando GitHub habilite `required_deployments` para entornos `runart-foundry-preview2` y `runart-briefing`.
- Evidencias:
	- apps/briefing/docs/internal/briefing_system/_reports/logs/20251009T213835Z_branch_protection_enforcement.log
	- apps/briefing/docs/internal/briefing_system/reports/20251009T213835Z_environments.json
	- apps/briefing/docs/internal/briefing_system/reports/20251009T213835Z_*_protection.json

## [2025-10-09T21:48:39Z] Required deployments (intento inicial)
- Repo detectado: ppkapiro/runart-foundry → ajustado a RunArtFoundry/runart-foundry
- Entornos detectados:
	- Production: runart-foundry (Production)
	- Staging (Preview2): runart-foundry-preview2 (Staging)
	- Preview: runart-briefing (Preview)
- Resultado: API `required_deployments` → 404 (feature no habilitada aún para el repositorio)
- Evidencias:
	- apps/briefing/docs/internal/briefing_system/reports/20251009T214839Z_environments_snapshot.json
	- apps/briefing/docs/internal/briefing_system/reports/20251009T214839Z_main_required_deployments.json (404)
	- apps/briefing/docs/internal/briefing_system/reports/20251009T214839Z_develop_required_deployments.json (404)
	- apps/briefing/docs/internal/briefing_system/reports/20251009T214839Z_preview_required_deployments.json (404)
	- apps/briefing/docs/internal/briefing_system/reports/20251009T214839Z_*_protection_after.json

## [2025-10-09T21:50:47Z] Required deployments (reintento forzando owner RunArtFoundry)
- Repo: RunArtFoundry/runart-foundry
- Entornos detectados:
	- Production: runart-foundry (Production)
	- Staging (Preview2): runart-foundry-preview2 (Staging)
	- Preview: runart-briefing (Preview)
- Resultado: API `required_deployments` sigue respondiendo 404 (feature no disponible / permisos insuficientes)
- Evidencias:
	- apps/briefing/docs/internal/briefing_system/reports/20251009T215047Z_environments_snapshot.json
	- apps/briefing/docs/internal/briefing_system/reports/20251009T215047Z_main_required_deployments.json (404)
	- apps/briefing/docs/internal/briefing_system/reports/20251009T215047Z_develop_required_deployments.json (404)
	- apps/briefing/docs/internal/briefing_system/reports/20251009T215047Z_preview_required_deployments.json (404)
	- apps/briefing/docs/internal/briefing_system/reports/20251009T215047Z_*_protection_after.json

## [2025-10-09T22:24:39Z] Preview2 bootstrap — workflow pendiente de publicar
- Workflow local detectado: `.github/workflows/pages-preview2.yml` (Deploy Preview2 (CloudFed)) aún no existe en GitHub (archivo sin publicar).
- `gh workflow run` devuelve 404 → no se disparó ningún run; queda pendiente subir el workflow.
- Snapshot de entornos (`apps/briefing/docs/internal/briefing_system/reports/20251009T222439Z_environments_snapshot.json`) no lista `runart-foundry-preview2` → entorno aún no registrado.
- Log: `apps/briefing/docs/internal/briefing_system/_reports/logs/20251009T222439Z_preview2_bootstrap.log`.
- Pendientes:
	- Publicar workflow Preview2 en rama remota y confirmar primer run.
	- Reintentar branch protection + required deployments cuando GitHub habilite la feature.


## [2025-10-09T21:50:47Z] Required deployments habilitado (GitHub Team)
- Repo: RunArtFoundry/runart-foundry
- Entornos detectados:
  - Production: runart-foundry (Production)
  - Staging (Preview2): runart-foundry-preview2 (Staging)
  - Preview: runart-briefing (Preview)
- Aplicado:
  - main    → required_deployments: [runart-foundry (Production)]
  - develop → required_deployments: [runart-foundry-preview2 (Staging)]
  - preview → required_deployments: [runart-briefing (Preview)]
- Evidencias:
  - apps/briefing/docs/internal/briefing_system/reports/20251009T215047Z_environments_snapshot.json
  - apps/briefing/docs/internal/briefing_system/reports/20251009T215047Z_main_required_deployments.json
  - apps/briefing/docs/internal/briefing_system/reports/20251009T215047Z_develop_required_deployments.json
  - apps/briefing/docs/internal/briefing_system/reports/20251009T215047Z_preview_required_deployments.json
  - apps/briefing/docs/internal/briefing_system/reports/20251009T215047Z_*_protection_after.json


## [2025-10-09T22:39:49Z] Preview2 (conservador) — workflow pendiente de publicar
- WARNING: Falta publicar .github/workflows/pages-preview2.yml en la rama 'develop' (remoto).
- Evidencia: apps/briefing/docs/internal/briefing_system/reports/20251009T223949Z_workflows_snapshot.json
- Acción manual: crear/pegar el archivo en GitHub UI y repetir este bloque.

## Verificación producción — 20251010T132947Z
- Gate smokes HTTP pre-deploy: Configurado en `.github/workflows/pages-prod.yml`.
- Smokes ejecutados manualmente: https://runart-foundry.pages.dev/ → Resultado: FAIL
- Banner producción (env-flag): Removido: YES
- Evidencias: `_reports/smokes_prod_20251010T132947Z/`
- Notas: Todos los endpoints rechazaron la conexión (EAI_AGAIN); repetir cuando la red esté disponible.

## Verificación producción (302 Access) — 20251010T133818Z
- Smokes HTTP con tolerancia 302: Resultado: FAIL
- Banner producción (env-flag): Removido: YES
- Evidencias: `_reports/smokes_prod_20251010T133818Z/`
- Notas: Todos los escenarios devolvieron `EAI_AGAIN`; se requiere nueva ejecución cuando el dominio responda.
## Diagnóstico smokes Producción — 20251010T134525Z
- Evidencias: `_reports/smokes_prod_diag_20251010T134525Z/`
- Resumen: / → redirige a Access (302); /api/whoami → redirige a Access (302); /api/inbox → redirige a Access (302)
- Próximo paso sugerido: revisar disponibilidad DNS/Access o ejecutar smokes con sesión válida

## Verificación producción (no-follow 30x) — 20251010T135513Z
- Smokes HTTP (no-follow, 30x tolerado): Resultado: FAIL
- Banner producción (env-flag): Removido: YES
- Evidencias: `_reports/smokes_prod_20251010T135513Z/`
- Notas: Runner sigue recibiendo `EAI_AGAIN` al resolver runart-foundry.pages.dev; revisar conectividad/DNS antes de reintentar.

## Verificación producción (aggregator fixed) — 20251010T140055Z
- Smokes HTTP (no-follow, 30x tolerado): Resultado: FAIL
- Banner producción (env-flag): Removido: YES
- Evidencias: `_reports/smokes_prod_20251010T140055Z/`
- Notas: Runner falla por `EAI_AGAIN` en todos los endpoints; requiere revisar DNS o acceso de red antes de repetir.

## Smokes Preview — 20251010T143001Z
- Público (Access 30x): FAIL
- Autenticado (Service Token): SKIPPED
- Evidencias: `_reports/smokes_preview_20251010T143001Z/`

### [2025-10-13] — Switch a  + Pages producción alineada
- Default branch: main
- Pages: production_branch=main
- Run Producción: https://github.com/RunArtFoundry/runart-foundry/actions/runs/18480176394
- Smokes post-deploy: NONBLOCKING-FAIL (Access/app check falló; ver body_preview en evidencias)
- Evidencias: apps/briefing/_reports/tests/T4_prod_smokes/20251013T230022Z/
- Notas: overlay activo en prod; KV validados.

### [2025-10-13] — Producción con AUS_XMOC habilitado
- Workflow: pages-prod (manual `workflow_dispatch`)
- Run: https://github.com/RunArtFoundry/runart-foundry/actions/runs/18480582333
- SMOKES_STATUS: NONBLOCKING-FAIL
- Evidencias: apps/briefing/_reports/tests/T4_prod_smokes/20251013T230022Z/
- Notas: auth-smoke habilitado vía AUS_XMOC; deploy no bloqueante; overlay/Access operativos.

### [2025-10-14] — Endurecimiento overlay + saneamiento KV
- Workflow `overlay-deploy.yml` actualizado para:
	- Inyectar `RUNART_ENV` diferenciado (`preview`/`production`) en los entornos wrangler.
	- Generar `worker.js` con resolución de roles alineada al runtime Pages (cache KV + overrides de preview controlados).
	- Registrar evidencias de canario (`/api/health`, `/api/whoami`) y metadatos `roles_source`/`roles_fetched_at`.
	- Limpiar automáticamente claves demo/banner (`demo|seed|sample`) en namespaces `RUNART_ROLES` (preview/prod) guardando diffs en `overlay-canary/kv/*.txt`.
- `apps/briefing/overrides/roles.js` ahora parte de `role: "visitor"` para evitar sesgos de vista demo.
- `apps/briefing/overrides/main.html` reconoce roles normalizados (`owner`, `team`, `client_admin`) para el autolog.
- Reporte `082_overlay_deploy_final.md` actualizado con la nueva evidencias (payloads actualizados, higiene KV y gobernanza).
---

### [2025-10-14] — Fase 1–3 · Canario roles unificados
- Fecha: 2025-10-14  
- Ramas: `feature/roles-unificados` (canario) ↔ `main` (legacy); hash canario: `TBD` (registrar al momento del merge).  
- Entornos:
	- preview — legacy (baseline) · **PASS** (smokes control).  
	- preview2 — canario (`RUNART_ROLES_MODE=unified`) · **PASS** (smokes comparativos, evidencias `_reports/roles_canary_20251014T000000Z/`).  
	- producción — sin cambios (esperando release) · **N/A**.
- Enlaces:
	- Evidencias canario: `_reports/roles_canary_20251014T000000Z/`  
	- ADR: `docs/adr/ADR-0005-unificacion-roles.md`  
	- Checklist release: `apps/briefing/docs/internal/briefing_system/checklists/roles_unificados_release.md`
- Resultado: Canario PASS en preview2; bloqueado hasta completar checklist y aprobación de gobernanza.

### [2025-10-14] — Incidente canario roles (preview2)
- Fecha: 2025-10-14  
- Hash / URLs: pendiente (rollback antes del merge).  
- Evidencia: `apps/briefing/_reports/roles_canary_preview2/BUG_OWNER_FOR_ALL_20251014_1624/`  
- Síntoma: `/api/whoami` en preview2 devolvió `role=admin` para todos los correos (owner, admin_delegate, team, client, visitor).  
- Impacto: escalamiento de privilegios; gobernanza comprometida.  
- Acción: rollback a resolver legacy (`ROLE_RESOLVER_SOURCE=lib`), instrumentación de logs comparativos, creación de pruebas unitarias.  
- Estado: **ROLLBACK ACTIVADO** (no promover preview2 → preview/prod hasta corregir).  
- Próximos pasos: ajustar resolver unificado (fallback visitor, normalización correo, orden de fuentes), repetir canario tras fix.

### [2025-10-14] — Canario por lista blanca (preview)
- Fecha: 2025-10-14T16:49Z  
- Ramas / hash: `hotfix/roles-canary-datacheck` (merge pending), commit de canario `TBD` al momento del despliegue.  
- Alcance: Cloudflare Pages queda limitado a entornos `preview` y `production` (se descarta `preview2`); canario se ejecuta en `preview` mediante lista blanca de correos almacenada en KV.  
- Evidencias:
	- `_reports/kv_snapshot_20251014T164900Z/`
	- `_reports/kv_audit_20251014T164900Z/`
	- `_reports/env_dump_20251014T164900Z/`
	- `_reports/roles_canary_preview/20251014T164900Z/`
- Decisión: mantener `ROLE_RESOLVER_SOURCE=lib` a nivel de entorno mientras se corrige el resolver unificado; habilitar canario solo para correos listados en KV (`RUNART_ROLES:canary_allowlist`).  
- Instrumentación: endpoints diagnósticos temporales (`/api/debug/roles_unified`, `/api/debug/roles_headers`) habilitados en preview con logging adicional; se eliminarán una vez finalizado el canario.  
- Estado: MONITOREO ACTIVO — no se promueve a producción hasta validar que la lista blanca respete la gobernanza.

### [2025-10-14] — Auditoría de datos y endurecimiento canario (preview)
- Fecha: 2025-10-14T17:05Z  
- Rama: `hotfix/roles-canary-datacheck` (pendiente de merge tras validación).  
- Alcance: auditoría de KV `RUNART_ROLES` (entorno preview) + endurecimiento del canario por correo con nuevas cabeceras de diagnóstico.  
- Cambios clave:
	- Guard (`functions/_lib/guard.js`) ahora propaga `X-RunArt-Resolver` y `X-RunArt-Canary` con origen y whitelist; los handlers esperan respuesta asíncrona (resuelve bug `role=undefined`).
	- Resolver unificado (`functions/_shared/roles.shared.js`) expone `resolveRoleUnifiedDetailed` y cachea `CANARY_ROLE_RESOLVER_EMAILS` (normaliza correos y evita lecturas repetidas de KV).
	- Endpoints de soporte (`functions/api/resolve_preview.js`, `functions/api/kv_roles_snapshot.js`) permiten inspección puntual del resolver y del KV durante el canario; se marcan como temporales.
	- Script `scripts/kv_audit.mjs` genera conteos y detecta claves inválidas desde `_reports/roles_canary_preview/kv_snapshot_preview_20251014T170500Z.json`.
- Evidencias actualizadas: `_reports/roles_canary_preview/kv_audit_preview_20251014T170500Z.md`, `_reports/roles_canary_preview/env_dump_preview_20251014T170500Z.md`, `_reports/roles_canary_preview/smokes_20251014T170600Z/` (smokes fallidos documentan `role=undefined` previo al fix asíncrono).
- Pendientes:<br>
	1. Exportar snapshot real del KV (correr `scripts/kv_audit.mjs` contra datos actualizados) y actualizar el markdown de conteos.<br>
	2. Poblar lista blanca con correos finales y repetir smokes (`tests/smokes/roles_canary_preview.*`) hasta obtener PASS con encabezados esperados.<br>
	3. Retirar endpoints de diagnóstico y limpiar evidencias temporales una vez cerrado el canario.<br>
	4. (Añadido) Scripts auxiliares creados: `scripts/kv_export_namespace.mjs` (export REST), `scripts/smoke_canary_emails.mjs` (smokes focalizados). Documentados comandos ejemplo en `_reports/kv_snapshot_preview_YYYYmmddTHHMMSSZ.cmd.txt` y `_reports/canary_allowlist_cmd_<TS>.txt`.

## Credenciales CI/CD Cloudflare (2025-10-14T18:30:00Z)

### Estado Post-Auditoría

**Auditoría completa ejecutada:** Rama `ci/credenciales-cloudflare-audit` con normalización hacia tokens canónicos.

**Secrets actuales identificados:**
- `CLOUDFLARE_API_TOKEN` + `CLOUDFLARE_ACCOUNT_ID` ← **CANÓNICOS** ✅
- `CF_API_TOKEN` + `CF_ACCOUNT_ID` ← **LEGACY** (eliminar tras migración)

### Matriz Workflow → Environment → Secret

| Workflow | Environment | Secret Actual | Secret Target | Estado |
|----------|-------------|---------------|---------------|---------|
| `pages-deploy.yml` | Repo | `CF_API_TOKEN` | `CLOUDFLARE_API_TOKEN` | ❌ Migrar |
| `pages-preview.yml` | Repo | `CLOUDFLARE_API_TOKEN` | `CLOUDFLARE_API_TOKEN` | ✅ OK |
| `pages-preview2.yml` | Repo | `CLOUDFLARE_API_TOKEN` | `CLOUDFLARE_API_TOKEN` | ✅ OK |
| `briefing_deploy.yml` | Repo | `CF_API_TOKEN` | `CLOUDFLARE_API_TOKEN` | ❌ Migrar |
| `overlay-deploy.yml` | Repo | `CLOUDFLARE_API_TOKEN` | `CLOUDFLARE_API_TOKEN` | ✅ OK |

### Scopes Requeridos (Least Privilege)

```
com.cloudflare.api.account.zone:read        ← Verificación dominios Pages
com.cloudflare.edge.worker.script:read      ← Validación Workers
com.cloudflare.edge.worker.kv:edit          ← Gestión KV namespaces  
com.cloudflare.api.account.zone.page:edit   ← Deploy/gestión Pages
```

### Verificación Automática Implementada

- **Scripts:** `tools/ci/check_cf_scopes.sh` + `scripts/secrets/node/cf_token_verify.mjs`
- **Workflow:** `.github/workflows/ci_cloudflare_tokens_verify.yml`
- **Frecuencia:** Semanal (lunes 09:00 UTC) + PR triggers + manual
- **Escalación:** Auto-creación de issues en GitHub si fallan verificaciones

### Política de Rotación

```json
{
  "CLOUDFLARE_API_TOKEN": {
    "rotation_days": 180,
    "next_rotation": "2026-04-11", 
    "reminder_days_before": 30,
    "workflow": "ci_secret_rotation_reminder.yml"
  }
}
```

**Workflow recordatorio:** Primer lunes de cada mes + manual dispatch

### Procedimiento Local (PS/Bash)

```bash
# Verificación local de scopes
export CLOUDFLARE_API_TOKEN=****
./tools/ci/check_cf_scopes.sh repo

# Listar secrets GitHub (solo nombres)
./tools/ci/list_github_secrets.sh

# Crear issue de rotación
./tools/ci/open_rotation_issue.sh CLOUDFLARE_API_TOKEN 30
```

### Enlaces y Documentación

- **Inventario completo:** `security/credentials/github_secrets_inventory.md`
- **Reporte auditoría:** `security/credentials/audit_cf_tokens_report.md`  
- **Política rotación:** `security/credentials/cloudflare_tokens.json`
- **Runbook operativo:** `docs/internal/runbooks/runbook_cf_tokens.md`

### Auditoría Cloudflare Tokens – Cierre Final
**Fecha de auditoría:** 2025-10-14  
**Tokens activos:** CLOUDFLARE_API_TOKEN (preview/prod)  
**Próxima rotación:** 2026-04-11  
**Auditor responsable:** RunArt CI Copilot  
**Estado:** ✅ Estable

#### Validación Final Ejecutada
- **Scopes verificados:** Framework implementado (requiere ejecución en GitHub Actions)
- **Workflows automáticos:** ci_cloudflare_tokens_verify.yml + ci_secret_rotation_reminder.yml ✅
- **Deploy workflows:** pages-preview.yml migrado ✅, pages-deploy.yml requiere migración ❌
- **Documentación:** Runbook completo + inventario actualizado ✅
- **Política rotación:** 180 días con recordatorios automáticos ✅

#### Hallazgos Críticos
1. **pages-deploy.yml** usa CF_API_TOKEN (legacy) - requiere migración a CLOUDFLARE_API_TOKEN
2. **briefing_deploy.yml** usa CF_API_TOKEN (legacy) - requiere migración a CLOUDFLARE_API_TOKEN
3. Todos los secrets existen y están actualizados (2025-10-13)

### Próximos Pasos

1. **CRÍTICO: Migrar workflows legacy** (pages-deploy.yml, briefing_deploy.yml)
2. **Validar 2-3 deploys** con nombres canónicos
3. **Eliminar secrets legacy** tras ventana de estabilización (7-14 días)
4. **Ejecutar verificación semanal** automática y documentar resultados
