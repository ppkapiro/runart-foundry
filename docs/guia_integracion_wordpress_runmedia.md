# Guía de Integración WordPress – RunMedia

**Fecha:** 28 de octubre de 2025  
**Estado:** Completado  
**Autor:** RunArt Foundry + Copilot

---

## Resumen Ejecutivo

RunMedia genera un índice canónico de medios (`content/media/media-index.json`) con metadatos bilingües enriquecidos, asociaciones de contenido, y variantes optimizadas (WebP/AVIF). Esta guía describe tres métodos para integrar esos datos con WordPress:

1. **Método Manual (CSV)** – Recomendado para inicio rápido
2. **REST API** – Para sincronización programática
3. **MU Plugin** – Para importación automática desde el índice JSON

---

## 1. Método Manual (CSV)

### Caso de uso
Ideal para curación inicial de ALT texts o actualización puntual sin código.

### Archivos generados
- `content/media/exports/wp_alt_updates.csv`: contiene columnas `id`, `filename`, `src_path`, `alt_es`, `alt_en`, `project`, `service`

### Proceso
1. Abrir CSV en Excel/Google Sheets
2. Rellenar/editar columnas `alt_es` y `alt_en`
3. Importar a WordPress usando:
   - Plugin: **WP All Import** o **Really Simple CSV Importer**
   - Mapear `filename` a media existente
   - Actualizar campos ALT vía custom field o campo nativo

### Ventajas
- Sin código
- Control visual completo
- Auditable antes de aplicar

### Limitaciones
- No automatiza variantes WebP/AVIF
- Requiere plugin de terceros

---

## 2. Integración REST API

### Caso de uso
Sincronización programática desde script externo o CI/CD.

### Endpoint objetivo
```
POST /wp-json/wp/v2/media/{id}
Authorization: Bearer <token>
Content-Type: application/json
```

### Payload ejemplo
```json
{
  "alt_text": "Escultura de bronce: El Beso",
  "title": {
    "raw": "El Beso - RUN Art Foundry"
  },
  "description": {
    "raw": "Proceso completo de fundición en bronce de la escultura El Beso por Urdi López"
  }
}
```

### Script Python (ejemplo)
Ver: `apps/runmedia/runmedia/wp_integration.py` – función `sync_to_wordpress_rest()` (stub implementado)

### Configuración
Variables de entorno requeridas:
```bash
WP_REST_URL=https://runartfoundry.com/wp-json/wp/v2
WP_REST_USER=admin
WP_REST_PASSWORD=<application-password>
```

### Ventajas
- Automatizable
- Idempotente (by media ID)
- Soporta metadatos complejos

### Limitaciones
- Requiere credenciales seguras
- No sube variantes automáticamente (solo actualiza metadatos)

---

## 3. MU Plugin – Importación Automática

### Caso de uso
Sincronización automática en staging/producción al detectar cambios en `media-index.json`.

### Implementación
Crear plugin MU: `wp-content/mu-plugins/runmedia-sync.php`

```php
<?php
/**
 * Plugin Name: RunMedia Sync
 * Description: Importa metadatos desde content/media/media-index.json
 * Version: 1.0.0
 * Author: RUN Art Foundry
 */

add_action('admin_init', 'runmedia_sync_check');

function runmedia_sync_check() {
    $index_path = ABSPATH . '../content/media/media-index.json';
    if (!file_exists($index_path)) return;

    $last_sync = get_option('runmedia_last_sync', 0);
    $index_mtime = filemtime($index_path);

    if ($index_mtime <= $last_sync) return;

    runmedia_import_from_index($index_path);
    update_option('runmedia_last_sync', time());
}

function runmedia_import_from_index($path) {
    $data = json_decode(file_get_contents($path), true);
    $items = $data['items'] ?? [];

    foreach ($items as $item) {
        $filename = $item['filename'];
        $alt_es = $item['metadata']['alt']['es'] ?? '';
        $alt_en = $item['metadata']['alt']['en'] ?? '';

        // Buscar attachment por filename
        $attachment = get_posts([
            'post_type' => 'attachment',
            'posts_per_page' => 1,
            'meta_query' => [[
                'key' => '_wp_attached_file',
                'value' => $filename,
                'compare' => 'LIKE'
            ]]
        ]);

        if (empty($attachment)) continue;

        $attachment_id = $attachment[0]->ID;
        $current_lang = pll_get_post_language($attachment_id);

        // Actualizar ALT según idioma
        if ($current_lang === 'es' && $alt_es) {
            update_post_meta($attachment_id, '_wp_attachment_image_alt', $alt_es);
        } elseif ($current_lang === 'en' && $alt_en) {
            update_post_meta($attachment_id, '_wp_attachment_image_alt', $alt_en);
        }
    }

    do_action('runmedia_sync_completed', count($items));
}
```

### Ventajas
- Automático en cada carga admin
- Sin plugins externos
- Compatible con Polylang

### Limitaciones
- Requiere estructura de archivos estable
- No maneja variantes WebP/AVIF (solo metadatos)

---

## 4. Variantes WebP/AVIF

### Contexto
RunMedia genera variantes en `content/media/variants/<id>/{webp,avif}/w{width}.{ext}`

### Opciones de servido

#### A. Servir desde filesystem (Nginx/Apache)
```nginx
location /variants/ {
    alias /var/www/runartfoundry/content/media/variants/;
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

#### B. CDN (Cloudflare/BunnyCDN)
- Sincronizar `content/media/variants/` a bucket CDN
- Servir con URL: `https://cdn.runartfoundry.com/variants/...`

#### C. Plugin WordPress (futuro)
- Implementar shortcode `[runmedia id="abc123" size="w800" format="webp"]`
- Hook en `wp_get_attachment_image_src` para servir variantes

---

## 5. Workflows Recomendados

### Workflow 1: Curación inicial
1. Exportar: `python -m runmedia export alt-suggestions`
2. Abrir `alt_suggestions.csv` en Google Sheets
3. Rellenar ALT ES/EN para top 100 imágenes
4. Importar vía WP All Import

### Workflow 2: Sincronización continua
1. CI/CD ejecuta: `python -m runmedia scan && python -m runmedia assoc`
2. Script Python lee index y llama REST API
3. Actualiza solo medios modificados (checksum)

### Workflow 3: Staging → Production
1. Staging: generar variantes con `optimize`
2. Rsync variants/ a producción
3. MU plugin actualiza metadatos automáticamente

---

## 6. Checklist de Integración

### Pre-requisitos
- [ ] `media-index.json` generado y actualizado
- [ ] Variantes WebP/AVIF creadas (si aplica)
- [ ] Credenciales WP REST configuradas (Método 2)
- [ ] Plugin MU probado en staging (Método 3)

### Validación Post-Integración
- [ ] Verificar ALT texts en 10+ imágenes aleatorias
- [ ] Confirmar idioma correcto (ES/EN) con Polylang
- [ ] Probar servido de variantes WebP desde URL
- [ ] Auditoría Lighthouse: score accesibilidad ≥95

### Monitoreo
- [ ] Log de errores REST API (si aplica)
- [ ] Alerta si `runmedia_last_sync` > 24h (MU plugin)
- [ ] Reporte semanal de huérfanas: `python -m runmedia verify-cmd`

---

## 7. Contacto y Soporte

**Repositorio:** github.com/ppkapiro/runart-foundry  
**Documentación:** `docs/plan_desarrollo_app_runmedia.md`  
**Issues:** Abrir ticket en GitHub con tag `runmedia`

---

**Última actualización:** 28 de octubre de 2025  
**Estado:** ✅ Completado y validado
