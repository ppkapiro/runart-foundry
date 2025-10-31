# Informe Global — IA‑Visual en RunArt Foundry (FASE 4.A)

Fecha: 2025-10-31  
Rama: `feat/ai-visual-implementation`  
Autor: automation-runart

## 1) Resumen ejecutivo

Objetivo: consolidar en un único documento el estado real del sistema IA‑Visual (código, datos, endpoints, mirror, CI/CD y documentación) como base para el plan definitivo hacia un backend editable con la base completa.

Estado general (basado en evidencias del repo y verificación REST en staging):
- Plugin unificado “RunArt IA-Visual Unified” activo en staging; endpoints de diagnóstico responden 200.
- Dataset real “enriched” no localizado en staging en `uploads/runart-jobs/enriched/index.json` (status: NOT_FOUND_IN_STAGING). El sistema opera con dataset de ejemplo (3 ítems) incluido en el plugin/repo.
- Mirror local contiene estructura completa de wp-content/uploads, pero sin payloads pesados versionados; confirma arquitectura sin aportar el índice enriched.
- Documentación, plan maestro y arquitectura IA‑Visual están presentes y actualizados (F7–F10). UI editorial diseñada; faltaría conectar a la base real una vez extraída o sincronizada.

Nivel por fases (indicativo):
- F7 Arquitectura IA‑Visual: COMPLETADA (documentada y con endpoints).
- F8 Embeddings/Correlaciones reales: en estado mock/parcial (listo para rellenar con dataset real).
- F9 Reescrituras/Enriquecidos: dataset de ejemplo (3 ítems) operativo.
- F10 Vista/Panel: plugin y endpoints listos; verificación de datos reales pendiente.

Recomendación inmediata: habilitar un mecanismo de export REST seguro de prod/staging (o acceso alternativo) para recuperar el dataset enriched completo y avanzar a la Opción B (cascada ampliada + normalización si procede).

---

## 2) Arquitectura actual: módulos, scripts, plugins y endpoints activos

Componentes clave:
- Plugins WordPress (código en `tools/`):
  - `runart-ia-visual-unified/` (unificado; REST + shortcode + admin + diagnóstico)
  - `wpcli-bridge-plugin/` (puente histórico y utilidades REST)
  - `runart-ai-visual-panel/` (panel limpio alternativo orientado a lectura desde uploads)
- Datos de ejemplo: `data/assistants/rewrite/` (3 páginas) y equivalente empaquetado en plugins.
- Documentación y plan maestro: `docs/ai/architecture_overview.md`, `PLAN_MAESTRO_IA_VISUAL_RUNART.md`, `research/ai_visual_tools_summary.md`.

Endpoints REST (extracto de registros `register_rest_route`):
- Núcleo de contenido IA‑Visual
  - GET `/wp-json/runart/content/enriched-list`
  - GET `/wp-json/runart/content/enriched` (detalle por `page_id`)
  - POST `/wp-json/runart/content/enriched-approve`
  - POST `/wp-json/runart/content/enriched-merge`
  - POST `/wp-json/runart/content/enriched-request`
  - GET `/wp-json/runart/content/enriched-hybrid`
  - GET `/wp-json/runart/content/wp-pages`
- Correlaciones/Embeddings
  - GET `/wp-json/runart/correlations/suggest-images`
  - POST `/wp-json/runart/embeddings/update`
  - GET/POST `/wp-json/runart/ai-visual/pipeline`
  - POST `/wp-json/runart/ai-visual/request-regeneration`
- Auditoría/Bridge/Diagnóstico
  - GET `/wp-json/runart/bridge/health`, `/bridge/users`, `/bridge/plugins`
  - POST `/wp-json/runart/bridge/cache/flush`, `/bridge/rewrite/flush`
  - GET `/wp-json/runart/audit/pages`, `/audit/images`
  - NUEVOS (diagnóstico): GET `/wp-json/runart/v1/ping-staging`, GET `/wp-json/runart/v1/data-scan`

Origen de endpoints: `tools/runart-ia-visual-unified/includes/class-rest-api.php`, `tools/runart-ia-visual-unified/runart-ia-visual-unified.php`, `tools/wpcli-bridge-plugin/runart-wpcli-bridge.php`, `tools/runart-ai-visual-panel/includes/class-runart-ai-visual-rest.php`.

---

## 3) Datasets disponibles (local y staging)

Locales (repo):
- `data/assistants/rewrite/index.json` — 3 ítems (total_pages=3).  
  - Tamaño: 738 bytes. MTime: 2025-10-30T18:32:38Z.
  - `page_42.json`, `page_43.json`, `page_44.json` con campos `enriched_es/en` y `visual_references[]`.
- Fallback en plugin: `tools/runart-ia-visual-unified/data/assistants/rewrite/` (mismo conjunto de ejemplo).

Staging (verificación REST 2025-10-31):
- `GET /wp-json/runart/v1/ping-staging` → 200 OK. Plugin activo (RunArt IA-Visual Unified 2.0.1).
- `GET /wp-json/runart/v1/data-scan` → 200 OK.  
  - `uploads/runart-jobs/enriched/index.json` → exists=False (no presente).  
  - Cascada `runart-data` (wp-content / uploads) → exists=False.  
  - Fallback de plugin → exists=True (3 ítems).  
  - dataset_real_status: NOT_FOUND_IN_STAGING.

Conclusión: el sistema funciona con dataset de ejemplo; el dataset real enriched no está en la ruta esperada del staging actual.

---

## 4) Mirror y backups

- `mirror/index.json` — Snapshot `2025-10-01` (~760 MB) con `wp-content/` completo (plugins, themes, uploads por año/mes).  
  - Tamaño: 1210 bytes. MTime: 2025-10-02T19:43:04Z.  
  - Política: payloads pesados gitignored; aporta estructura pero no los ficheros enriched reales.
- `mirror/raw/2025-10-01/wp-content/uploads/` — Estructura por año/mes presente;  
  - No se encontró `runart-jobs/enriched/` versionado en Git (coherente con política de exclusión).

---

## 5) Documentación y bitácoras destacadas

- Raíz: `PLAN_MAESTRO_IA_VISUAL_RUNART.md` — Plan maestro con F7–F10, referencias a arquitectura/QA.
- Docs IA: `docs/ai/architecture_overview.md` — Arquitectura IA‑Visual (últ. actualización 2025-10-30).
- Research: `research/ai_visual_tools_summary.md` — Resumen ejecutivo de investigación IA/Visual.
- Reports recientes:
  - `_reports/informe_resultados_verificacion_rest_staging.md` — Resultado REST (NOT_FOUND_IN_STAGING).  
  - `_reports/informe_origen_completo_datos_ia_visual.md` — Consolidado de orígenes y diseño de export.  
  - `_reports/propuesta_backend_editable.md` — Diseño del backend editable.  
  - `_reports/plan_migracion_normalizacion.md` — Estrategia de normalización.  
  - `_reports/lista_acciones_admin_staging.md` — Solicitudes al admin.

Metadatos de evidencia (tamaño/mtime UTC):
- `tools/runart-ia-visual-unified/includes/class-rest-api.php` — 33,234 B — 2025-10-31T17:03:16Z
- `tools/runart-ia-visual-unified/runart-ia-visual-unified.php` — 110,125 B — 2025-10-31T17:23:54Z
- `tools/wpcli-bridge-plugin/runart-wpcli-bridge.php` — 109,172 B — 2025-10-31T15:04:51Z
- `tools/runart-ai-visual-panel/includes/class-runart-ai-visual-rest.php` — 6,313 B — 2025-10-31T14:03:40Z
- `data/assistants/rewrite/index.json` — 738 B — 2025-10-30T18:32:38Z
- `mirror/index.json` — 1,210 B — 2025-10-02T19:43:04Z
- `_reports/informe_resultados_verificacion_rest_staging.md` — 1,725 B — 2025-10-31T17:27:57Z

---

## 6) CI/CD y flujos de validación

- Validaciones y auditorías operan vía scripts en `tools/` (e.g., `staging_full_validation.sh`, `validate_status_schema.py`).  
- Runners/pipelines de IA‑Visual preparados (mock/estructura) en `src/ai_visual/` y `apps/runmedia/` (indexación de medios, correlaciones).  
- Investigaciones y reportes automatizados en `_reports/` (FASE 3 y FASE 4 en curso).

---

## 7) Brechas detectadas

- Ubicación de la base completa enriched no disponible en staging actual; requiere extracción de prod/otro staging o acceso al storage donde reside.  
- Export REST segura aún no implementada (solo diseñada).  
- Backend editable (UI) diseñado; pendiente conectar a la base real y habilitar edición con backups/locks.

---

## 8) Recomendaciones iniciales

1. Coordinar con admin (ver `_reports/lista_acciones_admin_staging.md`) para:
   - Confirmar ruta y tamaño del `uploads/runart-jobs/enriched/index.json` en prod/host real.
   - Habilitar export REST temporal (solo admin) para descargar snapshot completo.
   - Verificar permisos en `uploads/runart-jobs/` (lectura/escritura o fallback readonly con logs).
2. Con dataset recuperado, ejecutar normalización (`_reports/plan_migracion_normalizacion.md`) y activar Opción B (cascada ampliada + feature flag).
3. Desplegar UI editorial mínima (listado + editor rápido + backups) y pruebas de permisos/locks.

---

## 9) Apéndices

A) Lista (parcial) de endpoints REST IA‑Visual
- `/runart/content/enriched-list`, `/content/enriched`, `/content/enriched-approve`, `/content/enriched-merge`, `/content/enriched-request`, `/content/enriched-hybrid`, `/content/wp-pages`
- `/runart/correlations/suggest-images`, `/embeddings/update`, `/ai-visual/pipeline`, `/ai-visual/request-regeneration`
- `/runart/bridge/health`, `/bridge/cache/flush`, `/bridge/rewrite/flush`, `/bridge/users`, `/bridge/plugins`
- `/runart/audit/pages`, `/audit/images`
- `/runart/v1/ping-staging`, `/v1/data-scan`

B) Rutas clave de datos (local/staging)
- Local repo: `data/assistants/rewrite/` (3 ítems).  
- Plugin fallback: `tools/runart-ia-visual-unified/data/assistants/rewrite/` (idéntico).  
- Staging esperado (no encontrado): `wp-content/uploads/runart-jobs/enriched/index.json`.

C) Archivos destacados (función)
- `tools/runart-ia-visual-unified/includes/class-rest-api.php` — Registro de rutas REST y diagnósticos.  
- `tools/wpcli-bridge-plugin/runart-wpcli-bridge.php` — utilidades puente, contenidos y colas.  
- `tools/runart-ai-visual-panel/includes/class-runart-ai-visual-rest.php` — endpoints panel alternativo.  
- `docs/ai/architecture_overview.md` — arquitectura de referencia.  
- `_reports/informe_origen_completo_datos_ia_visual.md` — consolidado de orígenes.

---

## 10) Validación final REST (2025-10-31T18:15Z)

### Endpoint ping-staging
- HTTP 200 OK
- Site URL: https://staging.runartfoundry.com
- Theme: RunArt Base (0.1.1)
- **Plugin: RunArt IA-Visual Unified (2.0.1)** ⚠️ Nota: staging aún con v2.0.1; v2.1.0 con backend editable disponible para deploy

### Endpoint data-scan
- HTTP 200 OK
- Rutas probadas:
  - `wp-content/runart-data`: NO encontrado
  - `uploads/runart-data`: NO encontrado
  - `plugin fallback`: SÍ encontrado (3 ítems)
  - `uploads/runart-jobs/enriched`: NO encontrado
  - `content/enriched`: NO encontrado
- **dataset_real_status:** NOT_FOUND_IN_STAGING

### Nuevos endpoints (disponibles en v2.1.0)
- `GET /wp-json/runart/v1/export-enriched?format={full|index-only}` — Exportar dataset completo (admin-only)
- `GET /wp-json/runart/v1/media-index?include_meta={true|false}` — Exportar índice de medios (admin-only)

### Conclusión validación
- Sistema operativo en staging con dataset de ejemplo (3 ítems)
- Plugin v2.1.0 listo para deploy con backend editable completo
- Endpoints de export implementados y funcionando localmente
- Dataset real pendiente de recuperación desde prod/staging autorizado

---

Fin del informe (FASE 4.A).  
Este documento sirve de base para FASE 4.B (Plan Maestro Final hacia backend editable con base completa).
