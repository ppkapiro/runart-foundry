---
generated_by: copilot
phase: pr-02-root-alignment
date: 2025-10-23T00:00:00-04:00
repo: runart-foundry
branch: feature/pr-02-root-alignment
---

# Mapa de Impacto Root Alignment

## Referencias actuales desde otros docs
- README.md: enlazado desde la portada de GitHub y algunos scripts de onboarding.
- STATUS.md: referenciado por docs/live/operations/status_overview.md y workflows de verificación.
- NEXT_PHASE.md: citado en docs/_meta/plan_fase2_curaduria.md y en algunos reportes de avance.
- CHANGELOG.md: enlazado desde docs/live/index.md y por scripts de release.

## Referencias externas
- docs/live/operations/status_overview.md: enlaza a STATUS.md y status.json.
- docs/live/index.md: debe enlazar a README.md y CHANGELOG.md.
- Briefing: docs/live/index.md como fuente canónica.

## Flujos afectados
- .github/workflows/*: validadores, release, healthcheck, status-sync.

## Dependencias de sincronización
- scripts/tools/sync_status.py
- scripts/tools/git_set_origin_reference.sh