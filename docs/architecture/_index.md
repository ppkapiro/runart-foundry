# Arquitectura del Monorepo RUNArt Foundry

Bienvenida al dossier de arquitectura que guía la Fase B de reorganización. Aquí encontrarás el mapa completo: estado actual, objetivos, estándares y plan de migración para evolucionar el monorepo sin interrumpir CI/CD.

## Cómo navegar

1. [000 — Resumen ejecutivo](000_overview.md) · Contexto general y principios.
2. [010 — Inventario actual](010_inventory.md) · Directorios, pipelines y artefactos vigentes.
3. [020 — Estructura objetivo](020_target_structure.md) · Árbol propuesto `/apps`, `/services`, `/packages`, `/tools`.
4. [030 — Convenciones y estándares](030_conventions.md) · Branching, layout mínimo por módulo, entorno.
5. [040 — Workflows compartidos](040_ci_shared.md) · Plantillas reusables y contratos de CI/CD.
6. [050 — Targets de Make unificados](050_make_targets.md) · Interface común para desarrollos y bots.
7. [060 — Plan de migración por fases](060_migration_plan.md) · Roadmap incremental con pruebas y rollback.
8. [070 — Registro de riesgos](070_risks.md) · Riesgos, mitigaciones y seguimiento.
9. [075 — Limpieza post-switch `briefing/`](075_cleanup_briefing.md) · Eliminación de la capa temporal tras validar producción.

## Próximos anexos

- `STATUS.md`: tablero vivo de progreso por fase.
- `CHANGELOG.md`: bitácora de decisiones y PRs aplicados.
- `INCIDENTS.md`: lecciones aprendidas de incidentes relacionados.

## Cómo contribuir

- Cada documento numérico es propiedad compartida; usa PRs pequeños con contexto.
- Incluye referencias cruzadas cuando un cambio afecte a múltiples piezas.
- Ejecuta `make lint-docs` (por definir) antes de mergear para asegurar consistencia.
