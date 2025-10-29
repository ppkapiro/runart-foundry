<?php
/**
 * Single Project Template
 *
 * @package RUNArtFoundry
 */

get_header();

while ( have_posts() ) :
    the_post();
    
    // Get ACF fields
    $artist_name = get_field('artist_name');
    $alloy = get_field('alloy');
    $measures = get_field('measures');
    $edition = get_field('edition');
    $edition_number = get_field('edition_number');
    $patina_type = get_field('patina_type');
    $year = get_field('year');
    $location = get_field('location');
    $video_url = get_field('video_url');
    $credits = get_field('credits');
    $gallery = get_field('gallery');
    $technical_description = get_field('technical_description');
    $process_steps = get_field('process_steps');
    $testimonial_quote = get_field('testimonial_quote');
    $related_testimonial = get_field('related_testimonial');
    
    // Get taxonomies
    $artists = get_the_terms(get_the_ID(), 'artist');
    $techniques = get_the_terms(get_the_ID(), 'technique');
    $alloys = get_the_terms(get_the_ID(), 'alloy');
    $patinas = get_the_terms(get_the_ID(), 'patina');
    $years = get_the_terms(get_the_ID(), 'year');
    ?>
    
    <article id="project-<?php the_ID(); ?>" <?php post_class('project-single'); ?>>
        
        <!-- Hero Section with Featured Image -->
        <?php if (has_post_thumbnail()) : ?>
        <div class="project-hero">
            <?php the_post_thumbnail('full', array('class' => 'project-hero-image')); ?>
        </div>
        <?php endif; ?>
        
        <div class="container project-content">
            
            <!-- Project Header -->
            <header class="project-header">
                <h1 class="project-title"><?php the_title(); ?></h1>
                
                <?php if ($artist_name) : ?>
                <p class="project-artist">
                    <strong><?php _e('Artista:', 'runart'); ?></strong> <?php echo esc_html($artist_name); ?>
                </p>
                <?php endif; ?>
                
                <!-- Taxonomies -->
                <div class="project-taxonomies">
                    <?php if ($techniques) : ?>
                    <span class="taxonomy-item">
                        <strong><?php _e('Técnica:', 'runart'); ?></strong>
                        <?php echo esc_html(implode(', ', wp_list_pluck($techniques, 'name'))); ?>
                    </span>
                    <?php endif; ?>
                    
                    <?php if ($year) : ?>
                    <span class="taxonomy-item">
                        <strong><?php _e('Año:', 'runart'); ?></strong> <?php echo esc_html($year); ?>
                    </span>
                    <?php endif; ?>
                </div>
            </header>
            
            <!-- Technical Description -->
            <?php if ($technical_description) : ?>
            <div class="project-description">
                <?php echo wpautop($technical_description); ?>
            </div>
            <?php endif; ?>
            
            <!-- Technical Sheet -->
            <div class="project-technical-sheet">
                <h2><?php _e('Ficha Técnica', 'runart'); ?></h2>
                <ul class="technical-sheet-list">
                    <?php if ($artist_name) : ?>
                    <li><strong><?php _e('Artista:', 'runart'); ?></strong> <?php echo esc_html($artist_name); ?></li>
                    <?php endif; ?>
                    
                    <?php if ($techniques) : ?>
                    <li><strong><?php _e('Técnica:', 'runart'); ?></strong> <?php echo esc_html(implode(', ', wp_list_pluck($techniques, 'name'))); ?></li>
                    <?php endif; ?>
                    
                    <?php if ($alloy) : ?>
                    <li><strong><?php _e('Aleación:', 'runart'); ?></strong> <?php echo esc_html($alloy); ?></li>
                    <?php endif; ?>
                    
                    <?php if ($measures) : ?>
                    <li><strong><?php _e('Medidas:', 'runart'); ?></strong> <?php echo esc_html($measures); ?></li>
                    <?php endif; ?>
                    
                    <?php if ($edition) : ?>
                    <li><strong><?php _e('Edición:', 'runart'); ?></strong> 
                        <?php 
                        $edition_labels = array(
                            'unique' => __('Pieza única', 'runart'),
                            'limited' => __('Edición limitada', 'runart'),
                            'open' => __('Edición abierta', 'runart')
                        );
                        echo esc_html($edition_labels[$edition]);
                        if ($edition === 'limited' && $edition_number) {
                            echo ' (' . esc_html($edition_number) . ')';
                        }
                        ?>
                    </li>
                    <?php endif; ?>
                    
                    <?php if ($patina_type) : ?>
                    <li><strong><?php _e('Pátina:', 'runart'); ?></strong> <?php echo esc_html($patina_type); ?></li>
                    <?php endif; ?>
                    
                    <?php if ($credits) : ?>
                    <li><strong><?php _e('Créditos:', 'runart'); ?></strong><br><?php echo nl2br(esc_html($credits)); ?></li>
                    <?php endif; ?>
                    
                    <?php if ($year && $location) : ?>
                    <li><strong><?php _e('Año y ubicación:', 'runart'); ?></strong> <?php echo esc_html($year); ?> — <?php echo esc_html($location); ?></li>
                    <?php elseif ($year) : ?>
                    <li><strong><?php _e('Año:', 'runart'); ?></strong> <?php echo esc_html($year); ?></li>
                    <?php elseif ($location) : ?>
                    <li><strong><?php _e('Ubicación:', 'runart'); ?></strong> <?php echo esc_html($location); ?></li>
                    <?php endif; ?>
                </ul>
            </div>
            
            <!-- Main Content -->
            <div class="project-main-content">
                <?php the_content(); ?>
            </div>
            
            <!-- Process Steps -->
            <?php if ($process_steps) : ?>
            <div class="project-process">
                <h2><?php _e('Proceso', 'runart'); ?></h2>
                <ol class="process-steps">
                    <?php foreach ($process_steps as $step) : ?>
                    <li>
                        <strong><?php echo esc_html($step['step_title']); ?></strong>
                        <?php if (!empty($step['step_description'])) : ?>
                        <p><?php echo esc_html($step['step_description']); ?></p>
                        <?php endif; ?>
                    </li>
                    <?php endforeach; ?>
                </ol>
            </div>
            <?php endif; ?>
            
            <!-- Gallery -->
            <?php if ($gallery) : ?>
            <div class="project-gallery">
                <h2><?php _e('Galería', 'runart'); ?></h2>
                <div class="gallery-grid">
                    <?php foreach ($gallery as $image) : ?>
                    <figure class="gallery-item">
                        <a href="<?php echo esc_url($image['url']); ?>" data-lightbox="project-gallery">
                            <img src="<?php echo esc_url($image['sizes']['medium']); ?>" 
                                 alt="<?php echo esc_attr($image['alt']); ?>" 
                                 loading="lazy">
                        </a>
                        <?php if ($image['caption']) : ?>
                        <figcaption><?php echo esc_html($image['caption']); ?></figcaption>
                        <?php endif; ?>
                    </figure>
                    <?php endforeach; ?>
                </div>
            </div>
            <?php endif; ?>
            
            <!-- Video Section -->
            <?php if ($video_url) : ?>
            <div class="project-video">
                <h2><?php _e('Video del Proyecto', 'runart'); ?></h2>
                <div class="video-embed">
                    <?php
                    // Auto-embed YouTube/Vimeo
                    echo wp_oembed_get($video_url);
                    ?>
                </div>
            </div>
            <?php endif; ?>
            
            <!-- Testimonial Quote -->
            <?php if ($testimonial_quote) : ?>
            <div class="project-testimonial">
                <h2><?php _e('Testimonio del Artista', 'runart'); ?></h2>
                <blockquote class="testimonial-quote">
                    <?php echo wpautop($testimonial_quote); ?>
                    <?php if ($artist_name) : ?>
                    <cite>— <?php echo esc_html($artist_name); ?></cite>
                    <?php endif; ?>
                </blockquote>
                
                <?php if ($related_testimonial) : ?>
                <p>
                    <a href="<?php echo get_permalink($related_testimonial); ?>" class="btn btn-secondary">
                        <?php _e('Ver testimonio completo', 'runart'); ?>
                    </a>
                </p>
                <?php endif; ?>
            </div>
            <?php endif; ?>
            
            <!-- Call to Action -->
            <div class="project-cta">
                <hr>
                <p>
                    <strong><?php _e('¿Tienes un proyecto similar en mente?', 'runart'); ?></strong><br>
                    <a href="<?php echo esc_url( runart_get_contact_url_for_lang( function_exists('pll_current_language') ? pll_current_language() : 'en' ) ); ?>" class="btn btn-primary"><?php _e('Inicia tu consulta', 'runart'); ?></a>
                    <a href="<?php echo esc_url( get_post_type_archive_link('service') ); ?>" class="btn btn-secondary"><?php _e('Ver servicios', 'runart'); ?></a>
                </p>
            </div>
            
            <!-- Navigation -->
            <nav class="project-navigation">
                <div class="nav-previous">
                    <?php previous_post_link('%link', '← %title', true, '', 'project'); ?>
                </div>
                <div class="nav-next">
                    <?php next_post_link('%link', '%title →', true, '', 'project'); ?>
                </div>
            </nav>
            
        </div><!-- .container -->
        
    </article>
    
    <?php
endwhile;

get_footer();
