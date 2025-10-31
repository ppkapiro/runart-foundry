<?php
/**
 * Init/Seeder: Monitor IA-Visual Page
 * - Registra creación automática de la página "Monitor IA-Visual" al activar el plugin
 * - Fallback en admin_init para escenarios donde no se dispara la activación (deploy incremental)
 */

if (!defined('ABSPATH')) {
    exit; // Exit if accessed directly
}

if (!function_exists('runart_ai_visual_monitor_activate')) {
    /**
     * Crear página de monitor en activación del plugin
     */
    function runart_ai_visual_monitor_activate() {
        if (!is_admin() || !current_user_can('manage_options')) {
            return;
        }
        // Evitar duplicados por título exacto
        $existing = get_page_by_title('Monitor IA-Visual');
        if (!$existing) {
            wp_insert_post([
                'post_title'   => 'Monitor IA-Visual',
                'post_content' => '[runart_ai_visual_monitor]',
                'post_status'  => 'publish',
                'post_type'    => 'page',
            ]);
        }
        // Marcar opción de inicialización realizada
        update_option('runart_ai_visual_monitor_seeded', '1', false);
    }
}

if (!function_exists('runart_ai_visual_monitor_maybe_seed')) {
    /**
     * Fallback: si el plugin ya estaba activo y se desplegó actualización,
     * crear la página una única vez en admin_init.
     */
    function runart_ai_visual_monitor_maybe_seed() {
        if (!is_admin() || !current_user_can('manage_options')) {
            return;
        }
        $seeded = get_option('runart_ai_visual_monitor_seeded', '0');
        if ($seeded === '1') {
            return;
        }
        $existing = get_page_by_title('Monitor IA-Visual');
        if (!$existing) {
            wp_insert_post([
                'post_title'   => 'Monitor IA-Visual',
                'post_content' => '[runart_ai_visual_monitor]',
                'post_status'  => 'publish',
                'post_type'    => 'page',
            ]);
        }
        update_option('runart_ai_visual_monitor_seeded', '1', false);
    }
    add_action('admin_init', 'runart_ai_visual_monitor_maybe_seed');
}

// Registrar hook de activación usando el archivo principal del plugin
if (defined('RUNART_WPCLI_BRIDGE_PLUGIN_FILE')) {
    register_activation_hook(RUNART_WPCLI_BRIDGE_PLUGIN_FILE, 'runart_ai_visual_monitor_activate');
}

if (!function_exists('runart_deployment_create_monitor_page')) {
    /**
     * Endpoint remoto para crear la página del monitor vía REST API.
     * POST /wp-json/runart/deployment/create-monitor-page
     */
    function runart_deployment_create_monitor_page($request) {
        if (!current_user_can('manage_options')) {
            return new WP_Error('forbidden', 'Sin permisos suficientes', ['status' => 403]);
        }
        
        $mode = $request->get_param('mode');
        $mode = in_array($mode, ['editor', 'technical'], true) ? $mode : 'technical';
        $default_title = $mode === 'editor' ? 'Panel Editorial IA-Visual' : 'Monitor IA-Visual';
        $title = $request->get_param('title');
        $title = is_string($title) && trim($title) !== '' ? sanitize_text_field($title) : $default_title;
        
        $slug = $request->get_param('slug');
        $slug = is_string($slug) && trim($slug) !== '' ? sanitize_title($slug) : sanitize_title($title);
        
        // Construir contenido del shortcode según modo
        $shortcode = '[runart_ai_visual_monitor';
        if ($mode !== 'technical') {
            $shortcode .= ' mode="' . esc_attr($mode) . '"';
        }
        $shortcode .= ']';
        
        // Verificar si la página ya existe por slug o título
        $existing = null;
        if (!empty($slug)) {
            $existing = get_page_by_path($slug);
        }
        if (!$existing) {
            $existing = get_page_by_title($title);
        }
        
        $page_args = [
            'post_title'   => $title,
            'post_content' => $shortcode,
            'post_status'  => 'publish',
            'post_type'    => 'page',
        ];
        
        if (!empty($slug)) {
            $page_args['post_name'] = $slug;
        }
        
        if ($existing) {
            $page_args['ID'] = $existing->ID;
            $page_id = wp_update_post($page_args, true);
            if (is_wp_error($page_id)) {
                return new WP_Error('update_failed', $page_id->get_error_message(), ['status' => 500]);
            }
            $message = 'Página actualizada';
        } else {
            $page_id = wp_insert_post($page_args, true);
            if (is_wp_error($page_id)) {
                return new WP_Error('creation_failed', $page_id->get_error_message(), ['status' => 500]);
            }
            $message = 'Página creada exitosamente';
        }
        
        update_option('runart_ai_visual_monitor_seeded', '1', false);
        
        return new WP_REST_Response([
            'ok' => true,
            'message' => $message,
            'data' => [
                'page_id' => $page_id,
                'page_url' => get_permalink($page_id),
                'mode' => $mode,
                'title' => $title,
                'slug' => $slug,
            ],
        ], 200);
    }
}
