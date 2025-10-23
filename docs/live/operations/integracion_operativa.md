---
status: active
owner: reinaldo.capiro
updated: 2025-10-23
audience: internal
tags: [briefing, runart, ops]
---

# Integración Operativa — Iteración 3

## Propósito

Automatizar el control de calidad documental y el reporting de estado en el monorepo `runart-foundry`, garantizando que cada Pull Request ejecute validaciones consistentes y que los hitos queden registrados sin intervención manual.

## Workflows integrados

### `docs-lint.yml`
- **Trigger:** `pull_request` cuando cambian archivos en `docs/**`, `apps/**/docs/**`, `mkdocs.yml`, `tools/lint_docs.*` o cualquier `*.md`.
- **Acción principal:** ejecuta `make lint-docs` con `MKDOCS_STRICT=1`, construyendo MkDocs para `apps/briefing` y la capa de compatibilidad.
- **Resultados:**
  - Check “Docs Lint” visible en la pestaña de checks del PR.
  - Artifact `docs-lint-log` con `audits/docs_lint.log`.
  - Anotaciones automáticas en caso de errores (`::error` con ruta y línea).

### `status-update.yml`
- **Trigger:** `push` sobre `main` y `workflow_dispatch` manual.
- **Acción principal:** mueve el bloque `## [Unreleased]` de `CHANGELOG.md` a un release con fecha actual (formato `## [Released — AAAA-MM-DD] (ops)`), actualiza `STATUS.md` y registra el hito.
- **Resultados:**
  - Commit automático `chore(docs): update status & changelog [skip ci]` (solo si hay cambios).
  - Artifact `status-update-diff` con el diff aplicado.
  - Registro en `STATUS.md` → sección “Últimos hitos”.
- **Permisos:** usa el `GITHUB_TOKEN` con `contents: write` (declarado en el workflow), no requiere secretos adicionales.

### `env-report.yml`
- **Trigger:** `pull_request` sobre cualquier archivo.
- **Acciones:**
  1. Ejecuta `python tools/check_env.py --mode=config`.
  2. Resuelve la URL de preview buscando el estado “Cloudflare Pages”; si no existe, usa `https://example.pages.dev`.
  3. Ejecuta `python tools/check_env.py --mode=http --base-url <preview> --expect-env preview`.
- **Resultados:**
  - Comentario automático en la PR:
    - `✅ ENV CHECK PASSED — env=preview` si ambos checks pasan.
    - `❌ ENV CHECK FAILED — see audits/env_check.log` en caso contrario.
  - Artifact `env-check-log` con `audits/env_check.log`.
  - El workflow falla si cualquiera de los modos reporta error (bloquea el merge).

## Reglas y variables
- Todos los workflows trabajan con `python3` y dependen de los scripts del repositorio (`tools/lint_docs.py`, `tools/check_env.py`).
- No se requieren secretos adicionales; el `GITHUB_TOKEN` concede permisos de lectura/escritura necesarios.
- Se puede definir una variable de repositorio `DEFAULT_PREVIEW_URL` para personalizar la URL fallback del workflow de entorno (opcional; si no existe se usa `https://example.pages.dev`).

## Interpretación de resultados en PRs
- Verifica la pestaña de checks: “Docs Lint” y “Environment Report” deben aparecer en verde antes de solicitar revisión.
- El comentario del bot con `ENV CHECK PASSED` confirma que `tools/check_env.py` validó configuración y endpoints.
- Ante fallos, revisar el artifact correspondiente (`docs-lint-log`, `env-check-log`) y repetir la ejecución local (`make lint-docs`, `python tools/check_env.py --mode=http ...`).

## Checklist para administradores
1. Confirmar que cada PR tiene el check “Docs Lint” en estado ✅.
2. Confirmar la presencia del comentario `ENV CHECK PASSED — env=preview` (o investigar el artifact si aparece `❌`).
3. Tras merges en `main`, verificar que el workflow `status-update` genera el commit automático con `skip ci` y que `STATUS.md` refleja el hito.
4. Registrar incidentes o anomalías en `INCIDENTS.md` si algún workflow falla de forma recurrente.

## Referencias
- `STATUS.md`
- `CHANGELOG.md`
- `INCIDENTS.md`
- Workflows: `.github/workflows/docs-lint.yml`, `.github/workflows/status-update.yml`, `.github/workflows/env-report.yml`
- Scripts de soporte: `tools/lint_docs.py`, `tools/check_env.py`
