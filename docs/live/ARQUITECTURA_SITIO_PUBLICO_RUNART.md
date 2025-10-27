---
title: "Arquitectura del Sitio Público — RUN Art Foundry"
meta:
  fuente: "Documento Estratégico Consolidado (25/Oct/2025)"
  objetivo: "Guía única para rediseño/implementación en WordPress o generador estático"
  idioma: "es"
  version: "1.0"
  owner: "RUN Art Foundry / PM: contenido + web"
---

# Arquitectura del Sitio Público — RUN Art Foundry

Este documento consolida la arquitectura de información, los modelos de contenido (plantillas), recomendaciones SEO/visual y notas de implementación WordPress para ejecutar el sitio público de RUN Art Foundry.

- Objetivos del sitio:
  - Atraer nuevos clientes (artistas y entidades). 
  - Posicionar la fundición como referente técnico internacional (bronce/pátinas).
  - Servir como archivo audiovisual y vitrina de proyectos.
- Público objetivo: Artistas, galerías, escuelas/iglesias/municipios, coleccionistas, arquitectos, curadores.
- Paleta visual: Negro base, rojo acento (botones/hover/íconos), tipografía sans-serif sobria.

---

## 1) Arquitectura de Información

Estructura propuesta (ES/EN paralela). Prefijo EN: `/en/`.

- Home (`/` · `/en/`)
  - Objetivo: Propuesta de valor técnico-artística + CTA primario "Inicia tu proyecto".
  - Contenido: Hero con video corto, 3 diferenciales, carrusel de proyectos, proceso en 5 pasos, testimonios destacados, CTA.
  - CTAs: Inicia tu proyecto · Ver Portafolio · Ver Servicios · Descargar Press Kit.
- Sobre Nosotros (`/about/` · `/en/about/`)
  - Objetivo: Confianza y credenciales técnicas (equipo, instalaciones, proceso).
  - Subpáginas: Historia, Equipo, Instalaciones, Proceso (molde → cera → colada → pátina → montaje).
- Servicios (`/services/` · `/en/services/`)
  - Objetivo: Captura de demanda por tipo de encargo/cliente.
  - Subpáginas (una por servicio) con ficha + FAQ + CTA.
- Portafolio (`/projects/` · `/en/projects/`)
  - Objetivo: Evidencia técnica por obra con ficha técnica + video + testimonio.
  - Listados por taxonomías: Artista, Técnica, Aleación, Pátina, Año, Tipo de cliente.
- Blog (`/blog/` · `/en/blog/`)
  - Objetivo: SEO informacional (making-of, entrevistas, consejos técnicos).
  - Categorías sugeridas: Proceso, Materiales, Conservación, Casos de Estudio, Noticias.
- Video (`/video/` · `/en/video/`)
  - Objetivo: Biblioteca de clips técnicos (etapas del proceso, making-of, testimonios).
  - Curación en playlists: Proceso, Testimonios, Proyectos.
- Contacto (`/contact/` · `/en/contact/`)
  - Objetivo: Conversión (formulario + datos completos + QR Press Kit).
  - Extras: Mapa, horarios, WhatsApp/call-to-action directo.
- Press Kit (`/press-kit/` · `/en/press-kit/`)
  - Objetivo: Descarga rápida de capacidades, hojas técnicas y casos (PDF ~4–8 págs).

### Navegación esperada (Header/Footer)
- Header (desktop): Home · About · Services · Projects · Video · Blog · Contact · [EN/ES switch]
- Footer: Contacto (dirección/teléfonos) · RRSS (Instagram/YouTube) · Enlaces rápidos · Aviso legal · Press Kit

### Objetivos por sección (resumen accionable)
- Home: captar lead y guiar a Portafolio/Servicios.
- About: reforzar confianza (equipo/proceso).
- Services: explicar alcance, estandarizar expectativas, activar contacto.
- Projects: demostrar dominio técnico, responder preguntas frecuentes por obra.
- Blog: atraer tráfico long-tail, apoyar decisiones técnicas.
- Video: construir autoridad visual.
- Contact: conversión directa.
- Press Kit: habilitar referencias y cierres rápidos.

---

## 2) Estrategia i18n (ES/EN)
- URLs paralelas: ES raíz `/`, EN bajo `/en/`.
- Hreflang y x-default en todas las páginas.
- Menús duplicados por idioma (ES/EN). 
- Campos bilingües en modelos de contenido (ver plantillas): título, resumen, cuerpo, FAQs, etiquetas SEO.
- Redirecciones canónicas si hay contenido sólo en un idioma.

---

## 3) Modelos y Plantillas de Contenido

Las siguientes plantillas incluyen: campos, notas de implementación WP, y SEO/Schema.

### 3.1 Ficha Técnica de Proyecto (Project)
- Tipo: Custom Post Type `project` (público, archivado, soporta i18n).
- Taxonomías: `artist`, `technique`, `alloy`, `patina`, `year`, `client_type`.
- Campos (ES/EN):
  - Título de la obra
  - Artista (relación o texto libre)
  - Técnica (ej. molde perdido, cera, etc.)
  - Aleación (bronce: composición si aplica)
  - Medidas (alto × ancho × profundo) y peso
  - Edición (única/serie, número de copias)
  - Pátina (tipo, receta si divulgable)
  - Créditos (equipo, curaduría, institución)
  - Año y lugar
  - Descripción técnica (100–250 palabras)
  - Galería (8–15 imágenes, ordenadas)
  - Video principal (URL YouTube/Vimeo) + posters 16:9/9:16
  - Testimonio relacionado (relación a `testimonial`)
  - Descargables (ficha PDF opcional)
  - SEO: slug, meta title (60c), meta description (155c), imagen social
- Notas WP:
  - ACF/Metabox para campos; plantilla single-project con bloques: Hero → Detalles → Galería → Video → Testimonio → CTA.
  - Shortcode/bloque de “Ficha Técnica” para mostrar tabla de specs.
  - Listado y filtros por taxonomías (artist/technique/alloy/patina/year/client_type).
- SEO/Schema:
  - JSON-LD: `CreativeWork` + `VideoObject` si hay video + `Review` si hay testimonio con rating (opcional, o `Testimonial`).
  - FAQs técnicas por proyecto (HowTo/FAQ si describe proceso específico).

Plantilla (Markdown, portable a WP Gutenberg):

```markdown
---
title: "{Obra} — {Artista}"
slug: projects/{slug-obra}
lang: es
seo:
  title: "{Obra} — Fundición en bronce por RUN Art Foundry"
  description: "{Resumen 140–155c con técnica/aleación/pátina y credenciales}."
  image: "/media/projects/{slug-obra}/cover.jpg"
project:
  artist: "{Nombre}"
  technique: ["cera perdida"]
  alloy: "Bronce Cu-Sn (90-10)"
  measures: "{alto}×{ancho}×{prof} cm — {peso} kg"
  edition: "{única/serie} {n}/{N}"
  patina: "{tipo}"
  credits: ["Equipo de pátina: ...", "Institución: ..."]
  year: 2025
  location: "{Ciudad, País}"
  video: "https://www.youtube.com/watch?v=..."
---

# {Obra}

{Descripción técnica 120–200 palabras}

## Ficha técnica

- Artista: {Nombre}
- Técnica: {técnica}
- Aleación: {aleación}
- Medidas: {medidas}
- Edición: {edición}
- Pátina: {pátina}
- Créditos: {créditos}
- Año/Lugar: {año} — {lugar}

## Galería

![Leyenda 1](/media/projects/{slug-obra}/01.jpg)
![Leyenda 2](/media/projects/{slug-obra}/02.jpg)

## Video

[Ver video]({url-video})

## Testimonio

> “{cita breve 1–2 frases}” — {Autor}

---

CTA: [Inicia tu proyecto](/contact/)
```

### 3.2 Testimonio (Texto/Video)
- Tipo: Custom Post Type `testimonial`.
- Campos:
  - Autor (nombre, rol: artista/coleccionista/curador)
  - Obra/proyecto relacionado (relación a `project`)
  - Cita (30–45 s en video, o 1–3 frases en texto)
  - Video (URL YouTube/Vimeo) + poster
  - Transcripción (para accesibilidad y SEO)
  - Permisos/cesión (checkbox)
  - SEO: meta title/description
- Notas WP:
  - Bloque “Testimonial” embebible en Project/Blog.
  - Si es video, auto-embed y schema `VideoObject` + `Person`.
- SEO/Schema:
  - JSON-LD: `Review` (si rating) o `Testimonial` (estructura de Organization/Person + comentario).

Plantilla (Markdown):

```markdown
---
title: "Testimonio — {Autor}"
slug: testimonials/{slug-autor}
lang: es
testimonial:
  author: "{Nombre}"
  role: "Artista"
  project: "{slug-obra}"
  video: "https://www.youtube.com/watch?v=..."
  transcript: |
    {Texto}
---

> “{Cita breve}” — {Autor}

[Ver video]({url-video})
```

### 3.3 Entrada de Blog (SEO)
- Tipo: Post estándar (`post`).
- Campos clave:
  - Título claro con keyword principal.
  - Extracto (1–2 frases).
  - Cuerpo con H2/H3, imágenes optimizadas y alt.
  - FAQs (3–5 preguntas) si aplica.
  - Video embebido si aporta.
  - SEO: slug, meta title/description, imagen social.
- Notas WP:
  - Bloques Gutenberg estándar; tabla de contenidos opcional.
  - Categorías y etiquetas consistentes.
- SEO/Schema:
  - JSON-LD: `BlogPosting` + `FAQPage` cuando existan FAQs.

Plantilla (Markdown):

```markdown
---
title: "{Keyword}: {ángulo útil para el lector}"
slug: blog/{slug}
lang: es
seo:
  title: "{Keyword} — RUN Art Foundry"
  description: "{Resumen 140–155c con beneficio/experiencia}."
---

# {H1 principal}

{Intro 2–3 frases}

## {H2 1}
Contenido...

## {H2 2}
Contenido...

### Preguntas frecuentes

- ¿Pregunta 1?
  - Respuesta breve.
- ¿Pregunta 2?
  - Respuesta breve.
```

### 3.4 Servicio (Descripción técnica y bilingüe)
- Tipo: Custom Post Type `service`.
- Campos (ES/EN):
  - Título del servicio
  - Descripción técnica (200–400 palabras)
  - Casos típicos / alcances
  - FAQs (3–5)
  - CTA (contacto o brief)
  - Imagen/Video demostrativo
  - SEO: slug, meta title/description
- Notas WP:
  - Plantilla single-service con bloques: Hero → Alcances → Casos → FAQs → CTA.
  - Shortcode para “Servicios relacionados” (por técnica/cliente).
- SEO/Schema:
  - JSON-LD: `Service` + `FAQPage`.

Plantilla (Markdown):

```markdown
---
title: "{Servicio}"
slug: services/{slug-servicio}
lang: es
seo:
  title: "{Servicio} en bronce — RUN Art Foundry"
  description: "{Beneficio + tipología de encargo + autoridad}."
---

# {Servicio}

{Descripción técnica (200–400 palabras)}

## Alcances
- Punto 1
- Punto 2

## Casos típicos
- Caso 1
- Caso 2

### Preguntas frecuentes
- ¿Tiempo de entrega?
- ¿Qué aleaciones manejan?

---

CTA: [Inicia tu proyecto](/contact/)
```

---

## 4) SEO por Sección (táctico)
- Global:
  - Títulos 50–60c, descripciones 140–155c, una H1 por página.
  - Hreflang ES/EN, canonical correcto, sitemap actualizado.
  - Schema por tipo (Home: `Organization`; Projects: `CreativeWork`/`VideoObject`; Blog: `BlogPosting`; Services: `Service`; FAQs: `FAQPage`; HowTo cuando proceda).
  - Imágenes: 1600×900 (hero), 1200×630 (social). Peso < 200 KB (optimización lossy + WebP/AVIF).
- Home:
  - Title: "RUN Art Foundry — Fundición en bronce y pátinas" (ES) / "Bronze Foundry & Patinas" (EN).
  - Destacar 3 diferenciales en H2 con keywords.
- About:
  - Title con entidad: "Fundición de bronce en Miami — Equipo e instalaciones".
  - Marcado `Organization` con `logo`, `sameAs` (Instagram/YouTube).
- Services:
  - `Service` + `FAQPage`, URLs amigables por servicio, contenido ES/EN paralelo.
- Projects:
  - `CreativeWork` + `VideoObject` y relación a `Person` (artista). Campos de ficha bien rellenados.
- Blog:
  - Intento de búsqueda informacional, enlazado interno a Services/Projects.
- Contact/Press Kit:
  - `Organization` + NAP consistente. QR Press Kit enlazable y trackeable (UTM).

---

## 5) Estilo Visual y Componentes
- Paleta: Negro dominante (#000/#111), rojo acento (#C30000 aprox.).
- Tipografía: Sans-serif moderna (p.ej., Inter/Roboto), 16–18 px base; contraste AA/AAA.
- Componentes clave:
  - Botones CTA rojos (hover más oscuro), uso consistente.
  - Cards de proyectos con imagen, técnica, artista.
  - Bloques de proceso (5 etapas) con iconografía simple.
  - Bloques de testimonio (cita + avatar + video opcional).
- Accesibilidad: Focus visible, alt-text, captions en video, contraste.

---

## 6) Implementación en WordPress (resumen técnico)
- CPTs: `project`, `testimonial`, `service`.
- Taxonomías: `artist`, `technique`, `alloy`, `patina`, `year`, `client_type`.
- Campos (ACF): definir field groups por CPT (ES/EN) o usar plugin multilingüe con campos duplicados.
- Plantillas:
  - single-project.php, archive-project.php con filtros.
  - single-service.php, archive-service.php.
  - Página Video con grid (fuente YouTube playlists) y `VideoObject`.
  - Press Kit: página estática con PDFs bilingües.
- Bloques/shortcodes:
  - [project-specs], [project-gallery], [project-video], [testimonial-embed], [services-related].
- i18n:
  - Estructura `/` (ES) y `/en/` (EN), menús duplicados, hreflang.
- Medios:
  - Convenciones de carpeta por proyecto `/uploads/projects/{slug-obra}/`. 
  - Posters de video 16:9; variantes WebP y AVIF.

---

## 7) Roadmap 0–30 días (accional)
1. Crear CPTs y taxonomías (ACF + plantillas single/archive).
2. Subir 5–10 fichas de proyecto con video/testimonio.
3. Habilitar 3–5 servicios con FAQs y CTA.
4. Publicar 3 entradas de blog (SEO) y 3 testimonios.
5. Montar página Video con 2–3 playlists.
6. Publicar Press Kit (PDF ES/EN) y enlazar desde Home/Footer.
7. Configurar hreflang/canonicals/sitemap y Search Console.
8. Medir: PageSpeed (LCP<2.5s), indexación, leads.

---

## 8) Anexos

### 8.1 Esquema JSON-LD — Project + Video + Testimonial (ejemplo)
```json
{
  "@context": "https://schema.org",
  "@type": "CreativeWork",
  "name": "{Obra}",
  "creator": {"@type": "Person", "name": "{Artista}"},
  "material": "Bronce",
  "size": "{alto}×{ancho}×{prof} cm",
  "associatedMedia": {
    "@type": "VideoObject",
    "name": "{Obra} — Making of",
    "thumbnailUrl": "https://www.runartfoundry.com/media/projects/{slug}/poster.jpg",
    "uploadDate": "2025-01-01",
    "contentUrl": "https://www.youtube.com/watch?v=..."
  },
  "review": {
    "@type": "Review",
    "author": {"@type": "Person", "name": "{Autor}"},
    "reviewBody": "{Cita breve}"
  }
}
```

### 8.2 Patrones de títulos/meta
- Projects: "{Obra} — {Artista} — Fundición en bronce (pátina {tipo})"
- Services: "{Servicio} en bronce — RUN Art Foundry"
- Blog: "{Keyword}: {beneficio/guía} — RUN Art Foundry"

### 8.3 Estructura EN/ES
- Rutas paralelas, espejo de navegación, campos duplicados por idioma.

---

Esto es un documento operativo único para ejecutar el sitio público de RUN Art Foundry en WordPress o en un generador estático con mínima adaptación.
