<?php
// Endpoint POST /wp-json/briefing/v1/trigger (opcional)
// Deshabilitado por defecto para evitar ejecuciones no deseadas.
// Para habilitar, enganche un filtro que devuelva true en 'wp_staging_lite_allow_trigger'.

add_action('rest_api_init', function () {
  register_rest_route('briefing/v1', '/trigger', [
    'methods' => 'POST',
    // Permitir acceso público, pero responder 501 salvo que esté habilitado explícitamente
    'permission_callback' => '__return_true',
    'callback' => function (WP_REST_Request $request) {
      if (apply_filters('wp_staging_lite_allow_trigger', false) || current_user_can('manage_options')) {
        // Aquí iría la lógica real cuando se habilite; por ahora, placeholder
        return new WP_REST_Response([
          'ok' => false,
          'message' => 'Placeholder: implementar lógica del trigger cuando se habilite.'
        ], 200);
      }
      // Por defecto, no realizar llamadas externas. Devolver 501 con mensaje instructivo.
      return new WP_REST_Response([
        'ok' => false,
        'message' => 'Trigger deshabilitado en el scaffold WP Staging Lite. Habilítelo con el filtro wp_staging_lite_allow_trigger y añada la lógica correspondiente.'
      ], 501);
    }
  ]);
});
