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

    // ==================== AUDIT ENDPOINTS ====================
    // Pages audit (GET) - F1: Inventario de Páginas
    register_rest_route('runart', '/audit/pages', [
        'methods'  => 'GET',
        'callback' => 'runart_audit_pages',
        'permission_callback' => 'runart_wpcli_bridge_permission_admin',
    ]);

    // Images audit (GET) - F2: Inventario de Imágenes
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

// ==================== AUDIT ENDPOINTS IMPLEMENTATION ====================

/**
 * F1: Audit Pages - Inventario de Páginas/Posts
 * GET /wp-json/runart/audit/pages
 * 
 * Returns: JSON with all pages/posts including language, type, status
 */
function runart_audit_pages(WP_REST_Request $req) {
    $args = [
        'post_type' => ['page', 'post'],
        'post_status' => ['publish', 'draft', 'pending', 'private'],
        'posts_per_page' => -1,
        'orderby' => 'ID',
        'order' => 'ASC',
    ];

    $posts = get_posts($args);
    $items = [];
    $total_es = 0;
    $total_en = 0;
    $total_unknown = 0;

    foreach ($posts as $post) {
        $lang = '-';
        
        // Detect language via Polylang if available
        if (function_exists('pll_get_post_language')) {
            $lang_obj = pll_get_post_language($post->ID, 'object');
            $lang = $lang_obj ? $lang_obj->slug : '-';
        } elseif (has_term('', 'language', $post->ID)) {
            // Fallback: check language taxonomy
            $terms = wp_get_post_terms($post->ID, 'language', ['fields' => 'slugs']);
            $lang = !empty($terms) && !is_wp_error($terms) ? $terms[0] : '-';
        }

        // Count by language
        if ($lang === 'es') {
            $total_es++;
        } elseif ($lang === 'en') {
            $total_en++;
        } else {
            $total_unknown++;
        }

        $items[] = [
            'id' => $post->ID,
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
        'total_es' => $total_es,
        'total_en' => $total_en,
        'total_unknown' => $total_unknown,
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
 * F2: Audit Images - Inventario de Imágenes/Media
 * GET /wp-json/runart/audit/images
 * 
 * Returns: JSON with all image attachments including metadata, dimensions, size
 */
function runart_audit_images(WP_REST_Request $req) {
    $args = [
        'post_type' => 'attachment',
        'post_status' => 'inherit',
        'post_mime_type' => 'image',
        'posts_per_page' => -1,
        'orderby' => 'ID',
        'order' => 'ASC',
    ];

    $attachments = get_posts($args);
    $items = [];
    $total_es = 0;
    $total_en = 0;
    $total_unknown = 0;

    foreach ($attachments as $attachment) {
        $lang = '-';
        
        // Detect language via Polylang if available
        if (function_exists('pll_get_post_language')) {
            $lang_obj = pll_get_post_language($attachment->ID, 'object');
            $lang = $lang_obj ? $lang_obj->slug : '-';
        } elseif (has_term('', 'language', $attachment->ID)) {
            // Fallback: check language taxonomy
            $terms = wp_get_post_terms($attachment->ID, 'language', ['fields' => 'slugs']);
            $lang = !empty($terms) && !is_wp_error($terms) ? $terms[0] : '-';
        }

        // Count by language
        if ($lang === 'es') {
            $total_es++;
        } elseif ($lang === 'en') {
            $total_en++;
        } else {
            $total_unknown++;
        }

        // Get attachment metadata
        $metadata = wp_get_attachment_metadata($attachment->ID);
        $file_path = get_attached_file($attachment->ID);
        $file_size_kb = 0;
        if ($file_path && file_exists($file_path)) {
            $file_size_kb = round(filesize($file_path) / 1024, 2);
        }

        $width = isset($metadata['width']) ? (int) $metadata['width'] : 0;
        $height = isset($metadata['height']) ? (int) $metadata['height'] : 0;
        $file = isset($metadata['file']) ? $metadata['file'] : '';

        $items[] = [
            'id' => $attachment->ID,
            'url' => wp_get_attachment_url($attachment->ID),
            'lang' => $lang,
            'mime' => get_post_mime_type($attachment->ID),
            'width' => $width,
            'height' => $height,
            'size_kb' => $file_size_kb,
            'title' => $attachment->post_title,
            'alt' => get_post_meta($attachment->ID, '_wp_attachment_image_alt', true),
            'file' => $file,
        ];
    }

    return new WP_REST_Response([
        'ok' => true,
        'total' => count($items),
        'total_es' => $total_es,
        'total_en' => $total_en,
        'total_unknown' => $total_unknown,
        'items' => $items,
        'meta' => [
            'timestamp' => gmdate('c'),
            'site' => get_site_url(),
            'phase' => 'F2',
            'description' => 'Inventario de Imágenes (Media Library)',
        ],
    ], 200);
}
