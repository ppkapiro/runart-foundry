</main><!-- #main-content -->

<footer id="site-footer" class="site-footer">
    <div class="footer-container">
        
        <!-- Footer Top: Logo + Info + Social -->
        <div class="footer-top">
            
            <!-- Logo Column -->
            <div class="footer-column footer-branding">
                <?php
                $logo_url = runmedia_get_url( null, 'run-art-foundry-branding', null, 'w600', 'webp', 0 );
                if ( $logo_url ) :
                    $lang = function_exists('pll_current_language') ? pll_current_language() : 'en';
                    $logo_alt = $lang === 'es' ? 'RUN Art Foundry Logo' : 'RUN Art Foundry Logo';
                    ?>
                    <img src="<?php echo esc_url( $logo_url ); ?>" 
                         alt="<?php echo esc_attr( $logo_alt ); ?>" 
                         class="footer-logo" />
                <?php else : ?>
                    <h3><?php bloginfo( 'name' ); ?></h3>
                <?php endif; ?>
                
                <p class="footer-tagline">
                    <?php 
                    $lang = function_exists('pll_current_language') ? pll_current_language() : 'en';
                    if ( $lang === 'es' ) :
                        echo 'Fundición artística en bronce desde 1990. Miami, Florida.';
                    else :
                        echo 'Artistic bronze casting since 1990. Miami, Florida.';
                    endif;
                    ?>
                </p>
            </div>

            <!-- Contact Info Column -->
            <div class="footer-column footer-contact">
                <h4 class="footer-title">
                    <?php echo $lang === 'es' ? 'Contacto' : 'Contact'; ?>
                </h4>
                <ul class="footer-contact-list">
                    <li>
                        <i class="icon-location" aria-hidden="true"></i>
                        <a href="https://maps.google.com/?q=3840+NW+25th+St,+Miami,+FL+33142" target="_blank" rel="noopener">
                            3840 NW 25th St, Miami, FL 33142
                        </a>
                    </li>
                    <li>
                        <i class="icon-email" aria-hidden="true"></i>
                        <a href="mailto:info@runartfoundry.com">info@runartfoundry.com</a>
                    </li>
                    <li>
                        <i class="icon-phone" aria-hidden="true"></i>
                        <a href="tel:+13056338879">+1 (305) 633-8879</a>
                    </li>
                    <li>
                        <i class="icon-whatsapp" aria-hidden="true"></i>
                        <a href="https://wa.me/13056338879" target="_blank" rel="noopener">
                            <?php echo $lang === 'es' ? 'WhatsApp' : 'WhatsApp'; ?>
                        </a>
                    </li>
                </ul>
            </div>

            <!-- Quick Links Column -->
            <div class="footer-column footer-links">
                <h4 class="footer-title">
                    <?php echo $lang === 'es' ? 'Enlaces Rápidos' : 'Quick Links'; ?>
                </h4>
                <?php
                wp_nav_menu( array(
                    'theme_location' => 'footer',
                    'menu_class'     => 'footer-menu',
                    'container'      => false,
                    'depth'          => 1,
                    'fallback_cb'    => '__return_false',
                ) );
                ?>
            </div>

            <!-- Social Links Column -->
            <div class="footer-column footer-social">
                <h4 class="footer-title">
                    <?php echo $lang === 'es' ? 'Síguenos' : 'Follow Us'; ?>
                </h4>
                <div class="social-links">
                    <a href="https://www.facebook.com/runartfoundry" target="_blank" rel="noopener" aria-label="Facebook">
                        <i class="icon-facebook" aria-hidden="true"></i>
                    </a>
                    <a href="https://www.instagram.com/runartfoundry" target="_blank" rel="noopener" aria-label="Instagram">
                        <i class="icon-instagram" aria-hidden="true"></i>
                    </a>
                    <a href="https://www.linkedin.com/company/run-art-foundry" target="_blank" rel="noopener" aria-label="LinkedIn">
                        <i class="icon-linkedin" aria-hidden="true"></i>
                    </a>
                    <a href="https://www.youtube.com/@runartfoundry" target="_blank" rel="noopener" aria-label="YouTube">
                        <i class="icon-youtube" aria-hidden="true"></i>
                    </a>
                </div>
            </div>

        </div><!-- .footer-top -->

        <!-- Footer Bottom: Copyright + Legal -->
        <div class="footer-bottom">
            <div class="footer-bottom-content">
                <p class="copyright">
                    &copy; <?php echo date('Y'); ?> RUN Art Foundry. 
                    <?php echo $lang === 'es' ? 'Todos los derechos reservados.' : 'All rights reserved.'; ?>
                </p>
                <nav class="footer-legal">
                    <a href="<?php echo esc_url( get_privacy_policy_url() ); ?>">
                        <?php echo $lang === 'es' ? 'Política de Privacidad' : 'Privacy Policy'; ?>
                    </a>
                    <span class="separator">|</span>
                    <a href="<?php echo esc_url( home_url( '/terms/' ) ); ?>">
                        <?php echo $lang === 'es' ? 'Términos y Condiciones' : 'Terms & Conditions'; ?>
                    </a>
                </nav>
            </div>
        </div><!-- .footer-bottom -->

    </div><!-- .footer-container -->
</footer>

<?php wp_footer(); ?>

<!-- Mobile Menu Toggle Script (inline for performance) -->
<script>
document.addEventListener('DOMContentLoaded', function() {
    const toggle = document.querySelector('.mobile-menu-toggle');
    const nav = document.querySelector('.main-navigation');
    
    if (toggle && nav) {
        toggle.addEventListener('click', function() {
            const expanded = this.getAttribute('aria-expanded') === 'true' || false;
            this.setAttribute('aria-expanded', !expanded);
            nav.classList.toggle('is-open');
            document.body.classList.toggle('menu-open');
        });
    }
});
</script>

</body>
</html>
