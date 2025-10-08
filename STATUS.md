# Estado Operativo — RUNArt Foundry

## Resumen Ejecutivo

- **Objetivo actual**: Consolidar la documentación y preparar la transición del monorepo hacia la estructura modular definida en `docs/architecture/020_target_structure.md`.
- **Salud general**: CI/CD estable; documentación estratégica 000–070 publicada y enlazada en MkDocs.
- **Prioridades inmediatas**: Adoptar el linter de documentación, completar plantillas de colaboración y planificar el job `docs-lint` en GitHub Actions.
- **Novedad**: Purga y smokes OTP en producción registrados vía auto-fill; dashboards por rol estables para owner/equipo/cliente.

## Semáforo por módulo

| Módulo | Estado | Comentarios |
| --- | --- | --- |
| `apps/briefing` | � | Dashboards por rol en producción con purga + smokes OTP completados (auto-fill 2025-10-08T15:00Z). |
| `services/*` | ⚪ | Aún en fase de diseño; plan detallado en `060_migration_plan.md` (F5). |
| `packages/*` | ⚪ | En backlog; creación de `packages/env-banner` programada para F3. |
| `tools/*` | 🟡 | Scripts legacy en `scripts/`; migración a `tools/` en progreso (F2) junto al nuevo linter. |

## Últimos hitos
- 2025-10-08 — Purga y smokes de producción marcados como listos (auto-fill, ver `_reports/` y `_reports/autofill_log_20251008T1500Z.md`).
- 2025-10-08 — Release automático registrado en CHANGELOG (ops).
- 2025-10-07 — Dashboards por rol activos en Cloudflare Pages (`/dash/*`) con middleware unificado y logging en `LOG_EVENTS`.
- 2025-10-07 — Redeploy de Cloudflare Pages (`runart-foundry`) tras consolidación; Access validado vía smoke test CLI.
- 2025-10-06 — Release automático registrado en CHANGELOG (ops).
- Documentos de arquitectura `000`–`070` validados y enlazados en navegación MkDocs.
- Sección “Arquitectura” visible en `briefing/` con contenido unificado vía snippets.
- Plan de migración incremental (`060_migration_plan.md`) con fases F1–F5 y checklist por PR.
- Playbook de switch (`065`) y cleanup post-switch (`075`) publicados con auditorías requeridas.

## Próximos 7 días (sprint)

1. Habilitar y monitorear los checks “Docs Lint” y “Environment Report” en las PR activas.
2. Ejecutar `status-update` tras los merges de documentación y validar el commit automático.
3. Socializar `docs/ops/integracion_operativa.md` con stewards y actualizar playbooks internos.
4. Definir responsables (stewards) por módulo en la matriz del semáforo.
5. Programar limpieza de la capa `briefing/` tras 48 h de estabilidad siguiendo `docs/architecture/075_cleanup_briefing.md`.
6. Monitorear `LOG_EVENTS` y Access tras el auto-fill para recopilar evidencia real de tráfico.
7. Diseñar widgets/KPIs específicos por rol aprovechando los smokes completados.

## Integración Operativa — Iteración 3

- **Objetivo:** Automatizar control de calidad y reporting CI.
- **Documentación:** `docs/ops/integracion_operativa.md`.

| Workflow | Estado | Comentarios |
| --- | --- | --- |
| Docs Lint | ⏳ Pending activation | Primera ejecución en PR piloto pendiente de confirmar.
| Status Update | ⏳ Pending activation | Se activará tras el siguiente merge a `main`.
| Env Report | ⏳ Pending activation | Requiere validar detección de URL de preview en una PR real.

## Riesgos activos

Consultar `docs/architecture/070_risks.md`. Riesgos en rojo actuales:

- **R1 (CI/CD)** — mitigación: migración canary para workflows.
- **R2 (Make targets)** — mitigación: validar `make build MODULE=x` y documentar atajos.
- **R6 (Duplicidad de assets)** — mitigación: crear `packages/*` con verificación hash.

## Enlaces rápidos

- **Preview briefing**: https://example.pages.dev/
- **Producción briefing**: https://example.pages.dev/
- **Logs de auditoría**: `audits/`
- **CHANGELOG**: [ver registro](changelog.md)
- **Registro de incidentes**: [abrir tablero](incidents.md)

## Anexos

- Métricas y convenciones: `docs/architecture/000_overview.md`
- Workflow compartido propuesto: `docs/architecture/040_ci_shared.md`
- Próximo tablero dinámico: se actualizará quincenalmente tras cada iteración.
