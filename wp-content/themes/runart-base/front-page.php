<?php
/**
 * Template for Front Page (Home)
 * 
 * @package RunArt_Base
 */

get_header(); ?>

<div class="front-page-content">
    <!-- Hero Section -->
    <section id="hero" class="hero-section">
        <?php
        // Get hero image from RunMedia (with safe fallback)
        $hero_image = runart_get_runmedia_image('run-art-foundry-branding', 'w2560');
        $hero_style = $hero_image ? 'background-image: url(' . esc_url($hero_image['url']) . ');' : '';
        
        // Get current language for Polylang
        $current_lang = function_exists('pll_current_language') ? pll_current_language() : 'en';
        
        // Hero texts by language
        $hero_texts = array(
            'en' => array(
                'subtitle' => 'Excellence in Art Casting',
                'description' => 'We transform artistic visions into the highest quality bronze through traditional techniques and contemporary technology',
                'cta_contact' => 'Start Your Consultation',
                'cta_projects' => 'View Projects'
            ),
            'es' => array(
                'subtitle' => 'Excelencia en Fundición Artística',
                'description' => 'Transformamos visiones artísticas en bronce de la más alta calidad mediante técnicas tradicionales y tecnología contemporánea',
                'cta_contact' => 'Iniciar Consulta',
                'cta_projects' => 'Ver Proyectos'
            )
        );
        
        $texts = isset($hero_texts[$current_lang]) ? $hero_texts[$current_lang] : $hero_texts['en'];
        ?>
        <div class="hero-background" style="<?php echo $hero_style; ?>"></div>
        <div class="hero-content">
            <h1 class="hero-title"><?php echo get_bloginfo('name'); ?> — <?php echo esc_html($texts['subtitle']); ?></h1>
            <p class="hero-subtitle"><?php echo esc_html($texts['description']); ?></p>
            <div class="hero-cta">
                <?php
                // Get contact page in current language
                $contact_page = function_exists('pll_get_post') ? pll_get_post(get_page_by_path('contact')->ID) : get_page_by_path('contact')->ID;
                ?>
                <a href="<?php echo esc_url(get_permalink($contact_page)); ?>" class="btn btn-primary"><?php echo esc_html($texts['cta_contact']); ?></a>
                <a href="#projects-preview" class="btn btn-outline"><?php echo esc_html($texts['cta_projects']); ?></a>
            </div>
        </div>
    </section>

    <!-- Featured Projects Section -->
    <section id="projects-preview" class="section">
        <div class="container">
            <?php
            $section_texts = array(
                'en' => array(
                    'title' => 'Featured Projects',
                    'description' => 'We proudly present some of our most demanding and successful works',
                    'no_projects' => 'No projects available yet.',
                    'view_all' => 'View All Projects'
                ),
                'es' => array(
                    'title' => 'Proyectos Destacados',
                    'description' => 'Presentamos con orgullo algunos de nuestros trabajos más exigentes y exitosos',
                    'no_projects' => 'No hay proyectos disponibles aún.',
                    'view_all' => 'Ver Todos los Proyectos'
                )
            );
            $texts = isset($section_texts[$current_lang]) ? $section_texts[$current_lang] : $section_texts['en'];
            ?>
            <h2 class="section-title"><?php echo esc_html($texts['title']); ?></h2>
            <p class="section-description"><?php echo esc_html($texts['description']); ?></p>
            
            <div class="projects-grid">
                <?php
                // Query latest 6 projects with language filter
                $query_args = array(
                    'post_type' => 'project',
                    'posts_per_page' => 6,
                    'orderby' => 'date',
                    'order' => 'DESC'
                );
                
                // Add Polylang language filter if available
                if (function_exists('pll_current_language')) {
                    $query_args['lang'] = pll_current_language();
                }
                
                $projects_query = new WP_Query($query_args);

                if ($projects_query->have_posts()) :
                    while ($projects_query->have_posts()) : $projects_query->the_post();
                        $project_slug = get_post_field('post_name', get_the_ID());
                        $thumbnail = runart_get_runmedia_image($project_slug, 'w800');
                        ?>
                        <article class="project-card">
                            <?php if ($thumbnail) : ?>
                                <a href="<?php the_permalink(); ?>" class="project-thumbnail">
                                    <img src="<?php echo esc_url($thumbnail['url']); ?>" 
                                         alt="<?php echo esc_attr(get_the_title()); ?>"
                                         loading="lazy">
                                </a>
                            <?php endif; ?>
                            <div class="project-content">
                                <h3 class="project-title"><a href="<?php the_permalink(); ?>"><?php the_title(); ?></a></h3>
                                <div class="project-excerpt"><?php echo wp_trim_words(get_the_excerpt(), 20); ?></div>
                            </div>
                        </article>
                        <?php
                    endwhile;
                    wp_reset_postdata();
                else : ?>
                    <p><?php echo esc_html($texts['no_projects']); ?></p>
                <?php endif; ?>
            </div>
            
            <p style="text-align: center; margin-top: 24px;">
                <a href="<?php echo get_post_type_archive_link('project'); ?>" class="btn btn-outline"><?php echo esc_html($texts['view_all']); ?> →</a>
            </p>
        </div>
    </section>

    <!-- Services Preview Section -->
    <section id="services-preview" class="section section-dark">
        <div class="container">
            <?php
            $services_texts = array(
                'en' => array(
                    'title' => 'Our Services',
                    'description' => 'Specialized processes for exceptional results',
                    'explore' => 'Explore Services',
                    'services' => array(
                        array('icon' => '🔥', 'title' => 'Bronze Casting', 'description' => 'Traditional lost-wax process with artisanal control'),
                        array('icon' => '🎨', 'title' => 'Patinas & Finishing', 'description' => 'Custom colors and textures that reflect your vision'),
                        array('icon' => '🏺', 'title' => 'Ceramic Shell Mold', 'description' => 'High precision for complex geometries'),
                        array('icon' => '🔧', 'title' => 'Restoration', 'description' => 'Conservation and repair of artistic bronze works'),
                        array('icon' => '📐', 'title' => 'Engineering Support', 'description' => 'Technical consulting for artists and designers')
                    )
                ),
                'es' => array(
                    'title' => 'Nuestros Servicios',
                    'description' => 'Procesos especializados para resultados excepcionales',
                    'explore' => 'Explorar Servicios',
                    'services' => array(
                        array('icon' => '🔥', 'title' => 'Fundición en Bronce', 'description' => 'Proceso tradicional a la cera perdida con control artesanal'),
                        array('icon' => '🎨', 'title' => 'Pátinas y Acabados', 'description' => 'Colores y texturas personalizadas que reflejan tu visión'),
                        array('icon' => '🏺', 'title' => 'Molde de Cerámica', 'description' => 'Alta precisión para geometrías complejas'),
                        array('icon' => '🔧', 'title' => 'Restauración', 'description' => 'Conservación y reparación de obras en bronce artístico'),
                        array('icon' => '📐', 'title' => 'Soporte Técnico', 'description' => 'Consultoría técnica para artistas y diseñadores')
                    )
                )
            );
            $texts = isset($services_texts[$current_lang]) ? $services_texts[$current_lang] : $services_texts['en'];
            ?>
            <h2 class="section-title"><?php echo esc_html($texts['title']); ?></h2>
            <p class="section-description"><?php echo esc_html($texts['description']); ?></p>
            
            <div class="services-cards">
                <?php foreach ($texts['services'] as $service) : ?>
                    <div class="service-card">
                        <div class="service-icon"><?php echo $service['icon']; ?></div>
                        <h3 class="service-title"><?php echo esc_html($service['title']); ?></h3>
                        <p class="service-description"><?php echo esc_html($service['description']); ?></p>
                    </div>
                <?php endforeach; ?>
            </div>
            
            <p style="text-align: center; margin-top: 24px;">
                <a href="<?php echo get_post_type_archive_link('service'); ?>" class="btn btn-light"><?php echo esc_html($texts['explore']); ?> →</a>
            </p>
        </div>
    </section>

    <!-- Testimonials Section -->
    <section id="testimonials-preview" class="section">
        <div class="container">
            <?php
            $test_texts = array(
                'en' => array('title' => 'What Our Clients Say', 'coming_soon' => 'Testimonials coming soon.', 'more' => 'More Testimonials'),
                'es' => array('title' => 'Lo Que Dicen Nuestros Clientes', 'coming_soon' => 'Testimonios próximamente.', 'more' => 'Más Testimonios')
            );
            $texts = isset($test_texts[$current_lang]) ? $test_texts[$current_lang] : $test_texts['en'];
            ?>
            <h2 class="section-title"><?php echo esc_html($texts['title']); ?></h2>
            
            <div class="testimonials-carousel">
                <?php
                $testimonials_query = new WP_Query(array(
                    'post_type' => 'testimonial',
                    'posts_per_page' => 3,
                    'orderby' => 'rand'
                ));

                if ($testimonials_query->have_posts()) :
                    while ($testimonials_query->have_posts()) : $testimonials_query->the_post(); ?>
                        <div class="testimonial-card">
                            <div class="testimonial-content"><?php the_content(); ?></div>
                            <div class="testimonial-author">
                                <strong><?php the_title(); ?></strong>
                                <?php
                                $client_title = get_post_meta(get_the_ID(), 'client_title', true);
                                if ($client_title) : ?>
                                    <span><?php echo esc_html($client_title); ?></span>
                                <?php endif; ?>
                            </div>
                        </div>
                        <?php
                    endwhile;
                    wp_reset_postdata();
                else : ?>
                    <p><?php echo esc_html($texts['coming_soon']); ?></p>
                <?php endif; ?>
            </div>
            
            <?php if ($testimonials_query->have_posts()) : ?>
                <p style="text-align: center; margin-top: 24px;">
                    <a href="<?php echo esc_url(get_permalink(function_exists('pll_get_post') && get_page_by_path('testimonials') ? pll_get_post(get_page_by_path('testimonials')->ID) : get_page_by_path('testimonials'))); ?>" class="btn btn-outline"><?php echo esc_html($texts['more']); ?> →</a>
                </p>
            <?php endif; ?>
        </div>
    </section>

    <!-- Blog Preview Section -->
    <section id="blog-preview" class="section">
        <div class="container">
            <?php
            $blog_texts = array(
                'en' => array('title' => 'Technical Insights', 'coming_soon' => 'Blog posts coming soon.', 'view_blog' => 'View Technical Blog'),
                'es' => array('title' => 'Perspectivas Técnicas', 'coming_soon' => 'Artículos próximamente.', 'view_blog' => 'Ver Blog Técnico')
            );
            $texts = isset($blog_texts[$current_lang]) ? $blog_texts[$current_lang] : $blog_texts['en'];
            ?>
            <h2 class="section-title"><?php echo esc_html($texts['title']); ?></h2>
            
            <div class="blog-grid">
                <?php
                $blog_args = array(
                    'post_type' => 'post',
                    'posts_per_page' => 3,
                    'orderby' => 'date',
                    'order' => 'DESC'
                );
                if (function_exists('pll_current_language')) {
                    $blog_args['lang'] = pll_current_language();
                }
                $blog_query = new WP_Query($blog_args);

                if ($blog_query->have_posts()) :
                    while ($blog_query->have_posts()) : $blog_query->the_post(); ?>
                        <article class="blog-card">
                            <?php if (has_post_thumbnail()) : ?>
                                <a href="<?php the_permalink(); ?>" class="blog-thumbnail">
                                    <?php the_post_thumbnail('medium'); ?>
                                </a>
                            <?php endif; ?>
                            <div class="blog-content">
                                <h3 class="blog-title"><a href="<?php the_permalink(); ?>"><?php the_title(); ?></a></h3>
                                <div class="blog-excerpt"><?php echo wp_trim_words(get_the_excerpt(), 20); ?></div>
                            </div>
                        </article>
                        <?php
                    endwhile;
                    wp_reset_postdata();
                else : ?>
                    <p><?php echo esc_html($texts['coming_soon']); ?></p>
                <?php endif; ?>
            </div>
            
            <p style="text-align: center; margin-top: 24px;">
                <a href="<?php echo get_permalink(get_option('page_for_posts')); ?>" class="btn btn-outline"><?php echo esc_html($texts['view_blog']); ?> →</a>
            </p>
        </div>
    </section>

    <!-- Stats Section -->
    <section id="stats" class="section section-dark">
        <div class="container">
            <?php
            $stats_texts = array(
                'en' => array(
                    'title' => 'Excellence in Numbers',
                    'stats' => array(
                        array('number' => '40+', 'label' => 'Years of Experience'),
                        array('number' => '500+', 'label' => 'Completed Projects'),
                        array('number' => '100%', 'label' => 'Client Satisfaction'),
                        array('number' => '15', 'label' => 'Specialized Artisans')
                    )
                ),
                'es' => array(
                    'title' => 'Excelencia en Números',
                    'stats' => array(
                        array('number' => '40+', 'label' => 'Años de Experiencia'),
                        array('number' => '500+', 'label' => 'Proyectos Completados'),
                        array('number' => '100%', 'label' => 'Satisfacción del Cliente'),
                        array('number' => '15', 'label' => 'Artesanos Especializados')
                    )
                )
            );
            $texts = isset($stats_texts[$current_lang]) ? $stats_texts[$current_lang] : $stats_texts['en'];
            ?>
            <h2 class="section-title"><?php echo esc_html($texts['title']); ?></h2>
            
            <div class="stats-grid">
                <?php foreach ($texts['stats'] as $stat) : ?>
                    <div class="stat">
                        <span class="stat-number"><?php echo esc_html($stat['number']); ?></span>
                        <span class="stat-label"><?php echo esc_html($stat['label']); ?></span>
                    </div>
                <?php endforeach; ?>
            </div>
        </div>
    </section>

    <!-- Contact CTA Section -->
    <section id="contact-cta" class="section">
        <div class="container">
            <?php
            $cta_texts = array(
                'en' => array(
                    'title' => 'Ready to Start Your Project?',
                    'description' => 'Contact us for a personalized consultation',
                    'button' => 'Contact Us'
                ),
                'es' => array(
                    'title' => '¿Listo para Iniciar tu Proyecto?',
                    'description' => 'Contáctanos para una consulta personalizada',
                    'button' => 'Contáctanos'
                )
            );
            $texts = isset($cta_texts[$current_lang]) ? $cta_texts[$current_lang] : $cta_texts['en'];
            $contact_page = function_exists('pll_get_post') && get_page_by_path('contact') ? pll_get_post(get_page_by_path('contact')->ID) : (get_page_by_path('contact') ? get_page_by_path('contact')->ID : '');
            ?>
            <h2 class="section-title"><?php echo esc_html($texts['title']); ?></h2>
            <p class="section-description"><?php echo esc_html($texts['description']); ?></p>
            <?php if ($contact_page) : ?>
                <p style="text-align: center;">
                    <a href="<?php echo esc_url(get_permalink($contact_page)); ?>" class="btn btn-primary"><?php echo esc_html($texts['button']); ?></a>
                </p>
            <?php endif; ?>
        </div>
    </section>

</div><!-- .front-page-content -->

<?php get_footer(); ?>
