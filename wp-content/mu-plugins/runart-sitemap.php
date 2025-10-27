<?php
/**
 * Plugin Name: RUN Art Foundry - XML Sitemap
 * Description: Generador simple de sitemap XML para SEO
 * Version: 1.0.0
 * Author: RUN Art Foundry
 */

if ( ! defined( 'ABSPATH' ) ) {
    exit;
}

/**
 * Registra rewrite rules para sitemap
 */
function runart_sitemap_rewrite_rules() {
    add_rewrite_rule( '^sitemap\.xml$', 'index.php?runart_sitemap=index', 'top' );
    add_rewrite_rule( '^sitemap-([a-z]+)\.xml$', 'index.php?runart_sitemap=$matches[1]', 'top' );
}
add_action( 'init', 'runart_sitemap_rewrite_rules' );

/**
 * Añade query vars
 */
function runart_sitemap_query_vars( $vars ) {
    $vars[] = 'runart_sitemap';
    return $vars;
}
add_filter( 'query_vars', 'runart_sitemap_query_vars' );

/**
 * Genera el sitemap
 */
function runart_sitemap_template_redirect() {
    $sitemap_type = get_query_var( 'runart_sitemap' );
    
    if ( ! $sitemap_type ) {
        return;
    }
    
    header( 'Content-Type: application/xml; charset=utf-8' );
    
    if ( $sitemap_type === 'index' ) {
        runart_generate_sitemap_index();
    } else {
        runart_generate_sitemap_type( $sitemap_type );
    }
    
    exit;
}
add_action( 'template_redirect', 'runart_sitemap_template_redirect' );

/**
 * Genera sitemap index
 */
function runart_generate_sitemap_index() {
    echo '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
    echo '<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' . "\n";
    
    $post_types = array( 'page', 'post', 'project', 'service', 'testimonial' );
    
    foreach ( $post_types as $post_type ) {
        $count = wp_count_posts( $post_type );
        if ( $count->publish > 0 ) {
            echo '  <sitemap>' . "\n";
            echo '    <loc>' . home_url( "/sitemap-{$post_type}.xml" ) . '</loc>' . "\n";
            echo '    <lastmod>' . date( 'c' ) . '</lastmod>' . "\n";
            echo '  </sitemap>' . "\n";
        }
    }
    
    echo '</sitemapindex>';
}

/**
 * Genera sitemap por tipo
 */
function runart_generate_sitemap_type( $post_type ) {
    echo '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
    echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">' . "\n";
    
    $args = array(
        'post_type' => $post_type,
        'post_status' => 'publish',
        'posts_per_page' => -1,
        'orderby' => 'modified',
        'order' => 'DESC',
        'lang' => '', // Polylang: obtener todos los idiomas
    );
    
    $posts = get_posts( $args );
    
    foreach ( $posts as $post ) {
        $permalink = get_permalink( $post->ID );
        $modified = get_post_modified_time( 'c', false, $post );
        
        // Prioridad según tipo
        $priority = '0.5';
        if ( $post_type === 'page' ) {
            $priority = is_front_page( $post->ID ) ? '1.0' : '0.8';
        } elseif ( $post_type === 'service' ) {
            $priority = '0.9';
        } elseif ( $post_type === 'project' ) {
            $priority = '0.8';
        } elseif ( $post_type === 'testimonial' ) {
            $priority = '0.7';
        } elseif ( $post_type === 'post' ) {
            $priority = '0.6';
        }
        
        // Frecuencia
        $changefreq = in_array( $post_type, array( 'project', 'service', 'testimonial' ) ) ? 'monthly' : 'weekly';
        
        echo '  <url>' . "\n";
        echo '    <loc>' . esc_url( $permalink ) . '</loc>' . "\n";
        echo '    <lastmod>' . $modified . '</lastmod>' . "\n";
        echo '    <changefreq>' . $changefreq . '</changefreq>' . "\n";
        echo '    <priority>' . $priority . '</priority>' . "\n";
        
        // Incluir imagen destacada si existe
        if ( has_post_thumbnail( $post->ID ) ) {
            $image_url = get_the_post_thumbnail_url( $post->ID, 'full' );
            echo '    <image:image>' . "\n";
            echo '      <image:loc>' . esc_url( $image_url ) . '</image:loc>' . "\n";
            echo '      <image:title>' . esc_html( get_the_title( $post->ID ) ) . '</image:title>' . "\n";
            echo '    </image:image>' . "\n";
        }
        
        echo '  </url>' . "\n";
    }
    
    echo '</urlset>';
}

/**
 * Flush rewrite rules al activar
 */
function runart_sitemap_activate() {
    runart_sitemap_rewrite_rules();
    flush_rewrite_rules();
}
register_activation_hook( __FILE__, 'runart_sitemap_activate' );
