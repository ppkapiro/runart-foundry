<?php
/**
 * Archive Projects Template
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
    
    <!-- Filters -->
    <div class="archive-filters">
        <div class="container">
            <form method="get" action="<?php echo esc_url(get_post_type_archive_link('project')); ?>" class="filters-form">
                
                <!-- Artist Filter -->
                <?php
                $artists = get_terms(array(
                    'taxonomy' => 'artist',
                    'hide_empty' => true,
                ));
                if ($artists && !is_wp_error($artists)) :
                ?>
                <div class="filter-group">
                    <label for="filter-artist"><?php _e('Artista:', 'runart'); ?></label>
                    <select name="artist" id="filter-artist">
                        <option value=""><?php _e('Todos', 'runart'); ?></option>
                        <?php foreach ($artists as $artist) : ?>
                        <option value="<?php echo esc_attr($artist->slug); ?>" <?php selected(get_query_var('artist'), $artist->slug); ?>>
                            <?php echo esc_html($artist->name); ?> (<?php echo $artist->count; ?>)
                        </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <?php endif; ?>
                
                <!-- Technique Filter -->
                <?php
                $techniques = get_terms(array(
                    'taxonomy' => 'technique',
                    'hide_empty' => true,
                ));
                if ($techniques && !is_wp_error($techniques)) :
                ?>
                <div class="filter-group">
                    <label for="filter-technique"><?php _e('Técnica:', 'runart'); ?></label>
                    <select name="technique" id="filter-technique">
                        <option value=""><?php _e('Todas', 'runart'); ?></option>
                        <?php foreach ($techniques as $technique) : ?>
                        <option value="<?php echo esc_attr($technique->slug); ?>" <?php selected(get_query_var('technique'), $technique->slug); ?>>
                            <?php echo esc_html($technique->name); ?> (<?php echo $technique->count; ?>)
                        </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <?php endif; ?>
                
                <!-- Year Filter -->
                <?php
                $years = get_terms(array(
                    'taxonomy' => 'year',
                    'hide_empty' => true,
                    'orderby' => 'name',
                    'order' => 'DESC',
                ));
                if ($years && !is_wp_error($years)) :
                ?>
                <div class="filter-group">
                    <label for="filter-year"><?php _e('Año:', 'runart'); ?></label>
                    <select name="year" id="filter-year">
                        <option value=""><?php _e('Todos', 'runart'); ?></option>
                        <?php foreach ($years as $year) : ?>
                        <option value="<?php echo esc_attr($year->slug); ?>" <?php selected(get_query_var('year'), $year->slug); ?>>
                            <?php echo esc_html($year->name); ?> (<?php echo $year->count; ?>)
                        </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <?php endif; ?>
                
                <button type="submit" class="btn btn-primary"><?php _e('Filtrar', 'runart'); ?></button>
                
                <?php if (get_query_var('artist') || get_query_var('technique') || get_query_var('year')) : ?>
                <a href="<?php echo esc_url(get_post_type_archive_link('project')); ?>" class="btn btn-secondary">
                    <?php _e('Limpiar filtros', 'runart'); ?>
                </a>
                <?php endif; ?>
                
            </form>
        </div>
    </div>
    
    <!-- Projects Grid -->
    <div class="container">
        
        <?php if (have_posts()) : ?>
        
        <div class="projects-grid">
            <?php
            while (have_posts()) :
                the_post();
                
                // Get ACF fields
                $artist_name = get_field('artist_name');
                $year = get_field('year');
                $techniques = get_the_terms(get_the_ID(), 'technique');
                ?>
                
                <article id="project-<?php the_ID(); ?>" <?php post_class('project-card'); ?>>
                    
                    <!-- Featured Image -->
                    <a href="<?php the_permalink(); ?>" class="project-card-image">
                        <?php if (has_post_thumbnail()) : ?>
                            <?php the_post_thumbnail('medium_large', array('loading' => 'lazy')); ?>
                        <?php else : ?>
                            <img src="/wp-content/themes/runart-theme/assets/images/placeholder-project.jpg" alt="<?php the_title_attribute(); ?>" loading="lazy">
                        <?php endif; ?>
                    </a>
                    
                    <!-- Card Content -->
                    <div class="project-card-content">
                        
                        <h2 class="project-card-title">
                            <a href="<?php the_permalink(); ?>"><?php the_title(); ?></a>
                        </h2>
                        
                        <?php if ($artist_name) : ?>
                        <p class="project-card-artist">
                            <strong><?php _e('Artista:', 'runart'); ?></strong> <?php echo esc_html($artist_name); ?>
                        </p>
                        <?php endif; ?>
                        
                        <div class="project-card-meta">
                            <?php if ($techniques) : ?>
                            <span class="meta-technique">
                                <?php echo esc_html(implode(', ', wp_list_pluck($techniques, 'name'))); ?>
                            </span>
                            <?php endif; ?>
                            
                            <?php if ($year) : ?>
                            <span class="meta-year"><?php echo esc_html($year); ?></span>
                            <?php endif; ?>
                        </div>
                        
                        <?php if (has_excerpt()) : ?>
                        <div class="project-card-excerpt">
                            <?php the_excerpt(); ?>
                        </div>
                        <?php endif; ?>
                        
                        <a href="<?php the_permalink(); ?>" class="btn btn-secondary btn-sm">
                            <?php _e('Ver proyecto', 'runart'); ?> →
                        </a>
                        
                    </div><!-- .project-card-content -->
                    
                </article>
                
            <?php endwhile; ?>
        </div><!-- .projects-grid -->
        
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
        
        <!-- No Projects Found -->
        <div class="no-projects-found">
            <p><?php _e('No se encontraron proyectos con los filtros seleccionados.', 'runart'); ?></p>
            <a href="<?php echo esc_url(get_post_type_archive_link('project')); ?>" class="btn btn-primary">
                <?php _e('Ver todos los proyectos', 'runart'); ?>
            </a>
        </div>
        
        <?php endif; ?>
        
    </div><!-- .container -->
    
    <!-- Call to Action -->
    <section class="archive-cta">
        <div class="container">
            <h2><?php _e('¿Quieres Crear tu Propia Escultura en Bronce?', 'runart'); ?></h2>
            <p><?php _e('Desde esculturas de galería hasta monumentos públicos, RUN Art Foundry transforma tu visión artística en bronce permanente.', 'runart'); ?></p>
            <a href="<?php echo esc_url( runart_get_contact_url_for_lang( function_exists('pll_current_language') ? pll_current_language() : 'en' ) ); ?>" class="btn btn-primary btn-lg"><?php _e('Inicia tu consulta gratuita', 'runart'); ?></a>
            <a href="<?php echo esc_url( get_post_type_archive_link('service') ); ?>" class="btn btn-secondary btn-lg"><?php _e('Ver servicios', 'runart'); ?></a>
        </div>
    </section>
    
</div><!-- .archive-projects -->

<?php
get_footer();
