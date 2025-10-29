<?php
/**
 * Single Post Template
 *
 * @package RunArt_Base
 */

get_header(); ?>

<div class="single-post-page">
    <?php while (have_posts()) : the_post(); ?>
        <article id="post-<?php the_ID(); ?>" <?php post_class(); ?>>
            <!-- Post Header -->
            <header class="post-header">
                <?php if (has_post_thumbnail()) : ?>
                    <div class="post-featured-image">
                        <?php the_post_thumbnail('full'); ?>
                    </div>
                <?php endif; ?>
                
                <div class="container">
                    <div class="post-header-content">
                        <div class="post-meta">
                            <span class="post-date"><?php echo get_the_date(); ?></span>
                            <?php
                            $categories = get_the_category();
                            if ($categories) :
                                foreach ($categories as $category) : ?>
                                    <span class="post-category"><?php echo esc_html($category->name); ?></span>
                                <?php endforeach;
                            endif;
                            ?>
                        </div>
                        
                        <h1 class="post-title"><?php the_title(); ?></h1>
                        
                        <?php if (has_excerpt()) : ?>
                            <div class="post-excerpt"><?php the_excerpt(); ?></div>
                        <?php endif; ?>
                    </div>
                </div>
            </header>

            <!-- Post Content -->
            <div class="container">
                <div class="post-layout">
                    <main class="post-content">
                        <?php the_content(); ?>
                        
                        <?php
                        wp_link_pages(array(
                            'before' => '<div class="page-links">' . esc_html__('Pages:', 'runart'),
                            'after' => '</div>',
                        ));
                        ?>
                        
                        <!-- Post Tags -->
                        <?php
                        $tags = get_the_tags();
                        if ($tags) : ?>
                            <div class="post-tags">
                                <span class="tags-label"><?php esc_html_e('Tags:', 'runart'); ?></span>
                                <?php foreach ($tags as $tag) : ?>
                                    <a href="<?php echo get_tag_link($tag->term_id); ?>" class="post-tag">
                                        <?php echo esc_html($tag->name); ?>
                                    </a>
                                <?php endforeach; ?>
                            </div>
                        <?php endif; ?>
                    </main>

                    <aside class="post-sidebar">
                        <!-- Author Box -->
                        <div class="widget widget-author">
                            <h3 class="widget-title"><?php esc_html_e('About the Author', 'runart'); ?></h3>
                            <div class="author-info">
                                <?php echo get_avatar(get_the_author_meta('ID'), 80); ?>
                                <div class="author-details">
                                    <h4><?php the_author(); ?></h4>
                                    <?php if (get_the_author_meta('description')) : ?>
                                        <p><?php the_author_meta('description'); ?></p>
                                    <?php endif; ?>
                                </div>
                            </div>
                        </div>

                        <!-- Related Posts -->
                        <?php
                        $related_posts = get_posts(array(
                            'category__in' => wp_get_post_categories(get_the_ID()),
                            'numberposts' => 3,
                            'post__not_in' => array(get_the_ID())
                        ));
                        
                        if ($related_posts) : ?>
                            <div class="widget widget-related-posts">
                                <h3 class="widget-title"><?php esc_html_e('Related Articles', 'runart'); ?></h3>
                                <ul>
                                    <?php foreach ($related_posts as $post) : setup_postdata($post); ?>
                                        <li>
                                            <a href="<?php the_permalink(); ?>">
                                                <?php if (has_post_thumbnail()) : ?>
                                                    <?php the_post_thumbnail('thumbnail'); ?>
                                                <?php endif; ?>
                                                <span><?php the_title(); ?></span>
                                            </a>
                                        </li>
                                    <?php endforeach;
                                    wp_reset_postdata(); ?>
                                </ul>
                            </div>
                        <?php endif; ?>

                        <!-- CTA Widget -->
                        <div class="widget widget-cta">
                            <h3 class="widget-title"><?php esc_html_e('Start Your Project', 'runart'); ?></h3>
                            <p><?php esc_html_e('Transform your artistic vision into bronze reality.', 'runart'); ?></p>
                            <a href="<?php echo esc_url(get_permalink(get_page_by_path('contact'))); ?>" class="btn btn-primary">
                                <?php esc_html_e('Contact us', 'runart'); ?>
                            </a>
                        </div>
                    </aside>
                </div>
            </div>

            <!-- Post Navigation -->
            <div class="container">
                <nav class="post-navigation">
                    <?php
                    $prev_post = get_previous_post();
                    $next_post = get_next_post();
                    ?>
                    
                    <?php if ($prev_post) : ?>
                        <div class="nav-previous">
                            <a href="<?php echo get_permalink($prev_post); ?>">
                                <span class="nav-label">← <?php esc_html_e('Previous', 'runart'); ?></span>
                                <span class="nav-title"><?php echo get_the_title($prev_post); ?></span>
                            </a>
                        </div>
                    <?php endif; ?>
                    
                    <?php if ($next_post) : ?>
                        <div class="nav-next">
                            <a href="<?php echo get_permalink($next_post); ?>">
                                <span class="nav-label"><?php esc_html_e('Next', 'runart'); ?> →</span>
                                <span class="nav-title"><?php echo get_the_title($next_post); ?></span>
                            </a>
                        </div>
                    <?php endif; ?>
                </nav>
            </div>

        </article>
    <?php endwhile; ?>
</div><!-- .single-post-page -->

<?php get_footer(); ?>
