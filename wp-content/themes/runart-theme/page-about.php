<?php
/**
 * Template Name: About Page
 * Description: About RUN Art Foundry — Workshop, process, team
 *
 * @package RUNArtFoundry
 */

get_header();

$lang = function_exists('pll_current_language') ? pll_current_language() : 'en';
?>

<div class="about-page">
    
    <!-- Hero Section -->
    <section class="about-hero">
        <div class="about-hero-background">
            <?php
            // Hero: imagen del taller (usar imagen de bronze-casting o run-art-foundry-branding)
            $hero_url = runmedia_get_url( null, 'bronze-casting', null, 'w2560', 'webp', 0 );
            if ( ! $hero_url ) {
                $hero_url = runmedia_get_url( null, 'run-art-foundry-branding', null, 'w2560', 'webp', 1 );
            }
            
            if ( $hero_url ) :
                $hero_alt = $lang === 'es' 
                    ? 'Taller de fundición artística RUN Art Foundry — Más de 30 años de experiencia' 
                    : 'RUN Art Foundry artistic casting workshop — Over 30 years of experience';
                ?>
                <img src="<?php echo esc_url( $hero_url ); ?>" 
                     alt="<?php echo esc_attr( $hero_alt ); ?>" 
                     loading="eager" />
            <?php endif; ?>
        </div>
        <div class="about-hero-content">
            <h1 class="about-hero-title">
                <?php echo $lang === 'es' 
                    ? 'Excelencia en Fundición Artística Desde 1994' 
                    : 'Excellence in Artistic Casting Since 1994'; ?>
            </h1>
            <p class="about-hero-subtitle">
                <?php echo $lang === 'es'
                    ? 'Tres décadas transformando visiones artísticas en esculturas permanentes de bronce'
                    : 'Three decades transforming artistic visions into permanent bronze sculptures'; ?>
            </p>
        </div>
    </section>
    
    <!-- Main Content -->
    <div class="container">
        
        <!-- Our Story Section -->
        <section class="about-section about-story">
            <div class="about-content-text">
                <h2><?php echo $lang === 'es' ? 'Nuestra Historia' : 'Our Story'; ?></h2>
                <?php if ( $lang === 'es' ) : ?>
                <p>RUN Art Foundry fue fundada en 1994 por el maestro fundidor Ramón Urquiza en Miami, Florida. Con más de 30 años de experiencia en fundición artística de bronce, hemos trabajado con artistas reconocidos internacionalmente para crear esculturas que van desde piezas de galería hasta monumentos públicos monumentales.</p>
                <p>Nuestra fundición combina técnicas tradicionales de cera perdida con tecnología contemporánea de moldeo y acabado. Cada proyecto recibe atención personalizada desde el concepto inicial hasta la instalación final, garantizando que la visión del artista se preserve con la máxima fidelidad técnica y artística.</p>
                <p>Nos especializamos en fundición de bronce a pequeña y gran escala, restauración de esculturas históricas, desarrollo de pátinas artísticas, y consultoría técnica integral para proyectos escultóricos complejos.</p>
                <?php else : ?>
                <p>RUN Art Foundry was founded in 1994 by master founder Ramón Urquiza in Miami, Florida. With over 30 years of experience in artistic bronze casting, we have worked with internationally recognized artists to create sculptures ranging from gallery pieces to monumental public monuments.</p>
                <p>Our foundry combines traditional lost-wax techniques with contemporary molding and finishing technology. Each project receives personalized attention from initial concept to final installation, ensuring that the artist's vision is preserved with the highest technical and artistic fidelity.</p>
                <p>We specialize in small and large-scale bronze casting, restoration of historical sculptures, development of artistic patinas, and comprehensive technical consulting for complex sculptural projects.</p>
                <?php endif; ?>
            </div>
            
            <div class="about-content-images">
                <?php
                // Galería de imágenes del taller/proceso
                $gallery_services = array( 'bronze-casting', 'wax-casting', 'patina', 'welding-polish' );
                foreach ( $gallery_services as $i => $service_slug ) {
                    $img_url = runmedia_get_url( null, null, $service_slug, 'w800', 'webp', $i );
                    $img_alt = runmedia_get_alt( null, null, $service_slug, $lang, $i );
                    
                    if ( $img_url ) :
                        ?>
                        <figure class="about-gallery-item">
                            <img src="<?php echo esc_url( $img_url ); ?>" 
                                 alt="<?php echo esc_attr( $img_alt ); ?>" 
                                 loading="lazy" />
                        </figure>
                        <?php
                    endif;
                }
                ?>
            </div>
        </section>
        
        <!-- Process Timeline -->
        <section class="about-section about-process">
            <h2><?php echo $lang === 'es' ? 'Nuestro Proceso' : 'Our Process'; ?></h2>
            <p class="section-intro">
                <?php echo $lang === 'es' 
                    ? 'Desde el modelo original hasta la escultura terminada, cada paso es ejecutado con precisión artesanal'
                    : 'From the original model to the finished sculpture, each step is executed with artisan precision'; ?>
            </p>
            
            <div class="process-timeline">
                <?php
                $process_steps = $lang === 'es' 
                    ? array(
                        array( 'title' => 'Consulta Inicial', 'desc' => 'Evaluación del proyecto, planificación técnica y cotización detallada' ),
                        array( 'title' => 'Moldeo en Caucho', 'desc' => 'Creación de moldes flexibles de silicona a partir del original' ),
                        array( 'title' => 'Reproducción en Cera', 'desc' => 'Inyección de cera en moldes para crear réplicas exactas' ),
                        array( 'title' => 'Cáscara Cerámica', 'desc' => 'Construcción de molde cerámico resistente al calor mediante inmersiones sucesivas' ),
                        array( 'title' => 'Fundición', 'desc' => 'Colada de bronce fundido a 1200°C en moldes cerámicos' ),
                        array( 'title' => 'Soldadura y Acabado', 'desc' => 'Ensamblaje de piezas, reparación de superficies y pulido' ),
                        array( 'title' => 'Pátina Artística', 'desc' => 'Aplicación de acabados químicos tradicionales para color y protección' ),
                        array( 'title' => 'Control de Calidad', 'desc' => 'Inspección final, documentación fotográfica y preparación para entrega' ),
                    )
                    : array(
                        array( 'title' => 'Initial Consultation', 'desc' => 'Project evaluation, technical planning and detailed quote' ),
                        array( 'title' => 'Rubber Molding', 'desc' => 'Creation of flexible silicone molds from original' ),
                        array( 'title' => 'Wax Reproduction', 'desc' => 'Wax injection into molds to create exact replicas' ),
                        array( 'title' => 'Ceramic Shell', 'desc' => 'Construction of heat-resistant ceramic mold through successive dipping' ),
                        array( 'title' => 'Casting', 'desc' => 'Pouring molten bronze at 1200°C into ceramic molds' ),
                        array( 'title' => 'Welding & Finishing', 'desc' => 'Assembly of pieces, surface repair and polishing' ),
                        array( 'title' => 'Artistic Patina', 'desc' => 'Application of traditional chemical finishes for color and protection' ),
                        array( 'title' => 'Quality Control', 'desc' => 'Final inspection, photographic documentation and delivery preparation' ),
                    );
                
                foreach ( $process_steps as $i => $step ) :
                    ?>
                    <div class="process-step">
                        <div class="process-step-number"><?php echo $i + 1; ?></div>
                        <h3 class="process-step-title"><?php echo esc_html( $step['title'] ); ?></h3>
                        <p class="process-step-desc"><?php echo esc_html( $step['desc'] ); ?></p>
                    </div>
                    <?php
                endforeach;
                ?>
            </div>
        </section>
        
        <!-- Values Section -->
        <section class="about-section about-values">
            <h2><?php echo $lang === 'es' ? 'Nuestros Valores' : 'Our Values'; ?></h2>
            
            <div class="values-grid">
                <?php
                $values = $lang === 'es'
                    ? array(
                        array( 'icon' => '🎯', 'title' => 'Precisión Técnica', 'desc' => 'Control total de cada fase del proceso de fundición' ),
                        array( 'icon' => '🤝', 'title' => 'Colaboración Artística', 'desc' => 'Trabajo cercano con artistas para preservar su visión' ),
                        array( 'icon' => '🔬', 'title' => 'Innovación', 'desc' => 'Integración de técnicas tradicionales con tecnología contemporánea' ),
                        array( 'icon' => '♻️', 'title' => 'Sostenibilidad', 'desc' => 'Prácticas responsables de gestión de materiales y residuos' ),
                    )
                    : array(
                        array( 'icon' => '🎯', 'title' => 'Technical Precision', 'desc' => 'Complete control of every phase of the casting process' ),
                        array( 'icon' => '🤝', 'title' => 'Artistic Collaboration', 'desc' => 'Close work with artists to preserve their vision' ),
                        array( 'icon' => '🔬', 'title' => 'Innovation', 'desc' => 'Integration of traditional techniques with contemporary technology' ),
                        array( 'icon' => '♻️', 'title' => 'Sustainability', 'desc' => 'Responsible materials and waste management practices' ),
                    );
                
                foreach ( $values as $value ) :
                    ?>
                    <div class="value-card">
                        <div class="value-icon"><?php echo $value['icon']; ?></div>
                        <h3><?php echo esc_html( $value['title'] ); ?></h3>
                        <p><?php echo esc_html( $value['desc'] ); ?></p>
                    </div>
                    <?php
                endforeach;
                ?>
            </div>
        </section>
        
        <!-- Stats Section -->
        <section class="about-section about-stats">
            <div class="stats-grid">
                <div class="stat-item">
                    <span class="stat-number">30+</span>
                    <span class="stat-label"><?php echo $lang === 'es' ? 'Años Experiencia' : 'Years Experience'; ?></span>
                </div>
                <div class="stat-item">
                    <span class="stat-number">500+</span>
                    <span class="stat-label"><?php echo $lang === 'es' ? 'Proyectos' : 'Projects'; ?></span>
                </div>
                <div class="stat-item">
                    <span class="stat-number">100+</span>
                    <span class="stat-label"><?php echo $lang === 'es' ? 'Artistas' : 'Artists'; ?></span>
                </div>
                <div class="stat-item">
                    <span class="stat-number">15</span>
                    <span class="stat-label"><?php echo $lang === 'es' ? 'Países' : 'Countries'; ?></span>
                </div>
            </div>
        </section>
        
        <!-- CTA Section -->
        <section class="about-section about-cta">
            <h2><?php echo $lang === 'es' ? '¿Listo para Comenzar tu Proyecto?' : 'Ready to Start Your Project?'; ?></h2>
            <p>
                <?php echo $lang === 'es'
                    ? 'Contáctanos para una consulta técnica gratuita y descubre cómo podemos transformar tu visión artística en bronce permanente.'
                    : 'Contact us for a free technical consultation and discover how we can transform your artistic vision into permanent bronze.'; ?>
            </p>
            <div class="about-cta-buttons">
                <a href="<?php echo esc_url( runart_get_contact_url_for_lang( $lang ) ); ?>" class="btn btn-primary btn-lg">
                    <?php echo $lang === 'es' ? 'Contactar Ahora' : 'Contact Now'; ?>
                </a>
                <a href="<?php echo esc_url( get_post_type_archive_link('project') ); ?>" class="btn btn-secondary btn-lg">
                    <?php echo $lang === 'es' ? 'Ver Proyectos' : 'View Projects'; ?>
                </a>
            </div>
        </section>
        
    </div><!-- .container -->
    
</div><!-- .about-page -->

<?php
get_footer();
