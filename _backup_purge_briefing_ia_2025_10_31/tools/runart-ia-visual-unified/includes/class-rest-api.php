<?php
/**
 * @file class-rest-api.php
 * @description Registro de endpoints REST (17 totales) del sistema IA-Visual.
 * @source Informe de Consolidación, sección 3.1 y 2.1
 * 
 * Responsabilidad:
 * - Registrar 17 endpoints REST bajo namespace /runart/v1
 * - Delegar permisos a RunArt_IA_Visual_Permissions
 * - Delegar lógica de datos a RunArt_IA_Visual_Data_Layer
 * 
 * Endpoints a implementar:
 * 1. GET  /health - Diagnóstico
 * 2. GET  /bridge/data-bases - Paths de datos
 * 3. POST /bridge/locate - Resolución de archivos
 * 4. POST /bridge/prepare-storage - Inicialización de storage
 * 5. GET  /enriched/list - Lista de contenido enriquecido
 * 6. POST /enriched/approve - Aprobar contenido
 * 7. POST /enriched/archive - Archivar contenido
 * 8. POST /enriched/restore - Restaurar contenido
 * 9. POST /enriched/delete - Eliminar contenido
 * 10. POST /enriched/rewrite - Obtener reescritura
 * 11. POST /enriched/request - Solicitar enriquecimiento (queue)
 * 12. POST /enriched/merge - Fusionar contenido
 * 13. POST /enriched/hybrid - Contenido híbrido
 * 14. GET  /wp-pages/all - Listar páginas WP
 * 15. GET  /audit/pages - Auditoría de páginas
 * 16. GET  /audit/images - Auditoría de imágenes
 * 17. POST /deployment/create-monitor-page - Crear página de monitor
 */

if (!defined('ABSPATH')) {
    exit; // Exit if accessed directly
}

class RunArt_IA_Visual_REST_API {
    
    /**
     * Namespace de la API REST.
     */
    const NAMESPACE = 'runart';
    
    /**
     * Registra todas las rutas REST del plugin.
     * Hook: rest_api_init
     */
    public static function register_routes() {
        $ns = self::NAMESPACE;
        
        // 1. Health endpoint (GET)
        register_rest_route($ns, '/bridge/health', [
            'methods'  => 'GET',
            'callback' => [self::class, 'endpoint_health'],
            'permission_callback' => [RunArt_IA_Visual_Permissions::class, 'check_admin'],
        ]);
        
        // 2. Data bases endpoint (GET)
        register_rest_route($ns, '/bridge/data-bases', [
            'methods'  => 'GET',
            'callback' => [self::class, 'endpoint_data_bases'],
            'permission_callback' => [RunArt_IA_Visual_Permissions::class, 'check_admin'],
        ]);
        
        // 3. Locate file endpoint (POST)
        register_rest_route($ns, '/bridge/locate', [
            'methods'  => 'POST',
            'callback' => [self::class, 'endpoint_locate'],
            'permission_callback' => [RunArt_IA_Visual_Permissions::class, 'check_admin'],
        ]);
        
        // 4. Prepare storage endpoint (POST)
        register_rest_route($ns, '/bridge/prepare-storage', [
            'methods'  => 'POST',
            'callback' => [self::class, 'endpoint_prepare_storage'],
            'permission_callback' => [RunArt_IA_Visual_Permissions::class, 'check_admin'],
        ]);
        
        // 5. Content Audit - Pages endpoint (GET)
        register_rest_route($ns, '/audit/pages', [
            'methods'  => 'GET',
            'callback' => [self::class, 'endpoint_audit_pages'],
            'permission_callback' => [RunArt_IA_Visual_Permissions::class, 'check_admin'],
        ]);
        
        // 6. Content Audit - Images endpoint (GET)
        register_rest_route($ns, '/audit/images', [
            'methods'  => 'GET',
            'callback' => [self::class, 'endpoint_audit_images'],
            'permission_callback' => [RunArt_IA_Visual_Permissions::class, 'check_admin'],
        ]);
        
        // 7. Deployment - Create monitor page (POST)
        register_rest_route($ns, '/deployment/create-monitor-page', [
            'methods'  => 'POST',
            'callback' => [self::class, 'endpoint_create_monitor_page'],
            'permission_callback' => [RunArt_IA_Visual_Permissions::class, 'check_admin'],
            'args' => [
                'title' => [
                    'required' => false,
                    'type' => 'string',
                    'description' => 'Título de la página a crear/actualizar',
                ],
                'slug' => [
                    'required' => false,
                    'type' => 'string',
                    'description' => 'Slug deseado para la página',
                ],
                'mode' => [
                    'required' => false,
                    'type' => 'string',
                    'enum' => ['technical', 'editor'],
                    'description' => 'Modo del shortcode: technical (por defecto) o editor',
                ],
            ],
        ]);
        
        // 8. F10-i - Listado rápido de contenidos IA (GET)
        register_rest_route($ns, '/content/enriched-list', [
            'methods'  => 'GET',
            'callback' => [self::class, 'endpoint_enriched_list'],
            'permission_callback' => [RunArt_IA_Visual_Permissions::class, 'check_editor'],
        ]);
        
        // 9. F10-i - Listado paginado de páginas WP (GET)
        register_rest_route($ns, '/content/wp-pages', [
            'methods'  => 'GET',
            'callback' => [self::class, 'endpoint_wp_pages'],
            'permission_callback' => [RunArt_IA_Visual_Permissions::class, 'check_editor'],
            'args' => [
                'page' => [
                    'required' => false,
                    'type' => 'integer',
                    'minimum' => 1,
                    'description' => 'Número de página (default: 1)'
                ],
                'per_page' => [
                    'required' => false,
                    'type' => 'integer',
                    'minimum' => 1,
                    'maximum' => 50,
                    'description' => 'Elementos por página (default: 25, máximo: 50)'
                ],
            ],
        ]);
        
        // 10. F10-b - Aprobar/Rechazar contenido (POST)
        register_rest_route($ns, '/content/enriched-approve', [
            'methods'  => 'POST',
            'callback' => [self::class, 'endpoint_enriched_approve'],
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
        
        // 11. F10-i - Fusión opcional IA + WP (POST)
        register_rest_route($ns, '/content/enriched-merge', [
            'methods'  => 'POST',
            'callback' => [self::class, 'endpoint_enriched_merge'],
            'permission_callback' => [RunArt_IA_Visual_Permissions::class, 'check_editor'],
        ]);
        
        // 12. F10-h - Listado híbrido WP+IA (GET)
        register_rest_route($ns, '/content/enriched-hybrid', [
            'methods'  => 'GET',
            'callback' => [self::class, 'endpoint_enriched_hybrid'],
            'permission_callback' => function () { return is_user_logged_in(); },
        ]);
        
        // 13. F10-h - Solicitar generación de contenido IA para una página (POST)
        register_rest_route($ns, '/content/enriched-request', [
            'methods'  => 'POST',
            'callback' => [self::class, 'endpoint_enriched_request'],
            'permission_callback' => [RunArt_IA_Visual_Permissions::class, 'check_editor'],
        ]);
        
        // 14. F10 - Endpoint para registrar solicitud de regeneración (POST)
        register_rest_route($ns, '/ai-visual/request-regeneration', [
            'methods'  => 'POST',
            'callback' => [self::class, 'endpoint_request_regeneration'],
            'permission_callback' => function () { return is_user_logged_in(); },
        ]);
        
        // 15. F9 - Get enriched content (GET)
        register_rest_route($ns, '/content/enriched', [
            'methods'  => 'GET',
            'callback' => [self::class, 'endpoint_enriched_content'],
            'permission_callback' => function () { return is_user_logged_in(); },
            'args' => [
                'page_id' => [
                    'required' => true,
                    'type' => 'string',
                    'description' => 'ID de la página enriquecida (ej: page_42)',
                ],
            ],
        ]);
        
        // 16. F10 - Master pipeline endpoint (GET/POST)
        register_rest_route($ns, '/ai-visual/pipeline', [
            'methods'  => ['GET', 'POST'],
            'callback' => [self::class, 'endpoint_pipeline'],
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
                    'description' => 'Acción a ejecutar',
                ],
            ],
        ]);
        
        // 17. IA-Visual Correlation - Suggest Images endpoint (GET)
        register_rest_route($ns, '/correlations/suggest-images', [
            'methods'  => 'GET',
            'callback' => [self::class, 'endpoint_suggest_images'],
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
                ],
                'threshold' => [
                    'required' => false,
                    'type' => 'number',
                    'default' => 0.70,
                ],
            ],
        ]);

        // FASE 3.D — Endpoints de verificación remota (sin SFTP)
        // A. Data Scan (GET): intenta leer múltiples rutas candidatas y reporta existencia, tamaño y conteos.
        register_rest_route($ns, '/v1/data-scan', [
            'methods'  => 'GET',
            'callback' => [self::class, 'endpoint_data_scan'],
            // Diagnóstico de solo lectura: permitir acceso público para facilitar verificación externa
            'permission_callback' => '__return_true',
        ]);

        // B. Ping Staging (GET): eco remoto mínimo para verificar alcance y plugin activo
        register_rest_route($ns, '/v1/ping-staging', [
            'methods'  => 'GET',
            'callback' => [self::class, 'endpoint_ping_staging'],
            'permission_callback' => '__return_true',
        ]);

        // FASE 4.A — Endpoints de export seguro (admin-only)
        // C. Export Enriched (GET): exportar dataset completo enriquecido en JSON
        register_rest_route($ns, '/v1/export-enriched', [
            'methods'  => 'GET',
            'callback' => [self::class, 'endpoint_export_enriched'],
            'permission_callback' => [RunArt_IA_Visual_Permissions::class, 'check_admin'],
            'args' => [
                'format' => [
                    'required' => false,
                    'type' => 'string',
                    'enum' => ['full', 'index-only'],
                    'default' => 'full',
                    'description' => 'full: incluye todas las páginas individuales. index-only: solo el index.json',
                ],
            ],
        ]);

        // D. Media Index (GET): exportar índice completo de medios
        register_rest_route($ns, '/v1/media-index', [
            'methods'  => 'GET',
            'callback' => [self::class, 'endpoint_media_index'],
            'permission_callback' => [RunArt_IA_Visual_Permissions::class, 'check_admin'],
            'args' => [
                'include_meta' => [
                    'required' => false,
                    'type' => 'boolean',
                    'default' => true,
                    'description' => 'Incluir metadatos completos de cada imagen',
                ],
            ],
        ]);
    }
    
    /**
     * Endpoint: GET /bridge/health
     */
    public static function endpoint_health($request) {
        return new WP_REST_Response([
            'ok' => true,
            'plugin' => 'RunArt IA-Visual Unified',
            'version' => RUNART_IA_VISUAL_VERSION,
            'php_version' => PHP_VERSION,
            'wp_version' => get_bloginfo('version'),
        ], 200);
    }
    
    /**
     * Endpoint: GET /bridge/data-bases
     */
    public static function endpoint_data_bases($request) {
        return new WP_REST_Response([
            'ok' => true,
            'bases' => RunArt_IA_Visual_Data_Layer::get_data_bases(),
        ], 200);
    }
    
    /**
     * Endpoint: POST /bridge/locate
     */
    public static function endpoint_locate($request) {
        $relative = $request->get_param('relative');
        $type = $request->get_param('type') ?: 'file';
        
        if (empty($relative)) {
            return new WP_Error('missing_param', 'Parameter "relative" is required', ['status' => 400]);
        }
        
        $result = RunArt_IA_Visual_Data_Layer::locate_file($relative, $type);
        return new WP_REST_Response(['ok' => true, 'result' => $result], 200);
    }
    
    /**
     * Endpoint: POST /bridge/prepare-storage
     */
    public static function endpoint_prepare_storage($request) {
        $relative = $request->get_param('relative');
        
        if (empty($relative)) {
            return new WP_Error('missing_param', 'Parameter "relative" is required', ['status' => 400]);
        }
        
        $result = RunArt_IA_Visual_Data_Layer::prepare_storage($relative);
        return new WP_REST_Response(['ok' => true, 'result' => $result], 200);
    }
    
    /**
     * Endpoint: GET /audit/pages
     */
    public static function endpoint_audit_pages($request) {
        // Implementación simplificada - delegar a función legacy si existe
        if (function_exists('runart_audit_pages')) {
            return runart_audit_pages($request);
        }
        return new WP_REST_Response(['ok' => true, 'pages' => []], 200);
    }
    
    /**
     * Endpoint: GET /audit/images
     */
    public static function endpoint_audit_images($request) {
        // Implementación simplificada - delegar a función legacy si existe
        if (function_exists('runart_audit_images')) {
            return runart_audit_images($request);
        }
        return new WP_REST_Response(['ok' => true, 'images' => []], 200);
    }
    
    /**
     * Endpoint: POST /deployment/create-monitor-page
     */
    public static function endpoint_create_monitor_page($request) {
        // Delegar a función de init_monitor_page.php
        if (function_exists('runart_deployment_create_monitor_page')) {
            return runart_deployment_create_monitor_page($request);
        }
        return new WP_Error('not_available', 'Monitor page creation not available', ['status' => 500]);
    }
    
    /**
     * Endpoint: GET /content/enriched-list
     * Lista contenido enriquecido disponible.
     */
    public static function endpoint_enriched_list($request) {
        $start = microtime(true);
        $paths_tried = [];
        $found_path = null;
        $found_label = 'none';

        $candidates = [];
        if (defined('WP_CONTENT_DIR')) {
            $candidates[] = [
                'label' => 'wp-content',
                'path' => trailingslashit(WP_CONTENT_DIR) . 'runart-data/assistants/rewrite/index.json',
            ];
            $candidates[] = [
                'label' => 'uploads',
                'path' => trailingslashit(WP_CONTENT_DIR) . 'uploads/runart-data/assistants/rewrite/index.json',
            ];
        }
        $candidates[] = [
            'label' => 'plugin',
            'path' => trailingslashit(RUNART_IA_VISUAL_PLUGIN_DIR) . 'data/assistants/rewrite/index.json',
        ];

        foreach ($candidates as $candidate) {
            $paths_tried[] = $candidate['path'];
            if (file_exists($candidate['path'])) {
                $found_path = $candidate['path'];
                $found_label = $candidate['label'];
                break;
            }
        }

        if (!$found_path) {
            $duration = (int) round((microtime(true) - $start) * 1000);
            return new WP_REST_Response([
                'ok' => true,
                'source' => 'none',
                'items' => [],
                'meta' => [
                    'timestamp' => gmdate('c'),
                    'duration_ms' => $duration,
                    'paths_tried' => $paths_tried,
                ],
            ], 200);
        }

        $index_content = @file_get_contents($found_path);
        if ($index_content === false) {
            return new WP_Error('read_error', 'Unable to read IA index file', ['status' => 500]);
        }

        $index_data = json_decode($index_content, true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            return new WP_Error('json_decode_error', 'Invalid IA index JSON: ' . json_last_error_msg(), ['status' => 500]);
        }

        $items = [];
        if (isset($index_data['pages']) && is_array($index_data['pages'])) {
            foreach ($index_data['pages'] as $page) {
                $page_id = isset($page['page_id']) ? $page['page_id'] : (isset($page['id']) ? $page['id'] : '');
                if (empty($page_id)) {
                    continue;
                }

                $title = isset($page['title']) ? (string) $page['title'] : $page_id;
                $lang = isset($page['lang']) ? (string) $page['lang'] : 'es';

                $item = [
                    'id' => $page_id,
                    'title' => $title,
                    'lang' => $lang,
                    'status' => isset($page['status']) ? (string) $page['status'] : 'generated',
                    'source' => 'ia',
                    'payload' => $page,
                ];

                if (isset($page['wp_id'])) {
                    $item['wp_id'] = (int) $page['wp_id'];
                }

                $items[] = $item;
            }
        }

        $duration = (int) round((microtime(true) - $start) * 1000);

        return new WP_REST_Response([
            'ok' => true,
            'source' => $found_path,
            'source_label' => $found_label,
            'items' => $items,
            'count' => count($items),
            'meta' => [
                'timestamp' => gmdate('c'),
                'duration_ms' => $duration,
                'paths_tried' => $paths_tried,
            ],
        ], 200);
    }
    
    /**
     * Endpoint: GET /content/wp-pages
     */
    public static function endpoint_wp_pages($request) {
        // Delegar a función legacy si existe
        if (function_exists('runart_content_wp_pages')) {
            return runart_content_wp_pages($request);
        }
        
        // Implementación básica
        $page = $request->get_param('page') ?: 1;
        $per_page = $request->get_param('per_page') ?: 25;
        $per_page = min(max(1, $per_page), 50);
        
        $args = [
            'post_type' => 'page',
            'post_status' => 'publish',
            'posts_per_page' => $per_page,
            'paged' => $page,
            'orderby' => 'title',
            'order' => 'ASC',
        ];
        
        $query = new WP_Query($args);
        $items = [];
        
        if ($query->have_posts()) {
            while ($query->have_posts()) {
                $query->the_post();
                $items[] = [
                    'id' => get_the_ID(),
                    'title' => get_the_title(),
                    'slug' => get_post_field('post_name'),
                ];
            }
            wp_reset_postdata();
        }
        
        return new WP_REST_Response([
            'ok' => true,
            'items' => $items,
            'total' => $query->found_posts,
            'page' => $page,
            'per_page' => $per_page,
        ], 200);
    }
    
    /**
     * Endpoint: POST /content/enriched-approve
     */
    public static function endpoint_enriched_approve($request) {
        $id = $request->get_param('id');
        $status = $request->get_param('status');
        
        if (empty($id) || empty($status)) {
            return new WP_Error('missing_params', 'id and status parameters are required', ['status' => 400]);
        }
        
        $current_user = wp_get_current_user();
        $user_login = $current_user && $current_user->user_login ? $current_user->user_login : 'unknown';
        
        $approval_entry = [
            'status' => $status,
            'updated_at' => gmdate('c'),
            'updated_by' => $user_login,
        ];
        
        // Ubicar aprobaciones existentes
        $approvals = [];
        $approvals_loc = RunArt_IA_Visual_Data_Layer::locate_file('assistants/rewrite/approvals.json');
        if ($approvals_loc['found']) {
            $approvals_content = file_get_contents($approvals_loc['path']);
            if ($approvals_content !== false) {
                $approvals_data = json_decode($approvals_content, true);
                if (json_last_error() === JSON_ERROR_NONE) {
                    $approvals = $approvals_data;
                }
            }
        }
        
        // Actualizar aprobación
        $approvals[$id] = $approval_entry;
        
        // Preparar destino escribible
        $storage = RunArt_IA_Visual_Data_Layer::prepare_storage('assistants/rewrite/approvals.json');
        if (!empty($storage['path'])) {
            $ok = @file_put_contents(
                $storage['path'],
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
                        'storage' => $storage['source'],
                    ],
                ], 200);
            }
        }
        
        // Fallback: uploads/
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
            ], 200);
        }
        
        return new WP_Error('write_error', 'No se pudo registrar la aprobación', ['status' => 500]);
    }
    
    /**
     * Endpoint: POST /content/enriched-merge
     */
    public static function endpoint_enriched_merge($request) {
        // Delegar a función legacy si existe
        if (function_exists('runart_content_enriched_merge')) {
            return runart_content_enriched_merge($request);
        }
        return new WP_REST_Response(['ok' => true, 'message' => 'Merge endpoint - to be implemented'], 200);
    }
    
    /**
     * Endpoint: GET /content/enriched-hybrid
     */
    public static function endpoint_enriched_hybrid($request) {
        // Delegar a función legacy si existe
        if (function_exists('runart_content_enriched_hybrid')) {
            return runart_content_enriched_hybrid($request);
        }
        return new WP_REST_Response(['ok' => true, 'items' => []], 200);
    }
    
    /**
     * Endpoint: POST /content/enriched-request
     */
    public static function endpoint_enriched_request($request) {
        // Delegar a función legacy si existe
        if (function_exists('runart_content_enriched_request')) {
            return runart_content_enriched_request($request);
        }
        return new WP_REST_Response(['ok' => true, 'message' => 'Request queued'], 200);
    }
    
    /**
     * Endpoint: POST /ai-visual/request-regeneration
     */
    public static function endpoint_request_regeneration($request) {
        if (function_exists('runart_ai_visual_request_regeneration')) {
            return runart_ai_visual_request_regeneration($request);
        }
        return new WP_REST_Response(['ok' => true, 'message' => 'Regeneration requested'], 200);
    }
    
    /**
     * Endpoint: GET /content/enriched
     */
    public static function endpoint_enriched_content($request) {
        if (function_exists('runart_content_enriched')) {
            return runart_content_enriched($request);
        }
        return new WP_REST_Response(['ok' => true, 'content' => null], 200);
    }
    
    /**
     * Endpoint: GET/POST /ai-visual/pipeline
     */
    public static function endpoint_pipeline($request) {
        if (function_exists('runart_ai_visual_pipeline')) {
            return runart_ai_visual_pipeline($request);
        }
        return new WP_REST_Response(['ok' => true, 'status' => 'pipeline endpoint'], 200);
    }
    
    /**
     * Endpoint: GET /correlations/suggest-images
     */
    public static function endpoint_suggest_images($request) {
        if (function_exists('runart_correlations_suggest_images')) {
            return runart_correlations_suggest_images($request);
        }
        return new WP_REST_Response(['ok' => true, 'suggestions' => []], 200);
    }

    /**
     * Endpoint: GET /v1/ping-staging
     * Respuesta mínima para comprobar que el plugin está activo y el entorno es alcanzable.
     */
    public static function endpoint_ping_staging($request) {
        $theme = function_exists('wp_get_theme') ? wp_get_theme() : null;
        $theme_name = $theme ? $theme->get('Name') : null;
        $theme_version = $theme ? $theme->get('Version') : null;

        return new WP_REST_Response([
            'ok' => true,
            'status' => 'ok',
            'site_url' => function_exists('get_site_url') ? get_site_url() : null,
            'theme' => [
                'name' => $theme_name,
                'version' => $theme_version,
            ],
            'runart_plugin' => [
                'name' => 'RunArt IA-Visual Unified',
                'version' => defined('RUNART_IA_VISUAL_VERSION') ? RUNART_IA_VISUAL_VERSION : null,
            ],
            'auth' => [
                'is_logged_in' => is_user_logged_in(),
                // Nota: si el entorno requiere autenticación (nonce/cabecera), la respuesta seguirá sirviendo de eco.
                'hint' => 'Si este endpoint estuviera detrás de autenticación, use X-WP-Nonce (usuarios WP) o Authorization: Bearer <token> según configuración.',
            ],
            'timestamp' => gmdate('c'),
        ], 200);
    }

    /**
     * Endpoint: GET /v1/data-scan
     * Intenta localizar y evaluar múltiples rutas candidatas para el índice IA (dataset pequeño y “grande”).
     * No lee archivos completos: sólo existencia, tamaño y conteo de items si se puede parsear JSON.
     */
    public static function endpoint_data_scan($request) {
        $attempts = [];

        // Construir rutas candidatas
        $uploads = function_exists('wp_upload_dir') ? wp_upload_dir() : null;
        $base_uploads = ($uploads && !empty($uploads['basedir'])) ? $uploads['basedir'] : (defined('WP_CONTENT_DIR') ? trailingslashit(WP_CONTENT_DIR) . 'uploads' : ABSPATH . 'wp-content/uploads');

        $candidates = [];
        if (defined('WP_CONTENT_DIR')) {
            $candidates[] = [
                'label' => 'wp-content',
                'path'  => trailingslashit(WP_CONTENT_DIR) . 'runart-data/assistants/rewrite/index.json',
            ];
            $candidates[] = [
                'label' => 'uploads-runart-data',
                'path'  => trailingslashit(WP_CONTENT_DIR) . 'uploads/runart-data/assistants/rewrite/index.json',
            ];
        }
        $candidates[] = [
            'label' => 'plugin',
            'path'  => trailingslashit(RUNART_IA_VISUAL_PLUGIN_DIR) . 'data/assistants/rewrite/index.json',
        ];
        $candidates[] = [
            'label' => 'uploads-enriched',
            'path'  => trailingslashit($base_uploads) . 'runart-jobs/enriched/index.json',
        ];
        $candidates[] = [
            'label' => 'content-enriched',
            'path'  => trailingslashit(ABSPATH) . 'content/enriched/index.json',
        ];

        // mirror/latest si existiera en el host (poco probable en staging), útil para entornos con espejo local
        $mirror_root = trailingslashit(ABSPATH) . 'mirror/raw/';
        if (is_dir($mirror_root)) {
            $dirs = glob($mirror_root . '*', GLOB_ONLYDIR);
            if (is_array($dirs) && !empty($dirs)) {
                rsort($dirs); // más reciente primero
                $latest = trailingslashit($dirs[0]);
                $candidates[] = [
                    'label' => 'mirror-latest-enriched',
                    'path'  => $latest . 'wp-content/uploads/runart-jobs/enriched/index.json',
                ];
            }
        }

        $small_count_total = 0;
        $small_sources_found = 0;
        $uploads_enriched_found = false;
        $uploads_enriched_count = null;

        foreach ($candidates as $cand) {
            $path = $cand['path'];
            $exists = @file_exists($path);
            $size = null;
            $item_count = null;
            $json_ok = false;
            $error = null;

            if ($exists) {
                // Tamaño (si el host lo permite)
                $size = @filesize($path);

                // Intento de lectura mínima para contar items
                $raw = @file_get_contents($path);
                if ($raw === false) {
                    $error = 'read_error';
                } else {
                    $data = json_decode($raw, true);
                    if (json_last_error() === JSON_ERROR_NONE) {
                        $json_ok = true;
                        if (isset($data['pages']) && is_array($data['pages'])) {
                            $item_count = count($data['pages']);
                        } elseif (is_array($data) && array_keys($data) === range(0, count($data) - 1)) {
                            // array indexado
                            $item_count = count($data);
                        } elseif (isset($data['items']) && is_array($data['items'])) {
                            $item_count = count($data['items']);
                        } else {
                            $item_count = null; // formato desconocido
                        }
                    } else {
                        $error = 'json_decode_error: ' . json_last_error_msg();
                    }
                }
            }

            // Acumulados para decisión automática
            if (in_array($cand['label'], ['wp-content', 'uploads-runart-data', 'plugin'], true)) {
                if ($exists) {
                    $small_sources_found++;
                    if (is_int($item_count)) {
                        $small_count_total += (int) $item_count;
                    }
                }
            }
            if ($cand['label'] === 'uploads-enriched') {
                $uploads_enriched_found = $exists ? true : false;
                if (is_int($item_count)) {
                    $uploads_enriched_count = (int) $item_count;
                }
            }

            $attempts[] = [
                'label' => $cand['label'],
                'path' => $path,
                'exists' => (bool) $exists,
                'size_bytes' => is_int($size) ? $size : null,
                'json_ok' => (bool) $json_ok,
                'item_count' => is_int($item_count) ? $item_count : null,
                'error' => $error,
            ];
        }

        // Decisión automática
        $dataset_status = 'UNKNOWN';
        if ($uploads_enriched_found && is_int($uploads_enriched_count) && $uploads_enriched_count > 3) {
            $dataset_status = 'FOUND_IN_STAGING';
        } elseif (!$uploads_enriched_found && $small_sources_found > 0 && $small_count_total === 3) {
            $dataset_status = 'NOT_FOUND_IN_STAGING';
        }

        // TODO(fase 3.E): Si dataset_status === 'FOUND_IN_STAGING', ampliar la cascada en endpoint_enriched_list
        // para incluir 'uploads-enriched' (wp-content/uploads/runart-jobs/enriched/index.json) como 4ª opción
        // de sólo lectura, con normalización de formato si fuera necesario.

        return new WP_REST_Response([
            'ok' => true,
            'scan' => $attempts,
            'summary' => [
                'dataset_real_status' => $dataset_status,
                'small_sources_found' => $small_sources_found,
                'small_total_items' => $small_count_total,
                'uploads_enriched_found' => $uploads_enriched_found,
                'uploads_enriched_items' => $uploads_enriched_count,
                'auth_note' => 'Si el entorno requiere autenticación, usar X-WP-Nonce (usuarios WP) o Authorization: Bearer <token>.',
                'timestamp' => gmdate('c'),
            ],
        ], 200);
    }

    /**
     * Endpoint: GET /v1/export-enriched
     * Export del dataset enriquecido completo (admin-only)
     * 
     * @param WP_REST_Request $request
     * @return WP_REST_Response
     */
    public static function endpoint_export_enriched($request) {
        $format = $request->get_param('format') ?: 'full';

        // Candidatos en orden de prioridad: 1) uploads-enriched, 2) wp-content/runart-data, 3) uploads/runart-data, 4) plugin fallback
        $candidates = [
            [
                'label' => 'uploads-enriched',
                'base_path' => WP_CONTENT_DIR . '/uploads/runart-jobs/enriched',
                'index' => 'index.json',
            ],
            [
                'label' => 'wp-content',
                'base_path' => WP_CONTENT_DIR . '/runart-data/assistants/rewrite',
                'index' => 'index.json',
            ],
            [
                'label' => 'uploads-runart-data',
                'base_path' => WP_CONTENT_DIR . '/uploads/runart-data/assistants/rewrite',
                'index' => 'index.json',
            ],
            [
                'label' => 'plugin',
                'base_path' => plugin_dir_path(dirname(__FILE__)) . 'data/assistants/rewrite',
                'index' => 'index.json',
            ],
        ];

        $source_found = null;
        $index_data = null;
        $full_dataset = [];

        // Buscar primer candidato con index.json válido
        foreach ($candidates as $cand) {
            $index_path = $cand['base_path'] . '/' . $cand['index'];
            if (@file_exists($index_path)) {
                $raw = @file_get_contents($index_path);
                if ($raw !== false) {
                    $data = json_decode($raw, true);
                    if (json_last_error() === JSON_ERROR_NONE) {
                        $source_found = $cand;
                        $index_data = $data;
                        break;
                    }
                }
            }
        }

        if (!$source_found) {
            return new WP_Error('export_no_source', 'No se encontró un dataset enriquecido válido en ninguna ruta candidata.', ['status' => 404]);
        }

        // Construir export completo o solo index
        if ($format === 'index-only') {
            $full_dataset = [
                'meta' => [
                    'source' => $source_found['label'],
                    'source_path' => $source_found['base_path'],
                    'export_timestamp' => gmdate('c'),
                    'format' => 'index-only',
                ],
                'index' => $index_data,
            ];
        } else {
            // formato 'full': incluir todas las páginas individuales
            $pages_list = [];
            if (isset($index_data['pages']) && is_array($index_data['pages'])) {
                $pages_list = $index_data['pages'];
            } elseif (isset($index_data['items']) && is_array($index_data['items'])) {
                // alternativa si el index usa 'items'
                $pages_list = $index_data['items'];
            }

            $pages_full = [];
            foreach ($pages_list as $page_entry) {
                $page_id = null;
                if (is_string($page_entry)) {
                    // si es string directo: "page_42"
                    $page_id = $page_entry;
                } elseif (is_array($page_entry) && isset($page_entry['id'])) {
                    $page_id = $page_entry['id'];
                } elseif (is_array($page_entry) && isset($page_entry['page_id'])) {
                    $page_id = $page_entry['page_id'];
                }

                if ($page_id) {
                    $page_file = $source_found['base_path'] . '/' . $page_id . '.json';
                    if (@file_exists($page_file)) {
                        $page_raw = @file_get_contents($page_file);
                        if ($page_raw !== false) {
                            $page_data = json_decode($page_raw, true);
                            if (json_last_error() === JSON_ERROR_NONE) {
                                $pages_full[$page_id] = $page_data;
                            }
                        }
                    }
                }
            }

            $full_dataset = [
                'meta' => [
                    'source' => $source_found['label'],
                    'source_path' => $source_found['base_path'],
                    'export_timestamp' => gmdate('c'),
                    'format' => 'full',
                    'total_pages' => count($pages_full),
                ],
                'index' => $index_data,
                'pages' => $pages_full,
            ];
        }

        return new WP_REST_Response([
            'ok' => true,
            'export' => $full_dataset,
        ], 200);
    }

    /**
     * Endpoint: GET /v1/media-index
     * Export del índice completo de medios (admin-only)
     * 
     * @param WP_REST_Request $request
     * @return WP_REST_Response
     */
    public static function endpoint_media_index($request) {
        $include_meta = $request->get_param('include_meta') !== false;

        // Obtener todas las imágenes de la biblioteca de medios
        $args = [
            'post_type' => 'attachment',
            'post_mime_type' => 'image',
            'post_status' => 'inherit',
            'posts_per_page' => -1,
            'orderby' => 'ID',
            'order' => 'ASC',
        ];

        $images = get_posts($args);
        $media_list = [];

        foreach ($images as $image) {
            $image_data = [
                'id' => $image->ID,
                'title' => $image->post_title,
                'url' => wp_get_attachment_url($image->ID),
                'alt' => get_post_meta($image->ID, '_wp_attachment_image_alt', true),
            ];

            if ($include_meta) {
                $meta = wp_get_attachment_metadata($image->ID);
                $image_data['meta'] = $meta ?: null;
                $image_data['file'] = get_attached_file($image->ID);
                $image_data['mime_type'] = get_post_mime_type($image->ID);
                $image_data['upload_date'] = $image->post_date_gmt;
            }

            $media_list[] = $image_data;
        }

        return new WP_REST_Response([
            'ok' => true,
            'total_images' => count($media_list),
            'export_timestamp' => gmdate('c'),
            'include_meta' => $include_meta,
            'images' => $media_list,
        ], 200);
    }
}
