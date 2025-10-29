# Guía de Implementación Técnica — RUN Art Foundry

**Fase 3: Implementación Técnica**  
**Fecha**: 27 Octubre 2025  
**Versión**: 1.0

## 📋 Resumen

Esta guía detalla la implementación técnica completa de la estructura WordPress para el sitio web de RUN Art Foundry. Incluye Custom Post Types, taxonomías, ACF fields, templates PHP, y migración de contenido.

---

## 🗂️ Archivos Creados

### 1. Custom Post Types y Taxonomías
**Archivo**: `wp-content/themes/runart-theme/inc/custom-post-types.php`

**CPTs creados:**
- `project` — Proyectos de fundición (archivo: `/projects/`)
- `service` — Servicios técnicos (archivo: `/services/`)
- `testimonial` — Testimonios de artistas (sin archivo público)

**Taxonomías creadas:**
- `artist` — Artistas (no jerárquica, asociada a `project`)
- `technique` — Técnicas de fundición (no jerárquica, asociada a `project`)
- `alloy` — Aleaciones de bronce (no jerárquica, asociada a `project`)
- `patina` — Tipos de pátina (no jerárquica, asociada a `project`)
- `year` — Año de creación (no jerárquica, asociada a `project`)
- `client_type` — Tipo de cliente (jerárquica, asociada a `project`)

### 2. ACF Field Groups (JSON)
**Directorio**: `wp-content/themes/runart-theme/acf-json/`

- `acf-project-fields.json` — 17 campos para CPT Project
- `acf-service-fields.json` — 9 campos para CPT Service
- `acf-testimonial-fields.json` — 9 campos para CPT Testimonial

### 3. Templates PHP
**Directorio**: `wp-content/themes/runart-theme/`

- `single-project.php` — Template para vista individual de proyecto
- `archive-project.php` — Template para archivo de proyectos con filtros

---

## 🚀 Instrucciones de Instalación

### Paso 1: Activar Custom Post Types

1. **Opción A: Via functions.php del theme**
   ```php
   // En wp-content/themes/runart-theme/functions.php
   require_once get_template_directory() . '/inc/custom-post-types.php';
   ```

2. **Opción B: Via plugin personalizado**
   - Crear plugin: `wp-content/plugins/runart-cpts/runart-cpts.php`
   - Copiar el contenido de `custom-post-types.php`
   - Añadir header de plugin:
     ```php
     <?php
     /**
      * Plugin Name: RUN Art Foundry CPTs
      * Description: Custom Post Types y Taxonomías para RUN Art Foundry
      * Version: 1.0
      * Author: RUN Art Foundry
      */
     ```
   - Activar en WordPress Admin → Plugins

3. **Flush permalinks**
   - Ir a `Ajustes → Enlaces permanentes`
   - Hacer clic en "Guardar cambios" (sin modificar nada)
   - Esto regenera las reglas de rewrite para los nuevos CPTs

### Paso 2: Importar ACF Fields

**Requisito**: Advanced Custom Fields PRO instalado y activado

1. Ir a `ACF → Tools → Import Field Groups`
2. Seleccionar archivo: `wp-content/themes/runart-theme/acf-json/acf-project-fields.json`
3. Importar
4. Repetir con `acf-service-fields.json` y `acf-testimonial-fields.json`

**Alternativa (automático):**
- ACF busca automáticamente archivos JSON en `/acf-json/` del theme activo
- Si los archivos están en la ruta correcta, se cargarán automáticamente

### Paso 3: Verificar Templates

1. **Templates single/archive ya disponibles:**
   - `single-project.php` → Debe aparecer automáticamente para CPT Project
   - `archive-project.php` → Debe aparecer automáticamente en `/projects/`

2. **Crear templates adicionales** (opcionales):
   - `single-service.php` → Vista individual de servicio
   - `archive-service.php` → Archivo de servicios
   - `single-testimonial.php` → Vista individual de testimonio

### Paso 4: Configurar Permalinks

**Estructura recomendada:**

```
/projects/williams-carmona-escultura-figurativa/
/services/fundicion-artistica-bronce/
/testimonials/williams-carmona/
/artist/williams-carmona/
/technique/molde-perdido/
```

**Ya configurado en el código:**
- `project` → slug: `projects`
- `service` → slug: `services`
- `testimonial` → slug: `testimonials`
- Taxonomías: `artist`, `technique`, `alloy`, `patina`, `year`, `client-type`

---

## 📊 Estructura de Datos

### Project (CPT)

**Campos principales (ACF):**
- `artist_name` (text) — Nombre del artista
- `alloy` (text) — Aleación (ej. Bronce Cu-Sn 90-10)
- `measures` (text) — Dimensiones
- `edition` (select) — Tipo de edición (única, limitada, abierta)
- `edition_number` (text) — Número de edición (ej. 3/25)
- `patina_type` (text) — Tipo de pátina
- `year` (number) — Año de creación
- `location` (text) — Ubicación
- `video_url` (url) — URL de video (YouTube/Vimeo)
- `credits` (textarea) — Créditos técnicos
- `gallery` (gallery) — Galería de imágenes (8-15)
- `technical_description` (textarea) — Descripción técnica (120-200 palabras)
- `process_steps` (repeater) — Pasos del proceso
- `testimonial_quote` (textarea) — Cita del artista
- `related_testimonial` (post_object) — Testimonio relacionado
- `seo_title` (text, max 60) — Título SEO
- `seo_description` (textarea, max 155) — Descripción SEO

**Taxonomías:**
- `artist`, `technique`, `alloy`, `patina`, `year`, `client_type`

### Service (CPT)

**Campos principales (ACF):**
- `service_icon` (select) — Icono Dashicon
- `service_scope` (repeater) — Alcances del servicio
- `typical_cases` (repeater) — Casos típicos
- `faqs` (repeater) — Preguntas frecuentes
- `cta_text` (text) — Texto del CTA
- `cta_url` (url) — URL del CTA
- `featured` (true_false) — Destacado en homepage
- `seo_title` (text, max 60)
- `seo_description` (textarea, max 155)

### Testimonial (CPT)

**Campos principales (ACF):**
- `author_role` (text) — Rol del autor (ej. Escultor)
- `featured_quote` (textarea) — Cita destacada
- `video_url` (url) — Video del testimonio
- `related_project` (post_object) — Proyecto relacionado
- `author_bio` (textarea) — Biografía del autor
- `author_photo` (image) — Foto del autor
- `featured` (true_false) — Destacado en homepage
- `seo_title` (text, max 60)
- `seo_description` (textarea, max 155)

---

## 🔄 Migración de Contenido

### Proyectos (5 proyectos de Fase 2)

**A crear en WordPress Admin → Proyectos → Añadir nuevo:**

1. **Williams Carmona — Escultura Figurativa**
   - Título: "Williams Carmona — Escultura Figurativa"
   - Slug: `williams-carmona-escultura-figurativa`
   - Contenido: Copiar de `FLUJO_CONSTRUCCION_WEB_RUNART.md` → Fase 2 → 2.1.1
   - ACF fields:
     - artist_name: "Williams Carmona"
     - alloy: "Bronce Cu-Sn (90-10)"
     - edition: "unique"
     - patina_type: "Pátina artística tradicional"
     - year: 2024
     - video_url: "https://www.youtube.com/watch?v=KC2EqTHomx0"
   - Taxonomías:
     - artist: "Williams Carmona"
     - technique: "Molde perdido"
     - year: "2024"
   - Featured Image: [Pendiente de cliente]
   - Gallery: [Pendiente de cliente - 8-15 imágenes]

2. **Roberto Fabelo — Escultura Contemporánea**
   - Título: "Roberto Fabelo — Escultura Contemporánea"
   - Slug: `roberto-fabelo-escultura-contemporanea`
   - Contenido: Copiar de Fase 2 → 2.1.2
   - ACF fields:
     - artist_name: "Roberto Fabelo"
     - alloy: "Bronce Cu-Sn (88-12)"
     - edition: "limited"
     - patina_type: "Pátina verde tradicional (técnicas europeas)"
     - year: 2023
   - Taxonomías:
     - artist: "Roberto Fabelo"
     - technique: "Molde perdido"
     - patina: "Verde tradicional"
     - year: "2023"

3. **Carole Feuerman — Escultura Hiperrealista**
   - Contenido: Fase 2 → 2.1.3
   - artist_name: "Carole A. Feuerman"
   - alloy: "Bronce Cu-Sn (90-10)"
   - patina_type: "Pátina naturalista avanzada"
   - year: 2024

4. **José Oliva — Escultura Monumental**
   - Contenido: Fase 2 → 2.1.4
   - artist_name: "José Oliva"
   - alloy: "Bronce Cu-Sn (85-15)"
   - patina_type: "Pátina protectora resistente UV"
   - year: 2023

5. **Arquidiócesis de Miami — Proyecto Institucional**
   - Contenido: Fase 2 → 2.1.5
   - artist_name: "[Pendiente confirmar]"
   - alloy: "Bronce Cu-Sn (90-10)"
   - patina_type: "Pátina tradicional protectora"
   - year: 2022

### Servicios (5 servicios de Fase 2)

**A crear en WordPress Admin → Servicios → Añadir nuevo:**

1. **Fundición Artística en Bronce**
   - Slug: `fundicion-artistica-bronce`
   - Contenido completo: Fase 2 → 2.2.1
   - ACF fields:
     - service_icon: "dashicons-hammer"
     - featured: true
     - FAQs: 5 preguntas (copiar del contenido)

2. **Pátinas Artísticas para Bronce**
   - Slug: `patinas-artisticas-bronce`
   - Contenido: Fase 2 → 2.2.2
   - service_icon: "dashicons-art"
   - featured: true

3. **Restauración y Conservación de Bronce**
   - Slug: `restauracion-conservacion-bronce`
   - Contenido: Fase 2 → 2.2.3
   - service_icon: "dashicons-admin-tools"

4. **Consultoría Técnica en Fundición**
   - Slug: `consultoria-tecnica-fundicion-escultura`
   - Contenido: Fase 2 → 2.2.4
   - service_icon: "dashicons-lightbulb"

5. **Producción de Ediciones Limitadas**
   - Slug: `ediciones-limitadas-bronce`
   - Contenido: Fase 2 → 2.2.5
   - service_icon: "dashicons-portfolio"
   - featured: true

### Testimonios (3 testimonios de Fase 2)

**A crear en WordPress Admin → Testimonios → Añadir nuevo:**

1. **Williams Carmona**
   - Slug: `williams-carmona`
   - Contenido: Fase 2 → 2.3.1
   - ACF fields:
     - author_role: "Artista visual y escultor"
     - featured_quote: "El trabajo de RUN Art Foundry representa el más alto nivel técnico..."
     - video_url: "https://www.youtube.com/watch?v=KC2EqTHomx0"
     - related_project: [Link al proyecto Williams Carmona]
     - featured: true

2. **Roberto Fabelo**
   - Slug: `roberto-fabelo`
   - Contenido: Fase 2 → 2.3.2
   - author_role: "Artista plástico y escultor"
   - featured_quote: "RUN Art Foundry entiende que la fundición no es solo un proceso técnico..."
   - featured: true

3. **Carole Feuerman**
   - Slug: `carole-feuerman`
   - Contenido: Fase 2 → 2.3.3
   - author_role: "Escultora hiperrealista"
   - featured_quote: "El nivel de precisión que logró RUN Art Foundry..."
   - featured: false

---

## 🎨 Estilos CSS Recomendados

**Archivo**: `wp-content/themes/runart-theme/assets/css/projects.css`

```css
/* Project Single */
.project-hero {
    width: 100%;
    max-height: 600px;
    overflow: hidden;
    margin-bottom: 2rem;
}

.project-hero-image {
    width: 100%;
    height: auto;
    object-fit: cover;
}

.project-technical-sheet {
    background: #f5f5f5;
    padding: 2rem;
    margin: 2rem 0;
    border-left: 4px solid #C30000;
}

.technical-sheet-list {
    list-style: none;
    padding: 0;
}

.technical-sheet-list li {
    padding: 0.5rem 0;
    border-bottom: 1px solid #ddd;
}

.project-gallery .gallery-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 1rem;
    margin-top: 1rem;
}

/* Project Archive */
.projects-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 2rem;
    margin: 2rem 0;
}

.project-card {
    border: 1px solid #e0e0e0;
    transition: transform 0.3s, box-shadow 0.3s;
}

.project-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 10px 20px rgba(0,0,0,0.1);
}

.project-card-image img {
    width: 100%;
    height: 250px;
    object-fit: cover;
}

.archive-filters {
    background: #f9f9f9;
    padding: 2rem 0;
    margin-bottom: 2rem;
}

.filters-form {
    display: flex;
    gap: 1rem;
    flex-wrap: wrap;
    align-items: flex-end;
}

.filter-group {
    flex: 1;
    min-width: 150px;
}
```

---

## ✅ Checklist de Verificación

Después de implementar:

- [ ] CPTs aparecen en menú admin (Proyectos, Servicios, Testimonios)
- [ ] Taxonomías aparecen en cada CPT correspondiente
- [ ] ACF fields aparecen al editar post de cada CPT
- [ ] Template `single-project.php` se muestra correctamente
- [ ] Template `archive-project.php` funciona con filtros
- [ ] Permalinks funcionan: `/projects/slug/`, `/services/slug/`
- [ ] Imágenes destacadas se muestran correctamente
- [ ] Galerías ACF funcionan con lightbox
- [ ] Videos de YouTube se embed automáticamente
- [ ] Navegación anterior/siguiente funciona
- [ ] Filtros de taxonomía funcionan en archivo
- [ ] SEO fields (title, description) se capturan correctamente

---

## 🐛 Troubleshooting

### CPTs no aparecen en admin
**Solución**: Verificar que `custom-post-types.php` está siendo require'd correctamente en `functions.php`

### Error 404 en permalinks
**Solución**: Ir a Ajustes → Enlaces permanentes → Guardar cambios (flush rewrite rules)

### ACF fields no aparecen
**Solución**: 
1. Verificar que ACF PRO está instalado
2. Importar manualmente los archivos JSON desde ACF → Tools → Import
3. Verificar que `acf-json/` está en la ruta correcta del theme

### Templates no se aplican
**Solución**: 
1. Verificar nombres de archivo (`single-project.php`, no `single-projects.php`)
2. Verificar que están en raíz del theme, no en subdirectorio
3. Limpiar caché (si hay plugin de cache activo)

### Videos no se muestran
**Solución**: Usar URLs completas de YouTube (`https://www.youtube.com/watch?v=...`), no compartidos (`youtu.be/...`)

---

## 📞 Soporte

**Documentación completa**: `docs/live/FLUJO_CONSTRUCCION_WEB_RUNART.md`  
**Contenido de Fase 2**: Ver secciones 2.1 a 2.6 del documento maestro

**Próximos pasos**: Fase 4 (Estilo Visual y Accesibilidad), Fase 5 (Revisión Final y Publicación)
