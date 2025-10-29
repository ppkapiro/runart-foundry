<?php
/**
 * Template Name: Home Page
 * Template for Front Page (Home)
 * 
 * @package RunArt_Base
 */

get_header(); ?>

<div class="front-page-content">
    <!-- Hero Section -->
    <section id="hero" class="hero-section">
        <?php
        // Get hero image from RunMedia
        if (function_exists('runmedia_get_image_by_slug')) {
            $hero_image = runmedia_get_image_by_slug('run-art-foundry-branding', 'w2560');
            $hero_style = $hero_image ? 'background-image: url(' . esc_url($hero_image['url']) . ');' : '';
        } else {
            $hero_style = '';
        }
        ?>
        <div class="hero-background" style="<?php echo $hero_style; ?>"></div>
        <div class="hero-content">
            <h1 class="hero-title"><?php echo get_bloginfo('name'); ?> — <?php esc_html_e('Excellence in Art Casting', 'runart'); ?></h1>
            <p class="hero-subtitle"><?php esc_html_e('We transform artistic visions into the highest quality bronze through traditional techniques and contemporary technology', 'runart'); ?></p>
            <div class="hero-cta">
                <a href="<?php echo esc_url(get_permalink(get_page_by_path('contact'))); ?>" class="btn btn-primary"><?php esc_html_e('Start your consultation', 'runart'); ?></a>
                <a href="#projects" class="btn btn-secondary"><?php esc_html_e('View projects', 'runart'); ?></a>
            </div>
        </div>
    </section>

    <!-- Featured Projects Section -->
    <section id="projects-preview" class="section">
        <div class="container">
            <h2 class="section-title"><?php esc_html_e('Featured Projects', 'runart'); ?></h2>
            <p class="section-description"><?php esc_html_e('We proudly present some of our most demanding and successful works', 'runart'); ?></p>
            
            <div class="projects-grid">
                <?php
                // Query latest 6 projects
                $projects_query = new WP_Query(array(
                    'post_type' => 'project',
                    'posts_per_page' => 6,
                    'orderby' => 'date',
                    'order' => 'DESC'
                ));

                if ($projects_query->have_posts()) :
                    while ($projects_query->have_posts()) : $projects_query->the_post();
                        $project_slug = get_post_field('post_name', get_the_ID());
                        $thumbnail = function_exists('runmedia_get_image_by_slug') ? runmedia_get_image_by_slug($project_slug, 'w800') : null;
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
                    <p><?php esc_html_e('No projects available yet.', 'runart'); ?></p>
                <?php endif; ?>
            </div>
            
            <p><a href="<?php echo get_post_type_archive_link('project'); ?>" class="btn btn-outline"><?php esc_html_e('View all projects', 'runart'); ?> →</a></p>
        </div>
    </section>

    <!-- Services Preview Section -->
    <section id="services-preview" class="section section-dark">
        <div class="container">
            <h2 class="section-title"><?php esc_html_e('Our Services', 'runart'); ?></h2>
            <p class="section-description"><?php esc_html_e('Specialized processes for exceptional results', 'runart'); ?></p>
            
            <div class="services-cards">
                <?php
                $services = array(
                    array('icon' => '🔥', 'title' => __('Bronze Casting', 'runart'), 'description' => __('Traditional lost-wax process with artisanal control', 'runart')),
                    array('icon' => '🎨', 'title' => __('Patinas & Finishing', 'runart'), 'description' => __('Custom colors and textures that reflect your vision', 'runart')),
                    array('icon' => '🏺', 'title' => __('Ceramic Shell Mold', 'runart'), 'description' => __('High precision for complex geometries', 'runart')),
                    array('icon' => '🔧', 'title' => __('Restoration', 'runart'), 'description' => __('Conservation and repair of artistic bronze works', 'runart')),
                    array('icon' => '📐', 'title' => __('Engineering Support', 'runart'), 'description' => __('Technical consulting for artists and designers', 'runart'))
                );

                foreach ($services as $service) : ?>
                    <div class="service-card">
                        <div class="service-icon"><?php echo $service['icon']; ?></div>
                        <h3 class="service-title"><?php echo esc_html($service['title']); ?></h3>
                        <p class="service-description"><?php echo esc_html($service['description']); ?></p>
                    </div>
                <?php endforeach; ?>
            </div>
            
            <p><a href="<?php echo get_post_type_archive_link('service'); ?>" class="btn btn-light"><?php esc_html_e('Explore services', 'runart'); ?> →</a></p>
        </div>
    </section>

    <!-- Testimonials Section -->
    <section id="testimonials-preview" class="section">
        <div class="container">
            <h2 class="section-title"><?php esc_html_e('What Our Clients Say', 'runart'); ?></h2>
            
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
                    <p><?php esc_html_e('Testimonials coming soon.', 'runart'); ?></p>
                <?php endif; ?>
            </div>
            
            <p><a href="<?php echo esc_url(get_permalink(get_page_by_path('testimonials'))); ?>" class="btn btn-outline"><?php esc_html_e('More testimonials', 'runart'); ?> →</a></p>
        </div>
    </section>

    <!-- Blog Preview Section -->
    <section id="blog-preview" class="section">
        <div class="container">
            <h2 class="section-title"><?php esc_html_e('Technical Insights', 'runart'); ?></h2>
            
            <div class="blog-grid">
                <?php
                $blog_query = new WP_Query(array(
                    'post_type' => 'post',
                    'posts_per_page' => 3,
                    'orderby' => 'date',
                    'order' => 'DESC'
                ));

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
                    <p><?php esc_html_e('Blog posts coming soon.', 'runart'); ?></p>
                <?php endif; ?>
            </div>
            
            <p><a href="<?php echo get_permalink(get_option('page_for_posts')); ?>" class="btn btn-outline"><?php esc_html_e('View technical blog', 'runart'); ?> →</a></p>
        </div>
    </section>

    <!-- Stats Section -->
    <section id="stats" class="section section-dark">
        <div class="container">
            <h2 class="section-title"><?php esc_html_e('Excellence in Numbers', 'runart'); ?></h2>
            
            <div class="stats-grid">
                <div class="stat">
                    <span class="stat-number">40+</span>
                    <span class="stat-label"><?php esc_html_e('Years of experience', 'runart'); ?></span>
                </div>
                <div class="stat">
                    <span class="stat-number">500+</span>
                    <span class="stat-label"><?php esc_html_e('Completed projects', 'runart'); ?></span>
                </div>
                <div class="stat">
                    <span class="stat-number">100%</span>
                    <span class="stat-label"><?php esc_html_e('Client satisfaction', 'runart'); ?></span>
                </div>
                <div class="stat">
                    <span class="stat-number">15</span>
                    <span class="stat-label"><?php esc_html_e('Specialized artisans', 'runart'); ?></span>
                </div>
            </div>
        </div>
    </section>

    <!-- Contact CTA Section -->
    <section id="contact-cta" class="section section-dark">
        <div class="container">
            <h2 class="section-title"><?php esc_html_e('Ready to start your project?', 'runart'); ?></h2>
            <p class="section-description"><?php esc_html_e('Contact us for a personalized consultation', 'runart'); ?></p>
            <p><a href="<?php echo esc_url(get_permalink(get_page_by_path('contact'))); ?>" class="btn btn-primary"><?php esc_html_e('Contact us', 'runart'); ?></a></p>
        </div>
    </section>

</div><!-- .front-page-content -->

<?php get_footer(); ?>
