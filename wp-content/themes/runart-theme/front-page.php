<?php
/**
 * Front Page Template — RUN Art Foundry
 * Home page with hero, projects, services, testimonials
 *
 * @package RUNArtFoundry
 */

get_header();

// Obtener idioma actual
$lang = function_exists('pll_current_language') ? pll_current_language() : 'en';
?>

<div class="home-page">
    
    <!-- Hero Section -->
    <section class="home-hero">
        <div class="home-hero-background">
            <?php
            // Hero image desde RunMedia (proyecto run-art-foundry-branding)
            $hero_url = runmedia_get_url( null, 'run-art-foundry-branding', null, 'w2560', 'webp', 0 );
            if ( $hero_url ) :
                $hero_alt = runmedia_get_alt( null, 'run-art-foundry-branding', null, $lang, 0 );
                if ( empty( $hero_alt ) ) {
                    $hero_alt = $lang === 'es' ? 'Taller de fundición artística RUN Art Foundry' : 'RUN Art Foundry artistic bronze casting workshop';
                }
                ?>
                <img src="<?php echo esc_url( $hero_url ); ?>" 
                     alt="<?php echo esc_attr( $hero_alt ); ?>" 
                     loading="eager" />
            <?php endif; ?>
        </div>
        <div class="home-hero-content">
            <h1 class="home-hero-title">
                <?php echo $lang === 'es' 
                    ? 'Fundición Artística de Bronce<br>Excelencia Técnica Desde 1994' 
                    : 'Artistic Bronze Casting<br>Technical Excellence Since 1994'; ?>
            </h1>
            <p class="home-hero-subtitle">
                <?php echo $lang === 'es'
                    ? 'Transformamos visiones artísticas en esculturas permanentes de bronce con técnicas tradicionales y procesos contemporáneos'
                    : 'We transform artistic visions into permanent bronze sculptures using traditional techniques and contemporary processes'; ?>
            </p>
            <div class="home-hero-cta">
                <a href="<?php echo esc_url( runart_get_contact_url_for_lang( $lang ) ); ?>" class="btn btn-primary btn-lg">
                    <?php echo $lang === 'es' ? 'Iniciar Consulta Gratuita' : 'Start Free Consultation'; ?>
                </a>
                <a href="<?php echo esc_url( get_post_type_archive_link('project') ); ?>" class="btn btn-secondary btn-lg">
                    <?php echo $lang === 'es' ? 'Ver Proyectos' : 'View Projects'; ?>
                </a>
            </div>
        </div>
    </section>
    
    <!-- Featured Projects Section -->
    <section class="home-featured-projects">
        <div class="container">
            <header class="home-section-header">
                <h2><?php echo $lang === 'es' ? 'Proyectos Destacados' : 'Featured Projects'; ?></h2>
                <p><?php echo $lang === 'es' 
                    ? 'Descubre nuestro portfolio de esculturas en bronce fundidas con técnicas de precisión artesanal'
                    : 'Discover our portfolio of bronze sculptures cast with artisan precision techniques'; ?></p>
            </header>
            
            <div class="featured-projects-grid">
                <?php
                // Obtener proyectos destacados (últimos 6)
                $featured_projects_query = new WP_Query( array(
                    'post_type'      => 'project',
                    'posts_per_page' => 6,
                    'orderby'        => 'date',
                    'order'          => 'DESC',
                ) );
                
                if ( $featured_projects_query->have_posts() ) :
                    while ( $featured_projects_query->have_posts() ) : $featured_projects_query->the_post();
                        $artist_name = get_field('artist_name');
                        $year = get_field('year');
                        $project_slug = get_post_field( 'post_name', get_the_ID() );
                        ?>
                        <article class="project-card">
                            <a href="<?php the_permalink(); ?>" class="project-card-image">
                                <?php
                                // Obtener imagen del proyecto desde RunMedia
                                $project_img_url = runmedia_get_url( null, $project_slug, null, 'w800', 'webp', 0 );
                                $project_alt = runmedia_get_alt( null, $project_slug, null, $lang, 0 );
                                
                                if ( empty( $project_alt ) ) {
                                    $project_alt = get_the_title() . ( $artist_name ? ' — ' . $artist_name : '' );
                                }
                                
                                if ( $project_img_url ) :
                                    ?>
                                    <img src="<?php echo esc_url( $project_img_url ); ?>" 
                                         alt="<?php echo esc_attr( $project_alt ); ?>" 
                                         loading="lazy" />
                                <?php else : ?>
                                    <img src="/wp-content/themes/runart-theme/assets/images/placeholder-project.jpg" 
                                         alt="<?php the_title_attribute(); ?>" loading="lazy">
                                <?php endif; ?>
                            </a>
                            
                            <div class="project-card-content">
                                <h3 class="project-card-title">
                                    <a href="<?php the_permalink(); ?>"><?php the_title(); ?></a>
                                </h3>
                                
                                <?php if ( $artist_name ) : ?>
                                <p class="project-card-artist">
                                    <strong><?php echo $lang === 'es' ? 'Artista:' : 'Artist:'; ?></strong> <?php echo esc_html( $artist_name ); ?>
                                </p>
                                <?php endif; ?>
                                
                                <?php if ( $year ) : ?>
                                <p class="project-card-meta">
                                    <span class="meta-year"><?php echo esc_html( $year ); ?></span>
                                </p>
                                <?php endif; ?>
                                
                                <a href="<?php the_permalink(); ?>" class="btn btn-secondary btn-sm">
                                    <?php echo $lang === 'es' ? 'Ver proyecto' : 'View project'; ?> →
                                </a>
                            </div>
                        </article>
                        <?php
                    endwhile;
                    wp_reset_postdata();
                endif;
                ?>
            </div>
            
            <div class="home-view-all-projects">
                <a href="<?php echo esc_url( get_post_type_archive_link('project') ); ?>" class="btn btn-primary btn-lg">
                    <?php echo $lang === 'es' ? 'Ver Todos los Proyectos' : 'View All Projects'; ?>
                </a>
            </div>
        </div>
    </section>
    
    <!-- Services Overview Section -->
    <section class="home-services-overview">
        <div class="container">
            <header class="home-section-header">
                <h2><?php echo $lang === 'es' ? 'Servicios Especializados' : 'Specialized Services'; ?></h2>
                <p><?php echo $lang === 'es' 
                    ? 'Desde fundición tradicional hasta acabados contemporáneos con control técnico completo'
                    : 'From traditional casting to contemporary finishes with complete technical control'; ?></p>
            </header>
            
            <div class="services-overview-grid">
                <?php
                // Obtener servicios destacados
                $services = array(
                    array(
                        'slug' => 'bronze-casting',
                        'title' => $lang === 'es' ? 'Fundición en Bronce' : 'Bronze Casting',
                        'icon' => '🔥',
                        'desc' => $lang === 'es' ? 'Técnica de molde perdido con control total del proceso' : 'Lost-wax technique with complete process control',
                    ),
                    array(
                        'slug' => 'patina',
                        'title' => $lang === 'es' ? 'Pátinas Artísticas' : 'Artistic Patinas',
                        'icon' => '🎨',
                        'desc' => $lang === 'es' ? 'Acabados químicos tradicionales y contemporáneos' : 'Traditional and contemporary chemical finishes',
                    ),
                    array(
                        'slug' => 'ceramic-shell',
                        'title' => $lang === 'es' ? 'Molde Cerámico' : 'Ceramic Shell',
                        'icon' => '🏺',
                        'desc' => $lang === 'es' ? 'Proceso de alta precisión para detalles complejos' : 'High precision process for complex details',
                    ),
                    array(
                        'slug' => 'restoration',
                        'title' => $lang === 'es' ? 'Restauración' : 'Restoration',
                        'icon' => '🛠️',
                        'desc' => $lang === 'es' ? 'Conservación y reparación de esculturas históricas' : 'Conservation and repair of historical sculptures',
                    ),
                    array(
                        'slug' => 'engineering',
                        'title' => $lang === 'es' ? 'Ingeniería' : 'Engineering',
                        'icon' => '📐',
                        'desc' => $lang === 'es' ? 'Diseño estructural y planificación técnica' : 'Structural design and technical planning',
                    ),
                );
                
                foreach ( $services as $service ) :
                    ?>
                    <div class="service-overview-card">
                        <div class="service-overview-icon"><?php echo $service['icon']; ?></div>
                        <h3><?php echo esc_html( $service['title'] ); ?></h3>
                        <p><?php echo esc_html( $service['desc'] ); ?></p>
                        <a href="<?php echo esc_url( get_post_type_archive_link('service') ); ?>">
                            <?php echo $lang === 'es' ? 'Ver más' : 'Learn more'; ?>
                        </a>
                    </div>
                    <?php
                endforeach;
                ?>
            </div>
            
            <div class="home-view-all-services">
                <a href="<?php echo esc_url( get_post_type_archive_link('service') ); ?>" class="btn btn-primary btn-lg">
                    <?php echo $lang === 'es' ? 'Ver Todos los Servicios' : 'View All Services'; ?>
                </a>
            </div>
        </div>
    </section>
    
    <!-- Stats Section -->
    <section class="home-stats">
        <div class="container">
            <div class="stats-grid">
                <div class="stat-item">
                    <span class="stat-number">30+</span>
                    <span class="stat-label"><?php echo $lang === 'es' ? 'Años de Experiencia' : 'Years Experience'; ?></span>
                </div>
                <div class="stat-item">
                    <span class="stat-number">500+</span>
                    <span class="stat-label"><?php echo $lang === 'es' ? 'Proyectos Completados' : 'Projects Completed'; ?></span>
                </div>
                <div class="stat-item">
                    <span class="stat-number">100+</span>
                    <span class="stat-label"><?php echo $lang === 'es' ? 'Artistas Atendidos' : 'Artists Served'; ?></span>
                </div>
                <div class="stat-item">
                    <span class="stat-number">15</span>
                    <span class="stat-label"><?php echo $lang === 'es' ? 'Países con Proyectos' : 'Countries w/ Projects'; ?></span>
                </div>
            </div>
        </div>
    </section>
    
    <!-- Testimonials Section -->
    <section class="home-testimonials">
        <div class="container">
            <header class="home-section-header">
                <h2><?php echo $lang === 'es' ? 'Lo Que Dicen los Artistas' : 'What Artists Say'; ?></h2>
                <p><?php echo $lang === 'es' 
                    ? 'Testimonios de artistas reconocidos internacionalmente que confían en nuestra fundición'
                    : 'Testimonials from internationally recognized artists who trust our foundry'; ?></p>
            </header>
            
            <div class="testimonials-carousel">
                <?php
                $testimonials_query = new WP_Query( array(
                    'post_type'      => 'testimonial',
                    'posts_per_page' => 3,
                    'orderby'        => 'rand',
                ) );
                
                if ( $testimonials_query->have_posts() ) :
                    while ( $testimonials_query->have_posts() ) : $testimonials_query->the_post();
                        $author_role = get_field('author_role');
                        $featured_quote = get_field('featured_quote');
                        ?>
                        <div class="testimonial-slide">
                            <blockquote class="testimonial-quote-text">
                                "<?php echo $featured_quote ? esc_html( $featured_quote ) : esc_html( get_the_excerpt() ); ?>"
                            </blockquote>
                            <div class="testimonial-author">
                                <div class="testimonial-author-info">
                                    <p class="testimonial-author-name"><?php the_title(); ?></p>
                                    <?php if ( $author_role ) : ?>
                                    <p class="testimonial-author-role"><?php echo esc_html( $author_role ); ?></p>
                                    <?php endif; ?>
                                </div>
                            </div>
                        </div>
                        <?php
                    endwhile;
                    wp_reset_postdata();
                endif;
                ?>
            </div>
        </div>
    </section>
    
    <!-- Contact CTA Section -->
    <section class="home-contact-cta">
        <div class="contact-cta-content">
            <h2><?php echo $lang === 'es' ? '¿Listo para Crear tu Escultura en Bronce?' : 'Ready to Create Your Bronze Sculpture?'; ?></h2>
            <p>
                <?php echo $lang === 'es'
                    ? 'Desde obras de galería hasta monumentos públicos, transformamos tu visión artística en bronce permanente. Consulta gratuita sin compromiso.'
                    : 'From gallery pieces to public monuments, we transform your artistic vision into permanent bronze. Free consultation with no obligation.'; ?>
            </p>
            <div class="contact-cta-buttons">
                <a href="<?php echo esc_url( runart_get_contact_url_for_lang( $lang ) ); ?>" class="btn btn-primary btn-lg">
                    <?php echo $lang === 'es' ? 'Contactar Ahora' : 'Contact Now'; ?>
                </a>
                <a href="<?php echo esc_url( get_post_type_archive_link('service') ); ?>" class="btn btn-secondary btn-lg">
                    <?php echo $lang === 'es' ? 'Ver Servicios' : 'View Services'; ?>
                </a>
            </div>
        </div>
    </section>
    
</div><!-- .home-page -->

<?php
get_footer();
