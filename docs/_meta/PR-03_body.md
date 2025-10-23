---
generated_by: copilot
phase: pr-03-curaduria-activa
date: 2025-10-23T00:00:00-04:00
repo: runart-foundry
branch: feature/pr-03-curaduria-activa
---
# PR-03 — Curaduría Activa (consolidación live/archive + validadores soft)

## Qué hace este PR
- Reorganiza documentos vigentes en `docs/live/`.
- Archiva documentos históricos en `docs/archive/`.
- Aplica frontmatter universal.
- Activa validadores en modo “soft” para detección de inconsistencias.

## Qué NO hace
- No elimina contenido.
- No fuerza errores de CI (solo reporta advertencias).

## Validación
- Verificar índices actualizados y rutas correctas.
- Consultar `docs/_meta/validators_report_soft.md`.

## Criterios de aceptación
- Frontmatter presente en 100 % de los documentos.
- Enlaces verificados.
- Reporte soft sin errores críticos.

## Siguientes pasos
- Merge de PR-03 tras revisión.
- Activar validadores en modo “strict” (PR-04).
