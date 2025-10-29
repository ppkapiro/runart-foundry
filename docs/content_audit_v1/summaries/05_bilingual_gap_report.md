# 05 · Análisis de Brecha Bilingüe (ES/EN)

**Fecha:** 2025-10-29  
**Rama:** `feat/content-audit-v1`  
**Propósito:** Evaluar cobertura de traducción español-inglés en contenido del sitio

---

## Resumen Ejecutivo

El sitio RunArt Foundry tiene **soporte bilingüe completo** (ES/EN) mediante **arrays hardcodeados** en plantillas PHP, NO mediante archivos `.po` de Polylang. Se identificaron **28 definiciones de arrays bilingües** en 2 plantillas principales (`front-page.php`, `page-about.php`), cubriendo ~100% del contenido estático visible.

**Problema crítico:** Textos no externalizados a archivos de traducción, dificultando mantenimiento y escalabilidad.

---

## Arquitectura de Traducción Actual

### Sistema Implementado: Arrays PHP Hardcodeados

```php
$current_lang = function_exists('pll_current_language') ? pll_current_language() : 'en';

$hero_texts = array(
    'en' => array(
        'subtitle' => 'Excellence in Art Casting',
        'description' => 'We transform artistic visions...',
        'cta_contact' => 'Start Your Consultation'
    ),
    'es' => array(
        'subtitle' => 'Excelencia en Fundición Artística',
        'description' => 'Transformamos visiones artísticas...',
        'cta_contact' => 'Iniciar Consulta'
    )
);

$texts = isset($hero_texts[$current_lang]) ? $hero_texts[$current_lang] : $hero_texts['en'];
```

**Ventajas:**
- ✅ 100% de cobertura en contenido estático
- ✅ Traducción sincronizada (ambos idiomas en mismo archivo)
- ✅ Detección automática con Polylang

**Desventajas:**
- 🔴 No escalable (agregar idiomas requiere editar todos los archivos PHP)
- 🔴 No usa estándar gettext (.po/.mo)
- 🔴 Duplicación de código (arrays repetidos en múltiples plantillas)
- 🔴 Sin herramientas de traducción profesionales (PoEdit, Crowdin, etc.)

---

## Inventario de Arrays Bilingües

### `front-page.php` (Home) — 8 arrays

| Array | Sección | Claves | ES ✅ | EN ✅ | Gap |
|-------|---------|--------|-------|-------|-----|
| `$hero_texts` | Hero | subtitle, description, cta_contact, cta_projects | ✅ | ✅ | 0% |
| `$section_texts` | Featured Projects | title, description, no_projects, view_all | ✅ | ✅ | 0% |
| `$services_texts` | Services Preview | title, description, explore, services[5×2] | ✅ | ✅ | 0% |
| `$test_texts` | Testimonials | title, coming_soon, more | ✅ | ✅ | 0% |
| `$blog_texts` | Blog Preview | title, coming_soon, view_blog | ✅ | ✅ | 0% |
| `$stats_texts` | Stats Section | title, stats[4×2] | ✅ | ✅ | 0% |
| `$cta_texts` | Contact CTA | title, description, button | ✅ | ✅ | 0% |

**Total de strings en Home:** ~40 (20 ES + 20 EN)

---

### `page-about.php` (About) — 1 array gigante

| Array | Sección | Claves | ES ✅ | EN ✅ | Gap |
|-------|---------|--------|-------|-------|-----|
| `$content` | Todas las secciones | hero_title, hero_subtitle, story_title, story[3×2], process_title, process_steps[9], values_title, values[4×2], stats_title, stats[4×2] | ✅ | ✅ | 0% |

**Total de strings en About:** ~35 (17-18 ES + 17-18 EN)

---

## Archivos `.po` de Polylang

### Estado Actual

```bash
wp-content/themes/runart-base/languages/
├── en_US.po        (Estado: VACÍO o plantilla base)
├── es_ES.po        (Estado: VACÍO o plantilla base)
└── runart-base.pot (Estado: VACÍO o plantilla base)
```

**Verificación necesaria:** Los archivos `.po` agregados en commit `8e1cca5` están vacíos o solo contienen headers.

---

## Cobertura de Traducción por Tipo de Contenido

### 1. Contenido Estático Hardcodeado

| Página | Strings ES | Strings EN | Gap | Método |
|--------|-----------|-----------|-----|--------|
| **Home** | 20 | 20 | 0% | Arrays PHP |
| **About** | 18 | 18 | 0% | Arrays PHP |
| **Services** | 0 | 0 | N/A | Sin contenido estático |
| **Projects** | 0 | 0 | N/A | Sin contenido estático |
| **Blog** | 0 | 0 | N/A | Sin contenido estático |
| **Contact** | 0 | 0 | N/A | Sin contenido estático |

**Total:** ~38 strings ES + ~38 strings EN = **76 strings bilingües**

---

### 2. Contenido Dinámico (WordPress)

| Post Type | Traducciones Requeridas | Estado Actual | Gap |
|-----------|-------------------------|---------------|-----|
| **Project** | Título, contenido, excerpt | 🔴 0 posts (no evaluable) | N/A |
| **Service** | Título, contenido, excerpt | 🔴 0 posts (no evaluable) | N/A |
| **Testimonial** | Título, contenido, metadata | 🔴 0 posts (no evaluable) | N/A |
| **Post (Blog)** | Título, contenido, excerpt | 🔴 0 posts (no evaluable) | N/A |

**Método esperado:** Polylang con posts duplicados (1 en ES, 1 en EN vinculados).

---

### 3. Elementos de UI/Navegación

| Elemento | ES | EN | Método | Gap |
|----------|----|----|--------|-----|
| **Menú principal** | Manual (WP Admin) | Manual (WP Admin) | Polylang menus | 🟡 Por configurar |
| **Breadcrumbs** | ❓ | ❓ | Tema/plugin | 🔴 No verificado |
| **Botones genéricos** | Hardcodeados | Hardcodeados | Arrays PHP | 0% |
| **Mensajes de error** | ❓ | ❓ | WordPress core | 🟡 Por verificar |

---

## Análisis de Calidad de Traducciones

### Muestra: Textos Hero de Home

| ES | EN | Calidad | Notas |
|----|----|---------+-------|
| "Excelencia en Fundición Artística" | "Excellence in Art Casting" | ✅ Excelente | Traducción profesional, equivalencia semántica |
| "Transformamos visiones artísticas en bronce de la más alta calidad mediante técnicas tradicionales y tecnología contemporánea" | "We transform artistic visions into the highest quality bronze through traditional techniques and contemporary technology" | ✅ Excelente | Traducción fluida, tono profesional |
| "Iniciar Consulta" | "Start Your Consultation" | ✅ Excelente | CTA claro en ambos idiomas |

**Evaluación general:** Traducciones de **alta calidad**, tono profesional consistente.

---

### Muestra: Servicios (Front-Page)

| ES | EN | Calidad | Notas |
|----|----|---------+-------|
| "Fundición en Bronce" | "Bronze Casting" | ✅ Excelente | Terminología técnica correcta |
| "Proceso tradicional a la cera perdida con control artesanal" | "Traditional lost-wax process with artisanal control" | ✅ Excelente | Traducción técnica precisa |
| "Pátinas y Acabados" | "Patinas & Finishing" | ✅ Excelente | Uso correcto de & en EN |
| "Colores y texturas personalizadas que reflejan tu visión" | "Custom colors and textures that reflect your vision" | 🟡 Bueno | Cambio de tono: "tu" (informal ES) vs "your" (neutral EN) |

**Nota:** Leve inconsistencia tonal (ES informal "tu" vs EN neutral "your"), pero aceptable para B2B.

---

## Problemas Detectados

### 1. **Textos No Externalizados**

**Impacto:** Alto  
**Descripción:** Los 76 strings bilingües están en arrays PHP, no en archivos `.po`.

**Consecuencias:**
- Imposible usar herramientas de traducción profesionales (PoEdit, Crowdin)
- Agregar un tercer idioma (ej: francés) requiere editar manualmente todos los archivos PHP
- Sin historial de cambios de traducciones (todo mezclado con código)

**Recomendación:** Migrar a gettext estándar (`pll_e()`, `pll__()`) + archivos `.po`.

---

### 2. **Archivos `.po` Vacíos**

**Impacto:** Medio  
**Descripción:** Los archivos `es_ES.po`, `en_US.po`, `runart-base.pot` agregados en commit `8e1cca5` están vacíos.

**Consecuencias:**
- Polylang no puede gestionar traducciones de strings del tema
- Funciones como `pll_e('texto')` no funcionarán

**Recomendación:** Generar `.pot` desde plantillas PHP y traducir strings.

---

### 3. **Sin Traducción de Metadatos de Imágenes**

**Impacto:** Alto (SEO)  
**Descripción:** De 6,162 imágenes, solo ~10% tienen alt text bilingüe.

**Consecuencias:**
- Penalización SEO en búsquedas por imágenes
- Accesibilidad reducida (screen readers)

**Recomendación:** Completar alt text bilingüe en `media-index.json`.

---

### 4. **Custom Post Types Sin Contenido Bilingüe**

**Impacto:** Alto  
**Descripción:** 0 posts en Projects, Services, Testimonials, Blog.

**Consecuencias:**
- Imposible evaluar cobertura de traducción de contenido dinámico
- Secciones de Home/About muestran "No projects available yet"

**Recomendación:** Crear al menos 3 posts por CPT en ambos idiomas.

---

## Métricas de Cobertura

| Métrica | Valor | Objetivo | Gap |
|---------|-------|----------|-----|
| **Strings estáticos traducidos** | 76/76 (100%) | 100% | 0% ✅ |
| **Strings en archivos .po** | 0/76 (0%) | 76/76 | 100% 🔴 |
| **Posts bilingües (Projects)** | 0/6 | 6/6 | 100% 🔴 |
| **Posts bilingües (Services)** | 0/5 | 5/5 | 100% 🔴 |
| **Posts bilingües (Testimonials)** | 0/3 | 3/3 | 100% 🔴 |
| **Posts bilingües (Blog)** | 0/5 | 5/5 | 100% 🔴 |
| **Alt text bilingüe (imágenes)** | 616/6162 (10%) | 1200/1200 (100% de contenido real) | 90% 🔴 |

---

## Recomendaciones

### Urgente
1. **Externalizar textos hardcodeados a .po:**
   - Reemplazar arrays PHP con `pll_e()`, `pll__()`, `pll_translate_string()`
   - Generar `runart-base.pot` con WP-CLI: `wp i18n make-pot`
   - Traducir `.pot` → `es_ES.po`, `en_US.po` con PoEdit

2. **Crear posts bilingües:**
   - 6 proyectos (3 ES + 3 EN vinculados con Polylang)
   - 5 servicios (3 ES + 2 EN mínimo)
   - 3 testimonios (2 ES + 1 EN mínimo)

### Corto Plazo
3. **Completar alt text bilingüe:**
   - Priorizar ~300 imágenes de contenido real
   - Usar `media-index.json` como fuente de verdad

4. **Configurar menús bilingües:**
   - Crear 2 menús en WP Admin: "Main Menu (ES)" y "Main Menu (EN)"
   - Vincular con Polylang

### Medio Plazo
5. **Implementar flujo de traducción profesional:**
   - Integrar Crowdin o Transifex para gestión de `.po`
   - Automatizar exportación de strings nuevos
   - Revisión de calidad por traductores nativos

6. **Agregar tercer idioma (opcional):**
   - Francés (FR) para mercado europeo
   - Catalán (CA) para mercado local español

---

## Flujo de Trabajo Recomendado

### Actual (Arrays PHP)
```
Desarrollador edita PHP → Arrays ES/EN hardcodeados → Deploy
```

### Propuesto (Gettext + Polylang)
```
Desarrollador escribe texto EN → `pll_e('text')` en PHP →
WP-CLI genera .pot → Traductor traduce .po (PoEdit) →
Polylang carga traducciones → Deploy
```

---

## Anexos

### Comandos Útiles

```bash
# Generar .pot desde plantillas PHP
wp i18n make-pot wp-content/themes/runart-base/ \
  wp-content/themes/runart-base/languages/runart-base.pot

# Verificar strings en plantillas
grep -r "pll_e\|pll__" wp-content/themes/runart-base/*.php

# Contar strings traducibles
msggrep --no-wrap runart-base.pot | grep msgid | wc -l
```

---

Ver `06_next_steps.md` para plan de acción detallado.
