# Plan de Desarrollo de la App RunMedia

Última actualización: 2025-10-27
Responsable: Equipo RUN + Copilot

Este documento es una guía viva para construir RunMedia, una aplicación modular para la gestión inteligente de imágenes vinculadas al sitio RUN Art Foundry. Se actualizará de forma iterativa conforme se avance en diseño, implementación, validación e integración.

---

## A. Objetivo de la Aplicación

RunMedia es una herramienta modular para:

- Inventariar y gestionar imágenes del ecosistema RUN Art Foundry (sitio WP, repositorio, y espejo offline).
- Asociar cada imagen a contenidos (proyectos, servicios, posts, páginas) por slug/ID y por idioma (ES/EN).
- Centralizar metadatos enriquecidos (título, alt, descripción, tipo de toma, tags, derechos, variantes, tamaños) y exportarlos.
- Detectar imágenes huérfanas, duplicadas o obsoletas, y proponer acciones.
- Optimizar para web (WebP/AVIF) y generar tamaños responsivos alineados con WordPress.
- Operar offline sobre una carpeta espejo y sincronizar cuando haya conectividad.

Relación con el sitio:
- Produce un índice canónico `content/media/media-index.json` que sirve de “fuente de verdad” para imágenes del sitio.
- Exporta CSV/JSON para ingestión en WordPress (vía REST, MU plugin, o procesos manuales guiados), sin acoplarse rígidamente.
- No sustituye la librería WP; la complementa con control, calidad y trazabilidad.

Necesidades que resuelve:
- Evita duplicados y pérdidas de contexto (qué imagen se usa dónde y por qué).
- Acelera preparación de alt/metadata bilingüe y su verificación de calidad SEO/Accesibilidad.
- Simplifica exportación e integración multiplataforma (proyectos futuros, presentaciones, catálogos).

---

## B. Base Técnica Inicial

Enfoque propuesto (fase 0-1):
- Núcleo CLI en Python (>= 3.10) para escaneo, indexación, verificación y exportación.
- Diseño modular y portable: el núcleo no depende de WordPress; la integración es un módulo opcional.
- Operación sobre árbol local del repo y carpeta espejo (mirror/ o content/media/library/), con capacidad de leer `wp-content/uploads` desde un espejo.

Posible evolución (fase 2+):
- Panel mínimo (Streamlit o FastAPI + UI ligera) para edición visual de metadatos.
- Extensiones: plugin MU en WP para importar/exportar el JSON, o scripts de sincronización vía REST.

Dependencias sugeridas (a validar en implementación):
- Python: `click` (CLI), `rich` o `textual` (UX CLI), `Pillow` (lectura básica de imágenes), `python-slugify`, `pyyaml`, `requests` (REST WP), `tqdm` (progreso).
- Herramientas opcionales: `exifread`/`piexif` para EXIF/IPTC; `opencv-python` si hiciera falta análisis básico; `pandas` para exportaciones CSV.

Estructuras y rutas:
- Índice canónico: `content/media/media-index.json`.
- Biblioteca de trabajo: `content/media/library/` (estructura lógica propuesta en la sección D).
- Inventario de base de referencia: `_reports/inventario_base_imagenes_runmedia.md`.

Contrato de datos (propuesto, sujeto a ajuste):
```json
{
  "version": 1,
  "generated_at": "2025-10-27T13:00:00Z",
  "items": [
    {
      "id": "img_0001",
      "filename": "runartfoundry-home.jpg",
      "ext": "jpg",
      "checksum": {
        "sha256": "..."
      },
      "source": {
        "origin": "wp-uploads|repo|mirror",
        "path": "wp-content/uploads/2023/04/runartfoundry-home.jpg"
      },
      "logical_path": "library/projects/slug-proyecto-1/runartfoundry-home.jpg",
      "created_at": "2023-04-10T00:00:00Z",
      "width": 1920,
      "height": 1080,
      "ratio": "16:9",
      "language": ["es", "en"],
      "metadata": {
        "title": {"es": "", "en": ""},
        "alt": {"es": "", "en": ""},
        "description": {"es": "", "en": ""},
        "shot_type": "studio|product|process|team|foundry|other",
        "tags": ["branding", "escultura", "bronze"],
        "copyright": {
          "holder": "RUN Art Foundry",
          "license": "All Rights Reserved|CC-BY-4.0|...",
          "credits": ""
        }
      },
      "related": {
        "projects": ["slug-proyecto-1"],
        "services": ["bronze-casting"],
        "posts": [],
        "pages": []
      },
      "primary_usage": ["hero", "gallery", "thumbnail"],
      "variants": {
        "webp": true,
        "avif": false
      },
      "sizes": {
        "full": "1920x1080",
        "large": "1200x675",
        "medium": "800x450",
        "thumb": "400x225"
      },
      "notes": "observaciones opcionales"
    }
  ]
}
```

---

## C. Funcionalidades por Módulo

Para cada módulo se indica: qué hace, cómo interactúa y su estado.

1) Escáner e indexador de imágenes
- Qué hace: Recorre carpetas de trabajo (mirror/ y content/media/library/), detecta imágenes, extrae metadatos mínimos (dimensiones, checksum), y genera/actualiza `media-index.json` sin duplicar entradas.
- Interacción: Alimenta a todos los demás módulos como fuente de verdad. Provee identificadores estables y checksums para deduplicación.
- Estado: [ ] Pendiente · [ ] En progreso · [x] Completado

2) Asociación con contenidos (slug o ID)
- Qué hace: Vincula imágenes con proyectos/servicios/posts/páginas a partir de slugs, reglas, sitemap y/o REST WP. Puede usar patrones de nombre o carpetas lógicas.
- Interacción: Enriquecimiento del índice; habilita validaciones y exportación contextual.
- Estado: [ ] Pendiente · [ ] En progreso · [x] Completado

3) Editor de metadatos (título, alt, descripción, tipo de toma, idioma)
- Qué hace: Permite editar metadatos bilingües y campos adicionales; soporta modo CLI y, en fases posteriores, panel simple.
- Interacción: Escribe cambios en `media-index.json`; opcionalmente exporta cambios diferenciales.
- Estado: [ ] Pendiente · [x] En progreso · [ ] Completado

4) Organizador de carpetas (estructura lógica)
- Qué hace: Propone y materializa una estructura en `content/media/library/` basada en categorías (projects/services/site/brand/people/etc.), creando enlaces simbólicos o copias controladas sin duplicar binarios.
- Interacción: Apoya asociación, exportación y auditoría. Trabaja con checksums para evitar duplicados.
- Estado: [ ] Pendiente · [ ] En progreso · [x] Completado

5) Exportador (JSON / CSV)
- Qué hace: Genera vistas filtradas en JSON/CSV para consumo externo (WP, informes, catálogos).
- Interacción: Lee del índice canónico y aplica transformaciones; puede crear paquetes con estructura+metadatos.
- Estado: [ ] Pendiente · [ ] En progreso · [x] Completado

6) Verificador de imágenes huérfanas y consistencia
- Qué hace: Detecta imágenes no referenciadas, duplicadas por contenido, o con metadatos incompletos; emite reportes.
- Interacción: Se apoya en asociación y escáner; alimenta decisiones de limpieza/optimización.
- Estado: [ ] Pendiente · [ ] En progreso · [x] Completado

7) Optimizador (WebP/AVIF y tamaños)
- Qué hace: Genera variantes WebP/AVIF y tamaños alineados con necesidades del tema WP; conserva originales y referencia en el índice.
- Interacción: Escribe rutas de variantes y tamaños en el índice; no sobreescribe ficheros WP originales.
- Estado: [ ] Pendiente · [ ] En progreso · [ ] Completado

8) Integración con WordPress (opcional, desacoplada)
- Qué hace: Exporta/importa metadatos vía REST o archivo; opcionalmente, MU plugin para ingesta de `media-index.json`.
- Interacción: Recibe desde exportador y actualiza medios/alt en WP de forma idempotente.
- Estado: [ ] Pendiente · [ ] En progreso · [ ] Completado

9) Auditor SEO/Accesibilidad (alt/hreflang/ratio)
- Qué hace: Revisa coberturas de alt bilingüe, tamaños mínimos, relaciones de aspecto, y coherencia con sitemap.
- Interacción: Reportes para los equipos de contenido/SEO; realimenta editor y optimizador.
- Estado: [x] Pendiente · [ ] En progreso · [ ] Completado

10) Resguardo y trazabilidad (checksums, snapshots)
- Qué hace: Mantiene manifest de checksums, fechas de generación y snapshots de índice para auditorías.
- Interacción: Base para reproducibilidad y rollbacks; integra con CI si aplica.
- Estado: [ ] Pendiente · [ ] En progreso · [ ] Completado

---

## D. Flujo de Desarrollo Iterativo

Orden recomendado y checkpoints:

1. Escaneo del sistema y generación de `media-index.json`
- Entradas: `_reports/inventario_base_imagenes_runmedia.md`, árbol de archivos (mirror/ y/o uploads), reglas de deduplicación por checksum.
- Salidas: `content/media/media-index.json` inicial con items mínimos (ruta, checksum, dimensiones, origen).
- Checkpoints: conteos por carpeta, nº de duplicados detectados, tiempo de ejecución.
- Decisiones: estrategia de IDs, política de colisiones por nombre.

2. Asociación con proyectos, servicios y blog
- Entradas: sitemap del sitio, slugs conocidos, reglas de mapeo por nombre de archivo y carpeta.
- Salidas: campos `related.{projects,services,posts,pages}` poblados.
- Checkpoints: % de imágenes con al menos una asociación, lista de no clasificadas.
- Decisiones: prioridad de asociación (por carpeta vs. por patrón de nombre).

3. Generador de carpetas por estructura lógica
- Entradas: índice consolidado; taxonomía propuesta (projects/services/site/brand/people/process/testimonials/others).
- Salidas: estructura en `content/media/library/` con enlaces simbólicos o copias controladas.
- Checkpoints: nº de enlaces creados, nº de archivos movidos/copias, 0 duplicados binarios.
- Decisiones: symlinks vs copias, normalización de nombres.

4. Editor visual/manual de metadatos
- Entradas: índice; reglas mínimas de calidad (alt obligatorio en ES/EN si aplica).
- Salidas: `media-index.json` enriquecido.
- Checkpoints: % de cobertura de alt por idioma; número de campos vacíos.
- Decisiones: formato de campos opcionales, vocabularios (shot_type, tags).

5. Exportador final (JSON/CSV y paquetes)
- Entradas: índice enriquecido.
- Salidas: vistas filtradas y paquetes para WP u otros usos.
- Checkpoints: validaciones de esquema; tamaño de exportes; muestras verificadas.
- Decisiones: mapeo exacto a WP (REST vs plugin).

6. Integración con WordPress
- Entradas: exportes; credenciales/control de entorno.
- Salidas: alt/metadata sincronizados; opcionalmente adjuntos nuevos con variantes.
- Checkpoints: nº de medios actualizados; tiempos; rollback probado.
- Decisiones: alcance exacto (solo alt/desc vs creación de adjuntos con variantes).

---

## E. Checklist de Requisitos Técnicos

- [x] Funciona sobre el inventario detectado (`_reports/inventario_base_imagenes_runmedia.md`).
- [x] No duplica imágenes (idempotente por checksum/ID).
- [x] Permite trabajar offline con carpeta espejo y sincroniza al reconectar.
- [x] Exportable como módulo a otros proyectos (configurable por rutas/reglas).
- [x] Reproducible y trazable (manifiestos de checksum y snapshots del índice).
- [x] Seguro: no sobreescribe archivos WP originales por defecto.
- [x] Determinístico: mismas entradas -> mismas salidas.
- [x] Rendimiento razonable en árbol ~miles de imágenes (progreso, caching de metadatos).

---

## F. Feedback y Problemas Detectados

Usa esta sección para documentar decisiones, dudas, bloqueos y soluciones. Mantener entradas cortas y accionables.

- Observación:
  - Contexto:
  - Impacto:
  - Acción tomada / propuesta:
  - Estado: [ ] Pendiente · [ ] En progreso · [ ] Resuelto

- Problema:
  - Descripción:
  - Evidencia:
  - Hipótesis de causa:
  - Próxima prueba:
  - Estado: [ ] Pendiente · [ ] En progreso · [ ] Resuelto

- Decisión:
  - Alternativas consideradas:
  - Criterios y por qué se elige:
  - Reversible hasta:
  - Seguimiento:

---

Notas finales
- Desarrollo: Escáner/Indexador, Exportador, Verificador, Asociación y Organizador COMPLETADOS. Editor en PROGRESO; resto PENDIENTE.
- Métrica actual: total=6162, huérfanas=703 tras reglas automáticas (comando `rules-auto`).
- Próximo paso recomendado: curar `association_rules.yaml` (afinado manual de 10–20 slugs críticos) y completar ALT con `export alt-suggestions` o `wp-plan` antes de integración.
