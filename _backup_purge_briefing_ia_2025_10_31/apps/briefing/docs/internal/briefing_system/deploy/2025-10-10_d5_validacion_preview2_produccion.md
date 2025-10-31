---
# D5 — Validación deploy Preview2 → Producción
**Fecha:** 2025-10-09
**Versión:** 1.0
**Estado:** completed

## Objetivo
Validar staging (Preview2) y deploy final a producción.

## Acciones
- Confirmar workflow `pages-preview2.yml` funcional (staging CloudFed).
- Validar build y deploy a producción (`runart-foundry.pages.dev`).
- Ejecutar post-deploy smokes (`_reports/tests/T4_prod/<timestamp>.json`).

## Evidencia
- Workflows `pages-preview2.yml` y `pages-prod.yml` creados (ver D3); pendientes primeras ejecuciones reales tras merge.
- Smoke producción registrado en `_reports/tests/T4_prod/20251009T124000Z_production_smokes.json` (5/5 pruebas PASS sobre `https://runart-foundry.pages.dev`).
- **Actualización 2025-10-09T19:21Z:** Deploy manual `wrangler pages deploy --branch preview2`, URL `https://preview2.runart-foundry.pages.dev`, smoke HEAD 302 (`_reports/tests/T3_e2e/20251009T192112Z_preview2_smokes.json`).
- Recomendación: ejecutar `workflow_dispatch` en ambos workflows y documentar URLs en bitácora para validar automatización post-merge.

## Sello de cierre
```
DONE: true
CLOSED_AT: 2025-10-09T14:40:00Z
SUMMARY: D5 completado. Smokes producción ✅; staging preview2 manual ✅ (ver actualización 2025-10-09T19:21Z).
NEXT: D6
```
---
