<?php
/**
 * Template Name: Contact Page
 * Bilingual contact page template with hero, form, map and info.
 *
 * @package RunArt_Base
 */

get_header();

// Detect current language
$current_lang = function_exists('pll_current_language') ? pll_current_language() : 'en';

// Bilingual content
$content = array(
    'en' => array(
        'hero_title' => 'Contact Us',
        'hero_subtitle' => 'Start your consultation with our team of master artisans.',
        'form_title' => 'Send a Message',
        'name_label' => 'Name',
        'email_label' => 'Email',
        'phone_label' => 'Phone',
        'message_label' => 'Message',
        'send_button' => 'Send Message',
        'visit_title' => 'Visit the Workshop',
        'email_label_short' => 'Email',
        'phone_label_short' => 'Phone',
        'hours_label' => 'Hours',
        'hours_value' => 'Monday–Friday: 9:00 AM – 6:00 PM',
        'address_label' => 'Address',
        'address_value' => '123 Foundry Lane, Los Angeles, CA 90001',
        'why_title' => 'Why Choose RUN Art Foundry',
        'reasons' => array(
            'Lost-wax casting expertise',
            'Custom patina mastery',
            'Engineering support',
            'Rigorous quality control',
            'On-time delivery',
            'Art-first approach'
        )
    ),
    'es' => array(
        'hero_title' => 'Contáctanos',
        'hero_subtitle' => 'Inicia tu consulta con nuestro equipo de maestros artesanos.',
        'form_title' => 'Enviar Mensaje',
        'name_label' => 'Nombre',
        'email_label' => 'Correo Electrónico',
        'phone_label' => 'Teléfono',
        'message_label' => 'Mensaje',
        'send_button' => 'Enviar Mensaje',
        'visit_title' => 'Visita el Taller',
        'email_label_short' => 'Correo',
        'phone_label_short' => 'Teléfono',
        'hours_label' => 'Horario',
        'hours_value' => 'Lunes a Viernes: 9:00 AM – 6:00 PM',
        'address_label' => 'Dirección',
        'address_value' => '123 Foundry Lane, Los Ángeles, CA 90001',
        'why_title' => 'Por Qué Elegir RUN Art Foundry',
        'reasons' => array(
            'Experiencia en fundición a la cera perdida',
            'Maestría en pátinas personalizadas',
            'Soporte de ingeniería',
            'Control de calidad riguroso',
            'Entrega puntual',
            'Enfoque prioritario en el arte'
        )
    )
);

$c = $content[$current_lang];
?>

<div class="contact-page">
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

    <!-- Contact Form + Info -->
    <section class="contact-section">
        <div class="container">
            <div class="contact-grid">
                <!-- Contact Form -->
                <div class="contact-form-wrapper">
                    <h2 class="section-title"><?php echo esc_html($c['form_title']); ?></h2>
                    <div class="form-card">
                        <?php
                        // Try Contact Form 7
                        $cf7_rendered = false;
                        if (function_exists('do_shortcode')) {
                            $cf7_ids = array(
                                'en' => '[contact-form-7 id="contact" title="Contact"]',
                                'es' => '[contact-form-7 id="contacto" title="Contacto"]'
                            );
                            $cf7_output = do_shortcode($cf7_ids[$current_lang]);
                            if ($cf7_output && strpos($cf7_output, 'wpcf7') !== false) {
                                echo $cf7_output;
                                $cf7_rendered = true;
                            }
                        }
                        
                        // Fallback form
                        if (!$cf7_rendered):
                        ?>
                            <form class="contact-form" action="mailto:team@runartfoundry.com" method="post" enctype="text/plain">
                                <div class="form-group">
                                    <label for="contact-name"><?php echo esc_html($c['name_label']); ?></label>
                                    <input type="text" id="contact-name" name="name" required>
                                </div>
                                <div class="form-group">
                                    <label for="contact-email"><?php echo esc_html($c['email_label']); ?></label>
                                    <input type="email" id="contact-email" name="email" required>
                                </div>
                                <div class="form-group">
                                    <label for="contact-phone"><?php echo esc_html($c['phone_label']); ?></label>
                                    <input type="tel" id="contact-phone" name="phone">
                                </div>
                                <div class="form-group">
                                    <label for="contact-message"><?php echo esc_html($c['message_label']); ?></label>
                                    <textarea id="contact-message" name="message" rows="6" required></textarea>
                                </div>
                                <button type="submit" class="btn btn-primary"><?php echo esc_html($c['send_button']); ?></button>
                            </form>
                        <?php endif; ?>
                    </div>
                </div>

                <!-- Contact Info + Map -->
                <div class="contact-info-wrapper">
                    <h2 class="section-title"><?php echo esc_html($c['visit_title']); ?></h2>
                    
                    <!-- Map -->
                    <div class="map-wrapper">
                        <iframe 
                            src="https://maps.google.com/maps?q=Los%20Angeles&t=&z=13&ie=UTF8&iwloc=&output=embed" 
                            style="border:0;width:100%;height:100%;" 
                            loading="lazy" 
                            referrerpolicy="no-referrer-when-downgrade"
                            title="<?php echo esc_attr($c['visit_title']); ?>">
                        </iframe>
                    </div>

                    <!-- Contact Info Cards -->
                    <div class="info-cards">
                        <div class="info-card">
                            <div class="info-icon">✉</div>
                            <div class="info-content">
                                <h3><?php echo esc_html($c['email_label_short']); ?></h3>
                                <p>team@runartfoundry.com</p>
                            </div>
                        </div>
                        <div class="info-card">
                            <div class="info-icon">📞</div>
                            <div class="info-content">
                                <h3><?php echo esc_html($c['phone_label_short']); ?></h3>
                                <p>+1 (555) 000-0000</p>
                            </div>
                        </div>
                        <div class="info-card">
                            <div class="info-icon">🕒</div>
                            <div class="info-content">
                                <h3><?php echo esc_html($c['hours_label']); ?></h3>
                                <p><?php echo esc_html($c['hours_value']); ?></p>
                            </div>
                        </div>
                        <div class="info-card">
                            <div class="info-icon">📍</div>
                            <div class="info-content">
                                <h3><?php echo esc_html($c['address_label']); ?></h3>
                                <p><?php echo esc_html($c['address_value']); ?></p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Why Choose Us Section -->
    <section class="why-section">
        <div class="container">
            <h2 class="section-title"><?php echo esc_html($c['why_title']); ?></h2>
            <div class="reasons-grid">
                <?php foreach ($c['reasons'] as $reason): ?>
                    <div class="reason-card">
                        <span class="reason-icon">✓</span>
                        <p><?php echo esc_html($reason); ?></p>
                    </div>
                <?php endforeach; ?>
            </div>
        </div>
    </section>
</div>

<?php get_footer(); ?>
