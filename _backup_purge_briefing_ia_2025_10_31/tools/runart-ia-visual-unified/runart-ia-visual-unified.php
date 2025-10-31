<?php
/**
 * Plugin Name: RunArt IA-Visual Unified
 * Plugin URI: https://runart.es
 * Description: Sistema unificado de enriquecimiento de contenido con IA (F7-F11) basado en el WP-CLI Bridge.
 * Version: 2.2.0
 * Author: RunArt Foundry
 * Author URI: https://runart.es
 * License: Proprietary
 * Requires at least: 6.0
 * Requires PHP: 7.4
 */

if (!defined('ABSPATH')) {
    exit; // Exit if accessed directly
}

// Definir constantes del plugin
define('RUNART_IA_VISUAL_VERSION', '2.2.0');
define('RUNART_IA_VISUAL_PLUGIN_FILE', __FILE__);
define('RUNART_IA_VISUAL_PLUGIN_DIR', plugin_dir_path(__FILE__));
define('RUNART_IA_VISUAL_PLUGIN_URL', plugin_dir_url(__FILE__));

// Backward compatibility: mantener constante antigua para init_monitor_page.php
if (!defined('RUNART_WPCLI_BRIDGE_PLUGIN_FILE')) {
    define('RUNART_WPCLI_BRIDGE_PLUGIN_FILE', __FILE__);
}

// Cargar clases del plugin unificado
require_once RUNART_IA_VISUAL_PLUGIN_DIR . 'includes/class-data-layer.php';
require_once RUNART_IA_VISUAL_PLUGIN_DIR . 'includes/class-permissions.php';
require_once RUNART_IA_VISUAL_PLUGIN_DIR . 'includes/class-rest-api.php';
require_once RUNART_IA_VISUAL_PLUGIN_DIR . 'includes/class-shortcode.php';
require_once RUNART_IA_VISUAL_PLUGIN_DIR . 'includes/class-admin-diagnostic.php';
require_once RUNART_IA_VISUAL_PLUGIN_DIR . 'includes/class-admin-editor.php';

// Incluir inicializador de página de monitor (creación automática al activar)
require_once RUNART_IA_VISUAL_PLUGIN_DIR . 'init_monitor_page.php';

// Inicializar componentes del plugin
add_action('rest_api_init', ['RunArt_IA_Visual_REST_API', 'register_routes']);
add_action('init', ['RunArt_IA_Visual_Shortcode', 'register']);
add_action('admin_menu', ['RunArt_IA_Visual_Admin_Diagnostic', 'add_menu']);
add_action('init', ['RunArt_IA_Visual_Admin_Editor', 'init']);

// ==========================================
// CÓDIGO HEREDADO DEL PLUGIN MAESTRO
// Pendiente de refactorización en clases
// ==========================================

if (!function_exists('runart_bridge_data_bases')) {
    /**
     * Obtiene rutas base posibles para los artefactos IA (data/...).
     * Prioridad: repo (../data), wp-content/runart-data, datos embebidos en el plugin.
     *
     * @return array<string,string>
     */
    function runart_bridge_data_bases() {
        static $bases = null;
        if ($bases !== null) {
            return $bases;
        }

        $bases = [];

        if (defined('WP_CONTENT_DIR')) {
            $bases['repo'] = trailingslashit(dirname(WP_CONTENT_DIR)) . 'data';
            $bases['wp_content'] = trailingslashit(WP_CONTENT_DIR) . 'runart-data';
            $bases['uploads'] = trailingslashit(WP_CONTENT_DIR) . 'uploads/runart-data';
        }

        $bases['plugin'] = trailingslashit(plugin_dir_path(__FILE__)) . 'data';

        // Remover duplicados manteniendo prioridad.
        $bases = array_unique($bases);

        return $bases;
    }
}

if (!function_exists('runart_bridge_locate')) {
    /**
     * Localiza un archivo o directorio dentro de las bases disponibles.
     *
     * @param string $relative Ruta relativa dentro de data/
     * @param string $type     "file" | "dir"
     * @return array{found:bool,path:?string,source:string,paths_tried:array<int,string>}
     */
    function runart_bridge_locate($relative, $type = 'file') {
        $relative = ltrim($relative, '/');
        $attempts = [];

        foreach (runart_bridge_data_bases() as $label => $base) {
            $full = trailingslashit($base) . $relative;
            $attempts[] = $full;

            if ($type === 'dir') {
                if (is_dir($full)) {
                    return [
                        'found' => true,
                        'path' => trailingslashit($full),
                        'source' => $label,
                        'paths_tried' => $attempts,
                    ];
                }
            } else {
                if (file_exists($full)) {
                    return [
                        'found' => true,
                        'path' => $full,
                        'source' => $label,
                        'paths_tried' => $attempts,
                    ];
                }
            }
        }

        return [
            'found' => false,
            'path' => null,
            'source' => 'not-found',
            'paths_tried' => $attempts,
        ];
    }
}

if (!function_exists('runart_bridge_prepare_storage')) {
    /**
     * Determina una ruta escribible para guardar artefactos calculados (aprobaciones, logs, etc.).
     * Prefiere wp-content/runart-data, luego repo/../data.
     *
     * @param string $relative Ruta relativa dentro de data/
     * @return array{path:?string,source:string,paths_tried:array<int,string>}
     */
    function runart_bridge_prepare_storage($relative) {
        $relative = ltrim($relative, '/');
        $preferred = ['wp_content', 'repo'];
        $bases = runart_bridge_data_bases();
        $attempts = [];

        foreach ($preferred as $label) {
            if (!isset($bases[$label])) {
                continue;
            }

            $base = trailingslashit($bases[$label]);
            $full = $base . $relative;
            $dir = is_dir($full) ? $full : dirname($full);
            $attempts[] = $full;

            if (!is_dir($dir)) {
                if (function_exists('wp_mkdir_p')) {
                    wp_mkdir_p($dir);
                } else {
                    @mkdir($dir, 0755, true);
                }
            }

            if (is_dir($dir) && is_writable($dir)) {
                return [
                    'path' => $full,
                    'source' => $label,
                    'paths_tried' => $attempts,
                ];
            }
        }

        return [
            'path' => null,
            'source' => 'not-writable',
            'paths_tried' => $attempts,
        ];
    }
}

add_action('rest_api_init', function () {
    $ns = 'runart/v1';

    // Health endpoint (GET)
    register_rest_route($ns, '/bridge/health', [
        'methods'  => 'GET',
        'callback' => 'runart_wpcli_bridge_health',
        'permission_callback' => 'runart_wpcli_bridge_permission_admin',
    ]);

    // Cache flush (POST)
    register_rest_route($ns, '/bridge/cache/flush', [
        'methods'  => 'POST',
        'callback' => 'runart_wpcli_bridge_cache_flush',
        'permission_callback' => 'runart_wpcli_bridge_permission_admin',
    ]);

    // Rewrite flush (POST)
    register_rest_route($ns, '/bridge/rewrite/flush', [
        'methods'  => 'POST',
        'callback' => 'runart_wpcli_bridge_rewrite_flush',
        'permission_callback' => 'runart_wpcli_bridge_permission_admin',
    ]);

    // Users list (GET)
    register_rest_route($ns, '/bridge/users', [
        'methods'  => 'GET',
        'callback' => 'runart_wpcli_bridge_users_list',
        'permission_callback' => 'runart_wpcli_bridge_permission_admin',
    ]);

    // Plugins list (GET)
    register_rest_route($ns, '/bridge/plugins', [
        'methods'  => 'GET',
        'callback' => 'runart_wpcli_bridge_plugins_list',
        'permission_callback' => 'runart_wpcli_bridge_permission_admin',
    ]);
    
    // Content Audit - Pages endpoint (GET)
    register_rest_route('runart', '/audit/pages', [
        'methods'  => 'GET',
        'callback' => 'runart_audit_pages',
        'permission_callback' => 'runart_wpcli_bridge_permission_admin',
    ]);
    
    // Content Audit - Images endpoint (GET)
    register_rest_route('runart', '/audit/images', [
        'methods'  => 'GET',
        'callback' => 'runart_audit_images',
        'permission_callback' => 'runart_wpcli_bridge_permission_admin',
    ]);
    
    // IA-Visual Correlation - Suggest Images endpoint (GET)
    register_rest_route('runart', '/correlations/suggest-images', [
        'methods'  => 'GET',
        'callback' => 'runart_correlations_suggest_images',
        // Permitir a cualquier usuario autenticado (se valida via nonce en el front)
        'permission_callback' => function () { return is_user_logged_in(); },
        'args' => [
            'page_id' => [
                'required' => true,
                'type' => 'integer',
                'description' => 'ID de la página para la que se solicitan recomendaciones',
            ],
            'top_k' => [
                'required' => false,
                'type' => 'integer',
                'default' => 5,
                'description' => 'Número máximo de recomendaciones (default: 5)',
            ],
            'threshold' => [
                'required' => false,
                'type' => 'number',
                'default' => 0.70,
                'description' => 'Umbral de similitud mínimo 0.0-1.0 (default: 0.70)',
            ],
        ],
    ]);
    
    // IA-Visual Embeddings - Update endpoint (POST)
    register_rest_route('runart', '/embeddings/update', [
        'methods'  => 'POST',
        'callback' => 'runart_embeddings_update',
        'permission_callback' => 'runart_wpcli_bridge_permission_admin',
        'args' => [
            'type' => [
                'required' => true,
                'type' => 'string',
                'enum' => ['image', 'text'],
                'description' => 'Tipo de embedding a regenerar (image o text)',
            ],
            'ids' => [
                'required' => true,
                'type' => 'array',
                'items' => ['type' => 'integer'],
                'description' => 'Array de IDs a procesar',
            ],
        ],
    ]);
    
    // F9 Content Enrichment - Get enriched content (GET)
    register_rest_route('runart', '/content/enriched', [
        'methods'  => 'GET',
        'callback' => 'runart_content_enriched',
        // Permitir a cualquier usuario autenticado (nonce requerido)
        'permission_callback' => function () { return is_user_logged_in(); },
        'args' => [
            'page_id' => [
                'required' => true,
                'type' => 'string',
                'description' => 'ID de la página enriquecida (ej: page_42)',
            ],
        ],
    ]);
    
    // F10 AI-Visual Pipeline Orchestrator - Master endpoint (GET/POST)
    register_rest_route('runart', '/ai-visual/pipeline', [
        'methods'  => ['GET', 'POST'],
        'callback' => 'runart_ai_visual_pipeline',
        // GET visible para usuarios autenticados (monitor), POST restringido a admins
        'permission_callback' => function( $request ) {
            $method = is_object($request) && method_exists($request, 'get_method') ? strtoupper($request->get_method()) : '';
            if ($method === 'GET') {
                return is_user_logged_in();
            }
            return current_user_can('manage_options');
        },
        'args' => [
            'action' => [
                'required' => true,
                'type' => 'string',
                'enum' => ['status', 'preview', 'regenerate'],
                'description' => 'Acción a ejecutar: status (estado del pipeline), preview (previsualizar contenido), regenerate (solicitar regeneración)',
            ],
            'target' => [
                'required' => false,
                'type' => 'string',
                'enum' => ['embeddings', 'correlations', 'rewrite', 'all'],
                'description' => 'Objetivo de la acción (requerido para preview y regenerate)',
            ],
            'page_id' => [
                'required' => false,
                'type' => 'string',
                'description' => 'ID de página específica (opcional, para preview)',
            ],
        ],
    ]);

    // F10 (Vista) - Endpoint simple para registrar solicitud de regeneración (POST)
    register_rest_route('runart', '/ai-visual/request-regeneration', [
        'methods'  => 'POST',
        'callback' => 'runart_ai_visual_request_regeneration',
        // Permitir a cualquier usuario autenticado (nonce requerido)
        'permission_callback' => function () { return is_user_logged_in(); },
    ]);
    
    // F10 (Deployment) - Endpoint para crear página de monitor remotamente (POST)
    register_rest_route('runart', '/deployment/create-monitor-page', [
        'methods'  => 'POST',
        'callback' => 'runart_deployment_create_monitor_page',
        'permission_callback' => 'runart_wpcli_bridge_permission_admin',
        'args' => [
            'title' => [
                'required' => false,
                'type' => 'string',
                'description' => 'Título de la página a crear/actualizar',
            ],
            'slug' => [
                'required' => false,
                'type' => 'string',
                'description' => 'Slug deseado para la página',
            ],
            'mode' => [
                'required' => false,
                'type' => 'string',
                'enum' => ['technical', 'editor'],
                'description' => 'Modo del shortcode: technical (por defecto) o editor',
            ],
        ],
    ]);
    
    // F10-i (Panel Editorial) - Listado rápido de contenidos IA (GET)
    register_rest_route('runart', '/content/enriched-list', [
        'methods'  => 'GET',
        'callback' => 'runart_content_enriched_list',
        'permission_callback' => 'runart_wpcli_bridge_permission_editor',
    ]);

    // F10-i (Panel Editorial) - Listado paginado de páginas WP (GET)
    register_rest_route('runart', '/content/wp-pages', [
        'methods'  => 'GET',
        'callback' => 'runart_content_wp_pages',
        'permission_callback' => 'runart_wpcli_bridge_permission_editor',
        'args' => [
            'page' => [
                'required' => false,
                'type' => 'integer',
                'minimum' => 1,
                'description' => 'Número de página (default: 1)'
            ],
            'per_page' => [
                'required' => false,
                'type' => 'integer',
                'minimum' => 1,
                'maximum' => 50,
                'description' => 'Elementos por página (default: 25, máximo: 50)'
            ],
        ],
    ]);

    // F10-i (Panel Editorial) - Fusión opcional IA + WP (POST)
    register_rest_route('runart', '/content/enriched-merge', [
        'methods'  => 'POST',
        'callback' => 'runart_content_enriched_merge',
        'permission_callback' => 'runart_wpcli_bridge_permission_editor',
    ]);
    
    // F10-b (Panel Editorial) - Aprobar/Rechazar contenido (POST)
    register_rest_route('runart', '/content/enriched-approve', [
        'methods'  => 'POST',
        'callback' => 'runart_content_enriched_approve',
        // Permitir a cualquier usuario autenticado
        'permission_callback' => function () { return is_user_logged_in(); },
        'args' => [
            'id' => [
                'required' => true,
                'type' => 'string',
                'description' => 'ID del contenido (ej: page_42)',
            ],
            'status' => [
                'required' => true,
                'type' => 'string',
                'enum' => ['approved', 'rejected', 'needs_review'],
                'description' => 'Estado de aprobación',
            ],
        ],
    ]);
    
    // F10-h: Listado híbrido WP+IA
    register_rest_route('runart', '/content/enriched-hybrid', [
        'methods'  => 'GET',
        'callback' => 'runart_content_enriched_hybrid',
        'permission_callback' => function () { return is_user_logged_in(); },
    ]);
    
    // F10-h: Solicitar generación de contenido IA para una página
    register_rest_route('runart', '/content/enriched-request', [
        'methods'  => 'POST',
        'callback' => 'runart_content_enriched_request',
        'permission_callback' => 'runart_wpcli_bridge_permission_editor',
    ]);
});

function runart_wpcli_bridge_permission_admin() {
    return current_user_can('manage_options');
}

function runart_wpcli_bridge_permission_editor() {
    return current_user_can('edit_pages') || current_user_can('manage_options');
}

function runart_wpcli_bridge_ok($data = [], $extra_meta = []) {
    return new WP_REST_Response([
        'ok' => true,
        'data' => $data,
        'meta' => array_merge([
            'timestamp' => gmdate('c'),
            'site' => get_site_url(),
        ], $extra_meta),
    ], 200);
}

function runart_wpcli_bridge_error($message, $code = 'runart_bridge_error', $status = 500) {
    return new WP_Error($code, $message, ['status' => $status]);
}

function runart_wpcli_bridge_health(WP_REST_Request $req) {
    global $wp_version;

    if (!function_exists('get_plugins')) {
        require_once ABSPATH . 'wp-admin/includes/plugin.php';
    }

    $active_theme = wp_get_theme();

    $data = [
        'wp_version' => $wp_version,
        'php_version' => PHP_VERSION,
        'site_url' => site_url(),
        'home_url' => home_url(),
        'active_theme' => [
            'name' => $active_theme ? $active_theme->get('Name') : null,
            'version' => $active_theme ? $active_theme->get('Version') : null,
            'stylesheet' => $active_theme ? $active_theme->get_stylesheet() : null,
        ],
        'debug' => defined('WP_DEBUG') ? (bool) WP_DEBUG : false,
        'rest_root' => esc_url_raw(rest_url()),
    ];
    return runart_wpcli_bridge_ok($data);
}

function runart_wpcli_bridge_cache_flush(WP_REST_Request $req) {
    $supported = function_exists('wp_cache_flush');
    $result = false;
    if ($supported) {
        $result = wp_cache_flush();
    }
    /**
     * Hook para integraciones de caché específicas (e.g., plugins de page cache).
     */
    do_action('runart_bridge_cache_flush');

    return runart_wpcli_bridge_ok([
        'object_cache_supported' => $supported,
        'object_cache_flushed' => (bool) $result,
    ]);
}

function runart_wpcli_bridge_rewrite_flush(WP_REST_Request $req) {
    flush_rewrite_rules(false);
    return runart_wpcli_bridge_ok(['rewrite_rules_flushed' => true]);
}

function runart_wpcli_bridge_users_list(WP_REST_Request $req) {
    $users = get_users([
        'fields' => ['ID', 'user_login', 'user_email', 'display_name', 'roles'],
        'number' => 200,
    ]);
    $out = array_map(function ($u) {
        return [
            'ID' => (int) $u->ID,
            'user_login' => $u->user_login,
            'user_email' => $u->user_email,
            'display_name' => $u->display_name,
            'roles' => array_values((array) $u->roles),
        ];
    }, $users);
    return runart_wpcli_bridge_ok(['count' => count($out), 'users' => $out]);
}

function runart_wpcli_bridge_plugins_list(WP_REST_Request $req) {
    if (!function_exists('get_plugins')) {
        require_once ABSPATH . 'wp-admin/includes/plugin.php';
    }
    if (!function_exists('is_plugin_active')) {
        require_once ABSPATH . 'wp-admin/includes/plugin.php';
    }
    $plugins = get_plugins();
    $out = [];
    foreach ($plugins as $path => $data) {
        $out[] = [
            'path' => $path,
            'name' => isset($data['Name']) ? $data['Name'] : basename($path),
            'version' => isset($data['Version']) ? $data['Version'] : null,
            'active' => function_exists('is_plugin_active') ? is_plugin_active($path) : null,
        ];
    }
    return runart_wpcli_bridge_ok(['count' => count($out), 'plugins' => $out]);
}

/**
 * Content Audit: Pages endpoint
 * Retorna todas las páginas y posts con información de idioma y emparejamientos
 */
function runart_audit_pages(WP_REST_Request $req) {
    $posts = get_posts([
        'post_type' => ['page', 'post'],
        'post_status' => 'any',
        'numberposts' => -1,
        'orderby' => 'ID',
        'order' => 'ASC',
    ]);
    
    $items = [];
    $count_es = 0;
    $count_en = 0;
    $count_unknown = 0;
    
    foreach ($posts as $post) {
        // Detectar idioma usando Polylang
        $lang = '-';
        $translations = [];
        
        if (function_exists('pll_get_post_language')) {
            $lang_obj = pll_get_post_language($post->ID, 'object');
            if ($lang_obj) {
                $lang = $lang_obj->slug;
            }
            
            // Obtener traducciones (emparejamientos)
            if (function_exists('pll_get_post_translations')) {
                $trans = pll_get_post_translations($post->ID);
                if (is_array($trans)) {
                    foreach ($trans as $lang_code => $trans_id) {
                        if ($trans_id !== $post->ID) {
                            $translations[$lang_code] = (int) $trans_id;
                        }
                    }
                }
            }
        }
        
        // Fallback: detectar por taxonomía language
        if ($lang === '-') {
            $terms = get_the_terms($post->ID, 'language');
            if ($terms && !is_wp_error($terms)) {
                $lang = $terms[0]->slug;
            }
        }
        
        // Contar por idioma
        if ($lang === 'es') {
            $count_es++;
        } elseif ($lang === 'en') {
            $count_en++;
        } elseif ($lang === '-') {
            $count_unknown++;
        }
        
        $items[] = [
            'id' => $post->ID,
            'url' => get_permalink($post->ID),
            'lang' => $lang,
            'type' => $post->post_type,
            'status' => $post->post_status,
            'title' => $post->post_title,
            'slug' => $post->post_name,
            'translations' => $translations,
        ];
    }
    
    return new WP_REST_Response([
        'ok' => true,
        'total' => count($items),
        'total_es' => $count_es,
        'total_en' => $count_en,
        'total_unknown' => $count_unknown,
        'items' => $items,
        'meta' => [
            'timestamp' => gmdate('c'),
            'site' => get_site_url(),
            'phase' => 'F1',
            'description' => 'Inventario de Páginas y Posts (ES/EN)',
        ],
    ], 200);
}

/**
 * Content Audit: Images endpoint
 * Retorna todas las imágenes con metadata
 */
function runart_audit_images(WP_REST_Request $req) {
    $images = get_posts([
        'post_type' => 'attachment',
        'post_mime_type' => 'image',
        'post_status' => 'inherit',
        'numberposts' => -1,
        'orderby' => 'ID',
        'order' => 'ASC',
    ]);
    
    $items = [];
    $count_es = 0;
    $count_en = 0;
    $count_unknown = 0;
    
    foreach ($images as $image) {
        // Detectar idioma
        $lang = '-';
        if (function_exists('pll_get_post_language')) {
            $lang_obj = pll_get_post_language($image->ID, 'object');
            if ($lang_obj) {
                $lang = $lang_obj->slug;
            }
        }
        
        if ($lang === '-') {
            $terms = get_the_terms($image->ID, 'language');
            if ($terms && !is_wp_error($terms)) {
                $lang = $terms[0]->slug;
            }
        }
        
        // Contar por idioma
        if ($lang === 'es') {
            $count_es++;
        } elseif ($lang === 'en') {
            $count_en++;
        } elseif ($lang === '-') {
            $count_unknown++;
        }
        
        $meta = wp_get_attachment_metadata($image->ID);
        $file_size = filesize(get_attached_file($image->ID));
        
        $items[] = [
            'id' => $image->ID,
            'url' => wp_get_attachment_url($image->ID),
            'lang' => $lang,
            'title' => $image->post_title,
            'alt' => get_post_meta($image->ID, '_wp_attachment_image_alt', true),
            'mime_type' => $image->post_mime_type,
            'file_size' => $file_size,
            'width' => isset($meta['width']) ? $meta['width'] : null,
            'height' => isset($meta['height']) ? $meta['height'] : null,
        ];
    }
    
    return new WP_REST_Response([
        'ok' => true,
        'total' => count($items),
        'total_es' => $count_es,
        'total_en' => $count_en,
        'total_unknown' => $count_unknown,
        'items' => $items,
        'meta' => [
            'timestamp' => gmdate('c'),
            'site' => get_site_url(),
            'phase' => 'F2',
            'description' => 'Inventario de Imágenes (Media Library)',
        ],
    ], 200);
}

/**
 * Endpoint: GET /wp-json/runart/correlations/suggest-images
 * 
 * Sugiere imágenes relevantes para una página basándose en correlación semántica IA-Visual.
 * Lee las recomendaciones pre-calculadas desde data/embeddings/correlations/recommendations_cache.json
 * 
 * Parámetros:
 * - page_id (int, requerido): ID de la página
 * - top_k (int, opcional): Número de recomendaciones (default: 5)
 * - threshold (float, opcional): Umbral de similitud (default: 0.70)
 * 
 * Respuesta:
 * - ok (bool): Estado de la operación
 * - page_id (int): ID de la página consultada
 * - recommendations (array): Lista de imágenes recomendadas con scores
 * 
 * @param WP_REST_Request $req Request object
 * @return WP_REST_Response|WP_Error Response object
 * 
 * @since F7
 */
function runart_correlations_suggest_images(WP_REST_Request $req) {
    $page_id = $req->get_param('page_id');
    $top_k = $req->get_param('top_k') ?? 5;
    $threshold = $req->get_param('threshold') ?? 0.70;
    
    // Construir ruta al cache de recomendaciones
    $cache_info = runart_bridge_locate('embeddings/correlations/recommendations_cache.json');
    
    // Verificar si el archivo existe
    if (!$cache_info['found']) {
        return new WP_REST_Response([
            'ok' => true,
            'page_id' => $page_id,
            'recommendations' => [],
            'message' => 'No recommendations cache available yet. Run correlator.py to generate.',
            'meta' => [
                'timestamp' => gmdate('c'),
                'cache_exists' => false,
                'paths_tried' => $cache_info['paths_tried'],
                'source' => 'not-found',
            ],
        ], 200);
    }
    
    $cache_path = $cache_info['path'];
    
    // Leer cache de recomendaciones
    $cache_content = file_get_contents($cache_path);
    $cache_data = json_decode($cache_content, true);
    
    if ($cache_data === null || !isset($cache_data['cache'])) {
        return runart_wpcli_bridge_error(
            'Invalid recommendations cache format',
            'invalid_cache_format',
            500
        );
    }
    
    // Buscar recomendaciones para la página solicitada
    $page_key = "page_{$page_id}";
    $recommendations = $cache_data['cache'][$page_key] ?? [];
    
    // Filtrar por threshold si es diferente del cache
    if ($threshold > $cache_data['threshold']) {
        $recommendations = array_filter($recommendations, function($rec) use ($threshold) {
            return $rec['similarity_score'] >= $threshold;
        });
    }
    
    // Limitar a top_k
    $recommendations = array_slice($recommendations, 0, $top_k);
    
    return new WP_REST_Response([
        'ok' => true,
        'page_id' => $page_id,
        'total_recommendations' => count($recommendations),
        'recommendations' => $recommendations,
        'meta' => [
            'timestamp' => gmdate('c'),
            'cache_generated_at' => $cache_data['generated_at'] ?? 'unknown',
            'cache_threshold' => $cache_data['threshold'] ?? 0.70,
            'requested_threshold' => $threshold,
            'requested_top_k' => $top_k,
            'phase' => 'F7',
            'description' => 'IA-Visual Image Recommendations',
            'source' => $cache_info['source'],
            'paths_tried' => $cache_info['paths_tried'],
        ],
    ], 200);
}

/**
 * Endpoint: POST /wp-json/runart/embeddings/update
 * 
 * Solicita regeneración de embeddings para imágenes o textos específicos.
 * Este endpoint NO ejecuta IA pesada directamente, sino que registra la solicitud
 * para que sea procesada por los scripts Python en segundo plano.
 * 
 * Body JSON:
 * - type (string, requerido): "image" o "text"
 * - ids (array, requerido): Array de IDs a procesar
 * 
 * Respuesta:
 * - ok (bool): Estado de la operación
 * - type (string): Tipo de embedding solicitado
 * - ids (array): IDs procesados
 * - status (string): Estado del procesamiento
 * 
 * @param WP_REST_Request $req Request object
 * @return WP_REST_Response Response object
 * 
 * @since F7
 */
function runart_embeddings_update(WP_REST_Request $req) {
    $type = $req->get_param('type');
    $ids = $req->get_param('ids');
    
    // Validar parámetros
    if (!in_array($type, ['image', 'text'], true)) {
        return runart_wpcli_bridge_error(
            'Invalid type. Must be "image" or "text"',
            'invalid_type',
            400
        );
    }
    
    if (!is_array($ids) || empty($ids)) {
        return runart_wpcli_bridge_error(
            'ids must be a non-empty array',
            'invalid_ids',
            400
        );
    }
    
    // Registrar solicitud en un log (para procesamiento posterior)
    $storage = runart_bridge_prepare_storage('embeddings/correlations/update_requests.log');
    $log_path = $storage['path'];
    $storage_source = $storage['source'];
    $storage_attempts = $storage['paths_tried'];

    if ($log_path === null) {
        // Fallback a uploads/ si data/ no es escribible
        $uploads = wp_upload_dir();
        $fallback_dir = trailingslashit($uploads['basedir']) . 'runart-jobs/';
        if (!is_dir($fallback_dir)) {
            @mkdir($fallback_dir, 0755, true);
        }
        $log_path = $fallback_dir . 'update_requests.log';
        $storage_source = 'uploads-fallback';
    }
    
    $log_dir = dirname($log_path);
    if (!is_dir($log_dir)) {
        if (function_exists('wp_mkdir_p')) {
            wp_mkdir_p($log_dir);
        } else {
            @mkdir($log_dir, 0755, true);
        }
    }
    $log_entry = [
        'timestamp' => gmdate('c'),
        'type' => $type,
        'ids' => $ids,
        'requested_by' => get_current_user_id(),
    ];
    
    file_put_contents(
        $log_path,
        json_encode($log_entry) . "\n",
        FILE_APPEND | LOCK_EX
    );
    
    return new WP_REST_Response([
        'ok' => true,
        'type' => $type,
        'ids' => $ids,
        'total_ids' => count($ids),
        'status' => 'queued',
        'message' => 'Update request queued. Run Python scripts to process: ' . 
                    ($type === 'image' ? 'vision_analyzer.py' : 'text_encoder.py'),
        'meta' => [
            'timestamp' => gmdate('c'),
            'log_path' => $log_path,
            'storage_source' => $storage_source,
            'paths_tried' => $storage_attempts,
            'phase' => 'F7',
            'description' => 'IA-Visual Embeddings Update Request',
        ],
    ], 200);
}

/**
 * F9 - Endpoint para servir contenido enriquecido.
 * 
 * Lee archivos JSON generados por content_enricher.py (F9) y los devuelve vía REST.
 * NO genera el contenido; solo lo sirve desde el filesystem.
 * 
 * GET /wp-json/runart/content/enriched?page_id=page_42
 * 
 * @param WP_REST_Request $request
 * @return WP_REST_Response
 */
function runart_content_enriched($request) {
    $page_id = $request->get_param('page_id');
    
    if (empty($page_id)) {
        return runart_wpcli_bridge_error(
            'page_id parameter is required',
            'missing_page_id',
            400
        );
    }
    
    // Sanitizar page_id (solo alfanuméricos y guión bajo)
    $page_id = preg_replace('/[^a-z0-9_]/', '', strtolower($page_id));
    
    // Ruta al archivo de contenido enriquecido (F9)
    $enriched_info = runart_bridge_locate('assistants/rewrite/' . $page_id . '.json');
    
    // Verificar si existe el archivo
    if (!$enriched_info['found']) {
        return new WP_REST_Response([
            'ok' => false,
            'status' => 'not_enriched',
            'page_id' => $page_id,
            'message' => 'No enriched content found for this page_id',
            'meta' => [
                'timestamp' => gmdate('c'),
                'phase' => 'F9',
                'expected_path' => $enriched_info['paths_tried'],
                'source' => 'not-found',
            ],
        ], 404);
    }
    
    $enriched_file = $enriched_info['path'];
    
    // Leer archivo JSON
    $enriched_content = file_get_contents($enriched_file);
    if ($enriched_content === false) {
        return runart_wpcli_bridge_error(
            'Error reading enriched content file',
            'read_error',
            500
        );
    }
    
    // Decodificar JSON
    $enriched_data = json_decode($enriched_content, true);
    if (json_last_error() !== JSON_ERROR_NONE) {
        return runart_wpcli_bridge_error(
            'Invalid JSON in enriched content file: ' . json_last_error_msg(),
            'json_decode_error',
            500
        );
    }
    
    // Normalizar formato del JSON (F10-g)
    // El JSON de F9 tiene enriched_es / enriched_en directamente
    // Aseguramos que siempre existan estas claves
    $normalized = [
        'id' => isset($enriched_data['id']) ? $enriched_data['id'] : $page_id,
        'lang' => isset($enriched_data['lang']) ? $enriched_data['lang'] : 'unknown',
        'source_text' => isset($enriched_data['source_text']) ? $enriched_data['source_text'] : '',
        'enriched_es' => isset($enriched_data['enriched_es']) ? $enriched_data['enriched_es'] : [
            'headline' => '',
            'summary' => '',
            'body' => '',
            'visual_references' => [],
            'tags' => []
        ],
        'enriched_en' => isset($enriched_data['enriched_en']) ? $enriched_data['enriched_en'] : [
            'headline' => '',
            'summary' => '',
            'body' => '',
            'visual_references' => [],
            'tags' => []
        ],
        'meta' => isset($enriched_data['meta']) ? $enriched_data['meta'] : []
    ];
    
    // Buscar estado de aprobación si existe (F10-b)
    $approval_data = null;
    $approvals_info = runart_bridge_locate('assistants/rewrite/approvals.json');
    if ($approvals_info['found']) {
        $approvals_content = file_get_contents($approvals_info['path']);
        if ($approvals_content !== false) {
            $approvals = json_decode($approvals_content, true);
            if (json_last_error() === JSON_ERROR_NONE && isset($approvals[$page_id])) {
                $approval_data = $approvals[$page_id];
            }
        }
    }
    
    // Devolver contenido normalizado con aprobación si existe
    $response_data = [
        'ok' => true,
        'page_id' => $page_id,
        'enriched_data' => $normalized,
        'meta' => [
            'timestamp' => gmdate('c'),
            'source_file' => basename($enriched_file),
            'phase' => 'F9',
            'description' => 'Content Enrichment - Rewritten content with AI suggestions',
            'source' => $enriched_info['source'],
            'paths_tried' => $enriched_info['paths_tried'],
            'normalized' => true,
        ],
    ];
    
    if ($approval_data !== null) {
        $response_data['approval'] = $approval_data;
    }
    
    return new WP_REST_Response($response_data, 200);
}

/**
 * F10 - Endpoint orquestador maestro del pipeline IA-Visual.
 * 
 * Proporciona acceso unificado a las capacidades del sistema IA-Visual:
 * - action=status: Estado del pipeline (F7/F8/F9), commits, conteos
 * - action=preview: Previsualizar contenido enriquecido
 * - action=regenerate: Solicitar regeneración (write-safe)
 * 
 * GET/POST /wp-json/runart/ai-visual/pipeline?action=status
 * 
 * @param WP_REST_Request $request
 * @return WP_REST_Response
 */
function runart_ai_visual_pipeline($request) {
    $action = $request->get_param('action');
    $target = $request->get_param('target');
    $page_id = $request->get_param('page_id');
    
    $base_path = ABSPATH . '../';
    
    switch ($action) {
        case 'status':
            return runart_ai_visual_pipeline_status($base_path);
            
        case 'preview':
            if (empty($target)) {
                return runart_wpcli_bridge_error(
                    'target parameter is required for preview action',
                    'missing_target',
                    400
                );
            }
            return runart_ai_visual_pipeline_preview($base_path, $target, $page_id);
            
        case 'regenerate':
            if (empty($target)) {
                return runart_wpcli_bridge_error(
                    'target parameter is required for regenerate action',
                    'missing_target',
                    400
                );
            }
            return runart_ai_visual_pipeline_regenerate($base_path, $target, $page_id);
            
        default:
            return runart_wpcli_bridge_error(
                'Invalid action. Must be: status, preview, or regenerate',
                'invalid_action',
                400
            );
    }
}

/**
 * Obtiene el estado actual del pipeline IA-Visual.
 * 
 * @param string $base_path Ruta base del proyecto
 * @return WP_REST_Response
 */
function runart_ai_visual_pipeline_status($base_path) {
    $status = [
        'phases' => [
            'F7' => [
                'name' => 'Arquitectura IA-Visual',
                'status' => 'implemented',
                'description' => 'Módulos Python + endpoints + estructura data/embeddings/',
            ],
            'F8' => [
                'name' => 'Embeddings y Correlaciones',
                'status' => 'completed',
                'commit' => '692ab370',
                'description' => 'Generación de embeddings visuales/texto + matriz de similitud',
            ],
            'F9' => [
                'name' => 'Reescritura Asistida y Enriquecimiento',
                'status' => 'completed',
                'commit' => '276030f3',
                'description' => 'Contenido enriquecido con referencias visuales y metadatos',
            ],
            'F10' => [
                'name' => 'Orquestación y Endurecimiento',
                'status' => 'active',
                'description' => 'Endpoint maestro + validaciones + sistema de jobs',
            ],
        ],
    ];
    
    // Obtener estadísticas de embeddings visuales
    $visual_embeddings_dir = $base_path . 'data/embeddings/visual/clip_512d/embeddings/';
    $visual_count = 0;
    $visual_last_modified = null;
    if (is_dir($visual_embeddings_dir)) {
        $visual_files = glob($visual_embeddings_dir . '*.json');
        $visual_count = count($visual_files);
        if (!empty($visual_files)) {
            $visual_last_modified = gmdate('c', max(array_map('filemtime', $visual_files)));
        }
    }
    
    // Obtener estadísticas de embeddings textuales
    $text_embeddings_dir = $base_path . 'data/embeddings/text/multilingual_mpnet/embeddings/';
    $text_count = 0;
    $text_last_modified = null;
    if (is_dir($text_embeddings_dir)) {
        $text_files = glob($text_embeddings_dir . '*.json');
        $text_count = count($text_files);
        if (!empty($text_files)) {
            $text_last_modified = gmdate('c', max(array_map('filemtime', $text_files)));
        }
    }
    
    // Obtener estadísticas de correlaciones
    $correlations_file = $base_path . 'data/embeddings/correlations/similarity_matrix.json';
    $correlations_data = null;
    if (file_exists($correlations_file)) {
        $correlations_content = file_get_contents($correlations_file);
        $correlations_data = json_decode($correlations_content, true);
    }
    
    // Obtener estadísticas de contenido enriquecido
    $rewrite_dir = $base_path . 'data/assistants/rewrite/';
    $rewrite_count = 0;
    $rewrite_last_modified = null;
    if (is_dir($rewrite_dir)) {
        $rewrite_files = glob($rewrite_dir . 'page_*.json');
        $rewrite_count = count($rewrite_files);
        if (!empty($rewrite_files)) {
            $rewrite_last_modified = gmdate('c', max(array_map('filemtime', $rewrite_files)));
        }
    }
    
    $status['statistics'] = [
        'embeddings' => [
            'visual' => [
                'count' => $visual_count,
                'last_modified' => $visual_last_modified,
                'path' => 'data/embeddings/visual/clip_512d/embeddings/',
            ],
            'text' => [
                'count' => $text_count,
                'last_modified' => $text_last_modified,
                'path' => 'data/embeddings/text/multilingual_mpnet/embeddings/',
            ],
        ],
        'correlations' => [
            'total_comparisons' => $correlations_data['total_comparisons'] ?? 0,
            'above_threshold' => $correlations_data['above_threshold'] ?? 0,
            'threshold' => $correlations_data['threshold'] ?? 0,
            'generated_at' => $correlations_data['generated_at'] ?? null,
            'path' => 'data/embeddings/correlations/',
        ],
        'enriched_content' => [
            'pages_count' => $rewrite_count,
            'last_modified' => $rewrite_last_modified,
            'path' => 'data/assistants/rewrite/',
        ],
    ];
    
    return new WP_REST_Response([
        'ok' => true,
        'pipeline_status' => $status,
        'meta' => [
            'timestamp' => gmdate('c'),
            'phase' => 'F10',
            'description' => 'AI-Visual Pipeline Orchestrator',
        ],
    ], 200);
}

/**
 * Previsualiza contenido del pipeline.
 * 
 * @param string $base_path Ruta base del proyecto
 * @param string $target Target: embeddings, correlations, rewrite, all
 * @param string|null $page_id ID de página opcional
 * @return WP_REST_Response
 */
function runart_ai_visual_pipeline_preview($base_path, $target, $page_id = null) {
    $result = ['previews' => []];
    
    if ($target === 'rewrite' || $target === 'all') {
        if (!empty($page_id)) {
            // Previsualizar página específica
            $page_id = preg_replace('/[^a-z0-9_]/', '', strtolower($page_id));
            $rewrite_file = $base_path . 'data/assistants/rewrite/' . $page_id . '.json';
            
            if (file_exists($rewrite_file)) {
                $content = json_decode(file_get_contents($rewrite_file), true);
                $result['previews']['rewrite'][$page_id] = $content;
            } else {
                $result['previews']['rewrite'][$page_id] = ['error' => 'Not found'];
            }
        } else {
            // Listar todas las páginas enriquecidas
            $index_file = $base_path . 'data/assistants/rewrite/index.json';
            if (file_exists($index_file)) {
                $index = json_decode(file_get_contents($index_file), true);
                $result['previews']['rewrite'] = $index;
            }
        }
    }
    
    if ($target === 'correlations' || $target === 'all') {
        $correlations_file = $base_path . 'data/embeddings/correlations/similarity_matrix.json';
        if (file_exists($correlations_file)) {
            $correlations = json_decode(file_get_contents($correlations_file), true);
            $result['previews']['correlations'] = [
                'total_comparisons' => $correlations['total_comparisons'] ?? 0,
                'above_threshold' => $correlations['above_threshold'] ?? 0,
                'sample_matrix' => array_slice($correlations['matrix'] ?? [], 0, 5),
            ];
        }
    }
    
    if ($target === 'embeddings' || $target === 'all') {
        $visual_index = $base_path . 'data/embeddings/visual/clip_512d/index.json';
        $text_index = $base_path . 'data/embeddings/text/multilingual_mpnet/index.json';
        
        $result['previews']['embeddings'] = [
            'visual' => file_exists($visual_index) ? json_decode(file_get_contents($visual_index), true) : null,
            'text' => file_exists($text_index) ? json_decode(file_get_contents($text_index), true) : null,
        ];
    }
    
    return new WP_REST_Response([
        'ok' => true,
        'target' => $target,
        'page_id' => $page_id,
        'data' => $result,
        'meta' => [
            'timestamp' => gmdate('c'),
            'phase' => 'F10',
            'action' => 'preview',
        ],
    ], 200);
}

/**
 * Solicita regeneración de componentes del pipeline (write-safe).
 * 
 * @param string $base_path Ruta base del proyecto
 * @param string $target Target a regenerar
 * @param string|null $page_id ID de página opcional
 * @return WP_REST_Response
 */
function runart_ai_visual_pipeline_regenerate($base_path, $target, $page_id = null) {
    $job_id = 'job-' . gmdate('Y-m-d\TH:i:s\Z');
    $job = [
        'id' => $job_id,
        'requested_at' => gmdate('c'),
        'requested_by' => 'wp-bridge',
        'target' => $target,
        'page_id' => $page_id,
        'status' => 'pending',
    ];
    
    // Intentar determinar si el entorno permite escritura
    $jobs_dir = $base_path . 'data/ai_visual_jobs/';
    $pending_requests_file = $jobs_dir . 'pending_requests.json';
    $fallback_dir = ABSPATH . 'wp-content/uploads/runart-jobs/';
    $fallback_file = $fallback_dir . 'pending_requests.json';
    
    $write_path = null;
    $write_location = null;
    
    // Intentar escribir en la ubicación del repo primero
    if (is_dir($jobs_dir) || @mkdir($jobs_dir, 0755, true)) {
        if (is_writable($jobs_dir)) {
            $write_path = $pending_requests_file;
            $write_location = 'repository';
        }
    }
    
    // Si no es posible, usar fallback en wp-content/uploads
    if ($write_path === null) {
        if (is_dir($fallback_dir) || @mkdir($fallback_dir, 0755, true)) {
            $write_path = $fallback_file;
            $write_location = 'fallback';
        }
    }
    
    if ($write_path === null) {
        return runart_wpcli_bridge_error(
            'Cannot write regeneration request: no writable location found',
            'write_error',
            500
        );
    }
    
    // Cargar solicitudes existentes
    $existing_jobs = [];
    if (file_exists($write_path)) {
        $content = file_get_contents($write_path);
        $existing_jobs = json_decode($content, true);
        if (!is_array($existing_jobs)) {
            $existing_jobs = [];
        }
    }
    
    // Agregar nueva solicitud
    $existing_jobs[] = $job;
    
    // Guardar
    $success = file_put_contents($write_path, json_encode($existing_jobs, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
    
    if ($success === false) {
        return runart_wpcli_bridge_error(
            'Failed to write regeneration request',
            'write_error',
            500
        );
    }
    
    return new WP_REST_Response([
        'ok' => true,
        'job' => $job,
        'write_location' => $write_location,
        'file_path' => $write_path,
        'message' => 'Regeneration request queued successfully',
        'meta' => [
            'timestamp' => gmdate('c'),
            'phase' => 'F10',
            'action' => 'regenerate',
            'note' => 'Job queued for processing by CI/runner. Check pending_requests.json for status.',
        ],
    ], 200);
}

/**
 * F10 (Vista) — Endpoint: POST /wp-json/runart/ai-visual/request-regeneration
 * 
 * Registra un pedido de regeneración mínimo (solo marca la intención) sin ejecutar Python
 * ni escribir en el repositorio si el entorno es READ_ONLY. Intenta escribir en
 * wp-content/uploads/runart-jobs/regeneration_request.json.
 * 
 * Respuesta exitosa (escritura OK): { status: "ok", message: "Solicitud registrada" }
 * Si no hay permisos de escritura: { status: "queued", message: "El entorno no permite escritura directa, revisar runner/CI" }
 * 
 * @param WP_REST_Request $request
 * @return WP_REST_Response|WP_Error
 */
function runart_ai_visual_request_regeneration(WP_REST_Request $request) {
    $current_user = wp_get_current_user();
    $user_login = $current_user && $current_user->user_login ? $current_user->user_login : 'unknown';

    // Objetivo fijo para esta vista (correlaciones); se puede ampliar en el futuro vía parámetro
    $target = 'correlations';

    // Directorio de uploads de WP
    $uploads = wp_upload_dir();
    $base_uploads = isset($uploads['basedir']) ? $uploads['basedir'] : (ABSPATH . 'wp-content/uploads');
    $jobs_dir = trailingslashit($base_uploads) . 'runart-jobs/';
    $request_file = $jobs_dir . 'regeneration_request.json';

    // Intentar crear directorio si no existe
    if (!is_dir($jobs_dir)) {
        @mkdir($jobs_dir, 0755, true);
    }

    $payload = [
        'last_request_at' => gmdate('c'),
        'requested_by' => $user_login,
        'target' => $target,
    ];

    // Intentar escribir archivo en uploads
    $can_write = is_dir($jobs_dir) && is_writable($jobs_dir);
    if ($can_write) {
        $ok = @file_put_contents($request_file, json_encode($payload, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
        if ($ok !== false) {
            return new WP_REST_Response([
                'ok' => true,
                'status' => 'ok',
                'message' => 'Solicitud registrada',
                'file_path' => $request_file,
                'data' => $payload,
                'meta' => [
                    'timestamp' => gmdate('c'),
                    'phase' => 'F10',
                    'view' => 'monitor',
                ],
            ], 200);
        }
    }

    // Si no se pudo escribir, devolver mensaje de cola/runner
    return new WP_REST_Response([
        'ok' => true,
        'status' => 'queued',
        'message' => 'El entorno no permite escritura directa, revisar runner/CI',
        'data' => $payload,
        'meta' => [
            'timestamp' => gmdate('c'),
            'phase' => 'F10',
            'view' => 'monitor',
            'note' => 'No se pudo escribir en uploads o carpeta inexistente/no escribible',
        ],
    ], 200);
}

/**
 * F10-b - Listado de contenidos enriquecidos.
 * 
 * Lee data/assistants/rewrite/index.json y fusiona con approvals.json si existe.
 * 
 * GET /wp-json/runart/content/enriched-list
 * 
 * @param WP_REST_Request $request
 * @return WP_REST_Response
 */
function runart_content_enriched_list(WP_REST_Request $request) {
    $start = microtime(true);
    $paths_tried = [];
    $found_path = null;
    $found_label = 'none';

    $candidates = [];
    if (defined('WP_CONTENT_DIR')) {
        $candidates[] = [
            'label' => 'wp-content',
            'path' => trailingslashit(WP_CONTENT_DIR) . 'runart-data/assistants/rewrite/index.json',
        ];
        $candidates[] = [
            'label' => 'uploads',
            'path' => trailingslashit(WP_CONTENT_DIR) . 'uploads/runart-data/assistants/rewrite/index.json',
        ];
    }
    $candidates[] = [
        'label' => 'plugin',
        'path' => trailingslashit(plugin_dir_path(__FILE__)) . 'data/assistants/rewrite/index.json',
    ];

    foreach ($candidates as $candidate) {
        $paths_tried[] = $candidate['path'];
        if (file_exists($candidate['path'])) {
            $found_path = $candidate['path'];
            $found_label = $candidate['label'];
            break;
        }
    }

    if (!$found_path) {
        $duration = (int) round((microtime(true) - $start) * 1000);
        return new WP_REST_Response([
            'ok' => true,
            'source' => 'none',
            'items' => [],
            'meta' => [
                'timestamp' => gmdate('c'),
                'duration_ms' => $duration,
                'paths_tried' => $paths_tried,
            ],
        ], 200);
    }

    $index_content = @file_get_contents($found_path);
    if ($index_content === false) {
        return runart_wpcli_bridge_error('Unable to read IA index file', 'read_error', 500);
    }

    $index_data = json_decode($index_content, true);
    if (json_last_error() !== JSON_ERROR_NONE) {
        return runart_wpcli_bridge_error(
            'Invalid IA index JSON: ' . json_last_error_msg(),
            'json_decode_error',
            500
        );
    }

    $items = [];
    if (isset($index_data['pages']) && is_array($index_data['pages'])) {
        foreach ($index_data['pages'] as $page) {
            $page_id = isset($page['page_id']) ? $page['page_id'] : (isset($page['id']) ? $page['id'] : '');
            if (empty($page_id)) {
                continue;
            }

            $title = isset($page['title']) ? (string) $page['title'] : $page_id;
            $lang = isset($page['lang']) ? (string) $page['lang'] : 'es';

            $item = [
                'id' => $page_id,
                'title' => $title,
                'lang' => $lang,
                'status' => isset($page['status']) ? (string) $page['status'] : 'generated',
                'source' => 'ia',
                'payload' => $page,
            ];

            if (isset($page['wp_id'])) {
                $item['wp_id'] = (int) $page['wp_id'];
            }

            $items[] = $item;
        }
    }

    $duration = (int) round((microtime(true) - $start) * 1000);

    return new WP_REST_Response([
        'ok' => true,
        'source' => $found_path,
        'source_label' => $found_label,
        'items' => $items,
        'count' => count($items),
        'meta' => [
            'timestamp' => gmdate('c'),
            'duration_ms' => $duration,
            'paths_tried' => $paths_tried,
        ],
    ], 200);
}

/**
 * F10-b - Aprobar/Rechazar contenido enriquecido.
 * 
 * Guarda estado de aprobación en data/assistants/rewrite/approvals.json.
 * Si el entorno es readonly, intenta guardar en uploads/ como fallback.
 * 
 * POST /wp-json/runart/content/enriched-approve
 * Body: { "id": "page_42", "status": "approved" | "rejected" | "needs_review" }
 * 
 * @param WP_REST_Request $request
 * @return WP_REST_Response
 */
function runart_content_enriched_approve(WP_REST_Request $request) {
    $id = $request->get_param('id');
    $status = $request->get_param('status');
    
    // Validar parámetros
    if (empty($id) || empty($status)) {
        return runart_wpcli_bridge_error(
            'id and status parameters are required',
            'missing_params',
            400
        );
    }
    
    $current_user = wp_get_current_user();
    $user_login = $current_user && $current_user->user_login ? $current_user->user_login : 'unknown';
    
    $approval_entry = [
        'status' => $status,
        'updated_at' => gmdate('c'),
        'updated_by' => $user_login,
    ];
    
    // Ubicar aprobaciones existentes y cargarlas
    $approvals = [];
    $approvals_loc = runart_bridge_locate('assistants/rewrite/approvals.json');
    if ($approvals_loc['found']) {
        $approvals_content = file_get_contents($approvals_loc['path']);
        if ($approvals_content !== false) {
            $approvals_data = json_decode($approvals_content, true);
            if (json_last_error() === JSON_ERROR_NONE) {
                $approvals = $approvals_data;
            }
        }
    }
    
    // Actualizar o insertar aprobación
    $approvals[$id] = $approval_entry;
    
    // Preparar destino escribible (prefiere wp-content/runart-data, luego repo)
    $storage = runart_bridge_prepare_storage('assistants/rewrite/approvals.json');
    if (!empty($storage['path'])) {
        $ok = @file_put_contents(
            $storage['path'],
            json_encode($approvals, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE)
        );

        if ($ok !== false) {
            return new WP_REST_Response([
                'ok' => true,
                'id' => $id,
                'status' => $status,
                'message' => 'Aprobación registrada correctamente',
                'approval' => $approval_entry,
                'meta' => [
                    'timestamp' => gmdate('c'),
                    'phase' => 'F10-b',
                    'storage' => $storage['source'],
                    'storage_path' => $storage['path'],
                    'storage_paths_tried' => $storage['paths_tried'],
                    'approvals_origin' => $approvals_loc['found'] ? $approvals_loc['source'] : 'not-found',
                ],
            ], 200);
        }
    }
    
    // Fallback: escribir en uploads/ si data/ no es escribible
    $uploads = wp_upload_dir();
    $base_uploads = isset($uploads['basedir']) ? $uploads['basedir'] : (ABSPATH . 'wp-content/uploads');
    $jobs_dir = trailingslashit($base_uploads) . 'runart-jobs/';
    $fallback_file = $jobs_dir . 'enriched-approvals.log';
    
    if (!is_dir($jobs_dir)) {
        @mkdir($jobs_dir, 0755, true);
    }
    
    $log_entry = json_encode([
        'timestamp' => gmdate('c'),
        'id' => $id,
        'status' => $status,
        'updated_by' => $user_login,
    ]) . "\n";
    
    $fallback_ok = @file_put_contents($fallback_file, $log_entry, FILE_APPEND);
    
    if ($fallback_ok !== false) {
        return new WP_REST_Response([
            'ok' => false,
            'status' => 'queued',
            'id' => $id,
            'requested_status' => $status,
            'message' => 'Staging en modo solo lectura. Solicitud registrada en uploads/.',
            'approval' => $approval_entry,
            'meta' => [
                'timestamp' => gmdate('c'),
                'phase' => 'F10-b',
                'storage' => 'uploads/runart-jobs (readonly fallback)',
                'intended_storage' => $storage['source'] ?? 'not-writable',
                'intended_storage_paths_tried' => $storage['paths_tried'] ?? [],
                'note' => 'Ejecutar CI para persistir en repo',
            ],
        ], 200);
    }
    
    // Si todo falló
    return runart_wpcli_bridge_error(
        'No se pudo registrar la aprobación (permisos de escritura)',
        'write_error',
        500
    );
}

/**
 * F10-i — Endpoint rápido para obtener páginas de WordPress con paginación.
 * No fusiona nada; sólo devuelve id/título para que el front haga el merge.
 * - GET /wp-json/runart/content/wp-pages?per_page=25&page=1
 */
function runart_content_wp_pages(WP_REST_Request $request) {
    $page = intval($request->get_param('page')) ?: 1;
    if ($page < 1) $page = 1;
    $per_page = intval($request->get_param('per_page')) ?: 25;
    if ($per_page < 1) $per_page = 1;
    if ($per_page > 50) $per_page = 50;
    $query = [
        'per_page' => $per_page,
        'page' => $page,
        '_fields' => 'id,title,slug,lang'
    ];

    $req = new WP_REST_Request('GET', '/wp/v2/pages');
    $req->set_query_params($query);

    $start = microtime(true);
    $resp = rest_do_request($req);
    $duration_ms = (int) round((microtime(true) - $start) * 1000);

    $status = 500;
    if ($resp instanceof WP_REST_Response) {
        $status = $resp->get_status();
    } elseif (is_wp_error($resp)) {
        $status = $resp->get_error_code() ? 500 : 500;
    }

    if (!$resp || is_wp_error($resp) || $status >= 400) {
        return new WP_REST_Response([
            'ok' => false,
            'message' => 'wp timeout',
            'status' => $status,
            'duration_ms' => $duration_ms,
        ], 200);
    }

    $data = $resp->get_data();
    $headers = $resp->get_headers();
    $total = isset($headers['X-WP-Total']) ? (int) $headers['X-WP-Total'] : null;
    $total_pages = isset($headers['X-WP-TotalPages']) ? (int) $headers['X-WP-TotalPages'] : null;

    $pages = [];
    if (is_array($data)) {
        foreach ($data as $p) {
            if (!is_array($p) || !isset($p['id'])) {
                continue;
            }
            $pid = (int) $p['id'];
            $title = '';
            if (isset($p['title'])) {
                if (is_array($p['title']) && isset($p['title']['rendered'])) {
                    $title = wp_strip_all_tags($p['title']['rendered']);
                } elseif (is_string($p['title'])) {
                    $title = $p['title'];
                }
            }

            $pages[] = [
                'id' => 'page_' . $pid,
                'wp_id' => $pid,
                'title' => $title ?: ('Página ' . $pid),
                'slug' => isset($p['slug']) ? (string) $p['slug'] : '',
                'lang' => isset($p['lang']) ? (string) $p['lang'] : 'es',
            ];
        }
    }

    $has_more = $total_pages ? ($page < $total_pages) : false;
    $next = $has_more ? (rest_url('runart/content/wp-pages') . '?page=' . ($page + 1) . '&per_page=' . $per_page) : null;

    return new WP_REST_Response([
        'ok' => true,
        'pages' => $pages,
        'page' => $page,
        'per_page' => $per_page,
        'total' => $total,
        'total_pages' => $total_pages,
        'has_more' => $has_more,
        'next' => $next,
        'duration_ms' => $duration_ms,
    ], 200);
}

function runart_content_enriched_merge(WP_REST_Request $request) {
    $payload = $request->get_json_params();
    $ia_items = isset($payload['ia']) && is_array($payload['ia']) ? $payload['ia'] : [];
    $wp_items = isset($payload['wp']) && is_array($payload['wp']) ? $payload['wp'] : [];

    $order = [];
    $map = [];

    $normalize_id = function ($item) {
        if (is_array($item)) {
            if (!empty($item['id'])) {
                return (string) $item['id'];
            }
            if (!empty($item['page_id'])) {
                return (string) $item['page_id'];
            }
            if (!empty($item['wp_id'])) {
                return 'page_' . (int) $item['wp_id'];
            }
        }
        return null;
    };

    foreach ($ia_items as $entry) {
        if (!is_array($entry)) {
            continue;
        }
        $id = $normalize_id($entry);
        if (!$id) {
            continue;
        }

        $item = [
            'id' => $id,
            'title' => isset($entry['title']) ? (string) $entry['title'] : $id,
            'lang' => isset($entry['lang']) ? (string) $entry['lang'] : 'es',
            'status' => isset($entry['status']) ? (string) $entry['status'] : 'generated',
            'source' => 'ia',
        ];

        if (isset($entry['wp_id'])) {
            $item['wp_id'] = (int) $entry['wp_id'];
        }
        if (isset($entry['slug'])) {
            $item['slug'] = (string) $entry['slug'];
        }

        $map[$id] = $item;
        $order[] = $id;
    }

    foreach ($wp_items as $entry) {
        if (!is_array($entry)) {
            continue;
        }
        $id = $normalize_id($entry);
        if (!$id) {
            continue;
        }

        $title = isset($entry['title']) ? (string) $entry['title'] : $id;
        $lang = isset($entry['lang']) ? (string) $entry['lang'] : 'es';
        $wp_id = isset($entry['wp_id']) ? (int) $entry['wp_id'] : null;
        $slug = isset($entry['slug']) ? (string) $entry['slug'] : '';
        $status = isset($entry['status']) ? (string) $entry['status'] : 'pending';

        if (isset($map[$id])) {
            $map[$id]['source'] = 'hybrid';
            $map[$id]['title'] = $map[$id]['title'] ?: $title;
            $map[$id]['lang'] = $map[$id]['lang'] ?: $lang;
            if (!isset($map[$id]['wp_id']) && $wp_id) {
                $map[$id]['wp_id'] = $wp_id;
            }
            if (!empty($slug)) {
                $map[$id]['slug'] = $slug;
            }
            if (!empty($status) && $map[$id]['status'] === 'pending') {
                $map[$id]['status'] = $status;
            }
        } else {
            $map[$id] = [
                'id' => $id,
                'wp_id' => $wp_id,
                'title' => $title,
                'slug' => $slug,
                'lang' => $lang,
                'status' => $status,
                'source' => 'wp',
            ];
            $order[] = $id;
        }
    }

    $result = [];
    $seen = [];
    foreach ($order as $id) {
        if (isset($map[$id]) && !isset($seen[$id])) {
            $item = $map[$id];
            if (empty($item['status'])) {
                $item['status'] = 'pending';
            }
            $result[] = $item;
            $seen[$id] = true;
        }
    }

    return new WP_REST_Response($result, 200);
}

/**
 * F10-h - Listado híbrido WP+IA.
 * 
 * Lista todas las páginas de WordPress y las cruza con contenidos IA generados.
 * 
 * GET /wp-json/runart/content/enriched-hybrid
 * 
 * @param WP_REST_Request $request
 * @return WP_REST_Response
 */
function runart_content_enriched_hybrid(WP_REST_Request $request) {
    $result = [];
    $wp_sync = false;
    
    // 1. Intentar obtener páginas de WordPress via REST interno
    $wp_pages = [];
    $wp_request = new WP_REST_Request('GET', '/wp/v2/pages');
    $wp_request->set_param('per_page', 100);
    $wp_request->set_param('status', 'publish');
    $wp_response = rest_do_request($wp_request);
    
    if ($wp_response->is_error()) {
        // Si falla, continuar solo con datos IA
        $wp_sync = false;
    } else {
        $wp_pages = $wp_response->get_data();
        $wp_sync = true;
    }
    
    // 2. Leer índice de contenidos IA
    $ia_pages = [];
    $index_info = runart_bridge_locate('assistants/rewrite/index.json');
    if ($index_info['found']) {
        $index_content = file_get_contents($index_info['path']);
        if ($index_content !== false) {
            $index_data = json_decode($index_content, true);
            if (json_last_error() === JSON_ERROR_NONE && isset($index_data['pages'])) {
                foreach ($index_data['pages'] as $page) {
                    $page_id = isset($page['page_id']) ? $page['page_id'] : '';
                    if (!empty($page_id)) {
                        $ia_pages[$page_id] = $page;
                    }
                }
            }
        }
    }
    
    // 3. Leer aprobaciones si existen
    $approvals = [];
    $approvals_info = runart_bridge_locate('assistants/rewrite/approvals.json');
    if ($approvals_info['found']) {
        $approvals_content = file_get_contents($approvals_info['path']);
        if ($approvals_content !== false) {
            $approvals_data = json_decode($approvals_content, true);
            if (json_last_error() === JSON_ERROR_NONE) {
                $approvals = $approvals_data;
            }
        }
    }
    
    // 4. Cruzar páginas WP con contenidos IA
    $wp_ids_processed = [];
    if ($wp_sync && !empty($wp_pages)) {
        foreach ($wp_pages as $wp_page) {
            $wp_id = $wp_page['id'];
            $wp_ids_processed[] = $wp_id;
            $ia_id = 'page_' . $wp_id;
            
            // Verificar si existe JSON de IA para este ID
            $ia_exists = isset($ia_pages[$ia_id]);
            $ia_file = runart_bridge_locate('assistants/rewrite/' . $ia_id . '.json');
            
            $status = 'pending';
            if ($ia_exists || $ia_file['found']) {
                $status = 'generated';
                // Verificar si tiene aprobación
                if (isset($approvals[$ia_id])) {
                    $status = $approvals[$ia_id]['status'];
                }
            }
            
            $item = [
                'wp_id' => $wp_id,
                'ia_id' => $ia_exists ? $ia_id : null,
                'title' => isset($wp_page['title']['rendered']) ? $wp_page['title']['rendered'] : 'Sin título',
                'slug' => isset($wp_page['slug']) ? $wp_page['slug'] : '',
                'lang' => isset($wp_page['lang']) ? $wp_page['lang'] : (isset($ia_pages[$ia_id]['lang']) ? $ia_pages[$ia_id]['lang'] : 'unknown'),
                'status' => $status,
                'source' => $ia_exists || $ia_file['found'] ? 'hybrid' : 'wp',
            ];
            
            if ($ia_exists || $ia_file['found']) {
                $item['ia_data'] = $ia_pages[$ia_id] ?? ['page_id' => $ia_id];
            }
            
            $result[] = $item;
        }
    }
    
    // 5. Añadir páginas IA que no están en WP (puede pasar si se borró página de WP)
    foreach ($ia_pages as $ia_id => $ia_page) {
        // Extraer wp_id del ia_id (page_42 → 42)
        if (preg_match('/page_(\d+)/', $ia_id, $matches)) {
            $wp_id = (int)$matches[1];
            if (in_array($wp_id, $wp_ids_processed)) {
                continue; // Ya procesada
            }
        } else {
            $wp_id = null;
        }
        
        $status = isset($approvals[$ia_id]) ? $approvals[$ia_id]['status'] : 'generated';
        
        $result[] = [
            'wp_id' => $wp_id,
            'ia_id' => $ia_id,
            'title' => isset($ia_page['title']) ? $ia_page['title'] : $ia_id,
            'slug' => '',
            'lang' => isset($ia_page['lang']) ? $ia_page['lang'] : 'unknown',
            'status' => $status,
            'source' => 'ia',
            'ia_data' => $ia_page,
        ];
    }
    
    // 6. Estadísticas
    $total_pages = count($result);
    $generated = count(array_filter($result, function($item) {
        return in_array($item['status'], ['generated', 'approved', 'rejected', 'needs_review']);
    }));
    $pending = count(array_filter($result, function($item) {
        return $item['status'] === 'pending';
    }));
    
    return new WP_REST_Response([
        'ok' => true,
        'items' => $result,
        'stats' => [
            'total' => $total_pages,
            'generated' => $generated,
            'pending' => $pending,
            'wp_sync' => $wp_sync,
        ],
        'meta' => [
            'timestamp' => gmdate('c'),
            'phase' => 'F10-h',
            'source' => 'hybrid',
            'wp_sync' => $wp_sync,
            'ia_index_source' => $index_info['found'] ? $index_info['source'] : 'not-found',
        ],
    ], 200);
}

/**
 * F10-h - Solicitar generación de contenido IA para una página.
 * 
 * Registra solicitud de generación en uploads/runart-jobs/
 * 
 * POST /wp-json/runart/content/enriched-request
 * Body: { "wp_id": 57, "lang": "es" }
 * 
 * @param WP_REST_Request $request
 * @return WP_REST_Response
 */
function runart_content_enriched_request(WP_REST_Request $request) {
    $params = $request->get_json_params();

    $wp_id = isset($params['wp_id']) ? (int) $params['wp_id'] : (int) $request->get_param('wp_id');
    $slug = isset($params['slug']) ? (string) $params['slug'] : (string) $request->get_param('slug');
    $lang = isset($params['lang']) ? (string) $params['lang'] : ($request->get_param('lang') ?: 'es');
    $assistant = isset($params['assistant']) ? (string) $params['assistant'] : ($request->get_param('assistant') ?: 'ia-visual');

    if (empty($wp_id)) {
        return runart_wpcli_bridge_error('wp_id parameter is required', 'missing_wp_id', 400);
    }

    $current_user = wp_get_current_user();
    $user_login = $current_user && $current_user->user_login ? $current_user->user_login : 'unknown';

    $uploads = wp_upload_dir();
    $base_uploads = isset($uploads['basedir']) ? $uploads['basedir'] : (ABSPATH . 'wp-content/uploads');
    $jobs_dir = trailingslashit($base_uploads) . 'runart-jobs/';
    $requests_file = $jobs_dir . 'enriched-requests.json';

    if (!is_dir($jobs_dir)) {
        if (function_exists('wp_mkdir_p')) {
            wp_mkdir_p($jobs_dir);
        } else {
            @mkdir($jobs_dir, 0755, true);
        }
    }

    if (!is_dir($jobs_dir) || !is_writable($jobs_dir)) {
        return new WP_REST_Response([
            'ok' => false,
            'status' => 'readonly',
            'message' => 'staging no permite escritura, ejecute runner en CI',
        ], 200);
    }

    $queue = [];
    if (file_exists($requests_file)) {
        $raw = file_get_contents($requests_file);
        if ($raw !== false) {
            $decoded = json_decode($raw, true);
            if (json_last_error() === JSON_ERROR_NONE && is_array($decoded)) {
                $queue = $decoded;
            }
        }
    }

    $job = [
        'wp_id' => $wp_id,
        'slug' => $slug,
        'lang' => $lang ?: 'es',
        'assistant' => $assistant ?: 'ia-visual',
        'status' => 'queued',
        'requested_at' => gmdate('c'),
        'requested_by' => $user_login,
    ];

    $queue[] = $job;

    $encoded = wp_json_encode($queue, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    $written = @file_put_contents($requests_file, $encoded);

    if ($written === false) {
        return new WP_REST_Response([
            'ok' => false,
            'status' => 'readonly',
            'message' => 'staging no permite escritura, ejecute runner en CI',
        ], 200);
    }

    return new WP_REST_Response([
        'ok' => true,
        'status' => 'queued',
        'job' => $job,
        'queue_file' => str_replace(ABSPATH, '', $requests_file),
    ], 200);
}

/**
 * Modo editor del monitor: Panel editorial IA-Visual.
 * 
 * Renderiza interfaz de listado y aprobación de contenidos enriquecidos.
 * 
 * @param string $rest_url Base URL de REST API
 * @param string $rest_nonce Nonce de WordPress REST
 * @return string HTML renderizado
 */
function runart_ai_visual_monitor_editor_mode($rest_url, $rest_nonce) {
    ob_start();
    ?>
    <div id="runart-editorial-panel" style="padding:12px;border:1px solid #ddd;border-radius:6px;background:#fff;">
        <h2 style="margin-top:0;">📝 Panel Editorial IA-Visual</h2>
        <p style="color:#666;margin-bottom:16px;">Revisión y aprobación de contenidos enriquecidos por IA</p>
        
        <div style="display:grid;grid-template-columns:350px 1fr;gap:20px;">
            <!-- Columna izquierda: Listado -->
            <div style="border:1px solid #eee;padding:12px;border-radius:6px;background:#f9fafb;">
                <h3 style="margin-top:0;font-size:16px;">Contenidos</h3>
                <div id="rep-content-list" style="min-height:200px;">
                    <div style="text-align:center;padding:20px;color:#999;">Cargando...</div>
                </div>
            </div>
            
            <!-- Columna derecha: Detalle -->
            <div style="border:1px solid #eee;padding:12px;border-radius:6px;">
                <div id="rep-content-detail">
                    <div style="text-align:center;padding:40px;color:#999;">
                        Selecciona un contenido de la lista para ver su detalle
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script>
    // Config global expuesta por WP: base REST URL y nonce
    window.RUNART_MONITOR = {
        restUrl: '<?php echo $rest_url; ?>',
        nonce: '<?php echo esc_js($rest_nonce); ?>'
    };
    </script>
    <script>
    (function(){
        const base = (window.RUNART_MONITOR && window.RUNART_MONITOR.restUrl) || (window.location.origin + '/wp-json/');
        const authHeaders = { 'X-WP-Nonce': (window.RUNART_MONITOR && window.RUNART_MONITOR.nonce) ? window.RUNART_MONITOR.nonce : '' };
        
        const listContainer = document.getElementById('rep-content-list');
        const detailContainer = document.getElementById('rep-content-detail');
        
        let currentItems = [];
        
        // Estado/banners
        let statusHtml = '';
        let currentStats = { total: 0, generated: 0, pending: 0 };

        function setStatus(message, tone) {
            const colors = {
                info: { bg: '#eef2ff', fg: '#3730a3' },
                warn: { bg: '#fff7ed', fg: '#9a3412' },
                ok:   { bg: '#ecfdf5', fg: '#065f46' }
            };
            const c = colors[tone || 'info'];
            statusHtml = `<div style="margin-bottom:8px;padding:8px 10px;background:${c.bg};color:${c.fg};border-radius:4px;font-size:12px;">${message}</div>`;
        }

        // fetch con timeout (solo para WP)
        function fetchWithTimeout(url, options, timeoutMs) {
            const ctrl = new AbortController();
            const id = setTimeout(() => ctrl.abort(), timeoutMs);
            const opts = Object.assign({}, options || {}, { signal: ctrl.signal });
            return fetch(url, opts).finally(() => clearTimeout(id));
        }

        // Fusionar resultados de WP en la lista actual (sin borrar los IA ya pintados)
        function mergeWpPages(wpItems) {
            const map = new Map();
            currentItems.forEach(it => map.set(it.id || it.ia_id, it));

            wpItems.forEach(p => {
                const idStr = p.id || ('page_' + (p.wp_id || ''));
                if (!idStr) return;
                if (map.has(idStr)) {
                    const ref = map.get(idStr);
                    if (!ref.wp_id && p.wp_id) ref.wp_id = p.wp_id;
                    if (!ref.lang && p.lang) ref.lang = p.lang;
                    // Mantener status existente (generated/approved). No tocar si ya existe.
                } else {
                    map.set(idStr, {
                        id: idStr,
                        wp_id: p.wp_id,
                        title: p.title || idStr,
                        lang: p.lang || 'es',
                        status: 'pending'
                    });
                }
            });

            currentItems = Array.from(map.values());
            const generated = currentItems.filter(i => i.status && i.status !== 'pending').length;
            currentStats = {
                total: currentItems.length,
                generated: generated,
                pending: Math.max(0, currentItems.length - generated)
            };
            renderList(currentItems, currentStats);
        }

        // Cargar listado (IA primero, WP en paralelo con timeout)
        function loadList() {
            setStatus('Cargando contenidos IA…', 'info');
            listContainer.innerHTML = '<div style="text-align:center;padding:16px;color:#666;">Cargando contenidos IA…</div>';

            // Lanzar fetch de WP en paralelo (con timeout 5s)
            const wpPromise = fetchWithTimeout(base + 'runart/content/wp-pages?per_page=25&page=1', {
                credentials: 'include',
                headers: authHeaders
            }, 5000)
            .then(r => r.json())
            .then(wpData => {
                if (wpData && wpData.ok && Array.isArray(wpData.items)) {
                    mergeWpPages(wpData.items);
                    setStatus('Páginas WP cargadas.', 'ok');
                } else {
                    setStatus('WP no respondió correctamente, mostrando solo IA.', 'warn');
                }
            })
            .catch(err => {
                console.warn('WP pages fetch failed/timeout:', err);
                setStatus('WP lento o sin respuesta. Modo IA solamente.', 'warn');
            });

            // Cargar IA (rápido - local)
            fetch(base + 'runart/content/enriched-list', {
                credentials: 'include',
                headers: authHeaders
            })
            .then(r => r.json())
            .then(data => {
                if (!data.ok) throw new Error('IA list not ok');
                const items = Array.isArray(data.items) ? data.items : [];
                currentItems = items.map(i => Object.assign({}, i, { status: i.status || 'generated' }));
                currentStats = { total: currentItems.length, generated: currentItems.length, pending: 0 };
                setStatus(`Mostrando contenidos IA (${currentItems.length}). Cargando páginas WP…`, 'info');
                renderList(currentItems, currentStats);
            })
            .catch(err => {
                console.error('Error loading IA enriched-list:', err);
                setStatus('No hay contenidos IA. Cargando páginas WP…', 'warn');
                // Seguir esperando WP para al menos mostrar pendientes
            });
        }
        
        // Renderizar listado
        function renderList(items, stats) {
            const statusColors = {
                'pending': '#999',
                'generated': '#3b82f6',
                'approved': '#059669',
                'rejected': '#dc2626',
                'needs_review': '#f59e0b'
            };
            
            const statusLabels = {
                'pending': 'Pendiente',
                'generated': 'Generado',
                'approved': 'Aprobado',
                'rejected': 'Rechazado',
                'needs_review': 'Revisar'
            };
            
            let html = '';
            // Banner de estado si existe
            if (statusHtml) {
                html += statusHtml;
            }
            
            // Estadísticas (si existen)
            if (stats) {
                html += `
                    <div style="margin-bottom:12px;padding:10px;background:#f0f9ff;border-radius:4px;font-size:12px;">
                        <div><strong>Total páginas:</strong> ${stats.total}</div>
                        <div><strong>Contenidos generados:</strong> ${stats.generated}</div>
                        <div><strong>Pendientes de IA:</strong> ${stats.pending}</div>
                    </div>
                `;
            }
            
            html += '<div style="display:flex;flex-direction:column;gap:8px;">';
            items.forEach(item => {
                const statusColor = statusColors[item.status] || '#999';
                const statusLabel = statusLabels[item.status] || item.status;
                const itemId = item.ia_id || item.id || ('wp_' + item.wp_id);
                const isPending = item.status === 'pending';
                
                html += `
                    <div class="rep-item" data-id="${itemId}" data-wp-id="${item.wp_id || ''}" data-status="${item.status}" 
                         style="padding:10px;border:1px solid #e5e7eb;border-radius:4px;background:#fff;cursor:pointer;transition:all 0.2s;${isPending ? 'opacity:0.7;' : ''}" 
                         onmouseover="this.style.borderColor='#3b82f6';this.style.boxShadow='0 2px 4px rgba(0,0,0,0.1)';" 
                         onmouseout="this.style.borderColor='#e5e7eb';this.style.boxShadow='none';">
                        <div style="font-weight:600;font-size:14px;margin-bottom:4px;">${item.title}</div>
                        <div style="display:flex;justify-content:space-between;font-size:12px;">
                            <span style="color:#666;">${item.lang.toUpperCase()}${item.wp_id ? ' · ID:' + item.wp_id : ''}</span>
                            <span style="color:${statusColor};font-weight:600;">${statusLabel}</span>
                        </div>
                    </div>
                `;
            });
            html += '</div>';
            
            listContainer.innerHTML = html;
            
            // Agregar event listeners
            document.querySelectorAll('.rep-item').forEach(el => {
                el.addEventListener('click', () => {
                    const id = el.getAttribute('data-id');
                    const status = el.getAttribute('data-status');
                    const wpId = el.getAttribute('data-wp-id');
                    console.log('Click en item, data-id =', id, 'status =', status);
                    
                    // Guardar ID actual globalmente para botones de acción
                    window.RUNART_CURRENT_PAGE_ID = id;
                    window.RUNART_CURRENT_WP_ID = wpId;
                    window.RUNART_CURRENT_STATUS = status;
                    
                    // Resaltar item seleccionado
                    document.querySelectorAll('.rep-item').forEach(item => {
                        item.style.background = '#fff';
                    });
                    el.style.background = '#eff6ff';
                    
                    // Si está pendiente, mostrar opción de generar
                    if (status === 'pending') {
                        showPendingDetail(id, wpId);
                    } else {
                        loadDetail(id);
                    }
                });
            });
        }
        
        // Mostrar detalle para página pendiente
        function showPendingDetail(id, wpId) {
            const item = currentItems.find(i => (i.ia_id || i.id || ('wp_' + i.wp_id)) === id);
            const title = item ? item.title : id;
            const lang = item ? item.lang : 'es';
            
            detailContainer.innerHTML = `
                <div style="padding:20px;text-align:center;">
                    <h3 style="margin-top:0;color:#666;">${title}</h3>
                    <p style="color:#999;margin:20px 0;">Este contenido no tiene aún versión enriquecida con IA.</p>
                    <button onclick="window.requestEnrichedGeneration(${wpId}, '${lang}')" 
                            style="padding:12px 24px;background:#3b82f6;color:#fff;border:none;border-radius:6px;cursor:pointer;font-weight:600;font-size:14px;"
                            onmouseover="this.style.background='#2563eb';" onmouseout="this.style.background='#3b82f6';">
                        ✨ Generar contenido IA
                    </button>
                    <p style="font-size:12px;color:#999;margin-top:16px;">La generación puede tardar unos minutos.</p>
                </div>
            `;
        }
        
        // Solicitar generación de contenido IA
        window.requestEnrichedGeneration = function(wpId, lang) {
            const btn = event.target;
            btn.disabled = true;
            btn.innerHTML = 'Procesando...';
            
            fetch(base + 'runart/content/enriched-request', {
                method: 'POST',
                headers: Object.assign({ 'Content-Type': 'application/json' }, authHeaders),
                credentials: 'include',
                body: JSON.stringify({ wp_id: parseInt(wpId), lang: lang })
            })
            .then(r => r.json())
            .then(data => {
                if (data.ok) {
                    detailContainer.innerHTML = `
                        <div style="padding:20px;text-align:center;">
                            <div style="font-size:48px;margin-bottom:16px;">✅</div>
                            <h3 style="color:#059669;">Solicitud registrada</h3>
                            <p style="color:#666;">${data.message || 'La generación se procesará en el próximo ciclo de IA.'}</p>
                            <p style="font-size:12px;color:#999;margin-top:16px;">ID de solicitud: ${data.request_id}</p>
                        </div>
                    `;
                } else {
                    detailContainer.innerHTML = `
                        <div style="padding:20px;text-align:center;">
                            <div style="font-size:48px;margin-bottom:16px;">❌</div>
                            <h3 style="color:#dc2626;">Error</h3>
                            <p style="color:#666;">${data.message || 'No se pudo registrar la solicitud.'}</p>
                        </div>
                    `;
                }
            })
            .catch(err => {
                console.error('Error requesting generation:', err);
                detailContainer.innerHTML = `
                    <div style="padding:20px;text-align:center;">
                        <div style="font-size:48px;margin-bottom:16px;">❌</div>
                        <h3 style="color:#dc2626;">Error de red</h3>
                        <p style="color:#666;">No se pudo conectar con el servidor.</p>
                    </div>
                `;
            });
        };
        }
        
        // Cargar detalle
        function loadDetail(id) {
            if (!id) {
                console.error('loadDetail: ID es vacío o undefined');
                detailContainer.innerHTML = '<div style="padding:20px;color:#c00;">Error: ID de página no proporcionado</div>';
                return;
            }
            
            console.log('loadDetail: cargando página con ID =', id);
            detailContainer.innerHTML = '<div style="text-align:center;padding:40px;color:#999;">Cargando detalle...</div>';
            
            const url = base + 'runart/content/enriched?page_id=' + encodeURIComponent(id);
            console.log('loadDetail: URL completa =', url);
            
            fetch(url, {
                credentials: 'include',
                headers: authHeaders
            })
            .then(r => r.json())
            .then(data => {
                console.log('loadDetail: respuesta del servidor =', data);
                if (!data.ok) {
                    detailContainer.innerHTML = '<div style="padding:20px;color:#c00;">Error: ' + (data.message || data.error || 'No disponible') + '</div>';
                    return;
                }
                
                renderDetail(id, data);
            })
            .catch(err => {
                detailContainer.innerHTML = '<div style="padding:20px;color:#c00;">Error al cargar detalle</div>';
                console.error('Error loading detail:', err);
            });
        }
        
        // Renderizar detalle
        function renderDetail(id, data) {
            const enriched = data.enriched_data || {};
            const approval = data.approval || null;
            
            // Extraer datos normalizados
            const enrichedEs = enriched.enriched_es || {};
            const enrichedEn = enriched.enriched_en || {};
            const lang = enriched.lang || 'unknown';
            
            const headlineEs = enrichedEs.headline || '';
            const summaryEs = enrichedEs.summary || '';
            const bodyEs = enrichedEs.body || '';
            const visualRefsEs = enrichedEs.visual_references || [];
            
            const headlineEn = enrichedEn.headline || '';
            const summaryEn = enrichedEn.summary || '';
            const bodyEn = enrichedEn.body || '';
            const visualRefsEn = enrichedEn.visual_references || [];
            
            let html = `
                <div style="padding:8px;">
                    <h3 style="margin-top:0;border-bottom:2px solid #e5e7eb;padding-bottom:8px;">${id} <span style="font-size:14px;color:#666;font-weight:normal;">(${lang.toUpperCase()})</span></h3>
                    
                    <!-- Contenido en ESPAÑOL -->
                    <div style="margin-bottom:24px;padding:12px;border:1px solid #e5e7eb;border-radius:6px;background:#fffbf0;">
                        <h4 style="margin:0 0 12px 0;color:#059669;font-size:15px;">🇪🇸 Contenido en Español</h4>
                        
                        <div style="margin-bottom:12px;">
                            <strong style="color:#666;font-size:12px;">Headline:</strong>
                            <div style="padding:8px;background:#fff;border-radius:4px;margin-top:4px;font-size:14px;font-weight:600;">
                                ${headlineEs || '<span style="color:#999;font-style:italic;font-weight:normal;">(sin datos)</span>'}
                            </div>
                        </div>
                        
                        <div style="margin-bottom:12px;">
                            <strong style="color:#666;font-size:12px;">Summary:</strong>
                            <div style="padding:8px;background:#fff;border-radius:4px;margin-top:4px;font-size:13px;">
                                ${summaryEs || '<span style="color:#999;font-style:italic;">(sin datos)</span>'}
                            </div>
                        </div>
                        
                        <div style="margin-bottom:12px;">
                            <strong style="color:#666;font-size:12px;">Body:</strong>
                            <div style="padding:8px;background:#fff;border-radius:4px;margin-top:4px;font-size:12px;max-height:180px;overflow-y:auto;white-space:pre-wrap;line-height:1.5;">
                                ${bodyEs || '<span style="color:#999;font-style:italic;">(sin datos)</span>'}
                            </div>
                        </div>
                        
                        ${visualRefsEs.length > 0 ? `
                        <div>
                            <strong style="color:#666;font-size:12px;">Referencias visuales (${visualRefsEs.length}):</strong>
                            <ul style="margin:8px 0 0 20px;padding:0;font-size:12px;">
                                ${visualRefsEs.map(ref => `
                                    <li style="margin-bottom:6px;">
                                        <strong>${ref.filename || ref.image_id}</strong>
                                        ${ref.similarity_score ? ` (score: ${(ref.similarity_score * 100).toFixed(2)}%)` : ''}
                                        ${ref.reason ? `<br><span style="color:#666;font-style:italic;">${ref.reason}</span>` : ''}
                                    </li>
                                `).join('')}
                            </ul>
                        </div>
                        ` : '<div style="color:#999;font-size:12px;font-style:italic;">Sin referencias visuales</div>'}
                    </div>
                    
                    <!-- Content in ENGLISH -->
                    <div style="margin-bottom:24px;padding:12px;border:1px solid #e5e7eb;border-radius:6px;background:#f0f9ff;">
                        <h4 style="margin:0 0 12px 0;color:#3b82f6;font-size:15px;">🇬🇧 Content in English</h4>
                        
                        <div style="margin-bottom:12px;">
                            <strong style="color:#666;font-size:12px;">Headline:</strong>
                            <div style="padding:8px;background:#fff;border-radius:4px;margin-top:4px;font-size:14px;font-weight:600;">
                                ${headlineEn || '<span style="color:#999;font-style:italic;font-weight:normal;">(no data)</span>'}
                            </div>
                        </div>
                        
                        <div style="margin-bottom:12px;">
                            <strong style="color:#666;font-size:12px;">Summary:</strong>
                            <div style="padding:8px;background:#fff;border-radius:4px;margin-top:4px;font-size:13px;">
                                ${summaryEn || '<span style="color:#999;font-style:italic;">(no data)</span>'}
                            </div>
                        </div>
                        
                        <div style="margin-bottom:12px;">
                            <strong style="color:#666;font-size:12px;">Body:</strong>
                            <div style="padding:8px;background:#fff;border-radius:4px;margin-top:4px;font-size:12px;max-height:180px;overflow-y:auto;white-space:pre-wrap;line-height:1.5;">
                                ${bodyEn || '<span style="color:#999;font-style:italic;">(no data)</span>'}
                            </div>
                        </div>
                        
                        ${visualRefsEn.length > 0 ? `
                        <div>
                            <strong style="color:#666;font-size:12px;">Visual references (${visualRefsEn.length}):</strong>
                            <ul style="margin:8px 0 0 20px;padding:0;font-size:12px;">
                                ${visualRefsEn.map(ref => `
                                    <li style="margin-bottom:6px;">
                                        <strong>${ref.filename || ref.image_id}</strong>
                                        ${ref.similarity_score ? ` (score: ${(ref.similarity_score * 100).toFixed(2)}%)` : ''}
                                        ${ref.reason ? `<br><span style="color:#666;font-style:italic;">${ref.reason}</span>` : ''}
                                    </li>
                                `).join('')}
                            </ul>
                        </div>
                        ` : '<div style="color:#999;font-size:12px;font-style:italic;">No visual references</div>'}
                    </div>
            `
            
            // Botones de aprobación
            html += `
                <div style="margin-top:24px;padding-top:16px;border-top:2px solid #e5e7eb;">
                    ${approval ? `
                        <div style="margin-bottom:12px;padding:8px;background:#f0f9ff;border-left:4px solid #3b82f6;font-size:12px;">
                            <strong>Última acción:</strong> ${approval.status} · ${approval.updated_at} · ${approval.updated_by}
                        </div>
                    ` : '<div style="margin-bottom:12px;font-size:12px;color:#999;font-style:italic;">Sin acciones registradas</div>'}
                    
                    <div style="display:flex;gap:10px;margin-bottom:12px;">
                        <button onclick="window.runartApprove('${id}', 'approved')" 
                                style="flex:1;padding:10px;background:#059669;color:#fff;border:none;border-radius:4px;cursor:pointer;font-weight:600;"
                                onmouseover="this.style.background='#047857';" onmouseout="this.style.background='#059669';">
                            ✅ Aprobar
                        </button>
                        <button onclick="window.runartApprove('${id}', 'rejected')" 
                                style="flex:1;padding:10px;background:#dc2626;color:#fff;border:none;border-radius:4px;cursor:pointer;font-weight:600;"
                                onmouseover="this.style.background='#b91c1c';" onmouseout="this.style.background='#dc2626';">
                            ❌ Rechazar
                        </button>
                        <button onclick="window.runartApprove('${id}', 'needs_review')" 
                                style="flex:1;padding:10px;background:#f59e0b;color:#fff;border:none;border-radius:4px;cursor:pointer;font-weight:600;"
                                onmouseover="this.style.background='#d97706';" onmouseout="this.style.background='#f59e0b';">
                            📋 Marcar revisión
                        </button>
                    </div>
                    <div id="rep-approval-result" style="padding:8px;border-radius:4px;display:none;"></div>
                </div>
            `;
            
            html += '</div>';
            
            detailContainer.innerHTML = html;
        }
        
        // Función global para aprobar
        window.runartApprove = function(id, status) {
            console.log('runartApprove: id =', id, 'status =', status);
            
            const resultDiv = document.getElementById('rep-approval-result');
            resultDiv.style.display = 'block';
            resultDiv.innerHTML = 'Procesando...';
            resultDiv.style.background = '#fef3c7';
            resultDiv.style.border = '1px solid #f59e0b';
            resultDiv.style.color = '#000';
            resultDiv.style.padding = '10px';
            
            const payload = { id: id, status: status };
            console.log('runartApprove: payload =', payload);
            
            fetch(base + 'runart/content/enriched-approve', {
                method: 'POST',
                headers: Object.assign({ 'Content-Type': 'application/json' }, authHeaders),
                credentials: 'include',
                body: JSON.stringify(payload)
            })
            .then(r => r.json())
            .then(data => {
                console.log('runartApprove: respuesta =', data);
                
                if (data.ok === true) {
                    resultDiv.innerHTML = '✅ ' + (data.message || 'Aprobación registrada correctamente');
                    resultDiv.style.background = '#d1fae5';
                    resultDiv.style.border = '1px solid #059669';
                } else if (data.status === 'queued') {
                    resultDiv.innerHTML = '🟡 ' + (data.message || 'Solicitud registrada (staging readonly)');
                    resultDiv.style.background = '#fef3c7';
                    resultDiv.style.border = '1px solid #f59e0b';
                } else {
                    resultDiv.innerHTML = '❌ Error: ' + (data.message || data.error || 'No se pudo procesar');
                    resultDiv.style.background = '#fee2e2';
                    resultDiv.style.border = '1px solid #dc2626';
                }
                
                // Recargar listado para actualizar estados
                setTimeout(() => {
                    console.log('runartApprove: recargando listado...');
                    loadList();
                }, 1500);
            })
            .catch(err => {
                resultDiv.innerHTML = '❌ Error de red al aprobar';
                resultDiv.style.background = '#fee2e2';
                resultDiv.style.border = '1px solid #dc2626';
                console.error('Error approving:', err);
            });
        };
        
        // Inicializar
        loadList();
    })();
    </script>
    <?php
    return ob_get_clean();
}

/**
 * Shortcode: [runart_ai_visual_monitor mode="technical|editor"]
 * 
 * Renderiza el monitor IA-Visual en dos modos:
 * - mode="technical" (default): Monitor técnico con endpoints F8/F9/F10
 * - mode="editor": Panel editorial con listado de contenidos y aprobación
 * 
 * Visibilidad: usuarios autenticados con manage_options o edit_pages.
 * 
 * @param array $atts Atributos del shortcode
 * @return string HTML renderizado
 */
function runart_ai_visual_monitor_shortcode($atts = []) {
    // Parsear atributos
    $atts = shortcode_atts([
        'mode' => 'technical', // technical | editor
    ], $atts, 'runart_ai_visual_monitor');
    if (!is_user_logged_in() || !(current_user_can('manage_options') || current_user_can('edit_pages'))) {
        return '<div>Acceso restringido</div>';
    }

    $mode = isset($atts['mode']) ? $atts['mode'] : 'technical';

    ob_start();
    $rest_url = esc_url_raw( get_rest_url() );
    $rest_nonce = wp_create_nonce('wp_rest');
    
    // Modo editor: panel editorial con listado y aprobación
    if ($mode === 'editor') {
        return runart_ai_visual_monitor_editor_mode($rest_url, $rest_nonce);
    }
    
    // Modo technical (default): monitor técnico
    ?>
    <div id="runart-ai-visual-monitor" style="padding:12px;border:1px solid #ddd;border-radius:6px;background:#fff;">
        <h2 style="margin-top:0;">Monitor IA-Visual (F7/F8/F9)</h2>
        <div id="raiv-status" style="margin-bottom:16px;">
            <strong>Estado pipeline (F10):</strong>
            <div id="raiv-status-content" style="font-family:monospace;font-size:12px;background:#f6f8fa;padding:8px;border-radius:4px;">Cargando...</div>
        </div>
        <div id="raiv-blocks" style="display:grid;grid-template-columns:1fr 1fr;gap:16px;">
            <div style="border:1px solid #eee;padding:10px;border-radius:6px;">
                <h3 style="margin-top:0;">Correlaciones (F8) — page_id=42</h3>
                <div id="raiv-correlations" style="font-family:monospace;font-size:12px;background:#f9fafb;padding:8px;border-radius:4px;">Cargando correlaciones...</div>
            </div>
            <div style="border:1px solid #eee;padding:10px;border-radius:6px;">
                <h3 style="margin-top:0;">Contenido enriquecido (F9) — page_42</h3>
                <div id="raiv-enriched" style="font-family:monospace;font-size:12px;background:#f9fafb;padding:8px;border-radius:4px;">Cargando contenido enriquecido...</div>
            </div>
        </div>
        <div style="margin-top:16px;">
            <button id="raiv-request-btn" style="background:#1e40af;color:#fff;border:none;padding:8px 12px;border-radius:4px;cursor:pointer;">Solicitar regeneración de correlaciones</button>
            <span id="raiv-request-result" style="margin-left:10px;font-weight:600;"></span>
        </div>
    </div>
    <script>
    // Config global expuesta por WP: base REST URL y nonce para autenticar llamadas desde el navegador
    window.RUNART_MONITOR = {
        restUrl: '<?php echo $rest_url; ?>',
        nonce: '<?php echo esc_js($rest_nonce); ?>'
    };
    </script>
    <script>
    (function(){
        const elStatus = document.getElementById('raiv-status-content');
        const elCor = document.getElementById('raiv-correlations');
        const elEnr = document.getElementById('raiv-enriched');
        const btnReq = document.getElementById('raiv-request-btn');
        const elReq = document.getElementById('raiv-request-result');

        const base = (window.RUNART_MONITOR && window.RUNART_MONITOR.restUrl) || (window.location.origin + '/wp-json/');
        const endpointCor = base + 'runart/correlations/suggest-images?page_id=42';
        const endpointEnr = base + 'runart/content/enriched?page_id=page_42';
        const endpointStatus = base + 'runart/ai-visual/pipeline?action=status';
        const endpointReq = base + 'runart/ai-visual/request-regeneration';

        const authHeaders = { 'X-WP-Nonce': (window.RUNART_MONITOR && window.RUNART_MONITOR.nonce) ? window.RUNART_MONITOR.nonce : '' };

        // Utilidad para formatear JSON seguro
        function fmt(obj){
            try { return JSON.stringify(obj, null, 2); } catch(e){ return String(obj); }
        }

        // Render estado del pipeline (F10)
    fetch(endpointStatus, { credentials: 'include', headers: authHeaders })
         .then(r => r.ok ? r.json() : Promise.reject(r))
         .then(data => {
            elStatus.textContent = fmt({
                phases: data.pipeline_status && data.pipeline_status.phases ? data.pipeline_status.phases : 'N/A',
                stats: data.pipeline_status && data.pipeline_status.statistics ? data.pipeline_status.statistics : 'N/A'
            });
         })
         .catch(err => {
            elStatus.textContent = 'No disponible (endpoint opcional).';
         });

        // Render correlaciones (F8)
    fetch(endpointCor, { credentials: 'include', headers: authHeaders })
         .then(r => r.json().then(j => ({ ok: r.ok, status: r.status, json: j })))
         .then(({ok,status,json}) => {
            if(!ok){
                elCor.textContent = 'Error ' + status + ': ' + (json && json.message ? json.message : '');
                return;
            }
            const recs = json && json.recommendations ? json.recommendations : [];
            if(!recs.length){
                elCor.textContent = 'Sin recomendaciones o cache no disponible.';
                return;
            }
            const html = ['<ul style="margin:0;padding-left:18px;">']
                .concat(recs.map(r => `<li>image_id=${r.image_id || '-'} | file=${r.filename || r.image_filename || '-'} | score=${(r.similarity_score||0).toFixed(4)}</li>`))
                .concat(['</ul>']).join('');
            elCor.innerHTML = html;
         })
         .catch(err => { elCor.textContent = 'Error al cargar correlaciones.'; });

        // Render contenido enriquecido (F9)
    fetch(endpointEnr, { credentials: 'include', headers: authHeaders })
         .then(r => r.json().then(j => ({ ok: r.ok, status: r.status, json: j })))
         .then(({ok,status,json}) => {
            if(status === 404){
                elEnr.textContent = 'No hay contenido enriquecido para esta página.';
                return;
            }
            if(!ok){
                elEnr.textContent = 'Error ' + status + ': ' + (json && json.message ? json.message : '');
                return;
            }
            const data = json && json.enriched_data ? json.enriched_data : {};
            // Campos flexibles: intentar varias rutas
            const headline = data.enriched_headline || (data.enriched && data.enriched.headline) || data.headline || '(sin headline)';
            const summary = data.enriched_summary || (data.enriched && data.enriched.summary) || data.summary || '(sin summary)';
            const refs = data.visual_references || (data.enriched && data.enriched.visual_references) || [];
            const list = Array.isArray(refs) && refs.length
                ? '<ul style="margin:0;padding-left:18px;">' + refs.map(v => `<li>${v.image_id || '-'} — ${v.media_hint ? (v.media_hint.possible_wp_slug || v.media_hint.original_name || '-') : (v.filename || '-')} (score=${(v.similarity_score||0).toFixed(4)})</li>`).join('') + '</ul>'
                : '(sin referencias)';
            elEnr.innerHTML = `<div><strong>Headline:</strong> ${headline}</div>` +
                              `<div><strong>Summary:</strong> ${summary}</div>` +
                              `<div style="margin-top:6px;"><strong>Visual references:</strong><br/>${list}</div>`;
         })
         .catch(err => { elEnr.textContent = 'Error al cargar contenido enriquecido.'; });

        // Botón: Solicitar regeneración
        btnReq.addEventListener('click', function(){
            elReq.textContent = 'Enviando...';
            fetch(endpointReq, {
                method: 'POST',
                headers: Object.assign({ 'Content-Type': 'application/json' }, authHeaders),
                credentials: 'include',
                body: JSON.stringify({ target: 'correlations' })
            })
            .then(r => r.json().then(j => ({ ok: r.ok, status: r.status, json: j })))
            .then(({ok,status,json}) => {
                if(!ok){
                    elReq.textContent = 'Error ' + status + (json && json.message ? ': ' + json.message : '');
                    elReq.style.color = '#b91c1c';
                    return;
                }
                elReq.textContent = (json && json.status) ? (json.status + ' — ' + (json.message || '')) : 'Solicitud procesada';
                elReq.style.color = '#065f46';
            })
            .catch(err => {
                elReq.textContent = 'Error de red al solicitar regeneración';
                elReq.style.color = '#b91c1c';
            });
        });
    })();
    </script>
    <?php
    return ob_get_clean();
}

// Registrar shortcode
add_shortcode('runart_ai_visual_monitor', 'runart_ai_visual_monitor_shortcode');

// ==========================================
// HOOK DE ACTIVACIÓN - FASE 4.E
// Inicializa estructura IA-Visual automáticamente
// ==========================================

/**
 * Función ejecutada al activar el plugin.
 * Crea la estructura completa de directorios para:
 * - Source of truth (wp-content/runart-data/)
 * - Colas editoriales (wp-content/uploads/runart-jobs/)
 * - Sistema de backups (wp-content/uploads/runart-backups/)
 * - Copia dataset inicial desde plugin
 */
function runart_ia_visual_activate() {
    $upload_dir = wp_upload_dir();
    $wp_content = defined('WP_CONTENT_DIR') ? WP_CONTENT_DIR : ABSPATH . 'wp-content';
    
    // 1. Crear source of truth (Layer 2)
    $source_of_truth = $wp_content . '/runart-data/assistants/rewrite';
    if (!file_exists($source_of_truth)) {
        wp_mkdir_p($source_of_truth);
    }
    
    // 2. Copiar dataset inicial desde plugin (si no existe ya)
    $plugin_data = RUNART_IA_VISUAL_PLUGIN_DIR . 'data/assistants/rewrite';
    if (is_dir($plugin_data) && !file_exists($source_of_truth . '/index.json')) {
        $files = glob($plugin_data . '/*.json');
        foreach ($files as $file) {
            copy($file, $source_of_truth . '/' . basename($file));
        }
    }
    
    // 3. Crear estructura de colas editoriales
    $queues_base = $upload_dir['basedir'] . '/runart-jobs';
    $queue_dirs = ['approved', 'rejected', 'queued', 'logs', 'enriched'];
    foreach ($queue_dirs as $dir) {
        $path = $queues_base . '/' . $dir;
        if (!file_exists($path)) {
            wp_mkdir_p($path);
        }
    }
    
    // 4. Crear estructura de sistema de backups
    $backup_base = $upload_dir['basedir'] . '/runart-backups/ia-visual';
    $backup_dirs = ['daily', 'full', 'monthly'];
    foreach ($backup_dirs as $dir) {
        $path = $backup_base . '/' . $dir;
        if (!file_exists($path)) {
            wp_mkdir_p($path);
        }
    }
    
    // 5. Crear backup inicial de activación
    $activation_backup = $backup_base . '/full/' . date('Ymd') . '/' . date('His') . '_activation';
    if (!file_exists($activation_backup)) {
        wp_mkdir_p($activation_backup);
        
        // Copiar dataset actual como backup
        if (file_exists($source_of_truth . '/index.json')) {
            $backup_files = glob($source_of_truth . '/*.json');
            foreach ($backup_files as $file) {
                copy($file, $activation_backup . '/' . basename($file));
            }
            
            // Crear manifest del backup
            $manifest = [
                'created_at' => gmdate('Y-m-d\TH:i:s\Z'),
                'type' => 'activation',
                'trigger' => 'plugin_activation',
                'files_count' => count($backup_files),
                'plugin_version' => RUNART_IA_VISUAL_VERSION
            ];
            file_put_contents(
                $activation_backup . '/manifest.json',
                json_encode($manifest, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE)
            );
        }
    }
    
    // 6. Registrar en opciones de WordPress
    update_option('runart_ia_visual_activated_at', gmdate('Y-m-d\TH:i:s\Z'));
    update_option('runart_ia_visual_structure_initialized', true);
    update_option('runart_ia_visual_version', RUNART_IA_VISUAL_VERSION);
}

register_activation_hook(__FILE__, 'runart_ia_visual_activate');
