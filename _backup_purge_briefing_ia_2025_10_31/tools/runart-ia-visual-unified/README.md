# RunArt IA-Visual Unified

**Versión:** 2.0.0  
**Fecha de inicio:** 2025-10-31  
**Estado:** Estructura base creada - Pendiente migración de lógica funcional

## Propósito

Plugin unificado que consolida todo el sistema de enriquecimiento de contenido con IA (Fases 7-11) de RunArt Foundry. Reemplaza múltiples plugins fragmentados (master, experimental, legacy) con una arquitectura modular y mantenible.

## Origen

Este plugin es el resultado del proceso de consolidación descrito en:
- **Informe de referencia:** `_reports/informe_consolidacion_plugin_ia_visual.md`
- **Plugin maestro (base):** `tools/wpcli-bridge-plugin/` (v1.2.0)
- **Plugin experimental (extractos):** `tools/runart-ai-visual-panel/` (v1.0.0)

## Estructura del Plugin

```
runart-ia-visual-unified/
├── runart-ia-visual-unified.php  # Bootstrap principal
├── init_monitor_page.php         # Creación automática de página monitor
├── README.md                     # Este archivo
├── CHANGELOG.md                  # Historial de cambios
├── uninstall.php                 # Limpieza al desinstalar
│
├── includes/                     # Clases del plugin
│   ├── class-data-layer.php      # Gestión de rutas y archivos JSON
│   ├── class-rest-api.php        # 17 endpoints REST
│   ├── class-shortcode.php       # Shortcode [runart_ai_visual_monitor]
│   ├── class-permissions.php     # Permisos admin/editor
│   └── class-admin-diagnostic.php # Página de diagnóstico
│
├── assets/                       # Frontend
│   ├── js/
│   │   └── panel-editor.js       # JavaScript del panel
│   └── css/
│       └── panel-editor.css      # Estilos del panel
│
└── data/                         # Datos embebidos
    └── assistants/
        └── rewrite/              # Prompts de reescritura
```

## Características

### Endpoints REST (17 totales)
Namespace: `/wp-json/runart/v1`

**Diagnóstico:**
- `GET /health` - Estado del plugin

**Bridge (Infraestructura):**
- `GET /bridge/data-bases` - Rutas de datos disponibles
- `POST /bridge/locate` - Resolución de archivos en cascada
- `POST /bridge/prepare-storage` - Inicialización de directorios

**Contenido Enriquecido:**
- `GET /enriched/list` - Lista de contenido
- `POST /enriched/approve` - Aprobar contenido
- `POST /enriched/archive` - Archivar contenido
- `POST /enriched/restore` - Restaurar contenido
- `POST /enriched/delete` - Eliminar contenido
- `POST /enriched/rewrite` - Obtener reescritura
- `POST /enriched/request` - Solicitar enriquecimiento (queue)
- `POST /enriched/merge` - Fusionar contenido
- `POST /enriched/hybrid` - Contenido híbrido

**Auditoría:**
- `GET /wp-pages/all` - Listar páginas WordPress
- `GET /audit/pages` - Auditoría de páginas
- `GET /audit/images` - Auditoría de imágenes

**Deployment:**
- `POST /deployment/create-monitor-page` - Crear página de monitor

### Shortcode
- `[runart_ai_visual_monitor]` - Panel de gestión de contenido
  - Atributo `mode`: `technical` (por defecto) o `editor`

### Página de Administración
- **Ubicación:** Herramientas → RunArt IA-Visual
- **Diagnóstico del sistema:** Rutas, permisos, queue, dependencias

## Requisitos

- **WordPress:** >= 6.0
- **PHP:** >= 7.4
- **Permisos:** Directorio `wp-content/uploads/` debe ser escribible

## Dependencias Opcionales

- **Polylang:** Detección automática de idiomas (graceful fallback si no está presente)

## Instalación

1. Copiar directorio `runart-ia-visual-unified/` a `wp-content/plugins/`
2. Activar desde panel de WordPress → Plugins
3. Verificar creación automática de página "Panel Editorial IA-Visual"
4. Acceder a Herramientas → RunArt IA-Visual para diagnóstico

## Estado de Desarrollo

### ✅ Completado (Fase 1: Estructura)
- Directorios y archivos creados
- Bootstrap con autoload de clases
- Clases vacías con documentación de referencia
- Assets placeholder (CSS/JS)
- Hooks de inicialización registrados

### ⏳ Pendiente (Fase 2: Migración de Lógica)
- Migrar funciones del plugin maestro a clases:
  - `class-data-layer.php` (líneas 28-105 del master)
  - `class-rest-api.php` (líneas 157-2078 del master)
  - `class-shortcode.php` (líneas 2078-2626 del master)
- Decidir: ¿JS inline o externo?
- Implementar página de diagnóstico completa
- Pruebas de endpoints con Postman/curl

### ⏳ Pendiente (Fase 3: Testing y Despliegue)
- Tests de integración (17 endpoints)
- Pruebas de permisos (admin vs editor)
- Verificación con/sin Polylang
- Despliegue a staging
- Rollback plan (mantener master en `_archive/`)

## Notas Técnicas

### Backward Compatibility
- Se mantiene constante `RUNART_WPCLI_BRIDGE_PLUGIN_FILE` para compatibilidad con `init_monitor_page.php`
- Namespace REST permanece en `/runart` (no cambiar para evitar rotura de integraciones)
- Shortcode mantiene nombre `[runart_ai_visual_monitor]` para compatibilidad con páginas existentes

### Decisión Implementada: JavaScript Externo
- ✅ Se eligió OPCIÓN B: JS en archivo externo (`assets/js/panel-editor.js`)
- Ventajas: Mejor mantenibilidad, CSS/JS cacheable, debugging más fácil
- El shortcode carga automáticamente los assets y pasa configuración vía `window.RUNART_MONITOR`

---

## FASE 3: Limpieza de Plugins Antiguos (NO EJECUTAR AÚN)

### ⚠️ IMPORTANTE: Esta fase solo debe ejecutarse cuando:
1. El plugin unificado esté activado en staging
2. El panel responda correctamente (sin "Cargando..." permanente)
3. Los endpoints devuelvan datos reales
4. Se haya verificado durante al menos 24 horas sin errores

### Plugins a Archivar

#### 1. Plugin Experimental (tools/runart-ai-visual-panel/)
**Razón:** Duplicado incompleto, solo 3 endpoints de 17, colisión de shortcode

**Comando de archival:**
```bash
mkdir -p _archive/plugins/runart-ai-visual-panel_v1.0.0_20250131
mv tools/runart-ai-visual-panel/* _archive/plugins/runart-ai-visual-panel_v1.0.0_20250131/
rmdir tools/runart-ai-visual-panel
echo "Archivado 2025-01-31: Reemplazado por plugin unificado v2.0.0" > _archive/plugins/runart-ai-visual-panel_v1.0.0_20250131/ARCHIVAL_REASON.txt
```

#### 2. Plugin Legacy (plugins/runart-wpcli-bridge/)
**Razón:** Obsoleto, solo 1 endpoint /health, 38 líneas

**Comando de archival:**
```bash
mkdir -p _archive/plugins/runart-wpcli-bridge_v1.0.1_legacy_20250131
mv plugins/runart-wpcli-bridge/* _archive/plugins/runart-wpcli-bridge_v1.0.1_legacy_20250131/
rmdir plugins/runart-wpcli-bridge
echo "Archivado 2025-01-31: Solo tenía endpoint /health, reemplazado por v2.0.0" > _archive/plugins/runart-wpcli-bridge_v1.0.1_legacy_20250131/ARCHIVAL_REASON.txt
```

#### 3. Plugin Maestro (tools/wpcli-bridge-plugin/)
**Razón:** Código migrado al plugin unificado, mantener temporalmente como backup

**Acción:** NO ELIMINAR todavía. Mantener hasta confirmar que unificado funciona 100%

**Comando de archival (solo cuando esté confirmado):**
```bash
mkdir -p _archive/plugins/runart-wpcli-bridge_v1.2.0_master_20250131
mv tools/wpcli-bridge-plugin/* _archive/plugins/runart-wpcli-bridge_v1.2.0_master_20250131/
rmdir tools/wpcli-bridge-plugin
echo "Archivado 2025-01-31: Código migrado a plugin unificado v2.0.0" > _archive/plugins/runart-wpcli-bridge_v1.2.0_master_20250131/ARCHIVAL_REASON.txt
```

### Archivos que NO se deben tocar
- `_dist/plugins/runart-wpcli-bridge/*.zip` - Historial de distribución (16 ZIPs)
- `wp-content/mu-plugins/` - Plugins auxiliares independientes
- `wp-content/uploads/runart-jobs/` - Datos de usuario
- `tools/runners/` - Runners externos (F11)

### Checklist Pre-Limpieza
- [ ] Plugin unificado activado en staging
- [ ] Panel carga sin "Cargando..." permanente
- [ ] Endpoint `/content/enriched-list` devuelve datos
- [ ] Endpoint `/content/wp-pages` responde (aunque con timeout está OK)
- [ ] Botones de Aprobar/Rechazar funcionan
- [ ] Página de diagnóstico muestra rutas correctamente
- [ ] Sin errores en logs de PHP (`wp-content/debug.log`)
- [ ] Verificación manual durante 24 horas
- [ ] Backup completo de staging antes de archivar

## Contacto

**Proyecto:** RunArt Foundry  
**Repositorio:** feat/ai-visual-implementation  
**Documentación:** `_reports/informe_consolidacion_plugin_ia_visual.md`

## Licencia

Proprietary - RunArt Foundry © 2025
