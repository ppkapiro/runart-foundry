<?php
/**
 * Theme Footer
 *
 * @package RunArt_Base
 */
?>
</main>

<footer class="site-footer">
  <div class="container">
    <div class="footer-grid" style="display:grid;gap:24px;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));">
      <div class="footer-col footer-brand">
        <h4 class="footer-title"><?php bloginfo('name'); ?></h4>
        <p class="text-muted">A Factory of Art</p>
      </div>
      <div class="footer-col footer-links">
        <h4 class="footer-title"><?php esc_html_e('Links', 'runart'); ?></h4>
        <?php
        wp_nav_menu([
          'theme_location' => 'footer',
          'container'      => false,
          'menu_class'     => 'menu menu-footer',
          'fallback_cb'    => false,
        ]);
        ?>
      </div>
      <div class="footer-col footer-contact">
        <h4 class="footer-title"><?php esc_html_e('Contact', 'runart'); ?></h4>
        <p class="text-muted">team@runartfoundry.com</p>
      </div>
      <div class="footer-col footer-social">
        <h4 class="footer-title"><?php esc_html_e('Social', 'runart'); ?></h4>
        <p class="text-muted">Instagram · LinkedIn</p>
      </div>
    </div>
    <div class="footer-bottom" style="margin-top:32px;border-top:1px solid rgba(255,255,255,.08);padding-top:16px;display:flex;justify-content:space-between;gap:12px;flex-wrap:wrap;">
      <small>&copy; <?php echo date('Y'); ?> <?php bloginfo('name'); ?>. <?php esc_html_e('All rights reserved.', 'runart'); ?></small>
      <small><a href="<?php echo esc_url(home_url('/privacy/')); ?>"><?php esc_html_e('Privacy', 'runart'); ?></a> · <a href="<?php echo esc_url(home_url('/legal/')); ?>"><?php esc_html_e('Legal', 'runart'); ?></a></small>
    </div>
  </div>
</footer>

<?php wp_footer(); ?>
</body>
</html>
