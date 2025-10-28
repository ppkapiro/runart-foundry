<?php
/**
 * RUN Art Foundry Theme Functions
 * 
 * @package RUNArtFoundry
 * @version 1.0.0
 */

// Prevenir acceso directo
if ( ! defined( 'ABSPATH' ) ) {
    exit;
}

/**
 * Theme setup
 */
function runart_theme_setup() {
    // Soporte para traducciones
    load_theme_textdomain( 'runart', get_template_directory() . '/languages' );
    
    // Soporte para título dinámico
    add_theme_support( 'title-tag' );
    
    // Soporte para imágenes destacadas
    add_theme_support( 'post-thumbnails' );
    
    // Tamaños de imagen personalizados
    add_image_size( 'runart-hero', 2560, 1200, true );
    add_image_size( 'runart-large', 1600, 900, true );
    add_image_size( 'runart-medium', 800, 450, true );
    add_image_size( 'runart-thumb', 400, 300, true );
    
    // Soporte para HTML5
    add_theme_support( 'html5', array(
        'search-form',
        'comment-form',
        'comment-list',
        'gallery',
        'caption',
    ) );
    
    // Soporte para editor de bloques
    add_theme_support( 'editor-styles' );
    add_theme_support( 'align-wide' );
    add_theme_support( 'responsive-embeds' );
    
    // Registrar menús
    register_nav_menus( array(
        'primary' => __( 'Menú Principal', 'runart' ),
        'footer'  => __( 'Menú Footer', 'runart' ),
    ) );
}
add_action( 'after_setup_theme', 'runart_theme_setup' );

/**
 * Enqueue styles and scripts
 */
function runart_enqueue_assets() {
    $theme_version = wp_get_theme()->get( 'Version' );
    
    // CSS
    wp_enqueue_style( 'runart-variables', get_template_directory_uri() . '/assets/css/variables.css', array(), $theme_version );
    wp_enqueue_style( 'runart-base', get_template_directory_uri() . '/assets/css/base.css', array( 'runart-variables' ), $theme_version );
    wp_enqueue_style( 'runart-header', get_template_directory_uri() . '/assets/css/header.css', array( 'runart-base' ), $theme_version );
    wp_enqueue_style( 'runart-footer', get_template_directory_uri() . '/assets/css/footer.css', array( 'runart-base' ), $theme_version );
    wp_enqueue_style( 'runart-home', get_template_directory_uri() . '/assets/css/home.css', array( 'runart-base' ), $theme_version );
    wp_enqueue_style( 'runart-projects', get_template_directory_uri() . '/assets/css/projects.css', array( 'runart-base' ), $theme_version );
    wp_enqueue_style( 'runart-services', get_template_directory_uri() . '/assets/css/services.css', array( 'runart-base' ), $theme_version );
    wp_enqueue_style( 'runart-about', get_template_directory_uri() . '/assets/css/about.css', array( 'runart-base' ), $theme_version );
    wp_enqueue_style( 'runart-contact', get_template_directory_uri() . '/assets/css/contact.css', array( 'runart-base' ), $theme_version );
    wp_enqueue_style( 'runart-testimonials', get_template_directory_uri() . '/assets/css/testimonials.css', array( 'runart-base' ), $theme_version );
    
    // JavaScript (si necesario)
    // wp_enqueue_script( 'runart-main', get_template_directory_uri() . '/assets/js/main.js', array(), $theme_version, true );
}
add_action( 'wp_enqueue_scripts', 'runart_enqueue_assets' );

/**
 * Registrar Custom Post Types y Taxonomías
 */
require_once get_template_directory() . '/inc/custom-post-types.php';

/**
 * Widget areas
 */
function runart_widgets_init() {
    register_sidebar( array(
        'name'          => __( 'Footer 1', 'runart' ),
        'id'            => 'footer-1',
        'description'   => __( 'Primera columna del footer', 'runart' ),
        'before_widget' => '<div id="%1$s" class="widget %2$s">',
        'after_widget'  => '</div>',
        'before_title'  => '<h3 class="widget-title">',
        'after_title'   => '</h3>',
    ) );
    
    register_sidebar( array(
        'name'          => __( 'Footer 2', 'runart' ),
        'id'            => 'footer-2',
        'description'   => __( 'Segunda columna del footer', 'runart' ),
        'before_widget' => '<div id="%1$s" class="widget %2$s">',
        'after_widget'  => '</div>',
        'before_title'  => '<h3 class="widget-title">',
        'after_title'   => '</h3>',
    ) );
    
    register_sidebar( array(
        'name'          => __( 'Footer 3', 'runart' ),
        'id'            => 'footer-3',
        'description'   => __( 'Tercera columna del footer', 'runart' ),
        'before_widget' => '<div id="%1$s" class="widget %2$s">',
        'after_widget'  => '</div>',
        'before_title'  => '<h3 class="widget-title">',
        'after_title'   => '</h3>',
    ) );
}
add_action( 'widgets_init', 'runart_widgets_init' );

/**
 * Excerpt customization
 */
function runart_excerpt_length( $length ) {
    return 30;
}
add_filter( 'excerpt_length', 'runart_excerpt_length' );

function runart_excerpt_more( $more ) {
    return '...';
}
add_filter( 'excerpt_more', 'runart_excerpt_more' );

/**
 * Cleanup WordPress head
 */
remove_action( 'wp_head', 'rsd_link' );
remove_action( 'wp_head', 'wlwmanifest_link' );
remove_action( 'wp_head', 'wp_generator' );
remove_action( 'wp_head', 'wp_shortlink_wp_head' );

/**
 * Helper: Get contact URL for language (used in templates)
 * Defined in mu-plugins/runart-quote-links.php but fallback here
 */
if ( ! function_exists( 'runart_get_contact_url_for_lang' ) ) {
    function runart_get_contact_url_for_lang( $lang = 'en' ) {
        $urls = array(
            'es' => home_url( '/es/contacto/' ),
            'en' => home_url( '/en/contact/' ),
        );
        return $urls[ $lang ] ?? $urls['en'];
    }
}

/**
 * Theme version for cache busting
 */
function runart_theme_version() {
    return wp_get_theme()->get( 'Version' );
}

/**
 * Disable WordPress emoji scripts
 */
remove_action( 'wp_head', 'print_emoji_detection_script', 7 );
remove_action( 'wp_print_styles', 'print_emoji_styles' );

/**
 * Security: Remove WordPress version from RSS
 */
add_filter( 'the_generator', '__return_empty_string' );
