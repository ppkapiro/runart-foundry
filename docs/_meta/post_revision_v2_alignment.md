---
generated_by: copilot
phase: post_revision_v2
date: 2025-10-23T14:31:24-04:00
repo: runart-foundry
branch: main
---

# Post Revisión Profunda V2 — Alineamiento (Lote A)

## Qué se hizo
- Se documentó la normalización propuesta del remoto canónico (sin ejecutar).
- Se generaron 4 listas priorizadas de curaduría (Lote A):
  - `lote_A_docs_live.md` — .md bajo `docs/**`
  - `lote_A_apps_briefing_docs.md` — .md bajo `apps/briefing/docs/**`
  - `lote_A_root_docs.md` — rol sugerido para README/STATUS/NEXT_PHASE/CHANGELOG
  - `lote_A_workflows_operativos.md` — workflows con propósito resumido
- Se declaró la fuente canónica de Briefing en `docs/live/briefing_canonical_source.md`.
- Se creó el borrador de validadores en `docs/_meta/validators_plan.md`.

## Qué NO se hizo
- No se movió, renombró ni borró ningún archivo.
- No se ejecutó cambio de remoto ni activación de validadores en CI.

## Decisiones pendientes
- OWNER confirma actualización de `origin` → `git@github.com:RunArtFoundry/runart-foundry.git`.
- Aprobación del Lote A y orden de migración hacia `docs/live/` y `docs/archive/`.
- Selección de validadores y su integración en CI.

## Siguientes pasos propuestos
- Validar criterios de priorización y ajustar listas si aplica.
- Preparar PRs atómicos por dominio (ops, i18n, ui_roles, architecture...).
- Activar validadores tras confirmar frontmatter/links en un subconjunto piloto.
