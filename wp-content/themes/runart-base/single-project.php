<?php
/**
 * Single Project Template
 *
 * @package RUNArtFoundry
 */

get_header();
?>

<article id="post-<?php the_ID(); ?>" <?php post_class('single-project'); ?>>
    <header class="single-header">
        <div class="container">
            <h1 class="single-title"><?php the_title(); ?></h1>
            <?php if ( has_post_thumbnail() ) : ?>
                <div class="single-featured-image">
                    <?php the_post_thumbnail('large'); ?>
                </div>
            <?php endif; ?>
        </div>
    </header>

    <div class="container">
        <div class="single-content">
            <?php while ( have_posts() ) : the_post(); ?>
                <div class="entry-content">
                    <?php the_content(); ?>
                </div>
            <?php endwhile; ?>
        </div>

        <nav class="single-navigation">
            <a class="btn btn-secondary" href="<?php echo esc_url( get_post_type_archive_link('project') ); ?>">&larr; <?php _e('Volver a proyectos', 'runart'); ?></a>
        </nav>
    </div>
</article>

<?php get_footer();
