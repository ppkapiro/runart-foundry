---
generated_by: copilot
phase: pr-02-raiz-alineada
date: 2025-10-23T15:00:00-04:00
repo: runart-foundry
branch: feature/pr-02-raiz-alineada
---

# PR-02: Raíz alineada — roles claros y enlaces canónicos (sin mover contenido por ahora)

Estado: Draft

## Objetivo
Alinear los documentos de raíz (`README.md`, `STATUS.md`, `NEXT_PHASE.md`, `CHANGELOG.md`) con la fuente canónica `docs/live/`, estableciendo enlaces claros y el rol de cada uno. No mover ni borrar en este PR; si se decide migración/duplicación, se hará en PRs posteriores.

## Alcance (incluido)
- `README.md` (raíz): confirmar rol de portada del repositorio y añadir enlace destacado a `docs/live/index.md`.
- `STATUS.md`: enlazar a `docs/live/operations/status_overview.md` (creado en PR-01) como referencia operativa canónica.
- `NEXT_PHASE.md`: aclarar rol (plan operativo) con enlace a hub canónico correspondiente (Operaciones o Roadmap) y/o sugerir conversión a issues/roadmap.
- `CHANGELOG.md`: mantener como registro de cambios en raíz y enlazar desde `docs/live/index.md`.

## No incluido (fuera de alcance de PR-02)
- No mover/renombrar los archivos de raíz.
- No activar validadores de CI.
- No realizar limpieza de histórico (eso ocurre en lotes posteriores).

## Implementación (pasos)
1) `README.md`
	- Añadir sección “Documentación canónica” con enlace a `docs/live/index.md`.
	- Mantener contenido actual; solo agregar el enlace canónico.
2) `STATUS.md`
	- Añadir enlace a `docs/live/operations/status_overview.md` como panel de estado canónico.
3) `NEXT_PHASE.md`
	- Añadir nota de rol y enlace a hub canónico (Operaciones/Roadmap).
4) `CHANGELOG.md`
	- Verificar presencia y enlazar desde `docs/live/index.md` (en PR-01 ya enlazado el índice; aquí solo asegurar consistencia del mensaje en raíz).

## Commits sugeridos
1) `docs(root): README enlaza a docs/live/index.md (fuente canónica)`
2) `docs(root): STATUS enlaza a operations/status_overview.md`
3) `docs(root): NEXT_PHASE aclara rol y enlaza a hub canónico`
4) `docs(root): referencias consistentes a CHANGELOG desde docs/live`

## Cómo validar localmente (manual, sin CI)
- Abrir `README.md` y verificar el enlace a `docs/live/index.md`.
- Abrir `STATUS.md` y navegar a `docs/live/operations/status_overview.md`.
- Abrir `NEXT_PHASE.md` y confirmar enlaces al hub canónico.
- Confirmar que no se movió ni renombró contenido.

## Criterios de aceptación
- Roles claros en los cuatro documentos de raíz y enlaces canónicos funcionales.
- Coherencia con PR-01 (hubs y `status_overview` existentes).
- 0 enlaces rotos observados en revisión básica.

## Título del PR sugerido
PR-02: Raíz alineada — roles claros y enlaces canónicos (sin mover contenido)
