<?php
/**
 * Plugin Name:       RunArt WP-CLI Bridge (REST)
 * Description:       Endpoints REST seguros para tareas comunes de WP-CLI (flush cache, flush rewrite, listar usuarios y plugins, health).
 * Version:           1.0.0
 * Author:            RunArt Foundry
 * Requires at least: 5.8
 * Requires PHP:      7.4
 * License:           GPL-2.0-or-later
 * License URI:       http://www.gnu.org/licenses/gpl-2.0.txt
 */

if (!defined('ABSPATH')) {
    exit; // Exit if accessed directly.
}

// Definir ruta del archivo principal del plugin para hooks de activación
if (!defined('RUNART_WPCLI_BRIDGE_PLUGIN_FILE')) {
    define('RUNART_WPCLI_BRIDGE_PLUGIN_FILE', __FILE__);
}

// Incluir inicializador de página de monitor (creación automática al activar)
$__runart_bridge_init_file = __DIR__ . '/init_monitor_page.php';
if (file_exists($__runart_bridge_init_file)) {
    require_once $__runart_bridge_init_file;
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
    ]);
    
    // F10-b (Panel Editorial) - Listado de contenidos enriquecidos (GET)
    register_rest_route('runart', '/content/enriched-list', [
        'methods'  => 'GET',
        'callback' => 'runart_content_enriched_list',
        // Permitir a cualquier usuario autenticado
        'permission_callback' => function () { return is_user_logged_in(); },
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
});

function runart_wpcli_bridge_permission_admin() {
    return current_user_can('manage_options');
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
    $cache_path = ABSPATH . '../data/embeddings/correlations/recommendations_cache.json';
    
    // Verificar si el archivo existe
    if (!file_exists($cache_path)) {
        return new WP_REST_Response([
            'ok' => true,
            'page_id' => $page_id,
            'recommendations' => [],
            'message' => 'No recommendations cache available yet. Run correlator.py to generate.',
            'meta' => [
                'timestamp' => gmdate('c'),
                'cache_path' => $cache_path,
                'cache_exists' => false,
            ],
        ], 200);
    }
    
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
    $log_dir = ABSPATH . '../data/embeddings/correlations/';
    if (!is_dir($log_dir)) {
        mkdir($log_dir, 0755, true);
    }
    
    $log_path = $log_dir . 'update_requests.log';
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
    $enriched_dir = ABSPATH . '../data/assistants/rewrite/';
    $enriched_file = $enriched_dir . $page_id . '.json';
    
    // Verificar si existe el archivo
    if (!file_exists($enriched_file)) {
        return new WP_REST_Response([
            'ok' => false,
            'status' => 'not_enriched',
            'page_id' => $page_id,
            'message' => 'No enriched content found for this page_id',
            'meta' => [
                'timestamp' => gmdate('c'),
                'phase' => 'F9',
                'expected_path' => $enriched_file,
            ],
        ], 404);
    }
    
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
    
    // Buscar estado de aprobación si existe (F10-b)
    $approval_data = null;
    $approvals_file = $enriched_dir . 'approvals.json';
    if (file_exists($approvals_file)) {
        $approvals_content = file_get_contents($approvals_file);
        if ($approvals_content !== false) {
            $approvals = json_decode($approvals_content, true);
            if (json_last_error() === JSON_ERROR_NONE && isset($approvals[$page_id])) {
                $approval_data = $approvals[$page_id];
            }
        }
    }
    
    // Devolver contenido enriquecido con aprobación si existe
    $response_data = [
        'ok' => true,
        'page_id' => $page_id,
        'enriched_data' => $enriched_data,
        'meta' => [
            'timestamp' => gmdate('c'),
            'source_file' => basename($enriched_file),
            'phase' => 'F9',
            'description' => 'Content Enrichment - Rewritten content with AI suggestions',
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
    $enriched_dir = ABSPATH . '../data/assistants/rewrite/';
    $index_file = $enriched_dir . 'index.json';
    
    // Si no existe el índice, devolver lista vacía
    if (!file_exists($index_file)) {
        return new WP_REST_Response([
            'ok' => true,
            'items' => [],
            'message' => 'No hay contenidos enriquecidos.',
            'meta' => [
                'timestamp' => gmdate('c'),
                'phase' => 'F10-b',
                'source' => 'enriched-list',
            ],
        ], 200);
    }
    
    // Leer índice
    $index_content = file_get_contents($index_file);
    if ($index_content === false) {
        return runart_wpcli_bridge_error(
            'Error reading index file',
            'read_error',
            500
        );
    }
    
    $index_data = json_decode($index_content, true);
    if (json_last_error() !== JSON_ERROR_NONE) {
        return runart_wpcli_bridge_error(
            'Invalid JSON in index file: ' . json_last_error_msg(),
            'json_decode_error',
            500
        );
    }
    
    // Leer aprobaciones si existe
    $approvals = [];
    $approvals_file = $enriched_dir . 'approvals.json';
    if (file_exists($approvals_file)) {
        $approvals_content = file_get_contents($approvals_file);
        if ($approvals_content !== false) {
            $approvals_data = json_decode($approvals_content, true);
            if (json_last_error() === JSON_ERROR_NONE) {
                $approvals = $approvals_data;
            }
        }
    }
    
    // Construir lista de items fusionando con aprobaciones
    $items = [];
    if (isset($index_data['pages']) && is_array($index_data['pages'])) {
        foreach ($index_data['pages'] as $page) {
            $page_id = isset($page['id']) ? $page['id'] : '';
            $item = [
                'id' => $page_id,
                'title' => isset($page['title']) ? $page['title'] : $page_id,
                'lang' => isset($page['lang']) ? $page['lang'] : 'unknown',
                'status' => isset($approvals[$page_id]['status']) ? $approvals[$page_id]['status'] : 'generated',
            ];
            
            if (isset($approvals[$page_id])) {
                $item['approval'] = $approvals[$page_id];
            }
            
            $items[] = $item;
        }
    }
    
    return new WP_REST_Response([
        'ok' => true,
        'items' => $items,
        'total' => count($items),
        'meta' => [
            'timestamp' => gmdate('c'),
            'phase' => 'F10-b',
            'source' => 'enriched-list',
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
    
    // Intentar escribir en data/assistants/rewrite/approvals.json
    $enriched_dir = ABSPATH . '../data/assistants/rewrite/';
    $approvals_file = $enriched_dir . 'approvals.json';
    
    // Leer aprobaciones existentes o inicializar
    $approvals = [];
    if (file_exists($approvals_file)) {
        $approvals_content = file_get_contents($approvals_file);
        if ($approvals_content !== false) {
            $approvals_data = json_decode($approvals_content, true);
            if (json_last_error() === JSON_ERROR_NONE) {
                $approvals = $approvals_data;
            }
        }
    }
    
    // Actualizar o insertar aprobación
    $approvals[$id] = $approval_entry;
    
    // Intentar escribir en data/
    $can_write_data = is_dir($enriched_dir) && is_writable($enriched_dir);
    if ($can_write_data) {
        $ok = @file_put_contents(
            $approvals_file,
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
                    'storage' => 'data/assistants/rewrite',
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
        
        // Cargar listado
        function loadList() {
            listContainer.innerHTML = '<div style="text-align:center;padding:20px;color:#999;">Cargando...</div>';
            
            fetch(base + 'runart/content/enriched-list', {
                credentials: 'include',
                headers: authHeaders
            })
            .then(r => r.json())
            .then(data => {
                if (!data.ok || !data.items || data.items.length === 0) {
                    listContainer.innerHTML = '<div style="padding:20px;color:#999;">No hay contenidos enriquecidos.</div>';
                    return;
                }
                
                currentItems = data.items;
                renderList(data.items);
            })
            .catch(err => {
                listContainer.innerHTML = '<div style="padding:20px;color:#c00;">Error al cargar listado</div>';
                console.error('Error loading enriched list:', err);
            });
        }
        
        // Renderizar listado
        function renderList(items) {
            const statusColors = {
                'generated': '#999',
                'approved': '#059669',
                'rejected': '#dc2626',
                'needs_review': '#f59e0b'
            };
            
            const statusLabels = {
                'generated': 'Generado',
                'approved': 'Aprobado',
                'rejected': 'Rechazado',
                'needs_review': 'Revisar'
            };
            
            let html = '<div style="display:flex;flex-direction:column;gap:8px;">';
            items.forEach(item => {
                const statusColor = statusColors[item.status] || '#999';
                const statusLabel = statusLabels[item.status] || item.status;
                
                html += `
                    <div class="rep-item" data-id="${item.id}" style="padding:10px;border:1px solid #e5e7eb;border-radius:4px;background:#fff;cursor:pointer;transition:all 0.2s;" 
                         onmouseover="this.style.borderColor='#3b82f6';this.style.boxShadow='0 2px 4px rgba(0,0,0,0.1)';" 
                         onmouseout="this.style.borderColor='#e5e7eb';this.style.boxShadow='none';">
                        <div style="font-weight:600;font-size:14px;margin-bottom:4px;">${item.title}</div>
                        <div style="display:flex;justify-content:space-between;font-size:12px;">
                            <span style="color:#666;">${item.lang.toUpperCase()}</span>
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
                    loadDetail(id);
                });
            });
        }
        
        // Cargar detalle
        function loadDetail(id) {
            detailContainer.innerHTML = '<div style="text-align:center;padding:40px;color:#999;">Cargando detalle...</div>';
            
            fetch(base + 'runart/content/enriched?page_id=' + id, {
                credentials: 'include',
                headers: authHeaders
            })
            .then(r => r.json())
            .then(data => {
                if (!data.ok) {
                    detailContainer.innerHTML = '<div style="padding:20px;color:#c00;">Error: ' + (data.message || 'No disponible') + '</div>';
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
            
            const headlineEs = enriched.headline_es || enriched.enriched_headline || enriched.headline || '(sin headline ES)';
            const headlineEn = enriched.headline_en || '(sin headline EN)';
            const summaryEs = enriched.summary_es || enriched.enriched_summary || enriched.summary || '(sin summary ES)';
            const summaryEn = enriched.summary_en || '(sin summary EN)';
            const visualRefs = enriched.visual_references || [];
            
            let html = `
                <div style="padding:8px;">
                    <h3 style="margin-top:0;border-bottom:2px solid #e5e7eb;padding-bottom:8px;">${id}</h3>
                    
                    <div style="margin-bottom:16px;">
                        <strong style="color:#3b82f6;">Headline ES:</strong>
                        <div style="padding:8px;background:#f9fafb;border-radius:4px;margin-top:4px;font-size:14px;">${headlineEs}</div>
                    </div>
                    
                    <div style="margin-bottom:16px;">
                        <strong style="color:#3b82f6;">Headline EN:</strong>
                        <div style="padding:8px;background:#f9fafb;border-radius:4px;margin-top:4px;font-size:14px;">${headlineEn}</div>
                    </div>
                    
                    <div style="margin-bottom:16px;">
                        <strong style="color:#3b82f6;">Summary ES:</strong>
                        <div style="padding:8px;background:#f9fafb;border-radius:4px;margin-top:4px;font-size:13px;">${summaryEs}</div>
                    </div>
                    
                    <div style="margin-bottom:16px;">
                        <strong style="color:#3b82f6;">Summary EN:</strong>
                        <div style="padding:8px;background:#f9fafb;border-radius:4px;margin-top:4px;font-size:13px;">${summaryEn}</div>
                    </div>
            `;
            
            if (visualRefs.length > 0) {
                html += '<div style="margin-bottom:16px;"><strong style="color:#3b82f6;">Referencias visuales:</strong><ul style="margin-top:8px;padding-left:20px;font-size:13px;">';
                visualRefs.forEach(ref => {
                    const imgId = ref.image_id || '-';
                    const filename = ref.filename || (ref.media_hint && ref.media_hint.original_name) || '-';
                    const score = ref.similarity_score ? ref.similarity_score.toFixed(4) : '-';
                    const context = ref.context || '';
                    html += `<li style="margin-bottom:6px;"><strong>ID ${imgId}:</strong> ${filename} (score: ${score})${context ? '<br><em style="color:#666;">' + context + '</em>' : ''}</li>`;
                });
                html += '</ul></div>';
            } else {
                html += '<div style="margin-bottom:16px;color:#666;font-style:italic;">Sin referencias visuales</div>';
            }
            
            // Botones de aprobación
            html += `
                <div style="margin-top:24px;padding-top:16px;border-top:2px solid #e5e7eb;">
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
            
            if (approval) {
                html += `
                    <div style="margin-top:12px;padding:10px;background:#f0f9ff;border:1px solid #3b82f6;border-radius:4px;font-size:13px;">
                        <strong>Estado actual:</strong> ${approval.status}<br>
                        <strong>Actualizado:</strong> ${approval.updated_at}<br>
                        <strong>Por:</strong> ${approval.updated_by}
                    </div>
                `;
            }
            
            html += '</div>';
            
            detailContainer.innerHTML = html;
        }
        
        // Función global para aprobar
        window.runartApprove = function(id, status) {
            const resultDiv = document.getElementById('rep-approval-result');
            resultDiv.style.display = 'block';
            resultDiv.innerHTML = 'Procesando...';
            resultDiv.style.background = '#fef3c7';
            resultDiv.style.border = '1px solid #f59e0b';
            
            fetch(base + 'runart/content/enriched-approve', {
                method: 'POST',
                headers: Object.assign({ 'Content-Type': 'application/json' }, authHeaders),
                credentials: 'include',
                body: JSON.stringify({ id: id, status: status })
            })
            .then(r => r.json())
            .then(data => {
                if (data.ok === true) {
                    resultDiv.innerHTML = '✅ ' + (data.message || 'Aprobación registrada correctamente');
                    resultDiv.style.background = '#d1fae5';
                    resultDiv.style.border = '1px solid #059669';
                } else if (data.status === 'queued') {
                    resultDiv.innerHTML = '🟡 ' + (data.message || 'Solicitud registrada (staging readonly)');
                    resultDiv.style.background = '#fef3c7';
                    resultDiv.style.border = '1px solid #f59e0b';
                } else {
                    resultDiv.innerHTML = '❌ Error: ' + (data.message || 'No se pudo procesar');
                    resultDiv.style.background = '#fee2e2';
                    resultDiv.style.border = '1px solid #dc2626';
                }
                
                // Recargar listado para actualizar estados
                setTimeout(() => {
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
