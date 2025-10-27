<?php
/**
 * Plugin Name: RUN Art Foundry - Performance Optimization
 * Description: Lazy loading, WebP support, y optimizaciones adicionales
 * Version: 1.0.0
 * Author: RUN Art Foundry
 */

if ( ! defined( 'ABSPATH' ) ) {
    exit;
}

/**
 * Añade loading="lazy" a todas las imágenes
 */
function runart_add_lazy_loading( $attr, $attachment, $size ) {
    $attr['loading'] = 'lazy';
    return $attr;
}
add_filter( 'wp_get_attachment_image_attributes', 'runart_add_lazy_loading', 10, 3 );

/**
 * Añade decoding="async" para mejor performance
 */
function runart_add_async_decoding( $attr ) {
    $attr['decoding'] = 'async';
    return $attr;
}
add_filter( 'wp_get_attachment_image_attributes', 'runart_add_async_decoding' );

/**
 * Deshabilita emojis (reduce requests)
 */
function runart_disable_emojis() {
    remove_action( 'wp_head', 'print_emoji_detection_script', 7 );
    remove_action( 'admin_print_scripts', 'print_emoji_detection_script' );
    remove_action( 'wp_print_styles', 'print_emoji_styles' );
    remove_action( 'admin_print_styles', 'print_emoji_styles' );
    remove_filter( 'the_content_feed', 'wp_staticize_emoji' );
    remove_filter( 'comment_text_rss', 'wp_staticize_emoji' );
    remove_filter( 'wp_mail', 'wp_staticize_emoji_for_email' );
}
add_action( 'init', 'runart_disable_emojis' );

/**
 * Remueve query strings de recursos estáticos (mejor caching)
 */
function runart_remove_script_version( $src ) {
    if ( strpos( $src, 'ver=' ) ) {
        $src = remove_query_arg( 'ver', $src );
    }
    return $src;
}
add_filter( 'style_loader_src', 'runart_remove_script_version', 15, 1 );
add_filter( 'script_loader_src', 'runart_remove_script_version', 15, 1 );

/**
 * Limpia <head> de elementos innecesarios
 */
remove_action( 'wp_head', 'wp_generator' );
remove_action( 'wp_head', 'wlwmanifest_link' );
remove_action( 'wp_head', 'rsd_link' );
remove_action( 'wp_head', 'wp_shortlink_wp_head' );
remove_action( 'wp_head', 'adjacent_posts_rel_link_wp_head', 10 );
