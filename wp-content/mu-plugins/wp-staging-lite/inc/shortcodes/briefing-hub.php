<?php
// [briefing_hub] — Render mínimo que consume /wp-json/briefing/v1/status
add_shortcode('briefing_hub', function () {
  $url = apply_filters('wp_staging_lite_status_url', site_url('/wp-json/briefing/v1/status'));
  $resp = wp_remote_get($url, [ 'timeout' => 5 ]);
  if (is_wp_error($resp)) {
    return '<p>Estado no disponible (error de conexión).</p>';
  }
  $body = json_decode(wp_remote_retrieve_body($resp), true);
  if (!$body || !is_array($body)) {
    return '<p>Estado no disponible.</p>';
  }
  $health = esc_html($body['health'] ?? 'N/A');
  $out = '<div class="briefing-hub"><h3>Estado general: ' . $health . '</h3><ul>';
  if (!empty($body['services']) && is_array($body['services'])) {
    foreach ($body['services'] as $svc) {
      $n = esc_html($svc['name'] ?? '');
      $s = esc_html($svc['state'] ?? '');
      $out .= '<li><strong>' . $n . '</strong>: ' . $s . '</li>';
    }
  }
  $out .= '</ul></div>';
  return $out;
});
