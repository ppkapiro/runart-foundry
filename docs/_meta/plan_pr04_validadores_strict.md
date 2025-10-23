---
generated_by: copilot
phase: pr-04-validadores-strict
date: 2025-10-23T00:00:00-04:00
repo: runart-foundry
branch: main
---

# PR-04 — Validadores Strict + CI

## Objetivo
Activar validadores estrictos para frontmatter, enlaces internos y duplicados legacy.

## Alcance
- Convertir `scripts/validate_docs_soft.py` en modo “strict”.
- Agregar validaciones obligatorias en CI.
- Eliminar duplicados legacy (solo los confirmados en PR-03).

## Plan
1. Crear `scripts/validate_docs_strict.py` (reutilizar lógica del soft validator con validaciones fatales).
2. Integrar en CI con paso obligatorio (pre-merge) usando un workflow dedicado o plantilla reusable.
3. Revisar `Makefile` y workflows para usar el nuevo target `make validate_strict`.
4. Archivar cualquier documento sin frontmatter o con enlaces rotos detectado en este paso.

## Criterios de aceptación
- CI en verde con validadores strict.
- 0 duplicados activos en `docs/live/`.
- 100% frontmatter válido.
- Índices actualizados.

## Implementación materializada en CI
- Script `scripts/validate_docs_strict.py` creado.
- Target de Make `validate_strict` añadido.
- Workflow `.github/workflows/docs-validate-strict.yml` agregado para PRs contra `main`.
