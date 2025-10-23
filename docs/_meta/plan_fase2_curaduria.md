---
generated_by: copilot
phase: phase2_planning
date: 2025-10-23T14:49:59-04:00
repo: runart-foundry
branch: main
---

# Fase 2 — Curaduría controlada (sin pérdida de historia)

Objetivo: mover, por lotes y con PRs atómicos, los documentos del Lote A a la capa adecuada (`live/` o `archive/`) manteniendo trazabilidad completa.

## Alcance inicial (fuente)
- `docs/_meta/lote_A_docs_live.md`
- `docs/_meta/lote_A_apps_briefing_docs.md`
- `docs/_meta/lote_A_root_docs.md`
- `docs/_meta/lote_A_workflows_operativos.md`

## Estrategia
1) PR-01 (Enrutado canónico Briefing)
   - Completar `docs/live/index.md` con enlaces a hubs (arquitectura, operaciones, ui_roles).
   - Añadir cross-links desde `apps/briefing/docs/**` hacia `docs/live/` (sin mover todavía `apps/`).
   - Validar enlaces relativos.
2) PR-02 (Raíz alineada)
   - README.md (raíz): confirmar rol de portada y enlazar a `docs/live/index.md`.
   - STATUS.md: evaluar mover o duplicar a `docs/live/operations/status_overview.md` manteniendo el original con enlace canónico (decisión a registrar).
   - NEXT_PHASE.md y CHANGELOG.md: aclarar rol y enlaces canónicos.
3) PR-03..N (Lotes temáticos)
   - Arquitectura, Operaciones, UI/Roles. Para cada lote:
     - Añadir frontmatter estándar donde falte.
     - Mover solo lo vigente a `docs/live/`.
     - Archivar histórico a `docs/archive/AAAA/MM/` con índice cronológico.
     - Arreglar enlaces relativos y anchors.
   - Checklist por PR: 0 enlaces rotos, frontmatter OK, índice actualizado.

## Validadores (modo “dry-run”)
- Planear `docs/_meta/validators_plan.md` → activar en CI después del primer PR estable.
- Dry-run local opcional (no obligatorio en esta fase).

## Criterios de aceptación globales
- Briefing consume `docs/live/` como fuente canónica sin warnings.
- `docs/archive/` contiene histórico con índice por año/fase.
- Raíz (README/STATUS/NEXT_PHASE/CHANGELOG) con roles claros y enlaces canónicos.
- 0 enlaces rotos en Lote A; frontmatter presente.
