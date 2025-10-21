<?php
/*
Plugin Name: RunArt WP-CLI Bridge (REST)
Description: Endpoint REST mínimo (health) para validar la instalación y servir como base del bridge WP-CLI controlado por CI/CD.
Version: 1.0.1
Author: RunArt Foundry
License: GPL-2.0-or-later
*/

if ( ! defined( 'ABSPATH' ) ) { exit; }

define( 'RUNART_WPCLI_BRIDGE_VERSION', '1.0.1' );

add_action('rest_api_init', function () {
    register_rest_route(
        'runart-bridge/v1',
        '/health',
        array(
            'methods'             => 'GET',
            'permission_callback' => function () {
                // Requiere credenciales con capacidad de admin (compatible con Application Passwords).
                return current_user_can('manage_options');
            },
            'callback'            => function () {
                return new WP_REST_Response(
                    array(
                        'ok'      => true,
                        'plugin'  => 'runart-wpcli-bridge',
                        'version' => RUNART_WPCLI_BRIDGE_VERSION,
                        'site'    => get_site_url(),
                        'ts'      => time(),
                    ),
                    200
                );
            },
        )
    );
});
