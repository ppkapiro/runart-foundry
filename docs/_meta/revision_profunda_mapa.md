---
generated_by: copilot
phase: revision_profunda_v2
date: 2025-10-23T14:18:42-04:00
repo: runart-foundry
branch: main
---

# Revisión Profunda V2 — Mapa de documentación

Leyenda: 🟢 activo · 🟡 incierto · 🔴 histórico

## Árbol resumido (nivel top-level)
- 🟢 docs/ — 218 (activos: 218)
  - adr/, architecture/, auditoria/, ci/, i18n/, integration_wp_staging_lite/, internal/, ops/, seo/, ui_roles/, ux/ ...
- 🟡 apps/ — 25,576 (activos: 209)
  - briefing/docs/** contiene documentación embebida activa
- 🟢 .github/ — 53 (activos: 44)
  - workflows/ (pipelines operativos)
- 🔴 _archive/ — 220 (activos: 0)
- 🔴 mirror/ — 12,537 (activos: 0)
- 🔴 _reports/ — 142 (activos: 0)
- 🔴 reports/ — 7 (activos: 0)
- 🔴 ci_artifacts/ — 252 (activos: 0)
- 🟡 tools/ — 114 (activos: 0)
- 🟡 scripts/ — 20 (activos: 0)
- 🟡 wp-content/ — 18 (activos: 0)
- 🟡 plugins/ — 2 (activos: 0)
- 🔴 _dist/ — 7 (activos: 0)
- 🔴 _artifacts/ — 1 (activos: 0)
- 🔴 _tmp/ — 8 (activos: 0)
- 🟡 content/ — 2 (activos: 0)
- (raíz) README.md, STATUS.md, NEXT_PHASE.md, CHANGELOG.md — 🟡 incierto

## Mapa de cobertura (activos/total por carpeta)
- docs/: 218/218 (100%)
- .github/: 44/53 (~83%)
- apps/: 209/25,576 (~0.8%)
- _archive/: 0/220 (0%)
- mirror/: 0/12,537 (0%)
- _reports/: 0/142 (0%)
- reports/: 0/7 (0%)
- ci_artifacts/: 0/252 (0%)
- tools/: 0/114 (0%) — incierto (scripts utilitarios; no docs formales)
- scripts/: 0/20 (0%) — incierto (comentarios útiles, no docs)

Notas:
- La cobertura “activa” se basa en heurística de rutas: docs/** y .github/workflows/** se marcan activas por rol operativo.
- apps/ contiene una mezcla mayoritariamente de código; solo la documentación bajo apps/briefing/docs/** se considera activa.
