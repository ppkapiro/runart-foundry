---
generated_by: copilot
phase: pr-07-governance-stale
date: 2025-10-23T21:55:00-04:00
repo: runart-foundry
branch: feature/pr-07-governance-stale
---

# Post PR-07 — Gobernanza + Poda Semanal

## Cambios
- `docs/_meta/governance.md`: completado con ciclo de vida (Draft → Active → Stale → Archived), detección automática stale >90d, owners por carpeta
- `CONTRIBUTING.md`: creado en raíz con guías de frontmatter, enlaces, tags, flujo PR y CI
- `.github/workflows/docs-stale-dryrun.yml`: workflow semanal (lunes 09:00 UTC) que detecta docs stale y genera reporte (dry-run)

## Validación
- scripts/validate_docs_strict.py: PASS (0 errores)
- Workflow testeable manualmente con `workflow_dispatch`

## Estado general
- PR-07: listo para merge
- Próximo: reporte final consolidado
