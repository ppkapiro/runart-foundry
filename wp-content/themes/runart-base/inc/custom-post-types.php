<?php
// Minimal override to ensure Testimonial archive exists
add_action('init', function() {
    if ( post_type_exists('testimonial') ) {
        global $wp_post_types;
        // Ensure has_archive is true and rewrite slug exists
        $wp_post_types['testimonial']->has_archive = 'testimonials';
        if ( isset($wp_post_types['testimonial']->rewrite) && is_array($wp_post_types['testimonial']->rewrite) ) {
            $wp_post_types['testimonial']->rewrite['slug'] = 'testimonials';
            $wp_post_types['testimonial']->rewrite['with_front'] = false;
        }
    }
}, 20);
