# Plan Maestro — Integración IA-Visual RunArt Foundry (F7–F10)

**Fecha de creación:** 2025-10-30  
**Branch:** `feat/content-audit-v2-phase1`  
**Autor:** automation-runart  
**Versión:** 1.0  
**Estado:** 🟢 Activo — Pendiente de aprobación e inicio de ejecución

---

## 📋 Índice

1. [Objetivo General](#1-objetivo-general)
2. [Fase 7 — Arquitectura IA-Visual](#2-fase-7--arquitectura-ia-visual)
3. [Fase 8 — Generación de Embeddings y Correlaciones](#3-fase-8--generación-de-embeddings-y-correlaciones)
4. [Fase 9 — Reescritura Asistida y Enriquecimiento](#4-fase-9--reescritura-asistida-y-enriquecimiento)
5. [Fase 10 — Monitoreo y Gobernanza](#5-fase-10--monitoreo-y-gobernanza)
6. [Cronograma General](#6-cronograma-general)
7. [Riesgos y Mitigaciones](#7-riesgos-y-mitigaciones)
8. [Resultado Final Esperado](#8-resultado-final-esperado)

---

## 1. Objetivo General

### Propósito
Implementar un **sistema completo de correlación semántica texto↔imagen** mediante IA para RunArt Foundry, con el fin de:

- ✅ **Automatizar la correlación texto↔imagen:** Generar recomendaciones inteligentes de imágenes relevantes para cada página basadas en similitud semántica
- ✅ **Enriquecer contenido bilingüe:** Optimizar artículos con imágenes contextualmente relevantes y metadatos ALT ES↔EN
- ✅ **Aumentar cobertura visual:** Pasar de 0% a ≥80% de páginas con imágenes correlacionadas semánticamente
- ✅ **Mejorar cobertura bilingüe:** Incrementar de 8% a ≥90% de emparejamientos ES↔EN válidos
- ✅ **Establecer pipeline automatizado:** Integrar análisis IA en CI/CD para mantenimiento continuo

### Contexto Estratégico

**Estado actual (F1–F6):**
- 25 páginas inventariadas (15 ES, 10 EN)
- 0 imágenes en biblioteca multimedia
- 84% desbalance texto↔imagen (21/25 páginas sin imágenes)
- 8% cobertura bilingüe (2/25 emparejamientos ES↔EN)
- Sistema RunMedia operativo pero sin capacidades IA

**Problemática:**
El análisis actual de correlación texto↔imagen es **puramente cuantitativo** (conteo de palabras) sin considerar relevancia semántica. No existe sistema de recomendaciones automáticas basadas en contenido visual.

**Solución propuesta:**
Implementar stack de IA con CLIP (embeddings visuales) + Sentence-Transformers (embeddings textuales) + similitud coseno (≥0.70) para correlación semántica real.

---

## 2. Fase 7 — Arquitectura IA-Visual

### 2.1. Objetivo de la Fase
Establecer la **infraestructura base de IA** con estructura de datos, módulos Python y endpoints REST para soportar análisis visual y semántico.

### 2.2. Entregables

#### A) Estructura de Almacenamiento
Crear carpetas y archivos en `data/embeddings/`:

```
data/embeddings/
├── visual/
│   ├── clip_512d/
│   │   ├── README.md                    # Documentación del formato
│   │   ├── index.json                   # Índice maestro de embeddings visuales
│   │   └── embeddings/                  # Carpeta con archivos JSON individuales
│   │       ├── {image_id_1}.json
│   │       ├── {image_id_2}.json
│   │       └── ...
│   └── metadata.json                     # Metadatos del modelo CLIP
├── text/
│   ├── multilingual_mpnet/
│   │   ├── README.md
│   │   ├── index.json                   # Índice maestro de embeddings textuales
│   │   └── embeddings/
│   │       ├── page_{id_1}.json
│   │       ├── page_{id_2}.json
│   │       └── ...
│   └── metadata.json                     # Metadatos del modelo de texto
└── correlations/
    ├── similarity_matrix.json            # Matriz completa de similitudes
    ├── recommendations_cache.json        # Cache de recomendaciones top-5
    └── validation_log.json               # Log de validaciones humanas
```

**Formato de archivo de embedding visual:**
```json
{
  "id": "abc123def456",
  "source": {
    "path": "content/media/hero-bronze-casting.jpg",
    "filename": "hero-bronze-casting.jpg",
    "checksum_sha256": "d4a5e6f7..."
  },
  "model": {
    "name": "clip-vit-base-patch32",
    "version": "2.7.0",
    "dimensions": 512
  },
  "embedding": [0.123, -0.456, 0.789, ...],  // 512 floats
  "generated_at": "2025-10-30T16:00:00Z",
  "metadata": {
    "width": 1920,
    "height": 1080,
    "file_size_kb": 450,
    "mime_type": "image/jpeg"
  }
}
```

---

#### B) Módulos Python en RunMedia

**Módulo 1: `apps/runmedia/runmedia/vision_analyzer.py`**

Responsabilidades:
- Cargar modelo CLIP (`clip-vit-base-patch32`)
- Generar embeddings visuales de 512 dimensiones
- Extraer features adicionales (colores dominantes, OCR opcional)
- Guardar embeddings en `data/embeddings/visual/clip_512d/`

```python
# Firma de función principal
def generate_visual_embedding(image_path: str) -> dict:
    """
    Genera embedding visual de una imagen.
    
    Args:
        image_path: Ruta absoluta a la imagen
    
    Returns:
        {
            "embedding": list[float],  # 512 dimensiones
            "metadata": {
                "width": int,
                "height": int,
                "file_size_kb": int,
                "generated_at": str (ISO 8601)
            }
        }
    """
```

---

**Módulo 2: `apps/runmedia/runmedia/text_encoder.py`**

Responsabilidades:
- Cargar modelo `paraphrase-multilingual-mpnet-base-v2`
- Generar embeddings textuales de contenido de páginas (ES/EN)
- Combinar título + contenido para contexto completo
- Guardar embeddings en `data/embeddings/text/multilingual_mpnet/`

```python
# Firma de función principal
def generate_text_embedding(page_title: str, page_content: str, lang: str) -> dict:
    """
    Genera embedding textual de una página.
    
    Args:
        page_title: Título de la página
        page_content: Contenido HTML/texto de la página
        lang: Código de idioma ('es' o 'en')
    
    Returns:
        {
            "embedding": list[float],  # 768 dimensiones
            "metadata": {
                "word_count": int,
                "lang": str,
                "generated_at": str
            }
        }
    """
```

---

**Módulo 3: `apps/runmedia/runmedia/correlator.py`**

Responsabilidades:
- Calcular similitud coseno entre embeddings de texto e imagen
- Filtrar por umbral mínimo (≥0.70)
- Generar top-K recomendaciones por página
- Guardar matriz de similitud en `data/embeddings/correlations/`

```python
# Firma de función principal
def recommend_images_for_page(
    page_embedding: list[float],
    image_embeddings: dict,
    threshold: float = 0.70,
    top_k: int = 5
) -> list[dict]:
    """
    Recomienda imágenes más relevantes para una página.
    
    Args:
        page_embedding: Vector de embedding de la página
        image_embeddings: Dict con {image_id: embedding_data}
        threshold: Similitud mínima (0.0-1.0)
        top_k: Número de recomendaciones
    
    Returns:
        [
            {
                "image_id": str,
                "similarity_score": float,
                "metadata": dict
            },
            ...
        ]
    """
```

---

#### C) Endpoints REST en Plugin WordPress

**Ubicación:** `tools/wpcli-bridge-plugin/runart-wpcli-bridge.php`

**Endpoint 1: `/wp-json/runart/correlations/suggest-images`**

Método: GET  
Parámetros:
- `page_id` (int, requerido): ID de página de WordPress
- `top_k` (int, opcional, default=5): Número de recomendaciones
- `threshold` (float, opcional, default=0.70): Similitud mínima

Respuesta:
```json
{
  "ok": true,
  "page_id": 123,
  "page_title": "Fundición de bronce artístico",
  "page_lang": "es",
  "recommendations": [
    {
      "image_id": 456,
      "url": "https://staging.runartfoundry.com/wp-content/uploads/hero-bronze.jpg",
      "similarity_score": 0.87,
      "alt_text_suggestion": "Proceso de fundición de bronce en taller artístico",
      "reason": "Alta correlación: fundición + bronce + artístico"
    },
    {
      "image_id": 789,
      "url": "https://staging.runartfoundry.com/wp-content/uploads/molde-arena.jpg",
      "similarity_score": 0.74,
      "alt_text_suggestion": "Molde de arena para fundición de metal",
      "reason": "Proceso técnico relacionado"
    }
  ],
  "total_analyzed": 150,
  "timestamp": "2025-10-30T16:30:00Z"
}
```

---

**Endpoint 2: `/wp-json/runart/embeddings/update`**

Método: POST  
Propósito: Regenerar embeddings de imágenes o páginas específicas  
Parámetros:
- `type` (string, requerido): "image" o "text"
- `ids` (array[int], requerido): IDs de ítems a procesar

Respuesta:
```json
{
  "ok": true,
  "type": "image",
  "processed": 5,
  "errors": 0,
  "embeddings_generated": [
    {"id": 456, "status": "success"},
    {"id": 789, "status": "success"}
  ],
  "timestamp": "2025-10-30T17:00:00Z"
}
```

---

#### D) Documentación de Arquitectura

**Archivo:** `docs/ai/architecture_overview.md`

Contenido mínimo:
- Diagrama de flujo del sistema (entrada → procesamiento → correlación → salida)
- Especificación de modelos utilizados (CLIP, Sentence-Transformers)
- Formato de datos de embeddings (JSON schema)
- API de endpoints REST con ejemplos de uso
- Métricas de evaluación (coverage, relevance score, precision@5)
- Guía de troubleshooting común

---

### 2.3. Dependencias Técnicas

**A instalar en `requirements.txt`:**
```txt
# Modelos de IA
sentence-transformers==2.7.0
torch==2.3.1+cpu  # Versión CPU para staging, GPU para producción
transformers==4.40.2

# Procesamiento de imágenes
pillow==10.3.0
opencv-python==4.9.0.80  # Opcional para análisis avanzado

# Cálculos científicos
numpy==1.26.4
scikit-learn==1.4.2  # Para similitud coseno

# Utilidades
tqdm==4.66.2  # Barra de progreso en procesamiento batch
```

**Instalación:**
```bash
cd /home/pepe/work/runartfoundry
python -m venv venv-ai
source venv-ai/bin/activate
pip install -r requirements.txt
```

---

### 2.4. Criterios de Éxito de Fase 7

- ✅ Estructura `data/embeddings/` creada con carpetas y READMEs
- ✅ 3 módulos Python funcionando (`vision_analyzer.py`, `text_encoder.py`, `correlator.py`)
- ✅ 2 endpoints REST accesibles y validados con Postman/curl
- ✅ Documentación en `docs/ai/architecture_overview.md` (mínimo 50 líneas)
- ✅ Dependencias instaladas sin conflictos en entorno de desarrollo
- ✅ Prueba de concepto (PoC): 1 imagen + 1 página → embedding generado → similitud calculada

**Duración estimada:** 10 días hábiles (2 semanas)  
**Responsable:** DevOps + IA Engineer

---

## 3. Fase 8 — Generación de Embeddings y Correlaciones

### 3.1. Objetivo de la Fase
**Generar embeddings completos** de todas las páginas e imágenes disponibles, calcular matriz de similitud y producir recomendaciones automatizadas.

### 3.2. Entregables

#### A) Embeddings Visuales

**Input:** Imágenes en `content/media/` o Media Library de WordPress  
**Output:** Archivos JSON en `data/embeddings/visual/clip_512d/embeddings/`

**Proceso:**
1. Escanear carpetas de imágenes usando RunMedia (`python -m runmedia scan`)
2. Generar embedding para cada imagen con CLIP
3. Guardar en formato JSON con metadata completa
4. Actualizar `index.json` con listado de embeddings disponibles

**Comando CLI propuesto:**
```bash
python -m runmedia generate-visual-embeddings \
    --roots content/media runmedia/library \
    --output data/embeddings/visual/clip_512d \
    --batch-size 32 \
    --verbose
```

**Métricas esperadas:**
- Total de imágenes procesadas: **TBD** (dependiente de población de Media Library)
- Tiempo de procesamiento: ~2-3 segundos por imagen (CPU), ~0.5s (GPU)
- Tamaño de almacenamiento: ~2 KB por embedding (512 floats × 4 bytes)

---

#### B) Embeddings Textuales

**Input:** Páginas desde `data/snapshots/2025-10-30/pages.json`  
**Output:** Archivos JSON en `data/embeddings/text/multilingual_mpnet/embeddings/`

**Proceso:**
1. Leer snapshot de páginas (F1)
2. Para cada página: combinar título + contenido
3. Generar embedding con modelo multilingüe (ES/EN)
4. Guardar con metadata (word_count, lang, url)

**Comando CLI propuesto:**
```bash
python -m runmedia generate-text-embeddings \
    --snapshot data/snapshots/2025-10-30/pages.json \
    --output data/embeddings/text/multilingual_mpnet \
    --verbose
```

**Métricas esperadas:**
- Total de páginas procesadas: **25** (15 ES + 10 EN)
- Tiempo de procesamiento: ~1 segundo por página
- Tamaño de almacenamiento: ~3 KB por embedding (768 floats × 4 bytes)

---

#### C) Matriz de Similitud y Correlaciones

**Input:** Embeddings visuales + embeddings textuales  
**Output:** `data/embeddings/correlations/similarity_matrix.json`

**Proceso:**
1. Cargar todos los embeddings de texto e imagen
2. Calcular similitud coseno entre cada par (página, imagen)
3. Filtrar por umbral ≥0.70
4. Generar top-5 recomendaciones por página
5. Guardar matriz completa + cache de recomendaciones

**Formato de matriz de similitud:**
```json
{
  "version": "1.0",
  "generated_at": "2025-11-15T12:00:00Z",
  "threshold": 0.70,
  "pages_analyzed": 25,
  "images_analyzed": 150,
  "total_correlations": 375,
  "correlations": {
    "page_123": {
      "page_metadata": {
        "title": "Fundición de bronce artístico",
        "url": "https://staging.runartfoundry.com/es/fundicion-bronce",
        "lang": "es",
        "word_count": 420
      },
      "recommendations": [
        {
          "image_id": "abc123",
          "similarity_score": 0.87,
          "filename": "hero-bronze-casting.jpg",
          "url": "https://staging.runartfoundry.com/wp-content/uploads/hero-bronze.jpg"
        },
        {
          "image_id": "def456",
          "similarity_score": 0.74,
          "filename": "molde-arena.jpg",
          "url": "https://staging.runartfoundry.com/wp-content/uploads/molde-arena.jpg"
        }
      ],
      "total_above_threshold": 2
    },
    "page_124": { ... }
  },
  "metrics": {
    "pages_with_recommendations": 20,
    "pages_without_recommendations": 5,
    "coverage_visual": "80%",
    "avg_similarity_score": 0.76,
    "precision_at_5": "TBD"  // Requiere validación humana
  }
}
```

---

#### D) Reporte de Correlaciones

**Archivo:** `data/correlations/text_image_links.json`

Formato simplificado para consumo por aplicaciones:
```json
{
  "version": "1.0",
  "generated_at": "2025-11-15T12:00:00Z",
  "links": [
    {
      "page_id": 123,
      "page_url": "https://staging.runartfoundry.com/es/fundicion-bronce",
      "recommended_images": [
        {
          "image_id": 456,
          "url": "https://staging.runartfoundry.com/wp-content/uploads/hero-bronze.jpg",
          "score": 0.87
        }
      ]
    }
  ]
}
```

---

### 3.3. Workflow GitHub Actions

**Archivo:** `.github/workflows/visual-analysis.yml`

**Trigger:**
- `workflow_dispatch` (manual)
- `push` en paths:
  - `content/media/**`
  - `data/snapshots/**/*.json`

**Jobs:**
1. **setup-python:** Python 3.11 con cache de dependencias
2. **generate-visual-embeddings:** Ejecutar script de análisis visual
3. **generate-text-embeddings:** Ejecutar script de análisis textual
4. **calculate-correlations:** Ejecutar correlator.py
5. **create-pr:** PR automático con recomendaciones

**Artefactos:**
- `embeddings_visual.tar.gz`
- `embeddings_text.tar.gz`
- `similarity_matrix.json`
- `recommendations_report.md`

---

### 3.4. Criterios de Éxito de Fase 8

- ✅ 25 embeddings textuales generados (1 por página)
- ✅ N embeddings visuales generados (N = total imágenes en biblioteca)
- ✅ Matriz de similitud con ≥80% de páginas con al menos 1 recomendación
- ✅ `text_image_links.json` creado y accesible vía REST
- ✅ Workflow GitHub Actions ejecutado sin errores
- ✅ Precision@5 ≥60% en validación manual de 10 páginas aleatorias

**Duración estimada:** 15 días hábiles (3 semanas)  
**Responsable:** Data Engineer + IA Engineer

---

## 4. Fase 9 — Reescritura Asistida y Enriquecimiento

### 4.1. Objetivo de la Fase
Utilizar las correlaciones de F8 para **reescribir y enriquecer artículos** con imágenes contextualmente relevantes, metadatos ALT optimizados y estructura visual mejorada.

### 4.2. Entregables

#### A) Selección de Artículos Prioritarios

Criterios de priorización:
1. **Alta relevancia estratégica:** Páginas de servicios principales (fundición, restauración)
2. **Alto desbalance texto↔imagen:** Páginas con >300 palabras sin imágenes
3. **Brechas bilingües:** Páginas sin traducción ES↔EN

**Proceso:**
1. Leer `data/embeddings/correlations/similarity_matrix.json`
2. Filtrar páginas con `similarity_score ≥ 0.75` y `total_above_threshold ≥ 3`
3. Ordenar por `word_count DESC` (priorizar artículos largos)
4. Seleccionar top-10 páginas para reescritura piloto

**Output:** `drafts_rewrite/prioritized_pages.json`

---

#### B) Estructura de Carpeta `drafts_rewrite/`

```
drafts_rewrite/
├── README.md                     # Guía de uso de drafts
├── prioritized_pages.json        # Lista de páginas seleccionadas
├── es/
│   ├── fundicion-bronce_v2.md    # Draft reescrito ES
│   ├── restauracion-esculturas_v2.md
│   └── ...
├── en/
│   ├── bronze-casting_v2.md      # Draft reescrito EN
│   ├── sculpture-restoration_v2.md
│   └── ...
└── images_mapping/
    ├── fundicion-bronce_images.json  # Mapeo de imágenes recomendadas
    └── ...
```

---

#### C) Formato de Draft Reescrito

**Archivo ejemplo:** `drafts_rewrite/es/fundicion-bronce_v2.md`

```markdown
---
original_url: https://staging.runartfoundry.com/es/fundicion-bronce
draft_version: 2
created_at: 2025-11-20T10:00:00Z
author: content-team
status: pending_review
correlations_used: [abc123, def456, ghi789]
---

# Fundición de Bronce Artístico — RUN Art Foundry

## Introducción

![Proceso de fundición de bronce en taller artístico](https://staging.runartfoundry.com/wp-content/uploads/hero-bronze.jpg)
*Alt: Proceso de fundición de bronce en taller artístico - RUN Art Foundry Miami*

La fundición de bronce es un proceso milenario que combina artesanía tradicional con técnicas modernas...

## Proceso Técnico

### 1. Preparación del Molde

![Molde de arena para fundición](https://staging.runartfoundry.com/wp-content/uploads/molde-arena.jpg)
*Alt: Molde de arena para fundición de metal - Detalle técnico*

El molde de arena es fundamental para...

[Continúa con contenido enriquecido...]
```

**Metadata de mapeo:** `drafts_rewrite/images_mapping/fundicion-bronce_images.json`

```json
{
  "page_id": 123,
  "page_url": "https://staging.runartfoundry.com/es/fundicion-bronce",
  "images_inserted": [
    {
      "image_id": 456,
      "url": "https://staging.runartfoundry.com/wp-content/uploads/hero-bronze.jpg",
      "position": "intro",
      "alt_es": "Proceso de fundición de bronce en taller artístico - RUN Art Foundry Miami",
      "alt_en": "Bronze casting process in artistic workshop - RUN Art Foundry Miami",
      "similarity_score": 0.87
    },
    {
      "image_id": 789,
      "url": "https://staging.runartfoundry.com/wp-content/uploads/molde-arena.jpg",
      "position": "section_1",
      "alt_es": "Molde de arena para fundición de metal - Detalle técnico",
      "alt_en": "Sand mold for metal casting - Technical detail",
      "similarity_score": 0.74
    }
  ],
  "total_images": 2,
  "visual_coverage": "100%",
  "generated_at": "2025-11-20T10:30:00Z"
}
```

---

#### D) Reporte de Reescrituras

**Archivo:** `_reports/IA_REWRITES_LOG.md`

```markdown
# Registro de Reescrituras Asistidas por IA — RunArt Foundry

**Periodo:** 2025-11-15 a 2025-12-15  
**Total de páginas reescritas:** 10  
**Páginas en revisión:** 3  
**Páginas publicadas:** 7

---

## Resumen de Reescrituras

| Página | Idioma | Imágenes añadidas | Score promedio | Estado | Revisor |
|--------|--------|-------------------|----------------|--------|---------|
| Fundición de bronce | ES | 3 | 0.82 | ✅ Publicado | Ana García |
| Bronze casting | EN | 3 | 0.81 | ✅ Publicado | John Smith |
| Restauración de esculturas | ES | 2 | 0.79 | 🔄 En revisión | — |
| Sculpture restoration | EN | 2 | 0.78 | 🔄 En revisión | — |
| ... | ... | ... | ... | ... | ... |

---

## Métricas de Calidad

- **Precision@5:** 75% (15/20 recomendaciones aceptadas por revisores)
- **Coverage visual:** 100% (10/10 páginas con ≥2 imágenes)
- **Tiempo promedio de reescritura:** 45 minutos por página
- **Tasa de aprobación:** 70% (7/10 drafts aprobados sin cambios mayores)

---

## Feedback de Revisores

### Positivo
- ✅ Imágenes altamente relevantes al contexto
- ✅ ALT text descriptivo y bilingüe
- ✅ Estructura visual mejora legibilidad

### A mejorar
- ⚠️ Algunas recomendaciones con score 0.70-0.75 requieren validación adicional
- ⚠️ Falta uniformidad en posición de imágenes (intro vs. secciones)

---

## Próximas Acciones

1. Revisar páginas en estado "En revisión"
2. Publicar drafts aprobados a staging
3. Recolectar feedback de usuarios finales
4. Ajustar umbral de similitud si necesario (0.70 → 0.75)
```

---

### 4.3. Proceso de Validación Humana

**Workflow de aprobación:**
1. Content Team recibe notificación de nuevo draft en `drafts_rewrite/`
2. Revisor abre draft en editor Markdown local
3. Valida relevancia de imágenes (aprueba/rechaza cada una)
4. Edita ALT text si es necesario
5. Marca draft como `approved` en metadata
6. Draft aprobado se migra a WordPress vía script de importación

**Herramienta de validación:** Dashboard web simple o interfaz CLI

```bash
# Ejemplo CLI para validación
python tools/validate_draft.py \
    --draft drafts_rewrite/es/fundicion-bronce_v2.md \
    --reviewer "Ana García" \
    --approve
```

---

### 4.4. Criterios de Éxito de Fase 9

- ✅ 10 artículos reescritos con imágenes correlacionadas (5 ES + 5 EN)
- ✅ 100% de drafts con metadata de mapeo completo
- ✅ Precision@5 ≥70% en validación humana
- ✅ Reporte `IA_REWRITES_LOG.md` actualizado con feedback
- ✅ ≥7 drafts publicados a staging tras aprobación
- ✅ Documentación de proceso en `drafts_rewrite/README.md`

**Duración estimada:** 30 días hábiles (6 semanas)  
**Responsable:** Content Team + IA Engineer (soporte)

---

## 5. Fase 10 — Monitoreo y Gobernanza

### 5.1. Objetivo de la Fase
Establecer **sistema de monitoreo continuo** con métricas IA, auditoría automática y gobernanza del sistema para garantizar calidad y mantenimiento a largo plazo.

### 5.2. Entregables

#### A) Archivo de Métricas IA

**Ubicación:** `data/metrics/ai_visual_progress.json`

```json
{
  "version": "1.0",
  "last_updated": "2025-12-15T18:00:00Z",
  "phases_completed": 10,
  "metrics": {
    "embeddings": {
      "visual_total": 150,
      "text_total": 25,
      "visual_updated_last_week": 5,
      "text_updated_last_week": 2
    },
    "correlations": {
      "total_pages": 25,
      "pages_with_recommendations": 21,
      "coverage_visual": "84%",
      "avg_similarity_score": 0.78,
      "threshold_used": 0.70
    },
    "content_enrichment": {
      "pages_rewritten": 10,
      "pages_published": 7,
      "pages_pending_review": 3,
      "total_images_inserted": 28,
      "precision_at_5": "75%"
    },
    "bilingual_coverage": {
      "total_pairs": 25,
      "paired_es_en": 22,
      "coverage": "88%",
      "gaps_remaining": 3
    },
    "performance": {
      "avg_embedding_time_ms": 1200,
      "avg_correlation_time_ms": 300,
      "last_full_analysis_duration_mins": 45
    }
  },
  "quality_indicators": {
    "precision_at_5": 0.75,
    "recall_at_5": "TBD",
    "user_satisfaction": "TBD",  // Encuestas post-publicación
    "bounce_rate_improvement": "TBD"
  }
}
```

---

#### B) Integración con Briefing Status Dashboard

**Ubicación:** `apps/briefing/public/index.html` (extender sección IA)

**Visualizaciones a agregar:**

1. **Gráfico de Coverage Visual:**
   - Tipo: Progress bar
   - Meta: ≥80%
   - Valor actual: 84% (21/25 páginas)

2. **Heatmap de Similitud:**
   - Eje X: Páginas (25 ítems)
   - Eje Y: Imágenes (top-10 por página)
   - Color: Verde (≥0.80), Amarillo (0.70-0.79), Rojo (<0.70)

3. **Distribución de Scores:**
   - Tipo: Histograma
   - Bins: [0.70-0.75), [0.75-0.80), [0.80-0.85), [0.85-0.90), [0.90+]
   - Cantidad de correlaciones por bin

4. **Timeline de Reescrituras:**
   - Tipo: Gráfico de línea
   - Eje X: Fechas (últimos 30 días)
   - Eje Y: Páginas reescritas acumuladas

5. **Tabla de Precision:**
   - Columnas: Página | Idioma | Imágenes | Precision@5 | Estado
   - Ordenable por cualquier columna

**Código de integración (JavaScript):**
```javascript
// Cargar métricas desde JSON
fetch('/data/metrics/ai_visual_progress.json')
  .then(res => res.json())
  .then(data => {
    // Actualizar progress bar de coverage
    document.getElementById('visual-coverage').innerText = data.metrics.correlations.coverage_visual;
    
    // Renderizar gráficos con Chart.js
    renderCoverageChart(data.metrics.correlations);
    renderPrecisionTable(data.metrics.content_enrichment);
  });
```

---

#### C) Auditoría Automática Mensual

**Workflow:** `.github/workflows/audit-ai-monthly.yml`

**Trigger:** Cron (`0 0 1 * *` — primer día de cada mes a medianoche)

**Jobs:**
1. **regenerate-embeddings:** Re-escanear imágenes y páginas nuevas
2. **recalculate-correlations:** Actualizar matriz de similitud
3. **validate-quality:** Ejecutar tests de calidad (precision, coverage)
4. **generate-report:** Crear reporte Markdown con hallazgos
5. **create-issue:** Abrir GitHub Issue si coverage < 70% o precision < 60%

**Reporte generado:** `_reports/AUDIT_IA_MONTHLY_YYYY-MM.md`

```markdown
# Auditoría IA-Visual Mensual — Noviembre 2025

**Fecha de ejecución:** 2025-11-01T00:00:00Z  
**Duración:** 12 minutos

---

## Estado General

- ✅ Coverage visual: 84% (meta: ≥80%)
- ✅ Precision@5: 75% (meta: ≥70%)
- ⚠️ 3 páginas sin recomendaciones (< 0.70 similitud)
- ✅ 5 nuevas imágenes procesadas
- ✅ 2 páginas nuevas procesadas

---

## Detalles

### Páginas sin Recomendaciones
1. **Página ID 145:** "Legal Notices" — 50 palabras (contenido técnico, sin imágenes relevantes)
2. **Página ID 167:** "Privacy Policy" — 80 palabras (similar a anterior)
3. **Página ID 189:** "Cookie Policy" — 60 palabras (ídem)

**Acción recomendada:** Exentar páginas legales de requisito de cobertura visual.

### Nuevas Imágenes
- `hero-restoration-2025.jpg` — Embedding generado — Correlacionada con 3 páginas
- `team-photo-miami.jpg` — Embedding generado — Correlacionada con 1 página

---

## Métricas de Tendencia

- Coverage visual: 80% → 84% (+4% mes anterior)
- Precision@5: 73% → 75% (+2% mes anterior)
- Tiempo de análisis: 50 min → 45 min (-10% por optimización)

---

## Acciones Pendientes

- [ ] Revisar páginas ID 145, 167, 189 (exentar de auditoría IA)
- [ ] Publicar 3 drafts pendientes de revisión
- [ ] Ajustar threshold a 0.75 si precision sube a 80%+
```

---

#### D) Gobernanza y Políticas

**Archivo:** `docs/ai/governance_policy.md`

Contenido mínimo:
- **Política de privacidad:** Embeddings no contienen datos personales
- **Uso de modelos:** Solo modelos open-source (CLIP, Sentence-Transformers)
- **Validación humana:** Requerida para publicación de contenido
- **Frecuencia de auditoría:** Mensual automática + trimestral manual
- **Umbral de calidad:** Precision@5 ≥70%, Coverage ≥80%
- **Proceso de actualización de modelos:** Versionado, testing, rollback plan
- **Responsabilidades:** IA Engineer (mantenimiento técnico), Content Team (validación editorial)

---

### 5.3. Alertas y Notificaciones

**Sistema de alertas configurado en GitHub Actions:**

| Condición | Severidad | Acción |
|-----------|----------|--------|
| Coverage < 70% | 🔴 Alta | Issue automático + notificación a equipo |
| Precision@5 < 60% | 🔴 Alta | Issue + revisión de threshold |
| Embeddings desactualizados (>30 días) | 🟡 Media | Comentario en PR activo |
| Auditoría mensual fallida | 🔴 Alta | Issue + rollback de cambios si necesario |
| Nuevas imágenes sin embedding (>10) | 🟡 Media | Ejecutar workflow manual |

---

### 5.4. Criterios de Éxito de Fase 10

- ✅ Archivo `ai_visual_progress.json` actualizado automáticamente
- ✅ Dashboard de métricas IA visible en Briefing Status
- ✅ Workflow de auditoría mensual ejecutado sin errores
- ✅ Primer reporte mensual generado (`AUDIT_IA_MONTHLY_2025-11.md`)
- ✅ Política de gobernanza documentada en `docs/ai/governance_policy.md`
- ✅ Sistema de alertas configurado y probado con caso de test
- ✅ Coverage visual mantenido ≥80% durante 2 meses consecutivos

**Duración estimada:** 15 días hábiles (3 semanas)  
**Responsable:** Analytics Lead + DevOps

---

## 6. Cronograma General

### 6.1. Timeline de Fases

| Fase | Duración | Inicio | Fin | Entregable Principal | Responsable |
|------|----------|--------|-----|----------------------|-------------|
| **F7 — Arquitectura IA-Visual** | 10 días | 2025-11-04 | 2025-11-15 | Módulos Python + endpoints REST | DevOps + IA Engineer |
| **F8 — Embeddings y Correlaciones** | 15 días | 2025-11-18 | 2025-12-06 | Matriz de similitud completa | Data Engineer + IA Engineer |
| **F9 — Reescritura Asistida** | 30 días | 2025-12-09 | 2026-01-17 | 10 artículos enriquecidos publicados | Content Team |
| **F10 — Monitoreo y Gobernanza** | 15 días | 2026-01-20 | 2026-02-07 | Dashboard + auditoría automática | Analytics Lead + DevOps |

**Duración total:** 70 días hábiles (~14 semanas / 3.5 meses)  
**Inicio estimado:** 2025-11-04 (tras aprobación de Plan Maestro)  
**Fin estimado:** 2026-02-07

---

### 6.2. Hitos Críticos (Milestones)

| Milestone | Fecha | Criterio de Validación | Bloqueador si falla |
|-----------|-------|------------------------|---------------------|
| **M1:** PoC exitoso (1 imagen + 1 página) | 2025-11-08 | Similarity score ≥0.70 calculado | ❌ Detiene F7 |
| **M2:** 3 módulos Python operativos | 2025-11-15 | Tests unitarios pasando | ❌ Detiene F8 |
| **M3:** Endpoints REST validados | 2025-11-15 | Postman collection 100% OK | ⚠️ Retrasa F8 |
| **M4:** 25 embeddings textuales generados | 2025-11-22 | index.json actualizado | ❌ Detiene F8 |
| **M5:** Matriz de similitud con coverage ≥60% | 2025-12-06 | 15/25 páginas con recomendaciones | ⚠️ Requiere ajuste threshold |
| **M6:** 5 drafts aprobados por revisores | 2025-12-27 | Precision@5 ≥70% validada | ⚠️ Retrasa F9 |
| **M7:** Dashboard IA visible en Briefing | 2026-01-31 | Gráficos renderizando correctamente | ⚠️ Retrasa F10 |
| **M8:** Primera auditoría mensual ejecutada | 2026-02-01 | Reporte generado sin errores | ❌ Detiene F10 |

---

### 6.3. Dependencias entre Fases

```
F7 (Arquitectura)
    ↓
    ├── Módulos Python creados
    ├── Endpoints REST activos
    └── Estructura data/embeddings/
                ↓
            F8 (Embeddings)
                ↓
                ├── Embeddings visuales generados
                ├── Embeddings textuales generados
                └── Matriz de similitud calculada
                            ↓
                        F9 (Reescritura)
                            ↓
                            ├── Drafts con imágenes correlacionadas
                            ├── Validación humana completada
                            └── Contenido publicado
                                        ↓
                                    F10 (Monitoreo)
                                        ↓
                                        ├── Métricas capturadas
                                        ├── Dashboard activo
                                        └── Auditoría automatizada
```

**Bloqueadores críticos:**
- ⚠️ **F7 → F8:** Si PoC falla, toda implementación se detiene
- ⚠️ **F8 → F9:** Si coverage < 50%, reescritura no tiene suficientes correlaciones
- ⚠️ **F9 → F10:** Si precision < 50%, sistema no es confiable para producción

---

## 7. Riesgos y Mitigaciones

### 7.1. Riesgos Técnicos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| **Falta de imágenes en biblioteca (0 actualmente)** | 🔴 **ALTA** | 🔴 **CRÍTICO** | **Prioridad P0:** Poblar Media Library con ≥100 imágenes antes de F8. Usar mirrors o assets externos. |
| Modelos de IA lentos (>30s por imagen) | 🟡 Media | 🔴 Alto | Usar GPU para inferencia o modelos cuantizados (INT8). Procesamiento batch nocturno. |
| Embeddings ocupan mucho espacio (>1GB) | 🟢 Baja | 🟡 Medio | Comprimir con PCA (512→128 dims). Almacenar en S3 comprimido. |
| Incompatibilidad de dependencias (torch/transformers) | 🟡 Media | 🟡 Medio | Usar Docker con imagen Python pre-configurada. Pin versions estrictas. |
| Precision@5 baja (<60%) en producción | 🟡 Media | 🔴 Alto | Recolectar feedback humano intensivo. Fine-tunear CLIP con dataset específico. |

---

### 7.2. Riesgos de Recursos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Falta de capacidad GPU para inferencia | 🟡 Media | 🟡 Medio | Usar instancias cloud on-demand (AWS EC2 g4dn). Alternativamente, CPU con batch pequeño. |
| Content Team sobrecargado (30 días para 10 artículos) | 🔴 Alta | 🟡 Medio | Reducir alcance inicial a 5 artículos piloto. Contratar freelancer temporal. |
| IA Engineer no disponible full-time | 🟡 Media | 🔴 Alto | Asignar DevOps como backup. Documentar exhaustivamente para handoff. |
| Presupuesto para APIs externas insuficiente | 🟢 Baja | 🟢 Bajo | Usar solo modelos open-source. Evaluar APIs solo si precision < 70% persistente. |

---

### 7.3. Riesgos de Calidad

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Recomendaciones IA irrelevantes (falsos positivos) | 🟡 Media | 🔴 Alto | Validación humana obligatoria. Umbral conservador (0.70→0.75). |
| Desbalance bilingüe persiste (coverage < 80%) | 🟡 Media | 🟡 Medio | Priorizar traducciones en F9. Contratar traductor profesional. |
| Drift de modelo (performance baja con tiempo) | 🟢 Baja | 🟡 Medio | Auditoría mensual detecta degradación. Re-entrenar trimestralmente. |
| ALT text generado automáticamente de baja calidad | 🟡 Media | 🟡 Medio | Revisión humana de 100% de ALTs antes de publicación. Templates bilingües. |

---

### 7.4. Plan de Contingencia

**Escenario 1:** Falta crítica de imágenes (0 en biblioteca)

**Acciones inmediatas:**
1. Contactar cliente para assets originales
2. Usar banco de imágenes con licencia comercial (Unsplash, Pexels)
3. Crear imágenes sintéticas/diagramas con herramientas (Figma, Canva)
4. Retrasar F8 hasta tener ≥50 imágenes mínimas

**Timeline de contingencia:** +2 semanas en F7

---

**Escenario 2:** Precision@5 < 50% en validación inicial

**Acciones inmediatas:**
1. Analizar falsos positivos manualmente (sample de 20 casos)
2. Ajustar threshold de 0.70 a 0.80
3. Fine-tunear CLIP con dataset específico de fundición (100 ejemplos)
4. Evaluar modelo alternativo (OpenCLIP, BLIP-2)

**Timeline de contingencia:** +1 semana en F8

---

**Escenario 3:** Content Team no puede completar 10 artículos en 30 días

**Acciones inmediatas:**
1. Reducir alcance a 5 artículos piloto
2. Contratar freelancer para 20 horas/semana
3. Automatizar generación de borradores con GPT-4 (opcional)
4. Extender F9 a 45 días

**Timeline de contingencia:** +2 semanas en F9

---

## 8. Resultado Final Esperado

### 8.1. Sistema IA-Visual Operativo

Al finalizar F7–F10, RunArt Foundry dispondrá de:

✅ **Infraestructura de IA completa:**
- Estructura de datos `data/embeddings/` con embeddings visuales y textuales
- 3 módulos Python en RunMedia: `vision_analyzer.py`, `text_encoder.py`, `correlator.py`
- 2 endpoints REST: `/correlations/suggest-images`, `/embeddings/update`

✅ **Correlaciones semánticas automatizadas:**
- Matriz de similitud con ≥80% de páginas con recomendaciones (umbral ≥0.70)
- Precision@5 ≥70% validada por Content Team
- Archivo `text_image_links.json` para consumo por aplicaciones

✅ **Contenido optimizado bilingüe y visual:**
- 10 artículos reescritos con imágenes correlacionadas (5 ES + 5 EN)
- 100% de imágenes con ALT text bilingüe descriptivo
- Coverage visual: 84% (21/25 páginas con imágenes relevantes)

✅ **Pipeline CI/CD automatizado:**
- Workflow GitHub Actions para análisis IA visual
- Auditoría mensual automática con generación de reportes
- Sistema de alertas configurado (coverage, precision, embeddings desactualizados)

✅ **Monitoreo y gobernanza:**
- Dashboard de métricas IA en Briefing Status (5 visualizaciones)
- Archivo `ai_visual_progress.json` actualizado automáticamente
- Política de gobernanza documentada en `docs/ai/governance_policy.md`

---

### 8.2. Métricas de Éxito Finales

| Métrica | Baseline (F1-F6) | Meta (F7-F10) | Impacto |
|---------|------------------|---------------|---------|
| **Coverage visual** | 0% | ≥80% | +80 pp |
| **Coverage bilingüe** | 8% | ≥90% | +82 pp |
| **Páginas sin imágenes** | 25/25 (100%) | ≤5/25 (20%) | -80 pp |
| **Precision@5** | N/A | ≥70% | Sistema confiable |
| **Tiempo de correlación** | N/A | <5 min para 25 páginas | Eficiente |
| **Artículos enriquecidos** | 0 | 10 | +10 |
| **Imágenes con ALT bilingüe** | 0% | 100% | +100 pp |

---

### 8.3. Beneficios Estratégicos

**Para el negocio:**
- 📈 **Mejora de SEO:** Imágenes con ALT optimizado aumentan ranking en búsqueda de imágenes
- 🌐 **Cobertura bilingüe real:** 90% de contenido disponible en ES y EN (vs. 8% actual)
- 💰 **Reducción de costos:** Automatización de correlación reduce 70% tiempo manual de selección de imágenes
- 🚀 **Escalabilidad:** Sistema puede procesar nuevas páginas/imágenes sin intervención humana intensiva

**Para el equipo técnico:**
- 🔧 **Infraestructura reutilizable:** Módulos de IA aplicables a otros proyectos
- 📊 **Visibilidad de métricas:** Dashboard permite tomar decisiones basadas en datos
- 🤖 **Automatización completa:** Pipeline CI/CD reduce tareas repetitivas
- 📖 **Documentación exhaustiva:** Facilita onboarding de nuevos integrantes

**Para los usuarios finales:**
- 🎨 **Experiencia visual mejorada:** Artículos con imágenes relevantes aumentan engagement
- ♿ **Accesibilidad:** ALT text descriptivo mejora experiencia para lectores de pantalla
- 🌍 **Contenido multilingüe:** Usuarios hispanohablantes y anglohablantes tienen acceso equitativo

---

### 8.4. Próximos Pasos Post-F10

Una vez completadas las fases F7–F10, considerar:

1. **Fine-tuning de modelos con datos propios** (F11):
   - Recolectar dataset de 500+ validaciones humanas
   - Fine-tunear CLIP con imágenes de fundición artística
   - Meta: Precision@5 ≥85% (vs. 70% actual)

2. **Expansión a análisis de video** (F12):
   - Integrar modelos de video (CLIP4Clip, Video-BERT)
   - Correlacionar contenido de videos con páginas
   - Generar thumbnails automáticos optimizados

3. **Generación de contenido con GPT-4** (F13):
   - Automatizar generación de borradores de artículos
   - Usar correlaciones IA para sugerir estructura de contenido
   - Validación humana obligatoria pre-publicación

4. **Integración con CMS** (F14):
   - Plugin WordPress con interfaz visual de recomendaciones
   - Drag-and-drop de imágenes sugeridas en editor
   - Preview en tiempo real de correlaciones

---

## 📝 Anexos

### A.1. Glosario de Términos

- **Embedding:** Vector numérico de alta dimensionalidad que representa características semánticas de texto o imagen
- **CLIP:** Contrastive Language-Image Pre-training — modelo de OpenAI para embeddings visuales
- **Sentence-Transformers:** Framework para generar embeddings textuales contextuales
- **Similitud coseno:** Métrica de similitud entre vectores (rango 0.0 a 1.0)
- **Precision@K:** Porcentaje de recomendaciones relevantes en top-K resultados
- **Coverage:** Porcentaje de páginas con al menos N imágenes correlacionadas
- **Threshold:** Umbral mínimo de similitud para considerar una correlación válida

### A.2. Referencias

- [CLIP Paper (OpenAI)](https://arxiv.org/abs/2103.00020)
- [Sentence-Transformers Documentation](https://www.sbert.net/)
- [RunMedia Architecture](apps/runmedia/README.md)
- [Resumen Ejecutivo IA-Visual](research/ai_visual_tools_summary.md)
- [Reporte Completo de Investigación](_reports/AI_VISUAL_TOOLS_REPORT.md)

### A.3. Contactos

- **IA Engineer Lead:** TBD
- **DevOps Lead:** TBD
- **Content Team Lead:** TBD
- **Analytics Lead:** TBD
- **Product Owner:** @ppkapiro

---

**Documento generado por:** automation-runart  
**Fecha:** 2025-10-30T17:00:00Z  
**Branch:** feat/content-audit-v2-phase1  
**PR:** #77  
**Estado:** ✅ Listo para aprobación  
**Próxima acción:** Validar con equipo técnico y aprobar inicio de **Fase 7** (2025-11-04)

---

**Versión del documento:** 1.0  
**Líneas totales:** 917  
**Última actualización:** 2025-10-30
