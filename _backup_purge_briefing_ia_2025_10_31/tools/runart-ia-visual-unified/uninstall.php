<?php
/**
 * Uninstall Script para RunArt IA-Visual Unified
 * 
 * Se ejecuta automáticamente cuando el plugin se desinstala desde WordPress.
 * NO se ejecuta al desactivar, solo al hacer "Eliminar" desde el panel de plugins.
 * 
 * Responsabilidad:
 * - Limpiar opciones de WordPress creadas por el plugin
 * - Eliminar archivos/directorios temporales (opcional)
 * - NO eliminar datos de contenido enriquecido (esos son del usuario)
 */

// Si no se llamó desde WordPress, salir
if (!defined('WP_UNINSTALL_PLUGIN')) {
    exit;
}

/**
 * Limpiar opciones de WordPress
 */
function runart_ia_visual_uninstall_cleanup_options() {
    // Opción del seeder de página monitor
    delete_option('runart_ai_visual_monitor_seeded');
    
    // TODO: Agregar otras opciones si se crean en el futuro
    // Ejemplo: delete_option('runart_ia_visual_settings');
}

/**
 * Eliminar páginas creadas automáticamente (opcional)
 * 
 * ADVERTENCIA: Esto eliminará la página "Panel Editorial IA-Visual".
 * Solo descomentar si se desea limpiar completamente.
 */
function runart_ia_visual_uninstall_cleanup_pages() {
    // DESHABILITADO por defecto: el usuario puede querer mantener la página
    /*
    $page = get_page_by_title('Panel Editorial IA-Visual');
    if ($page) {
        wp_delete_post($page->ID, true); // true = force delete (bypass trash)
    }
    
    $page_alt = get_page_by_title('Monitor IA-Visual');
    if ($page_alt) {
        wp_delete_post($page_alt->ID, true);
    }
    */
}

/**
 * NO eliminar datos de contenido enriquecido
 * 
 * Los archivos en wp-content/uploads/runart-jobs/ contienen trabajo del usuario.
 * NO se eliminan automáticamente. Si el usuario desea limpiar, debe hacerlo manualmente.
 * 
 * Ubicaciones preservadas:
 * - wp-content/uploads/runart-jobs/enriched/*.json
 * - wp-content/uploads/runart-data/ (si existe)
 */

// Ejecutar limpieza
runart_ia_visual_uninstall_cleanup_options();
// runart_ia_visual_uninstall_cleanup_pages(); // Descomentado si se desea eliminar páginas

// Log de desinstalación (opcional, solo para debugging)
if (defined('WP_DEBUG') && WP_DEBUG) {
    error_log('RunArt IA-Visual Unified: Plugin desinstalado correctamente');
}
