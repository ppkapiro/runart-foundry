<?php
/**
 * Plugin Name: RunMedia Media Bridge
 * Plugin URI: https://runartfoundry.com
 * Description: Integra el índice de RunMedia (content/media/media-index.json) con WordPress para servir imágenes optimizadas WebP/AVIF sin duplicar archivos
 * Version: 1.0.0
 * Author: RUN Art Foundry
 * Author URI: https://runartfoundry.com
 * License: All Rights Reserved
 */

if ( ! defined( 'ABSPATH' ) ) {
    exit;
}

/**
 * RunMedia Media Bridge Class
 */
class RunMedia_Media_Bridge {
    
    private static $instance = null;
    private $index_cache = null;
    private $index_path;
    private $base_url;
    
    public static function get_instance() {
        if ( null === self::$instance ) {
            self::$instance = new self();
        }
        return self::$instance;
    }
    
    private function __construct() {
        // Path al índice de RunMedia (relativo a ABSPATH)
        $this->index_path = ABSPATH . '../content/media/media-index.json';
        
        // Base URL para servir imágenes (ajustar según deployment)
        $this->base_url = home_url( '/content/media/' );
        
        // Hooks
        add_shortcode( 'runmedia', array( $this, 'shortcode_handler' ) );
        add_action( 'init', array( $this, 'add_rewrite_rules' ) );
        add_filter( 'query_vars', array( $this, 'add_query_vars' ) );
        add_action( 'template_redirect', array( $this, 'serve_runmedia_image' ) );
    }
    
    /**
     * Cargar índice JSON de RunMedia con cache
     */
    private function load_index() {
        if ( null !== $this->index_cache ) {
            return $this->index_cache;
        }
        
        if ( ! file_exists( $this->index_path ) ) {
            error_log( 'RunMedia: index not found at ' . $this->index_path );
            return array( 'items' => array() );
        }
        
        $json = file_get_contents( $this->index_path );
        $this->index_cache = json_decode( $json, true );
        
        return $this->index_cache;
    }
    
    /**
     * Buscar imagen por ID o proyecto/servicio
     */
    public function find_image( $id = null, $project = null, $service = null, $index = 0 ) {
        $idx = $this->load_index();
        $items = $idx['items'] ?? array();
        
        // Búsqueda por ID (directo)
        if ( $id ) {
            foreach ( $items as $item ) {
                if ( $item['id'] === $id ) {
                    return $item;
                }
            }
        }
        
        // Búsqueda por proyecto o servicio
        $candidates = array();
        foreach ( $items as $item ) {
            $related = $item['related'] ?? array();
            
            if ( $project && in_array( $project, $related['projects'] ?? array(), true ) ) {
                $candidates[] = $item;
            } elseif ( $service && in_array( $service, $related['services'] ?? array(), true ) ) {
                $candidates[] = $item;
            }
        }
        
        // Filtrar solo imágenes con width >= 1600 para calidad
        $candidates = array_filter( $candidates, function( $item ) {
            return ( $item['width'] ?? 0 ) >= 1200;
        } );
        
        // Ordenar por ancho (más grande primero)
        usort( $candidates, function( $a, $b ) {
            return ( $b['width'] ?? 0 ) - ( $a['width'] ?? 0 );
        } );
        
        // Retornar índice específico o primero
        return $candidates[ $index ] ?? null;
    }
    
    /**
     * Shortcode [runmedia id="abc123" size="w1200" format="webp" alt="..."]
     */
    public function shortcode_handler( $atts ) {
        $atts = shortcode_atts( array(
            'id'      => null,
            'project' => null,
            'service' => null,
            'index'   => 0,
            'size'    => 'w1200',
            'format'  => 'webp',
            'alt'     => '',
            'class'   => '',
            'lang'    => function_exists( 'pll_current_language' ) ? pll_current_language() : 'en',
        ), $atts );
        
        $item = $this->find_image( $atts['id'], $atts['project'], $atts['service'], (int) $atts['index'] );
        
        if ( ! $item ) {
            return '<!-- RunMedia: image not found -->';
        }
        
        // Obtener ruta de variante
        $sizes = $item['sizes'][ $atts['format'] ] ?? array();
        $variant = $sizes[ $atts['size'] ] ?? null;
        
        if ( ! $variant ) {
            // Fallback a source original
            $image_path = $item['source']['path'];
        } else {
            $image_path = $variant['path'];
        }
        
        // Construir URL
        $image_url = $this->base_url . str_replace( 'content/media/', '', $image_path );
        
        // ALT text (priorizar parámetro, luego metadata del índice)
        if ( empty( $atts['alt'] ) ) {
            $metadata = $item['metadata'] ?? array();
            $alt_data = $metadata['alt'] ?? array();
            $atts['alt'] = $alt_data[ $atts['lang'] ] ?? $item['filename'];
        }
        
        // Width/height para lazy loading
        $width = $variant['width'] ?? $item['width'] ?? '';
        $height = $variant['height'] ?? $item['height'] ?? '';
        
        // Generar HTML
        $html = sprintf(
            '<img src="%s" alt="%s" width="%d" height="%d" class="%s" loading="lazy" />',
            esc_url( $image_url ),
            esc_attr( $atts['alt'] ),
            $width,
            $height,
            esc_attr( $atts['class'] )
        );
        
        return $html;
    }
    
    /**
     * Helper function accesible desde templates PHP
     */
    public function get_image_url( $id = null, $project = null, $service = null, $size = 'w1200', $format = 'webp', $index = 0 ) {
        $item = $this->find_image( $id, $project, $service, $index );
        
        if ( ! $item ) {
            return '';
        }
        
        $sizes = $item['sizes'][ $format ] ?? array();
        $variant = $sizes[ $size ] ?? null;
        
        if ( ! $variant ) {
            $image_path = $item['source']['path'];
        } else {
            $image_path = $variant['path'];
        }
        
        return $this->base_url . str_replace( 'content/media/', '', $image_path );
    }
    
    /**
     * Helper: Obtener ALT text
     */
    public function get_alt_text( $id = null, $project = null, $service = null, $lang = 'en', $index = 0 ) {
        $item = $this->find_image( $id, $project, $service, $index );
        
        if ( ! $item ) {
            return '';
        }
        
        $metadata = $item['metadata'] ?? array();
        $alt_data = $metadata['alt'] ?? array();
        $alt = $alt_data[ $lang ] ?? '';
        
        // Fallback a título o filename
        if ( empty( $alt ) ) {
            $title_data = $metadata['title'] ?? array();
            $alt = $title_data[ $lang ] ?? $item['filename'];
        }
        
        return $alt;
    }
    
    /**
     * Helper: Obtener múltiples imágenes para galería
     */
    public function get_gallery_images( $project = null, $service = null, $limit = 10, $format = 'webp', $size = 'w800' ) {
        $idx = $this->load_index();
        $items = $idx['items'] ?? array();
        
        $candidates = array();
        foreach ( $items as $item ) {
            $related = $item['related'] ?? array();
            
            if ( $project && in_array( $project, $related['projects'] ?? array(), true ) ) {
                $candidates[] = $item;
            } elseif ( $service && in_array( $service, $related['services'] ?? array(), true ) ) {
                $candidates[] = $item;
            }
            
            if ( count( $candidates ) >= $limit ) {
                break;
            }
        }
        
        // Construir array de URLs
        $gallery = array();
        foreach ( $candidates as $item ) {
            $sizes = $item['sizes'][ $format ] ?? array();
            $variant = $sizes[ $size ] ?? null;
            
            if ( ! $variant ) {
                $image_path = $item['source']['path'];
            } else {
                $image_path = $variant['path'];
            }
            
            $gallery[] = array(
                'url'    => $this->base_url . str_replace( 'content/media/', '', $image_path ),
                'alt'    => $this->get_alt_text( $item['id'], null, null, function_exists( 'pll_current_language' ) ? pll_current_language() : 'en' ),
                'width'  => $variant['width'] ?? $item['width'] ?? '',
                'height' => $variant['height'] ?? $item['height'] ?? '',
            );
        }
        
        return $gallery;
    }
    
    /**
     * Rewrite rules para servir imágenes directamente (opcional)
     */
    public function add_rewrite_rules() {
        add_rewrite_rule(
            '^runmedia/([^/]+)/([^/]+)/([^/]+)/?',
            'index.php?runmedia_id=$matches[1]&runmedia_format=$matches[2]&runmedia_size=$matches[3]',
            'top'
        );
    }
    
    public function add_query_vars( $vars ) {
        $vars[] = 'runmedia_id';
        $vars[] = 'runmedia_format';
        $vars[] = 'runmedia_size';
        return $vars;
    }
    
    public function serve_runmedia_image() {
        $id = get_query_var( 'runmedia_id' );
        $format = get_query_var( 'runmedia_format', 'webp' );
        $size = get_query_var( 'runmedia_size', 'w1200' );
        
        if ( ! $id ) {
            return;
        }
        
        $item = $this->find_image( $id );
        
        if ( ! $item ) {
            status_header( 404 );
            exit;
        }
        
        // Obtener ruta física
        $sizes = $item['sizes'][ $format ] ?? array();
        $variant = $sizes[ $size ] ?? null;
        
        if ( ! $variant ) {
            $file_path = ABSPATH . '../' . $item['source']['path'];
        } else {
            $file_path = ABSPATH . '../' . $variant['path'];
        }
        
        if ( ! file_exists( $file_path ) ) {
            status_header( 404 );
            exit;
        }
        
        // Servir archivo
        $mime = $format === 'avif' ? 'image/avif' : 'image/webp';
        header( 'Content-Type: ' . $mime );
        header( 'Cache-Control: public, max-age=31536000, immutable' );
        readfile( $file_path );
        exit;
    }
}

// Inicializar plugin
RunMedia_Media_Bridge::get_instance();

/**
 * Helper functions globales para usar en templates
 */
function runmedia_get_url( $id = null, $project = null, $service = null, $size = 'w1200', $format = 'webp', $index = 0 ) {
    return RunMedia_Media_Bridge::get_instance()->get_image_url( $id, $project, $service, $size, $format, $index );
}

function runmedia_get_alt( $id = null, $project = null, $service = null, $lang = 'en', $index = 0 ) {
    return RunMedia_Media_Bridge::get_instance()->get_alt_text( $id, $project, $service, $lang, $index );
}

function runmedia_gallery( $project = null, $service = null, $limit = 10, $format = 'webp', $size = 'w800' ) {
    return RunMedia_Media_Bridge::get_instance()->get_gallery_images( $project, $service, $limit, $format, $size );
}
