<?php
/**
 * Single Testimonial Template
 *
 * @package RUNArtFoundry
 */

get_header();

while (have_posts()) :
    the_post();
    
    // ACF Fields
    $client_role = get_field('client_role');
    $client_company = get_field('client_company');
    $project_name = get_field('project_name');
    $project_link = get_field('project_link');
    $rating = get_field('rating');
    $video_url = get_field('video_url');
    $key_quote = get_field('key_quote');
    ?>
    
    <article id="testimonial-<?php the_ID(); ?>" <?php post_class('single-testimonial'); ?>>
        
        <!-- Hero Section -->
        <header class="testimonial-hero">
            <div class="container">
                
                <!-- Client Info -->
                <div class="testimonial-hero-header">
                    <?php if (has_post_thumbnail()) : ?>
                    <div class="testimonial-hero-avatar">
                        <?php the_post_thumbnail('medium', array('class' => 'avatar-img')); ?>
                    </div>
                    <?php endif; ?>
                    
                    <div class="testimonial-hero-info">
                        <h1 class="testimonial-title"><?php the_title(); ?></h1>
                        <?php if ($client_role) : ?>
                        <p class="testimonial-role"><?php echo esc_html($client_role); ?></p>
                        <?php endif; ?>
                        <?php if ($client_company) : ?>
                        <p class="testimonial-company"><?php echo esc_html($client_company); ?></p>
                        <?php endif; ?>
                    </div>
                </div>
                
                <!-- Rating -->
                <?php if ($rating) : ?>
                <div class="testimonial-rating">
                    <?php for ($i = 0; $i < 5; $i++) : ?>
                        <span class="star <?php echo ($i < $rating) ? 'filled' : ''; ?>">⭐</span>
                    <?php endfor; ?>
                    <span class="rating-value"><?php echo esc_html($rating); ?>/5</span>
                </div>
                <?php endif; ?>
                
                <!-- Key Quote -->
                <?php if ($key_quote) : ?>
                <blockquote class="testimonial-key-quote">
                    "<?php echo esc_html($key_quote); ?>"
                </blockquote>
                <?php endif; ?>
                
            </div>
        </header>
        
        <div class="container">
            
            <!-- Video Section -->
            <?php if ($video_url) : ?>
            <section class="testimonial-video">
                <div class="video-wrapper">
                    <?php
                    // Extract YouTube ID
                    preg_match('/(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]+)/', $video_url, $matches);
                    $video_id = $matches[1] ?? '';
                    
                    if ($video_id) :
                    ?>
                    <iframe 
                        src="https://www.youtube.com/embed/<?php echo esc_attr($video_id); ?>" 
                        frameborder="0" 
                        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                        allowfullscreen
                        loading="lazy">
                    </iframe>
                    <?php else : ?>
                    <video controls>
                        <source src="<?php echo esc_url($video_url); ?>" type="video/mp4">
                        <?php _e('Tu navegador no soporta el elemento de video.', 'runart'); ?>
                    </video>
                    <?php endif; ?>
                </div>
            </section>
            <?php endif; ?>
            
            <!-- Main Content -->
            <div class="testimonial-content-wrap">
                
                <div class="testimonial-content-main">
                    
                    <!-- Full Testimonial Text -->
                    <section class="testimonial-content">
                        <?php the_content(); ?>
                    </section>
                    
                    <!-- Project Reference -->
                    <?php if ($project_name || $project_link) : ?>
                    <section class="testimonial-project">
                        <h2><?php _e('Proyecto Relacionado', 'runart'); ?></h2>
                        <?php if ($project_link) : ?>
                        <a href="<?php echo esc_url($project_link); ?>" class="project-link">
                            <?php echo esc_html($project_name ?: __('Ver proyecto', 'runart')); ?> →
                        </a>
                        <?php else : ?>
                        <p><?php echo esc_html($project_name); ?></p>
                        <?php endif; ?>
                    </section>
                    <?php endif; ?>
                    
                    <!-- Share Section -->
                    <section class="testimonial-share">
                        <h3><?php _e('Compartir testimonio', 'runart'); ?></h3>
                        <div class="share-buttons">
                            <a href="https://twitter.com/intent/tweet?url=<?php echo urlencode(get_permalink()); ?>&text=<?php echo urlencode(get_the_title()); ?>" 
                               target="_blank" 
                               rel="noopener"
                               class="btn btn-secondary btn-sm">
                                Twitter
                            </a>
                            <a href="https://www.facebook.com/sharer/sharer.php?u=<?php echo urlencode(get_permalink()); ?>" 
                               target="_blank" 
                               rel="noopener"
                               class="btn btn-secondary btn-sm">
                                Facebook
                            </a>
                            <a href="https://www.linkedin.com/shareArticle?mini=true&url=<?php echo urlencode(get_permalink()); ?>&title=<?php echo urlencode(get_the_title()); ?>" 
                               target="_blank" 
                               rel="noopener"
                               class="btn btn-secondary btn-sm">
                                LinkedIn
                            </a>
                        </div>
                    </section>
                    
                </div><!-- .testimonial-content-main -->
                
                <!-- Sidebar -->
                <aside class="testimonial-sidebar">
                    
                    <!-- CTA -->
                    <div class="testimonial-cta-card">
                        <h3><?php _e('¿Listo para tu proyecto?', 'runart'); ?></h3>
                        <p><?php _e('Trabajemos juntos en tu próxima obra de arte en bronce.', 'runart'); ?></p>
                        <a href="<?php echo esc_url( runart_get_contact_url_for_lang( function_exists('pll_current_language') ? pll_current_language() : 'en' ) ); ?>" class="btn btn-primary"><?php _e('Contactar', 'runart'); ?></a>
                    </div>
                    
                    <!-- Other Testimonials -->
                    <?php
                    $other_testimonials = get_posts(array(
                        'post_type' => 'testimonial',
                        'posts_per_page' => 3,
                        'post__not_in' => array(get_the_ID()),
                        'orderby' => 'rand',
                    ));
                    
                    if ($other_testimonials) :
                    ?>
                    <div class="related-testimonials">
                        <h3><?php _e('Otros Testimonios', 'runart'); ?></h3>
                        <ul>
                            <?php foreach ($other_testimonials as $testimonial_post) : ?>
                            <li>
                                <a href="<?php echo get_permalink($testimonial_post->ID); ?>">
                                    <?php echo get_the_title($testimonial_post->ID); ?>
                                </a>
                            </li>
                            <?php endforeach; ?>
                        </ul>
                    </div>
                    <?php endif; ?>
                    
                </aside>
                
            </div><!-- .testimonial-content-wrap -->
            
        </div><!-- .container -->
        
    </article>
    
    <?php
endwhile;

get_footer();
