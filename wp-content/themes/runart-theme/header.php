<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
    <meta charset="<?php bloginfo( 'charset' ); ?>">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <?php wp_head(); ?>
</head>

<body <?php body_class(); ?>>
<?php wp_body_open(); ?>

<header id="site-header" class="site-header">
    <div class="header-container">
        
        <!-- Logo -->
        <div class="site-branding">
            <a href="<?php echo esc_url( home_url( '/' ) ); ?>" rel="home">
                <?php
                $logo_url = runmedia_get_url( null, 'run-art-foundry-branding', null, 'w800', 'webp', 0 );
                if ( $logo_url ) :
                    $lang = function_exists('pll_current_language') ? pll_current_language() : 'en';
                    $logo_alt = $lang === 'es' ? 'RUN Art Foundry — Fundición Artística Miami' : 'RUN Art Foundry — Artistic Bronze Casting Miami';
                    ?>
                    <img src="<?php echo esc_url( $logo_url ); ?>" 
                         alt="<?php echo esc_attr( $logo_alt ); ?>" 
                         class="site-logo" />
                <?php else : ?>
                    <span class="site-title"><?php bloginfo( 'name' ); ?></span>
                <?php endif; ?>
            </a>
        </div>

        <!-- Mobile Menu Toggle -->
        <button class="mobile-menu-toggle" aria-label="Toggle navigation" aria-expanded="false">
            <span class="hamburger-line"></span>
            <span class="hamburger-line"></span>
            <span class="hamburger-line"></span>
        </button>

        <!-- Navigation -->
        <nav id="site-navigation" class="main-navigation">
            <?php
            wp_nav_menu( array(
                'theme_location' => 'primary',
                'menu_class'     => 'nav-menu',
                'container'      => false,
                'fallback_cb'    => '__return_false',
            ) );
            ?>

            <!-- Language Switcher (Polylang) -->
            <?php if ( function_exists('pll_the_languages') ) : ?>
                <div class="language-switcher">
                    <?php
                    $languages = pll_the_languages( array( 'raw' => 1 ) );
                    if ( ! empty( $languages ) ) :
                        foreach ( $languages as $language ) :
                            $class = $language['current_lang'] ? 'lang-item active' : 'lang-item';
                            ?>
                            <a href="<?php echo esc_url( $language['url'] ); ?>" 
                               class="<?php echo esc_attr( $class ); ?>"
                               hreflang="<?php echo esc_attr( $language['slug'] ); ?>"
                               lang="<?php echo esc_attr( $language['slug'] ); ?>">
                                <?php echo esc_html( strtoupper( $language['slug'] ) ); ?>
                            </a>
                        <?php
                        endforeach;
                    endif;
                    ?>
                </div>
            <?php endif; ?>
        </nav>

    </div>
</header>

<main id="main-content" class="site-main">
