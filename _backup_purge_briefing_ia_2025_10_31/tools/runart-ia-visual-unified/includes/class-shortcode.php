<?php
/**
 * @file class-shortcode.php
 * @description Shortcode principal del Panel IA-Visual (monitor/editor).
 * @source Informe de Consolidación, sección 2.2 y 3.1
 * 
 * Responsabilidad:
 * - Registrar shortcode [runart_ai_visual_monitor]
 * - Renderizar panel según modo (technical/editor)
 * - Enqueue de assets (JS/CSS)
 * 
 * Modos:
 * - technical: Panel técnico con todos los controles (por defecto)
 * - editor: Panel editorial simplificado para editores
 * 
 * Opciones de implementación:
 * - OPCIÓN A: JS inline (como master plugin, líneas 2078-2626)
 * - OPCIÓN B: JS externo (assets/js/panel-editor.js + enqueue)
 */

if (!defined('ABSPATH')) {
    exit; // Exit if accessed directly
}

class RunArt_IA_Visual_Shortcode {
    
    /**
     * Registra el shortcode.
     * Hook: init
     */
    public static function register() {
        add_shortcode('runart_ai_visual_monitor', [self::class, 'render']);
    }
    
    /**
     * Renderiza el shortcode del panel IA-Visual.
     *
     * @param array $atts Atributos del shortcode
     * @return string HTML del panel
     */
    public static function render($atts = []) {
        $atts = shortcode_atts([
            'mode' => 'technical', // technical | editor
        ], $atts, 'runart_ai_visual_monitor');
        
        // Enqueue assets externos
        self::enqueue_assets();
        
        // Preparar datos para el JS
        $rest_url = rest_url('runart/');
        $rest_nonce = wp_create_nonce('wp_rest');
        
        ob_start();
        
        // Renderizar según modo
        if ($atts['mode'] === 'editor') {
            self::render_editor_mode($rest_url, $rest_nonce);
        } else {
            self::render_technical_mode($rest_url, $rest_nonce);
        }
        
        return ob_get_clean();
    }
    
    /**
     * Renderiza modo editor (simplificado).
     */
    private static function render_editor_mode($rest_url, $rest_nonce) {
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
        window.RUNART_MONITOR = {
            restUrl: '<?php echo esc_js($rest_url); ?>',
            nonce: '<?php echo esc_js($rest_nonce); ?>',
            mode: 'editor'
        };
        </script>
        <?php
    }
    
    /**
     * Renderiza modo technical (completo).
     */
    private static function render_technical_mode($rest_url, $rest_nonce) {
        ?>
        <div id="runart-editorial-panel" style="padding:12px;border:1px solid #ddd;border-radius:6px;background:#fff;">
            <h2 style="margin-top:0;">🔧 Panel Técnico IA-Visual</h2>
            <p style="color:#666;margin-bottom:16px;">Gestión completa del sistema de contenidos enriquecidos</p>
            
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
        window.RUNART_MONITOR = {
            restUrl: '<?php echo esc_js($rest_url); ?>',
            nonce: '<?php echo esc_js($rest_nonce); ?>',
            mode: 'technical'
        };
        </script>
        <?php
    }
    
    /**
     * Enqueue assets del panel (JS + CSS externo).
     */
    private static function enqueue_assets() {
        wp_enqueue_script(
            'runart-ia-visual-panel',
            RUNART_IA_VISUAL_PLUGIN_URL . 'assets/js/panel-editor.js',
            [], // Sin dependencias (vanilla JS)
            RUNART_IA_VISUAL_VERSION,
            true
        );
        
        wp_enqueue_style(
            'runart-ia-visual-panel',
            RUNART_IA_VISUAL_PLUGIN_URL . 'assets/css/panel-editor.css',
            [],
            RUNART_IA_VISUAL_VERSION
        );
    }
}
