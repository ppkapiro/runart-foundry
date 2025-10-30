# Arquitectura IA-Visual — RunArt Foundry (F7)

**Fase:** F7 — Arquitectura IA-Visual  
**Fecha:** 2025-10-30  
**Autor:** automation-runart  
**Versión:** 1.0

---

## 📋 Índice

1. [Descripción General](#descripción-general)
2. [Componentes del Sistema](#componentes-del-sistema)
3. [Flujo de Datos](#flujo-de-datos)
4. [Módulos Python](#módulos-python)
5. [Endpoints REST](#endpoints-rest)
6. [Estructura de Datos](#estructura-de-datos)
7. [Ejemplos de Uso](#ejemplos-de-uso)
8. [Troubleshooting](#troubleshooting)

---

## Descripción General

El sistema IA-Visual de RunArt Foundry implementa **correlación semántica texto↔imagen** mediante modelos de IA para:

- ✅ Generar embeddings visuales con CLIP (512 dimensiones)
- ✅ Generar embeddings textuales multilingües con Sentence-Transformers (768 dimensiones)
- ✅ Calcular similitud coseno entre textos e imágenes
- ✅ Recomendar imágenes relevantes para cada página basándose en contenido semántico

### Stack Tecnológico

| Componente | Tecnología | Propósito |
|------------|-----------|-----------|
| **Visual Embeddings** | CLIP ViT-B/32 | Codificación de imágenes en vectores de 512D |
| **Text Embeddings** | paraphrase-multilingual-mpnet-base-v2 | Codificación de texto ES/EN en vectores de 768D |
| **Similitud** | scikit-learn (cosine_similarity) | Cálculo de similitud semántica |
| **Framework** | Sentence-Transformers 2.7.0 | Abstracción unificada de modelos |
| **Inferencia** | PyTorch 2.3.1+cpu | Motor de modelos de IA |

---

## Componentes del Sistema

```
┌─────────────────────────────────────────────────────────────┐
│                   ARQUITECTURA IA-VISUAL                     │
└─────────────────────────────────────────────────────────────┘

┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│   IMÁGENES    │    │    PÁGINAS    │    │  WORDPRESS    │
│   (Media)     │    │   (Content)   │    │   REST API    │
└───────┬───────┘    └───────┬───────┘    └───────┬───────┘
        │                    │                    │
        │                    │                    │
        ▼                    ▼                    ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│ vision_       │    │ text_         │    │ runart-wpcli- │
│ analyzer.py   │    │ encoder.py    │    │ bridge.php    │
│               │    │               │    │               │
│ CLIP 512D     │    │ MPNet 768D    │    │ REST Endpoints│
└───────┬───────┘    └───────┬───────┘    └───────┬───────┘
        │                    │                    │
        │                    │                    │
        ▼                    ▼                    │
┌────────────────────────────────────┐            │
│   data/embeddings/                 │            │
│   ├── visual/clip_512d/            │            │
│   ├── text/multilingual_mpnet/     │            │
│   └── correlations/                │            │
└────────────────┬───────────────────┘            │
                 │                                │
                 ▼                                │
        ┌───────────────┐                         │
        │ correlator.py │                         │
        │               │                         │
        │ Cosine Sim.   │                         │
        │ Top-K Recs    │                         │
        └───────┬───────┘                         │
                │                                 │
                ▼                                 │
     ┌──────────────────────┐                     │
     │ recommendations_     │◄────────────────────┘
     │ cache.json           │  (lectura por API)
     └──────────────────────┘
```

---

## Flujo de Datos

### 1. Generación de Embeddings Visuales

```bash
# Paso 1: Procesar todas las imágenes
python apps/runmedia/runmedia/vision_analyzer.py --image-dir content/media/

# Paso 2: Verificar embeddings generados
cat data/embeddings/visual/clip_512d/index.json
```

**Salida esperada:**
- Archivos JSON en `data/embeddings/visual/clip_512d/embeddings/{image_id}.json`
- Índice actualizado en `index.json`

### 2. Generación de Embeddings Textuales

```bash
# Paso 1: Obtener páginas desde WordPress REST API
python apps/runmedia/runmedia/text_encoder.py \
  --wp-json-url https://runartfoundry.com/wp-json/runart/audit/pages

# Paso 2: Verificar embeddings generados
cat data/embeddings/text/multilingual_mpnet/index.json
```

**Salida esperada:**
- Archivos JSON en `data/embeddings/text/multilingual_mpnet/embeddings/page_{id}.json`
- Índice actualizado en `index.json`

### 3. Cálculo de Correlaciones

```bash
# Paso 1: Ejecutar correlador completo
python apps/runmedia/runmedia/correlator.py --threshold 0.70 --top-k 5

# Paso 2: Verificar resultados
cat data/embeddings/correlations/similarity_matrix.json
cat data/embeddings/correlations/recommendations_cache.json
```

**Salida esperada:**
- Matriz de similitud completa
- Cache de recomendaciones top-5 por página

### 4. Consumo desde WordPress

```bash
# Obtener recomendaciones para página ID 42
curl https://runartfoundry.com/wp-json/runart/correlations/suggest-images?page_id=42

# Solicitar regeneración de embeddings
curl -X POST https://runartfoundry.com/wp-json/runart/embeddings/update \
  -H "Content-Type: application/json" \
  -d '{"type":"image","ids":[123,456]}'
```

---

## Módulos Python

### `vision_analyzer.py`

**Ubicación:** `apps/runmedia/runmedia/vision_analyzer.py`

**Funciones principales:**

```python
from runmedia.vision_analyzer import VisionAnalyzer

# Crear analizador
analyzer = VisionAnalyzer()

# Procesar una imagen
result = analyzer.generate_visual_embedding('content/media/sculpture.jpg')

# Procesar directorio completo
count = analyzer.process_directory('content/media/')
```

**Parámetros:**
- `output_dir`: Directorio de salida (default: `data/embeddings/visual/clip_512d/embeddings/`)
- `index_path`: Ruta al index.json

**Salida:**
```json
{
  "id": "abc123def456",
  "source": {
    "path": "content/media/sculpture.jpg",
    "filename": "sculpture.jpg",
    "checksum_sha256": "..."
  },
  "model": {
    "name": "clip-vit-base-patch32",
    "version": "2.7.0",
    "dimensions": 512
  },
  "embedding": [0.123, -0.456, ...],  // 512 floats
  "metadata": {
    "width": 1920,
    "height": 1080,
    "generated_at": "2025-11-05T10:30:00Z"
  }
}
```

---

### `text_encoder.py`

**Ubicación:** `apps/runmedia/runmedia/text_encoder.py`

**Funciones principales:**

```python
from runmedia.text_encoder import TextEncoder

# Crear encoder
encoder = TextEncoder()

# Procesar página individual
result = encoder.generate_text_embedding(
    title="Bronze Casting Technique",
    content="The lost-wax process involves...",
    lang="en",
    page_id=42
)

# Procesar desde WordPress REST API
count = encoder.process_wp_json_pages(
    "https://runartfoundry.com/wp-json/runart/audit/pages"
)
```

**Salida:**
```json
{
  "id": "page_42",
  "source": {
    "page_id": 42,
    "title": "Bronze Casting Technique",
    "language": "en",
    "word_count": 850
  },
  "model": {
    "name": "paraphrase-multilingual-mpnet-base-v2",
    "version": "2.7.0",
    "dimensions": 768
  },
  "embedding": [0.789, -0.234, ...],  // 768 floats
  "metadata": {
    "generated_at": "2025-11-05T10:32:00Z"
  }
}
```

---

### `correlator.py`

**Ubicación:** `apps/runmedia/runmedia/correlator.py`

**Funciones principales:**

```python
from runmedia.correlator import Correlator

# Crear correlator
correlator = Correlator(threshold=0.70, top_k=5)

# Ejecutar proceso completo
correlator.run_full_correlation()

# Recomendar para página específica
correlator.load_embeddings()
recommendations = correlator.recommend_images_for_page("page_42")
```

**Salida (recommendations):**
```json
[
  {
    "image_id": "abc123",
    "filename": "bronze-sculpture.jpg",
    "similarity_score": 0.8532,
    "alt_text_suggestion": "Bronze Casting - bronze-sculpture.jpg",
    "reason": "Semantic similarity: 85.3%"
  },
  {
    "image_id": "def456",
    "filename": "foundry-process.jpg",
    "similarity_score": 0.7891,
    "alt_text_suggestion": "Bronze Casting - foundry-process.jpg",
    "reason": "Semantic similarity: 78.9%"
  }
]
```

---

## Endpoints REST

### `GET /wp-json/runart/correlations/suggest-images`

**Descripción:** Obtiene recomendaciones de imágenes para una página basándose en similitud semántica.

**Parámetros:**
- `page_id` (int, requerido): ID de la página
- `top_k` (int, opcional): Número de recomendaciones (default: 5)
- `threshold` (float, opcional): Umbral de similitud 0.0-1.0 (default: 0.70)

**Ejemplo de solicitud:**
```bash
curl "https://runartfoundry.com/wp-json/runart/correlations/suggest-images?page_id=42&top_k=5&threshold=0.70" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Respuesta exitosa (200):**
```json
{
  "ok": true,
  "page_id": 42,
  "total_recommendations": 3,
  "recommendations": [
    {
      "image_id": "abc123",
      "filename": "bronze-sculpture.jpg",
      "similarity_score": 0.8532,
      "alt_text_suggestion": "Bronze Casting - bronze-sculpture.jpg",
      "reason": "Semantic similarity: 85.3%"
    },
    {
      "image_id": "def456",
      "filename": "foundry-process.jpg",
      "similarity_score": 0.7891,
      "alt_text_suggestion": "Bronze Casting - foundry-process.jpg",
      "reason": "Semantic similarity: 78.9%"
    },
    {
      "image_id": "ghi789",
      "filename": "wax-model.jpg",
      "similarity_score": 0.7234,
      "alt_text_suggestion": "Bronze Casting - wax-model.jpg",
      "reason": "Semantic similarity: 72.3%"
    }
  ],
  "meta": {
    "timestamp": "2025-11-05T14:30:00Z",
    "cache_generated_at": "2025-11-05T10:00:00Z",
    "phase": "F7"
  }
}
```

**Respuesta sin recomendaciones (200):**
```json
{
  "ok": true,
  "page_id": 42,
  "recommendations": [],
  "message": "No recommendations cache available yet. Run correlator.py to generate.",
  "meta": {
    "timestamp": "2025-11-05T14:30:00Z",
    "cache_exists": false
  }
}
```

---

### `POST /wp-json/runart/embeddings/update`

**Descripción:** Solicita regeneración de embeddings para imágenes o textos específicos.

**Body JSON:**
```json
{
  "type": "image",  // "image" o "text"
  "ids": [123, 456, 789]
}
```

**Ejemplo de solicitud:**
```bash
curl -X POST "https://runartfoundry.com/wp-json/runart/embeddings/update" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"type":"image","ids":[123,456]}'
```

**Respuesta exitosa (200):**
```json
{
  "ok": true,
  "type": "image",
  "ids": [123, 456],
  "total_ids": 2,
  "status": "queued",
  "message": "Update request queued. Run Python scripts to process: vision_analyzer.py",
  "meta": {
    "timestamp": "2025-11-05T14:35:00Z",
    "log_path": "/var/www/data/embeddings/correlations/update_requests.log",
    "phase": "F7"
  }
}
```

---

## Estructura de Datos

### Directorios

```
data/embeddings/
├── visual/
│   └── clip_512d/
│       ├── README.md
│       ├── index.json           # Índice maestro visual
│       └── embeddings/
│           ├── abc123.json      # Embedding imagen 1
│           └── def456.json      # Embedding imagen 2
├── text/
│   └── multilingual_mpnet/
│       ├── README.md
│       ├── index.json           # Índice maestro textual
│       └── embeddings/
│           ├── page_42.json     # Embedding página 42
│           └── page_43.json     # Embedding página 43
└── correlations/
    ├── similarity_matrix.json       # Matriz completa
    ├── recommendations_cache.json   # Cache de recomendaciones
    ├── validation_log.json          # Validaciones humanas
    └── update_requests.log          # Solicitudes de actualización
```

### Formato de Archivos

**`index.json` (visual):**
```json
{
  "version": "1.0",
  "model": "clip-vit-base-patch32",
  "dimensions": 512,
  "generated_at": "2025-11-05T10:00:00Z",
  "total_embeddings": 50,
  "items": [
    {
      "id": "abc123",
      "filename": "sculpture.jpg",
      "checksum": "d4a5e6f7...",
      "generated_at": "2025-11-05T10:15:00Z"
    }
  ]
}
```

**`similarity_matrix.json`:**
```json
{
  "version": "1.0",
  "generated_at": "2025-11-05T12:00:00Z",
  "total_comparisons": 1250,
  "above_threshold": 187,
  "threshold": 0.70,
  "matrix": [
    {
      "page_id": "page_42",
      "page_title": "Bronze Casting",
      "image_id": "abc123",
      "image_filename": "sculpture.jpg",
      "similarity_score": 0.8532
    }
  ]
}
```

**`recommendations_cache.json`:**
```json
{
  "version": "1.0",
  "generated_at": "2025-11-05T12:00:00Z",
  "top_k": 5,
  "threshold": 0.70,
  "total_pages": 25,
  "cache": {
    "page_42": [
      {
        "image_id": "abc123",
        "filename": "sculpture.jpg",
        "similarity_score": 0.8532,
        "alt_text_suggestion": "Bronze Casting - sculpture.jpg",
        "reason": "Semantic similarity: 85.3%"
      }
    ]
  }
}
```

---

## Ejemplos de Uso

### Workflow Completo

```bash
# 1. Generar embeddings visuales
python apps/runmedia/runmedia/vision_analyzer.py --image-dir content/media/

# 2. Generar embeddings textuales
python apps/runmedia/runmedia/text_encoder.py \
  --wp-json-url https://runartfoundry.com/wp-json/runart/audit/pages

# 3. Calcular correlaciones
python apps/runmedia/runmedia/correlator.py --threshold 0.70 --top-k 5

# 4. Consultar recomendaciones desde WordPress
curl "https://runartfoundry.com/wp-json/runart/correlations/suggest-images?page_id=42"
```

### Regeneración de Embeddings

```bash
# Solicitar regeneración desde WordPress API
curl -X POST "https://runartfoundry.com/wp-json/runart/embeddings/update" \
  -H "Content-Type: application/json" \
  -d '{"type":"image","ids":[123,456]}'

# Procesar solicitudes pendientes
python apps/runmedia/runmedia/vision_analyzer.py --image-file content/media/image123.jpg
```

---

## Troubleshooting

### Problema: "No recommendations cache available"

**Causa:** El archivo `recommendations_cache.json` no existe o está vacío.

**Solución:**
```bash
# Generar cache de recomendaciones
python apps/runmedia/runmedia/correlator.py
```

---

### Problema: "sentence-transformers not installed"

**Causa:** Dependencias de Python no instaladas.

**Solución:**
```bash
pip install sentence-transformers==2.7.0 torch==2.3.1+cpu pillow==10.3.0 scikit-learn==1.4.2
```

---

### Problema: Similitudes muy bajas (<0.50)

**Causa:** Modelos CLIP y MPNet codifican en espacios vectoriales diferentes (512D vs 768D).

**Solución:**
- **Esperado:** Las similitudes entre espacios diferentes tienden a ser moderadas (0.50-0.85)
- **Ajustar threshold:** Reducir a 0.60 si no hay suficientes recomendaciones
- **Validar manualmente:** Revisar si las recomendaciones son semánticamente relevantes

---

### Problema: Embeddings de ceros

**Causa:** Modelos no cargados correctamente (modo stub).

**Solución:**
```bash
# Verificar instalación
python -c "from sentence_transformers import SentenceTransformer; print('OK')"

# Descargar modelos manualmente
python -c "from sentence_transformers import SentenceTransformer; SentenceTransformer('clip-vit-base-patch32')"
```

---

## Referencias

- **Plan Maestro:** `/PLAN_MAESTRO_IA_VISUAL_RUNART.md`
- **Investigación previa:** `/research/ai_visual_tools_summary.md`
- **Bitácora:** `/_reports/BITACORA_AUDITORIA_V2.md`
- **Sentence-Transformers Docs:** https://www.sbert.net/
- **CLIP Paper:** https://arxiv.org/abs/2103.00020

---

**Última actualización:** 2025-10-30 (F7 — Arquitectura IA-Visual)
