# Changelog

Todas las versiones y cambios significativos del plugin RunArt IA-Visual Unified.

El formato se basa en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

---

## [2.1.0] - 2025-10-31

### Added
- **FASE 4.A: Backend Editable Completo**
  - Nueva clase `class-admin-editor.php` con UI completa de administración
  - Menú "IA-Visual" en WordPress admin (capability: `edit_posts`)
  - Listado de contenido enriquecido con:
    - Búsqueda en tiempo real por ID/título/contenido
    - Filtros por estado (aprobado/pendiente/rechazado)
    - Estadísticas y metadatos (total páginas, idiomas, referencias visuales)
  - Editor inline modal con preview lado a lado (ES/EN)
  - Página de Export/Import con:
    - Descarga de dataset local (full o index-only)
    - Sincronización AJAX desde staging/prod
    - Configuración de backup automático
- **Endpoints REST de Export Seguro (admin-only)**:
  - `GET /wp-json/runart/v1/export-enriched?format={full|index-only}` - Export completo del dataset
  - `GET /wp-json/runart/v1/media-index?include_meta={true|false}` - Export de índice de medios
  - Cascada de búsqueda: uploads-enriched → wp-content → uploads → plugin
- **Assets Frontend/Admin**:
  - CSS: `assets/admin-editor.css` - Estilos del backend editable
  - JS: `assets/admin-editor.js` - Interactividad, búsqueda, filtros, modal
- **Hooks AJAX**:
  - `wp_ajax_runart_save_enriched` - Guardar contenido (preparado para persistencia)
  - `wp_ajax_runart_delete_enriched` - Eliminar contenido (preparado)
  - `wp_ajax_runart_export_dataset` - Exportar dataset

### Changed
- Versión bumpeada a 2.1.0 por features mayores
- Inicialización de `RunArt_IA_Visual_Admin_Editor::init()` en hook `init`

### Notes
- Persistencia de ediciones aún en modo mock (preparado para Milestone 3 de FASE 4.B)
- Requiere dataset real para funcionalidad completa (ver `_reports/FASE4/PLAN_MAESTRO_FINAL_FASE4B.md`)

---

## [2.0.1] - 2025-10-31

### Added
- Fase 3.D: Endpoints REST de diagnóstico añadidos (solo lectura):
  - `GET /wp-json/runart/v1/ping-staging` (eco remoto: status, site_url, theme, versión plugin)
  - `GET /wp-json/runart/v1/data-scan` (explora rutas candidatas, reporta exists/size/item_count y `summary.dataset_real_status`)

### Notes
- No cambia la cascada del endpoint de lista. La ampliación quedará sujeta a la verificación en staging (Fase 3.E).
- Este release permite verificar datasets por REST sin SFTP.

---

## [2.0.0] - 2025-10-31

### Objetivo
Consolidación de múltiples plugins fragmentados (master v1.2.0, experimental v1.0.0, legacy v1.0.1) en una única arquitectura modular.

### Added (Estructura Base)
- Creación de arquitectura modular con 5 clases en `includes/`:
  - `class-data-layer.php` - Gestión de rutas y archivos JSON
  - `class-rest-api.php` - Registro de 17 endpoints REST
  - `class-shortcode.php` - Shortcode del panel IA-Visual
  - `class-permissions.php` - Sistema de permisos (admin/editor)
  - `class-admin-diagnostic.php` - Página de diagnóstico en Herramientas
- Assets separados (CSS/JS) en `assets/` para futuro mantenimiento
- Bootstrap principal `runart-ia-visual-unified.php` con autoload
- Constantes del plugin: `RUNART_IA_VISUAL_VERSION`, `PLUGIN_FILE`, `PLUGIN_DIR`, `PLUGIN_URL`
- Documentación: README.md, CHANGELOG.md, uninstall.php

### Migrated
- `init_monitor_page.php` copiado desde plugin maestro (sin cambios)
- Prompts de reescritura: `data/assistants/rewrite/*.txt`
- Código heredado del plugin maestro (2787 líneas) como base para refactorización

### Pending (Next Phase)
- Migración de lógica funcional desde plugin maestro a clases:
  - Data Layer: funciones `runart_bridge_data_bases()`, `locate()`, `prepare_storage()`
  - REST API: implementación de 17 endpoints
  - Shortcode: migración de HTML + JS inline (o externo)
- Decisión de arquitectura: JS inline vs externo
- Implementación completa de página de diagnóstico
- Testing de endpoints y permisos

### Reference
- **Informe base:** `_reports/informe_consolidacion_plugin_ia_visual.md`
- **Plugin maestro:** `tools/wpcli-bridge-plugin/runart-wpcli-bridge.php` v1.2.0
- **Reemplaza:** 3 plugins (master, experimental, legacy)

---

## [1.2.0] - 2025-10-31 (Plugin Maestro)

**Nota:** Esta versión corresponde al plugin maestro (`tools/wpcli-bridge-plugin/`) que sirve como base para v2.0.0.

### Features
- 17 endpoints REST bajo namespace `/runart/v1`
- Sistema de queue para jobs de enriquecimiento (`enriched-requests.json`)
- Shortcode `[runart_ai_visual_monitor]` con modos technical/editor
- Soporte opcional para Polylang (detección de idiomas)
- Cascada de rutas: wp-content → uploads → plugin
- Timeout de 5s para endpoints de páginas WP

---

## [1.0.0] - 2025-10-28 (Plugin Experimental)

**Nota:** Plugin experimental (`tools/runart-ai-visual-panel/`) con arquitectura limpia pero incompleto.

### Features
- Solo 3 endpoints REST (18% de funcionalidad)
- JS externo: `assets/js/panel-editor.js` (220 líneas)
- CSS separado: `assets/css/panel-editor.css`
- Página de diagnóstico en Herramientas (concepto)

### Issues
- Duplica endpoints del master (colisión)
- No tiene lógica de cascada de rutas
- No tiene integración de activación
- Nunca se completó (experimento abandonado)

**Estado:** Archivado en consolidación v2.0.0

---

## [1.0.1] - 2025-10-20 (Plugin Legacy)

**Nota:** Plugin legacy (`plugins/runart-wpcli-bridge/`) con funcionalidad mínima.

### Features
- Solo 1 endpoint: `GET /health`
- 38 líneas de código

**Estado:** Obsoleto, reemplazado por master v1.2.0, archivado en consolidación v2.0.0

---

## Formato de Versionado

- **MAJOR (X.0.0):** Cambios incompatibles en API o arquitectura
- **MINOR (0.X.0):** Nuevas funcionalidades backward-compatible
- **PATCH (0.0.X):** Correcciones de bugs y mejoras menores

---

**Próxima versión esperada:** v2.1.0 (implementación completa de lógica funcional)
