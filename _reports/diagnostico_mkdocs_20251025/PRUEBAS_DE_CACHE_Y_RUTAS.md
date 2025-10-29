# PRUEBAS_DE_CACHE_Y_RUTAS — 2025-10-25

## Directorio de ejecución
- Uso recomendado y aplicado: `make -C apps/briefing serve-local`
  - cwd efectivo: `/home/pepe/work/runartfoundry/apps/briefing`
  - mkdocs.yml activo esperado: `/home/pepe/work/runartfoundry/apps/briefing/mkdocs.yml`

## Evidencia de mkdocs activo
- Log de `serve-local` (extracto):
  - `INFO - Building documentation...`
  - `Cleaning site directory`
  - Páginas en docs pero fuera de nav: (lista extensa)
  - `Serving on http://127.0.0.1:8000/`
- Nota: el intento de `curl` interrumpió un `serve` previo; se recomienda usar una terminal separada para `curl`.

## Limpieza y artefactos
- `mkdocs serve` reportó `Cleaning site directory` al iniciar, lo cual descarta residuos persistentes de builds anteriores.
- Build local manual (`mkdocs build`) generó `apps/briefing/site/` y el `index.html` correspondiente al esquema nuevo.

## Carga de overrides
- Overrides activos en `apps/briefing/overrides/`:
  - `main.html` (inyecta skip-link, meta noindex, control de roles/env)
  - `extra.css`
  - `roles.js`

## Variables de entorno
- `.env.local` establece `AUTH_MODE=none`. No hay variables detectadas que alteren `docs_dir` o `site_dir`.
- `assets/auth-mode.js` se sobreescribe en `serve-local` para forzar `window.__AUTH_MODE__='none'` (solo afecta comportamiento de JS del frontend, no rutas de documentación).

## mkdocs.yml cargados en el repo
- Activo: `apps/briefing/mkdocs.yml`
- Legacy (archivado): `_archive/legacy_removed_20251007/briefing/mkdocs.yml`

## Comprobación de navegación efectiva
- Derivada de `apps/briefing/mkdocs.yml` (3 partes): Inicio, Cliente · RunArt Foundry, Equipo Técnico · Briefing System, Proyectos.

