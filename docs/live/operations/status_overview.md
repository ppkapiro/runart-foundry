---
generated_by: copilot
phase: pr-01-briefing-canon
date: 2025-10-23T15:10:00-04:00
repo: runart-foundry
branch: feature/pr-01-briefing-canon
---

# Estado operativo — Overview

Esta vista consolida el estado operacional a partir de artefactos en `docs/ops/` y tareas de automatización.

## Fuente de verdad (JSON)
- Snapshot de estado: `docs/ops/status.json`
  - Uso: indicadores de ambientes, integraciones y últimas verificaciones.

## Tareas locales relevantes (VS Code)
- Auditoría Aislamiento Staging — valida aislamiento de staging.
- Reparación AUTO-DETECT (IONOS/raíz) — detección y reparación asistida.
- Reparación Automática Prod/Staging — rutina de saneamiento.
- Reparación Final Prod/Staging (Raíz) — cierre de reparaciones.

## Próximos pasos
- Integrar validadores automáticos (links, frontmatter) y publicar métricas ligeras aquí.
- Añadir tablero con checks básicos (ejecuciones recientes, diferencias Prod/Staging).
