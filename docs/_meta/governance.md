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

## Políticas de Staging y Deployment

### Canon del Tema

- **Tema oficial:** RunArt Base (`runart-base`)
- **Ruta canónica:** `/homepages/7/d958591985/htdocs/staging/wp-content/themes/runart-base/`
- Toda documentación y scripts apuntan a `runart-base` como referencia.

### Operación Congelada (Freeze Policy)

- **READ_ONLY=1:** Activado por defecto en todos los scripts de deployment
- **DRY_RUN=1:** Activado por defecto; rsync ejecuta con `--dry-run`
- **SKIP_SSH=1:** Soportado para CI y documentación sin conexión real
- Cualquier deployment requiere issue aprobado y desactivación explícita de flags

### CI Guardrails

1. **Dry-run Guard** (`.github/workflows/guard-deploy-readonly.yml`):
   - Verifica que scripts tienen defaults READ_ONLY/DRY_RUN activos
   - Falla si falta marcador `CI-GUARD: DRY-RUN-CAPABLE`

2. **Media Review Guard**:
   - Falla PRs que tocan `wp-content/uploads/`, `runmedia/` o `content/media/` sin label `media-review`
   - Protege contra cambios accidentales en biblioteca de medios

3. **Structure Guard** (`.github/workflows/structure-guard.yml`):
   - Valida estructura de directorios conforme a governance
   - Falla si se detectan rutas prohibidas o archivos fuera de lugar

### Deployment Policy

- **Staging:** Solo bajo issue aprobado + ventana de mantenimiento documentada
- **Producción:** Requiere smoke tests exitosos en staging + sign-off del owner
- **Rollback:** Backups automáticos en `/tmp/` del servidor; procedimiento documentado en Deployment Master

## TODO
- Completar RACI de documentación
- Integrar validación de antigüedad (>90d) en workflow semanal (HECHO: docs-stale-dryrun.yml)
- Evaluar badges de freshness en índices live/
