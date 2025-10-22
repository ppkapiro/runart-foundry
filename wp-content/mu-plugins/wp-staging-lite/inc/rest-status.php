<?php
// Endpoint GET /wp-json/briefing/v1/status
// Nota: En producción, leer docs/status.json generado por CI o componer desde WP.
add_action('rest_api_init', function () {
  register_rest_route('briefing/v1', '/status', [
    'methods' => 'GET',
    'permission_callback' => '__return_true',
    'callback' => function () {
      // Intentar leer status.json generado por workflow (copiado al plugin)
      $status_path = __DIR__ . '/../status.json';
      if (file_exists($status_path)) {
        $json = file_get_contents($status_path);
        $data = json_decode($json, true);
        if (is_array($data) && !empty($data)) {
          return new WP_REST_Response($data, 200);
        }
      }
      // Fallback mínimo
      return new WP_REST_Response([
        'version' => 'staging',
        'last_update' => gmdate('c'),
        'health' => 'OK',
        'services' => [ ['name' => 'web', 'state' => 'OK'] ],
      ], 200);
    }
  ]);
});
