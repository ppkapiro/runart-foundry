<?php
/**
 * Archive Testimonials Template with Fallback Query (Polylang-aware)
 *
 * @package RUNArtFoundry
 */

get_header();
?>

<div class="archive-testimonials">
    
    <!-- Archive Header -->
    <header class="archive-header">
        <div class="container">
            <h1 class="archive-title"><?php echo runart_t('Testimonios'); ?></h1>
            <p class="archive-description">
                <?php echo runart_t('Lo que dicen nuestros clientes sobre su experiencia trabajando con RUN Art Foundry en proyectos de fundición artística.'); ?>
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
                        <strong><?php echo runart_t('Proyecto:'); ?></strong> <?php echo esc_html($project_name); ?>
                    </div>
                    <?php endif; ?>
                    
                    <a href="<?php the_permalink(); ?>" class="btn btn-secondary btn-sm">
                        <?php echo runart_t('Leer completo'); ?> →
                    </a>
                    
                </article>
                
            <?php endwhile; ?>
        </div><!-- .testimonials-grid -->
        
        <!-- Pagination -->
        <nav class="archive-pagination">
            <?php
            the_posts_pagination(array(
                'mid_size' => 2,
                'prev_text' => runart_t('← Anterior'),
                'next_text' => runart_t('Siguiente →'),
            ));
            ?>
        </nav>
        
        <?php else : ?>
        
            <?php
            // Fallback query if main query is empty (caching or filter issues)
            $current_lang = function_exists('pll_current_language') ? pll_current_language('slug') : '';
            $args = array(
                'post_type'      => 'testimonial',
                'posts_per_page' => 12,
                'post_status'    => 'publish',
            );
            if ( ! empty( $current_lang ) ) {
                $args['lang'] = $current_lang; // Polylang filter
            }
            $fallback = new WP_Query( $args );
            if ( $fallback->have_posts() ) : ?>
                <div class="testimonials-grid">
                    <?php while ( $fallback->have_posts() ) : $fallback->the_post(); 
                        $client_role = get_field('client_role');
                        $project_name = get_field('project_name');
                        $rating = get_field('rating');
                    ?>
                        <article id="testimonial-<?php the_ID(); ?>" <?php post_class('testimonial-card'); ?>>
                            <div class="testimonial-card-header">
                                <?php if ( has_post_thumbnail() ) : ?>
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
                            <?php if ($rating) : ?>
                            <div class="testimonial-card-rating">
                                <?php for ($i = 0; $i < 5; $i++) : ?>
                                    <span class="star <?php echo ($i < $rating) ? 'filled' : ''; ?>">⭐</span>
                                <?php endfor; ?>
                            </div>
                            <?php endif; ?>
                            <div class="testimonial-card-content">
                                <?php echo has_excerpt() ? get_the_excerpt() : wp_trim_words( get_the_content(), 50, '...' ); ?>
                            </div>
                            <?php if ($project_name) : ?>
                            <div class="testimonial-card-project">
                                <strong><?php echo runart_t('Proyecto:'); ?></strong> <?php echo esc_html($project_name); ?>
                            </div>
                            <?php endif; ?>
                            <a href="<?php the_permalink(); ?>" class="btn btn-secondary btn-sm"><?php echo runart_t('Leer completo'); ?> →</a>
                        </article>
                    <?php endwhile; wp_reset_postdata(); ?>
                </div>
            <?php else : ?>
                <div class="no-testimonials-found"><p><?php echo runart_t('No se encontraron testimonios.'); ?></p></div>
            <?php endif; ?>
        
        <?php endif; ?>
        
    </div><!-- .container -->
    
    <!-- Call to Action -->
    <section class="archive-cta">
        <div class="container">
            <h2><?php echo runart_t('¿Listo para Crear tu Obra de Arte en Bronce?'); ?></h2>
            <p><?php echo runart_t('Únete a artistas de todo el mundo que confían en RUN Art Foundry para materializar sus visiones artísticas.'); ?></p>
            <a href="<?php echo esc_url( runart_get_contact_url_for_lang( function_exists('pll_current_language') ? pll_current_language() : 'en' ) ); ?>" class="btn btn-primary btn-lg"><?php echo runart_t('Iniciar proyecto'); ?></a>
            <a href="/projects/" class="btn btn-secondary btn-lg"><?php echo runart_t('Ver galería'); ?></a>
        </div>
    </section>
    
</div><!-- .archive-testimonials -->

<?php
get_footer();
