<?php
if (!defined('ABSPATH')) {
    exit;
}

class RunArt_AI_Visual_REST {
    public static function register_routes() {
        register_rest_route('runart', '/content/enriched-list', [
            'methods' => 'GET',
            'callback' => [__CLASS__, 'handle_enriched_list'],
            'permission_callback' => '__return_true'
        ]);

        register_rest_route('runart', '/content/wp-pages', [
            'methods' => 'GET',
            'callback' => [__CLASS__, 'handle_wp_pages'],
            'permission_callback' => function () {
                // permitir a usuarios logueados; si se requiere público, cambiar a __return_true
                return is_user_logged_in();
            },
            'args' => [
                'page' => ['required' => false, 'type' => 'integer', 'default' => 1],
                'per_page' => ['required' => false, 'type' => 'integer', 'default' => 25],
            ],
        ]);

        register_rest_route('runart', '/content/enriched-request', [
            'methods' => 'POST',
            'callback' => [__CLASS__, 'handle_enriched_request'],
            'permission_callback' => function () {
                return current_user_can('edit_posts');
            },
        ]);
    }

    public static function handle_enriched_list($request) {
        $file = self::locate_enriched_index();

        if (!$file || !file_exists($file)) {
            return new WP_REST_Response(['ok' => true, 'items' => []], 200);
        }

        $content = file_get_contents($file);
        if ($content === false) {
            return new WP_REST_Response(['ok' => false, 'items' => [], 'message' => 'read_error'], 500);
        }

        $data = json_decode($content, true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            return new WP_REST_Response(['ok' => false, 'items' => [], 'message' => 'json_error'], 500);
        }

        $items = [];
        if (isset($data['pages']) && is_array($data['pages'])) {
            $items = $data['pages'];
        } elseif (isset($data[0])) {
            $items = $data;
        }

        return new WP_REST_Response(['ok' => true, 'items' => $items], 200);
    }

    public static function handle_wp_pages($request) {
        $page = intval($request->get_param('page')) ?: 1;
        $per_page = intval($request->get_param('per_page')) ?: 25;
        if ($per_page > 50) $per_page = 50;

        $req = new WP_REST_Request('GET', '/wp/v2/pages');
        $req->set_query_params(['per_page' => $per_page, 'page' => $page]);
        $start = microtime(true);
        $resp = rest_do_request($req);
        $duration_ms = intval(round((microtime(true) - $start) * 1000));

        if (!$resp || $resp->is_error()) {
            return new WP_REST_Response(['ok' => false, 'status' => 'fallback', 'duration_ms' => $duration_ms], 200);
        }

        $data = $resp->get_data();
        $headers = $resp->get_headers();
        $total = isset($headers['X-WP-Total']) ? intval($headers['X-WP-Total']) : null;
        $total_pages = isset($headers['X-WP-TotalPages']) ? intval($headers['X-WP-TotalPages']) : null;

        $items = [];
        if (is_array($data)) {
            foreach ($data as $p) {
                $pid = isset($p['id']) ? intval($p['id']) : null;
                $title = '';
                if (isset($p['title']) && is_array($p['title']) && isset($p['title']['rendered'])) {
                    $title = wp_strip_all_tags($p['title']['rendered']);
                } elseif (isset($p['title']) && is_string($p['title'])) {
                    $title = $p['title'];
                }
                if ($title === '') {
                    $title = 'Página ' . $pid;
                }
                $items[] = ['id' => 'page_' . $pid, 'wp_id' => $pid, 'title' => $title];
            }
        }

        $has_more = $total_pages ? ($page < $total_pages) : false;
        $next = $has_more ? rest_url('runart/content/wp-pages') . '?page=' . ($page + 1) . '&per_page=' . $per_page : null;

        return new WP_REST_Response([
            'ok' => true,
            'items' => $items,
            'page' => $page,
            'per_page' => $per_page,
            'total' => $total,
            'total_pages' => $total_pages,
            'has_more' => $has_more,
            'next' => $next,
            'duration_ms' => $duration_ms
        ], 200);
    }

    public static function handle_enriched_request($request) {
        $body = $request->get_json_params();
        $wp_id = isset($body['wp_id']) ? intval($body['wp_id']) : null;
        $lang = isset($body['lang']) ? sanitize_text_field($body['lang']) : 'es';

        if (!$wp_id) {
            return new WP_REST_Response(['ok' => false, 'message' => 'missing_wp_id'], 400);
        }

        $uploads = wp_upload_dir();
        $base = isset($uploads['basedir']) ? $uploads['basedir'] : (ABSPATH . 'wp-content/uploads');
        $dir = trailingslashit($base) . 'runart-jobs/';
        if (!is_dir($dir)) {
            wp_mkdir_p($dir);
        }

        $file = $dir . 'enriched-requests.json';
        $requests = [];
        if (file_exists($file)) {
            $c = file_get_contents($file);
            $r = json_decode($c, true);
            if (json_last_error() === JSON_ERROR_NONE && is_array($r)) $requests = $r;
        }

        $req_id = 'wp_' . $wp_id . '_' . time();
        $requests[$req_id] = ['wp_id' => $wp_id, 'lang' => $lang, 'requested_at' => gmdate('c')];
        $ok = @file_put_contents($file, json_encode($requests, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
        if ($ok === false) {
            return new WP_REST_Response(['ok' => false, 'message' => 'write_error'], 500);
        }

        return new WP_REST_Response(['ok' => true, 'request_id' => $req_id], 200);
    }

    private static function locate_enriched_index() {
        $uploads = wp_upload_dir();
        $base = isset($uploads['basedir']) ? $uploads['basedir'] : (ABSPATH . 'wp-content/uploads');
        $paths = [
            trailingslashit($base) . RUNART_AIVP_DATA_RELATIVE,
            RUNART_AIVP_DIR . 'data/index.json',
        ];
        foreach ($paths as $path) {
            if ($path && file_exists($path)) {
                return $path;
            }
        }
        return null;
    }
}
