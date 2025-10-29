<?php
/**
 * Theme Header
 *
 * @package RunArt_Base
 */
?><!doctype html>
<html <?php language_attributes(); ?>>
<head>
<meta charset="<?php bloginfo('charset'); ?>">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="profile" href="https://gmpg.org/xfn/11">
<?php wp_head(); ?>
</head>
<body <?php body_class(); ?>>
<?php wp_body_open(); ?>

<header class="site-header">
  <div class="container">
    <div class="site-branding">
      <?php if (function_exists('the_custom_logo') && has_custom_logo()) {
        the_custom_logo();
      } else { ?>
        <a class="site-title" href="<?php echo esc_url(home_url('/')); ?>"><?php bloginfo('name'); ?></a>
      <?php } ?>
    </div>

    <nav class="site-nav" aria-label="Primary">
      <?php
      wp_nav_menu([
        'theme_location' => 'primary',
        'container'      => false,
        'menu_class'     => 'menu menu-primary',
        'fallback_cb'    => false,
      ]);
      ?>
    </nav>

    <?php if (function_exists('pll_the_languages')) { ?>
    <div class="site-lang-switcher">
      <?php
        pll_the_languages([
          'show_flags' => 1,
          'show_names' => 0,
          'hide_current' => 0,
          'display_names_as' => 'name',
        ]);
      ?>
    </div>
    <?php } ?>
  </div>
</header>

<main id="content" class="site-content">
