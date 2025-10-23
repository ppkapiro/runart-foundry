---
generated_by: copilot
phase: pr-01-briefing-canon
date: 2025-10-23T00:00:00-04:00
repo: runart-foundry
branch: feature/pr-01-briefing-canon
---

# PR-01: Enrutado canónico de Briefing (docs/live) + enlaces cruzados desde apps/briefing/docs (sin mover contenido)

## Qué hace este PR
- Establece `docs/live/` como índice canónico de Briefing con hubs:
  - Arquitectura → `docs/live/architecture/index.md` (enlaces verificados)
  - Operaciones → `docs/live/operations/index.md` (rutas corregidas a `docs/DEPLOY_RUNBOOK.md`, `docs/DEPLOY_PROD_CHECKLIST.md`, `docs/ops/integracion_operativa.md`, `docs/integration_wp_staging_lite/**`, etc.)
  - UI/Roles → `docs/live/ui_roles/index.md` (`ui_inventory.md`, `tecnico_portada.md`, `equipo_portada.md`, `VERIFICACION_DEPLOY_FINAL.md`, `QA_*`)
- Añade `docs/live/operations/status_overview.md` (estado mínimo; pendiente métricas).
- Inserta bloque “Fuente canónica” en `apps/briefing/docs/**` (cross-links iniciales).
- Incluye `docs/_meta/linkmap_briefing.md` (mapa de enlaces) y `docs/_meta/checklist_pr01.md` (validación manual).

## Qué NO hace
- No mueve ni borra archivos existentes.
- No modifica `README.md`, `STATUS.md`, `NEXT_PHASE.md`, `CHANGELOG.md` (eso va en PR-02).

## Cómo validar
1. Abrir `docs/live/index.md` y navegar hubs.
2. Confirmar que Operaciones apunta a rutas reales existentes (no a `docs/operations/` inexistente).
3. Verificar en `apps/briefing/docs/**` la presencia del bloque “Fuente canónica” y que las rutas relativas resuelvan.
4. Revisar `docs/_meta/linkmap_briefing.md` y `docs/_meta/checklist_pr01.md` (0 enlaces rotos observados).

## Criterios de aceptación
- Hubs accesibles y con ≥ 8 enlaces por hub.
- Bloque “Fuente canónica” en todos los `.md` de `apps/briefing/docs/**`.
- 0 enlaces rotos detectados en verificación básica (existencia).
- Sin movimiento/borrado de contenidos heredados.

## Siguientes pasos
- Subtarea PR-01.1: extender cross-links restantes y pulir descripciones.
- PR-02 (root alignment): roles y enlaces canónicos en raíz, sin pérdida de historia.
- OWNER: ejecutar normalización de origin (set-url) según `scripts/tools/git_set_origin_reference.sh`.
