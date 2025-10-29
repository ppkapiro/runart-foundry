<?php
/**
 * Single Service Template
 *
 * @package RUNArtFoundry
 */

get_header();

while (have_posts()) :
    the_post();
    
    // ACF Fields
    $service_process = get_field('service_process');
    $service_duration = get_field('service_duration');
    $service_includes = get_field('service_includes');
    $service_gallery = get_field('service_gallery');
    $service_faqs = get_field('service_faqs');
    ?>
    
    <article id="service-<?php the_ID(); ?>" <?php post_class('single-service'); ?>>
        
        <!-- Hero Section -->
        <header class="service-hero">
            <?php if (has_post_thumbnail()) : ?>
            <div class="service-hero-image">
                <?php the_post_thumbnail('full'); ?>
            </div>
            <?php endif; ?>
            
            <div class="service-hero-content container">
                <h1 class="service-title"><?php the_title(); ?></h1>
                <?php if (has_excerpt()) : ?>
                <p class="service-subtitle"><?php echo get_the_excerpt(); ?></p>
                <?php endif; ?>
            </div>
        </header>
        
        <div class="container">
            
            <!-- Main Content -->
            <div class="service-content-wrap">
                
                <div class="service-content-main">
                    
                    <!-- Description -->
                    <section class="service-description">
                        <?php the_content(); ?>
                    </section>
                    
                    <!-- Process -->
                    <?php if ($service_process) : ?>
                    <section class="service-process">
                        <h2><?php _e('Proceso', 'runart'); ?></h2>
                        <?php echo wp_kses_post($service_process); ?>
                    </section>
                    <?php endif; ?>
                    
                    <!-- Gallery -->
                    <?php if ($service_gallery) : ?>
                    <section class="service-gallery">
                        <h2><?php _e('Ejemplos', 'runart'); ?></h2>
                        <div class="service-gallery-grid">
                            <?php foreach ($service_gallery as $image) : ?>
                            <div class="service-gallery-item">
                                <img src="<?php echo esc_url($image['sizes']['large']); ?>" 
                                     alt="<?php echo esc_attr($image['alt']); ?>"
                                     loading="lazy">
                            </div>
                            <?php endforeach; ?>
                        </div>
                    </section>
                    <?php endif; ?>
                    
                    <!-- FAQs -->
                    <?php if ($service_faqs) : ?>
                    <section class="service-faqs">
                        <h2><?php _e('Preguntas Frecuentes', 'runart'); ?></h2>
                        <div class="faqs-list">
                            <?php foreach ($service_faqs as $index => $faq) : ?>
                            <details class="faq-item" <?php echo ($index === 0) ? 'open' : ''; ?>>
                                <summary class="faq-question">
                                    <?php echo esc_html($faq['question']); ?>
                                    <span class="faq-icon" aria-hidden="true">+</span>
                                </summary>
                                <div class="faq-answer">
                                    <?php echo wp_kses_post($faq['answer']); ?>
                                </div>
                            </details>
                            <?php endforeach; ?>
                        </div>
                    </section>
                    <?php endif; ?>
                    
                    <!-- CTA -->
                    <section class="service-cta">
                        <h2><?php _e('¿Interesado en este servicio?', 'runart'); ?></h2>
                        <p><?php _e('Contáctanos para recibir una cotización personalizada y asesoría técnica especializada.', 'runart'); ?></p>
                        <a href="<?php echo esc_url( runart_get_quote_url_for_lang( function_exists('pll_current_language') ? pll_current_language() : 'en' ) ); ?>" class="btn btn-primary btn-lg"><?php _e('Solicitar cotización', 'runart'); ?></a>
                    </section>
                    
                </div><!-- .service-content-main -->
                
                <!-- Sidebar -->
                <aside class="service-sidebar">
                    
                    <!-- Quick Info -->
                    <div class="service-info-card">
                        <h3><?php _e('Información', 'runart'); ?></h3>
                        
                        <?php if ($service_duration) : ?>
                        <div class="info-item">
                            <strong><?php _e('Duración:', 'runart'); ?></strong>
                            <span><?php echo esc_html($service_duration); ?></span>
                        </div>
                        <?php endif; ?>
                        
                        <?php if ($service_includes) : ?>
                        <div class="info-item">
                            <strong><?php _e('Incluye:', 'runart'); ?></strong>
                            <ul>
                                <?php foreach (explode("\n", $service_includes) as $item) : ?>
                                    <?php if (trim($item)) : ?>
                                    <li><?php echo esc_html(trim($item)); ?></li>
                                    <?php endif; ?>
                                <?php endforeach; ?>
                            </ul>
                        </div>
                        <?php endif; ?>
                    </div>
                    
                    <!-- Other Services -->
                    <?php
                    $other_services = get_posts(array(
                        'post_type' => 'service',
                        'posts_per_page' => 3,
                        'post__not_in' => array(get_the_ID()),
                        'orderby' => 'rand',
                    ));
                    
                    if ($other_services) :
                    ?>
                    <div class="related-services">
                        <h3><?php _e('Otros Servicios', 'runart'); ?></h3>
                        <ul>
                            <?php foreach ($other_services as $service_post) : ?>
                            <li>
                                <a href="<?php echo get_permalink($service_post->ID); ?>">
                                    <?php echo get_the_title($service_post->ID); ?>
                                </a>
                            </li>
                            <?php endforeach; ?>
                        </ul>
                    </div>
                    <?php endif; ?>
                    
                </aside>
                
            </div><!-- .service-content-wrap -->
            
        </div><!-- .container -->
        
    </article>
    
    <?php
endwhile;

get_footer();
