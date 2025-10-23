---
generated_by: copilot
phase: pr-01-briefing-canon
date: 2025-10-23T15:10:00-04:00
repo: runart-foundry
branch: feature/pr-01-briefing-canon
---

# Linkmap — Briefing (PR-01)

Este mapa lista los hubs canónicos creados en `docs/live/` y los cruces añadidos en `apps/briefing/docs/`.

## Hubs canónicos (verificado=Sí/No)
- docs/live/index.md → hubs (verificado: Sí)
  - docs/live/architecture/index.md (verificado: Sí)
    - docs/architecture/000_overview.md (Sí)
    - docs/architecture/010_inventory.md (Sí)
    - docs/architecture/020_target_structure.md (Sí)
    - docs/architecture/030_conventions.md (Sí)
    - docs/architecture/040_ci_shared.md (Sí)
    - docs/architecture/050_make_targets.md (Sí)
    - docs/architecture/060_migration_plan.md (Sí)
    - docs/architecture/065_switch_pages.md (Sí)
    - docs/architecture/070_risks.md (Sí)
    - docs/architecture/075_cleanup_briefing.md (Sí)
    - docs/adr/ADR-0005-unificacion-roles.md (Sí)
  - docs/live/operations/index.md (verificado: Sí)
    - docs/DEPLOY_RUNBOOK.md (Sí)
    - docs/DEPLOY_PROD_CHECKLIST.md (Sí)
    - docs/PR_INTEGRATION_FINAL.md (Sí)
    - docs/ops/integracion_operativa.md (Sí)
    - docs/ops/load_staging_credentials.md (Sí)
    - docs/integration_wp_staging_lite/README_MU_PLUGIN.md (Sí)
    - docs/integration_wp_staging_lite/ORQUESTADOR_DE_INTEGRACION.md (Sí)
    - docs/integration_wp_staging_lite/TROUBLESHOOTING.md (Sí)
    - docs/integration_wp_staging_lite/ROLLBACK_PLAN.md (Sí)
    - docs/integration_wp_staging_lite/ISSUES_WORKFLOWS.md (Sí)
    - docs/live/operations/status_overview.md (Sí)
  - docs/live/ui_roles/index.md (verificado: Sí)
    - docs/ui_roles/ui_inventory.md (Sí)
    - docs/ui_roles/tecnico_portada.md (Sí)
    - docs/ui_roles/equipo_portada.md (Sí)
    - docs/ui_roles/VERIFICACION_DEPLOY_FINAL.md (Sí)
    - docs/ui_roles/QA_cases_viewas.md (Sí)
    - docs/ui_roles/QA_checklist_admin_viewas_dep.md (Sí)
    - docs/ui_roles/INFORME_COHERENCIA_UI.md (Sí)
    - docs/ui_roles/PLAN_BACKLOG_SPRINTS.md (Sí)

## Cross-links añadidos (apps/briefing/docs → docs/live) (verificado=Sí/No)
- apps/briefing/docs/index.md → docs/live/index.md (+ hubs) (Sí)
- apps/briefing/docs/internal/briefing_system/index.md → docs/live/index.md (+ hubs) (Sí)
- apps/briefing/docs/client_projects/runart_foundry/index.md → docs/live/index.md (+ hubs) (Sí)
- Pendientes PR-01.1: el resto de `apps/briefing/docs/**/index.md` (No)

Notas:
- Todos los enlaces fueron verificados contra la estructura existente; no se movió ni borró contenido.
- Pendiente ampliar cross-links al resto de índices de `apps/briefing/docs/**` en PRs posteriores.
