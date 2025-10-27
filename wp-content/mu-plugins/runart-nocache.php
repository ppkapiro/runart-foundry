<?php
/**
 * MU Plugin: RUNArt No-Cache for critical pages
 * Forces no-cache headers on specific routes to avoid stale caches during staging.
 */

if (!defined('ABSPATH')) { exit; }

add_action('send_headers', function() {
    if (!function_exists('is_post_type_archive')) { return; }

    $apply = false;

    // No-cache for front page
    if (is_front_page()) { $apply = true; }

    // No-cache for critical archives
    if (is_post_type_archive('project') || is_post_type_archive('service') || is_post_type_archive('testimonial')) {
        $apply = true;
    }

    if ($apply) {
        // Strong no-cache headers
        header_remove('Last-Modified');
        header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
        header('Cache-Control: post-check=0, pre-check=0', false);
        header('Pragma: no-cache');
        header('Expires: 0');
    }
});
