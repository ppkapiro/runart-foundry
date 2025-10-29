<?php
/**
 * RUNART FOUNDRY - STAGING FUNCTIONS.PHP UPDATE
 * Fase 2: Navegación & Switcher i18n - Integración completa Polylang
 * 
 * Este archivo contiene el functions.php completo para deployment en staging
 * Incluye todas las funciones de Fase 1 + nuevas integraciones Fase 2
 */

/**
 * GeneratePress child theme functions and definitions.
 *
 * Add your custom PHP in this file. 
 * Only edit this file if you have direct access to it on your server (to fix errors if they happen).
 */

// i18n Setup - RunArt Foundry Internationalization
function runart_foundry_i18n_setup() {
    load_theme_textdomain('runart-foundry', get_template_directory() . '/languages');
}
add_action('after_setup_theme', 'runart_foundry_i18n_setup');

// i18n Helper Functions (work with or without Polylang)
function runart_get_current_language() {
    return function_exists('pll_current_language') ? 
           pll_current_language('slug') : 'es'; // Default to Spanish
}

function runart_is_english() {
    return runart_get_current_language() === 'en';
}

function runart_get_home_url($lang = null) {
    return function_exists('pll_home_url') ? 
           pll_home_url($lang) : home_url('/');
}

// Bilingual Menu Registration (ready for Polylang)
function runart_register_bilingual_menus() {
    register_nav_menus([
        'primary-es' => __('Main Menu (Spanish)', 'runart-foundry'),
        'primary-en' => __('Main Menu (English)', 'runart-foundry'),
        'footer-es'  => __('Footer Menu (Spanish)', 'runart-foundry'),
        'footer-en'  => __('Footer Menu (English)', 'runart-foundry'),
    ]);
}
add_action('init', 'runart_register_bilingual_menus');

function generatepress_child_enqueue_scripts() {
	if ( is_rtl() ) {
		wp_enqueue_style( 'generatepress-rtl', trailingslashit( get_template_directory_uri() ) . 'rtl.css' );
	}
}
add_action( 'wp_enqueue_scripts', 'generatepress_child_enqueue_scripts', 100 );

// desactivar el editor Gutenberg de WordPress
add_filter('use_block_editor_for_post', '__return_false', 10);
add_filter('use_block_editor_for_post_type', '__return_false', 10);
add_filter( 'use_widgets_block_editor', '__return_false' );

function page_category() {
    register_taxonomy_for_object_type('post_tag', 'page');
    register_taxonomy_for_object_type('category', 'page');
}
add_action( 'init', 'page_category' );

// Soporte de Dashicons - poner en fichero de funciones
add_action( 'wp_enqueue_scripts', 'dcms_load_dashicons_front_end' );
function dcms_load_dashicons_front_end() {
        wp_enqueue_style( 'dashicons' );
}

// ===================================================================
// FASE 2: NAVEGACIÓN & SWITCHER i18n - Integración Polylang
// ===================================================================

// Funciones de Menús Bilingües con Polylang
function runart_get_current_menu_location($menu_type = 'primary') {
    $current_lang = runart_get_current_language();
    return $menu_type . '-' . $current_lang;
}

function runart_display_bilingual_menu($menu_type = 'primary') {
    $menu_location = runart_get_current_menu_location($menu_type);
    
    if (has_nav_menu($menu_location)) {
        wp_nav_menu([
            'theme_location' => $menu_location,
            'container'      => 'nav',
            'container_class'=> 'runart-nav-' . $menu_type . '-' . runart_get_current_language(),
            'menu_class'     => 'menu',
            'fallback_cb'    => false
        ]);
    } else {
        // Fallback to default WordPress menu
        wp_nav_menu([
            'theme_location' => $menu_type,
            'container'      => 'nav',
            'container_class'=> 'runart-nav-fallback',
            'menu_class'     => 'menu',
            'fallback_cb'    => 'wp_page_menu'
        ]);
    }
}

// Language Switcher - Integración con Polylang API
function runart_language_switcher($echo = true) {
    if (!function_exists('pll_the_languages')) {
        return '<!-- Polylang not available -->';
    }
    
    $output = '<div class="runart-language-switcher">';
    
    // Obtener idiomas disponibles de Polylang
    $languages = pll_the_languages([
        'echo' => false,
        'show_flags' => 1,
        'show_names' => 1,
        'hide_if_empty' => 1,
        'force_home' => 0,
        'hide_if_no_translation' => 0,
        'dropdown' => 0,
        'raw' => 1
    ]);
    
    if (is_array($languages)) {
        foreach ($languages as $lang) {
            $class = 'runart-lang-link';
            if ($lang['current_lang']) {
                $class .= ' current-lang';
            }
            
            $flag_img = '';
            if (!empty($lang['flag'])) {
                $flag_img = '<span class="lang-flag">' . $lang['flag'] . '</span>';
            }
            
            $output .= sprintf(
                '<a href="%s" class="%s" hreflang="%s" title="%s">%s<span class="lang-name">%s</span></a>',
                esc_url($lang['url']),
                esc_attr($class),
                esc_attr($lang['slug']),
                esc_attr('Switch to ' . $lang['name']),
                $flag_img,
                esc_html($lang['name'])
            );
        }
    }
    
    $output .= '</div>';
    
    if ($echo) {
        echo $output;
    } else {
        return $output;
    }
}

// CSS básico para Language Switcher
function runart_language_switcher_styles() {
    $css = '
    <style>
    .runart-language-switcher {
        display: flex;
        align-items: center;
        gap: 10px;
        margin: 0;
    }
    .runart-lang-link {
        display: flex;
        align-items: center;
        gap: 5px;
        text-decoration: none;
        padding: 5px 8px;
        border-radius: 3px;
        transition: background-color 0.2s ease;
    }
    .runart-lang-link:hover {
        background-color: rgba(0,0,0,0.1);
    }
    .runart-lang-link.current-lang {
        font-weight: bold;
        background-color: rgba(0,0,0,0.05);
    }
    .runart-lang-link .lang-flag img {
        width: 16px;
        height: 11px;
        border: 1px solid #ccc;
    }
    .runart-lang-link .lang-name {
        font-size: 14px;
    }
    </style>';
    
    echo $css;
}
add_action('wp_head', 'runart_language_switcher_styles');

// Shortcode para usar language switcher en templates
function runart_language_switcher_shortcode($atts) {
    return runart_language_switcher(false);
}
add_shortcode('runart_language_switcher', 'runart_language_switcher_shortcode');

// Hook para integrar en header GeneratePress
function runart_add_language_switcher_to_navigation() {
    if (function_exists('pll_the_languages')) {
        echo '<div style="margin-left: 20px;">';
        runart_language_switcher();
        echo '</div>';
    }
}
add_action('generate_inside_navigation', 'runart_add_language_switcher_to_navigation');

// Debug function para validar configuración
function runart_i18n_debug_info() {
    if (!current_user_can('administrator') || !isset($_GET['runart_debug'])) {
        return;
    }
    
    echo '<div style="background: #f0f0f0; padding: 15px; margin: 20px; border-left: 4px solid #0073aa;">';
    echo '<h3>RunArt Foundry i18n Debug Info</h3>';
    echo '<p><strong>Current Language:</strong> ' . runart_get_current_language() . '</p>';
    echo '<p><strong>Is English:</strong> ' . (runart_is_english() ? 'Yes' : 'No') . '</p>';
    echo '<p><strong>Home URL:</strong> ' . runart_get_home_url() . '</p>';
    echo '<p><strong>Polylang Active:</strong> ' . (function_exists('pll_current_language') ? 'Yes' : 'No') . '</p>';
    
    if (function_exists('pll_the_languages')) {
        echo '<p><strong>Available Languages:</strong></p>';
        echo '<div style="margin-left: 20px;">';
        pll_the_languages(['echo' => 1, 'show_flags' => 1, 'show_names' => 1]);
        echo '</div>';
    }
    
    echo '<p><strong>Registered Menu Locations:</strong></p>';
    echo '<ul>';
    foreach (get_registered_nav_menus() as $location => $description) {
        echo '<li>' . $location . ' - ' . $description . '</li>';
    }
    echo '</ul>';
    echo '</div>';
}
add_action('wp_footer', 'runart_i18n_debug_info');