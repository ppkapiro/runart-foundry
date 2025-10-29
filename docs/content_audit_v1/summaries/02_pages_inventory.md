# 02 · Inventario de Páginas y Plantillas

**Fecha:** 2025-10-29  
**Rama:** `feat/content-audit-v1`  
**Propósito:** Listar páginas del sitio, plantillas PHP, y estado del contenido

---

## Resumen Ejecutivo

El sitio RunArt Foundry tiene **6 páginas principales** y **3 custom post types** (project, service, testimonial) implementados mediante **14 plantillas PHP**. El contenido está **mayormente hardcodeado** en arrays bilingües (ES/EN) dentro de las plantillas, con integración limitada con WordPress (usa `the_title()`, `the_content()` para posts dinámicos).

---

## Páginas Principales

| Página | Plantilla PHP | URL Staging | Idiomas | Estado |
|--------|---------------|-------------|---------|--------|
| **Home** | `front-page.php` | `/` | ES/EN | ✅ Completo |
| **About** | `page-about.php` | `/about` | ES/EN | ✅ Completo |
| **Services** | `archive-service.php` | `/services` | ES/EN | ✅ Completo |
| **Projects** | `archive-project.php` | `/projects` | ES/EN | ✅ Completo |
| **Blog** | `page-blog.php` | `/blog` | ES/EN | 🟡 Estructura lista, sin posts |
| **Contact** | `page-contact.php` | `/contact` | ES/EN | 🔴 Formulario pendiente |

---

## Plantillas PHP Detectadas

### Páginas Estáticas (6)

#### 1. `front-page.php` (Home)
**Secciones:**
- Hero con imagen RunMedia (`run-art-foundry-branding`)
- Featured Projects (últimos 6 posts de `project`)
- Services Preview (5 tarjetas hardcodeadas con iconos emoji)
- Testimonials Carousel (3 posts aleatorios de `testimonial`)
- Blog Preview (últimos 3 posts de `post`)
- Stats Section (40+ años, 500+ proyectos, 100% satisfacción, 15 artesanos)
- Contact CTA

**Contenido hardcodeado:**
- Textos hero: "Excellence in Art Casting" / "Excelencia en Fundición Artística"
- Descripciones de servicios (Bronze Casting, Patinas & Finishing, Ceramic Shell Mold, Restoration, Engineering Support)
- Estadísticas numéricas

**Contenido dinámico:**
- Proyectos (WP_Query de custom post type `project`)
- Testimonios (WP_Query de `testimonial`)
- Posts de blog (WP_Query de `post`)

---

#### 2. `page-about.php` (About)
**Secciones:**
- Hero con imagen RunMedia (`workshop-hero`)
- Our Story (3 tarjetas: Origins, Workshop, Philosophy)
- Our Process (9 pasos: Model → Mold → Wax Pattern → Ceramic Shell → Burnout → Casting → Chasing → Patina → Final Finish)
- Our Values (4 valores: Precision, Integrity, Collaboration, Sustainability)
- Stats (idénticas a Home)

**Contenido:** 100% hardcodeado en arrays bilingües ES/EN.

---

#### 3. `page-blog.php` (Blog)
**Secciones:**
- Hero con imagen RunMedia (`blog-hero`)
- Posts loop con paginación

**Estado:** Estructura completa, pero **sin posts publicados**.

---

#### 4. `page-contact.php` (Contact)
**Secciones:**
- Hero con imagen RunMedia (`contact-hero`)
- Formulario de contacto (pendiente integración plugin)

**Estado:** Plantilla lista, **formulario no implementado**.

---

#### 5. `page-home.php`
**Estado:** Duplicado de `front-page.php` (puede eliminarse).

---

#### 6. `page.php` (Template genérico)
**Uso:** Fallback para páginas sin template específico.
**Contenido:** `the_title()` + `the_content()` (100% dinámico).

---

### Archivos de Custom Post Types (3)

#### 7. `archive-project.php`
**Propósito:** Lista de todos los proyectos de fundición.
**Loop:** WP_Query de `post_type='project'` con paginación.
**Contenido por proyecto:** Título, thumbnail (RunMedia), excerpt.

---

#### 8. `archive-service.php`
**Propósito:** Lista de todos los servicios ofrecidos.
**Loop:** WP_Query de `post_type='service'` con grid layout.
**Contenido por servicio:** Título, icono, descripción breve.

---

#### 9. `archive-testimonial.php`
**Propósito:** Lista de testimonios de clientes.
**Loop:** WP_Query de `post_type='testimonial'` con cards.
**Contenido por testimonio:** Título (nombre cliente), contenido (testimonio), metadata (puesto/empresa).

---

### Singles de Custom Post Types (3)

#### 10. `single-project.php`
**Propósito:** Página individual de proyecto.
**Contenido:** Galería de imágenes RunMedia, descripción completa, metadatos (fecha, cliente, materiales).

---

#### 11. `single-service.php`
**Propósito:** Página individual de servicio.
**Contenido:** Hero con imagen, descripción detallada, proceso, beneficios, CTA.

---

#### 12. `single-testimonial.php`
**Propósito:** Página individual de testimonio.
**Contenido:** Cita completa, información del cliente, metadata.

---

### Core Templates (3)

#### 13. `header.php`
**Contenido:** Logo, menú de navegación bilingüe (Polylang), selector de idioma.
**Estado:** ✅ Completo, responsive con CSS v0.3.1.3.

---

#### 14. `footer.php`
**Contenido:** Links legales, copyright, redes sociales.
**Estado:** ✅ Completo.

---

#### 15. `index.php`
**Uso:** Fallback de WordPress para todas las rutas.
**Estado:** Básico, nunca se usa (templates específicos siempre presentes).

---

## Custom Post Types Identificados

| CPT | Slug | Taxonomías | Estado |
|-----|------|------------|--------|
| **Project** | `project` | `project_category`, `project_tag` | 🟡 Estructura lista, **sin posts** |
| **Service** | `service` | `service_category` | 🟡 Estructura lista, **sin posts** |
| **Testimonial** | `testimonial` | Ninguna | 🟡 Estructura lista, **sin posts** |

---

## Integración con Polylang

Todas las plantillas detectan idioma con:
```php
$current_lang = function_exists('pll_current_language') ? pll_current_language() : 'en';
```

**Arrays de contenido bilingüe:**
- `$texts['en']` / `$texts['es']`
- Hero titles, CTAs, descripciones de secciones, labels de botones

**Problema:** Textos no externalizados a archivos `.po`, dificulta traducción masiva.

---

## Hallazgos Críticos

1. **Contenido hardcodeado:** ~80% del contenido visible está en arrays PHP, no en base de datos WordPress.
2. **Custom post types vacíos:** Projects, Services, Testimonials tienen estructura pero **0 posts publicados**.
3. **Formulario de contacto pendiente:** `page-contact.php` no tiene plugin de formularios (recomendado: Contact Form 7 o WPForms).
4. **Blog sin contenido:** `page-blog.php` funcional pero sin posts.
5. **Duplicados:** `page-home.php` y `front-page.php` son idénticos.

---

## Contenido Dinámico vs Hardcodeado

| Sección | Dinámico (WordPress) | Hardcodeado (PHP) | Ratio |
|---------|----------------------|-------------------|-------|
| **Hero texts** | 0% | 100% | 0/100 |
| **Services** | 0% | 100% (5 servicios) | 0/100 |
| **Process steps** | 0% | 100% (9 pasos) | 0/100 |
| **Values** | 0% | 100% (4 valores) | 0/100 |
| **Stats** | 0% | 100% (4 cifras) | 0/100 |
| **Projects** | 100% | 0% | 100/0 ✅ |
| **Testimonials** | 100% | 0% | 100/0 ✅ |
| **Blog posts** | 100% | 0% | 100/0 ✅ |

**Promedio general:** ~30% dinámico, ~70% hardcodeado.

---

## Recomendaciones

1. **Crear posts de Custom Post Types:**
   - Mínimo 6 proyectos (con galerías de imágenes RunMedia)
   - 5 servicios (con descripciones completas)
   - 3 testimonios (con metadatos de clientes)

2. **Externalizar textos hardcodeados:**
   - Migrar arrays a archivos `.po` de Polylang
   - Usar `pll_e()` y `pll__()` en lugar de arrays PHP

3. **Integrar formulario de contacto:**
   - Instalar Contact Form 7 o WPForms
   - Configurar SMTP para envío de emails

4. **Eliminar duplicados:**
   - Borrar `page-home.php` (usar solo `front-page.php`)

5. **Poblar blog:**
   - Crear 3-5 posts técnicos (ej: "Proceso de fundición a la cera perdida", "Tipos de pátinas para bronce")

---

Ver `03_images_inventory.md` para análisis de imágenes y multimedia.
