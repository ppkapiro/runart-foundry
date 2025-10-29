<?php
/**
 * Custom Post Types para RUN Art Foundry
 * 
 * CPTs: project, service, testimonial
 * Taxonomías: artist, technique, alloy, patina, year, client_type
 * 
 * @package RUNArtFoundry
 * @version 1.0.0
 */

// Prevenir acceso directo
if ( ! defined( 'ABSPATH' ) ) {
    exit;
}

/**
 * Registrar Custom Post Type: Project
 */
function runart_register_cpt_project() {
    $labels = array(
        'name'                  => _x( 'Proyectos', 'Post Type General Name', 'runart' ),
        'singular_name'         => _x( 'Proyecto', 'Post Type Singular Name', 'runart' ),
        'menu_name'             => __( 'Proyectos', 'runart' ),
        'name_admin_bar'        => __( 'Proyecto', 'runart' ),
        'archives'              => __( 'Archivo de Proyectos', 'runart' ),
        'attributes'            => __( 'Atributos del Proyecto', 'runart' ),
        'parent_item_colon'     => __( 'Proyecto Padre:', 'runart' ),
        'all_items'             => __( 'Todos los Proyectos', 'runart' ),
        'add_new_item'          => __( 'Agregar Nuevo Proyecto', 'runart' ),
        'add_new'               => __( 'Agregar Nuevo', 'runart' ),
        'new_item'              => __( 'Nuevo Proyecto', 'runart' ),
        'edit_item'             => __( 'Editar Proyecto', 'runart' ),
        'update_item'           => __( 'Actualizar Proyecto', 'runart' ),
        'view_item'             => __( 'Ver Proyecto', 'runart' ),
        'view_items'            => __( 'Ver Proyectos', 'runart' ),
        'search_items'          => __( 'Buscar Proyecto', 'runart' ),
        'not_found'             => __( 'No se encontraron proyectos', 'runart' ),
        'not_found_in_trash'    => __( 'No se encontraron proyectos en la papelera', 'runart' ),
    );
    
    $args = array(
        'label'                 => __( 'Proyecto', 'runart' ),
        'description'           => __( 'Proyectos de fundición artística', 'runart' ),
        'labels'                => $labels,
        'supports'              => array( 'title', 'editor', 'thumbnail', 'excerpt', 'revisions', 'custom-fields' ),
        'taxonomies'            => array( 'artist', 'technique', 'alloy', 'patina', 'year' ),
        'hierarchical'          => false,
        'public'                => true,
        'show_ui'               => true,
        'show_in_menu'          => true,
        'menu_position'         => 5,
        'menu_icon'             => 'dashicons-admin-multisite',
        'show_in_admin_bar'     => true,
        'show_in_nav_menus'     => true,
        'can_export'            => true,
        'has_archive'           => 'projects',
        'exclude_from_search'   => false,
        'publicly_queryable'    => true,
        'capability_type'       => 'post',
        'show_in_rest'          => true, // Gutenberg support
        'rewrite'               => array(
            'slug'       => 'projects',
            'with_front' => false,
        ),
    );
    
    register_post_type( 'project', $args );
}
add_action( 'init', 'runart_register_cpt_project', 0 );

/**
 * Registrar Custom Post Type: Service
 */
function runart_register_cpt_service() {
    $labels = array(
        'name'                  => _x( 'Servicios', 'Post Type General Name', 'runart' ),
        'singular_name'         => _x( 'Servicio', 'Post Type Singular Name', 'runart' ),
        'menu_name'             => __( 'Servicios', 'runart' ),
        'name_admin_bar'        => __( 'Servicio', 'runart' ),
        'archives'              => __( 'Archivo de Servicios', 'runart' ),
        'all_items'             => __( 'Todos los Servicios', 'runart' ),
        'add_new_item'          => __( 'Agregar Nuevo Servicio', 'runart' ),
        'add_new'               => __( 'Agregar Nuevo', 'runart' ),
        'new_item'              => __( 'Nuevo Servicio', 'runart' ),
        'edit_item'             => __( 'Editar Servicio', 'runart' ),
        'update_item'           => __( 'Actualizar Servicio', 'runart' ),
        'view_item'             => __( 'Ver Servicio', 'runart' ),
        'search_items'          => __( 'Buscar Servicio', 'runart' ),
    );
    
    $args = array(
        'label'                 => __( 'Servicio', 'runart' ),
        'description'           => __( 'Servicios técnicos ofrecidos', 'runart' ),
        'labels'                => $labels,
        'supports'              => array( 'title', 'editor', 'thumbnail', 'excerpt', 'revisions' ),
        'hierarchical'          => false,
        'public'                => true,
        'show_ui'               => true,
        'show_in_menu'          => true,
        'menu_position'         => 6,
        'menu_icon'             => 'dashicons-awards',
        'show_in_admin_bar'     => true,
        'show_in_nav_menus'     => true,
        'can_export'            => true,
        'has_archive'           => 'services',
        'exclude_from_search'   => false,
        'publicly_queryable'    => true,
        'capability_type'       => 'post',
        'show_in_rest'          => true,
        'rewrite'               => array(
            'slug'       => 'services',
            'with_front' => false,
        ),
    );
    
    register_post_type( 'service', $args );
}
add_action( 'init', 'runart_register_cpt_service', 0 );

/**
 * Registrar Custom Post Type: Testimonial
 */
function runart_register_cpt_testimonial() {
    $labels = array(
        'name'                  => _x( 'Testimonios', 'Post Type General Name', 'runart' ),
        'singular_name'         => _x( 'Testimonio', 'Post Type Singular Name', 'runart' ),
        'menu_name'             => __( 'Testimonios', 'runart' ),
        'name_admin_bar'        => __( 'Testimonio', 'runart' ),
        'all_items'             => __( 'Todos los Testimonios', 'runart' ),
        'add_new_item'          => __( 'Agregar Nuevo Testimonio', 'runart' ),
        'add_new'               => __( 'Agregar Nuevo', 'runart' ),
        'new_item'              => __( 'Nuevo Testimonio', 'runart' ),
        'edit_item'             => __( 'Editar Testimonio', 'runart' ),
        'view_item'             => __( 'Ver Testimonio', 'runart' ),
        'search_items'          => __( 'Buscar Testimonio', 'runart' ),
    );
    
    $args = array(
        'label'                 => __( 'Testimonio', 'runart' ),
        'description'           => __( 'Testimonios de artistas', 'runart' ),
        'labels'                => $labels,
        'supports'              => array( 'title', 'editor', 'thumbnail', 'revisions' ),
        'hierarchical'          => false,
        'public'                => true,
        'show_ui'               => true,
        'show_in_menu'          => true,
        'menu_position'         => 7,
        'menu_icon'             => 'dashicons-format-quote',
        'show_in_admin_bar'     => true,
        'show_in_nav_menus'     => false,
        'can_export'            => true,
        'has_archive'           => false,
        'exclude_from_search'   => true,
        'publicly_queryable'    => true,
        'capability_type'       => 'post',
        'show_in_rest'          => true,
        'rewrite'               => array(
            'slug'       => 'testimonials',
            'with_front' => false,
        ),
    );
    
    register_post_type( 'testimonial', $args );
}
add_action( 'init', 'runart_register_cpt_testimonial', 0 );

/**
 * Registrar Taxonomía: Artist (Artista)
 */
function runart_register_taxonomy_artist() {
    $labels = array(
        'name'              => _x( 'Artistas', 'taxonomy general name', 'runart' ),
        'singular_name'     => _x( 'Artista', 'taxonomy singular name', 'runart' ),
        'search_items'      => __( 'Buscar Artistas', 'runart' ),
        'all_items'         => __( 'Todos los Artistas', 'runart' ),
        'edit_item'         => __( 'Editar Artista', 'runart' ),
        'update_item'       => __( 'Actualizar Artista', 'runart' ),
        'add_new_item'      => __( 'Agregar Nuevo Artista', 'runart' ),
        'new_item_name'     => __( 'Nuevo Nombre de Artista', 'runart' ),
        'menu_name'         => __( 'Artistas', 'runart' ),
    );
    
    $args = array(
        'labels'            => $labels,
        'hierarchical'      => false,
        'public'            => true,
        'show_ui'           => true,
        'show_admin_column' => true,
        'show_in_nav_menus' => true,
        'show_tagcloud'     => false,
        'show_in_rest'      => true,
        'rewrite'           => array( 'slug' => 'artist' ),
    );
    
    register_taxonomy( 'artist', array( 'project' ), $args );
}
add_action( 'init', 'runart_register_taxonomy_artist', 0 );

/**
 * Registrar Taxonomía: Technique (Técnica)
 */
function runart_register_taxonomy_technique() {
    $labels = array(
        'name'              => _x( 'Técnicas', 'taxonomy general name', 'runart' ),
        'singular_name'     => _x( 'Técnica', 'taxonomy singular name', 'runart' ),
        'search_items'      => __( 'Buscar Técnicas', 'runart' ),
        'all_items'         => __( 'Todas las Técnicas', 'runart' ),
        'edit_item'         => __( 'Editar Técnica', 'runart' ),
        'add_new_item'      => __( 'Agregar Nueva Técnica', 'runart' ),
        'menu_name'         => __( 'Técnicas', 'runart' ),
    );
    
    $args = array(
        'labels'            => $labels,
        'hierarchical'      => false,
        'public'            => true,
        'show_ui'           => true,
        'show_admin_column' => true,
        'show_in_nav_menus' => true,
        'show_in_rest'      => true,
        'rewrite'           => array( 'slug' => 'technique' ),
    );
    
    register_taxonomy( 'technique', array( 'project' ), $args );
}
add_action( 'init', 'runart_register_taxonomy_technique', 0 );

/**
 * Registrar Taxonomía: Alloy (Aleación)
 */
function runart_register_taxonomy_alloy() {
    $labels = array(
        'name'              => _x( 'Aleaciones', 'taxonomy general name', 'runart' ),
        'singular_name'     => _x( 'Aleación', 'taxonomy singular name', 'runart' ),
        'search_items'      => __( 'Buscar Aleaciones', 'runart' ),
        'all_items'         => __( 'Todas las Aleaciones', 'runart' ),
        'edit_item'         => __( 'Editar Aleación', 'runart' ),
        'add_new_item'      => __( 'Agregar Nueva Aleación', 'runart' ),
        'menu_name'         => __( 'Aleaciones', 'runart' ),
    );
    
    $args = array(
        'labels'            => $labels,
        'hierarchical'      => false,
        'public'            => true,
        'show_ui'           => true,
        'show_admin_column' => true,
        'show_in_rest'      => true,
        'rewrite'           => array( 'slug' => 'alloy' ),
    );
    
    register_taxonomy( 'alloy', array( 'project' ), $args );
}
add_action( 'init', 'runart_register_taxonomy_alloy', 0 );

/**
 * Registrar Taxonomía: Patina (Pátina)
 */
function runart_register_taxonomy_patina() {
    $labels = array(
        'name'              => _x( 'Pátinas', 'taxonomy general name', 'runart' ),
        'singular_name'     => _x( 'Pátina', 'taxonomy singular name', 'runart' ),
        'search_items'      => __( 'Buscar Pátinas', 'runart' ),
        'all_items'         => __( 'Todas las Pátinas', 'runart' ),
        'edit_item'         => __( 'Editar Pátina', 'runart' ),
        'add_new_item'      => __( 'Agregar Nueva Pátina', 'runart' ),
        'menu_name'         => __( 'Pátinas', 'runart' ),
    );
    
    $args = array(
        'labels'            => $labels,
        'hierarchical'      => false,
        'public'            => true,
        'show_ui'           => true,
        'show_admin_column' => true,
        'show_in_rest'      => true,
        'rewrite'           => array( 'slug' => 'patina' ),
    );
    
    register_taxonomy( 'patina', array( 'project' ), $args );
}
add_action( 'init', 'runart_register_taxonomy_patina', 0 );

/**
 * Registrar Taxonomía: Year (Año)
 */
function runart_register_taxonomy_year() {
    $labels = array(
        'name'              => _x( 'Años', 'taxonomy general name', 'runart' ),
        'singular_name'     => _x( 'Año', 'taxonomy singular name', 'runart' ),
        'search_items'      => __( 'Buscar Años', 'runart' ),
        'all_items'         => __( 'Todos los Años', 'runart' ),
        'edit_item'         => __( 'Editar Año', 'runart' ),
        'add_new_item'      => __( 'Agregar Nuevo Año', 'runart' ),
        'menu_name'         => __( 'Años', 'runart' ),
    );
    
    $args = array(
        'labels'            => $labels,
        'hierarchical'      => false,
        'public'            => true,
        'show_ui'           => true,
        'show_admin_column' => true,
        'show_in_rest'      => true,
        'rewrite'           => array( 'slug' => 'year' ),
    );
    
    register_taxonomy( 'year', array( 'project' ), $args );
}
add_action( 'init', 'runart_register_taxonomy_year', 0 );

/**
 * Registrar Taxonomía: Client Type (Tipo de Cliente)
 */
function runart_register_taxonomy_client_type() {
    $labels = array(
        'name'              => _x( 'Tipos de Cliente', 'taxonomy general name', 'runart' ),
        'singular_name'     => _x( 'Tipo de Cliente', 'taxonomy singular name', 'runart' ),
        'search_items'      => __( 'Buscar Tipos', 'runart' ),
        'all_items'         => __( 'Todos los Tipos', 'runart' ),
        'edit_item'         => __( 'Editar Tipo', 'runart' ),
        'add_new_item'      => __( 'Agregar Nuevo Tipo', 'runart' ),
        'menu_name'         => __( 'Tipos de Cliente', 'runart' ),
    );
    
    $args = array(
        'labels'            => $labels,
        'hierarchical'      => true,
        'public'            => true,
        'show_ui'           => true,
        'show_admin_column' => false,
        'show_in_rest'      => true,
        'rewrite'           => array( 'slug' => 'client-type' ),
    );
    
    register_taxonomy( 'client_type', array( 'project' ), $args );
}
add_action( 'init', 'runart_register_taxonomy_client_type', 0 );

/**
 * Flush rewrite rules on theme activation
 */
function runart_rewrite_flush() {
    runart_register_cpt_project();
    runart_register_cpt_service();
    runart_register_cpt_testimonial();
    runart_register_taxonomy_artist();
    runart_register_taxonomy_technique();
    runart_register_taxonomy_alloy();
    runart_register_taxonomy_patina();
    runart_register_taxonomy_year();
    runart_register_taxonomy_client_type();
    flush_rewrite_rules();
}
register_activation_hook( __FILE__, 'runart_rewrite_flush' );
