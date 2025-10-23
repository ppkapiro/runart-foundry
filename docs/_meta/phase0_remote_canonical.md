---
generated_by: copilot
phase: post_revision_v2
date: 2025-10-23T14:31:24-04:00
repo: runart-foundry
branch: main
---

# Normalización de remoto canónico (sin ejecutar)

Este documento propone alinear el remoto `origin` a la URL canónica para evitar avisos de reubicación y consolidar los pushes futuros.

## Estado actual (solo informativo)
Remotos configurados:

```
origin  git@github.com:ppkapiro/runart-foundry.git (fetch)
origin  git@github.com:ppkapiro/runart-foundry.git (push)
upstream        git@github.com:RunArtFoundry/runart-foundry.git (fetch)
upstream        git@github.com:RunArtFoundry/runart-foundry.git (push)
```

## Remoto propuesto
- origin → `git@github.com:RunArtFoundry/runart-foundry.git`
- upstream → (opcional) mantenerlo apuntando al mismo o eliminar si no se usa.

## Motivo
- Evitar los warnings de “This repository moved” en cada push.
- Consolidar el remoto principal al repositorio canónico de la organización.

## Comando sugerido (no ejecutar aún)

```bash
# Actualizar remoto origin al canónico (RunArtFoundry)
git remote set-url origin git@github.com:RunArtFoundry/runart-foundry.git
```

> Nota: No se ejecutó ningún cambio. Este archivo deja constancia de la recomendación.

---

Decisión pendiente: OWNER confirma actualización de origin a git@github.com:RunArtFoundry/runart-foundry.git
