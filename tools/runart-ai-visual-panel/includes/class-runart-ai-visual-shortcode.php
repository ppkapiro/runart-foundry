<?php
if (!defined('ABSPATH')) {
    exit;
}

class RunArt_AI_Visual_Shortcode {
    public static $shortcodes = ['runart_ai_visual_panel', 'runart_ai_visual_monitor'];

    public static function init() {
        foreach (self::$shortcodes as $tag) {
            add_shortcode($tag, [__CLASS__, 'render_panel']);
        }
    }

    public static function render_panel($atts = []) {
        // Enqueue script only when shortcode is rendered
        static $script_enqueued = false;
        if (!$script_enqueued) {
            wp_register_script('runart-aivp-panel', RUNART_AIVP_URL . 'assets/js/panel-editor.js', array(), RUNART_AIVP_VERSION, true);
            wp_localize_script('runart-aivp-panel', 'RUNART_AIVP', array(
                'restUrl' => esc_url_raw(rest_url()),
                'nonce' => wp_create_nonce('wp_rest')
            ));
            wp_enqueue_script('runart-aivp-panel');
            $script_enqueued = true;
        }

        ob_start();
        ?>
        <div id="runart-ai-visual-panel" class="runart-ai-visual-panel">
            <h3>📝 Panel Editorial IA-Visual</h3>
            <div id="runart-aivp-status" style="color:#666;padding:8px;">Cargando...</div>
            <div id="runart-aivp-list" style="min-height:120px;padding:8px;background:#fff;border:1px solid #eee;border-radius:6px;margin-top:8px;">Cargando...</div>
            <div id="runart-aivp-detail" style="margin-top:12px;"></div>
        </div>
        <?php
        return ob_get_clean();
    }
}
