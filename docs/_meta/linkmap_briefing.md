---
generated_by: copilot
phase: pr-01-briefing-canon
date: 2025-10-23T15:10:00-04:00
repo: runart-foundry
branch: feature/pr-01-briefing-canon
---

# Linkmap — Briefing (PR-01)

Este mapa lista los hubs canónicos creados en `docs/live/` y los cruces añadidos en `apps/briefing/docs/`.

## Hubs canónicos
- docs/live/index.md → hubs
  - docs/live/architecture/index.md
    - docs/architecture/000_overview.md
    - docs/architecture/010_inventory.md
    - docs/architecture/020_target_structure.md
    - docs/architecture/030_conventions.md
    - docs/architecture/040_ci_shared.md
    - docs/architecture/050_make_targets.md
    - docs/architecture/060_migration_plan.md
    - docs/architecture/065_switch_pages.md
    - docs/architecture/070_risks.md
    - docs/architecture/075_cleanup_briefing.md
    - docs/adr/ADR-0005-unificacion-roles.md
  - docs/live/operations/index.md
    - docs/DEPLOY_RUNBOOK.md
    - docs/DEPLOY_PROD_CHECKLIST.md
    - docs/PR_INTEGRATION_FINAL.md
    - docs/ops/integracion_operativa.md
    - docs/ops/load_staging_credentials.md
    - docs/integration_wp_staging_lite/README_MU_PLUGIN.md
    - docs/integration_wp_staging_lite/ORQUESTADOR_DE_INTEGRACION.md
    - docs/integration_wp_staging_lite/TROUBLESHOOTING.md
    - docs/integration_wp_staging_lite/ROLLBACK_PLAN.md
    - docs/integration_wp_staging_lite/ISSUES_WORKFLOWS.md
    - docs/live/operations/status_overview.md
  - docs/live/ui_roles/index.md
    - docs/ui_roles/ui_inventory.md
    - docs/ui_roles/tecnico_portada.md
    - docs/ui_roles/equipo_portada.md
    - docs/ui_roles/VERIFICACION_DEPLOY_FINAL.md
    - docs/ui_roles/QA_cases_viewas.md
    - docs/ui_roles/QA_checklist_admin_viewas_dep.md
    - docs/ui_roles/INFORME_COHERENCIA_UI.md
    - docs/ui_roles/PLAN_BACKLOG_SPRINTS.md

## Cross-links añadidos (apps/briefing/docs → docs/live)
- apps/briefing/docs/index.md → docs/live/index.md (+ hubs)
- apps/briefing/docs/internal/briefing_system/index.md → docs/live/index.md (+ hubs)
- apps/briefing/docs/client_projects/runart_foundry/index.md → docs/live/index.md (+ hubs)

Notas:
- Todos los enlaces fueron verificados contra la estructura existente; no se movió ni borró contenido.
- Pendiente ampliar cross-links al resto de índices de `apps/briefing/docs/**` en PRs posteriores.
