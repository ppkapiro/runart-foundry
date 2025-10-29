<?php
/**
 * Plugin Name: RUN Art Foundry - Social Meta Tags
 * Description: Open Graph y Twitter Cards para compartir en redes sociales
 * Version: 1.0.0
 * Author: RUN Art Foundry
 */

if ( ! defined( 'ABSPATH' ) ) {
    exit;
}

/**
 * Genera meta tags de Open Graph y Twitter Cards
 */
function runart_social_meta_tags() {
    // Solo en frontend
    if ( is_admin() ) {
        return;
    }

    // Datos base del sitio
    $site_name = 'RUN Art Foundry';
    $site_url = home_url();
    $default_image = $site_url . '/wp-content/uploads/logo-runart.png';
    
    // Variables para meta tags
    $og_title = '';
    $og_description = '';
    $og_image = $default_image;
    $og_url = '';
    $og_type = 'website';

    // Determinar contenido según contexto
    if ( is_singular() ) {
        global $post;
        
        $og_title = get_the_title();
        $og_description = has_excerpt() ? get_the_excerpt() : wp_trim_words( strip_tags( $post->post_content ), 30 );
        $og_url = get_permalink();
        
        // Imagen destacada
        if ( has_post_thumbnail() ) {
            $og_image = get_the_post_thumbnail_url( $post->ID, 'full' );
        }
        
        // Tipo según post type
        $post_type = get_post_type();
        if ( $post_type === 'project' ) {
            $og_title .= ' — Fundición Artística';
            $og_type = 'article';
        } elseif ( $post_type === 'service' ) {
            $og_title .= ' — Servicios de Fundición';
            $og_type = 'article';
        } elseif ( $post_type === 'testimonial' ) {
            $og_title = 'Testimonio: ' . $og_title;
            $og_type = 'article';
        } elseif ( $post_type === 'post' ) {
            $og_type = 'article';
        }
        
        $og_title .= ' | ' . $site_name;
        
    } elseif ( is_post_type_archive( 'project' ) ) {
        $og_title = 'Proyectos de Fundición Artística | ' . $site_name;
        $og_description = 'Galería completa de proyectos de fundición en bronce y otros metales realizados por RUN Art Foundry.';
        $og_url = get_post_type_archive_link( 'project' );
        
    } elseif ( is_post_type_archive( 'service' ) ) {
        $og_title = 'Servicios de Fundición Artística | ' . $site_name;
        $og_description = 'Servicios especializados de fundición en bronce, restauración y acabados para artistas y escultores.';
        $og_url = get_post_type_archive_link( 'service' );
        
    } elseif ( is_front_page() ) {
        $og_title = $site_name . ' — Fundición Artística en Bronce de Alta Calidad';
        $og_description = 'Fundición artística de precisión en bronce y otros metales nobles. Más de 30 años de experiencia al servicio de artistas y escultores.';
        $og_url = home_url();
        
    } elseif ( is_page() ) {
        $og_title = get_the_title() . ' | ' . $site_name;
        $og_description = has_excerpt() ? get_the_excerpt() : '';
        $og_url = get_permalink();
        
    } else {
        $og_title = get_bloginfo( 'name' );
        $og_description = get_bloginfo( 'description' );
        $og_url = home_url();
    }

    // Limpiar descripción
    $og_description = wp_strip_all_tags( $og_description );
    $og_description = str_replace( '"', '&quot;', $og_description );
    
    // Output Open Graph tags
    echo "\n<!-- Open Graph Meta Tags -->\n";
    echo '<meta property="og:site_name" content="' . esc_attr( $site_name ) . '">\n';
    echo '<meta property="og:type" content="' . esc_attr( $og_type ) . '">\n';
    echo '<meta property="og:title" content="' . esc_attr( $og_title ) . '">\n';
    echo '<meta property="og:description" content="' . esc_attr( $og_description ) . '">\n';
    echo '<meta property="og:url" content="' . esc_url( $og_url ) . '">\n';
    echo '<meta property="og:image" content="' . esc_url( $og_image ) . '">\n';
    echo '<meta property="og:image:width" content="1200">\n';
    echo '<meta property="og:image:height" content="630">\n';
    echo '<meta property="og:locale" content="' . ( function_exists('pll_current_language') && pll_current_language() === 'es' ? 'es_ES' : 'en_US' ) . '">\n';
    
    // Alternate language
    if ( function_exists( 'pll_current_language' ) && function_exists( 'pll_the_languages' ) ) {
        $translations = pll_the_languages( array( 'raw' => 1 ) );
        foreach ( $translations as $lang ) {
            if ( !empty($lang['current_lang']) ) continue;
            echo '<meta property="og:locale:alternate" content="' . ( $lang['slug'] === 'es' ? 'es_ES' : 'en_US' ) . '">\n';
        }
    }
    
    // Output Twitter Card tags
    echo "\n<!-- Twitter Card Meta Tags -->\n";
    echo '<meta name="twitter:card" content="summary_large_image">\n';
    echo '<meta name="twitter:site" content="@runartfoundry">\n';
    echo '<meta name="twitter:title" content="' . esc_attr( $og_title ) . '">\n';
    echo '<meta name="twitter:description" content="' . esc_attr( $og_description ) . '">\n';
    echo '<meta name="twitter:image" content="' . esc_url( $og_image ) . '">\n';
}

add_action( 'wp_head', 'runart_social_meta_tags', 5 );
