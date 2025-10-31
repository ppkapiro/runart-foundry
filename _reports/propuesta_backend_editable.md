# Propuesta — Backend editable IA‑Visual (diseño y prioridades)

Fecha: 2025-10-31
Autor: automation-runart
Ámbito: Diseño del panel editorial y endpoints seguros (sin implementación todavía)

## 1) Objetivo

Habilitar un panel en WordPress (Herramientas → RunArt IA‑Visual) para listar, buscar, editar, aprobar, versionar y exportar contenidos enriquecidos (texto + referencias visuales), con control de permisos y auditoría.

## 2) Funcionalidades mínimas (MVP útil inmediato)

1. Listado paginado de ítems
   - Columnas: `page_id`, `title`, `lang`, `status`, `visual_references_count`, `last_modified`.
   - Paginación servidor (per_page=25/50).

2. Filtros
   - Por `status` (generated/pending/archived), `lang`, `date`, `author`.

3. Búsqueda libre
   - Por `title`, `slug`, fragmento de `enriched_*`.

4. Editor rápido en línea
   - Campos: `title`, `excerpt`/`summary`, `enriched_es`, `enriched_en` (solo texto). Botón Guardar.

5. Editor avanzado (modal)
   - Vista JSON completa. Botón “Guardar y actualizar origen” con backup automático.

6. Versionado mínimo
   - Antes de escribir, snapshot a `/wp-content/uploads/runart-backups/YYYYMMDD/{page_id}.json` + índice de backups.

7. Permisos
   - Solo roles con `manage_options` o `edit_pages` avanzado. Nonces en cada acción.

8. Operaciones masivas
   - Aprobar/Rechazar/Archivar lotes.

9. Regenerar con IA
   - Botón “Re‑run AI” → encolar `enriched-request` (write‑safe). Visible sólo si hay runner.

10. Visual References Viewer
   - Miniaturas desde `media-index` con re‑asignar/añadir enlace a imagen.

11. Export
   - Exportar subset filtrado a ZIP/JSON para backup o migración.

12. Audit log
   - Tabla simple con `user`, `action`, `page_id`, `ts`, `hash_before`, `hash_after`.

## 3) Arquitectura técnica propuesta

- Capa de datos (Data Layer)
  - Lectura/escritura principal: `wp-content/uploads/runart-jobs/enriched/` (si existe) o cascada existente (`runart-data`, `plugin/data`).
  - Normalización a formato canónico `{ pages[] }`.

- Endpoints REST (seguros)
  - `GET /wp-json/runart/v1/editor/list` → listado con filtros/paginación.
  - `GET /wp-json/runart/v1/editor/item?page_id=...` → detalle.
  - `POST /wp-json/runart/v1/editor/update` → actualizar item (json body), con backup previo.
  - `POST /wp-json/runart/v1/editor/bulk` → acciones masivas.
  - `POST /wp-json/runart/v1/editor/request-regeneration` → encolar.
  - `GET /wp-json/runart/v1/editor/export` → exportar subset.
  - Seguridad: `current_user_can`, nonce `X-WP-Nonce`, y opción Bearer en entornos cerrados.

- UI (admin)
  - `assets/js/panel-editor.js` (vanilla/React/Vue) y `assets/css/panel.css`.
  - `wp_enqueue_script`/`wp_localize_script` para inyectar nonce y `rest_url`.

- Backups y locks
  - Carpeta: `/wp-content/uploads/runart-backups/YYYYMMDD/`.
  - Lock por `page_id` en `/wp-content/uploads/runart-backups/locks/{page_id}.lock` para evitar concurrencia.

## 4) Contrato de datos (canónico)

Entrada/salida principal:
- `index.json`: `{ version, generated_at, total_pages, pages: [ { page_id, lang, title, status, visual_references_count } ] }`
- `page_{id}.json`: `{ id, lang, enriched_es?, enriched_en?, visual_references: [ { image_id?, attachment_id?, filename?, url?, alt?, role?, score? } ] }`

Errores comunes y manejo:
- 404 si `page_id` no existe; 409 si lock activo; 422 si esquema inválido; 403 si capability insuficiente.

## 5) Roadmap breve

1. MVP list+view (read‑only) sobre la cascada actual.
2. Añadir editor rápido + backups.
3. Export/Import básicos.
4. Acciones masivas + regeneración IA.
5. Visual References Manager.

## 6) QA y seguridad

- Tests de permisos (rol admin/editor).
- Pruebas de concurrencia (locks), rollback con backups, checksum post‑write.
- Auditoría en `_reports/` con timestamp y hash de cambios.
