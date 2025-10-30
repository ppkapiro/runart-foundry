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

## Rutas de Datos y Hosting Environments

### Sistema de Prioridades (Cascading Read)

El plugin WP-CLI Bridge (`runart-wpcli-bridge.php`) implementa un sistema de lectura en cascada para ubicar archivos JSON de contenido enriquecido y embeddings. Esto garantiza compatibilidad con distintos entornos de hosting:

```php
// Orden de búsqueda (función runart_bridge_data_bases):
1. repo:      ../data                                 # Repositorio (desarrollo local)
2. wp_content: wp-content/runart-data                 # WP-Content (staging/producción)
3. uploads:    wp-content/uploads/runart-data         # Uploads (hosting restringido)
4. plugin:     wp-content/plugins/runart-wpcli-bridge/data  # Plugin (fallback final)
```

### Razón: Restricciones de Hosting

En entornos de hosting gestionado (ej: IONOS, WP Engine), PHP no puede leer fuera del árbol `wp-content/`. Por tanto:

- **Desarrollo Local**: Lee desde `../data/` (repositorio completo)
- **Staging/Producción**: Lee desde `wp-content/runart-data/` (copia manual)
- **Hosting Restringido**: Lee desde `wp-content/uploads/runart-data/` (subido vía FTP)
- **Fallback Plugin**: Lee desde `wp-content/plugins/runart-wpcli-bridge/data/` (incluido en deploy)

### Sincronización de Datos

Los archivos críticos deben copiarse a todas las ubicaciones accesibles:

```bash
# Sincronizar contenido enriquecido (F9)
cp -r data/assistants/rewrite/*.json wp-content/runart-data/assistants/rewrite/
cp -r data/assistants/rewrite/*.json wp-content/uploads/runart-data/assistants/rewrite/
cp -r data/assistants/rewrite/*.json wp-content/plugins/runart-wpcli-bridge/data/assistants/rewrite/

# Sincronizar embeddings (F7/F8)
cp -r data/embeddings/* wp-content/runart-data/embeddings/
cp -r data/embeddings/* wp-content/uploads/runart-data/embeddings/
```

El plugin reporta en el campo `meta.source` qué ruta utilizó (valores: `repo`, `wp_content`, `uploads`, `plugin`), útil para diagnóstico.

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

## Fase 10 — Orquestación y Endurecimiento

**Fecha:** 2025-10-30  
**Objetivo:** Exponer capacidades IA-Visual mediante endpoint maestro, validar esquemas JSON, y crear canal seguro de solicitudes de regeneración.

### Endpoint Maestro: `/wp-json/runart/ai-visual/pipeline`

El orquestador unificado proporciona acceso centralizado a todas las capacidades del pipeline IA-Visual.

#### Action: `status`
Obtiene el estado actual del sistema completo (F7/F8/F9/F10).

#### Action: `preview`
Previsualiza contenido del pipeline sin modificaciones.

#### Action: `regenerate`
Solicita regeneración de componentes (write-safe).

### Sistema de Jobs
**Archivo:** `data/ai_visual_jobs/pending_requests.json`

Las solicitudes de regeneración se registran en este archivo JSON para procesamiento asíncrono por CI/runner.

### Validación de Esquemas
**Módulo:** `apps/runmedia/runmedia/schema_validator.py`

Valida la estructura de todos los artefactos del pipeline (similarity_matrix.json, recommendations_cache.json, rewrite/*.json).

### Integración CI/CD
El workflow `.github/workflows/ai-visual-analysis.yml` incluye job de validación que falla el build si hay JSONs inválidos.

---

**Última actualización:** 2025-10-30 (F10 — Orquestación y Endurecimiento)

## Monitor IA-Visual en WP (F10 — Vista)

Esta vista mínima permite a usuarios autenticados (admin/editor) verificar desde el navegador los datos ya generados en F7/F8/F9 y registrar una solicitud de regeneración sin ejecutar procesos pesados.

### Shortcode

- Colocar en una página protegida: `[runart_ai_visual_monitor]`
- Visibilidad: requiere usuario autenticado con `manage_options` (admin) o `edit_pages` (editor).

### Qué muestra

- Correlaciones (F8) para `page_id=42` consultando:
  - `GET /wp-json/runart/correlations/suggest-images?page_id=42`
- Contenido enriquecido (F9) para `page_42` consultando:
  - `GET /wp-json/runart/content/enriched?page_id=page_42`
- Estado general del pipeline (F10, opcional si habilitado):
  - `GET /wp-json/runart/ai-visual/pipeline?action=status`

### Solicitar regeneración (solo registro)

- Botón “Solicitar regeneración de correlaciones” que realiza:
  - `POST /wp-json/runart/ai-visual/request-regeneration`
- Comportamiento:
  - Si `wp-content/uploads/runart-jobs/` es escribible → escribe `regeneration_request.json` con:
    ```json
    { "last_request_at": "<ISO8601>", "requested_by": "<user_login>", "target": "correlations" }
    ```
    Respuesta: `{ "status": "ok", "message": "Solicitud registrada" }`
  - Si no es escribible → no escribe y retorna:
    `{ "status": "queued", "message": "El entorno no permite escritura directa, revisar runner/CI" }`

### Notas

- Los endpoints REST existentes permanecen sin cambios. La vista no re-genera embeddings; solo consume los datos actuales y registra solicitudes.
- La seguridad de endpoints sigue gobernada por el plugin; el shortcode solo es visible para admin/editor.

---

## Panel Editorial IA-Visual (F10-b)

Extensión del monitor que agrega modo editorial para revisión y aprobación de contenidos enriquecidos.

### Uso

```
[runart_ai_visual_monitor mode="editor"]
```

### Endpoints Nuevos

#### 1. Listado de contenidos enriquecidos

```
GET /wp-json/runart/content/enriched-list
```

- **Permisos:** Usuario autenticado (`is_user_logged_in()`)
- **Comportamiento:**
  - Lee `data/assistants/rewrite/index.json`
  - Fusiona con `data/assistants/rewrite/approvals.json` si existe
  - Devuelve array de contenidos con estado de aprobación

**Respuesta:**
```json
{
  "ok": true,
  "items": [
    {
      "id": "page_42",
      "title": "page_42",
      "lang": "es",
      "status": "approved",
      "approval": {
        "status": "approved",
        "updated_at": "2025-10-30T20:00:00Z",
        "updated_by": "runart-admin"
      }
    }
  ],
  "total": 3
}
```

#### 2. Aprobar/Rechazar contenido

```
POST /wp-json/runart/content/enriched-approve
Body: { "id": "page_42", "status": "approved" | "rejected" | "needs_review" }
```

- **Permisos:** Usuario autenticado
- **Comportamiento:**
  - Intenta escribir en `data/assistants/rewrite/approvals.json`
  - Si readonly (staging): fallback a `wp-content/uploads/runart-jobs/enriched-approvals.log`
  - Registra usuario y timestamp

**Respuestas:**
```json
// Éxito (data/ escribible)
{
  "ok": true,
  "id": "page_42",
  "status": "approved",
  "message": "Aprobación registrada correctamente",
  "storage": "data/assistants/rewrite"
}

// Fallback (staging readonly)
{
  "ok": false,
  "status": "queued",
  "id": "page_42",
  "message": "Staging en modo solo lectura. Solicitud registrada en uploads/.",
  "storage": "uploads/runart-jobs (readonly fallback)"
}
```

#### 3. Detalle con aprobación (extendido)

```
GET /wp-json/runart/content/enriched?page_id=page_42
```

- Endpoint existente **extendido** para incluir estado de aprobación
- Agrega campo `approval` en la respuesta cuando existe

### Interfaz del Panel Editorial

- **Listado (columna izquierda):**
  - Muestra todos los contenidos enriquecidos disponibles
  - Indica ID, idioma y estado visual (Generado/Aprobado/Rechazado/Revisar)
  - Clic en item → carga detalle y resalta item seleccionado

- **Detalle (columna derecha):**
  - Headline ES/EN
  - Summary ES/EN
  - Referencias visuales con image_id, filename, score y contexto
  - Botones: ✅ Aprobar | ❌ Rechazar | 📋 Marcar revisión
  - Estado actual de aprobación con timestamp y usuario
  - Feedback visual después de cada acción

### Debugging y Validación

El panel incluye logging detallado en consola del navegador para diagnóstico:

```javascript
// Eventos registrados:
- Click en item: "Click en item, data-id = page_42"
- Carga de detalle: "loadDetail: cargando página con ID = page_42"
- URL completa: "loadDetail: URL completa = https://..."
- Respuesta: "loadDetail: respuesta del servidor = {...}"
- Aprobación: "runartApprove: id = page_42 status = approved"
- Payload: "runartApprove: payload = {id: 'page_42', status: 'approved'}"
```

**Verificación de funcionamiento:**
1. Abrir consola de desarrollador (F12)
2. Hacer click en un contenido → verificar logs de carga
3. Hacer click en botón de acción → verificar logs de POST
4. Comprobar que no aparece error "page_id parameter is required"

### Flujo de trabajo

1. Editor abre panel editorial
2. Ve listado de contenidos enriquecidos generados por F9
3. Selecciona uno para ver detalle completo
4. Revisa headlines, summaries y referencias visuales
5. Aprueba, rechaza o marca para revisión
6. Estado se guarda en `approvals.json` (o en log si staging readonly)
7. Listado se actualiza mostrando nuevo estado

### Persistencia

- **Producción/desarrollo:** Escritura directa en `data/assistants/rewrite/approvals.json`
- **Staging readonly:** Fallback a `wp-content/uploads/runart-jobs/enriched-approvals.log`
- CI puede procesar el log y actualizar el repo posteriormente
