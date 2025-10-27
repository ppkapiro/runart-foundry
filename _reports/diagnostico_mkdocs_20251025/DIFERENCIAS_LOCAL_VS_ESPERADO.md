# DIFERENCIAS_LOCAL_VS_ESPERADO — 2025-10-25

Este documento contrasta lo que se está viendo en local con lo esperado para el Briefing "nuevo".

## Evidencia local (build más reciente)
- Comando: `AUTH_MODE=none make -C apps/briefing build`
- Resultado: PASS — `mkdocs build` completó y generó `apps/briefing/site/`
- Index generado: `apps/briefing/site/index.html`
  - Título: "RUN Art Foundry — Briefing Privado"
  - Hojas de estilo y assets de MkDocs Material cargados
  - Overrides activos (`extra_css`, `overrides/main.html` inyecta meta `noindex`)

## Navegación esperada (nuevo esquema, 3 partes)
- Inicio
- Cliente · RunArt Foundry (varias subsecciones)
- Equipo Técnico · Briefing System (varias subsecciones)
- Proyectos
- Smoke Test

## Navegación legacy (archivo archivado)
- El `mkdocs.yml` legacy en `_archive/legacy_removed_20251007/briefing/` no incluye el grupo "Equipo Técnico · Briefing System" como bloque principal.

## Diferencias detectadas
- Local (site generado) corresponde al esquema NUEVO; se observan rutas y grupos propios del nuevo `mkdocs.yml`.
- Si en algún navegador se observa una UI antigua, es probable que sea por:
  1) Caché de navegador de una build previa o dominio diferente (preview/prod).
  2) Ejecución de `mkdocs serve` fuera de `apps/briefing/` cargando un `mkdocs.yml` distinto.
  3) Exploración manual del `_archive/legacy_removed_20251007/briefing/site/` (si existiera) en lugar del servidor dev.

## Páginas clave verificadas (nuevo)
- `docs/client_projects/runart_foundry/index.md` → presente (OK)
- `docs/internal/briefing_system/index.md` → presente (OK)
- `docs/projects/index.md` → presente (OK)
- `docs/exports/index.md` → presente (OK)

