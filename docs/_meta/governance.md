# Gobernanza documental (RunArt Foundry / Briefing)

> Placeholder inicial — Fase 1 (preparar terreno)

Esta guía define reglas mínimas para mantener la documentación ordenada bajo el modelo de tres capas: `live/`, `archive/`, `_meta/`.

## Objetivos
- Claridad entre contenido vigente vs histórico.
- Trazabilidad y audiencias claras.
- Estandarización (naming, frontmatter, revisiones).

## Capas
- `docs/live/`: Contenido vigente, referenciado por operaciones y producto.
- `docs/archive/`: Histórico estable, solo lectura salvo correcciones menores.
- `docs/_meta/`: Reglas, plantillas, resúmenes de fase, inventarios.

## Naming y convenciones
- Fechas: `YYYY-MM-DD` para documentos cronológicos (ej.: `2025-10-23_resumen.md`).
- Fases: prefijo `F#_` cuando aplique (ej.: `F7_*`).
- Idioma: sufijos `-es`/`-en` solo si coexisten versiones paralelas.
- Evitar espacios; usar `_` o `-` de forma consistente.

## Frontmatter requerido
Todos los documentos deben incluir el frontmatter definido en `_meta/frontmatter_template.md`.

Campos mínimos: `status`, `owner`, `updated`, `audience`, `tags`.

## Ciclo de vida documental
1. **Draft**: documento en creación, no activo
2. **Active**: vigente y operativo (en `docs/live/`)
3. **Stale**: sin actualización >90 días (candidato a revisión o archivado)
4. **Archived**: movido a `docs/archive/` por cierre de fase o desuso

### Detección automática de stale
- Cada lunes a las 09:00 UTC, el workflow `docs-stale-dryrun.yml` detecta documentos con `updated` >90 días
- Se genera reporte `docs/_meta/stale_candidates.md` (dry-run, sin commits automáticos)
- El owner del documento debe revisar y decidir: actualizar `updated`, archivar o marcar como evergreen

### Archivado
- Movimiento manual a `docs/archive/YYYY-MM/<tema>/`
- Actualizar enlaces entrantes desde `live/` (eliminar o redirigir a nueva versión)
- Aplicar frontmatter con `status: archived`

## Audiencias
- `internal`: equipo técnico/ops.
- `external`: stakeholders externos (si aplica).

## Roles y responsabilidades
- **Owner por documento** (campo `owner`): responsable de actualizar y mantener el contenido
- **Owners por carpeta**:
  - `docs/live/architecture/`: reinaldo.capiro
  - `docs/live/operations/`: reinaldo.capiro
  - `docs/live/ui_roles/`: reinaldo.capiro
  - `docs/_meta/`: reinaldo.capiro
- PR de cambios en docs debe asignar revisor de gobernanza (owner de carpeta o designado)

## TODO
- Completar RACI de documentación
- Integrar validación de antigüedad (>90d) en workflow semanal (HECHO: docs-stale-dryrun.yml)
- Evaluar badges de freshness en índices live/
