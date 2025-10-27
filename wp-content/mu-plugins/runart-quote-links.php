<?php
/**
 * Plugin Name: RUN Art Foundry - Quote Links Normalizer
 * Description: Normaliza todos los enlaces de "Cotización/Quote" en contenidos y menús según idioma.
 * Version: 1.1.0
 * Author: RUN Art Foundry
 */

if ( ! defined( 'ABSPATH' ) ) { exit; }

function runart_get_quote_url_for_lang( $lang ) {
    $es = get_page_by_path( 'cotizacion' );
    $en = get_page_by_path( 'quote' );
    $urls = array(
        'es' => $es ? get_permalink( $es ) : home_url( '/es/cotizacion/' ),
        'en' => $en ? get_permalink( $en ) : home_url( '/en/quote/' ),
    );
    $lang = in_array( $lang, array( 'es', 'en' ), true ) ? $lang : ( function_exists( 'pll_current_language' ) ? pll_current_language() : 'en' );
    return $urls[ $lang ];
}

function runart_normalize_quote_links_in_content( $content ) {
    if ( is_admin() || empty( $content ) ) { return $content; }

    $lang = function_exists( 'pll_current_language' ) ? pll_current_language() : ( strpos( home_url(), '/es/' ) !== false ? 'es' : 'en' );
    $target = esc_url( runart_get_quote_url_for_lang( $lang ) );

    // Patrones por idioma
    $patterns = array();
    if ( $lang === 'es' ) {
        $patterns = array(
            '/<a\s+([^>]*?)href=(["\'])([^"\']*)(["\'])\s*([^>]*)>([^<]*?(cotiz[a-zá]+|solicita(r)?\s+una\s+cotización|solicitar\s+cotización)[^<]*?)<\/a>/iu',
        );
    } else {
        $patterns = array(
            '/<a\s+([^>]*?)href=(["\'])([^"\']*)(["\'])\s*([^>]*)>([^<]*?(request\s+a\s+quote|get\s+a?\s*quote|\bquote\b)[^<]*?)<\/a>/iu',
        );
    }

    foreach ( $patterns as $regex ) {
        $content = preg_replace_callback( $regex, function( $m ) use ( $target ) {
            $before_attrs = $m[1];
            $q1 = $m[2];
            $old = $m[3];
            $q2 = $m[4];
            $after_attrs = $m[5];
            $anchor_text = $m[6];
            $attrs = trim( $before_attrs . ' ' . $after_attrs );
            $attrs = preg_replace( '/\bhref\s*=\s*(["\']).*?\1/i', '', $attrs );
            $attrs = trim( preg_replace( '/\s+/', ' ', $attrs ) );
            $attrs = $attrs ? ' ' . $attrs : '';
            return '<a href="' . esc_url( $target ) . '"' . $attrs . '>' . $anchor_text . '</a>';
        }, $content );
    }

    return $content;
}
add_filter( 'the_content', 'runart_normalize_quote_links_in_content', 9 );

function runart_normalize_quote_links_in_menu( $items, $args ) {
    if ( empty( $items ) ) { return $items; }
    $lang = function_exists( 'pll_current_language' ) ? pll_current_language() : 'en';
    $target_es = runart_get_quote_url_for_lang( 'es' );
    $target_en = runart_get_quote_url_for_lang( 'en' );
    $out = array();

    foreach ( $items as $item ) {
        $title = wp_strip_all_tags( $item->title );
        if ( preg_match( '/cotiz/i', $title ) ) {
            $item->url = $target_es;
            if ( $lang !== 'es' ) { continue; }
        } elseif ( preg_match( '/\bquote\b/i', $title ) || preg_match( '/request\s+a\s+quote|get\s+a?\s*quote/i', $title ) ) {
            $item->url = $target_en;
            if ( $lang !== 'en' ) { continue; }
        }
        $out[] = $item;
    }
    return $out;
}
add_filter( 'wp_nav_menu_objects', 'runart_normalize_quote_links_in_menu', 10, 2 );

function runart_shortcode_quote_url( $atts ) {
    $lang = isset( $atts['lang'] ) ? $atts['lang'] : ( function_exists( 'pll_current_language' ) ? pll_current_language() : 'en' );
    return esc_url( runart_get_quote_url_for_lang( $lang ) );
}
add_shortcode( 'quote_url', 'runart_shortcode_quote_url' );

if ( ! function_exists( 'runart_get_contact_url_for_lang' ) ) {
    function runart_get_contact_url_for_lang( $lang ) {
        $es = get_page_by_path( 'contacto' );
        // Variantes comunes en EN
        $en = get_page_by_path( 'contact' );
        if ( ! $en ) { $en = get_page_by_path( 'contact-us' ); }
        $urls = array(
            'es' => $es ? get_permalink( $es ) : home_url( '/es/contacto/' ),
            'en' => $en ? get_permalink( $en ) : home_url( '/en/contact/' ),
        );
        $lang = in_array( $lang, array( 'es', 'en' ), true ) ? $lang : ( function_exists( 'pll_current_language' ) ? pll_current_language() : 'en' );
        return $urls[ $lang ];
    }
}
