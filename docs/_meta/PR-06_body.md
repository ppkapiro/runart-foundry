# PR-06 — Status operativo mínimo + Briefing → live/

## Qué hace
- Genera `docs/status.json` con estado operativo mínimo (conteos, refs, flags preview/prod)
- Añade target `make status_update` para regenerar el JSON
- Actualiza `docs/live/operations/status_overview.md` para enlazar el JSON y documentar regeneración
- Documenta en `apps/briefing/README_briefing.md` que la fuente canónica es `docs/live/`

## Qué NO hace
- No toca infraestructura de deploy ni endpoints de verificación (preview_ok/prod_ok se dejan como true con TODO)

## Validación esperada
- CI en verde; 0 errores strict.
- `docs/status.json` generado y enlazado desde status_overview.md
