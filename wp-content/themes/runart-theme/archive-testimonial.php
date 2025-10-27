<?php
/**
 * Archive Testimonials Template
 *
 * @package RUNArtFoundry
 */

get_header();
?>

<div class="archive-testimonials">
    
    <!-- Archive Header -->
    <header class="archive-header">
        <div class="container">
            <h1 class="archive-title"><?php _e('Testimonios', 'runart'); ?></h1>
            <p class="archive-description">
                <?php _e('Lo que dicen nuestros clientes sobre su experiencia trabajando con RUN Art Foundry en proyectos de fundición artística.', 'runart'); ?>
            </p>
        </div>
    </header>
    
    <!-- Testimonials Grid -->
    <div class="container">
        
        <?php if (have_posts()) : ?>
        
        <div class="testimonials-grid">
            <?php
            while (have_posts()) :
                the_post();
                
                $client_role = get_field('client_role');
                $project_name = get_field('project_name');
                $rating = get_field('rating');
                ?>
                
                <article id="testimonial-<?php the_ID(); ?>" <?php post_class('testimonial-card'); ?>>
                    
                    <!-- Client Info -->
                    <div class="testimonial-card-header">
                        <?php if (has_post_thumbnail()) : ?>
                        <div class="testimonial-card-avatar">
                            <?php the_post_thumbnail('thumbnail', array('loading' => 'lazy')); ?>
                        </div>
                        <?php endif; ?>
                        
                        <div class="testimonial-card-client">
                            <h2 class="testimonial-card-title"><?php the_title(); ?></h2>
                            <?php if ($client_role) : ?>
                            <p class="testimonial-card-role"><?php echo esc_html($client_role); ?></p>
                            <?php endif; ?>
                        </div>
                    </div>
                    
                    <!-- Rating -->
                    <?php if ($rating) : ?>
                    <div class="testimonial-card-rating">
                        <?php for ($i = 0; $i < 5; $i++) : ?>
                            <span class="star <?php echo ($i < $rating) ? 'filled' : ''; ?>">⭐</span>
                        <?php endfor; ?>
                    </div>
                    <?php endif; ?>
                    
                    <!-- Content -->
                    <div class="testimonial-card-content">
                        <?php if (has_excerpt()) : ?>
                            <?php the_excerpt(); ?>
                        <?php else : ?>
                            <?php echo wp_trim_words(get_the_content(), 50, '...'); ?>
                        <?php endif; ?>
                    </div>
                    
                    <!-- Project Link -->
                    <?php if ($project_name) : ?>
                    <div class="testimonial-card-project">
                        <strong><?php _e('Proyecto:', 'runart'); ?></strong> <?php echo esc_html($project_name); ?>
                    </div>
                    <?php endif; ?>
                    
                    <a href="<?php the_permalink(); ?>" class="btn btn-secondary btn-sm">
                        <?php _e('Leer completo', 'runart'); ?> →
                    </a>
                    
                </article>
                
            <?php endwhile; ?>
        </div><!-- .testimonials-grid -->
        
        <!-- Pagination -->
        <nav class="archive-pagination">
            <?php
            the_posts_pagination(array(
                'mid_size' => 2,
                'prev_text' => __('← Anterior', 'runart'),
                'next_text' => __('Siguiente →', 'runart'),
            ));
            ?>
        </nav>
        
        <?php else : ?>
        
        <!-- No Testimonials Found -->
        <div class="no-testimonials-found">
            <p><?php _e('No se encontraron testimonios.', 'runart'); ?></p>
        </div>
        
        <?php endif; ?>
        
    </div><!-- .container -->
    
    <!-- Call to Action -->
    <section class="archive-cta">
        <div class="container">
            <h2><?php _e('¿Listo para Crear tu Obra de Arte en Bronce?', 'runart'); ?></h2>
            <p><?php _e('Únete a artistas de todo el mundo que confían en RUN Art Foundry para materializar sus visiones artísticas.', 'runart'); ?></p>
            <a href="<?php echo esc_url( runart_get_contact_url_for_lang( function_exists('pll_current_language') ? pll_current_language() : 'en' ) ); ?>" class="btn btn-primary btn-lg"><?php _e('Iniciar proyecto', 'runart'); ?></a>
            <a href="<?php echo esc_url( get_post_type_archive_link('project') ); ?>" class="btn btn-secondary btn-lg"><?php _e('Ver galería', 'runart'); ?></a>
        </div>
    </section>
    
</div><!-- .archive-testimonials -->

<?php
get_footer();
