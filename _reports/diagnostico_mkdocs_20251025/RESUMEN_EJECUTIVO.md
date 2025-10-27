# RESUMEN_EJECUTIVO — 2025-10-25

## Diagnóstico preliminar
- mkdocs en local está utilizando el archivo correcto: `apps/briefing/mkdocs.yml`.
- El contenido servido/compilado corresponde al esquema **nuevo** con 3 bloques (Cliente / Equipo Técnico / Proyectos).
- La presencia de un `mkdocs.yml` legacy en `_archive/legacy_removed_20251007/briefing/` puede generar confusión si se ejecuta `mkdocs serve` fuera de `apps/briefing/` o si se navega directamente a artefactos legacy.

## Causas raíz más probables
1) Ejecución de `mkdocs serve` desde un directorio incorrecto (p. ej., raíz del repo o dentro de `_archive/`).
2) Caché del navegador mostrando artefactos previos (preview/prod) en lugar del servidor local `127.0.0.1:8000`.
3) Apertura manual de un `site/` antiguo en el explorador de archivos o en un servidor distinto.

## Impacto
- Percepción de que "se ve el micrositio antiguo" cuando, en realidad, el build local corresponde al nuevo. Esto puede retrasar validaciones de UI/documentación al comparar contra una fuente/tarea equivocada.

## Plan de corrección (3 pasos, reversible)
1) Forzar ruta de configuración en todos los comandos locales
   - Actualizar/usar siempre: `mkdocs serve -f apps/briefing/mkdocs.yml -a 127.0.0.1:8000`
   - Alternativa ya disponible: `make -C apps/briefing serve-local` (recomendado). Añadir a la guía de desarrollo.
2) Neutralizar el mkdocs.yml legacy
   - Renombrar `_archive/legacy_removed_20251007/briefing/mkdocs.yml` → `mkdocs.yml.legacy` o agregar un `README` dentro indicando que no debe usarse.
   - Opcional: añadir un `.mkdocs-ignore` (si se adopta algún tooling que recorra el repo) o mover ese árbol a un ZIP.
3) Añadir banner de fuente activa (solo dev)
   - Inyectar en `overrides/main.html` un pequeño aviso (dev-only) con: `config path`, `docs_dir`, branch. Esto evita dudas futuras.

## Verificación final
- Ejecutar: `make -C apps/briefing serve-local`
- Abrir: `http://127.0.0.1:8000`
- Confirmar en navegación la presencia de: "Cliente · RunArt Foundry", "Equipo Técnico · Briefing System", "Proyectos".
- Asegurar que los endpoints /api no bloquean la UI en local (AUTH_MODE=none ya activo) y que no aparecen redirecciones/Access.

## Referencias
- INVENTARIO_MKDOCS.md
- MAPA_FUENTES_DOCUMENTACION.md
- PRUEBAS_DE_CACHE_Y_RUTAS.md
- DIFERENCIAS_LOCAL_VS_ESPERADO.md
