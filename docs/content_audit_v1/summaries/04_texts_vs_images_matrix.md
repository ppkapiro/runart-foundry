# 04 · Matriz Texto-Imagen

**Fecha:** 2025-10-29  
**Rama:** `feat/content-audit-v1`  
**Propósito:** Análisis de relación entre contenido textual y recursos multimedia

---

## Resumen Ejecutivo

El sitio RunArt Foundry presenta una **desconexión moderada** entre contenido textual (mayormente hardcodeado en PHP) y recursos multimedia (6,162 imágenes catalogadas pero 95% de plugins/temas). Solo **~5% de las imágenes** están directamente relacionadas con el contenido editorial del sitio (proyectos de fundición, servicios, workshop).

---

## Análisis por Página

### 🏠 Home (`front-page.php`)

| Sección | Texto | Imagen Esperada | Imagen Real | Estado |
|---------|-------|-----------------|-------------|--------|
| **Hero** | "Excellence in Art Casting" | Hero workshop/foundry | `run-art-foundry-branding` (slug, no archivo) | 🔴 Falta imagen |
| **Featured Projects** | Loop de 6 proyectos | Thumbnails de proyectos | RunMedia `$project_slug` | 🟡 Depende de posts |
| **Services Preview** | 5 tarjetas (Bronze Casting, Patinas, etc.) | Íconos emoji 🔥🎨🏺🔧📐 | **Solo emojis** (sin imágenes) | 🔴 Sin multimedia |
| **Testimonials** | Loop de 3 testimonios | Fotos de clientes | **Sin imágenes** | 🔴 Sin multimedia |
| **Blog Preview** | Loop de 3 posts | Featured images de posts | `the_post_thumbnail('medium')` | 🟡 Depende de posts |
| **Stats** | "40+ Years", "500+ Projects" | Íconos/gráficos | **Solo texto** | 🔴 Sin multimedia |

**Ratio texto/imagen:** 30% (2/7 secciones con imágenes)

---

### 📖 About (`page-about.php`)

| Sección | Texto | Imagen Esperada | Imagen Real | Estado |
|---------|-------|-----------------|-------------|--------|
| **Hero** | "About RUN Art Foundry" | Workshop interior/equipo | `workshop-hero` (slug, no archivo) | 🔴 Falta imagen |
| **Our Story** | 3 tarjetas (Origins, Workshop, Philosophy) | Fotos históricas/taller | **Solo texto** | 🔴 Sin multimedia |
| **Our Process** | 9 pasos (Model → Final Finish) | Diagrama de flujo o fotos de proceso | **Solo texto + números** | 🔴 Sin multimedia |
| **Our Values** | 4 valores (Precision, Integrity, etc.) | Íconos ilustrativos | **Solo texto** | 🔴 Sin multimedia |
| **Stats** | "40+ Years", "500+ Projects" | Íconos/gráficos | **Solo texto** | 🔴 Sin multimedia |

**Ratio texto/imagen:** 0% (0/5 secciones con imágenes)

---

### 🔧 Services (`archive-service.php`)

| Sección | Texto | Imagen Esperada | Imagen Real | Estado |
|---------|-------|-----------------|-------------|--------|
| **Hero** | "Our Services" | Workshop tools/procesos | **Sin hero image** | 🔴 Sin multimedia |
| **Services Loop** | Loop de posts `service` | Thumbnails por servicio (ej: horno de fundición, pátinas aplicadas) | RunMedia `$service_slug` | 🟡 Depende de posts |

**Ratio texto/imagen:** 50% (1/2 secciones con potencial de imágenes)

---

### 🎨 Projects (`archive-project.php`)

| Sección | Texto | Imagen Esperada | Imagen Real | Estado |
|---------|-------|-----------------|-------------|--------|
| **Hero** | "Our Projects" | Featured sculpture | **Sin hero image** | 🔴 Sin multimedia |
| **Projects Loop** | Loop de posts `project` | Thumbnails de esculturas fundidas | RunMedia `$project_slug` | 🟡 Depende de posts |

**Ratio texto/imagen:** 50% (1/2 secciones con potencial de imágenes)

---

### 📝 Blog (`page-blog.php`)

| Sección | Texto | Imagen Esperada | Imagen Real | Estado |
|---------|-------|-----------------|-------------|--------|
| **Hero** | "Technical Insights" | Blog header/biblioteca | `blog-hero` (slug, no archivo) | 🔴 Falta imagen |
| **Blog Loop** | Loop de posts `post` | Featured images de artículos | `the_post_thumbnail('medium')` | 🟡 Depende de posts |

**Ratio texto/imagen:** 50% (1/2 secciones con potencial de imágenes)

---

### 📬 Contact (`page-contact.php`)

| Sección | Texto | Imagen Esperada | Imagen Real | Estado |
|---------|-------|-----------------|-------------|--------|
| **Hero** | "Contact Us" | Workshop exterior/equipo | `contact-hero` (slug, no archivo) | 🔴 Falta imagen |
| **Formulario** | Campos de contacto | **Sin imágenes** (solo formulario) | N/A | ✅ N/A |

**Ratio texto/imagen:** 0% (formulario no requiere imágenes)

---

## Matriz de Dependencias

### Contenido Estático (Hardcodeado)

| Página | Textos Hardcodeados | Imágenes Asociadas | Estado Sincronización |
|--------|---------------------|--------------------|-----------------------|
| Home | Hero, Services (5), Stats (4), CTAs | 1 hero + 5 íconos servicios | 🔴 **Textos sin imágenes** |
| About | Hero, Story (3), Process (9), Values (4), Stats (4) | 1 hero + fotos ilustrativas | 🔴 **Textos sin imágenes** |
| Services | Hero | 1 hero | 🔴 **Texto sin imagen** |
| Projects | Hero | 1 hero | 🔴 **Texto sin imagen** |
| Blog | Hero | 1 hero | 🔴 **Texto sin imagen** |
| Contact | Hero | 1 hero | 🔴 **Texto sin imagen** |

**Total de heros faltantes:** 6  
**Total de secciones ilustrativas faltantes:** ~15 (Services, Values, Process, Stats)

---

### Contenido Dinámico (WordPress)

| Post Type | Texto (WP) | Imagen (RunMedia/WP) | Estado Posts |
|-----------|------------|----------------------|--------------|
| **Project** | `the_title()`, `the_content()` | `runart_get_runmedia_image($project_slug, 'w800')` | 🔴 **0 posts** |
| **Service** | `the_title()`, `the_content()` | `runart_get_runmedia_image($service_slug, 'w800')` | 🔴 **0 posts** |
| **Testimonial** | `the_title()`, `the_content()` | **Sin imágenes** (solo texto) | 🔴 **0 posts** |
| **Post (Blog)** | `the_title()`, `the_content()` | `the_post_thumbnail('medium')` | 🔴 **0 posts** |

**Conclusión:** Contenido dinámico **no puede ser evaluado** hasta crear posts.

---

## Slugs de RunMedia vs Archivos Reales

### Slugs Usados en Plantillas

| Slug en PHP | Página | Archivo Esperado | Presente en `media-index.json` |
|-------------|--------|------------------|--------------------------------|
| `run-art-foundry-branding` | Home Hero | `runartfoundry-home.jpg` (?) | ✅ ID `97d07bd5a561` |
| `workshop-hero` | About Hero | `workshop-*.jpg` | 🔴 **No encontrado** |
| `blog-hero` | Blog Hero | `blog-*.jpg` | 🔴 **No encontrado** |
| `contact-hero` | Contact Hero | `contact-*.jpg` | 🔴 **No encontrado** |

**Problema:** Slugs en PHP no coinciden con estructura de `media-index.json` (usa IDs SHA-256).

---

## Análisis de Cobertura de Alt Text

De las **6,162 imágenes** en el índice:
- **~10%** tienen alt text bilingüe completo (ES/EN)
- **~5%** tienen alt text solo en un idioma
- **~85%** **carecen de alt text**

### Imágenes Críticas Sin Alt Text

| Filename | Uso en Plantilla | Alt Text Actual | SEO Impact |
|----------|------------------|-----------------|------------|
| `runartfoundry-home.jpg` | Hero Home | ✅ "RUN Art Foundry — Taller..." | 🟢 OK |
| `background-image-fallback.jpg` | Fallback GeneratePress | ❌ Vacío | 🟡 Bajo (plugin) |
| Placeholders (plugins) | UI de admin | ❌ Vacío | 🟢 OK (no públicas) |

**Recomendación:** Priorizar alt text para imágenes de contenido editorial (proyectos, servicios).

---

## Relación Texto/Imagen por Tipo de Contenido

### 1. Textos con Imagen Asignada
- **Hero de Home:** `run-art-foundry-branding` → Texto "Excellence in Art Casting"
- **Proyectos (cuando existan):** Thumbnails → Títulos de proyectos

**Cobertura:** ~10%

---

### 2. Textos SIN Imagen (solo texto o emojis)
- **Services Preview:** 5 servicios con emojis (🔥🎨🏺🔧📐) pero sin fotos reales
- **Stats:** "40+ Years", "500+ Projects" sin gráficos ilustrativos
- **Values:** "Precision", "Integrity", "Collaboration", "Sustainability" sin íconos
- **Process:** 9 pasos sin diagrama de flujo visual

**Cobertura:** ~70%

---

### 3. Textos Dinámicos (dependen de posts)
- **Projects, Services, Testimonials, Blog:** Requieren creación de posts con featured images

**Cobertura:** N/A (0% hasta crear posts)

---

## Problema: Desbalance Cantidad vs Uso

- **Total de imágenes catalogadas:** 6,162
- **Imágenes de contenido real:** ~300 (5%)
- **Imágenes de plugins/temas:** ~5,800 (95%)

**Implicación:** El 95% del catálogo es "ruido" (assets de desarrollo que no aparecen en frontend).

---

## Recomendaciones

### Urgente
1. **Crear 6 imágenes hero:**
   - `run-art-foundry-branding` (ya existe)
   - `workshop-hero` (About)
   - `services-hero` (Services)
   - `projects-hero` (Projects)
   - `blog-hero` (Blog)
   - `contact-hero` (Contact)

2. **Normalizar slugs de RunMedia:**
   - Actualizar `association_rules.yaml` con mapeo slug → ID SHA-256
   - Ejemplo: `workshop-hero` → `[nuevo_ID]`

### Corto Plazo
3. **Crear 15 imágenes ilustrativas:**
   - 5 fotos de servicios (Bronze Casting, Patinas, etc.)
   - 4 íconos de valores (Precision, Integrity, etc.)
   - 6 fotos de proceso (Model, Mold, Casting, etc.)

4. **Agregar alt text a imágenes de contenido:**
   - Prioridad: Imágenes hero y de proyectos
   - Bilingüe (ES/EN) para SEO internacional

### Medio Plazo
5. **Crear custom posts con imágenes:**
   - 6 proyectos con galerías (3-5 fotos por proyecto)
   - 5 servicios con foto featured
   - 3 testimonios con foto del cliente (opcional)
   - 5 posts de blog con featured image

6. **Limpiar catálogo:**
   - Eliminar imágenes de plugins/temas no utilizadas
   - Retener solo ~1,200 imágenes de contenido real

---

## Métricas de Éxito

| Métrica | Actual | Objetivo |
|---------|--------|----------|
| **Páginas con hero image** | 0/6 (0%) | 6/6 (100%) |
| **Servicios con foto** | 0/5 (0%) | 5/5 (100%) |
| **Proyectos con galería** | 0 posts | 6 posts |
| **Alt text bilingüe** | 10% | 100% (imágenes públicas) |
| **Ratio texto/imagen** | 30% | 80% |

---

Ver `05_bilingual_gap_report.md` para análisis de cobertura de traducción.
