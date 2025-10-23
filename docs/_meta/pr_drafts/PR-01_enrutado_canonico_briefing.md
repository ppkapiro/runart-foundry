---
generated_by: copilot
phase: phase2_planning
date: 2025-10-23T15:05:37-04:00
repo: runart-foundry
branch: main
---

# PR-01 — Enrutado canónico Briefing (sin mover contenidos)

Título sugerido: chore(docs): PR-01 enrutado canónico Briefing — hubs en docs/live e interlinks apps/briefing/docs

## Objetivo
Completar el índice temático canónico en `docs/live/index.md` y establecer enlaces cruzados desde `apps/briefing/docs/**` hacia `docs/live/`, sin mover ni renombrar archivos.

## Alcance
- Editar `docs/live/index.md` para incluir hubs: Arquitectura, Operaciones, UI/Roles, Integraciones.
- Añadir enlaces de ida y vuelta (cross-links) en documentos clave de `apps/briefing/docs/**` apuntando a `docs/live/` (solo edición de enlaces/headers, sin relocalización de archivos).

## Archivos objetivo (ejemplos)
- `docs/live/index.md` (completar secciones y enlaces)
- `apps/briefing/docs/internal/briefing_system/architecture/_index.md` (cross-link a `docs/live/`)
- `apps/briefing/docs/internal/briefing_system/ops/runbook_operacion.md` (cross-link a Operaciones en `docs/live/`)
- `apps/briefing/docs/briefing_arquitectura.md` (cross-link a Arquitectura en `docs/live/`)

## Pasos propuestos
1) En `docs/live/index.md`, agregar secciones con listas de enlaces a:
   - Arquitectura (docs/architecture/* relevantes vigentes)
   - Operaciones/Runbooks (docs/DEPLOY_RUNBOOK.md, docs/DEPLOY_PROD_CHECKLIST.md, etc.)
   - UI/Roles (docs/ui_roles/*)
   - Integraciones (docs/integration_wp_staging_lite/*)
2) En `apps/briefing/docs/**`, insertar al inicio un bloque “Ver también” con enlaces a `docs/live/` (donde aplique).
3) Ejecutar lint de documentación y verificador de enlaces (si está configurado) antes del PR.

## Checklist
- [ ] No se mueven ni renombran archivos.
- [ ] `docs/live/index.md` actualizado con hubs claros.
- [ ] Cross-links añadidos en `apps/briefing/docs/**` clave.
- [ ] Frontmatter presente donde aplique.
- [ ] Enlaces relativos verificados (0 rotos).
- [ ] CI verde (docs-lint, structure-guard).

## Riesgos y mitigación
- Enlaces rotos: ejecutar verificador de links y corregir rutas relativas.
- Confusión de canonicidad: mantener nota explícita “Canónico: docs/live/”.

## Fuentes
- `docs/_meta/lote_A_docs_live.md`
- `docs/_meta/lote_A_apps_briefing_docs.md`
- `docs/live/briefing_canonical_source.md`
