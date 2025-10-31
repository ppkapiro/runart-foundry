<?php
if (!defined('ABSPATH')) {
    exit;
}

class RunArt_AI_Visual_Admin {
    public static function register_admin_page() {
        add_management_page('RunArt IA-Visual Status', 'RunArt IA-Visual', 'manage_options', 'runart-aivp-status', [__CLASS__, 'render_admin_page']);
    }

    public static function render_admin_page() {
        if (!current_user_can('manage_options')) {
            wp_die('Insufficient permissions');
        }

        $version = RUNART_AIVP_VERSION;
        $uploads = wp_upload_dir();
        $base = isset($uploads['basedir']) ? $uploads['basedir'] : (ABSPATH . 'wp-content/uploads');
        $index = trailingslashit($base) . RUNART_AIVP_DATA_RELATIVE;
        $jobs_dir = trailingslashit($base) . 'runart-jobs/';

        ?>
        <div class="wrap">
            <h1>RunArt IA-Visual Status</h1>
            <p>Plugin version: <?php echo esc_html($version); ?></p>
            <p>Registered shortcodes: <code><?php echo esc_html(implode('</code>, <code>', RunArt_AI_Visual_Shortcode::$shortcodes)); ?></code></p>
            <p>Enriched index path: <code><?php echo esc_html($index); ?></code></p>
            <p>Runart-jobs dir exists: <?php echo is_dir($jobs_dir) ? 'Yes' : 'No'; ?></p>
            <p>Runart-jobs dir writable: <?php echo is_writable($jobs_dir) ? 'Yes' : 'No'; ?></p>
            <form method="post">
                <?php wp_nonce_field('runart_aivp_test'); ?>
                <p><button name="runart_aivp_test" class="button button-primary">Test enriched-list</button></p>
            </form>
            <?php
            if (isset($_POST['runart_aivp_test']) && check_admin_referer('runart_aivp_test')) {
                $resp = wp_remote_get(rest_url('runart/content/enriched-list'));
                echo '<h2>Test result</h2><pre>'; print_r($resp); echo '</pre>';
            }
            ?>
        </div>
        <?php
    }
}
