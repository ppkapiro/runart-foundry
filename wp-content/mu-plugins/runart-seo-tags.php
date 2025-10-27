<?php
/**
 * Plugin Name: RUN Art Foundry - SEO Tags (Canonical + Hreflang)
 * Description: Canonical tags y hreflang para SEO multilingüe
 * Version: 1.0.0
 * Author: RUN Art Foundry
 */

if ( ! defined( 'ABSPATH' ) ) {
    exit;
}

/**
 * Añade canonical tags y hreflang
 */
function runart_seo_canonical_hreflang() {
    if ( is_admin() ) {
        return;
    }
    
    // Canonical URL
    $canonical = '';
    
    if ( is_singular() ) {
        $canonical = get_permalink();
    } elseif ( is_post_type_archive() ) {
        $canonical = get_post_type_archive_link( get_post_type() );
    } elseif ( is_front_page() ) {
        $canonical = home_url( '/' );
    } elseif ( is_page() ) {
        $canonical = get_permalink();
    }
    
    // Output canonical
    if ( $canonical ) {
        echo '<link rel="canonical" href="' . esc_url( $canonical ) . '">\n';
    }
    
    // Hreflang tags (si Polylang está activo)
    if ( function_exists( 'pll_the_languages' ) ) {
        $translations = pll_the_languages( array( 'raw' => 1 ) );
        
        echo "<!-- Hreflang Tags -->\n";
        
        foreach ( $translations as $lang ) {
            if ( ! empty( $lang['url'] ) ) {
                $hreflang = $lang['slug']; // 'es' o 'en'
                echo '<link rel="alternate" hreflang="' . esc_attr( $hreflang ) . '" href="' . esc_url( $lang['url'] ) . '">\n';
            }
        }
        
        // x-default (idioma por defecto)
        $default_lang = pll_default_language();
        foreach ( $translations as $lang ) {
            if ( $lang['slug'] === $default_lang && ! empty( $lang['url'] ) ) {
                echo '<link rel="alternate" hreflang="x-default" href="' . esc_url( $lang['url'] ) . '">\n';
                break;
            }
        }
    }
}
add_action( 'wp_head', 'runart_seo_canonical_hreflang', 1 );

/**
 * Añade meta description si no existe
 */
function runart_meta_description() {
    if ( is_admin() ) {
        return;
    }
    
    $description = '';
    
    if ( is_singular() ) {
        global $post;
        if ( has_excerpt() ) {
            $description = get_the_excerpt();
        } else {
            $description = wp_trim_words( strip_tags( $post->post_content ), 25 );
        }
    } elseif ( is_post_type_archive( 'project' ) ) {
        $description = 'Galería completa de proyectos de fundición artística en bronce y otros metales realizados por RUN Art Foundry.';
    } elseif ( is_post_type_archive( 'service' ) ) {
        $description = 'Servicios especializados de fundición artística en bronce, restauración y acabados para artistas y escultores.';
    } elseif ( is_front_page() ) {
        $description = 'Fundición artística de precisión en bronce y otros metales nobles. Más de 30 años de experiencia al servicio de artistas y escultores.';
    }
    
    if ( $description ) {
        $description = wp_strip_all_tags( $description );
        $description = str_replace( '"', '&quot;', $description );
        echo '<meta name="description" content="' . esc_attr( $description ) . '">\n';
    }
}
add_action( 'wp_head', 'runart_meta_description', 2 );
