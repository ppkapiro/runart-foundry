---
generated_by: copilot
phase: pr-01-briefing-canon
date: 2025-10-23T15:10:00-04:00
repo: runart-foundry
branch: feature/pr-01-briefing-canon
status: active
owner: reinaldo.capiro
updated: 2025-10-23
audience: internal
tags: [briefing, runart, ops]
---

# Estado operativo — Overview

Esta vista consolida el estado operacional a partir de artefactos en `docs/ops/` y tareas de automatización.

## Fuente de verdad (JSON)
- Snapshot de estado: [`docs/status.json`](../../status.json)
  - Campos: `generated_at`, `preview_ok`, `prod_ok`, `last_ci_ref`, `docs_live_count`, `archive_count`
  - **Última ref CI**: ver `last_ci_ref` en el JSON

## Cómo regenerar
```bash
make status_update
```
O ejecuta directamente:
```bash
python3 scripts/gen_status.py
```

## Tareas locales relevantes (VS Code)
- Auditoría Aislamiento Staging — valida aislamiento de staging.
- Reparación AUTO-DETECT (IONOS/raíz) — detección y reparación asistida.
- Reparación Automática Prod/Staging — rutina de saneamiento.
- Reparación Final Prod/Staging (Raíz) — cierre de reparaciones.

## Próximos pasos
- Integrar validadores automáticos (links, frontmatter) y publicar métricas ligeras aquí.
- Añadir tablero con checks básicos (ejecuciones recientes, diferencias Prod/Staging).
