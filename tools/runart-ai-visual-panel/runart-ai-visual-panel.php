<?php
/**
 * Plugin Name: RunArt AI Visual Panel
 * Description: Panel editorial IA-Visual (reemplazo limpio). Shortcode y endpoints REST separados del JS.
 * Version: 1.0.0
 * Author: RunArt Foundry
 * Requires PHP: 7.4
 */

if (!defined('ABSPATH')) {
    exit;
}

define('RUNART_AIVP_VERSION', '1.0.0');
define('RUNART_AIVP_DIR', plugin_dir_path(__FILE__));
define('RUNART_AIVP_URL', plugin_dir_url(__FILE__));
define('RUNART_AIVP_DATA_RELATIVE', 'runart-jobs/enriched/index.json'); // editable central

require_once RUNART_AIVP_DIR . 'includes/class-runart-ai-visual-rest.php';
require_once RUNART_AIVP_DIR . 'includes/class-runart-ai-visual-shortcode.php';
require_once RUNART_AIVP_DIR . 'includes/class-runart-ai-visual-admin.php';

add_action('rest_api_init', ['RunArt_AI_Visual_REST', 'register_routes']);
add_action('init', ['RunArt_AI_Visual_Shortcode', 'init']);
add_action('admin_menu', ['RunArt_AI_Visual_Admin', 'register_admin_page']);

?>
