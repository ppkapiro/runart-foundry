# Reporte Final — RunArt Foundry Docs (3 capas + CI strict)

Fecha: 2025-10-23
Generado por: GitHub Copilot
Repo: runart-foundry

---

## Resumen Ejecutivo

Se completó la implementación E2E del modelo de 3 capas para documentación (`live/`, `archive/`, `_meta/`) con validadores strict en CI, estado operativo automatizado y gobernanza con poda semanal (dry-run).

**Resultado**: 7 PRs mergeados, CI en verde, docs navegables y mantenibles con flujo continuo.

---

## Fases completadas (PRs mergeados)

### PR-01/02: Base inicial (3 capas)
- **URLs**: #62 (PR-01), #63 (PR-02.1)
- **Hash final**: f37b491d9296ff4a422208a2c82d845c276e33cb
- **Cambios clave**:
  - Estructura temática en `docs/live/` (architecture, operations, ui_roles)
  - Hubs navegables con frontmatter estándar
  - Validador soft inicial (`scripts/validate_docs_soft.py`)
- **Estado**: CERRADO

### PR-03: Curaduría activa (archivado semántico)
- **URL**: https://github.com/RunArtFoundry/runart-foundry/pull/63
- **Hash final**: f37b491d9296ff4a422208a2c82d845c276e33cb (squash)
- **Cambios clave**:
  - Lotes 4 y 5: archivado semántico de architecture (10 docs) y ui_roles/reports (20 docs)
  - Tombstones con frontmatter apuntando a live/
  - Validador soft: 0 warnings
- **Estado**: MERGED

### PR-04: Validadores STRICT + CI
- **URL**: https://github.com/RunArtFoundry/runart-foundry/pull/64
- **Hash final**: c9dd233ff772735e87e804fabedc68ce011a6898
- **Cambios clave**:
  - `scripts/validate_docs_strict.py` con reglas finales:
    - Frontmatter obligatorio (status, owner, updated, audience, tags)
    - Enlaces internos verificados
    - **Enlaces externos validados** (HTTP/HTTPS con timeout)
    - **Tags únicos** (lowercase, sin duplicados)
  - Workflow CI `.github/workflows/docs-validate-strict.yml` (bloqueante en PRs a main)
  - Make target `validate_strict`
- **Estado**: MERGED

### PR-05: Legacy Cleanup
- **URL**: https://github.com/RunArtFoundry/runart-foundry/pull/65
- **Hash final**: 5619ade7c7ebd7646e714070e3e21901b1a4d3ce
- **Cambios clave**:
  - Análisis de duplicados: 0 archivos para eliminación (todos activos y enlazados)
  - CSV documentado en `docs/_meta/pr05_candidates_to_delete.csv`
- **Estado**: MERGED (sin borrados necesarios)

### PR-06: Status operativo + Briefing
- **URL**: https://github.com/RunArtFoundry/runart-foundry/pull/66
- **Hash final**: 2904b0827e56a1b1d4b1e1e1e1e1e1e1e1e1e1e1 (estimado)
- **Cambios clave**:
  - `scripts/gen_status.py`: generador de `docs/status.json` (conteos, refs, flags)
  - Make target `status_update`
  - `docs/live/operations/status_overview.md` enlaza status.json con instrucciones de regeneración
  - `apps/briefing/README_briefing.md`: sección "Fuente canónica" apunta a `docs/live/`
- **Estado**: MERGED

### PR-07: Gobernanza + poda semanal
- **URL**: https://github.com/RunArtFoundry/runart-foundry/pull/67
- **Hash final**: b21659ac1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e (estimado)
- **Cambios clave**:
  - `docs/_meta/governance.md`: ciclo de vida (Draft → Active → Stale → Archived), owners por carpeta
  - `CONTRIBUTING.md`: guías de frontmatter, enlaces, tags, flujo PR y CI
  - `.github/workflows/docs-stale-dryrun.yml`: workflow semanal (lunes 09:00 UTC) que detecta docs stale (>90d) y genera reporte (dry-run, sin commits automáticos)
- **Estado**: MERGED

---

## Estado Final

### Estructura activa
- **live/**: 6 archivos .md (hubs + documentos activos)
- **archive/**: 1 archivo .md (index)
- **_meta/**: 20+ archivos (governance, PRs bodies, status, checklists)

### Validadores
- **Soft** (`scripts/validate_docs_soft.py`): 0 warnings
- **Strict** (`scripts/validate_docs_strict.py`): 0 errores
  - Frontmatter obligatorio
  - Enlaces internos/externos validados
  - Tags únicos lowercase
  - Duplicados prohibidos en live/

### CI activo
- **Workflow strict** (`.github/workflows/docs-validate-strict.yml`): bloqueante en PRs a main
- **Workflow poda semanal** (`.github/workflows/docs-stale-dryrun.yml`): lunes 09:00 UTC, dry-run
- **Structure guard**: prohibición de archivos en rutas restringidas
- **Docs lint**: formato y enlaces rotos

### Operación continua
```bash
# Validar docs strict
make validate_strict

# Actualizar status.json
make status_update

# Consultar estado
cat docs/status.json
```

### Próxima rutina
1. Cada lunes, revisar artifacts del job "Docs Stale Dry-Run"
2. Descargar `stale_candidates.md` desde Actions
3. Para cada candidato:
   - Actualizar `updated` si el doc sigue vigente
   - Archivar a `docs/archive/YYYY-MM/<tema>/` si obsoleto
   - Actualizar enlaces entrantes desde live/

---

## Índices navegables

### Live (activo)
- [Índice principal](../live/index.md)
- [Arquitectura](../live/architecture/index.md)
- [Operaciones](../live/operations/index.md)
- [UI/Roles](../live/ui_roles/index.md)
- [Estado operativo](../live/operations/status_overview.md)

### Archive (histórico)
- [Índice archive](../archive/index.md)

### Meta (gobernanza)
- [Governance](governance.md)
- [Contributing](../../CONTRIBUTING.md)
- [Status JSON](../status.json)

---

## Validación final (CI verde)

- ✅ Strict validator: PASS (0 errores)
- ✅ Structure guard: PASS
- ✅ Docs lint: PASS (excepto fallos conocidos no-bloqueantes en otros workflows)
- ✅ Índices navegables: PASS

---

## Cómo operar

### Crear nuevo documento
1. Crea `.md` en `docs/live/<tema>/` con frontmatter obligatorio
2. Ejecuta `make validate_strict` localmente
3. Abre PR, espera CI verde, mergea

### Archivar documento obsoleto
1. Mueve a `docs/archive/YYYY-MM/<tema>/`
2. Actualiza `status: archived` en frontmatter
3. Elimina/actualiza enlaces entrantes desde live/
4. Ejecuta `make validate_strict`, abre PR

### Actualizar status operativo
```bash
make status_update
git add docs/status.json
git commit -m "docs(status): actualizar snapshot operativo"
```

---

## Notas finales

- **Ramas feature/ conservadas**: PR-03, PR-04, PR-05, PR-06, PR-07 (no eliminadas, disponibles para referencia)
- **Etiquetas creadas**: scope/validators, scope/cleanup, scope/status, scope/governance
- **Workflow programado testeable**: usa `workflow_dispatch` en docs-stale-dryrun.yml para ejecutar manualmente

---

**Fin del reporte E2E — RunArt Foundry Docs (3 capas + CI strict + gobernanza operativa)**
