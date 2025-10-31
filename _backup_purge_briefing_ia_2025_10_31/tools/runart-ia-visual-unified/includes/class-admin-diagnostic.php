<?php
/**
 * @file class-admin-diagnostic.php
 * @description Página de diagnóstico (Herramientas → RunArt IA-Visual Status).
 * @source Informe de Consolidación, sección 3.2
 * 
 * Responsabilidad:
 * - Crear página de administración en menú Herramientas
 * - Mostrar diagnóstico del sistema IA-Visual:
 *   · Rutas data-bases y su existencia
 *   · Permisos de escritura en wp-content/uploads/runart-jobs/
 *   · Estado de queue (enriched-requests.json)
 *   · Últimos 10 trabajos procesados
 *   · Detección de Polylang (activo/inactivo)
 *   · Versión del plugin y endpoints disponibles
 * 
 * Inspiración: tools/runart-ai-visual-panel/includes/class-runart-ai-visual-admin.php
 */

if (!defined('ABSPATH')) {
    exit; // Exit if accessed directly
}

class RunArt_IA_Visual_Admin_Diagnostic {
    
    /**
     * Agrega página de diagnóstico al menú de administración.
     * Hook: admin_menu
     */
    public static function add_menu() {
        add_management_page(
            'RunArt IA-Visual Status',      // Page title
            'RunArt IA-Visual',              // Menu title
            'manage_options',                // Capability
            'runart-ia-visual-status',       // Menu slug
            [self::class, 'render_page']     // Callback
        );
    }
    
    /**
     * Renderiza la página de diagnóstico.
     */
    public static function render_page() {
        if (!current_user_can('manage_options')) {
            wp_die('Acceso denegado');
        }
        
        ?>
        <div class="wrap">
            <h1>RunArt IA-Visual: Diagnóstico del Sistema</h1>
            
            <h2>Información General</h2>
            <table class="widefat">
                <tr>
                    <td><strong>Versión del Plugin:</strong></td>
                    <td><?php echo esc_html(RUNART_IA_VISUAL_VERSION); ?></td>
                </tr>
                <tr>
                    <td><strong>PHP Version:</strong></td>
                    <td><?php echo esc_html(PHP_VERSION); ?></td>
                </tr>
                <tr>
                    <td><strong>WordPress Version:</strong></td>
                    <td><?php echo esc_html(get_bloginfo('version')); ?></td>
                </tr>
            </table>
            
            <h2>Rutas de Datos</h2>
            <?php self::render_data_paths(); ?>
            
            <h2>Permisos de Escritura</h2>
            <?php self::render_permissions(); ?>
            
            <h2>Estado de Queue</h2>
            <?php self::render_queue_status(); ?>
            
            <h2>Dependencias Opcionales</h2>
            <?php self::render_optional_dependencies(); ?>
            
            <h2>Endpoints REST Disponibles</h2>
            <?php self::render_endpoints(); ?>
        </div>
        <?php
    }
    
    /**
     * Renderiza diagnóstico de rutas de datos.
     */
    private static function render_data_paths() {
        $bases = RunArt_IA_Visual_Data_Layer::get_data_bases();
        
        echo '<table class="widefat">';
        echo '<thead><tr><th>Label</th><th>Path</th><th>¿Existe?</th><th>¿Escribible?</th></tr></thead>';
        echo '<tbody>';
        
        foreach ($bases as $label => $path) {
            $exists = is_dir($path);
            $writable = $exists && is_writable($path);
            
            echo '<tr>';
            echo '<td><strong>' . esc_html($label) . '</strong></td>';
            echo '<td><code>' . esc_html($path) . '</code></td>';
            echo '<td>' . ($exists ? '✅ Sí' : '❌ No') . '</td>';
            echo '<td>' . ($writable ? '✅ Sí' : '❌ No') . '</td>';
            echo '</tr>';
        }
        
        echo '</tbody></table>';
        
        // Test de locate
        echo '<h4 style="margin-top:20px;">Test de Locate</h4>';
        $test_locate = RunArt_IA_Visual_Data_Layer::locate_file('assistants/rewrite/index.json');
        echo '<p><strong>Buscando:</strong> assistants/rewrite/index.json</p>';
        echo '<p><strong>Encontrado:</strong> ' . ($test_locate['found'] ? '✅ Sí' : '❌ No') . '</p>';
        if ($test_locate['found']) {
            echo '<p><strong>Path:</strong> <code>' . esc_html($test_locate['path']) . '</code></p>';
            echo '<p><strong>Source:</strong> ' . esc_html($test_locate['source']) . '</p>';
        } else {
            echo '<p><strong>Rutas intentadas:</strong></p><ul>';
            foreach ($test_locate['paths_tried'] as $tried) {
                echo '<li><code>' . esc_html($tried) . '</code></li>';
            }
            echo '</ul>';
        }
    }
    
    /**
     * Renderiza diagnóstico de permisos de escritura.
     */
    private static function render_permissions() {
        echo '<h4>Directorios de Storage</h4>';
        
        $test_paths = [
            'assistants/rewrite/approvals.json',
            'enriched/index.json',
        ];
        
        echo '<table class="widefat">';
        echo '<thead><tr><th>Archivo</th><th>Path Preparado</th><th>Source</th><th>Estado</th></tr></thead>';
        echo '<tbody>';
        
        foreach ($test_paths as $rel_path) {
            $storage = RunArt_IA_Visual_Data_Layer::prepare_storage($rel_path);
            echo '<tr>';
            echo '<td><code>' . esc_html($rel_path) . '</code></td>';
            echo '<td>' . (!empty($storage['path']) ? '<code>' . esc_html($storage['path']) . '</code>' : '❌ No preparado') . '</td>';
            echo '<td>' . esc_html($storage['source']) . '</td>';
            echo '<td>' . (!empty($storage['path']) ? '✅ Listo' : '❌ No escribible') . '</td>';
            echo '</tr>';
        }
        
        echo '</tbody></table>';
        
        // Upload dir
        echo '<h4 style="margin-top:20px;">WordPress Uploads</h4>';
        $upload_dir = wp_upload_dir();
        $target_dir = $upload_dir['basedir'] . '/runart-jobs/';
        
        echo '<table class="widefat"><tr>';
        echo '<td><strong>Directorio:</strong></td>';
        echo '<td><code>' . esc_html($target_dir) . '</code></td>';
        echo '</tr><tr>';
        echo '<td><strong>¿Existe?</strong></td>';
        echo '<td>' . (is_dir($target_dir) ? '✅ Sí' : '❌ No') . '</td>';
        echo '</tr><tr>';
        echo '<td><strong>¿Escribible?</strong></td>';
        echo '<td>' . (is_writable($target_dir) ? '✅ Sí' : '❌ No') . '</td>';
        echo '</tr></table>';
    }
    
    /**
     * Renderiza estado de la cola de trabajos.
     */
    private static function render_queue_status() {
        $queue_loc = RunArt_IA_Visual_Data_Layer::locate_file('enriched/enriched-requests.json');
        
        if (!$queue_loc['found']) {
            echo '<p style="color:#999;">No se encontró archivo de cola. Sistema no inicializado o sin trabajos pendientes.</p>';
            echo '<p><strong>Rutas intentadas:</strong></p><ul>';
            foreach ($queue_loc['paths_tried'] as $tried) {
                echo '<li><code>' . esc_html($tried) . '</code></li>';
            }
            echo '</ul>';
            return;
        }
        
        $queue_content = RunArt_IA_Visual_Data_Layer::read_json($queue_loc['path']);
        
        if ($queue_content === false) {
            echo '<p style="color:#f59e0b;">⚠️ Archivo de cola encontrado pero no se pudo leer</p>';
            echo '<p><strong>Path:</strong> <code>' . esc_html($queue_loc['path']) . '</code></p>';
            return;
        }
        
        $requests = isset($queue_content['requests']) && is_array($queue_content['requests']) ? $queue_content['requests'] : [];
        
        echo '<p><strong>Path:</strong> <code>' . esc_html($queue_loc['path']) . '</code></p>';
        echo '<p><strong>Source:</strong> ' . esc_html($queue_loc['source']) . '</p>';
        echo '<p><strong>Trabajos en cola:</strong> ' . count($requests) . '</p>';
        
        if (count($requests) > 0) {
            echo '<h4>Últimos 10 trabajos:</h4>';
            echo '<table class="widefat">';
            echo '<thead><tr><th>ID</th><th>Page ID</th><th>Estado</th><th>Fecha</th></tr></thead>';
            echo '<tbody>';
            
            $recent = array_slice($requests, -10);
            foreach ($recent as $req) {
                echo '<tr>';
                echo '<td>' . esc_html($req['id'] ?? 'N/A') . '</td>';
                echo '<td>' . esc_html($req['page_id'] ?? 'N/A') . '</td>';
                echo '<td>' . esc_html($req['status'] ?? 'pending') . '</td>';
                echo '<td>' . esc_html($req['created_at'] ?? 'N/A') . '</td>';
                echo '</tr>';
            }
            
            echo '</tbody></table>';
        }
    }
    
    /**
     * Renderiza detección de dependencias opcionales.
     */
    private static function render_optional_dependencies() {
        echo '<table class="widefat">';
        echo '<tr><td><strong>Polylang:</strong></td>';
        echo '<td>' . (function_exists('pll_get_post_language') ? '✅ Activo' : '❌ Inactivo') . '</td></tr>';
        echo '</table>';
    }
    
    /**
     * Renderiza lista de endpoints REST.
     */
    private static function render_endpoints() {
        $base_url = rest_url('runart/v1');
        $endpoints = [
            'GET  /health',
            'GET  /bridge/data-bases',
            'POST /bridge/locate',
            'POST /bridge/prepare-storage',
            'GET  /enriched/list',
            'POST /enriched/approve',
            'POST /enriched/archive',
            'POST /enriched/restore',
            'POST /enriched/delete',
            'POST /enriched/rewrite',
            'POST /enriched/request',
            'POST /enriched/merge',
            'POST /enriched/hybrid',
            'GET  /wp-pages/all',
            'GET  /audit/pages',
            'GET  /audit/images',
            'POST /deployment/create-monitor-page',
        ];
        
        echo '<ul>';
        foreach ($endpoints as $endpoint) {
            $parts = explode(' ', $endpoint, 2);
            $url = $base_url . $parts[1];
            echo '<li><code>' . esc_html($endpoint) . '</code> → <a href="' . esc_url($url) . '" target="_blank">Test</a></li>';
        }
        echo '</ul>';
    }
}
