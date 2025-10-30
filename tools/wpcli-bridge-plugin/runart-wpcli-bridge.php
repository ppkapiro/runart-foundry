<?php
/**
 * Plugin Name:       RunArt WP-CLI Bridge (REST)
 * Description:       Endpoints REST seguros para tareas comunes de WP-CLI y auditoría de contenido (páginas e imágenes).
 * Version:           1.1.0
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
 * Retorna todas las páginas y posts con información de idioma
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
        // Detectar idioma via Polylang
        $lang = '-';
        if (function_exists('pll_get_post_language')) {
            $lang_obj = pll_get_post_language($post->ID, 'object');
            if ($lang_obj) {
                $lang = $lang_obj->slug;
            }
        }
        
        // Fallback: taxonomía
        if ($lang === '-') {
            $terms = get_the_terms($post->ID, 'language');
            if ($terms && !is_wp_error($terms)) {
                $lang = $terms[0]->slug;
            }
        }
        
        // Contar por idioma
        if ($lang === 'es' || $lang === 'es_ES') {
            $count_es++;
        } elseif ($lang === 'en' || $lang === 'en_US' || $lang === 'en_GB') {
            $count_en++;
        } elseif ($lang === '-') {
            $count_unknown++;
        }
        
        $items[] = [
            'ID' => $post->ID,
            'url' => get_permalink($post->ID),
            'lang' => $lang,
            'type' => $post->post_type,
            'status' => $post->post_status,
            'title' => $post->post_title,
            'slug' => $post->post_name,
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
        if ($lang === 'es' || $lang === 'es_ES') {
            $count_es++;
        } elseif ($lang === 'en' || $lang === 'en_US' || $lang === 'en_GB') {
            $count_en++;
        } elseif ($lang === '-') {
            $count_unknown++;
        }
        
        // Metadata
        $metadata = wp_get_attachment_metadata($image->ID);
        $file_path = get_attached_file($image->ID);
        $file_size_kb = 0;
        if ($file_path && file_exists($file_path)) {
            $file_size_kb = round(filesize($file_path) / 1024, 2);
        }
        
        $items[] = [
            'ID' => $image->ID,
            'url' => wp_get_attachment_url($image->ID),
            'lang' => $lang,
            'mime_type' => $image->post_mime_type,
            'width' => isset($metadata['width']) ? $metadata['width'] : null,
            'height' => isset($metadata['height']) ? $metadata['height'] : null,
            'size_kb' => $file_size_kb,
            'title' => $image->post_title,
            'alt' => get_post_meta($image->ID, '_wp_attachment_image_alt', true),
            'file' => basename(get_attached_file($image->ID)),
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
        ],
    ], 200);
}
