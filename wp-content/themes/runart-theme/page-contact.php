<?php
/**
 * Template Name: Contact Page
 * Description: Contact RUN Art Foundry — Form, map, information
 *
 * @package RUNArtFoundry
 */

get_header();

$lang = function_exists('pll_current_language') ? pll_current_language() : 'en';
?>

<div class="contact-page">
    
    <!-- Hero Section -->
    <section class="contact-hero">
        <div class="contact-hero-background">
            <?php
            // Hero: exterior del taller o imagen de branding
            $hero_url = runmedia_get_url( null, 'run-art-foundry-branding', null, 'w2560', 'webp', 0 );
            
            if ( $hero_url ) :
                $hero_alt = $lang === 'es' 
                    ? 'Contacto — RUN Art Foundry Fundición Artística en Miami' 
                    : 'Contact — RUN Art Foundry Artistic Foundry in Miami';
                ?>
                <img src="<?php echo esc_url( $hero_url ); ?>" 
                     alt="<?php echo esc_attr( $hero_alt ); ?>" 
                     loading="eager" />
            <?php endif; ?>
        </div>
        <div class="contact-hero-content">
            <h1 class="contact-hero-title">
                <?php echo $lang === 'es' 
                    ? 'Inicia tu Consulta Gratuita' 
                    : 'Start Your Free Consultation'; ?>
            </h1>
            <p class="contact-hero-subtitle">
                <?php echo $lang === 'es'
                    ? 'Cuéntanos sobre tu proyecto. Nuestro equipo de expertos te responderá en menos de 24 horas.'
                    : 'Tell us about your project. Our expert team will respond within 24 hours.'; ?>
            </p>
        </div>
    </section>
    
    <!-- Main Content -->
    <div class="container">
        
        <!-- Contact Info + Form Section -->
        <section class="contact-section contact-main">
            
            <div class="contact-info">
                <h2><?php echo $lang === 'es' ? 'Información de Contacto' : 'Contact Information'; ?></h2>
                
                <div class="contact-info-item">
                    <div class="contact-info-icon">📍</div>
                    <div class="contact-info-content">
                        <h3><?php echo $lang === 'es' ? 'Ubicación' : 'Location'; ?></h3>
                        <p>
                            RUN Art Foundry<br>
                            3901 NW 25th Street<br>
                            Miami, FL 33142<br>
                            United States
                        </p>
                    </div>
                </div>
                
                <div class="contact-info-item">
                    <div class="contact-info-icon">📧</div>
                    <div class="contact-info-content">
                        <h3><?php echo $lang === 'es' ? 'Correo Electrónico' : 'Email'; ?></h3>
                        <p><a href="mailto:info@runartfoundry.com">info@runartfoundry.com</a></p>
                    </div>
                </div>
                
                <div class="contact-info-item">
                    <div class="contact-info-icon">📞</div>
                    <div class="contact-info-content">
                        <h3><?php echo $lang === 'es' ? 'Teléfono' : 'Phone'; ?></h3>
                        <p><a href="tel:+13056334646">+1 (305) 633-4646</a></p>
                    </div>
                </div>
                
                <div class="contact-info-item">
                    <div class="contact-info-icon">🕐</div>
                    <div class="contact-info-content">
                        <h3><?php echo $lang === 'es' ? 'Horario' : 'Hours'; ?></h3>
                        <p>
                            <?php echo $lang === 'es' ? 'Lunes – Viernes' : 'Monday – Friday'; ?>: 8:00 AM – 5:00 PM<br>
                            <?php echo $lang === 'es' ? 'Sábado – Domingo' : 'Saturday – Sunday'; ?>: <?php echo $lang === 'es' ? 'Cerrado (citas disponibles)' : 'Closed (appointments available)'; ?>
                        </p>
                    </div>
                </div>
                
                <div class="contact-info-item">
                    <div class="contact-info-icon">💬</div>
                    <div class="contact-info-content">
                        <h3>WhatsApp</h3>
                        <p><a href="https://wa.me/13056334646" target="_blank" rel="noopener">+1 (305) 633-4646</a></p>
                    </div>
                </div>
                
            </div>
            
            <div class="contact-form-wrapper">
                <h2><?php echo $lang === 'es' ? 'Envíanos un Mensaje' : 'Send Us a Message'; ?></h2>
                
                <form class="contact-form" method="post" action="#">
                    <div class="form-row">
                        <div class="form-group">
                            <label for="contact-name"><?php echo $lang === 'es' ? 'Nombre Completo' : 'Full Name'; ?> *</label>
                            <input type="text" id="contact-name" name="name" required>
                        </div>
                        <div class="form-group">
                            <label for="contact-email"><?php echo $lang === 'es' ? 'Correo Electrónico' : 'Email'; ?> *</label>
                            <input type="email" id="contact-email" name="email" required>
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="contact-phone"><?php echo $lang === 'es' ? 'Teléfono' : 'Phone'; ?></label>
                            <input type="tel" id="contact-phone" name="phone">
                        </div>
                        <div class="form-group">
                            <label for="contact-project-type"><?php echo $lang === 'es' ? 'Tipo de Proyecto' : 'Project Type'; ?></label>
                            <select id="contact-project-type" name="project_type">
                                <option value=""><?php echo $lang === 'es' ? '-- Seleccionar --' : '-- Select --'; ?></option>
                                <option value="casting"><?php echo $lang === 'es' ? 'Fundición nueva' : 'New casting'; ?></option>
                                <option value="patina"><?php echo $lang === 'es' ? 'Pátina / Acabado' : 'Patina / Finishing'; ?></option>
                                <option value="restoration"><?php echo $lang === 'es' ? 'Restauración' : 'Restoration'; ?></option>
                                <option value="consulting"><?php echo $lang === 'es' ? 'Consultoría técnica' : 'Technical consulting'; ?></option>
                                <option value="other"><?php echo $lang === 'es' ? 'Otro' : 'Other'; ?></option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="contact-message"><?php echo $lang === 'es' ? 'Mensaje' : 'Message'; ?> *</label>
                        <textarea id="contact-message" name="message" rows="6" required></textarea>
                    </div>
                    
                    <button type="submit" class="btn btn-primary btn-lg">
                        <?php echo $lang === 'es' ? 'Enviar Mensaje' : 'Send Message'; ?>
                    </button>
                </form>
                
                <p class="contact-form-note">
                    <small>
                        <?php echo $lang === 'es'
                            ? '* Campos obligatorios. Responderemos en menos de 24 horas hábiles.'
                            : '* Required fields. We will respond within 24 business hours.'; ?>
                    </small>
                </p>
            </div>
            
        </section>
        
        <!-- Map Section -->
        <section class="contact-section contact-map">
            <h2><?php echo $lang === 'es' ? 'Encuéntranos' : 'Find Us'; ?></h2>
            <div class="map-container">
                <iframe 
                    src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3591.8523456789!2d-80.25123456789!3d25.8123456789!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x0%3A0x0!2zMjXCsDQ4JzQ0LjQiTiA4MMKwMTUnMDQuNCJX!5e0!3m2!1sen!2sus!4v1234567890123!5m2!1sen!2sus"
                    width="100%" 
                    height="450" 
                    style="border:0;" 
                    allowfullscreen="" 
                    loading="lazy" 
                    referrerpolicy="no-referrer-when-downgrade">
                </iframe>
            </div>
            <p class="map-note">
                <?php echo $lang === 'es'
                    ? 'Estamos ubicados en el corazón del distrito industrial de Miami, a 10 minutos del aeropuerto internacional.'
                    : 'We are located in the heart of Miami\'s industrial district, 10 minutes from the international airport.'; ?>
            </p>
        </section>
        
        <!-- Why Choose Us Section -->
        <section class="contact-section contact-reasons">
            <h2><?php echo $lang === 'es' ? '¿Por Qué Elegir RUN Art Foundry?' : 'Why Choose RUN Art Foundry?'; ?></h2>
            
            <div class="reasons-grid">
                <?php
                $reasons = $lang === 'es'
                    ? array(
                        array( 'icon' => '✅', 'title' => 'Consulta Gratuita', 'desc' => 'Evaluación técnica sin compromiso para todos los proyectos' ),
                        array( 'icon' => '🎓', 'title' => '30+ Años Experiencia', 'desc' => 'Equipo experto en todas las técnicas de fundición artística' ),
                        array( 'icon' => '🌍', 'title' => 'Alcance Internacional', 'desc' => 'Proyectos entregados en 15 países de 4 continentes' ),
                        array( 'icon' => '🔬', 'title' => 'Tecnología Avanzada', 'desc' => 'Equipamiento de precisión para control técnico total' ),
                        array( 'icon' => '⚡', 'title' => 'Respuesta Rápida', 'desc' => 'Cotizaciones técnicas en menos de 48 horas' ),
                        array( 'icon' => '💎', 'title' => 'Calidad Garantizada', 'desc' => 'Inspección exhaustiva antes de cada entrega' ),
                    )
                    : array(
                        array( 'icon' => '✅', 'title' => 'Free Consultation', 'desc' => 'Technical evaluation with no obligation for all projects' ),
                        array( 'icon' => '🎓', 'title' => '30+ Years Experience', 'desc' => 'Expert team in all artistic casting techniques' ),
                        array( 'icon' => '🌍', 'title' => 'International Reach', 'desc' => 'Projects delivered in 15 countries across 4 continents' ),
                        array( 'icon' => '🔬', 'title' => 'Advanced Technology', 'desc' => 'Precision equipment for complete technical control' ),
                        array( 'icon' => '⚡', 'title' => 'Fast Response', 'desc' => 'Technical quotes within 48 hours' ),
                        array( 'icon' => '💎', 'title' => 'Quality Guaranteed', 'desc' => 'Exhaustive inspection before every delivery' ),
                    );
                
                foreach ( $reasons as $reason ) :
                    ?>
                    <div class="reason-card">
                        <div class="reason-icon"><?php echo $reason['icon']; ?></div>
                        <h3><?php echo esc_html( $reason['title'] ); ?></h3>
                        <p><?php echo esc_html( $reason['desc'] ); ?></p>
                    </div>
                    <?php
                endforeach;
                ?>
            </div>
        </section>
        
        <!-- CTA Projects -->
        <section class="contact-section contact-cta">
            <h2><?php echo $lang === 'es' ? 'Explora Nuestro Trabajo' : 'Explore Our Work'; ?></h2>
            <p>
                <?php echo $lang === 'es'
                    ? 'Descubre proyectos realizados para artistas internacionales reconocidos'
                    : 'Discover projects created for internationally recognized artists'; ?>
            </p>
            <a href="<?php echo esc_url( get_post_type_archive_link('project') ); ?>" class="btn btn-primary btn-lg">
                <?php echo $lang === 'es' ? 'Ver Proyectos' : 'View Projects'; ?>
            </a>
        </section>
        
    </div><!-- .container -->
    
</div><!-- .contact-page -->

<?php
get_footer();
