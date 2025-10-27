<?php
/**
 * Plugin Name: RUNArt Redirects
 * Description: Redirecciones específicas para URLs antiguas.
 * Author: RUN Art Foundry
 * Version: 1.1.0
 */

if ( ! defined( 'ABSPATH' ) ) { exit; }

add_action('template_redirect', function () {
    if ( is_admin() ) return;

    $uri = isset($_SERVER['REQUEST_URI']) ? $_SERVER['REQUEST_URI'] : '';
    $path = strtok($uri, '?');

    // Normalizar sin trailing slash
    $normalized = rtrim($path, '/');

    // Redirigir /es/servicios o /es/servicios/ -> /es/services/
    if ($normalized === '/es/servicios') {
        $target = home_url('/es/services/');
        wp_redirect($target, 301);
        exit;
    }
});
