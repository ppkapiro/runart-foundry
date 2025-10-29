<?php
/**
 * Single Blog Post Template
 *
 * @package RUNArtFoundry
 */

get_header();

$lang = function_exists('pll_current_language') ? pll_current_language() : 'en';

while ( have_posts() ) : the_post();
?>

<article id="post-<?php the_ID(); ?>" <?php post_class('post-single'); ?>>
    
    <!-- Hero Section -->
    <?php if ( has_post_thumbnail() ) : ?>
    <div class="post-hero">
        <?php the_post_thumbnail('full', array('class' => 'post-hero-image')); ?>
    </div>
    <?php endif; ?>
    
    <div class="container post-content">
        
        <!-- Post Header -->
        <header class="post-header">
            
            <div class="post-meta">
                <span class="meta-date"><?php echo get_the_date(); ?></span>
                <?php
                $categories = get_the_category();
                if ( $categories ) :
                    ?>
                    <span class="meta-separator">•</span>
                    <span class="meta-category"><?php echo esc_html( $categories[0]->name ); ?></span>
                    <?php
                endif;
                ?>
                <span class="meta-separator">•</span>
                <span class="meta-reading-time">
                    <?php
                    $word_count = str_word_count( strip_tags( get_the_content() ) );
                    $reading_time = ceil( $word_count / 200 );
                    echo $lang === 'es' 
                        ? $reading_time . ' min lectura'
                        : $reading_time . ' min read';
                    ?>
                </span>
            </div>
            
            <h1 class="post-title"><?php the_title(); ?></h1>
            
            <?php if ( has_excerpt() ) : ?>
            <div class="post-excerpt">
                <?php the_excerpt(); ?>
            </div>
            <?php endif; ?>
            
        </header>
        
        <!-- Post Content -->
        <div class="post-main-content">
            <?php the_content(); ?>
        </div>
        
        <!-- Post Tags -->
        <?php
        $tags = get_the_tags();
        if ( $tags ) :
            ?>
            <div class="post-tags">
                <strong><?php echo $lang === 'es' ? 'Etiquetas:' : 'Tags:'; ?></strong>
                <?php
                foreach ( $tags as $tag ) :
                    ?>
                    <a href="<?php echo esc_url( get_tag_link( $tag->term_id ) ); ?>" class="tag-link">
                        <?php echo esc_html( $tag->name ); ?>
                    </a>
                    <?php
                endforeach;
                ?>
            </div>
            <?php
        endif;
        ?>
        
        <!-- Navigation -->
        <nav class="post-navigation">
            <div class="nav-previous">
                <?php previous_post_link('%link', '← %title'); ?>
            </div>
            <div class="nav-next">
                <?php next_post_link('%link', '%title →'); ?>
            </div>
        </nav>
        
        <!-- CTA Section -->
        <div class="post-cta">
            <hr>
            <p>
                <strong>
                    <?php echo $lang === 'es' 
                        ? '¿Tienes un proyecto de fundición en mente?' 
                        : 'Do you have a casting project in mind?'; ?>
                </strong><br>
                <?php echo $lang === 'es'
                    ? 'Contáctanos para una consulta técnica gratuita'
                    : 'Contact us for a free technical consultation'; ?>
            </p>
            <a href="<?php echo esc_url( runart_get_contact_url_for_lang( $lang ) ); ?>" class="btn btn-primary">
                <?php echo $lang === 'es' ? 'Contactar Ahora' : 'Contact Now'; ?>
            </a>
            <a href="<?php echo esc_url( get_post_type_archive_link('project') ); ?>" class="btn btn-secondary">
                <?php echo $lang === 'es' ? 'Ver Proyectos' : 'View Projects'; ?>
            </a>
        </div>
        
    </div><!-- .container -->
    
</article>

<?php
endwhile;

get_footer();
