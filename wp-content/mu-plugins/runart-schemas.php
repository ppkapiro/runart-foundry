<?php
/**
 * Plugin Name: RUNArt Schemas JSON-LD
 * Description: Añade schemas estructurados para SEO (Organization, FAQPage, VideoObject, BreadcrumbList)
 * Version: 1.0.0
 * Author: RUN Art Foundry
 */

if (!defined('ABSPATH')) exit;

/**
 * Organization Schema (Global - en footer)
 */
function runart_organization_schema() {
    $schema = [
        '@context' => 'https://schema.org',
        '@type' => 'Organization',
        'name' => 'R.U.N. Art Foundry',
        'alternateName' => 'RunArt Foundry',
        'url' => home_url('/'),
        'logo' => home_url('/wp-content/themes/runart-base/assets/images/logo.png'),
        'description' => 'Fundición artística especializada en bronce con más de 40 años de experiencia. Técnicas tradicionales y tecnología contemporánea.',
        'foundingDate' => '1980',
        'address' => [
            '@type' => 'PostalAddress',
            'addressCountry' => 'CU',
            'addressLocality' => 'La Habana',
        ],
        'contactPoint' => [
            '@type' => 'ContactPoint',
            'contactType' => 'customer service',
            'email' => 'info@runartfoundry.com',
            'availableLanguage' => ['Spanish', 'English']
        ],
        'sameAs' => [
            'https://www.instagram.com/runartfoundry',
            'https://www.facebook.com/runartfoundry',
            'https://www.youtube.com/@runartfoundry',
            'https://www.linkedin.com/company/runartfoundry'
        ]
    ];
    
    echo '<script type="application/ld+json">' . json_encode($schema, JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT) . '</script>' . "\n";
}
add_action('wp_footer', 'runart_organization_schema');

/**
 * FAQPage Schema para Services
 */
function runart_service_faq_schema() {
    if (!is_singular('service')) return;
    
    global $post;
    
    // Obtener FAQs de ACF (asumiendo que hay un grupo de campos repetidor 'faqs')
    if (!function_exists('get_field')) return;
    
    $faqs = get_field('faqs', $post->ID);
    if (!$faqs || !is_array($faqs)) return;
    
    $questions = [];
    foreach ($faqs as $faq) {
        if (empty($faq['question']) || empty($faq['answer'])) continue;
        
        $questions[] = [
            '@type' => 'Question',
            'name' => wp_strip_all_tags($faq['question']),
            'acceptedAnswer' => [
                '@type' => 'Answer',
                'text' => wp_strip_all_tags($faq['answer'])
            ]
        ];
    }
    
    if (empty($questions)) return;
    
    $schema = [
        '@context' => 'https://schema.org',
        '@type' => 'FAQPage',
        'mainEntity' => $questions
    ];
    
    echo '<script type="application/ld+json">' . json_encode($schema, JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT) . '</script>' . "\n";
}
add_action('wp_footer', 'runart_service_faq_schema');

/**
 * FAQPage Schema para Blog Posts
 */
function runart_post_faq_schema() {
    if (!is_single() || get_post_type() !== 'post') return;
    
    global $post;
    
    if (!function_exists('get_field')) return;
    
    $faqs = get_field('faqs', $post->ID);
    if (!$faqs || !is_array($faqs)) return;
    
    $questions = [];
    foreach ($faqs as $faq) {
        if (empty($faq['question']) || empty($faq['answer'])) continue;
        
        $questions[] = [
            '@type' => 'Question',
            'name' => wp_strip_all_tags($faq['question']),
            'acceptedAnswer' => [
                '@type' => 'Answer',
                'text' => wp_strip_all_tags($faq['answer'])
            ]
        ];
    }
    
    if (empty($questions)) return;
    
    $schema = [
        '@context' => 'https://schema.org',
        '@type' => 'FAQPage',
        'mainEntity' => $questions
    ];
    
    echo '<script type="application/ld+json">' . json_encode($schema, JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT) . '</script>' . "\n";
}
add_action('wp_footer', 'runart_post_faq_schema');

/**
 * VideoObject Schema para Testimonials con video
 */
function runart_testimonial_video_schema() {
    if (!is_singular('testimonial')) return;
    
    global $post;
    
    if (!function_exists('get_field')) return;
    
    $video_url = get_field('video_url', $post->ID);
    if (empty($video_url)) return;
    
    // Extraer ID de YouTube si es URL de YouTube
    $video_id = null;
    if (preg_match('/(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\s]+)/', $video_url, $matches)) {
        $video_id = $matches[1];
    }
    
    if (!$video_id) return;
    
    $schema = [
        '@context' => 'https://schema.org',
        '@type' => 'VideoObject',
        'name' => get_the_title(),
        'description' => get_the_excerpt() ?: wp_trim_words(get_the_content(), 30),
        'thumbnailUrl' => 'https://img.youtube.com/vi/' . $video_id . '/hqdefault.jpg',
        'uploadDate' => get_the_date('c'),
        'contentUrl' => 'https://www.youtube.com/watch?v=' . $video_id,
        'embedUrl' => 'https://www.youtube.com/embed/' . $video_id
    ];
    
    // Añadir autor si está disponible
    $artist_name = get_field('artist_name', $post->ID);
    if ($artist_name) {
        $schema['author'] = [
            '@type' => 'Person',
            'name' => $artist_name
        ];
    }
    
    echo '<script type="application/ld+json">' . json_encode($schema, JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT) . '</script>' . "\n";
}
add_action('wp_footer', 'runart_testimonial_video_schema');

/**
 * BreadcrumbList Schema
 */
function runart_breadcrumb_schema() {
    if (is_front_page() || is_home()) return;
    
    $items = [
        [
            '@type' => 'ListItem',
            'position' => 1,
            'name' => 'Home',
            'item' => home_url('/')
        ]
    ];
    
    $position = 2;
    
    // Archive pages
    if (is_post_type_archive()) {
        $post_type = get_post_type();
        $post_type_obj = get_post_type_object($post_type);
        
        $items[] = [
            '@type' => 'ListItem',
            'position' => $position,
            'name' => $post_type_obj->labels->name,
            'item' => get_post_type_archive_link($post_type)
        ];
    }
    // Single posts/CPTs
    elseif (is_singular()) {
        global $post;
        $post_type = get_post_type();
        
        // Add archive link if CPT
        if ($post_type !== 'post' && $post_type !== 'page') {
            $post_type_obj = get_post_type_object($post_type);
            $items[] = [
                '@type' => 'ListItem',
                'position' => $position++,
                'name' => $post_type_obj->labels->name,
                'item' => get_post_type_archive_link($post_type)
            ];
        }
        
        // Add current page
        $items[] = [
            '@type' => 'ListItem',
            'position' => $position,
            'name' => get_the_title(),
            'item' => get_permalink()
        ];
    }
    
    if (count($items) <= 1) return;
    
    $schema = [
        '@context' => 'https://schema.org',
        '@type' => 'BreadcrumbList',
        'itemListElement' => $items
    ];
    
    echo '<script type="application/ld+json">' . json_encode($schema, JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT) . '</script>' . "\n";
}
add_action('wp_footer', 'runart_breadcrumb_schema');
