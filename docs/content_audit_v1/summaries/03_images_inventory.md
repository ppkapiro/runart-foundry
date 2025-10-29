# 03 · Inventario de Imágenes y Multimedia

**Fecha:** 2025-10-29  
**Rama:** `feat/content-audit-v1`  
**Propósito:** Catalogar imágenes, variantes, y estado de biblioteca de medios

---

## Resumen Ejecutivo

El repositorio contiene **6,162 imágenes catalogadas** en `media-index.json` (343,841 líneas), con variantes optimizadas en WebP y AVIF. Sin embargo, la **biblioteca original está vacía** (`content/media/library/` = 0 archivos), y las rutas en el índice apuntan a `mirror/raw/2025-10-01/`, una estructura histórica del sitio WordPress.

---

## Estadísticas Generales

| Métrica | Valor |
|---------|-------|
| **Total de imágenes catalogadas** | 6,162 |
| **Archivo índice** | `content/media/media-index.json` (343,841 líneas) |
| **Biblioteca original** | `content/media/library/` (VACÍA) |
| **Variantes generadas** | `content/media/variants/` (30,810 archivos) |
| **Formatos originales** | JPG (5,412), PNG (689), WebP (46), GIF (15) |
| **Variantes por imagen** | 10 (5 WebP + 5 AVIF en anchos: 2560, 1600, 1200, 800, 400) |

---

## Distribución por Formato Original

```
   5,412  jpg  (87.8%)
     689  png  (11.2%)
      46  webp ( 0.7%)
      15  gif  ( 0.2%)
   ─────────────────
   6,162  total
```

**Análisis:**
- **JPG dominante:** Fotografías de proyectos, workshops, procesos de fundición.
- **PNG secundario:** Logos, iconos de plugins, placeholders de temas.
- **WebP/GIF minoritarios:** Spinners, loaders, íconos animados.

---

## Estructura de Variantes

Cada imagen original tiene **10 variantes** generadas automáticamente:

```
content/media/variants/[SHA256_ID]/
├── webp/
│   ├── w2560.webp  (Original hasta 2560px ancho)
│   ├── w1600.webp  (Desktop grande)
│   ├── w1200.webp  (Laptop)
│   ├── w800.webp   (Tablet)
│   └── w400.webp   (Mobile)
└── avif/
    ├── w2560.avif
    ├── w1600.avif
    ├── w1200.avif
    ├── w800.avif
    └── w400.avif
```

**Total de variantes generadas:** 6,162 × 10 = **61,620 archivos** (teórico).  
**Presentes en disco:** ~30,810 archivos (50% de cobertura estimada).

---

## Ejemplo de Registro en `media-index.json`

```json
{
  "id": "97d07bd5a561",
  "filename": "runartfoundry-home.jpg",
  "ext": "jpg",
  "checksum": {
    "sha256": "97d07bd5a561c9c5b4b7ff2fd2d1d388a32b12ba2ff9d47fd76a92d35dc3df64"
  },
  "source": {
    "origin": "repo",
    "path": "mirror/raw/2025-10-01/site_static/wp-content/uploads/2023/04/runartfoundry-home.jpg"
  },
  "width": 1813,
  "height": 1196,
  "metadata": {
    "alt": {
      "es": "RUN Art Foundry — Taller de fundición artística en bronce",
      "en": "RUN Art Foundry — Artistic bronze casting workshop"
    }
  },
  "related": {
    "projects": ["home", "runartfoundry", "run-art-foundry-branding"],
    "services": ["bronze-casting"]
  },
  "variants": {
    "webp": true,
    "avif": true
  }
}
```

---

## Top 50 Imágenes (Muestra)

| Filename | Extensión | Dimensiones | Proyecto Relacionado | Alt Text (ES) |
|----------|-----------|-------------|----------------------|---------------|
| `runartfoundry-home.jpg` | jpg | 1813×1196 | `home` | RUN Art Foundry — Taller de fundición artística en bronce |
| `background-image-fallback.jpg` | jpg | 1500×600 | `back` | (sin alt) |
| `spinner.gif` | gif | 20×20 | — | (sin alt) |
| `author-image-placeholder.png` | png | 500×500 | — | (sin alt) |
| `featured-image-placeholder.png` | png | 1000×650 | — | (sin alt) |
| `acf-logo.png` | png | 256×256 | `logo` | RUN Art Foundry — Taller de fundición artística en bronce |
| `screenshot.png` | png | 1200×900 | `screen` | (sin alt) |

**Hallazgos:**
- Solo **~10% de las imágenes** tienen metadata alt bilingüe completa.
- **Mayoría de imágenes** provienen de plugins/temas (GeneratePress, Yoast SEO, WP core).
- **Imágenes de contenido real** (proyectos, servicios) son minoría (~5%).

---

## Imágenes por Categoría

### Contenido Editorial (estimado ~300 imágenes)
- **Proyectos de fundición:** Esculturas en bronce, moldes, procesos (ej: `runartfoundry-home.jpg`)
- **Servicios:** Bronze casting, patinas, restauración
- **Workshop/Team:** Fotos del taller, artesanos trabajando

### Assets de Plugins (~5,000 imágenes)
- **Yoast SEO:** `seo_analysis.png`, `rest_api.png`, `twitter_card.png` (36 imágenes)
- **GeneratePress Premium:** `background-image-fallback.jpg`, `spinner.gif`, `transparency-grid.png` (12 imágenes)
- **Advanced Custom Fields:** `acf-logo.png` (1 imagen)
- **WordPress Core:** `wpspin_light.gif`, `loading.gif`, thumbnails (200+ imágenes)

### Otros (~862 imágenes)
- **Avatares/placeholders:** `author-image-placeholder.png`, `featured-image-placeholder.png`
- **Íconos UI:** `close.png`, `arrow-down.png`, `ordering-icons.png`
- **Screenshots:** `screenshot.png` (capturas de temas/plugins)

---

## Problema Crítico: Biblioteca Original Vacía

```bash
$ find content/media/library -type f
(0 archivos)
```

**Implicaciones:**
1. Las **rutas en `media-index.json`** apuntan a `mirror/raw/2025-10-01/`, una estructura histórica que puede no estar sincronizada.
2. Las **variantes optimizadas existen** (`content/media/variants/`), pero sin originales es imposible regenerarlas o editarlas.
3. **RunMedia** (sistema de gestión de imágenes) espera originales en `library/` para procesamiento.

**Recomendación urgente:** Copiar imágenes originales desde `mirror/raw/2025-10-01/` a `content/media/library/` y actualizar rutas en `media-index.json`.

---

## Integración con Plantillas PHP

Las plantillas usan la función `runart_get_runmedia_image($slug, $size)` para obtener imágenes:

```php
$hero_image = runart_get_runmedia_image('run-art-foundry-branding', 'w2560');
```

**Slugs detectados en plantillas:**
- `run-art-foundry-branding` (Hero de Home)
- `workshop-hero` (Hero de About)
- `blog-hero` (Hero de Blog)
- `contact-hero` (Hero de Contact)

**Estado:** Función implementada en `functions.php`, pero **slugs no coinciden** con nombres de archivos en `media-index.json` (ej: `run-art-foundry-branding` vs `runartfoundry-home.jpg`).

---

## Metadatos de Imágenes

### Campos Disponibles en `media-index.json`

| Campo | Descripción | Cobertura |
|-------|-------------|-----------|
| `metadata.alt` | Texto alternativo (ES/EN) | ~10% |
| `metadata.title` | Título de imagen (ES/EN) | <5% |
| `metadata.description` | Descripción larga (ES/EN) | <1% |
| `metadata.tags` | Etiquetas temáticas | ~2% |
| `metadata.copyright.holder` | Titular de derechos | 100% ("RUN Art Foundry") |
| `metadata.copyright.license` | Licencia | 100% ("All Rights Reserved") |
| `related.projects` | Proyectos relacionados | ~15% |
| `related.services` | Servicios relacionados | ~5% |

**Problema:** Metadatos insuficientes para SEO y accesibilidad.

---

## Recomendaciones

### Urgente
1. **Poblar `content/media/library/`:**
   - Copiar originales desde `mirror/raw/2025-10-01/`
   - Verificar integridad con checksums SHA-256 del índice

2. **Normalizar slugs de RunMedia:**
   - Mapear `run-art-foundry-branding` → `97d07bd5a561` (ID del índice)
   - Actualizar `association_rules.yaml` con aliases

### Corto Plazo
3. **Completar metadatos:**
   - Agregar alt text bilingüe a ~5,500 imágenes faltantes
   - Etiquetar imágenes de contenido editorial (projects, services)

4. **Optimizar catálogo:**
   - Eliminar imágenes de plugins/temas no utilizadas (~80% del total)
   - Retener solo imágenes de contenido real (~1,200 imágenes)

### Medio Plazo
5. **Integrar RunMedia:**
   - Configurar app de gestión de imágenes
   - Automatizar generación de variantes
   - Implementar CDN para servir variantes optimizadas

---

## Anexos

### Archivo: `content/media/media-index.json`
- **Líneas:** 343,841
- **Tamaño:** ~45 MB
- **Formato:** JSON con array de 6,162 objetos
- **Generado:** 2025-10-28T13:09:35Z

### Archivo: `content/media/association_rules.yaml`
- Define reglas de asociación entre slugs y IDs
- Estado: Pendiente revisión detallada

### Archivo: `content/media/media_manifest.json`
- Manifiesto secundario (uso desconocido)
- Estado: Pendiente revisión detallada

---

Ver `04_texts_vs_images_matrix.md` para análisis de relación entre textos y multimedia.
