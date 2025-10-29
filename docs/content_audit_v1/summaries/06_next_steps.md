# 06 · Próximos Pasos y Normalización

**Fecha:** 2025-10-29  
**Rama:** `feat/content-audit-v1`  
**Propósito:** Plan de acción para normalización de contenido y cierre de brechas

---

## Resumen Ejecutivo

Esta auditoría de contenido reveló **5 problemas críticos** que impiden el lanzamiento exitoso del sitio RunArt Foundry:

1. **Biblioteca de medios vacía:** 6,162 imágenes catalogadas pero 0 archivos en `library/`
2. **Custom post types sin contenido:** 0 posts en Projects, Services, Testimonials, Blog
3. **Textos hardcodeados:** 76 strings en arrays PHP, no en archivos `.po`
4. **Imágenes hero faltantes:** 5/6 páginas sin imagen de cabecera
5. **Alt text insuficiente:** 90% de imágenes sin texto alternativo bilingüe

Este documento prioriza acciones por impacto y urgencia.

---

## Prioridad 1: Urgente (Blockers de Lanzamiento)

### 1.1 Poblar Biblioteca de Medios

**Problema:** `content/media/library/` vacío, variantes optimizadas existen pero no hay originales.

**Impacto:** Alto (bloquea regeneración de imágenes, ediciones futuras).

**Pasos:**
1. Copiar originales desde `mirror/raw/2025-10-01/` a `content/media/library/`:
   ```bash
   cd /home/pepe/work/runartfoundry
   rsync -av --checksum mirror/raw/2025-10-01/site_static/wp-content/uploads/ \
             content/media/library/
   ```

2. Verificar integridad con checksums SHA-256:
   ```bash
   jq -r '.items[] | [.source.path, .checksum.sha256] | @tsv' \
      content/media/media-index.json > checksums.txt
   sha256sum -c checksums.txt
   ```

3. Actualizar rutas en `media-index.json`:
   - Cambiar `"path": "mirror/raw/..."` → `"path": "content/media/library/..."`

**Tiempo estimado:** 2 horas  
**Responsable:** DevOps / Desarrollador

---

### 1.2 Crear 6 Imágenes Hero

**Problema:** Páginas Home, About, Services, Projects, Blog, Contact sin imagen de cabecera.

**Impacto:** Alto (apariencia incompleta, afecta branding).

**Pasos:**
1. **Seleccionar/crear imágenes:**
   - `run-art-foundry-branding.jpg` (ya existe: `97d07bd5a561`)
   - `workshop-hero.jpg` → Foto del taller/equipos
   - `services-hero.jpg` → Proceso de fundición en acción
   - `projects-hero.jpg` → Escultura featured
   - `blog-hero.jpg` → Biblioteca/documentación técnica
   - `contact-hero.jpg` → Fachada del taller o equipo

2. **Procesar con RunMedia:**
   - Generar variantes WebP/AVIF (w2560, w1600, w1200, w800, w400)
   - Agregar a `media-index.json` con metadata bilingüe

3. **Actualizar `association_rules.yaml`:**
   ```yaml
   slugs:
     workshop-hero: [nuevo_id_sha256]
     services-hero: [nuevo_id_sha256]
     projects-hero: [nuevo_id_sha256]
     blog-hero: [nuevo_id_sha256]
     contact-hero: [nuevo_id_sha256]
   ```

**Tiempo estimado:** 4 horas  
**Responsable:** Diseñador + Desarrollador

---

### 1.3 Crear Custom Posts Mínimos

**Problema:** 0 posts en Projects, Services, Testimonials, Blog → Secciones vacías en Home.

**Impacto:** Alto (afecta presentación del sitio, SEO).

**Pasos:**

#### Projects (6 posts, 3 ES + 3 EN)
1. **Crear posts en WP Admin:**
   - Título ES: "Escultura Ecuestre en Bronce"
   - Título EN: "Equestrian Bronze Sculpture"
   - Contenido: Descripción del proyecto, técnicas usadas, dimensiones
   - Metadatos: Cliente, fecha, materiales, peso
   - Galería: 3-5 fotos del proceso (maqueta, molde, fundición, acabado)

2. **Vincular con Polylang:**
   - Crear versión ES, luego versión EN vinculada
   - Repetir para 3 proyectos

#### Services (5 posts, 5 ES + 5 EN)
1. **Posts requeridos:**
   - Bronze Casting / Fundición en Bronce
   - Patinas & Finishing / Pátinas y Acabados
   - Ceramic Shell Mold / Molde de Cerámica
   - Restoration / Restauración
   - Engineering Support / Soporte Técnico

2. **Contenido por post:**
   - Featured image: Foto del servicio en acción
   - Descripción: 300-500 palabras, proceso detallado
   - Beneficios: Lista de ventajas
   - CTA: "Contact us for a quote" / "Contáctanos para presupuesto"

#### Testimonials (3 posts, 3 ES + 3 EN)
1. **Posts requeridos:**
   - Cliente 1: Artista plástico (ES)
   - Cliente 2: Museo (EN)
   - Cliente 3: Diseñador industrial (ES)

2. **Contenido por post:**
   - Título: Nombre del cliente
   - Contenido: Testimonio (100-150 palabras)
   - Metadatos: Puesto/empresa, foto del cliente (opcional)

#### Blog (5 posts, 3 ES + 2 EN)
1. **Posts sugeridos:**
   - "Proceso de fundición a la cera perdida" (ES)
   - "Bronze Patina Techniques" (EN)
   - "Historia de la fundición artística" (ES)
   - "Choosing the Right Bronze Alloy" (EN)
   - "Restauración de esculturas antiguas" (ES)

2. **Contenido por post:**
   - Featured image: Foto ilustrativa
   - Contenido: 600-1000 palabras, técnico pero accesible
   - Categorías: Processes, History, Materials, Techniques

**Tiempo estimado:** 16 horas (2 días de trabajo)  
**Responsable:** Content writer + Desarrollador

---

## Prioridad 2: Importante (Pre-Lanzamiento)

### 2.1 Externalizar Textos a Archivos `.po`

**Problema:** 76 strings hardcodeados en arrays PHP.

**Impacto:** Medio (bloquea escalabilidad de traducciones).

**Pasos:**
1. **Reemplazar arrays con funciones Polylang:**
   ```php
   // Antes
   $texts = array('en' => 'Excellence', 'es' => 'Excelencia');
   echo $texts[$current_lang];
   
   // Después
   pll_e('Excellence in Art Casting');
   ```

2. **Registrar strings en `functions.php`:**
   ```php
   if (function_exists('pll_register_string')) {
       pll_register_string('hero_subtitle', 'Excellence in Art Casting', 'runart-base');
       pll_register_string('hero_description', 'We transform...', 'runart-base');
       // ... repetir para 76 strings
   }
   ```

3. **Traducir en Polylang String Translations:**
   - WP Admin → Idiomas → String translations
   - Buscar "runart-base"
   - Agregar traducciones ES para cada string

**Alternativa (más estándar):**
- Usar `__('text', 'runart-base')` en templates
- Generar `.pot` con WP-CLI: `wp i18n make-pot`
- Traducir `.pot` → `.po` con PoEdit

**Tiempo estimado:** 8 horas  
**Responsable:** Desarrollador + Traductor

---

### 2.2 Completar Alt Text Bilingüe

**Problema:** 90% de imágenes sin alt text bilingüe.

**Impacto:** Medio (afecta SEO y accesibilidad).

**Pasos:**
1. **Priorizar imágenes de contenido real (~300 imágenes):**
   - Proyectos: Esculturas, moldes, procesos
   - Servicios: Equipos, técnicas
   - Workshop: Taller, equipo

2. **Actualizar `media-index.json`:**
   ```json
   "metadata": {
     "alt": {
       "es": "Escultura ecuestre en bronce — Proceso de fundición",
       "en": "Equestrian bronze sculpture — Casting process"
     }
   }
   ```

3. **Generar script de migración:**
   ```python
   import json
   
   with open('media-index.json') as f:
       data = json.load(f)
   
   for item in data['items']:
       if item['related']['projects']:
           # Generar alt text automático desde proyecto
           item['metadata']['alt']['es'] = f"{item['filename']} — Proyecto {item['related']['projects'][0]}"
   ```

**Tiempo estimado:** 6 horas (2 horas script + 4 horas revisión manual)  
**Responsable:** Desarrollador + Content writer

---

### 2.3 Configurar Formulario de Contacto

**Problema:** `page-contact.php` sin formulario funcional.

**Impacto:** Medio (bloquea conversiones).

**Pasos:**
1. **Instalar Contact Form 7:**
   ```bash
   wp plugin install contact-form-7 --activate
   ```

2. **Crear formulario bilingüe:**
   - Campos: Name, Email, Phone, Message
   - Versión ES: Nombre, Correo, Teléfono, Mensaje
   - Versión EN: Name, Email, Phone, Message

3. **Insertar shortcode en `page-contact.php`:**
   ```php
   <?php
   $form_id = ($current_lang == 'es') ? 123 : 456;
   echo do_shortcode('[contact-form-7 id="' . $form_id . '"]');
   ?>
   ```

4. **Configurar SMTP:**
   - Plugin: WP Mail SMTP
   - Configurar con cuenta de correo del cliente

**Tiempo estimado:** 2 horas  
**Responsable:** Desarrollador

---

## Prioridad 3: Deseable (Post-Lanzamiento)

### 3.1 Limpiar Catálogo de Imágenes

**Problema:** 95% de imágenes catalogadas son assets de plugins/temas no utilizados.

**Impacto:** Bajo (afecta performance del índice, no del sitio).

**Pasos:**
1. **Identificar imágenes de plugins:**
   ```bash
   jq -r '.items[] | select(.source.path | contains("plugins")) | .filename' \
      media-index.json > plugins_images.txt
   ```

2. **Eliminar del índice:**
   - Crear `media-index-clean.json` con solo imágenes de contenido real
   - Reducir de 6,162 → ~1,200 imágenes

3. **Eliminar variantes no utilizadas:**
   ```bash
   find content/media/variants/ -type f | while read file; do
     id=$(basename $(dirname $(dirname $file)))
     jq -e ".items[] | select(.id == \"$id\")" media-index-clean.json > /dev/null || rm "$file"
   done
   ```

**Tiempo estimado:** 4 horas  
**Responsable:** Desarrollador

---

### 3.2 Integrar RunMedia App

**Problema:** Gestión de imágenes manual, sin interfaz de administración.

**Impacto:** Bajo (mejora flujo de trabajo futuro).

**Pasos:**
1. **Configurar app Flask:**
   ```bash
   cd apps/runmedia
   pip install -r requirements.txt
   python app.py
   ```

2. **Integrar con WordPress:**
   - Endpoint REST API: `/wp-json/runmedia/v1/images`
   - Webhook para notificar nuevas imágenes subidas a WP Media Library

3. **Automatizar generación de variantes:**
   - Cron job: cada hora buscar nuevas imágenes en `library/`
   - Generar variantes WebP/AVIF
   - Actualizar `media-index.json`

**Tiempo estimado:** 12 horas  
**Responsable:** Desarrollador backend

---

### 3.3 Agregar Tercer Idioma (Francés)

**Problema:** Solo ES/EN, mercado europeo puede requerir FR.

**Impacto:** Bajo (expansión futura).

**Pasos:**
1. **Configurar Polylang para FR:**
   - WP Admin → Idiomas → Agregar nuevo idioma → Francés

2. **Traducir archivos `.po`:**
   - Contratar traductor nativo FR
   - Traducir `runart-base.pot` → `runart-base-fr_FR.po`

3. **Crear posts en FR:**
   - 3 proyectos FR vinculados con ES/EN
   - 5 servicios FR
   - 3 testimonios FR

**Tiempo estimado:** 20 horas (10 horas traducción + 10 horas creación de posts)  
**Responsable:** Traductor + Content writer

---

## Plan de Acción (Roadmap)

### Fase 1: Preparación (Semana 1)
- [ ] Poblar `content/media/library/` (2h)
- [ ] Crear 6 imágenes hero (4h)
- [ ] Configurar formulario de contacto (2h)
- [ ] Crear 3 proyectos ES/EN (6h)

### Fase 2: Contenido (Semana 2)
- [ ] Crear 5 servicios ES/EN (5h)
- [ ] Crear 3 testimonios ES/EN (3h)
- [ ] Crear 5 posts de blog (8h)
- [ ] Completar alt text de 300 imágenes (6h)

### Fase 3: Optimización (Semana 3)
- [ ] Externalizar textos a `.po` (8h)
- [ ] Configurar menús bilingües (2h)
- [ ] Limpiar catálogo de imágenes (4h)
- [ ] Testing QA bilingüe (4h)

### Fase 4: Lanzamiento (Semana 4)
- [ ] Deploy a producción (2h)
- [ ] Configurar SMTP y formulario (1h)
- [ ] Monitoreo de errores (continuo)
- [ ] Optimización SEO (4h)

**Total estimado:** ~70 horas de trabajo (~2 semanas a tiempo completo)

---

## Criterios de Éxito

| Criterio | Objetivo | Estado Actual | Gap |
|----------|----------|---------------|-----|
| **Imágenes hero presentes** | 6/6 | 0/6 | 100% |
| **Custom posts creados** | 19 (6+5+3+5) | 0 | 100% |
| **Textos en .po** | 76/76 | 0/76 | 100% |
| **Alt text bilingüe** | 300/300 (imágenes públicas) | 30/300 | 90% |
| **Formulario funcional** | 1 | 0 | 100% |
| **Menús bilingües** | 2 (ES/EN) | 0 | 100% |
| **Biblioteca de medios** | 300 originales | 0 | 100% |

**Métrica global de completitud:** 10% → Objetivo 100%

---

## Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| **Imágenes originales no disponibles** | Media | Alto | Contactar cliente para obtener backups |
| **Traducción de baja calidad** | Baja | Medio | Contratar traductor nativo, no usar IA |
| **Retraso en creación de contenido** | Alta | Medio | Priorizar posts mínimos, agregar más post-lanzamiento |
| **Problemas de performance (6k imágenes)** | Media | Bajo | Limpiar catálogo, usar CDN para variantes |

---

## Recursos Necesarios

| Rol | Horas | Tareas |
|-----|-------|--------|
| **Desarrollador Full-Stack** | 40h | Poblar biblioteca, externalizar textos, integrar RunMedia, configurar formulario |
| **Content Writer (ES)** | 15h | Crear 10 posts ES, completar alt text |
| **Content Writer (EN)** | 10h | Crear 9 posts EN, revisar traducciones |
| **Diseñador Gráfico** | 4h | Crear 5 imágenes hero faltantes |
| **QA Tester** | 4h | Testing bilingüe, verificar enlaces, formularios |

**Total:** ~73 horas (~2 semanas a 40h/semana con 2 personas)

---

## Conclusión

Esta auditoría identificó **7 brechas críticas** en el contenido de RunArt Foundry. El plan de acción propuesto prioriza las 3 más urgentes (biblioteca de medios, imágenes hero, custom posts) para permitir un lanzamiento básico en 2 semanas.

**Recomendación:** Ejecutar Fase 1 y Fase 2 antes del lanzamiento, diferir Fase 3 y Fase 4 para optimización post-lanzamiento.

---

## Anexos

### Checklist de Pre-Lanzamiento

```markdown
- [ ] ✅ `content/media/library/` poblado con 300+ originales
- [ ] ✅ 6 imágenes hero creadas y procesadas
- [ ] ✅ 6 proyectos ES/EN publicados
- [ ] ✅ 5 servicios ES/EN publicados
- [ ] ✅ 3 testimonios ES/EN publicados
- [ ] ✅ 5 posts de blog publicados
- [ ] ✅ Formulario de contacto funcional
- [ ] ✅ SMTP configurado
- [ ] ✅ Menús bilingües creados
- [ ] ✅ Alt text de 300 imágenes completado
- [ ] ✅ Testing en staging OK
- [ ] ✅ Backup de base de datos realizado
```

### Comandos de Deploy

```bash
# Sincronizar biblioteca de medios
rsync -av content/media/ usuario@staging:/var/www/html/wp-content/uploads/

# Deploy de tema
./tools/deploy_wp_ssh.sh staging

# Verificar CSS
curl -sI https://staging.runartfoundry.com/wp-content/themes/runart-base/assets/css/responsive.overrides.css | grep "Content-Length"

# Smoke tests
for page in "" about services projects blog contact; do
  curl -sI "https://staging.runartfoundry.com/$page" | head -1
done
```

---

**Fin del documento 06_next_steps.md**
