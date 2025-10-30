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
