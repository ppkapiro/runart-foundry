<?php
/**
 * RunArt Base Theme Functions
 *
 * @package RunArt_Base
 */

// Theme Setup
function runart_theme_setup() {
    // Add theme support
    add_theme_support('title-tag');
    add_theme_support('post-thumbnails');
    add_theme_support('html5', array('search-form', 'comment-form', 'comment-list', 'gallery', 'caption'));
    add_theme_support('custom-logo');

    // Register nav menus
    register_nav_menus(array(
        'primary' => __('Primary Menu', 'runart'),
        'footer'  => __('Footer Menu', 'runart'),
    ));

    // Image sizes
    add_image_size('project-thumbnail', 800, 600, true);
    add_image_size('blog-thumbnail', 600, 400, true);
}
add_action('after_setup_theme', 'runart_theme_setup');

// Enqueue Styles and Scripts
function runart_enqueue_assets() {
    // CSS Variables (first)
    wp_enqueue_style('runart-variables', get_template_directory_uri() . '/assets/css/variables.css', array(), '1.0.0');
    
    // Base CSS
    wp_enqueue_style('runart-base-css', get_template_directory_uri() . '/assets/css/base.css', array('runart-variables'), '1.0.0');
    
    // Page-specific CSS
    if (is_front_page()) {
        wp_enqueue_style('runart-home', get_template_directory_uri() . '/assets/css/home.css', array('runart-base-css'), '1.0.0');
    }
    
    if (is_page_template('page-about.php')) {
        wp_enqueue_style('runart-about', get_template_directory_uri() . '/assets/css/about.css', array('runart-base-css'), '1.0.0');
    }
    
    if (is_page_template('page-contact.php')) {
        wp_enqueue_style('runart-contact', get_template_directory_uri() . '/assets/css/contact.css', array('runart-base-css'), '1.0.0');
    }
    
    if (is_singular('project') || is_post_type_archive('project')) {
        wp_enqueue_style('runart-projects', get_template_directory_uri() . '/assets/css/projects.css', array('runart-base-css'), '1.0.0');
    }
    
    if (is_singular('service') || is_post_type_archive('service')) {
        wp_enqueue_style('runart-services', get_template_directory_uri() . '/assets/css/services.css', array('runart-base-css'), '1.0.0');
    }
    
    if (is_home() || is_singular('post') || is_archive()) {
        wp_enqueue_style('runart-blog', get_template_directory_uri() . '/assets/css/blog.css', array('runart-base-css'), '1.0.0');
    }
    
    // Header & Footer CSS (on all pages)
    wp_enqueue_style('runart-header', get_template_directory_uri() . '/assets/css/header.css', array('runart-base-css'), '1.0.0');
    wp_enqueue_style('runart-footer', get_template_directory_uri() . '/assets/css/footer.css', array('runart-base-css'), '1.0.0');
    
    // Main theme stylesheet (last)
    wp_enqueue_style('runart-base-style', get_stylesheet_uri(), array('runart-header', 'runart-footer'), '1.0.0');

    // Responsive overrides (absolute last): surgical fixes for mobile/tablet
    wp_enqueue_style(
        'runart-responsive-overrides',
        get_template_directory_uri() . '/assets/css/responsive.overrides.css',
        array('runart-base-style'),
        '0.3.1.3'
    );
    
    // JavaScript
    wp_enqueue_script('runart-main', get_template_directory_uri() . '/assets/js/main.js', array('jquery'), '1.0.0', true);
}
add_action('wp_enqueue_scripts', 'runart_enqueue_assets');

// Register Sidebar
function runart_widgets_init() {
    register_sidebar(array(
        'name'          => __('Blog Sidebar', 'runart'),
        'id'            => 'blog-sidebar',
        'description'   => __('Widgets for blog pages', 'runart'),
        'before_widget' => '<div id="%1$s" class="widget %2$s">',
        'after_widget'  => '</div>',
        'before_title'  => '<h3 class="widget-title">',
        'after_title'   => '</h3>',
    ));
}
add_action('widgets_init', 'runart_widgets_init');

// Custom excerpt length
function runart_excerpt_length($length) {
    return 30;
}
add_filter('excerpt_length', 'runart_excerpt_length');

// Custom excerpt more
function runart_excerpt_more($more) {
    return '...';
}
add_filter('excerpt_more', 'runart_excerpt_more');

// Add body classes for language
function runart_body_classes($classes) {
    if (function_exists('pll_current_language')) {
        $classes[] = 'lang-' . pll_current_language();
    }
    return $classes;
}
add_filter('body_class', 'runart_body_classes');

// Remove Polylang generator meta
remove_action('wp_head', array('Polylang', 'html_lang'), 5);
/**
 * Fix Polylang root language redirect
 * Redirect /en/ to /en/home/ and /es/ to /es/inicio/
 * 
 * This fixes the issue where Polylang shows blog index at language root
 * instead of the actual home page.
 */
add_action('template_redirect', 'runart_fix_polylang_home_redirect', 1);
function runart_fix_polylang_home_redirect() {
    // Solo en front-end
    if (is_admin() || wp_doing_ajax() || wp_doing_cron()) {
        return;
    }

    $request_uri = trim($_SERVER['REQUEST_URI'], '?');
    
    // Redirección para /en/ raíz
    if (preg_match('#^/en/?(\?.*)?$#', $request_uri)) {
        // Solo redirigir si NO estamos ya en la home page correcta
        if (!is_page('home') || is_home()) {
            wp_safe_redirect(home_url('/en/home/'), 301);
            exit;
        }
    }
    
    // Redirección para /es/ raíz
    if (preg_match('#^/es/?(\?.*)?$#', $request_uri)) {
        // Solo redirigir si NO estamos ya en la home page correcta
        if (!is_page('inicio') || is_home()) {
            wp_safe_redirect(home_url('/es/inicio/'), 301);
            exit;
        }
    }
}

/**
 * Helper function to safely get RunMedia images with fallback
 * 
 * @param string $slug Image slug in RunMedia library
 * @param string $size Image size (e.g., 'w800', 'w2560')
 * @return array|false Array with 'url' and other metadata, or false if not available
 */
function runart_get_runmedia_image($slug, $size = 'w800') {
    // Check if RunMedia functions exist
    if (function_exists('runmedia_get_image_by_slug')) {
        return runmedia_get_image_by_slug($slug, $size);
    }
    
    // Fallback: return false to allow template to handle gracefully
    return false;
}
