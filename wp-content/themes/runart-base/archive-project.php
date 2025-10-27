<?php
/**
 * Archive Projects Template with Fallback Query (Polylang-aware)
 *
 * @package RUNArtFoundry
 */

get_header();
?>

<div class="archive-projects">
    <!-- Archive Header -->
    <header class="archive-header">
        <div class="container">
            <h1 class="archive-title"><?php _e('Proyectos', 'runart'); ?></h1>
            <p class="archive-description">
                <?php _e('Explora nuestra galería de proyectos de fundición artística en bronce. Desde esculturas figurativas hasta obras monumentales para espacios públicos.', 'runart'); ?>
            </p>
        </div>
    </header>

    <!-- Projects Grid -->
    <div class="container">
        <?php if ( have_posts() ) : ?>
            <div class="projects-grid">
                <?php while ( have_posts() ) : the_post(); ?>
                    <article id="project-<?php the_ID(); ?>" <?php post_class('project-card'); ?>>
                        <?php if ( has_post_thumbnail() ) : ?>
                            <a href="<?php the_permalink(); ?>" class="project-card-image">
                                <?php the_post_thumbnail('medium_large', array('loading' => 'lazy')); ?>
                            </a>
                        <?php endif; ?>

                        <div class="project-card-content">
                            <h2 class="project-card-title">
                                <a href="<?php the_permalink(); ?>"><?php the_title(); ?></a>
                            </h2>

                            <?php if ( has_excerpt() ) : ?>
                                <div class="project-card-excerpt"><?php the_excerpt(); ?></div>
                            <?php else : ?>
                                <div class="project-card-excerpt"><?php echo wp_trim_words( get_the_content(), 30, '...' ); ?></div>
                            <?php endif; ?>

                            <a href="<?php the_permalink(); ?>" class="btn btn-secondary btn-sm"><?php _e('Ver proyecto', 'runart'); ?> →</a>
                        </div>
                    </article>
                <?php endwhile; ?>
            </div>

            <nav class="archive-pagination">
                <?php the_posts_pagination(array(
                    'mid_size'  => 2,
                    'prev_text' => __('← Anterior', 'runart'),
                    'next_text' => __('Siguiente →', 'runart'),
                )); ?>
            </nav>
        <?php else : ?>
            <?php
            // Fallback query if main query is empty (caching or filter issues)
            $current_lang = function_exists('pll_current_language') ? pll_current_language('slug') : '';
            $args = array(
                'post_type'      => 'project',
                'posts_per_page' => 12,
                'post_status'    => 'publish',
            );
            if ( ! empty( $current_lang ) ) {
                $args['lang'] = $current_lang; // Polylang filter
            }
            $fallback = new WP_Query( $args );
            if ( $fallback->have_posts() ) : ?>
                <div class="projects-grid">
                    <?php while ( $fallback->have_posts() ) : $fallback->the_post(); ?>
                        <article id="project-<?php the_ID(); ?>" <?php post_class('project-card'); ?>>
                            <?php if ( has_post_thumbnail() ) : ?>
                                <a href="<?php the_permalink(); ?>" class="project-card-image">
                                    <?php the_post_thumbnail('medium_large', array('loading' => 'lazy')); ?>
                                </a>
                            <?php endif; ?>
                            <div class="project-card-content">
                                <h2 class="project-card-title"><a href="<?php the_permalink(); ?>"><?php the_title(); ?></a></h2>
                                <div class="project-card-excerpt"><?php echo has_excerpt() ? get_the_excerpt() : wp_trim_words( get_the_content(), 30, '...' ); ?></div>
                                <a href="<?php the_permalink(); ?>" class="btn btn-secondary btn-sm"><?php _e('Ver proyecto', 'runart'); ?> →</a>
                            </div>
                        </article>
                    <?php endwhile; wp_reset_postdata(); ?>
                </div>
            <?php else : ?>
                <div class="no-projects-found"><p><?php _e('No se encontraron proyectos.', 'runart'); ?></p></div>
            <?php endif; ?>
        <?php endif; ?>
    </div>

    <section class="archive-cta">
        <div class="container">
            <h2><?php _e('¿Listo para tu Proyecto de Fundición?', 'runart'); ?></h2>
            <p><?php _e('Conversemos sobre cómo podemos materializar tu visión artística en bronce de alta calidad.', 'runart'); ?></p>
            <a href="<?php echo esc_url( function_exists('runart_get_contact_url_for_lang') ? runart_get_contact_url_for_lang( function_exists('pll_current_language') ? pll_current_language() : 'en' ) : home_url('/contact/') ); ?>" class="btn btn-primary btn-lg"><?php _e('Contactar ahora', 'runart'); ?></a>
            <a href="<?php echo esc_url( get_post_type_archive_link('service') ); ?>" class="btn btn-secondary btn-lg"><?php _e('Ver servicios', 'runart'); ?></a>
        </div>
    </section>
</div>

<?php get_footer();