<?php
// Permite validar el shortcode sin crear una página: /?briefing_hub=1

// Evitar redirección canónica cuando usamos el flag de test
add_filter('redirect_canonical', function ($redirect_url) {
  if (isset($_GET['briefing_hub']) && $_GET['briefing_hub'] == '1') {
    return false;
  }
  return $redirect_url;
});

add_action('template_redirect', function () {
  if (isset($_GET['briefing_hub']) && $_GET['briefing_hub'] == '1') {
    if (!empty($_GET['status_url'])) {
      $status_url = esc_url_raw($_GET['status_url']);
      add_filter('wp_staging_lite_status_url', function ($u) use ($status_url) { return $status_url; });
    }
    status_header(200);
    header('Content-Type: text/html; charset=UTF-8');
    echo do_shortcode('[briefing_hub]');
    exit;
  }
});
