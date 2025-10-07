---
title: 082 — Reestructuración local Briefing
---
# 082 — Reestructuración local Briefing

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
