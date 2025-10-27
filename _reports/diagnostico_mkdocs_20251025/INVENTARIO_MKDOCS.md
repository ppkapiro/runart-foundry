# INVENTARIO_MKDOCS — 2025-10-25

Este inventario lista todos los archivos de configuración de MkDocs encontrados en el monorepo y resume sus parámetros clave.

## Resumen

Encontrados 2 archivos `mkdocs.yml`:

1. apps/briefing/mkdocs.yml (ACTIVO para desarrollo local)
2. _archive/legacy_removed_20251007/briefing/mkdocs.yml (LEGACY — archivado)

---

## 1) apps/briefing/mkdocs.yml
- Ruta: /home/pepe/work/runartfoundry/apps/briefing/mkdocs.yml
- docs_dir: (por defecto) `docs`
- site_dir: (por defecto) `site`
- theme:
  - name: material
  - language: es
  - features: navigation.sections, navigation.expand, content.code.copy, content.action.edit, search.suggest
  - palette: default / primary: indigo / accent: light blue
  - custom_dir (overrides): `overrides`
- plugins: [search]
- extra_css:
  - assets/extra.css
  - assets/runart/userbar.css
  - assets/runart/dashboards.css
- extra_javascript (orden):
  1) assets/auth-mode.js
  2) assets/env-flag.js
  3) assets/runart/userbar.js
  4) assets/runart/dashboards.js
- overrides/activos: apps/briefing/overrides/
  - main.html
  - extra.css
  - roles.js

## 2) _archive/legacy_removed_20251007/briefing/mkdocs.yml
- Ruta: /home/pepe/work/runartfoundry/_archive/legacy_removed_20251007/briefing/mkdocs.yml
- docs_dir: (por defecto) `docs`
- site_dir: (por defecto) `site`
- theme:
  - name: material
  - language: es
  - custom_dir (overrides): `overrides`
- plugins: [search]
- extra_css:
  - overrides/extra.css
- Notas: Este archivo corresponde al micrositio legacy archivado; no debe utilizarse para desarrollo. Mantenerlo sólo para trazabilidad.

## Observaciones clave
- No se detectaron otros `mkdocs.yml` en el repo.
- El `mkdocs.yml` activo para el Briefing nuevo es el de `apps/briefing/`.
- La presencia del `mkdocs.yml` legacy en `_archive/` no afecta si los comandos se ejecutan desde `apps/briefing/`. Podría causar confusiones si se ejecuta `mkdocs serve` desde dentro de `_archive/` por error.
