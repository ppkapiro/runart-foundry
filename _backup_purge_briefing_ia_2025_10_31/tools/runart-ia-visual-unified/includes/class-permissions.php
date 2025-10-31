<?php
/**
 * @file class-permissions.php
 * @description Define permisos (admin/editor) para endpoints IA-Visual.
 * @source Informe de Consolidación, sección 2.1
 * 
 * Responsabilidad:
 * - Verificar permisos de usuario para acceso a endpoints REST
 * - Callbacks de permission para register_rest_route
 * 
 * Niveles de permiso:
 * - admin: manage_options (administradores)
 * - editor: edit_posts (editores + administradores)
 */

if (!defined('ABSPATH')) {
    exit; // Exit if accessed directly
}

class RunArt_IA_Visual_Permissions {
    
    /**
     * Verifica si el usuario actual tiene permisos de administrador.
     *
     * @return bool
     */
    public static function is_admin() {
        return current_user_can('manage_options');
    }
    
    /**
     * Verifica si el usuario actual tiene permisos de editor o superior.
     *
     * @return bool
     */
    public static function is_editor() {
        return current_user_can('edit_posts');
    }
    
    /**
     * Callback de permission para endpoints REST nivel admin.
     * Usar en register_rest_route: 'permission_callback' => [RunArt_IA_Visual_Permissions::class, 'check_admin']
     *
     * @return bool|WP_Error
     */
    public static function check_admin() {
        if (!self::is_admin()) {
            return new WP_Error(
                'rest_forbidden',
                'Requiere permisos de administrador.',
                ['status' => 403]
            );
        }
        return true;
    }
    
    /**
     * Callback de permission para endpoints REST nivel editor.
     * Usar en register_rest_route: 'permission_callback' => [RunArt_IA_Visual_Permissions::class, 'check_editor']
     *
     * @return bool|WP_Error
     */
    public static function check_editor() {
        if (!self::is_editor()) {
            return new WP_Error(
                'rest_forbidden',
                'Requiere permisos de editor o superior.',
                ['status' => 403]
            );
        }
        return true;
    }
}
