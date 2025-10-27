<?php
/**
 * Front Page Template
 * Renders the static front page content (the_content)
 *
 * @package RUNArtFoundry
 */

get_header();

if (have_posts()) :
    while (have_posts()) : the_post();
        ?>
        <article id="post-<?php the_ID(); ?>" <?php post_class('front-page'); ?>>
            <div class="front-page-content">
                <?php the_content(); ?>
            </div>
        </article>
        <?php
    endwhile;
else :
    ?>
    <article class="front-page-empty">
        <header>
            <h1 class="entry-title"><?php esc_html_e('Nothing Found', 'runart'); ?></h1>
        </header>
        <div class="entry-content">
            <p><?php esc_html_e('No content set for the front page yet.', 'runart'); ?></p>
        </div>
    </article>
    <?php
endif;

get_footer();
