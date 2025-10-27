# Inventario base de imágenes — RunMedia

Fecha: 2025-10-27
Ámbito: Repositorio local + mirror de sitio WP + documentación interna

## 1. Ubicaciones detectadas de imágenes (carpetas)

- content/media/
  - Archivo: content/media/media_manifest.json (manifesto de medios existente)
- wp-content/themes/runart-theme/
  - Referencias a assets: /wp-content/themes/runart-theme/assets/images/placeholder-project.jpg (archivo referenciado; carpeta `assets/images` no presente en repo)
- wp-content/themes/runart-base/
  - Referencia a logo en mu-plugins: /wp-content/themes/runart-base/assets/images/logo.png (carpeta no presente en repo)
- mirror/raw/2025-10-01/wp-content/uploads/
  - Estructura WP histórica por año/mes (2013–2025). Sirve como snapshot del origen.
- mirror/raw/2025-10-01/site_static/wp-content/uploads/
  - Copia estática del sitio; ejemplo: 2023/04/runartfoundry-home.jpg
- docs/ (MkDocs/Briefing)
  - Favicon referenciado: /assets/images/favicon.png en HTML de snippets (assets de mkdocs, no del WP)
- docs/ui_roles/datos_demo/
  - JSON de demo con rutas relativas a imágenes de evidencia (./evidencias/*.jpg) — solo demo, no productivo.

Observaciones:
- En el repo no existe `wp-content/uploads/` (esperable). Para inventario real de medios WP, usar mirror/ o staging.
- Paths de assets de temas (assets/images) están referenciados pero las carpetas no están versionadas (probablemente assets de despliegue o faltantes en el template).

## 2. Convenciones de nombres detectadas

- Nombre por contexto “hero-es.jpg”, “hero-en.jpg”: indican variante por idioma.
- Manifest `media_manifest.json` usa campos `id`, `filename`, `type`, `featured_in` (pistas de dónde se usa).
- En documentación pública aparecen patrones: 
  - /media/projects/{slug-obra}/cover.jpg
  - /media/projects/{slug-obra}/01.jpg, 02.jpg… (ordinales de galería)
- Placeholder de proyectos: `placeholder-project.jpg`.
- En documentación/UI se mencionan términos como “pátina”, “fabricacion”, “matriz_fase6.png”, lo que sugiere taxonomía temática.

## 3. Rutas relativas referenciadas en contenido y código

- Mu-plugins:
  - runart-social-meta.php: /wp-content/uploads/logo-runart.png (imagen por defecto OG/Twitter)
  - runart-schemas.php: /wp-content/themes/runart-base/assets/images/logo.png (logo JSON-LD Organization)
- Tema `runart-theme`:
  - archive-project.php: /wp-content/themes/runart-theme/assets/images/placeholder-project.jpg
  - single-project.php: usa `get_field('gallery')` (ACF) → genera <img src="...sizes['medium']"> (imágenes desde Media Library)
  - single-service.php: `service_gallery` (ACF) → `<img src="...sizes['large']">`
- Documentación (MkDocs / docs/live/ARQUITECTURA_...):
  - /media/projects/{slug-obra}/cover.jpg, /01.jpg, /02.jpg
- Mirror (sitio estático):
  - /wp-content/uploads/2023/04/runartfoundry-home.jpg

## 4. Patrones de asociación imagen → contenido

- ACF en `single-project.php` y `single-service.php` indica que galería/featured se gestionan vía Media Library (relación directa con posts/CPTs).
- Convención propuesta en docs: `/media/projects/{slug}/...` sugiere que RunMedia debería mapear slug del proyecto ↔ carpeta.
- Manifest `content/media/media_manifest.json` ya contiene `featured_in` (IDs lógicos como home_hero_es) que pueden cruzarse con páginas/plantillas.

## 5. Metadatos presentes/ausentes

- Presente:
  - Media Library (vía ACF) típicamente guarda título/alt/caption; no visible en repo, pero inferido por plantillas.
  - Manifest JSON: id, filename, type, size, hash, featured_in, test.
- Ausente en código:
  - Asignación explícita de alt/texto bilingüe desde ACF (se usa `$image['alt']` cuando existe; si falta, queda vacío).
  - No hay esquema estándar de “tipo de toma” (ej. vista-frontal, detalle, proceso) en repo.

## 6. Relaciones implícitas a partir de nombres y carpetas

- `hero-es.jpg` / `hero-en.jpg`: relación a idioma (página Home ES/EN).
- `placeholder-project.jpg`: asociación al CPT project como fallback.
- `/media/projects/{slug}/nn.jpg`: orden natural para galerías.
- Mirror `uploads/YYYY/MM/` puede asociarse a fechas de publicación o batch de carga.

## 7. Imágenes potencialmente sueltas/no vinculadas

- En mirror estático existen archivos (p.ej., uploads/2023/04/runartfoundry-home.jpg) cuya vinculación actual a contenido WP no es comprobable solo con repo. Requiere cruce con la BD o con sitemap de staging.
- En docs/ui_roles/datos_demo hay rutas demo a `./evidencias/*.jpg` (no forman parte del sitio).

## 8. Propuesta de esquema de carpetas (RunMedia)

- images/
  - projects/{slug}/
    - cover.{webp|jpg}
    - poster.{webp|jpg}
    - 01.{webp|jpg}
    - 02.{webp|jpg}
    - ...
  - services/{slug}/
    - hero.{webp|jpg}
    - demo-01.{webp|jpg}
  - blog/{slug}/
    - hero.{webp|jpg}
    - inline-01.{webp|jpg}
  - common/
    - logo.svg
    - placeholder-project.jpg
    - social-default.jpg

Notas:
- WebP preferente (+ JPG fallback). Tamaños responsivos via WordPress (srcset) o build.
- Mantener naming consistente con sufijos de rol (cover, poster, hero, inline, detalle, proceso).

## 9. Plantilla base de metadatos por imagen

```json
{
  "id": "projects:feuerman:cover",
  "title": "{Obra} — Cover",
  "description": "{Descripción breve de la imagen}",
  "alt": {
    "es": "{Obra} de {Artista}, vista frontal",
    "en": "{Work} by {Artist}, front view"
  },
  "artist": "{Nombre}",
  "technique": ["cera perdida"],
  "shot_type": "frontal|detalle|proceso|montaje",
  "order": 1,
  "source": "library|runmedia|externo",
  "hash": "{sha256}",
  "width": 1600,
  "height": 900,
  "formats": ["webp", "jpg"],
  "featured_in": ["projects/{slug}"]
}
```

## 10. Exportación propuesta (media-index.json)

- Archivo JSON en `content/media/media-index.json` (o `content/media/index.json`) con entradas por imagen.
- Claves sugeridas por ítem:
  - id, path (ruta relativa dentro de `images/`), title, description, alt.{es,en}, tags [artist, technique, shot_type], order, formats, hash, featured_in, source.
- Ejemplo:

```json
[
  {
    "id": "projects:feuerman:01",
    "path": "images/projects/feuerman/01.webp",
    "title": "Feuerman — detalle de pátina",
    "alt": {"es": "Detalle de pátina verde", "en": "Green patina detail"},
    "tags": ["artist:Feuerman", "technique:patina", "shot:detalle"],
    "order": 1,
    "formats": ["webp", "jpg"],
    "hash": "...",
    "featured_in": ["projects/feuerman"],
    "source": "runmedia"
  }
]
```

## 11. Checklist de integración con WordPress

- Fuente de verdad de metadatos (media-index.json) ↔ sincronización a ACF (alt bilingüe, shot_type, order).
- Helpers para alt automático si falta (`$image['alt']` vacío): construir desde metadatos.
- Reemplazar rutas hardcodeadas por funciones/helpers (ya se hizo para CTAs; replicar para medios si aplicara).
- Social default image: asegurar que exista y esté referenciada correctamente (actualmente `/wp-content/uploads/logo-runart.png`).
- Logo JSON-LD: apuntar a `images/common/logo.svg` o a media-index mapeado.

## 12. Hallazgos clave y gaps

- No hay carpeta `assets/images` en los temas dentro del repo, aunque se referencian archivos ahí.
- El default social image apunta a `/wp-content/uploads/logo-runart.png` (requiere presencia en la librería de medios WP).
- Existe `content/media/media_manifest.json` como base; RunMedia puede evolucionarlo hacia `media-index.json` enriquecido.
- Mirror `uploads/` ofrece snapshot histórico útil para migración y detección de huérfanas.

## 13. Recomendaciones inmediatas

1) Crear `images/common/` en repo para logo y placeholders controlados por RunMedia (luego sincronizar con WP).
2) Generar `content/media/media-index.json` a partir del manifest actual + detección de patrones /media/projects/{slug}/.
3) Auditar en staging la librería de medios: extraer listado con `wp media list --format=json` para cruzar con RunMedia.
4) Definir convención de alt bilingüe y shot_type en ACF para projects/services/testimonials.
5) Preparar script de migración: mirror uploads → estructura `images/` normalizada, con WebP y metadatos.

---

Documento autogenerado como base para la app RunMedia. Este archivo es el punto de partida para diseño de esquema, migración y automatización.
