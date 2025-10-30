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
        'permission_callback' => 'runart_wpcli_bridge_permission_admin',
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
