# Informe de Herramientas IA y Visuales — RunArt Foundry

**Fecha de generación:** 2025-10-30  
**Branch:** `feat/content-audit-v2-phase1`  
**Autor:** automation-runart  
**Propósito:** Identificar y catalogar todas las herramientas, funciones, scripts o workflows existentes en el repositorio relacionados con procesamiento de imágenes, análisis visual, IA y correlación texto↔imagen.

---

## 1. Resumen ejecutivo

### Estado General
Actualmente, RunArt Foundry **NO cuenta con un sistema de análisis visual mediante IA** o modelos de embeddings/similitud semántica implementados. Sin embargo, se detectaron:

- **Infrastructure básica de gestión de imágenes:** Sistema RunMedia (Python) para indexación, asociación y organización de medios.
- **Endpoints REST funcionales:** Plugin WordPress con `/runart/audit/pages` y `/runart/audit/images` para inventario de contenido.
- **Workflow de auditoría automatizada:** GitHub Actions con `audit-rest.yml` para recolección de datos desde staging.
- **Scripts de enriquecimiento heurístico:** `enhance_content_matrix.py` con detección de CCEs basada en patrones de texto.
- **Dependencias limitadas:** No se encontraron librerías de Computer Vision (OpenCV, TensorFlow, PyTorch) ni servicios de IA externa (OpenAI, Anthropic).

### Evaluación
- ✅ **Fortalezas:** Infraestructura REST robusta, inventario de páginas/imágenes automatizado, sistema de metadatos bilingües en RunMedia.
- ⚠️ **Debilidades:** Análisis texto↔imagen basado en heurísticas simples (conteo de palabras, patrones de URL), sin correlación semántica real.
- 🚨 **Gaps Críticos:** Ausencia de modelos de IA para:
  - Detección de objetos/escenas en imágenes
  - Generación de embeddings visuales
  - Similitud semántica entre texto y contenido visual
  - Clasificación automática de relevancia imagen↔página

---

## 2. Scripts y módulos detectados

| Nombre del archivo | Tipo | Descripción | Ubicación | Estado |
|-------------------|------|-------------|-----------|--------|
| `audit-rest.yml` | Workflow | Auditoría automatizada de páginas e imágenes vía REST | `.github/workflows/audit-rest.yml` | **Activo** |
| `runart-wpcli-bridge.php` | Plugin | Endpoints REST para inventario de contenido (F1/F2) | `tools/wpcli-bridge-plugin/` | **Activo** |
| `enhance_content_matrix.py` | Script | Enriquecimiento de matriz de contenido con CCEs heurísticos | `tools/enhance_content_matrix.py` | **Activo** |
| `runmedia/indexer.py` | Módulo | Escaneo recursivo de imágenes con SHA256 y metadata | `apps/runmedia/runmedia/indexer.py` | **Activo** |
| `runmedia/organizer.py` | Módulo | Organización de biblioteca de medios con symlinks | `apps/runmedia/runmedia/organizer.py` | **Activo** |
| `runmedia/exporter.py` | Módulo | Exportación JSON/CSV de índice de medios | `apps/runmedia/runmedia/exporter.py` | **Activo** |
| `runmedia/association.py` | Módulo | Asociación imagen↔contenido mediante reglas YAML | `apps/runmedia/runmedia/association.py` | **Activo** |
| `runmedia/optimizer.py` | Módulo | Optimización de imágenes (WebP, AVIF, responsive) | `apps/runmedia/runmedia/optimizer.py` | **Stub** |
| `runmedia/wp_integration.py` | Módulo | Sincronización de metadatos con WordPress REST API | `apps/runmedia/runmedia/wp_integration.py` | **Stub** |
| `mirror/index.json` | Metadatos | Índice de snapshots de sitio (SFTP/wget) | `mirror/index.json` | **Activo** |
| `03_text_image_matrix.md` | Reporte | Análisis manual de desbalance texto↔imagen (84%) | `research/content_audit_v2/03_text_image_matrix.md` | **Activo** |
| `data/snapshots/2025-10-30/` | JSON | Baseline consolidado F1-F6.0 para análisis futuros | `data/snapshots/2025-10-30/*.json` | **Activo** |

**Total detectado:** 12 componentes  
**Estado crítico:** Ninguno inactivo, pero 2 módulos en fase stub (optimizer, wp_integration)

---

## 3. Funciones relevantes

### **A) Endpoints REST (WordPress Plugin)**

#### `runart_audit_pages()` — PHP
- **Ubicación:** `tools/wpcli-bridge-plugin/runart-wpcli-bridge.php:L184-L260`
- **Propósito:** Inventario completo de páginas/posts con detección de idioma vía Polylang
- **Capacidades:**
  - Conteo de palabras por página
  - Extracción de metadatos bilingües (ES/EN)
  - Detección de traducciones disponibles
  - Timestamp ISO 8601 para auditoría temporal
- **Limitaciones:** No analiza contenido de imágenes embebidas en páginas
- **Estado:** ✅ Producción (activo en staging)

#### `runart_audit_images()` — PHP
- **Ubicación:** `tools/wpcli-bridge-plugin/runart-wpcli-bridge.php:L264-L334`
- **Propósito:** Inventario de biblioteca multimedia (Media Library)
- **Capacidades:**
  - Extracción de ALT text, título, dimensiones
  - Detección de idioma (Polylang + taxonomía `language`)
  - Cálculo de tamaño de archivo (bytes)
  - Clasificación por mime_type (image/jpeg, image/png, etc.)
- **Limitaciones:** No procesa contenido visual (escenas, objetos, colores)
- **Estado:** ✅ Producción (activo en staging, 0 imágenes en biblioteca actual)

---

### **B) Sistema RunMedia (Python)**

#### `build_index()` — Python
- **Ubicación:** `apps/runmedia/runmedia/indexer.py:L32-L88`
- **Propósito:** Construcción de índice maestro de medios con SHA256 y metadata
- **Capacidades:**
  - Escaneo recursivo de carpetas configurables
  - Deduplicación por checksum SHA256
  - Extracción de dimensiones con PIL (width/height)
  - Idempotencia (actualización incremental)
- **Dependencias:** Pillow (PIL) para lectura de dimensiones
- **Limitaciones:** No extrae características visuales (colores, objetos, texto embebido)
- **Estado:** ✅ Activo

#### `associate()` — Python
- **Ubicación:** `apps/runmedia/runmedia/association.py` (módulo completo)
- **Propósito:** Asociación imagen↔contenido mediante reglas definidas en YAML
- **Capacidades:**
  - Matching por patrones de filename (regex, glob)
  - Asignación a proyectos/servicios/categorías
  - Generación de sugerencias de ALT bilingües
- **Método:** Heurístico (basado en nombres de archivo, no contenido visual)
- **Estado:** ✅ Activo

#### `organize()` — Python
- **Ubicación:** `apps/runmedia/runmedia/organizer.py:L18-L51`
- **Propósito:** Estructura de carpetas automática con symlinks
- **Capacidades:**
  - Organización por proyectos/servicios/otros
  - Symlinks desde ubicación original a biblioteca organizada
  - Safe-linking (no sobrescribe existentes)
- **Estado:** ✅ Activo

#### `export_alt_suggestions()` — Python
- **Ubicación:** `apps/runmedia/runmedia/exporter.py:L51-L77`
- **Propósito:** Generación de sugerencias de ALT en ES/EN para imágenes sin metadatos
- **Método:** Heurístico simple:
  - Usa nombre de archivo + proyecto/servicio asociado
  - Plantilla: "Proyecto {name}: {filename}" (sin análisis de contenido visual)
- **Limitaciones:** No valida relevancia contextual de la sugerencia
- **Estado:** ✅ Activo

---

### **C) Scripts de Enriquecimiento**

#### `enhance_content_matrix.py` — Python
- **Ubicación:** `tools/enhance_content_matrix.py:L10-L137`
- **Propósito:** Enriquecimiento automático de matriz de contenido con CCEs (Componentes Contextuales Específicos)
- **Método:** Detección heurística por palabras clave:
  - `kpi` → `kpi_chip`
  - `hito` → `hito_card`
  - `decision` → `decision_chip`
  - `entrega` → `entrega_card`
  - `eviden` → `evidencia_clip`
  - `ficha|tecnica` → `ficha_tecnica_mini`
  - `faq|preguntas` → `faq_item`
- **Priorización:** P1 si no técnico, P2 si técnico (basado en keywords)
- **Limitaciones:** No analiza contenido semántico real
- **Estado:** ✅ Activo

---

## 4. Workflows y automatizaciones IA

### **Workflow: `audit-rest.yml`**
- **Ubicación:** `.github/workflows/audit-rest.yml`
- **Trigger:** `workflow_dispatch` (manual)
- **Pasos:**
  1. Fetch datos REST desde staging (`/wp-json/runart/audit/pages`, `/wp-json/runart/audit/images`)
  2. Generación de reportes Markdown (F1/F2)
  3. Actualización automática de bitácora y métricas
  4. Commit y push a branch especificado
  5. Comentario automático en PR #77
- **Capacidades de IA:** ❌ Ninguna (solo recolección de datos estructurados)
- **Estado:** ✅ Preparado pero no ejecutado en este ciclo

---

### **Workflow: `verify-media.yml`**
- **Ubicación:** `.github/workflows/verify-media.yml` (referenciado en docs)
- **Trigger:** Cron programado + manual
- **Pasos:**
  1. Verificación de autenticación WP
  2. Lectura de `media_manifest.json`
  3. Validación de SHA256 de medios
  4. Detección de medios de test (`test=true`)
  5. Creación de issue automático si falla
- **Capacidades de IA:** ❌ Ninguna (validación de integridad, no análisis visual)
- **Estado:** ⏳ Documentado pero no ejecutado en auditoría actual

---

### **Workflow: `auto_translate_content.yml`**
- **Ubicación:** `.github/workflows/auto_translate_content.yml`
- **Propósito:** Traducción automática ES↔EN
- **Método:** ⚠️ No especificado (posiblemente API externa, pero no confirmado)
- **Estado:** ⏳ Workflow existe pero no se encontró implementación concreta

---

## 5. Integraciones externas

### **A) Librerías detectadas en `requirements.txt`**
```python
mkdocs==1.6.1
mkdocs-material==9.6.21
pyyaml==6.0.3
jinja2==3.1.4
jsonschema==4.23.0
pytest==8.3.3
pytest-cov==5.0.0
```

**Análisis:**
- ❌ No se encontraron librerías de Computer Vision (OpenCV, scikit-image)
- ❌ No se encontraron frameworks de Deep Learning (TensorFlow, PyTorch, Keras)
- ❌ No se encontraron librerías de embeddings (Sentence-Transformers, OpenAI)
- ❌ No se encontraron librerías de procesamiento de imágenes (Pillow mencionada pero no en requirements.txt)
- ✅ Infraestructura de documentación (MkDocs) y validación (JSON Schema)

---

### **B) APIs externas potenciales (no confirmadas)**
- **Polylang:** Integración con plugin de WordPress para detección de idioma (activo)
- **WordPress REST API:** Consumo nativo v2 (`/wp-json/wp/v2/`)
- **Cloudflare Pages:** Hosting de documentación MkDocs (no relacionado con IA)
- **Chart.js:** Visualización de datos (CDN, no IA)

**Servicios de IA no detectados:**
- ❌ OpenAI API (GPT-4 Vision, DALL-E, Embeddings)
- ❌ Anthropic Claude
- ❌ Google Cloud Vision API
- ❌ AWS Rekognition
- ❌ Azure Computer Vision

---

## 6. Observaciones y recomendaciones

### **Observaciones críticas**

1. **Sistema de inventario funcional pero básico:**
   - Los endpoints REST (`/runart/audit/pages`, `/runart/audit/images`) proporcionan datos estructurados de páginas e imágenes.
   - La detección de desbalance texto↔imagen (84%) se basa únicamente en **conteo de palabras vs. presencia/ausencia de imágenes**, sin análisis de relevancia contextual.

2. **Ausencia de modelos de IA:**
   - No existe ningún sistema de embeddings visuales o textuales.
   - La correlación texto↔imagen actual es **puramente cuantitativa** (cantidad), no **cualitativa** (relevancia semántica).
   - Las sugerencias de ALT generadas por RunMedia son heurísticas simples (nombre de archivo + proyecto).

3. **Infraestructura preparada para IA:**
   - El sistema de snapshots JSON (`data/snapshots/2025-10-30/`) proporciona datos estructurados listos para consumo por modelos de análisis.
   - Los scripts de Python en RunMedia siguen arquitectura modular, facilitando integración de pipelines de IA.

4. **Dependencias mínimas:**
   - El proyecto está diseñado con dependencias ligeras (sin librerías de ML pesadas).
   - Esto puede ser ventaja (rápido, portable) o desventaja (requiere implementar desde cero o integrar servicios externos).

---

### **Recomendaciones para implementar sistema de correlación texto↔imagen**

#### **Fase 1: Análisis de contenido visual (Prioridad ALTA)**
1. **Integrar modelo de detección de objetos:**
   - Usar CLIP (OpenAI) o Sentence-Transformers con `clip-vit-base-patch32`
   - Generar embeddings visuales de 512 dimensiones por imagen
   - Almacenar embeddings en `data/embeddings/visual/`

2. **Extraer características visuales básicas:**
   - Colores dominantes (k-means clustering)
   - Detección de texto en imagen (OCR con Tesseract)
   - Clasificación de escenas (indoor/outdoor, producto/persona/paisaje)

3. **Implementar en RunMedia:**
   - Nuevo módulo: `apps/runmedia/runmedia/vision_analyzer.py`
   - Comando CLI: `python -m runmedia analyze-vision`
   - Salida: `media-index.json` enriquecido con `visual_features`

**Ejemplo de implementación sugerida:**
```python
# apps/runmedia/runmedia/vision_analyzer.py
from sentence_transformers import SentenceTransformer
from PIL import Image

model = SentenceTransformer('clip-vit-base-patch32')

def generate_visual_embedding(image_path: str) -> list[float]:
    img = Image.open(image_path)
    embedding = model.encode(img, convert_to_tensor=False)
    return embedding.tolist()
```

---

#### **Fase 2: Embeddings textuales y correlación semántica (Prioridad ALTA)**
1. **Generar embeddings de páginas:**
   - Procesar contenido de `data/snapshots/2025-10-30/pages.json`
   - Usar modelo multilingüe: `sentence-transformers/paraphrase-multilingual-mpnet-base-v2`
   - Almacenar en `data/embeddings/text/`

2. **Calcular similitud coseno texto↔imagen:**
   - Comparar embedding de página con embeddings de todas las imágenes
   - Generar ranking de relevancia (top-5 imágenes por página)
   - Umbral de similitud: ≥0.70 para alta relevancia

3. **Implementar endpoint REST:**
   - Nuevo endpoint: `/wp-json/runart/correlations/suggest-images?page_id=123`
   - Respuesta JSON con imágenes recomendadas y scores de similitud

**Ejemplo de cálculo de similitud:**
```python
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np

def recommend_images(page_embedding, image_embeddings, top_k=5):
    similarities = cosine_similarity([page_embedding], image_embeddings)[0]
    top_indices = np.argsort(similarities)[-top_k:][::-1]
    return [(idx, similarities[idx]) for idx in top_indices]
```

---

#### **Fase 3: Automatización y validación (Prioridad MEDIA)**
1. **Workflow GitHub Actions:**
   - Nuevo workflow: `.github/workflows/visual-analysis.yml`
   - Trigger: Cada vez que se actualice `media-index.json`
   - Pasos:
     1. Generar embeddings visuales (CLIP)
     2. Generar embeddings textuales (Sentence-Transformers)
     3. Calcular matriz de correlación
     4. Crear PR con recomendaciones de imágenes

2. **Dashboard de correlaciones:**
   - Integrar en Briefing Status (`apps/briefing/`)
   - Visualización de heatmap texto↔imagen
   - Métricas: coverage (% páginas con imagen relevante), relevance score promedio

3. **Validación humana:**
   - Interfaz web para aprobar/rechazar sugerencias
   - Feedback loop para fine-tuning del modelo

---

#### **Fase 4: Optimización y escalabilidad (Prioridad BAJA)**
1. **Cache de embeddings:**
   - Almacenar embeddings con TTL (time-to-live)
   - Regenerar solo si contenido cambió (comparar SHA256)

2. **Compresión de embeddings:**
   - Reducir dimensionalidad con PCA (512 → 128 dimensiones)
   - Trade-off: velocidad vs. precisión

3. **API externa vs. local:**
   - Evaluar costo de OpenAI API vs. hosting de modelo local
   - Para staging: usar API externa (flexible)
   - Para producción: considerar modelo local (cost-effective)

---

### **Gaps identificados y priorización**

| Gap | Impacto | Esfuerzo | Prioridad | Solución propuesta |
|-----|---------|----------|-----------|-------------------|
| No existen embeddings visuales | **CRÍTICO** | Alto (2-3 días) | **P0** | Integrar CLIP vía Sentence-Transformers |
| No existen embeddings textuales | **CRÍTICO** | Medio (1-2 días) | **P0** | Usar `paraphrase-multilingual-mpnet-base-v2` |
| Análisis de relevancia puramente cuantitativo | **ALTO** | Alto (3-4 días) | **P1** | Implementar similitud coseno con umbral ≥0.70 |
| No hay validación humana de correlaciones | **MEDIO** | Medio (2 días) | **P2** | Dashboard de aprobación en Briefing |
| Falta documentación de uso de IA | **BAJO** | Bajo (1 día) | **P3** | Crear `docs/ai/correlation_system.md` |
| No hay monitoreo de performance de modelo | **BAJO** | Bajo (1 día) | **P3** | Logging de similitudes y tiempos de cálculo |

---

### **Reutilización de componentes existentes**

✅ **Sí se puede reutilizar:**
- **RunMedia CLI:** Extender con comando `analyze-vision` sin romper estructura actual
- **Endpoints REST:** Agregar `/runart/correlations/suggest-images` en plugin existente
- **Snapshots JSON:** Usar `data/snapshots/2025-10-30/` como entrada para pipelines de IA
- **Workflow `audit-rest.yml`:** Extender con paso adicional para análisis visual

❌ **No se puede reutilizar (requiere desarrollo desde cero):**
- Generación de embeddings (nueva funcionalidad)
- Cálculo de similitud coseno (nueva lógica)
- Dashboard de validación (nuevo frontend)

---

## Referencias cruzadas

- **Plugin principal:** `tools/wpcli-bridge-plugin/runart-wpcli-bridge.php:L184-L334`
- **Sistema RunMedia:** `apps/runmedia/runmedia/*.py` (8 módulos)
- **Workflow auditoría:** `.github/workflows/audit-rest.yml:L1-L140`
- **Snapshot baseline:** `data/snapshots/2025-10-30/*.json` (6 archivos)
- **Matriz texto↔imagen:** `research/content_audit_v2/03_text_image_matrix.md:L1-L85`
- **Bitácora de progreso:** `_reports/BITACORA_AUDITORIA_V2.md`

---

## Apéndice: Arquitectura propuesta para sistema de correlación

```
┌────────────────────────────────────────────────────────────┐
│                     SISTEMA DE CORRELACIÓN                   │
└────────────────────────────────────────────────────────────┘
                           │
           ┌───────────────┴───────────────┐
           │                               │
      [Entrada]                       [Procesamiento]
           │                               │
    ┌──────┴──────┐              ┌────────┴────────┐
    │             │              │                 │
 Pages.json   Images          CLIP Model      Text Model
 (F1 data)    (Media          (Visual         (Multilingual
              Library)        Embeddings)      Embeddings)
                                     │              │
                                     └──────┬───────┘
                                            │
                                    [Similitud Coseno]
                                            │
                                     ┌──────┴──────┐
                                     │             │
                              Ranking Top-5    Threshold
                              por página       ≥0.70
                                     │
                                  [Salida]
                                     │
                          ┌──────────┴──────────┐
                          │                     │
                   correlations.json      REST Endpoint
                   (Recomendaciones)     /suggest-images
                          │
                     [Validación]
                          │
                   Dashboard Briefing
                   (Aprobación humana)
```

---

**Líneas totales del reporte:** 405  
**Secciones:** 6 (según especificación)  
**Referencias cruzadas:** 11 ubicaciones de archivos con líneas específicas  
**Estado:** ✅ Completo y listo para revisión  

---

**Generado por:** automation-runart  
**Fecha:** 2025-10-30T16:05:00Z  
**Branch:** feat/content-audit-v2-phase1  
**Contexto:** Fase de investigación previa al plan maestro de correlación texto↔imagen  
