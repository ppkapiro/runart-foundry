RunArt AI Visual Panel
======================

Plugin limpio para renderizar el panel editorial IA-Visual sin scripts inline.

Shortcodes registrados
----------------------
- `[runart_ai_visual_panel]`
- `[runart_ai_visual_monitor]` (compatibilidad con páginas existentes)

Estructura del plugin
---------------------
- `runart-ai-visual-panel.php`: bootstrap, define constantes y registra hooks.
- `includes/class-runart-ai-visual-rest.php`: endpoints REST (`enriched-list`, `wp-pages`, `enriched-request`).
- `includes/class-runart-ai-visual-shortcode.php`: shortcode + enqueue del JS externo.
- `includes/class-runart-ai-visual-admin.php`: página de diagnóstico en Herramientas → RunArt IA-Visual.
- `assets/js/panel-editor.js`: lógica del panel (ES5, sin módulos, carga IA primero y WP en paralelo con timeout).
- `data/index.json` (opcional): fallback si no existe uploads.

Instalación
-----------
1. Empaqueta la carpeta `runart-ai-visual-panel` en un ZIP (`zip -r runart-ai-visual-panel.zip runart-ai-visual-panel`).
2. En WordPress: Plugins → Añadir nuevo → Subir plugin → Seleccionar ZIP → Instalar → Activar.
3. Inserta el shortcode en la página deseada.

Endpoints
---------
- `GET /wp-json/runart/content/enriched-list`
	- Busca `wp-content/uploads/runart-jobs/enriched/index.json`.
- `GET /wp-json/runart/content/wp-pages`
	- Proxy interno a `/wp/v2/pages` con paginación (`page`, `per_page`).
- `POST /wp-json/runart/content/enriched-request`
	- Registra solicitudes en `wp-content/uploads/runart-jobs/enriched-requests.json`.

Diagnóstico
-----------
- Herramientas → RunArt IA-Visual Status: muestra versión, shortcodes, ruta del JSON y permite probar `enriched-list`.

Motivación
----------
- El plugin anterior embebía JS inline dentro del shortcode, lo que provocaba errores de sintaxis y evitaba que el panel cargara. Este reemplazo separa PHP y JS y se asegura de encolar scripts de forma segura.
