---
generated_by: copilot
phase: pr-01-briefing-canon
date: 2025-10-23T15:00:00-04:00
repo: runart-foundry
branch: feature/pr-01-briefing-canon
---

# PR-01: Enrutado canónico Briefing (docs/live) + enlaces cruzados desde apps/briefing/docs (sin mover contenido)

Estado: Draft

## Objetivo
Completar el enrutado canónico en `docs/live/` y añadir enlaces cruzados desde `apps/briefing/docs/**` hacia los hubs canónicos, sin mover ni borrar archivos.

## Alcance (incluido)
- Completar `docs/live/index.md` con hubs mínimos (Arquitectura, Operaciones, UI/Roles) y enlace a `operations/status_overview.md`.
- Crear hubs si faltan:
  - `docs/live/architecture/index.md`
  - `docs/live/operations/index.md`
  - `docs/live/ui_roles/index.md`
- Cada hub debe listar 8–15 enlaces existentes (derivados de `docs/_meta/revision_profunda_index.csv`).
- Crear/actualizar `docs/live/operations/status_overview.md` con contexto de `status.json` y workflows relevantes.
- Añadir bloque “Canonical source” al inicio de cada `.md` bajo `apps/briefing/docs/**` con enlaces a los hubs canónicos.
- Crear `docs/_meta/linkmap_briefing.md` (mapa de enlaces) y `docs/_meta/checklist_pr01.md` (verificaciones).

## Fuentes de datos
- `docs/_meta/revision_profunda_index.csv`
- `docs/_meta/lote_A_docs_live.md`
- `docs/_meta/lote_A_apps_briefing_docs.md`

## No incluido (fuera de alcance de PR-01)
- No mover, renombrar ni borrar contenidos heredados.
- No reescribir README/STATUS/NEXT_PHASE/CHANGELOG (eso ocurre en PR-02).
- No activar validadores de CI.

## Implementación (pasos)
1) Hubs canónicos
   - Editar `docs/live/index.md` con frontmatter de PR-01 y enlaces a hubs.
   - Crear `architecture/index.md`, `operations/index.md`, `ui_roles/index.md` con frontmatter y listas iniciales (8–15 enlaces cada uno) a documentos existentes.
2) Status overview
   - Crear `docs/live/operations/status_overview.md` (frontmatter PR-01).
   - Describir qué es `status.json` (si existe) y enlazar workflows `.github/workflows/*.yml` relevantes (1 línea de propósito).
3) Enlaces cruzados en apps/briefing/docs/**
   - Insertar bloque “Canonical source” al inicio de cada `.md` con enlaces a hubs canónicos.
   - Mantener autoría original; si no hay frontmatter, añadir el de PR-01.
4) Mapa y checklist
   - `docs/_meta/linkmap_briefing.md`: registrar “Hubs → Enlaces” y “apps → Canonical links”.
   - `docs/_meta/checklist_pr01.md`: criterios de verificación manual (enlaces existen, frontmatter presente, nada movido/borrado).

## Commits sugeridos
1) `docs(briefing-canon): hubs canónicos en docs/live + status_overview`
2) `docs(briefing-canon): cross-links en apps/briefing/docs/**`
3) `docs(briefing-canon): linkmap y checklist PR-01`

## Cómo validar localmente (manual, sin CI)
- Navegar `docs/live/index.md` → hubs → enlaces listados (verificar que los destinos existen).
- Abrir algunos `.md` en `apps/briefing/docs/**` y confirmar bloque “Canonical source” con rutas relativas correctas.
- Revisar `docs/_meta/linkmap_briefing.md` y `docs/_meta/checklist_pr01.md` presentes.

## Criterios de aceptación
- `docs/live/index.md` con hubs y enlace a `operations/status_overview.md` accesible.
- Cada hub con ≥8 enlaces existentes (no rotos) a documentación actual.
- Todos los `.md` de `apps/briefing/docs/**` muestran el bloque “Canonical source”.
- `linkmap_briefing.md` y `checklist_pr01.md` creados.
- 0 enlaces rotos observados en revisión básica.

## Título del PR sugerido
PR-01: Enrutado canónico Briefing (docs/live) + enlaces cruzados desde apps/briefing/docs (sin mover contenido)

