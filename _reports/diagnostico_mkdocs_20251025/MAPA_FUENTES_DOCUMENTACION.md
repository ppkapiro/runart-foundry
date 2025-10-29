# MAPA_FUENTES_DOCUMENTACION — 2025-10-25

Este mapa describe cómo se compone la documentación del Briefing "nuevo" (interfaz en 3 partes) según `apps/briefing/mkdocs.yml`.

## Raíz del sitio
- Inicio → `docs/index.md`

## Partes principales

1) Cliente · RunArt Foundry
- Raíz: `docs/client_projects/runart_foundry/index.md`
- Subsecciones destacadas:
  - Plan y roadmap → `docs/client_projects/runart_foundry/plan/index.md`
  - Auditorías y métricas → `docs/client_projects/runart_foundry/auditoria/index.md`
  - Decisiones y formularios → `docs/decisiones/index.md`, `docs/decisiones/ficha-proyecto.md`
  - Inbox del cliente → `docs/inbox/index.md`, `docs/inbox/fichas.md`
  - Dashboards → `docs/dashboards/cliente.md`
  - Herramientas para cliente → `docs/editor/index.md`, `docs/editor/editor.md`, `docs/exports/index.md`

2) Equipo Técnico · Briefing System
- Raíz: `docs/internal/briefing_system/index.md`
- Secciones: planes, deploy, CI/QA, guías, auditorías internas, arquitectura, operación
  - Ejemplos: `docs/internal/briefing_system/plans/00_orquestador_fases_runart_briefing.md`, `docs/internal/briefing_system/guides/Guia_QA_y_Validaciones.md`

3) Proyectos
- Raíz: `docs/projects/index.md`
- Contiene fichas YAML (ES/EN) con esquema y plantilla.

## Includes/symlinks
- No se detectan symlinks en `docs/`. La integración se hace vía navegación (nav) en `mkdocs.yml`.
- Overrides de tema en `overrides/` definen comportamiento de UI (roles, env banner) que aplica a todo el sitio.

## Índices clave
- Home: `docs/index.md`
- Cliente: `docs/client_projects/runart_foundry/index.md`
- Equipo técnico: `docs/internal/briefing_system/index.md`
- Proyectos: `docs/projects/index.md`

