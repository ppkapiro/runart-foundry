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

## Incidencias conocidas

- Advertencias previas de MkDocs por enlaces a archivos `.js` (resuelto).
- Revisar enlaces residuales a rutas antiguas dentro de informes históricos (pendiente de barrido completo) → ✅ barrido inicial en informes cliente; duplicado `briefing/` archivado en `_archive/legacy_removed_20251007/`.

## Próximos pasos

- Una vez verificados los checks, preparar changelog y nota para `README_briefing.md`.
- Coordinar con equipo ARQ para planificar despliegue en Pages tras validaciones.
