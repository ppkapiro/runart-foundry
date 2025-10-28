<?php
/**
 * Blog Archive Template
 * Lists all blog posts
 *
 * @package RUNArtFoundry
 */

get_header();

$lang = function_exists('pll_current_language') ? pll_current_language() : 'en';
?>

<div class="blog-archive">
    
    <!-- Archive Header -->
    <header class="archive-header">
        <div class="container">
            <h1 class="archive-title"><?php echo $lang === 'es' ? 'Blog Técnico' : 'Technical Blog'; ?></h1>
            <p class="archive-description">
                <?php echo $lang === 'es' 
                    ? 'Artículos sobre técnicas de fundición, aleaciones, procesos y conservación de esculturas de bronce'
                    : 'Articles on casting techniques, alloys, processes and conservation of bronze sculptures'; ?>
            </p>
        </div>
    </header>
    
    <!-- Blog Posts Grid -->
    <div class="container">
        <?php if ( have_posts() ) : ?>
        
        <div class="blog-grid">
            <?php while ( have_posts() ) : the_post(); ?>
                
                <article id="post-<?php the_ID(); ?>" <?php post_class('blog-card'); ?>>
                    
                    <?php if ( has_post_thumbnail() ) : ?>
                    <a href="<?php the_permalink(); ?>" class="blog-card-image">
                        <?php the_post_thumbnail('medium_large', array('loading' => 'lazy')); ?>
                    </a>
                    <?php endif; ?>
                    
                    <div class="blog-card-content">
                        
                        <div class="blog-card-meta">
                            <span class="meta-date"><?php echo get_the_date(); ?></span>
                            <?php
                            $categories = get_the_category();
                            if ( $categories ) :
                                ?>
                                <span class="meta-category"><?php echo esc_html( $categories[0]->name ); ?></span>
                                <?php
                            endif;
                            ?>
                        </div>
                        
                        <h2 class="blog-card-title">
                            <a href="<?php the_permalink(); ?>"><?php the_title(); ?></a>
                        </h2>
                        
                        <?php if ( has_excerpt() ) : ?>
                        <div class="blog-card-excerpt">
                            <?php the_excerpt(); ?>
                        </div>
                        <?php endif; ?>
                        
                        <a href="<?php the_permalink(); ?>" class="blog-card-link">
                            <?php echo $lang === 'es' ? 'Leer más' : 'Read more'; ?> →
                        </a>
                    </div>
                    
                </article>
                
            <?php endwhile; ?>
        </div>
        
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
        
        <!-- No Posts Found -->
        <div class="no-posts-found">
            <p><?php echo $lang === 'es' ? 'No hay artículos publicados aún.' : 'No articles published yet.'; ?></p>
        </div>
        
        <?php endif; ?>
    </div>
    
</div>

<?php
get_footer();
