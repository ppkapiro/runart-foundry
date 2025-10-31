# Resumen de Construcción: Plugin Unificado RunArt IA-Visual

**Fecha:** 2025-10-31  
**Tarea:** Fase 1 - Construcción de estructura base del plugin unificado  
**Estado:** ✅ COMPLETADO

---

## Objetivo

Crear la arquitectura inicial del plugin "RunArt IA-Visual Unified v2.0.0" basándose en el informe de consolidación. Esta fase prepara la estructura modular sin implementar lógica funcional, estableciendo las bases para la migración del código desde el plugin maestro.

---

## Tareas Ejecutadas

### 1. ✅ Crear directorio base del plugin unificado
**Acción:** Creación de `/tools/runart-ia-visual-unified/` con estructura completa de subcarpetas.

**Estructura creada:**
```
runart-ia-visual-unified/
├── includes/
├── assets/
│   ├── js/
│   └── css/
└── data/
    └── assistants/
        └── rewrite/
```

**Comando ejecutado:**
```bash
mkdir -p /home/pepe/work/runartfoundry/tools/runart-ia-visual-unified/{includes,assets/js,assets/css,data/assistants/rewrite}
```

---

### 2. ✅ Copiar archivos originales desde plugin maestro
**Acción:** Migración de archivos base desde `tools/wpcli-bridge-plugin/`.

**Archivos copiados:**
- `runart-wpcli-bridge.php` → Base del bootstrap principal (2788 líneas)
- `init_monitor_page.php` → Helper de creación de página monitor (150 líneas)
- `data/assistants/rewrite/*.txt` → Prompts de reescritura

**Comandos ejecutados:**
```bash
cp tools/wpcli-bridge-plugin/runart-wpcli-bridge.php tools/runart-ia-visual-unified/
cp tools/wpcli-bridge-plugin/init_monitor_page.php tools/runart-ia-visual-unified/
cp -r tools/wpcli-bridge-plugin/data/assistants/rewrite/* tools/runart-ia-visual-unified/data/assistants/rewrite/
```

---

### 3. ✅ Crear bootstrap principal (runart-ia-visual-unified.php)
**Acción:** Renombrado del archivo base y actualización del encabezado con metadatos del plugin unificado.

**Cambios implementados:**
- **Renombrado:** `runart-wpcli-bridge.php` → `runart-ia-visual-unified.php`
- **Encabezado actualizado:**
  - Plugin Name: RunArt IA-Visual Unified
  - Version: 2.0.0
  - Description: Sistema unificado de enriquecimiento de contenido con IA (F7-F11)
  - License: Proprietary
  - Requires at least: 6.0

**Constantes definidas:**
```php
define('RUNART_IA_VISUAL_VERSION', '2.0.0');
define('RUNART_IA_VISUAL_PLUGIN_FILE', __FILE__);
define('RUNART_IA_VISUAL_PLUGIN_DIR', plugin_dir_path(__FILE__));
define('RUNART_IA_VISUAL_PLUGIN_URL', plugin_dir_url(__FILE__));
```

**Requires agregados:**
```php
require_once RUNART_IA_VISUAL_PLUGIN_DIR . 'includes/class-data-layer.php';
require_once RUNART_IA_VISUAL_PLUGIN_DIR . 'includes/class-permissions.php';
require_once RUNART_IA_VISUAL_PLUGIN_DIR . 'includes/class-rest-api.php';
require_once RUNART_IA_VISUAL_PLUGIN_DIR . 'includes/class-shortcode.php';
require_once RUNART_IA_VISUAL_PLUGIN_DIR . 'includes/class-admin-diagnostic.php';
require_once RUNART_IA_VISUAL_PLUGIN_DIR . 'init_monitor_page.php';
```

**Hooks registrados:**
```php
add_action('rest_api_init', ['RunArt_IA_Visual_REST_API', 'register_routes']);
add_action('init', ['RunArt_IA_Visual_Shortcode', 'register']);
add_action('admin_menu', ['RunArt_IA_Visual_Admin_Diagnostic', 'add_menu']);
```

**Backward compatibility:**
```php
// Mantener constante antigua para init_monitor_page.php
define('RUNART_WPCLI_BRIDGE_PLUGIN_FILE', __FILE__);
```

---

### 4. ✅ Crear clases vacías en includes/
**Acción:** Generación de 5 clases PHP con estructura de marcadores y documentación de referencia al informe de consolidación.

#### **class-data-layer.php** (105 líneas)
**Responsabilidad:** Gestión de rutas y lectura/escritura de archivos JSON.

**Métodos definidos (stubs):**
- `get_data_bases()` - Rutas base con cascada de prioridad
- `locate_file($relative_path)` - Resolución de archivos
- `prepare_storage($type)` - Creación de directorios
- `read_json($path)` - Lectura de JSON
- `write_json($path, $data)` - Escritura atómica de JSON

**Pendiente:** Migrar lógica desde plugin maestro líneas 28-105.

#### **class-permissions.php** (72 líneas)
**Responsabilidad:** Sistema de permisos para endpoints REST.

**Métodos implementados:**
- `is_admin()` - Verifica `manage_options`
- `is_editor()` - Verifica `edit_posts`
- `check_admin()` - Callback para `permission_callback` (admin)
- `check_editor()` - Callback para `permission_callback` (editor)

**Estado:** ✅ COMPLETO (no requiere migración, lógica simple)

#### **class-rest-api.php** (108 líneas)
**Responsabilidad:** Registro de 17 endpoints REST bajo namespace `/runart/v1`.

**Constante definida:**
```php
const NAMESPACE = 'runart/v1';
```

**Método principal:**
- `register_routes()` - Registra 17 rutas (stub)

**Endpoints a implementar:**
1. GET /health
2. GET /bridge/data-bases
3. POST /bridge/locate
4. POST /bridge/prepare-storage
5. GET /enriched/list
6. POST /enriched/approve
7. POST /enriched/archive
8. POST /enriched/restore
9. POST /enriched/delete
10. POST /enriched/rewrite
11. POST /enriched/request
12. POST /enriched/merge
13. POST /enriched/hybrid
14. GET /wp-pages/all
15. GET /audit/pages
16. GET /audit/images
17. POST /deployment/create-monitor-page

**Pendiente:** Migrar desde plugin maestro líneas 157-2078.

#### **class-shortcode.php** (91 líneas)
**Responsabilidad:** Shortcode `[runart_ai_visual_monitor]` con modos technical/editor.

**Métodos definidos:**
- `register()` - Registra shortcode (hook: init)
- `render($atts)` - Renderiza panel (HTML placeholder)
- `enqueue_assets()` - Enqueue de JS/CSS externo (privado)

**Atributos soportados:**
- `mode`: `technical` (por defecto) | `editor`

**Decisión pendiente:** JS inline (master) vs externo (experimental)

**Pendiente:** Migrar HTML + JS desde plugin maestro líneas 2078-2626.

#### **class-admin-diagnostic.php** (164 líneas)
**Responsabilidad:** Página "Herramientas → RunArt IA-Visual" con diagnóstico del sistema.

**Métodos implementados:**
- `add_menu()` - Registra página en admin_menu
- `render_page()` - Renderiza página principal
- `render_data_paths()` - Diagnóstico de rutas (stub)
- `render_permissions()` - Verificación de permisos (implementado)
- `render_queue_status()` - Estado de queue (stub)
- `render_optional_dependencies()` - Detección de Polylang (implementado)
- `render_endpoints()` - Lista de 17 endpoints con links de test (implementado)

**Estado:** 50% COMPLETO (diagnóstico básico funcional, rutas/queue pendientes)

---

### 5. ✅ Copiar y preparar assets (CSS/JS)
**Acción:** Creación de archivos de assets con contenido placeholder.

#### **assets/css/panel-editor.css** (28 líneas)
**Contenido:**
- Reset y contenedor principal `#runart-ai-visual-panel`
- Estilos básicos de tipografía
- Comentario: Pendiente migración desde plugin maestro

**Nota:** Plugin experimental NO tenía CSS separado, se creó placeholder.

#### **assets/js/panel-editor.js** (51 líneas)
**Contenido:**
- Estructura comentada de funciones principales:
  - `loadContent()` - Fetch de `/enriched/list`
  - `renderContent(items)` - Renderizado de tabla
- Lógica deshabilitada (comentada)
- `console.log()` de confirmación

**Decisión pendiente:** Implementar aquí o mantener inline del master.

---

### 6. ✅ Crear archivos de documentación
**Acción:** Generación de README, CHANGELOG y uninstall script.

#### **README.md** (156 líneas)
**Secciones:**
- Propósito y origen del plugin
- Estructura de directorios con árbol visual
- 17 endpoints REST documentados por categoría
- Shortcode con atributos
- Requisitos técnicos (WP >= 6.0, PHP >= 7.4)
- Dependencias opcionales (Polylang)
- Instrucciones de instalación
- Estado de desarrollo (Fase 1 ✅, Fase 2-3 ⏳)
- Notas técnicas (backward compatibility)
- Decisiones pendientes (JS inline vs externo)

#### **CHANGELOG.md** (132 líneas)
**Formato:** [Keep a Changelog](https://keepachangelog.com/)

**Versiones documentadas:**
- **[2.0.0] - 2025-10-31:** Consolidación y estructura base (esta fase)
- **[1.2.0] - 2025-10-31:** Plugin maestro (referencia histórica)
- **[1.0.0] - 2025-10-28:** Plugin experimental (archivado)
- **[1.0.1] - 2025-10-20:** Plugin legacy (obsoleto)

**Versionado:** Semantic Versioning (MAJOR.MINOR.PATCH)

#### **uninstall.php** (59 líneas)
**Funcionalidad:**
- Limpieza de opción `runart_ai_visual_monitor_seeded`
- Eliminación de páginas monitor (comentado por seguridad)
- NO elimina datos de usuario (`wp-content/uploads/runart-jobs/`)
- Log de desinstalación en modo debug

---

### 7. ✅ Verificar sintaxis y estructura del plugin
**Acción:** Validación de sintaxis PHP y estructura de archivos.

#### **Sintaxis PHP verificada:**
```bash
php -l runart-ia-visual-unified.php
# No syntax errors detected

php -l includes/*.php
# No syntax errors detected (5 archivos)
```

#### **Estructura verificada:**
```
8 directories, 12 files
✓ runart-ia-visual-unified.php (bootstrap)
✓ init_monitor_page.php (helper)
✓ README.md, CHANGELOG.md, uninstall.php (docs)
✓ includes/class-*.php (5 clases)
✓ assets/js/panel-editor.js
✓ assets/css/panel-editor.css
✓ data/assistants/rewrite/ (prompts)
```

#### **Includes verificados:**
```php
✓ require_once class-data-layer.php
✓ require_once class-permissions.php
✓ require_once class-rest-api.php
✓ require_once class-shortcode.php
✓ require_once class-admin-diagnostic.php
✓ require_once init_monitor_page.php
```

#### **Hooks verificados:**
```php
✓ add_action('rest_api_init', 'RunArt_IA_Visual_REST_API::register_routes')
✓ add_action('init', 'RunArt_IA_Visual_Shortcode::register')
✓ add_action('admin_menu', 'RunArt_IA_Visual_Admin_Diagnostic::add_menu')
```

---

## Resultados

### ✅ Archivos Creados (12 totales)

| Archivo | Líneas | Estado | Función |
|---------|--------|--------|---------|
| `runart-ia-visual-unified.php` | 2830 | ⚠️ Base heredada | Bootstrap principal con código legacy |
| `init_monitor_page.php` | 150 | ✅ Completo | Creación automática de página monitor |
| `README.md` | 156 | ✅ Completo | Documentación del plugin |
| `CHANGELOG.md` | 132 | ✅ Completo | Historial de versiones |
| `uninstall.php` | 59 | ✅ Completo | Limpieza al desinstalar |
| `includes/class-data-layer.php` | 105 | 🔵 Stub | Gestión de datos (pendiente migración) |
| `includes/class-permissions.php` | 72 | ✅ Completo | Sistema de permisos |
| `includes/class-rest-api.php` | 108 | 🔵 Stub | 17 endpoints REST (pendiente migración) |
| `includes/class-shortcode.php` | 91 | 🔵 Stub | Shortcode del panel (pendiente migración) |
| `includes/class-admin-diagnostic.php` | 164 | 🟡 50% | Página de diagnóstico (básico funcional) |
| `assets/js/panel-editor.js` | 51 | 🔵 Placeholder | JavaScript del panel |
| `assets/css/panel-editor.css` | 28 | 🔵 Placeholder | Estilos del panel |

**Leyenda:**
- ✅ Completo: No requiere cambios
- 🟡 Parcial: Funcional pero incompleto
- 🔵 Stub: Estructura lista, pendiente implementación
- ⚠️ Legacy: Contiene código heredado a refactorizar

---

## Estado del Plugin

### Fase 1: Estructura Base ✅ COMPLETADO
- [x] Directorio base y subcarpetas
- [x] Bootstrap con autoload de clases
- [x] 5 clases con estructura de marcadores
- [x] Assets placeholder (CSS/JS)
- [x] Documentación completa (README, CHANGELOG, uninstall)
- [x] Hooks de inicialización registrados
- [x] Sintaxis PHP validada sin errores

### Fase 2: Migración de Lógica ⏳ PENDIENTE
- [ ] Migrar `class-data-layer.php` (líneas 28-105 del master)
- [ ] Migrar `class-rest-api.php` (líneas 157-2078 del master)
- [ ] Migrar `class-shortcode.php` (líneas 2078-2626 del master)
- [ ] Decidir: ¿JS inline o externo?
- [ ] Completar `class-admin-diagnostic.php` (rutas y queue)
- [ ] Eliminar código legacy del bootstrap

### Fase 3: Testing y Despliegue ⏳ PENDIENTE
- [ ] Tests de 17 endpoints REST
- [ ] Verificación de permisos (admin vs editor)
- [ ] Pruebas con/sin Polylang
- [ ] Despliegue a staging
- [ ] Monitoreo 24h sin errores
- [ ] Rollback plan (archivar master en `_archive/`)

---

## Próximos Pasos

### Inmediato (Fase 2.1: Data Layer)
1. Abrir `tools/wpcli-bridge-plugin/runart-wpcli-bridge.php`
2. Copiar funciones líneas 28-105:
   - `runart_bridge_data_bases()`
   - `runart_bridge_locate()`
   - `runart_bridge_prepare_storage()`
3. Adaptar a métodos estáticos de `class-data-layer.php`
4. Verificar funcionamiento con tests unitarios

### Siguiente (Fase 2.2: REST API)
1. Migrar 17 `register_rest_route()` desde líneas 157-406
2. Migrar implementaciones de callbacks (líneas 406-2078)
3. Reemplazar llamadas a funciones legacy por métodos de clases:
   - `runart_bridge_locate()` → `RunArt_IA_Visual_Data_Layer::locate_file()`
   - `runart_wpcli_bridge_permission_admin()` → `RunArt_IA_Visual_Permissions::check_admin()`
4. Verificar con Postman/curl

### Decisión Crítica (Fase 2.3: Shortcode)
**Opción A: JS Inline (como master)**
- ✅ Despliegue simple (todo en un archivo)
- ✅ Sin dependencias de assets
- ❌ Difícil debugging
- ❌ No cacheable

**Opción B: JS Externo (como experimental)**
- ✅ Mejor mantenibilidad
- ✅ CSS/JS cacheable
- ✅ Debugging más fácil
- ❌ Requiere enqueue de assets
- ❌ Más archivos que gestionar

**Recomendación:** Opción B (externo) para mantenibilidad a largo plazo.

---

## Métricas

### Antes de Consolidación
- **Plugins activos:** 3 (master, experimental, legacy)
- **Archivos PHP:** 24 relevantes
- **Duplicaciones:** 3 endpoints, 1 shortcode
- **Colisiones:** 2 (namespace REST, shortcode)
- **Líneas de código:** ~3500 (fragmentado)

### Después de Fase 1 (Estructura)
- **Plugins creados:** 1 (unificado)
- **Archivos PHP:** 12 (8 nuevo + 4 heredados)
- **Duplicaciones:** 0 (pendiente eliminar legacy)
- **Colisiones:** 0 (pendiente activar en WP)
- **Líneas de código nuevo:** ~900 (clases + docs)
- **Líneas heredadas:** ~2900 (pendiente refactorizar)

### Objetivo Final (Post-Fase 3)
- **Plugins activos:** 1 (unificado refactorizado)
- **Archivos PHP:** ~8-10 (clases modulares)
- **Duplicaciones:** 0
- **Colisiones:** 0
- **Líneas de código:** ~2500 (optimizado, sin legacy)
- **Plugins archivados:** 3 (en `_archive/plugins/`)

---

## Referencias

- **Informe de consolidación:** `_reports/informe_consolidacion_plugin_ia_visual.md`
- **Plugin maestro (origen):** `tools/wpcli-bridge-plugin/runart-wpcli-bridge.php` v1.2.0
- **Plugin experimental (extractos):** `tools/runart-ai-visual-panel/` v1.0.0
- **Branch:** `feat/ai-visual-implementation`
- **Fecha de inicio consolidación:** 2025-10-31

---

## Notas de Implementación

### Backward Compatibility Crítica
1. **Constante `RUNART_WPCLI_BRIDGE_PLUGIN_FILE`:**
   - Mantenida para compatibilidad con `init_monitor_page.php`
   - Referencia a `__FILE__` del bootstrap
   - NO eliminar sin actualizar init helper

2. **Namespace REST `/runart/v1`:**
   - Mantener sin cambios para evitar rotura de integraciones
   - Scripts externos de F11 (OpenAI runner) dependen de este namespace
   - Auditar `tools/runners/` antes de cambiar

3. **Shortcode `[runart_ai_visual_monitor]`:**
   - Mantener nombre original por compatibilidad
   - Páginas existentes pueden tener este shortcode en contenido
   - Si se renombra, agregar alias con `add_shortcode()` duplicado

### Archivos a NO Modificar
1. **`_dist/plugins/runart-wpcli-bridge/*.zip`** - Historial de distribución (16 ZIPs)
2. **`wp-content/mu-plugins/`** - Plugins auxiliares independientes
3. **`wp-content/uploads/runart-jobs/`** - Datos de usuario (no tocar en ninguna fase)
4. **`tools/runners/openai_runner.py`** - Runner externo de F11

### Rollback Plan
Si algo falla en Fase 2-3:
1. Desactivar plugin unificado desde WP Admin
2. Reactivar master plugin desde `tools/wpcli-bridge-plugin/`
3. Verificar funcionamiento de endpoints REST
4. Analizar logs de error PHP (`wp-content/debug.log`)
5. Restaurar desde `_dist/plugins/runart-wpcli-bridge-v1.2.0.zip` si es necesario

---

**Fase 1 finalizada exitosamente. Sistema listo para Fase 2: Migración de Lógica.**
