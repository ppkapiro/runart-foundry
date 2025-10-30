# REST Bridge API — Content Audit Endpoints

**Versión:** 1.1.0  
**Plugin:** runart-wpcli-bridge  
**Fecha:** 2025-10-30

---

## Descripción

El plugin `runart-wpcli-bridge` proporciona endpoints REST seguros para auditoría de contenido. Estos endpoints reemplazan el uso de SSH y WP-CLI arbitrario, cumpliendo con las políticas de READ_ONLY y DRY_RUN por diseño.

---

## Endpoints de Auditoría

### 1. GET /wp-json/runart/audit/pages

**Descripción:** Inventario completo de páginas y posts (F1)

**Autenticación:** WordPress Application Password (manage_options capability required)

**Respuesta:**
```json
{
  "ok": true,
  "total": 45,
  "total_es": 22,
  "total_en": 20,
  "total_unknown": 3,
  "items": [
    {
      "id": 123,
      "url": "https://example.com/page",
      "lang": "es",
      "type": "page",
      "status": "publish",
      "title": "Página de ejemplo",
      "slug": "pagina-ejemplo"
    }
  ],
  "meta": {
    "timestamp": "2025-10-30T00:00:00+00:00",
    "site": "https://example.com",
    "phase": "F1",
    "description": "Inventario de Páginas y Posts (ES/EN)"
  }
}
```

**Campos por item:**
- `id` (int): Post ID
- `url` (string): Permalink permanente
- `lang` (string): Código de idioma (`es`, `en`, `-` si desconocido)
- `type` (string): Post type (`page`, `post`, custom)
- `status` (string): Estado (`publish`, `draft`, `pending`, `private`)
- `title` (string): Título del post
- `slug` (string): Slug (post_name)

**Detección de idioma:**
- Polylang: Usa `pll_get_post_language()` si disponible
- Fallback: Revisa taxonomía `language`
- Default: `-` si no se detecta

**Ejemplo curl:**
```bash
curl -u "runart-admin:APP_PASSWORD" \
  https://staging.runartfoundry.com/wp-json/runart/audit/pages
```

---

### 2. GET /wp-json/runart/audit/images

**Descripción:** Inventario completo de imágenes/media (F2)

**Autenticación:** WordPress Application Password (manage_options capability required)

**Respuesta:**
```json
{
  "ok": true,
  "total": 312,
  "total_es": 145,
  "total_en": 140,
  "total_unknown": 27,
  "items": [
    {
      "id": 456,
      "url": "https://example.com/wp-content/uploads/2025/10/escultura.jpg",
      "lang": "es",
      "mime": "image/jpeg",
      "width": 1920,
      "height": 1080,
      "size_kb": 245.67,
      "title": "Escultura de bronce",
      "alt": "Escultura moderna de bronce en galería",
      "file": "2025/10/escultura.jpg"
    }
  ],
  "meta": {
    "timestamp": "2025-10-30T00:00:00+00:00",
    "site": "https://example.com",
    "phase": "F2",
    "description": "Inventario de Imágenes (Media Library)"
  }
}
```

**Campos por item:**
- `id` (int): Attachment ID
- `url` (string): URL completa de la imagen
- `lang` (string): Código de idioma (`es`, `en`, `-`)
- `mime` (string): MIME type (`image/jpeg`, `image/png`, `image/webp`, etc.)
- `width` (int): Ancho en píxeles
- `height` (int): Alto en píxeles
- `size_kb` (float): Tamaño del archivo en KB
- `title` (string): Título del attachment
- `alt` (string): Texto alternativo (ALT) para accesibilidad
- `file` (string): Ruta relativa del archivo (`YYYY/MM/filename.ext`)

**Detección de idioma:**
- Igual que `/audit/pages`: Polylang → taxonomía → default `-`

**Ejemplo curl:**
```bash
curl -u "runart-admin:APP_PASSWORD" \
  https://staging.runartfoundry.com/wp-json/runart/audit/images
```

---

## Uso con GitHub Actions

### Workflow: audit-content-rest.yml

**Ubicación:** `.github/workflows/audit-content-rest.yml`

**Trigger:** Manual (workflow_dispatch)

**Inputs:**
- `phase`: Fase a ejecutar (`f1_pages`, `f2_images`, `both`)
- `target_branch`: Branch donde commitear resultados (default: `feat/content-audit-v2-phase1`)

**Ejemplo de ejecución:**
```bash
# Ejecutar F1 y F2 simultáneamente
gh workflow run audit-content-rest.yml -f phase=both

# Solo F1 (páginas)
gh workflow run audit-content-rest.yml -f phase=f1_pages

# Solo F2 (imágenes)
gh workflow run audit-content-rest.yml -f phase=f2_images

# Cambiar branch destino
gh workflow run audit-content-rest.yml -f phase=both -f target_branch=develop
```

**Flujo del workflow:**
1. Fetch: Consume endpoint REST (`curl` con autenticación)
2. Transform: Convierte JSON → Markdown con `jq`
3. Commit: Actualiza archivos en `research/content_audit_v2/` y commitea
4. Push: Sube cambios al branch especificado
5. Report: Genera reporte en `_reports/audit/audit_rest_*.md`

**Archivos actualizados:**
- `research/content_audit_v2/01_pages_inventory.md` (F1)
- `research/content_audit_v2/02_images_inventory.md` (F2)

**Variables requeridas:**
- `WP_BASE_URL` (var): URL base del sitio (ej: `https://staging.runartfoundry.com`)
- `WP_USER` (secret): Usuario con permisos admin
- `WP_APP_PASSWORD` (secret): Application Password de WordPress

---

## Seguridad

### Autenticación
- **Método:** WordPress Application Password (RFC 2617 Basic Auth)
- **Permisos:** Requiere capability `manage_options` (administrador)
- **Transmisión:** HTTPS obligatorio (el plugin valida SSL en producción)

### Protección adicional (opcional)
- Cloudflare Access con Service Token
- Rate limiting en Cloudflare
- IP whitelisting para GitHub Actions IPs

### Datos expuestos
- ✅ Solo metadatos públicos (títulos, URLs, slugs, idioma)
- ✅ No expone contenido sensible (usuarios, emails, passwords)
- ✅ No expone configuración interna de WP
- ✅ READ_ONLY: No permite escritura ni modificación

---

## Desarrollo Local

### Requisitos
- WordPress 5.8+
- PHP 7.4+
- Plugin Polylang (opcional, para detección de idioma)

### Instalación
```bash
# Copiar plugin a WordPress local
cp -r tools/wpcli-bridge-plugin /path/to/wordpress/wp-content/plugins/runart-wpcli-bridge

# Activar plugin
wp plugin activate runart-wpcli-bridge
```

### Pruebas locales
```bash
# Health check
curl http://wp.local/wp-json/runart/v1/bridge/health

# F1 - Páginas
curl -u "admin:admin" http://wp.local/wp-json/runart/audit/pages | jq

# F2 - Imágenes
curl -u "admin:admin" http://wp.local/wp-json/runart/audit/images | jq

# Verificar conteos
curl -u "admin:admin" http://wp.local/wp-json/runart/audit/pages | jq '{total, total_es, total_en, total_unknown}'
```

### Validación de respuesta
```bash
# Schema validation con jq
curl -u "admin:admin" http://wp.local/wp-json/runart/audit/pages | \
  jq 'if .ok and .total and .items then "✅ Valid" else "❌ Invalid" end'
```

---

## Deploy a Staging

### Opción 1: Via workflow (recomendado)
```bash
# Build plugin
gh workflow run build-wpcli-bridge.yml

# Esperar a que termine (~2min)

# Deploy a staging
gh workflow run install-wpcli-bridge.yml

# Verificar instalación
curl -u "runart-admin:APP_PASSWORD" \
  https://staging.runartfoundry.com/wp-json/runart/v1/bridge/health
```

### Opción 2: Manual (emergencia)
```bash
# Build local
cd tools/wpcli-bridge-plugin
zip -r runart-wpcli-bridge.zip . -x ".*" -x "__MACOSX"

# Subir a staging via panel IONOS o SFTP
# Activar desde wp-admin → Plugins
```

---

## Troubleshooting

### Error: 401 Unauthorized
**Causa:** Credenciales incorrectas o Application Password expirado

**Solución:**
```bash
# Regenerar Application Password en wp-admin
# Actualizar GitHub Secret WP_APP_PASSWORD
gh secret set WP_APP_PASSWORD
```

### Error: 403 Forbidden
**Causa:** Usuario no tiene capability `manage_options`

**Solución:**
```bash
# Verificar rol del usuario
wp user get runart-admin --field=roles

# Promover a administrador si es necesario
wp user set-role runart-admin administrator
```

### Error: 404 Not Found
**Causa:** Plugin no instalado o endpoints no registrados

**Solución:**
```bash
# Verificar plugin activo
wp plugin list | grep runart-wpcli-bridge

# Reactivar
wp plugin deactivate runart-wpcli-bridge
wp plugin activate runart-wpcli-bridge

# Flush rewrite rules
wp rewrite flush
```

### Error: Empty response (total: 0)
**Causa:** Base de datos sin contenido o filtro demasiado restrictivo

**Solución:**
```bash
# Verificar posts en DB
wp post list --post_type=page,post --format=count

# Verificar attachments
wp media list --format=count

# Si devuelve 0, importar contenido o revisar post_status
```

### Error: Language detection fails (all `-`)
**Causa:** Polylang no instalado o taxonomía `language` no configurada

**Solución:**
```bash
# Verificar Polylang
wp plugin list | grep polylang

# Verificar taxonomía language
wp taxonomy list | grep language

# Si no existe, considerar añadir detección manual por post_meta
```

---

## Changelog

### v1.1.0 (2025-10-30)
- ✅ Añadidos endpoints `/audit/pages` y `/audit/images`
- ✅ Soporte para detección de idioma (Polylang)
- ✅ Cálculo de tamaño de archivo (KB) para imágenes
- ✅ Extracción de ALT text para accesibilidad
- ✅ Conteos agregados por idioma (ES/EN/unknown)

### v1.0.0 (2025-10-20)
- ✅ Endpoints base: health, cache_flush, rewrite_flush, users, plugins
- ✅ Autenticación con Application Password
- ✅ Respuestas JSON estandarizadas

---

## Referencias

- Plugin source: `tools/wpcli-bridge-plugin/runart-wpcli-bridge.php`
- Workflow: `.github/workflows/audit-content-rest.yml`
- Plan Maestro: `docs/content/PLAN_AUDITORIA_CONTENIDO_IMAGENES.md`
- Bitácora: `_reports/BITACORA_AUDITORIA_V2.md`
- Opciones de ejecución: `_reports/F1_F2_EXECUTION_OPTIONS_20251029.md`

---

**Última actualización:** 2025-10-30  
**Mantenedor:** RunArt Foundry Team

