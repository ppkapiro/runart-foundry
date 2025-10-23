---
generated_by: copilot
phase: pr-01-briefing-canon
date: 2025-10-23T15:10:00-04:00
repo: runart-foundry
branch: feature/pr-01-briefing-canon
---

# Checklist PR-01 — Enrutado canónico Briefing

- [x] `docs/live/index.md` actualizado con hubs y enlaces a archivo/estado.
- [x] Crear `docs/live/architecture/index.md` con enlaces válidos a `docs/architecture/**` y `docs/adr/**`.
- [x] Crear `docs/live/operations/index.md` con enlaces válidos a `docs/**` operativos y `integration_wp_staging_lite/**`.
- [x] Crear `docs/live/ui_roles/index.md` con enlaces válidos a `docs/ui_roles/**` existentes.
- [x] Crear `docs/live/operations/status_overview.md` referenciando `docs/ops/status.json` y tareas locales.
- [x] Añadir bloque de enlace canónico en:
  - [x] `apps/briefing/docs/index.md`
  - [x] `apps/briefing/docs/internal/briefing_system/index.md`
  - [x] `apps/briefing/docs/client_projects/runart_foundry/index.md`
- [x] Registrar `docs/_meta/linkmap_briefing.md` con hubs y cruces añadidos.
- [ ] Revisión manual: abrir cada hub y comprobar que no hay 404 en enlaces listados.
- [x] Abrir PR como Draft con descripción y enlazar a `docs/_meta/pr_drafts/PR-01_enrutado_canonico_briefing.md` (PR #60).

Notas
- No se movieron ni renombraron archivos legados; sólo enlaces y nuevos hubs.
- Validadores de frontmatter/enlaces quedan para PRs futuros (modo dry-run primero).

## Verificación manual (en seco)

### Hubs y enlaces verificados
- Arquitectura (OK):
  - docs/architecture/000_overview.md (OK)
  - docs/architecture/010_inventory.md (OK)
  - docs/architecture/020_target_structure.md (OK)
  - docs/architecture/030_conventions.md (OK)
  - docs/architecture/040_ci_shared.md (OK)
  - docs/architecture/050_make_targets.md (OK)
  - docs/architecture/060_migration_plan.md (OK)
  - docs/architecture/065_switch_pages.md (OK)
  - docs/architecture/070_risks.md (OK)
  - docs/architecture/075_cleanup_briefing.md (OK)
  - docs/adr/ADR-0005-unificacion-roles.md (OK)

- Operaciones (OK):
  - docs/DEPLOY_RUNBOOK.md (OK)
  - docs/DEPLOY_PROD_CHECKLIST.md (OK)
  - docs/PR_INTEGRATION_FINAL.md (OK)
  - docs/ops/integracion_operativa.md (OK)
  - docs/ops/load_staging_credentials.md (OK)
  - docs/integration_wp_staging_lite/README_MU_PLUGIN.md (OK)
  - docs/integration_wp_staging_lite/ORQUESTADOR_DE_INTEGRACION.md (OK)
  - docs/integration_wp_staging_lite/TROUBLESHOOTING.md (OK)
  - docs/integration_wp_staging_lite/ROLLBACK_PLAN.md (OK)
  - docs/integration_wp_staging_lite/ISSUES_WORKFLOWS.md (OK)
  - docs/live/operations/status_overview.md (OK)

- UI/Roles (OK):
  - docs/ui_roles/ui_inventory.md (OK)
  - docs/ui_roles/tecnico_portada.md (OK)
  - docs/ui_roles/equipo_portada.md (OK)
  - docs/ui_roles/VERIFICACION_DEPLOY_FINAL.md (OK)
  - docs/ui_roles/QA_cases_viewas.md (OK)
  - docs/ui_roles/QA_checklist_admin_viewas_dep.md (OK)
  - docs/ui_roles/INFORME_COHERENCIA_UI.md (OK)
  - docs/ui_roles/PLAN_BACKLOG_SPRINTS.md (OK)

### Cross-links en apps/briefing/docs/**
- Con bloque “Fuente canónica” (OK):
  - apps/briefing/docs/index.md
  - apps/briefing/docs/internal/briefing_system/index.md
  - apps/briefing/docs/client_projects/runart_foundry/index.md
- Pendientes (PR-01.1):
  - apps/briefing/docs/editor/index.md
  - apps/briefing/docs/inbox/index.md
  - apps/briefing/docs/galeria/index.md
  - apps/briefing/docs/fases/index.md
  - apps/briefing/docs/acerca/index.md
  - apps/briefing/docs/decisiones/index.md
  - apps/briefing/docs/internal/briefing_system/ui/index.md
  - apps/briefing/docs/projects/index.md
  - apps/briefing/docs/proceso/index.md
  - apps/briefing/docs/exports/index.md
  - apps/briefing/docs/client_projects/runart_foundry/auditoria/index.md
  - apps/briefing/docs/client_projects/runart_foundry/plan/index.md

