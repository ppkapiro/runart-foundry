#!/usr/bin/env php
<?php
/**
 * RunArt Foundry - Link and Publish Translations
 * Vincula traducciones EN ↔ ES via Polylang y publica drafts
 * 
 * Usage: wp eval-file link_and_publish_translations.php --allow-root
 */

// Mapeo de IDs EN → ES (según logs de traducción)
$translations = [
    // Projects
    3548 => 3563, // Arquidiócesis de La Habana
    3547 => 3564, // Escultura Monumental Oliva
    3546 => 3565, // Carole Feuerman
    3545 => 3566, // Roberto Fabelo
    3544 => 3567, // Monumento Williams Carmona
    
    // Services
    3553 => 3568, // Ediciones Limitadas
    3552 => 3569, // Consultoría Técnica
    3551 => 3570, // Restauración
    3550 => 3571, // Pátinas
    3549 => 3572, // Fundición Artística
    
    // Testimonials
    3556 => 3573, // Carole Feuerman
    3555 => 3574, // Roberto Fabelo
    3554 => 3575, // Williams Carmona
    
    // Posts
    3559 => 3576, // Pátinas en Bronce
    3558 => 3577, // Proceso Cera Perdida
    3557 => 3578, // Guía Aleaciones
];

$linked = 0;
$published = 0;
$errors = [];

echo "[" . date('H:i:s') . "] Iniciando vinculación de traducciones...\n";
echo "============================================================\n";

foreach ($translations as $en_id => $es_id) {
    $en_post = get_post($en_id);
    $es_post = get_post($es_id);
    
    if (!$en_post || !$es_post) {
        $errors[] = "Post no encontrado: EN={$en_id}, ES={$es_id}";
        continue;
    }
    
    // 1. Vincular con Polylang
    try {
        // Obtener o crear translation group
        $translations_ids = pll_get_post_translations($en_id);
        
        if (empty($translations_ids)) {
            // Crear nuevo grupo de traducciones
            pll_set_post_language($en_id, 'en');
            pll_set_post_language($es_id, 'es');
            pll_save_post_translations([
                'en' => $en_id,
                'es' => $es_id
            ]);
        } else {
            // Agregar al grupo existente
            $translations_ids['es'] = $es_id;
            pll_save_post_translations($translations_ids);
        }
        
        $linked++;
        echo "[" . date('H:i:s') . "] ✓ Vinculado: {$en_post->post_title} (EN:{$en_id} ↔ ES:{$es_id})\n";
        
    } catch (Exception $e) {
        $errors[] = "Error vinculando EN:{$en_id} ↔ ES:{$es_id}: " . $e->getMessage();
        echo "[" . date('H:i:s') . "] ✗ Error vinculando EN:{$en_id}\n";
        continue;
    }
    
    // 2. Publicar draft ES
    if ($es_post->post_status === 'draft') {
        $updated = wp_update_post([
            'ID' => $es_id,
            'post_status' => 'publish'
        ], true);
        
        if (is_wp_error($updated)) {
            $errors[] = "Error publicando ES:{$es_id}: " . $updated->get_error_message();
            echo "[" . date('H:i:s') . "] ✗ Error publicando ES:{$es_id}\n";
        } else {
            $published++;
            echo "[" . date('H:i:s') . "] ✓ Publicado: {$es_post->post_title} (ES:{$es_id})\n";
        }
    } else {
        echo "[" . date('H:i:s') . "] ⚠ Ya publicado: ES:{$es_id}\n";
    }
    
    // Rate-limit (evitar sobrecarga)
    usleep(100000); // 100ms
}

echo "\n============================================================\n";
echo "[" . date('H:i:s') . "] Resumen:\n";
echo "  • Traducciones vinculadas: {$linked}/16\n";
echo "  • Drafts publicados: {$published}/16\n";

if (!empty($errors)) {
    echo "\n[ERROR] Se encontraron " . count($errors) . " errores:\n";
    foreach ($errors as $error) {
        echo "  - {$error}\n";
    }
    exit(1);
}

echo "\n[" . date('H:i:s') . "] ✓ Proceso completado exitosamente\n";
exit(0);
