<?php
/**
 * Plugin Name: WP Staging Lite (MU)
 * Description: Endpoints y shortcodes mínimos para hub/status.
 * Must Use: true
 */

// Cargar endpoints REST
require_once __DIR__ . '/inc/rest-status.php';
require_once __DIR__ . '/inc/rest-trigger.php'; // opcional, deshabilitado por defecto

// Cargar shortcodes
require_once __DIR__ . '/inc/shortcodes/briefing-hub.php';

// Ruta de test rápida del shortcode sin crear página: /?briefing_hub=1
require_once __DIR__ . '/inc/route-briefing-hub-test.php';
