<?php
/**
 * Template Name: Blog Page
 * Bilingual blog page template with hero and post grid.
 *
 * @package RunArt_Base
 */

get_header();

// Detect current language (prefer page language to avoid mismatches)
$current_lang = 'en';
if ( function_exists('pll_get_post_language') ) {
    $page_id = get_queried_object_id();
    $lang = pll_get_post_language( $page_id );
    if ( $lang ) { $current_lang = $lang; }
} elseif ( function_exists('pll_current_language') ) {
    $current_lang = pll_current_language();
}

// Bilingual content
$content = array(
    'en' => array(
        'hero_title' => 'Technical Blog',
        'hero_subtitle' => 'Insights, processes, and expertise in art casting from our master artisans.',
        'read_more' => 'Read More',
        'no_posts' => 'No posts found.',
        'by' => 'By',
        'on' => 'on',
        'in' => 'in',
        'categories' => 'Categories',
        'all' => 'All Posts'
    ),
    'es' => array(
        'hero_title' => 'Blog Técnico',
        'hero_subtitle' => 'Conocimientos, procesos y experiencia en fundición artística de nuestros maestros artesanos.',
        'read_more' => 'Leer Más',
        'no_posts' => 'No se encontraron publicaciones.',
        'by' => 'Por',
        'on' => 'el',
        'in' => 'en',
        'categories' => 'Categorías',
        'all' => 'Todas las Publicaciones'
    )
);

$c = isset($content[$current_lang]) ? $content[$current_lang] : $content['en'];

// Get posts in current language
$paged = (get_query_var('paged')) ? get_query_var('paged') : 1;
$args = array(
    'post_type' => 'post',
    'posts_per_page' => 9,
    'paged' => $paged,
    'post_status' => 'publish'
);

// Add language filter explicitly
if (function_exists('pll_current_language')) {
    $args['lang'] = $current_lang;
}

$blog_query = new WP_Query($args);
?>

<div class="blog-page">
    <!-- Hero Section -->
    <section class="hero-section">
        <?php
        $hero_img = runart_get_runmedia_image('run-art-foundry-branding', 'w2560');
        if ($hero_img):
        ?>
            <div class="hero-background" style="background-image: url('<?php echo esc_url($hero_img); ?>');"></div>
        <?php endif; ?>
        <div class="hero-content">
            <h1 class="hero-title"><?php echo esc_html($c['hero_title']); ?></h1>
            <p class="hero-subtitle"><?php echo esc_html($c['hero_subtitle']); ?></p>
        </div>
    </section>

    <!-- Blog Posts Grid -->
    <section class="blog-section">
        <div class="container">
            <?php if ($blog_query->have_posts()): ?>
                <div class="blog-grid">
                    <?php while ($blog_query->have_posts()): $blog_query->the_post(); ?>
                        <article id="post-<?php the_ID(); ?>" <?php post_class('blog-card'); ?>>
                            <?php if (has_post_thumbnail()): ?>
                                <div class="blog-card-image">
                                    <a href="<?php the_permalink(); ?>">
                                        <?php the_post_thumbnail('large'); ?>
                                    </a>
                                </div>
                            <?php endif; ?>
                            
                            <div class="blog-card-content">
                                <div class="blog-meta">
                                    <span class="blog-date">
                                        <?php echo get_the_date(); ?>
                                    </span>
                                    <?php
                                    $categories = get_the_category();
                                    if ($categories):
                                    ?>
                                        <span class="blog-category">
                                            <?php
                                            $cat_name = $categories[0]->name;
                                            if ( strtolower($cat_name) === 'uncategorized' ) {
                                                $cat_name = ($current_lang === 'es') ? 'Sin categoría' : 'Uncategorized';
                                            }
                                            echo esc_html($cat_name);
                                            ?>
                                        </span>
                                    <?php endif; ?>
                                </div>
                                
                                <h2 class="blog-card-title">
                                    <a href="<?php the_permalink(); ?>">
                                        <?php the_title(); ?>
                                    </a>
                                </h2>
                                
                                <div class="blog-excerpt">
                                    <?php 
                                    if (has_excerpt()) {
                                        the_excerpt();
                                    } else {
                                        echo wp_trim_words(get_the_content(), 25, '...');
                                    }
                                    ?>
                                </div>
                                
                                <a href="<?php the_permalink(); ?>" class="blog-read-more">
                                    <?php echo esc_html($c['read_more']); ?> →
                                </a>
                            </div>
                        </article>
                    <?php endwhile; ?>
                </div>

                <!-- Pagination -->
                <?php if ($blog_query->max_num_pages > 1): ?>
                    <div class="blog-pagination">
                        <?php
                        echo paginate_links(array(
                            'total' => $blog_query->max_num_pages,
                            'current' => $paged,
                            'prev_text' => '←',
                            'next_text' => '→',
                            'type' => 'list'
                        ));
                        ?>
                    </div>
                <?php endif; ?>

            <?php else: ?>
                <div class="no-posts">
                    <p><?php echo esc_html($c['no_posts']); ?></p>
                </div>
            <?php endif; ?>

            <?php wp_reset_postdata(); ?>
        </div>
    </section>

    <!-- Newsletter CTA (Optional) -->
    <section class="newsletter-section">
        <div class="container">
            <div class="newsletter-card">
                <h2 class="newsletter-title">
                    <?php echo $current_lang === 'en' ? 'Stay Updated' : 'Mantente Informado'; ?>
                </h2>
                <p class="newsletter-description">
                    <?php echo $current_lang === 'en' 
                        ? 'Subscribe to receive insights from our foundry and news about upcoming projects.' 
                        : 'Suscríbete para recibir conocimientos de nuestra fundición y noticias sobre próximos proyectos.'; 
                    ?>
                </p>
                <a href="<?php echo esc_url(function_exists('pll_get_post') ? get_permalink(pll_get_post(3515, $current_lang)) : '/en/contact/'); ?>" class="btn btn-primary">
                    <?php echo $current_lang === 'en' ? 'Contact Us' : 'Contáctanos'; ?>
                </a>
            </div>
        </div>
    </section>
</div>

<?php get_footer(); ?>
