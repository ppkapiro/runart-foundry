# Estado Operativo — RUNArt Foundry

## Resumen Ejecutivo

<<<<<<< HEAD
- **Objetivo actual**: Consolidar la documentación y preparar la transición del monorepo hacia la estructura modular definida en `docs/architecture/020_target_structure.md`.
- **Salud general**: CI/CD estable; documentación estratégica 000–070 publicada y enlazada en MkDocs.
- **Prioridades inmediatas**: Adoptar el linter de documentación, completar plantillas de colaboración y planificar el job `docs-lint` en GitHub Actions.
- **Novedad**: Build estable en `apps/briefing` (mkdocs estricta) y workflow de fallback para deploy de Pages; además, purga y smokes OTP registrados vía auto-fill; dashboards por rol estables (owner/equipo/cliente).
=======
- **Objetivo actual**: Fase 5 cerrada (documentación UI/QA/observabilidad consolidada); preparar backlog Fase 6 para entregar datos reales y sesiones "Ver como".
- **Salud general**: CI/CD y documentación en verde; Access y roles validados (`_reports/kv_roles/20251009T2106Z/`).
- **Prioridades inmediatas**: Planificar activación continua de guardias (`docs-lint`, `env-report`, `status-update`), agendar sesiones "Ver como" para Fase 6 y avanzar con `packages/env-banner`.
- **Novedad**: Reporte F5 v1.0 con sello DONE y notas de diferimiento publicadas.
>>>>>>> chore/bootstrap-git

## Semáforo por módulo

| Módulo | Estado | Comentarios |
| --- | --- | --- |
<<<<<<< HEAD
| `apps/briefing` | 🟢 | Dashboards por rol en producción; build estable (mkdocs estricta) y fallback CI listo; purga + smokes OTP completados (auto-fill 2025-10-08T15:00Z). |
| `services/*` | ⚪ | Aún en fase de diseño; plan detallado en `060_migration_plan.md` (F5). |
| `packages/*` | ⚪ | En backlog; creación de `packages/env-banner` programada para F3. |
| `tools/*` | 🟡 | Scripts legacy en `scripts/`; migración a `tools/` en progreso (F2) junto al nuevo linter. |

## Últimos hitos
- 2025-10-08 — Build estable + fallback CI (Pages deploy); purga y smokes de producción marcados como listos (auto-fill, ver `_reports/` y `_reports/autofill_log_20251008T1500Z.md`).
=======
| `apps/briefing` | 🟢 | Fase 5 cerrada con documentación consolidada; datos reales y capturas quedan en backlog controlado (ver reporte F5 §10). |
| `services/*` | ⚪ | Esperando kickoff de Fase 5 para definir servicios y bindings externos (ver `060_migration_plan.md`). |
| `packages/*` | ⚪ | Backlog preparado; primera entrega `packages/env-banner` programada para próxima iteración. |
| `tools/*` | 🟡 | Guardias Docs Lint/Env Report validadas en local; migración de scripts y smoke Access programados para Fase 6. |

## Últimos hitos
- 2025-10-08 — Fase 5 cerrada (reporte v1.0, backlog diferido registrado en STATUS/NEXT).
- 2025-10-11 — Wireframes v1 de dashboards por rol publicados (`docs/internal/briefing_system/ui/dash/*.md`).
- 2025-10-08 — Observabilidad LOG_EVENTS documentada (`ops/observabilidad.md`) + script `tools/log_events_summary.py`.
- 2025-10-08 — Plan de sesiones "Ver como" preparado (`_reports/access_sessions/20251008T222921Z/`, guía QA actualizada).
- 2025-10-08 — Guardia QA activada con primer run de `docs-lint` + `check_env` (`_reports/qa_runs/20251008T221533Z/`, `ops/qa_guardias.md`).
- 2025-10-11 — Scaffolding dashboards `/dash/*` y contrato de datos documentado (`docs/internal/briefing_system/ui/**`).
- 2025-10-11 — Auditoría overrides UI contextual registrada (`_reports/ui_context/20251011T153200Z/`) como primer entregable Fase 5.
- 2025-10-11 — Kickoff Fase 5 (reporte v0.1, orquestador actualizado, backlog priorizado).
- 2025-10-10 — Fase 4 cerrada (reporte final, STATUS/NEXT actualizados, orquestador y bitácora sincronizados).
- 2025-10-09 — Evidencias Access/KV registradas (`_reports/kv_roles/20251009T2106Z/`) y guía de administración publicada.
- 2025-10-08 — Build estable + fallback CI (Pages deploy) documentados; guardias listos para activarse.
>>>>>>> chore/bootstrap-git
- 2025-10-08 — Release automático registrado en CHANGELOG (ops).
- 2025-10-07 — Dashboards por rol activos en Cloudflare Pages (`/dash/*`) con middleware unificado y logging en `LOG_EVENTS`.
- 2025-10-07 — Redeploy de Cloudflare Pages (`runart-foundry`) tras consolidación; Access validado vía smoke test CLI.
- 2025-10-06 — Release automático registrado en CHANGELOG (ops).
- Documentos de arquitectura `000`–`070` validados y enlazados en navegación MkDocs.
- Sección “Arquitectura” visible en `briefing/` con contenido unificado vía snippets.
- Plan de migración incremental (`060_migration_plan.md`) con fases F1–F5 y checklist por PR.
- Playbook de switch (`065`) y cleanup post-switch (`075`) publicados con auditorías requeridas.

## Próximos 7 días (sprint)

<<<<<<< HEAD
1. Habilitar y monitorear los checks “Docs Lint” y “Environment Report” en las PR activas.
2. Ejecutar `status-update` tras los merges de documentación y validar el commit automático.
3. Socializar `docs/ops/integracion_operativa.md` con stewards y actualizar playbooks internos.
4. Definir responsables (stewards) por módulo en la matriz del semáforo.
5. Programar limpieza de la capa `briefing/` tras 48 h de estabilidad siguiendo `docs/architecture/075_cleanup_briefing.md`.
6. Monitorear `LOG_EVENTS` y Access tras el auto-fill para recopilar evidencia real de tráfico.
7. Diseñar widgets/KPIs específicos por rol aprovechando los smokes completados.
=======
1. Elaborar plan de arranque Fase 6 con foco en datos reales para dashboards y sesiones "Ver como".
2. Calendarizar sesiones Access (owner/client_admin/team) usando plantillas `_reports/access_sessions/20251008T222921Z/`.
3. Configurar ejecución recurrente de `docs-lint`, `env-report`, `status-update` (cron/Actions) y documentar owners.
4. Diseñar playbook de alertas automáticas basadas en `tools/log_events_summary.py` y preparar pruebas de disparo.
5. Kickoff `packages/env-banner` y definir roadmap de migración de scripts hacia `tools/`.
6. Actualizar métricas operativas en reporte F6 inicial (QA sessions, cobertura dashboards, alertas Access).
7. Mantener vigilancia del guard `structure-guard` y actualizar documentación si surgen nuevas reglas.
>>>>>>> chore/bootstrap-git

## Integración Operativa — Iteración 3

- **Objetivo:** Automatizar control de calidad y reporting CI.
- **Documentación:** `docs/ops/integracion_operativa.md`.

| Workflow | Estado | Comentarios |
| --- | --- | --- |
<<<<<<< HEAD
| Docs Lint | ⏳ Pending activation | Primera ejecución en PR piloto pendiente de confirmar.
| Status Update | ⏳ Pending activation | Se activará tras el siguiente merge a `main`.
| Env Report | ⏳ Pending activation | Requiere validar detección de URL de preview en una PR real.
=======
| Docs Lint | 🟡 Guardia activa | Validación local `tools/lint_docs.py`; falta primer run en PR con artifact.
| Status Update | ⏳ Pending activation | Se activará tras el siguiente merge a `main`.
| Env Report | 🟡 Config OK | `check_env.py --mode=config` en verde; HTTP pendiente de preview real.
>>>>>>> chore/bootstrap-git

## Riesgos activos

Consultar `docs/architecture/070_risks.md`. Riesgos en rojo actuales:

- **R1 (CI/CD)** — mitigación: migración canary para workflows.
- **R2 (Make targets)** — mitigación: validar `make build MODULE=x` y documentar atajos.
- **R6 (Duplicidad de assets)** — mitigación: crear `packages/*` con verificación hash.

## Enlaces rápidos

<<<<<<< HEAD
- **Preview briefing**: https://example.pages.dev/
- **Producción briefing**: https://example.pages.dev/
- **Logs de auditoría**: `audits/`
- **CHANGELOG**: [ver registro](changelog.md)
=======
- **Preview briefing**: utilizar la URL hash publicada por Cloudflare Pages (salida `deploy-preview.preview_url`)
- **Producción briefing**: https://runart-foundry.pages.dev/
- **Logs de auditoría**: `audits/`
- **CHANGELOG**: [ver registro](CHANGELOG.md)
>>>>>>> chore/bootstrap-git
- **Registro de incidentes**: [abrir tablero](incidents.md)

## Anexos

- Métricas y convenciones: `docs/architecture/000_overview.md`
- Workflow compartido propuesto: `docs/architecture/040_ci_shared.md`
- Próximo tablero dinámico: se actualizará quincenalmente tras cada iteración.
