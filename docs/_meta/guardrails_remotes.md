---
generated_by: copilot
phase: post_revision_v2
date: 2025-10-23T14:49:59-04:00
repo: runart-foundry
branch: main
---

# Guardarraíles — Remotos Git

## Señales de alerta
- Mensaje “This repository moved. Please use the new location” tras cada push.
- Diferencias entre `origin` y `upstream` no intencionadas.
- Colaboradores reportan pushes sin efecto en el repositorio de la organización.

## Pasos de verificación previos a cualquier push
1) Ver remotos configurados:
   - `git remote -v`
2) Confirmar que `origin` apunta a: `git@github.com:RunArtFoundry/runart-foundry.git`
3) Verificar branch actual:
   - `git rev-parse --abbrev-ref HEAD` (debería ser `main` salvo política distinta)
4) Probar un push en seco si es necesario:
   - `git push --dry-run origin main`

## Recomendaciones
- Documentar en CONTRIBUTING (si existe) la URL canónica de `origin` y los pasos de verificación.
- Si no existe CONTRIBUTING.md, considerar crear `docs/_meta/contributing_notes.md` con esta información.
- Para nuevos entornos/máquinas, validar remotos tras clonar.

## Referencias
- `docs/_meta/phase0_remote_canonical.md`
- `docs/_meta/remote_canonical_APPROVED.md`
- `scripts/tools/git_set_origin_reference.sh` (uso de referencia, no autoejecutado)
