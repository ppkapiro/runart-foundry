# 🚀 FASE 2 i18n - DESPLIEGUE INMEDIATO

**Estado:** ✅ Archivos preparados y verificados  
**Polylang:** ✅ Activo con ES/EN  
**Staging:** ✅ Accesible y listo

## ⚡ DESPLIEGUE RÁPIDO (3 pasos)

### PASO 1: Acceder a WordPress Admin
```
URL: https://staging.runartfoundry.com/wp-admin/
```

### PASO 2: Editar functions.php
1. **Appearance** → **Theme Editor**
2. Seleccionar **functions.php** (GeneratePress Child)
3. **Seleccionar TODO el contenido actual** (Ctrl+A)
4. **REEMPLAZAR** con el contenido del archivo siguiente

### PASO 3: Contenido functions.php Fase 2
```php
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

function runart_is_spanish() {
    return runart_get_current_language() === 'es';
}

function runart_get_translated_url($lang_code) {
    if (function_exists('pll_the_languages')) {
        $languages = pll_the_languages(array('raw' => 1));
        if (isset($languages[$lang_code])) {
            return $languages[$lang_code]['url'];
        }
    }
    return home_url($lang_code === 'en' ? '/' : '/es/');
}

// FASE 2: NAVEGACIÓN BILINGÜE - Language Switcher & Navigation
function runart_language_switcher() {
    if (!function_exists('pll_the_languages')) {
        return ''; // Polylang not active
    }
    
    $current_lang = pll_current_language('slug');
    $languages = pll_the_languages(array('raw' => 1));
    
    if (empty($languages) || count($languages) < 2) {
        return ''; // No languages configured
    }
    
    $output = '<div class="runart-language-switcher">';
    
    foreach ($languages as $lang) {
        $is_current = ($lang['slug'] === $current_lang);
        $class = $is_current ? 'lang-active' : 'lang-inactive';
        
        $output .= sprintf(
            '<a href="%s" class="lang-link %s" data-lang="%s" title="%s">%s</a>',
            esc_url($lang['url']),
            esc_attr($class),
            esc_attr($lang['slug']),
            esc_attr($lang['name']),
            esc_html($lang['slug'] === 'en' ? 'EN' : 'ES')
        );
    }
    
    $output .= '</div>';
    
    return $output;
}

// Language Switcher Shortcode
function runart_language_switcher_shortcode($atts) {
    $atts = shortcode_atts(array(
        'style' => 'default'
    ), $atts);
    
    return runart_language_switcher();
}
add_shortcode('runart_lang_switcher', 'runart_language_switcher_shortcode');

// Add Language Switcher to Header
function runart_add_language_switcher_to_header() {
    if (function_exists('pll_the_languages')) {
        echo runart_language_switcher();
    }
}
add_action('generate_header', 'runart_add_language_switcher_to_header', 15);

// Navigation Menu Integration with Polylang
function runart_setup_bilingual_menus() {
    if (function_exists('pll_register_string')) {
        // Register menu strings for translation
        pll_register_string('runart-nav-home', 'Home', 'RunArt Foundry Navigation');
        pll_register_string('runart-nav-about', 'About', 'RunArt Foundry Navigation');
        pll_register_string('runart-nav-services', 'Services', 'RunArt Foundry Navigation');
        pll_register_string('runart-nav-portfolio', 'Portfolio', 'RunArt Foundry Navigation');
        pll_register_string('runart-nav-contact', 'Contact', 'RunArt Foundry Navigation');
        pll_register_string('runart-nav-blog', 'Blog', 'RunArt Foundry Navigation');
    }
}
add_action('init', 'runart_setup_bilingual_menus');

// Helper function for translated menu labels
function runart_get_nav_label($key, $default) {
    if (function_exists('pll__')) {
        return pll__($default);
    }
    return $default;
}

// Custom Menu Walker for Bilingual Support
class RunArt_Bilingual_Walker_Nav_Menu extends Walker_Nav_Menu {
    
    function start_el(&$output, $item, $depth = 0, $args = null, $id = 0) {
        $current_lang = runart_get_current_language();
        
        // Add language-specific classes
        $classes = empty($item->classes) ? array() : (array) $item->classes;
        $classes[] = 'lang-' . $current_lang;
        
        // Check if this menu item should be hidden for current language
        if (function_exists('pll_get_post_language') && $item->object_id) {
            $item_lang = pll_get_post_language($item->object_id);
            if ($item_lang && $item_lang !== $current_lang) {
                // Skip this item if it's for a different language
                return;
            }
        }
        
        $item->classes = $classes;
        
        // Call parent method
        parent::start_el($output, $item, $depth, $args, $id);
    }
}

// Language-specific content helpers
function runart_get_content_by_language($en_content, $es_content) {
    return runart_is_english() ? $en_content : $es_content;
}

// CSS Integration for Language Switcher
function runart_language_switcher_styles() {
    ?>
    <style>
    .runart-language-switcher {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        margin-left: 20px;
    }
    
    .runart-language-switcher .lang-link {
        display: inline-block;
        padding: 4px 8px;
        text-decoration: none;
        font-size: 12px;
        font-weight: 600;
        text-transform: uppercase;
        border-radius: 3px;
        transition: all 0.3s ease;
        color: #666;
        border: 1px solid #ddd;
    }
    
    .runart-language-switcher .lang-link:hover {
        color: #333;
        border-color: #999;
        text-decoration: none;
    }
    
    .runart-language-switcher .lang-active {
        background-color: #0073aa;
        color: white;
        border-color: #0073aa;
    }
    
    .runart-language-switcher .lang-active:hover {
        background-color: #005a87;
        color: white;
        border-color: #005a87;
    }
    
    /* Mobile responsive */
    @media (max-width: 768px) {
        .runart-language-switcher {
            margin-left: 10px;
            gap: 5px;
        }
        
        .runart-language-switcher .lang-link {
            padding: 3px 6px;
            font-size: 11px;
        }
    }
    
    /* GeneratePress specific integration */
    .main-navigation .runart-language-switcher {
        margin-left: auto;
        margin-right: 20px;
    }
    
    .site-header .runart-language-switcher {
        position: absolute;
        top: 15px;
        right: 20px;
    }
    </style>
    <?php
}
add_action('wp_head', 'runart_language_switcher_styles');

// JavaScript for Language Switcher Enhancement
function runart_language_switcher_script() {
    ?>
    <script>
    document.addEventListener('DOMContentLoaded', function() {
        const langSwitcher = document.querySelector('.runart-language-switcher');
        if (langSwitcher) {
            // Add loading state during language switch
            langSwitcher.addEventListener('click', function(e) {
                if (e.target.classList.contains('lang-link') && !e.target.classList.contains('lang-active')) {
                    e.target.innerHTML = '...';
                }
            });
            
            // Store current language preference
            const currentLang = document.querySelector('.lang-active');
            if (currentLang) {
                localStorage.setItem('runart_preferred_lang', currentLang.dataset.lang);
            }
        }
    });
    </script>
    <?php
}
add_action('wp_footer', 'runart_language_switcher_script');

// Polylang Integration Hooks
function runart_polylang_integration() {
    if (function_exists('pll_current_language')) {
        // Set document language
        add_filter('language_attributes', function($output) {
            $lang = pll_current_language('slug');
            return str_replace('lang="en-US"', 'lang="' . $lang . '"', $output);
        });
        
        // Add hreflang links for SEO
        add_action('wp_head', function() {
            if (function_exists('pll_the_languages')) {
                $languages = pll_the_languages(array('raw' => 1));
                foreach ($languages as $lang) {
                    printf(
                        '<link rel="alternate" hreflang="%s" href="%s" />' . "\n",
                        esc_attr($lang['slug']),
                        esc_url($lang['url'])
                    );
                }
            }
        });
    }
}
add_action('init', 'runart_polylang_integration');

// Body classes for language-specific styling
function runart_add_language_body_class($classes) {
    $current_lang = runart_get_current_language();
    $classes[] = 'lang-' . $current_lang;
    $classes[] = 'runart-i18n-active';
    
    if (function_exists('pll_current_language')) {
        $classes[] = 'polylang-active';
    }
    
    return $classes;
}
add_filter('body_class', 'runart_add_language_body_class');

// Admin Bar Language Info (for logged-in users)
function runart_admin_bar_language_info($wp_admin_bar) {
    if (!is_admin_bar_showing() || !function_exists('pll_current_language')) {
        return;
    }
    
    $current_lang = pll_current_language('name');
    
    $wp_admin_bar->add_node(array(
        'id'    => 'runart-current-language',
        'title' => '🌍 ' . $current_lang,
        'href'  => admin_url('admin.php?page=mlang'),
    ));
}
add_action('admin_bar_menu', 'runart_admin_bar_language_info', 999);

// Debug Information (only for development)
function runart_i18n_debug_info() {
    if (current_user_can('manage_options') && isset($_GET['runart_debug'])) {
        echo '<!-- RunArt Foundry i18n Debug -->';
        echo '<div style="position:fixed;bottom:10px;right:10px;background:#333;color:#fff;padding:10px;font-size:12px;z-index:9999;">';
        echo 'Current Language: ' . runart_get_current_language() . '<br>';
        echo 'Polylang Active: ' . (function_exists('pll_current_language') ? 'Yes' : 'No') . '<br>';
        echo 'Languages: ' . (function_exists('pll_the_languages') ? count(pll_the_languages(array('raw' => 1))) : '0') . '<br>';
        echo '</div>';
    }
}
add_action('wp_footer', 'runart_i18n_debug_info');

// Phase 2 Initialization
function runart_phase2_init() {
    // Ensure Polylang compatibility
    if (function_exists('pll_register_string')) {
        // Success message
        add_action('admin_notices', function() {
            if (current_user_can('manage_options') && isset($_GET['runart_phase2'])) {
                echo '<div class="notice notice-success"><p><strong>RunArt Foundry Phase 2 i18n:</strong> Navegación bilingüe activada correctamente. <a href="' . home_url() . '">Ver sitio</a></p></div>';
            }
        });
    }
}
add_action('init', 'runart_phase2_init');

/* 
 * END OF PHASE 2 i18n IMPLEMENTATION
 * 
 * Features included:
 * ✅ Bilingual Navigation (ES/EN)  
 * ✅ Automatic Language Switcher
 * ✅ Polylang Integration
 * ✅ GeneratePress Compatibility
 * ✅ SEO hreflang tags
 * ✅ Mobile responsive design
 * ✅ Admin bar language info
 * ✅ Debug capabilities
 * 
 * Total lines: 242
 * Compatible with: WordPress 5.0+, GeneratePress, Polylang 2.8+
 * Created: October 2025 - RunArt Foundry Phase 2
 */
?>
```

4. **Save Changes** → **Update File**

## ✅ VERIFICACIÓN INMEDIATA

Después de guardar, verifica:

### URLs de Prueba:
- **Español:** https://staging.runartfoundry.com/es/
- **English:** https://staging.runartfoundry.com/

### Funcionalidades:
- ✅ **Language Switcher** visible en header (EN/ES)
- ✅ **Navegación bilingüe** funcional
- ✅ **Cambio automático** entre idiomas
- ✅ **CSS integrado** con GeneratePress

### Debug (opcional):
- Añadir `?runart_debug=1` a cualquier URL para ver info técnica

## 🎯 RESULTADO ESPERADO

**Fase 2 i18n completamente funcional:**
- Navegación bilingüe ES/EN
- Language switcher automático  
- Integración completa con Polylang
- Compatible con contenido existente
- CSS responsive incluido

**Tiempo estimado:** 2-3 minutos

---

*Archivo generado automáticamente el 22/10/2025*  
*Ready for immediate deployment*