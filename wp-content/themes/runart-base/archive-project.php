<?php
/**
 * Archive Projects Template with Fallback Query (Polylang-aware)
 *
 * @package RUNArtFoundry
 */

get_header();

// Detect language (archives): Polylang current language, fallback to locale
$current_lang = function_exists('pll_current_language') ? pll_current_language() : 'en';
if ( ! in_array( $current_lang, array('en','es'), true ) ) {
    $loc = function_exists('get_locale') ? get_locale() : '';
    if ( is_string($loc) && stripos($loc, 'es') === 0 ) {
        $current_lang = 'es';
    } else {
        $current_lang = 'en';
    }
}
// Last-resort override by URL prefix
if ( isset($_SERVER['REQUEST_URI']) ) {
    $uri = $_SERVER['REQUEST_URI'];
    if ( strpos($uri, '/es/') === 0 || $uri === '/es/' ) {
        $current_lang = 'es';
    } elseif ( strpos($uri, '/en/') === 0 || $uri === '/en/' ) {
        $current_lang = 'en';
    }
}

// Bilingual strings
$t = array(
    'en' => array(
        'title' => 'Projects',
        'desc' => 'Explore our gallery of fine art bronze casting projects. From figurative sculptures to monumental works for public spaces.',
        'view' => 'View project',
        'prev' => '← Previous',
        'next' => 'Next →',
        'none' => 'No projects found.',
        'cta_title' => 'Ready for your Casting Project?',
        'cta_desc' => 'Let’s discuss how we can bring your artistic vision to life in high‑quality bronze.',
        'cta_contact' => 'Contact now',
        'cta_services' => 'View services',
    ),
    'es' => array(
        'title' => 'Proyectos',
        'desc' => 'Explora nuestra galería de proyectos de fundición artística en bronce. Desde esculturas figurativas hasta obras monumentales para espacios públicos.',
        'view' => 'Ver proyecto',
        'prev' => '← Anterior',
        'next' => 'Siguiente →',
        'none' => 'No se encontraron proyectos.',
        'cta_title' => '¿Listo para tu Proyecto de Fundición?',
        'cta_desc' => 'Conversemos sobre cómo podemos materializar tu visión artística en bronce de alta calidad.',
        'cta_contact' => 'Contactar ahora',
        'cta_services' => 'Ver servicios',
    ),
);
$c = isset($t[$current_lang]) ? $t[$current_lang] : $t['en'];
?>

<div class="archive-projects">
    <!-- Archive Header -->
    <header class="archive-header">
        <div class="container">
            <h1 class="archive-title"><?php echo esc_html($c['title']); ?></h1>
            <p class="archive-description"><?php echo esc_html($c['desc']); ?></p>
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

                            <a href="<?php the_permalink(); ?>" class="btn btn-secondary btn-sm"><?php echo esc_html($c['view']); ?> →</a>
                        </div>
                    </article>
                <?php endwhile; ?>
            </div>

            <nav class="archive-pagination">
                <?php the_posts_pagination(array(
                    'mid_size'  => 2,
                    'prev_text' => $c['prev'],
                    'next_text' => $c['next'],
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
                                <a href="<?php the_permalink(); ?>" class="btn btn-secondary btn-sm"><?php echo esc_html($c['view']); ?> →</a>
                            </div>
                        </article>
                    <?php endwhile; wp_reset_postdata(); ?>
                </div>
            <?php else : ?>
                <div class="no-projects-found"><p><?php echo esc_html($c['none']); ?></p></div>
            <?php endif; ?>
        <?php endif; ?>
    </div>

    <section class="archive-cta">
        <div class="container">
            <h2><?php echo esc_html($c['cta_title']); ?></h2>
            <p><?php echo esc_html($c['cta_desc']); ?></p>
            <a href="<?php echo esc_url( function_exists('runart_get_contact_url_for_lang') ? runart_get_contact_url_for_lang( $current_lang ) : home_url('/contact/') ); ?>" class="btn btn-primary btn-lg"><?php echo esc_html($c['cta_contact']); ?></a>
            <a href="<?php echo esc_url( get_post_type_archive_link('service') ); ?>" class="btn btn-secondary btn-lg"><?php echo esc_html($c['cta_services']); ?></a>
        </div>
    </section>
</div>

<?php get_footer();