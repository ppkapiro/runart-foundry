<?php
/**
 * Archive Services Template
 *
 * @package RUNArtFoundry
 */

get_header();
?>

<div class="archive-services">
    
    <!-- Archive Header -->
    <header class="archive-header">
        <div class="container">
            <h1 class="archive-title"><?php _e('Servicios', 'runart'); ?></h1>
            <p class="archive-description">
                <?php _e('Servicios especializados de fundición artística en bronce. Desde técnicas tradicionales hasta procesos contemporáneos para artistas, coleccionistas e instituciones.', 'runart'); ?>
            </p>
        </div>
    </header>
    
    <!-- Services Grid -->
    <div class="container">
        
        <?php if (have_posts()) : ?>
        
        <div class="services-grid">
            <?php
            while (have_posts()) :
                the_post();
                ?>
                
                <article id="service-<?php the_ID(); ?>" <?php post_class('service-card'); ?>>
                    
                    <!-- Featured Image -->
                    <?php if (has_post_thumbnail()) : ?>
                    <a href="<?php the_permalink(); ?>" class="service-card-image">
                        <?php the_post_thumbnail('medium_large', array('loading' => 'lazy')); ?>
                    </a>
                    <?php endif; ?>
                    
                    <!-- Card Content -->
                    <div class="service-card-content">
                        
                        <h2 class="service-card-title">
                            <a href="<?php the_permalink(); ?>"><?php the_title(); ?></a>
                        </h2>
                        
                        <?php if (has_excerpt()) : ?>
                        <div class="service-card-excerpt">
                            <?php the_excerpt(); ?>
                        </div>
                        <?php else : ?>
                        <div class="service-card-excerpt">
                            <?php echo wp_trim_words(get_the_content(), 30, '...'); ?>
                        </div>
                        <?php endif; ?>
                        
                        <a href="<?php the_permalink(); ?>" class="btn btn-secondary btn-sm">
                            <?php _e('Ver detalles', 'runart'); ?> →
                        </a>
                        
                    </div><!-- .service-card-content -->
                    
                </article>
                
            <?php endwhile; ?>
        </div><!-- .services-grid -->
        
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
        
        <!-- No Services Found -->
        <div class="no-services-found">
            <p><?php _e('No se encontraron servicios.', 'runart'); ?></p>
        </div>
        
        <?php endif; ?>
        
    </div><!-- .container -->
    
    <!-- Call to Action -->
    <section class="archive-cta">
        <div class="container">
            <h2><?php _e('¿Necesitas Asesoría Especializada?', 'runart'); ?></h2>
            <p><?php _e('Nuestro equipo de expertos está disponible para consultas técnicas, cotizaciones personalizadas y planificación de proyectos de fundición artística.', 'runart'); ?></p>
            <a href="<?php echo esc_url( runart_get_contact_url_for_lang( function_exists('pll_current_language') ? pll_current_language() : 'en' ) ); ?>" class="btn btn-primary btn-lg"><?php _e('Contactar ahora', 'runart'); ?></a>
            <a href="<?php echo esc_url( get_post_type_archive_link('project') ); ?>" class="btn btn-secondary btn-lg"><?php _e('Ver proyectos', 'runart'); ?></a>
        </div>
    </section>
    
</div><!-- .archive-services -->

<?php
get_footer();
