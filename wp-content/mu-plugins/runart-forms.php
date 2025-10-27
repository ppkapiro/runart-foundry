<?php
/**
 * Plugin Name: RUN Art Foundry - Forms Integration
 * Description: Integración y estilos de Contact Form 7
 * Version: 1.0.0
 * Author: RUN Art Foundry
 */

if ( ! defined( 'ABSPATH' ) ) {
    exit;
}

/**
 * Añade CSS personalizado para formularios
 */
function runart_forms_styles() {
    if ( ! function_exists( 'wpcf7_enqueue_styles' ) ) {
        return;
    }
    
    wp_add_inline_style( 'contact-form-7', '
        /* Formularios RUN Art Foundry */
        .wpcf7 {
            max-width: 800px;
            margin: 0 auto;
        }
        
        .wpcf7-form {
            background: #fff;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .form-group {
            margin-bottom: 1.5rem;
        }
        
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem;
        }
        
        @media (max-width: 768px) {
            .form-row {
                grid-template-columns: 1fr;
            }
        }
        
        .form-group label {
            display: block;
            font-weight: 600;
            margin-bottom: 0.5rem;
            color: #231c1a;
        }
        
        .wpcf7-form-control-wrap {
            display: block;
        }
        
        .wpcf7-text,
        .wpcf7-email,
        .wpcf7-tel,
        .wpcf7-number,
        .wpcf7-date,
        .wpcf7-textarea,
        .wpcf7-select {
            width: 100%;
            padding: 0.75rem 1rem;
            font-size: 1rem;
            line-height: 1.5;
            color: #231c1a;
            background: #fff;
            border: 2px solid #e0e0e0;
            border-radius: 4px;
            transition: border-color 0.3s ease;
        }
        
        .wpcf7-text:focus,
        .wpcf7-email:focus,
        .wpcf7-tel:focus,
        .wpcf7-number:focus,
        .wpcf7-date:focus,
        .wpcf7-textarea:focus,
        .wpcf7-select:focus {
            outline: none;
            border-color: #C30000;
            box-shadow: 0 0 0 3px rgba(195, 0, 0, 0.1);
        }
        
        .wpcf7-textarea {
            min-height: 120px;
            resize: vertical;
        }
        
        .wpcf7-file {
            padding: 0.5rem;
            border: 2px dashed #e0e0e0;
            border-radius: 4px;
            cursor: pointer;
            transition: border-color 0.3s ease;
        }
        
        .wpcf7-file:hover {
            border-color: #C30000;
        }
        
        .form-group small {
            display: block;
            margin-top: 0.25rem;
            font-size: 0.875rem;
            color: #666;
        }
        
        .form-privacy {
            padding: 1rem;
            background: #f5f5f5;
            border-radius: 4px;
        }
        
        .form-privacy .wpcf7-list-item {
            margin: 0;
        }
        
        .form-privacy label {
            font-weight: normal;
            font-size: 0.9rem;
        }
        
        .form-privacy a {
            color: #C30000;
            text-decoration: underline;
        }
        
        .wpcf7-submit {
            display: inline-block;
            padding: 1rem 2rem;
            font-size: 1rem;
            font-weight: 600;
            color: #fff;
            background: #C30000;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .wpcf7-submit:hover {
            background: #a00000;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(195, 0, 0, 0.3);
        }
        
        .wpcf7-submit:active {
            transform: translateY(0);
        }
        
        .wpcf7-not-valid-tip {
            display: block;
            margin-top: 0.25rem;
            font-size: 0.875rem;
            color: #C30000;
        }
        
        .wpcf7-response-output {
            margin: 1.5rem 0 0;
            padding: 1rem;
            border-radius: 4px;
            font-size: 0.95rem;
        }
        
        .wpcf7-response-output.wpcf7-mail-sent-ok {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .wpcf7-response-output.wpcf7-mail-sent-ng,
        .wpcf7-response-output.wpcf7-validation-errors {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .wpcf7-spinner {
            margin-left: 1rem;
        }
        
        /* Accessibility */
        .wpcf7-form input:focus,
        .wpcf7-form select:focus,
        .wpcf7-form textarea:focus {
            outline: 2px solid #C30000;
            outline-offset: 2px;
        }
    ' );
}
add_action( 'wp_enqueue_scripts', 'runart_forms_styles' );

/**
 * Añade reCAPTCHA v3 (cuando esté configurado)
 */
function runart_forms_recaptcha_notice() {
    // Placeholder para configuración futura de reCAPTCHA
    // Descomentar cuando se obtengan las keys:
    // if ( ! defined( 'WPCF7_RECAPTCHA_SITEKEY' ) ) {
    //     define( 'WPCF7_RECAPTCHA_SITEKEY', 'YOUR_SITE_KEY' );
    // }
    // if ( ! defined( 'WPCF7_RECAPTCHA_SECRET' ) ) {
    //     define( 'WPCF7_RECAPTCHA_SECRET', 'YOUR_SECRET_KEY' );
    // }
}
add_action( 'init', 'runart_forms_recaptcha_notice' );

/**
 * Deshabilita AJAX submit si hay problemas
 * Descomentar si se necesita:
 */
// add_filter( 'wpcf7_load_js', '__return_false' );
// add_filter( 'wpcf7_load_css', '__return_false' );

/**
 * Cambia el directorio de uploads para formularios
 */
function runart_forms_upload_dir( $dir ) {
    $dir['path'] = $dir['basedir'] . '/contact-form-submissions';
    $dir['url'] = $dir['baseurl'] . '/contact-form-submissions';
    $dir['subdir'] = '/contact-form-submissions';
    return $dir;
}
// Descomentar si se quiere cambiar el directorio:
// add_filter( 'wpcf7_upload_dir', 'runart_forms_upload_dir' );

/**
 * Configuración de SMTP (placeholder)
 * Configurar en wp-config.php o usar plugin WP Mail SMTP
 */
function runart_configure_smtp_notice() {
    // Para configurar SMTP, añadir en wp-config.php:
    /*
    define( 'SMTP_HOST', 'smtp.ejemplo.com' );
    define( 'SMTP_PORT', '587' );
    define( 'SMTP_SECURE', 'tls' );
    define( 'SMTP_USERNAME', 'tu@email.com' );
    define( 'SMTP_PASSWORD', 'tu_password' );
    define( 'SMTP_FROM', 'tu@email.com' );
    define( 'SMTP_FROMNAME', 'RUN Art Foundry' );
    */
}
