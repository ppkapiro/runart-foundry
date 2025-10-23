# PR-07 — Gobernanza + poda semanal (dry-run)

## Qué hace
- Completa `docs/_meta/governance.md` con ciclo de vida documental (Draft → Active → Stale → Archived) y owners por carpeta
- Crea `CONTRIBUTING.md` en raíz con guías de frontmatter, enlaces, tags, flujo de PR y CI
- Añade workflow `.github/workflows/docs-stale-dryrun.yml` (ejecuta lunes 09:00 UTC):
  - Detecta documentos en `docs/live/` con `updated` >90 días
  - Genera reporte `docs/_meta/stale_candidates.md` (dry-run, sin commits automáticos)
  - Sube reporte como artifact descargable

## Qué NO hace
- No mueve ni modifica archivos automáticamente (solo genera reporte)
- No integra revisión manual forzosa (el owner debe actuar sobre el reporte)

## Validación esperada
- CI en verde; 0 errores strict.
- Workflow programado activo y testeable con `workflow_dispatch`
