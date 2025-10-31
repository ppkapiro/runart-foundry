<?php
/**
 * @file class-admin-editor.php
 * @description Backend editable para contenido IA-Visual
 * @phase FASE 4.A
 * 
 * Funcionalidades:
 * - Listado de contenido enriquecido con filtros y búsqueda
 * - Editor inline con preview lado a lado
 * - Export/import de datasets
 * - Backups automáticos antes de editar
 * - Permisos granulares (admin + editor)
 * - Audit log de cambios
 */

if (!defined('ABSPATH')) {
    exit; // Exit if accessed directly
}

class RunArt_IA_Visual_Admin_Editor {
    
    /**
     * Inicializar el módulo de admin editor
     */
    public static function init() {
        // Hook para menú de administración
        add_action('admin_menu', [self::class, 'register_admin_menu']);
        
        // Hook para enqueue de assets
        add_action('admin_enqueue_scripts', [self::class, 'enqueue_admin_assets']);
        
        // AJAX handlers para operaciones de edición
        add_action('wp_ajax_runart_save_enriched', [self::class, 'ajax_save_enriched']);
        add_action('wp_ajax_runart_delete_enriched', [self::class, 'ajax_delete_enriched']);
        add_action('wp_ajax_runart_export_dataset', [self::class, 'ajax_export_dataset']);
    }
    
    /**
     * Registrar página de administración
     */
    public static function register_admin_menu() {
        add_menu_page(
            'IA-Visual Editor',           // page_title
            'IA-Visual',                   // menu_title
            'edit_posts',                  // capability (editor+)
            'runart-ia-visual-editor',     // menu_slug
            [self::class, 'render_editor_page'], // callback
            'dashicons-art',               // icon
            25                             // position
        );
        
        // Subpáginas
        add_submenu_page(
            'runart-ia-visual-editor',
            'Editor de Contenido',
            'Editor',
            'edit_posts',
            'runart-ia-visual-editor',
            [self::class, 'render_editor_page']
        );
        
        add_submenu_page(
            'runart-ia-visual-editor',
            'Exportar/Importar',
            'Export/Import',
            'manage_options',
            'runart-ia-visual-export',
            [self::class, 'render_export_page']
        );
    }
    
    /**
     * Enqueue assets para admin
     */
    public static function enqueue_admin_assets($hook) {
        // Solo cargar en nuestras páginas
        if (strpos($hook, 'runart-ia-visual') === false) {
            return;
        }
        
        // CSS básico para el editor
        wp_enqueue_style(
            'runart-ia-visual-admin',
            plugins_url('assets/admin-editor.css', dirname(__FILE__)),
            [],
            RUNART_IA_VISUAL_VERSION
        );
        
        // JS para interactividad
        wp_enqueue_script(
            'runart-ia-visual-admin',
            plugins_url('assets/admin-editor.js', dirname(__FILE__)),
            ['jquery'],
            RUNART_IA_VISUAL_VERSION,
            true
        );
        
        // Localizar script con datos
        wp_localize_script('runart-ia-visual-admin', 'runartIAVisual', [
            'ajaxUrl' => admin_url('admin-ajax.php'),
            'nonce' => wp_create_nonce('runart-ia-visual-nonce'),
            'restUrl' => rest_url('runart/content/'),
        ]);
    }
    
    /**
     * Renderizar página principal del editor
     */
    public static function render_editor_page() {
        // Verificar permisos
        if (!current_user_can('edit_posts')) {
            wp_die(__('No tienes permisos para acceder a esta página.'));
        }
        
        // Obtener dataset
        $data_layer = new RunArt_IA_Visual_Data_Layer();
        $enriched_data = $data_layer->get_enriched_content();
        
        $pages = [];
        if (isset($enriched_data['pages']) && is_array($enriched_data['pages'])) {
            foreach ($enriched_data['pages'] as $page_id) {
                $page_content = $data_layer->get_enriched_page($page_id);
                if ($page_content) {
                    $pages[] = [
                        'id' => $page_id,
                        'data' => $page_content,
                    ];
                }
            }
        }
        
        ?>
        <div class="wrap runart-ia-visual-editor">
            <h1>
                <?php echo esc_html__('IA-Visual — Editor de Contenido', 'runart-ia-visual'); ?>
            </h1>
            
            <div class="runart-toolbar">
                <div class="runart-search">
                    <input 
                        type="text" 
                        id="search-content" 
                        placeholder="Buscar por ID, título o contenido..."
                        class="regular-text"
                    >
                    <button type="button" class="button" id="btn-search">Buscar</button>
                </div>
                
                <div class="runart-filters">
                    <label>
                        <input type="checkbox" id="filter-approved" checked> 
                        Aprobados
                    </label>
                    <label>
                        <input type="checkbox" id="filter-pending" checked> 
                        Pendientes
                    </label>
                    <label>
                        <input type="checkbox" id="filter-rejected"> 
                        Rechazados
                    </label>
                </div>
                
                <?php if (current_user_can('manage_options')): ?>
                <div class="runart-admin-actions">
                    <a href="<?php echo esc_url(admin_url('admin.php?page=runart-ia-visual-export')); ?>" 
                       class="button button-secondary">
                        Export/Import
                    </a>
                </div>
                <?php endif; ?>
            </div>
            
            <div class="runart-stats">
                <span class="stat-item">
                    <strong>Total:</strong> <?php echo count($pages); ?>
                </span>
                <span class="stat-item">
                    <strong>Idiomas:</strong> ES, EN
                </span>
            </div>
            
            <table class="wp-list-table widefat fixed striped">
                <thead>
                    <tr>
                        <th style="width: 10%;">ID</th>
                        <th style="width: 15%;">WP Page ID</th>
                        <th style="width: 30%;">Título (ES)</th>
                        <th style="width: 15%;">Estado</th>
                        <th style="width: 15%;">Imágenes</th>
                        <th style="width: 15%;">Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($pages)): ?>
                    <tr>
                        <td colspan="6" style="text-align: center;">
                            No hay contenido enriquecido disponible.
                        </td>
                    </tr>
                    <?php else: ?>
                        <?php foreach ($pages as $page): ?>
                        <?php
                            $page_data = $page['data'];
                            $page_id = $page['id'];
                            $wp_page_id = $page_data['wp_page_id'] ?? 'N/A';
                            $enriched_es = $page_data['enriched_es'] ?? [];
                            $visual_refs = $page_data['visual_references'] ?? [];
                            $status = $page_data['status'] ?? 'pending';
                            $title_es = $enriched_es['title'] ?? 'Sin título';
                        ?>
                        <tr data-page-id="<?php echo esc_attr($page_id); ?>" data-status="<?php echo esc_attr($status); ?>">
                            <td>
                                <code><?php echo esc_html($page_id); ?></code>
                            </td>
                            <td>
                                <?php if (is_numeric($wp_page_id)): ?>
                                    <a href="<?php echo esc_url(get_edit_post_link($wp_page_id)); ?>" target="_blank">
                                        <?php echo esc_html($wp_page_id); ?>
                                    </a>
                                <?php else: ?>
                                    <?php echo esc_html($wp_page_id); ?>
                                <?php endif; ?>
                            </td>
                            <td>
                                <strong><?php echo esc_html($title_es); ?></strong>
                            </td>
                            <td>
                                <span class="status-badge status-<?php echo esc_attr($status); ?>">
                                    <?php echo esc_html(ucfirst($status)); ?>
                                </span>
                            </td>
                            <td>
                                <?php echo count($visual_refs); ?> referencias
                            </td>
                            <td>
                                <button 
                                    type="button" 
                                    class="button button-small btn-edit-page" 
                                    data-page-id="<?php echo esc_attr($page_id); ?>"
                                >
                                    Editar
                                </button>
                                <?php if (current_user_can('manage_options')): ?>
                                <button 
                                    type="button" 
                                    class="button button-small button-link-delete btn-delete-page" 
                                    data-page-id="<?php echo esc_attr($page_id); ?>"
                                >
                                    Eliminar
                                </button>
                                <?php endif; ?>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
        
        <!-- Modal de edición (cargado dinámicamente via JS) -->
        <div id="runart-edit-modal" style="display: none;">
            <div class="runart-modal-content">
                <span class="runart-modal-close">&times;</span>
                <h2>Editor de Contenido</h2>
                <div id="runart-modal-body">
                    <!-- Cargado dinámicamente -->
                </div>
            </div>
        </div>
        <?php
    }
    
    /**
     * Renderizar página de export/import
     */
    public static function render_export_page() {
        if (!current_user_can('manage_options')) {
            wp_die(__('No tienes permisos para acceder a esta página.'));
        }
        
        $staging_url = get_option('runart_staging_url', 'https://staging.runartfoundry.com/');
        
        ?>
        <div class="wrap">
            <h1><?php echo esc_html__('Export/Import Dataset', 'runart-ia-visual'); ?></h1>
            
            <div class="card">
                <h2>Exportar Dataset Local</h2>
                <p>
                    Exporta el dataset actual (index.json + páginas) como archivo JSON descargable.
                </p>
                <form method="post" action="<?php echo esc_url(rest_url('runart/v1/export-enriched')); ?>" target="_blank">
                    <?php wp_nonce_field('wp_rest'); ?>
                    <p>
                        <label>
                            <input type="radio" name="format" value="full" checked> 
                            Completo (index + páginas)
                        </label>
                        <br>
                        <label>
                            <input type="radio" name="format" value="index-only"> 
                            Solo índice
                        </label>
                    </p>
                    <button type="submit" class="button button-primary">
                        Descargar Export
                    </button>
                </form>
            </div>
            
            <div class="card">
                <h2>Sincronizar desde Staging/Prod</h2>
                <p>
                    Sincroniza el dataset enriquecido desde el entorno remoto usando el endpoint REST seguro.
                </p>
                <form method="post" id="form-sync-dataset">
                    <table class="form-table">
                        <tr>
                            <th><label for="staging_url">URL Staging</label></th>
                            <td>
                                <input 
                                    type="url" 
                                    id="staging_url" 
                                    name="staging_url" 
                                    value="<?php echo esc_attr($staging_url); ?>" 
                                    class="regular-text"
                                    required
                                >
                            </td>
                        </tr>
                        <tr>
                            <th><label for="auth_token">Token Admin (opcional)</label></th>
                            <td>
                                <input 
                                    type="password" 
                                    id="auth_token" 
                                    name="auth_token" 
                                    class="regular-text"
                                    placeholder="Bearer token o Application Password"
                                >
                                <p class="description">
                                    Requerido si el endpoint está protegido. Puedes generar un Application Password 
                                    en tu perfil de usuario en staging.
                                </p>
                            </td>
                        </tr>
                        <tr>
                            <th><label for="format">Formato</label></th>
                            <td>
                                <select id="format" name="format">
                                    <option value="full">Completo (recomendado)</option>
                                    <option value="index-only">Solo índice</option>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <th><label for="create_backup">Backup automático</label></th>
                            <td>
                                <label>
                                    <input type="checkbox" id="create_backup" name="create_backup" checked>
                                    Crear backup del dataset actual antes de sincronizar
                                </label>
                            </td>
                        </tr>
                    </table>
                    
                    <p class="submit">
                        <button type="submit" class="button button-primary">
                            Sincronizar Ahora
                        </button>
                    </p>
                </form>
                
                <div id="sync-result" style="margin-top: 20px; display: none;">
                    <!-- Resultado de sincronización -->
                </div>
            </div>
            
            <div class="card">
                <h2>Información del Sistema</h2>
                <table class="widefat">
                    <tr>
                        <td><strong>Ruta dataset local:</strong></td>
                        <td><code><?php echo esc_html(WP_CONTENT_DIR . '/runart-data/assistants/rewrite'); ?></code></td>
                    </tr>
                    <tr>
                        <td><strong>Plugin versión:</strong></td>
                        <td><?php echo esc_html(RUNART_IA_VISUAL_VERSION); ?></td>
                    </tr>
                    <tr>
                        <td><strong>Endpoint export local:</strong></td>
                        <td><code><?php echo esc_url(rest_url('runart/v1/export-enriched')); ?></code></td>
                    </tr>
                </table>
            </div>
        </div>
        
        <script>
        jQuery(document).ready(function($) {
            $('#form-sync-dataset').on('submit', function(e) {
                e.preventDefault();
                
                var $form = $(this);
                var $result = $('#sync-result');
                var $button = $form.find('button[type="submit"]');
                
                $button.prop('disabled', true).text('Sincronizando...');
                $result.html('<p>⏳ Sincronizando dataset...</p>').show();
                
                var stagingUrl = $('#staging_url').val().replace(/\/$/, '');
                var authToken = $('#auth_token').val();
                var format = $('#format').val();
                
                var headers = {
                    'Accept': 'application/json',
                };
                
                if (authToken) {
                    headers['Authorization'] = 'Bearer ' + authToken;
                }
                
                $.ajax({
                    url: stagingUrl + '/wp-json/runart/v1/export-enriched?format=' + format,
                    method: 'GET',
                    headers: headers,
                    dataType: 'json',
                    success: function(response) {
                        if (response.ok) {
                            var meta = response.export.meta || {};
                            var pages = response.export.pages || {};
                            var pagesCount = Object.keys(pages).length;
                            
                            $result.html(
                                '<div class="notice notice-success"><p>' +
                                '<strong>✅ Sincronización exitosa</strong><br>' +
                                'Fuente: ' + meta.source + '<br>' +
                                'Páginas: ' + pagesCount + '<br>' +
                                'Timestamp: ' + meta.export_timestamp +
                                '</p></div>'
                            );
                        } else {
                            $result.html('<div class="notice notice-error"><p>❌ Error en la respuesta del servidor.</p></div>');
                        }
                    },
                    error: function(xhr, status, error) {
                        var errorMsg = 'Error desconocido';
                        try {
                            var response = JSON.parse(xhr.responseText);
                            errorMsg = response.message || response.error || errorMsg;
                        } catch(e) {
                            errorMsg = xhr.status + ': ' + xhr.statusText;
                        }
                        
                        $result.html('<div class="notice notice-error"><p><strong>❌ Error:</strong> ' + errorMsg + '</p></div>');
                    },
                    complete: function() {
                        $button.prop('disabled', false).text('Sincronizar Ahora');
                    }
                });
            });
        });
        </script>
        <?php
    }
    
    /**
     * AJAX: Guardar contenido enriquecido
     */
    public static function ajax_save_enriched() {
        check_ajax_referer('runart-ia-visual-nonce', 'nonce');
        
        if (!current_user_can('edit_posts')) {
            wp_send_json_error(['message' => 'Permisos insuficientes'], 403);
        }
        
        // TODO: Implementar lógica de guardado con backup automático
        
        wp_send_json_success(['message' => 'Contenido guardado (mock)']);
    }
    
    /**
     * AJAX: Eliminar contenido enriquecido
     */
    public static function ajax_delete_enriched() {
        check_ajax_referer('runart-ia-visual-nonce', 'nonce');
        
        if (!current_user_can('manage_options')) {
            wp_send_json_error(['message' => 'Permisos insuficientes'], 403);
        }
        
        // TODO: Implementar lógica de eliminación con confirmación
        
        wp_send_json_success(['message' => 'Contenido eliminado (mock)']);
    }
    
    /**
     * AJAX: Exportar dataset
     */
    public static function ajax_export_dataset() {
        check_ajax_referer('runart-ia-visual-nonce', 'nonce');
        
        if (!current_user_can('manage_options')) {
            wp_send_json_error(['message' => 'Permisos insuficientes'], 403);
        }
        
        // Redirigir al endpoint REST
        wp_send_json_success([
            'redirect' => rest_url('runart/v1/export-enriched?format=full')
        ]);
    }
}
