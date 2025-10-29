<?php
/**
 * Main Blog Index Template (Polylang-aware, bilingual)
 *
 * @package RunArt_Base
 */

get_header();

// Detect current language (for blog index, prefer global current language)
$current_lang = function_exists('pll_current_language') ? pll_current_language() : 'en';

// Bilingual UI strings
$t = array(
    'en' => array(
        'title' => 'Technical Blog',
        'subtitle' => 'Insights, processes, and expertise in art casting',
        'read_more' => 'Read more',
        'prev' => '← Previous',
        'next' => 'Next →',
        'no_posts_title' => 'No posts found',
        'no_posts_body' => 'Stay tuned for upcoming technical articles about our casting processes.',
        'sidebar_categories' => 'Categories',
        'sidebar_recent' => 'Recent Posts',
        'cta_title' => 'Stay Updated',
        'cta_desc' => 'Subscribe to receive insights from our foundry and news about upcoming projects.',
        'cta_btn' => 'Contact Us',
    ),
    'es' => array(
        'title' => 'Blog Técnico',
        'subtitle' => 'Conocimientos, procesos y experiencia en fundición artística',
        'read_more' => 'Leer más',
        'prev' => '← Anterior',
        'next' => 'Siguiente →',
        'no_posts_title' => 'No se encontraron publicaciones',
        'no_posts_body' => 'Pronto publicaremos artículos técnicos sobre nuestros procesos de fundición.',
        'sidebar_categories' => 'Categorías',
        'sidebar_recent' => 'Publicaciones Recientes',
        'cta_title' => 'Mantente Informado',
        'cta_desc' => 'Suscríbete para recibir conocimientos de nuestra fundición y noticias sobre próximos proyectos.',
        'cta_btn' => 'Contáctanos',
    ),
);
$c = isset($t[$current_lang]) ? $t[$current_lang] : $t['en'];
?>

<div class="blog-page">
    <!-- Blog Header -->
    <section class="blog-header">
        <div class="container">
            <h1 class="blog-title"><?php echo esc_html($c['title']); ?></h1>
            <p class="blog-description"><?php echo esc_html($c['subtitle']); ?></p>
        </div>
    </section>

    <!-- Blog Content -->
    <div class="container">
        <div class="blog-layout">
            <main class="blog-main">
                <?php if (have_posts()) : ?>
                    <div class="blog-grid">
                        <?php while (have_posts()) : the_post(); ?>
                            <article id="post-<?php the_ID(); ?>" <?php post_class('blog-card'); ?>>
                                <?php if (has_post_thumbnail()) : ?>
                                    <a href="<?php the_permalink(); ?>" class="blog-thumbnail">
                                        <?php the_post_thumbnail('large'); ?>
                                    </a>
                                <?php endif; ?>
                                
                                <div class="blog-card-content">
                                    <div class="blog-meta">
                                        <span class="blog-date"><?php echo get_the_date(); ?></span>
                                        <?php
                                        $categories = get_the_category();
                                        if ($categories) :
                                            foreach ($categories as $category) :
                                                $cat_name = $category->name;
                                                if ( strtolower($cat_name) === 'uncategorized' ) {
                                                    $cat_name = ($current_lang === 'es') ? 'Sin categoría' : 'Uncategorized';
                                                }
                                                ?>
                                                <span class="blog-category"><?php echo esc_html($cat_name); ?></span>
                                            <?php endforeach;
                                        endif;
                                        ?>
                                    </div>
                                    
                                    <h2 class="blog-card-title">
                                        <a href="<?php the_permalink(); ?>"><?php the_title(); ?></a>
                                    </h2>
                                    
                                    <div class="blog-excerpt">
                                        <?php echo wp_trim_words(get_the_excerpt(), 30); ?>
                                    </div>
                                    
                                    <a href="<?php the_permalink(); ?>" class="blog-read-more">
                                        <?php echo esc_html($c['read_more']); ?> →
                                    </a>
                                </div>
                            </article>
                        <?php endwhile; ?>
                    </div>

                    <!-- Pagination -->
                    <div class="blog-pagination">
                        <?php
                        the_posts_pagination(array(
                            'mid_size' => 2,
                            'prev_text' => $c['prev'],
                            'next_text' => $c['next'],
                        ));
                        ?>
                    </div>

                <?php else : ?>
                    <div class="blog-no-posts">
                        <h2><?php echo esc_html($c['no_posts_title']); ?></h2>
                        <p><?php echo esc_html($c['no_posts_body']); ?></p>
                    </div>
                <?php endif; ?>
            </main>

            <aside class="blog-sidebar">
                <?php if (is_active_sidebar('blog-sidebar')) : ?>
                    <?php dynamic_sidebar('blog-sidebar'); ?>
                <?php else : ?>
                    <!-- Default sidebar widgets -->
                    <div class="widget widget-categories">
                        <h3 class="widget-title"><?php echo esc_html($c['sidebar_categories']); ?></h3>
                        <ul>
                            <?php
                            wp_list_categories(array(
                                'title_li' => '',
                                'show_count' => true,
                            ));
                            ?>
                        </ul>
                    </div>

                    <div class="widget widget-recent-posts">
                        <h3 class="widget-title"><?php echo esc_html($c['sidebar_recent']); ?></h3>
                        <ul>
                            <?php
                            $recent_posts = wp_get_recent_posts(array(
                                'numberposts' => 5,
                                'post_status' => 'publish'
                            ));
                            foreach ($recent_posts as $post) : ?>
                                <li>
                                    <a href="<?php echo get_permalink($post['ID']); ?>">
                                        <?php echo esc_html($post['post_title']); ?>
                                    </a>
                                </li>
                            <?php endforeach;
                            wp_reset_query();
                            ?>
                        </ul>
                    </div>

                    <div class="widget widget-cta">
                        <h3 class="widget-title"><?php echo esc_html($c['cta_title']); ?></h3>
                        <p><?php echo esc_html($c['cta_desc']); ?></p>
                        <a href="<?php echo esc_url( function_exists('runart_get_contact_url_for_lang') ? runart_get_contact_url_for_lang( $current_lang ) : home_url('/contact/') ); ?>" class="btn btn-primary">
                            <?php echo esc_html($c['cta_btn']); ?>
                        </a>
                    </div>
                <?php endif; ?>
            </aside>
        </div>
    </div>
</div><!-- .blog-page -->

<?php get_footer(); ?>
