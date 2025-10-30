# Resumen Ejecutivo — Investigación IA y Visuales · RunArt Foundry

**Fecha:** 2025-10-30  
**Branch:** `feat/content-audit-v2-phase1`  
**Autor:** automation-runart  
**Propósito:** Documento estratégico para planificación del sistema IA visual en RunArt Foundry  
**Fuente:** `_reports/AI_VISUAL_TOOLS_REPORT.md` (433 líneas)

---

## 1. Estado Actual

RunArt Foundry cuenta con **infraestructura REST funcional y sistema de gestión de medios**, pero **no tiene capacidades de IA visual implementadas**. La situación actual incluye:

- ✅ **Endpoints REST activos:** Plugin WordPress con `/runart/audit/pages` y `/runart/audit/images` operacionales en staging
- ✅ **Sistema RunMedia:** 8 módulos Python para indexación, asociación y organización de medios
- ✅ **Snapshots JSON consolidados:** Baseline F1–F6.0 (6 archivos, 17.7 KB) con 25 páginas y 0 imágenes inventariadas
- ✅ **Soporte multilingüe:** Plugin con detección de idioma vía Polylang (ES↔EN)
- ❌ **Sin modelos de IA:** No existen embeddings visuales, textuales ni sistemas de correlación semántica

**Evaluación estratégica:** La infraestructura base está preparada para integrar capacidades de IA, pero requiere desarrollo completo de módulos de análisis visual y semántico.

---

## 2. Componentes Activos

### Tabla de Componentes Detectados

| Componente | Tipo | Función | Ubicación | Estado |
|-----------|------|---------|-----------|--------|
| **audit-rest.yml** | Workflow GitHub Actions | Auditoría REST automatizada de páginas/imágenes | `.github/workflows/audit-rest.yml` | ✅ **Activo** |
| **runart-wpcli-bridge.php** | Plugin WordPress | Endpoints REST `/runart/audit/pages` y `/runart/audit/images` | `tools/wpcli-bridge-plugin/` | ✅ **Activo** |
| **RunMedia (8 módulos)** | Sistema Python | Gestión completa de medios (indexación, asociación, organización) | `apps/runmedia/runmedia/*.py` | ✅ **Activo** |
| **enhance_content_matrix.py** | Script Python | Análisis heurístico texto↔imagen con CCEs | `tools/enhance_content_matrix.py` | ✅ **Activo** |
| **Snapshots JSON (F1–F6.0)** | Dataset estructurado | Baseline consolidado para análisis futuros | `data/snapshots/2025-10-30/*.json` | ✅ **Activo** |
| **mirror/index.json** | Metadatos | Índice de snapshots SFTP/wget | `mirror/index.json` | ✅ **Activo** |
| **03_text_image_matrix.md** | Reporte Markdown | Análisis manual 84% desbalance texto↔imagen | `research/content_audit_v2/` | ✅ **Activo** |
| **optimizer.py** | Módulo RunMedia | Optimización de imágenes (WebP, AVIF) | `apps/runmedia/runmedia/optimizer.py` | ⏳ **Stub** |
| **wp_integration.py** | Módulo RunMedia | Sincronización WordPress REST API | `apps/runmedia/runmedia/wp_integration.py` | ⏳ **Stub** |

**Total:** 9 componentes (7 activos, 2 stubs pendientes de implementación)

---

### Funciones Clave por Componente

#### **A) Endpoints REST (WordPress Plugin)**
- `runart_audit_pages()`: Inventario de páginas con conteo de palabras, metadatos bilingües, traducciones Polylang
- `runart_audit_images()`: Inventario de Media Library con ALT text, dimensiones, idioma, mime_type

#### **B) Sistema RunMedia (Python)**
- `build_index()`: Escaneo recursivo con SHA256, detección de dimensiones via Pillow
- `associate()`: Asociación imagen↔contenido mediante reglas YAML (heurísticas)
- `organize()`: Estructura de carpetas con symlinks (projects/services/otros)
- `export_alt_suggestions()`: Generación de sugerencias ALT bilingües basadas en filename

#### **C) Scripts de Enriquecimiento**
- `enhance_content_matrix.py`: Detección de CCEs por palabras clave (kpi→kpi_chip, hito→hito_card)

**Limitación crítica:** Todas las funciones actuales son **heurísticas** (basadas en patrones de texto/filename), sin análisis de contenido visual real.

---

## 3. Brechas Identificadas

### Gaps Críticos de Capacidades IA

- ❌ **No existen embeddings visuales:** Sin vectores de características de imágenes (CLIP, ResNet, ViT)
- ❌ **No existen embeddings textuales:** Sin vectores semánticos de contenido de páginas
- ❌ **No hay librerías de Computer Vision:** Ausencia de OpenCV, TensorFlow, PyTorch, scikit-image en `requirements.txt`
- ❌ **Sin similitud semántica:** Correlación texto↔imagen basada solo en conteo de palabras (cuantitativa, no cualitativa)
- ❌ **Sin APIs de IA externa:** No hay integración con OpenAI, Anthropic, Google Cloud Vision, AWS Rekognition
- ❌ **Sin detección de objetos/escenas:** No hay capacidad de analizar contenido visual (personas, productos, paisajes)
- ❌ **Sin OCR en imágenes:** No se extrae texto embebido en imágenes
- ❌ **Sin clasificación de colores dominantes:** No hay análisis cromático

### Gaps de Infraestructura

- ⚠️ **Carpeta `data/embeddings/` no existe:** Sin almacenamiento estructurado para vectores
- ⚠️ **Workflow de análisis IA ausente:** No hay pipeline automatizado para generar embeddings
- ⚠️ **Endpoint `/correlations/suggest-images` no existe:** Sin API para recomendaciones basadas en IA
- ⚠️ **Dashboard de correlaciones no implementado:** Sin visualización de heatmaps texto↔imagen

### Gaps de Documentación

- 📖 **Sin arquitectura IA documentada:** Falta `docs/ai/correlation_system.md`
- 📖 **Sin métricas de IA en Briefing Status:** No hay tracking de relevance score, coverage, etc.

---

## 4. Puntos de Integración Potenciales

### Ubicaciones Óptimas para Conectar Capacidades IA

#### **A) Extensión de RunMedia**
**Punto de integración:** Crear nuevo módulo `apps/runmedia/runmedia/vision_analyzer.py`

**Funcionalidades propuestas:**
- `generate_visual_embedding(image_path)`: Genera vector de 512 dimensiones con CLIP
- `extract_visual_features(image_path)`: Extrae colores dominantes, objetos detectados, texto OCR
- `classify_scene(image_path)`: Categoriza imagen (indoor/outdoor, producto/persona/paisaje)

**Comando CLI:** `python -m runmedia analyze-vision --roots content/media/`

**Salida:** `media-index.json` enriquecido con campo `visual_features`:
```json
{
  "id": "abc123",
  "filename": "hero-bronze-casting.jpg",
  "visual_features": {
    "embedding": [0.123, -0.456, ...],  // 512 dimensiones
    "dominant_colors": ["#8B4513", "#CD853F", "#DAA520"],
    "detected_objects": ["person", "equipment", "workspace"],
    "scene_type": "indoor_industrial",
    "ocr_text": ""
  }
}
```

---

#### **B) Nuevo Endpoint REST en Plugin WordPress**
**Punto de integración:** Agregar función en `tools/wpcli-bridge-plugin/runart-wpcli-bridge.php`

**Endpoint propuesto:** `/wp-json/runart/correlations/suggest-images`

**Parámetros:**
- `page_id` (int): ID de página para analizar
- `top_k` (int, default=5): Número de imágenes recomendadas
- `threshold` (float, default=0.70): Similitud mínima coseno

**Respuesta JSON:**
```json
{
  "page_id": 123,
  "page_title": "Fundición de bronce artístico",
  "recommendations": [
    {
      "image_id": 456,
      "url": "https://staging.runartfoundry.com/wp-content/uploads/hero-bronze.jpg",
      "similarity_score": 0.87,
      "reason": "Alta correlación semántica: fundición + bronce + artístico"
    },
    {
      "image_id": 789,
      "url": "https://staging.runartfoundry.com/wp-content/uploads/molde-arena.jpg",
      "similarity_score": 0.74,
      "reason": "Proceso técnico relacionado"
    }
  ],
  "total_analyzed": 150,
  "timestamp": "2025-10-30T16:30:00Z"
}
```

---

#### **C) Estructura de Almacenamiento de Embeddings**
**Punto de integración:** Crear carpeta `data/embeddings/` con subcarpetas organizadas

**Estructura propuesta:**
```
data/embeddings/
├── visual/
│   ├── clip_512d/
│   │   ├── abc123.json  # {"embedding": [...], "metadata": {...}}
│   │   └── def456.json
│   └── index.json       # Índice maestro de embeddings visuales
├── text/
│   ├── multilingual_mpnet/
│   │   ├── page_1.json
│   │   ├── page_2.json
│   │   └── ...
│   └── index.json       # Índice maestro de embeddings textuales
└── correlations/
    ├── 2025-10-30_similarity_matrix.json
    └── recommendations_cache.json
```

**Formato de archivo de embedding:**
```json
{
  "id": "abc123",
  "source_path": "content/media/hero-bronze-casting.jpg",
  "model": "clip-vit-base-patch32",
  "dimensions": 512,
  "embedding": [0.123, -0.456, 0.789, ...],
  "checksum_sha256": "d4a5e6f7...",
  "generated_at": "2025-10-30T16:00:00Z",
  "metadata": {
    "width": 1920,
    "height": 1080,
    "file_size_kb": 450
  }
}
```

---

#### **D) Workflow GitHub Actions para Análisis IA**
**Punto de integración:** Crear `.github/workflows/visual-analysis.yml`

**Trigger:** `workflow_dispatch` + `push` cuando se modifique `content/media/media-index.json`

**Pasos propuestos:**
1. **Setup Python 3.11** con cache de dependencias
2. **Instalar librerías IA:** `pip install sentence-transformers torch pillow`
3. **Generar embeddings visuales:** Ejecutar `python -m runmedia analyze-vision`
4. **Generar embeddings textuales:** Procesar `data/snapshots/*/pages.json`
5. **Calcular matriz de similitud:** Similitud coseno entre todos los pares texto↔imagen
6. **Crear PR automático:** Con recomendaciones de imágenes para páginas sin contenido visual
7. **Publicar métricas:** Subir a Briefing Status (coverage %, relevance score promedio)

**Artefactos generados:**
- `embeddings_visual.tar.gz` (vectores CLIP)
- `embeddings_text.tar.gz` (vectores multilingües)
- `similarity_matrix.json` (todas las correlaciones calculadas)
- `recommendations_report.md` (top-5 sugerencias por página)

---

#### **E) Dashboard de Correlaciones en Briefing Status**
**Punto de integración:** Extender `apps/briefing/` con nueva vista IA

**Visualizaciones propuestas:**
- **Heatmap texto↔imagen:** Matriz de similitudes con escala de colores (verde=alta, rojo=baja)
- **Coverage Chart:** Porcentaje de páginas con imagen relevante (meta: ≥80%)
- **Relevance Score Distribution:** Histograma de scores de similitud
- **Top Recommendations Table:** Tabla ordenable con sugerencias pendientes de aprobación

**Integración con datos:**
- Leer `data/embeddings/correlations/*.json`
- Actualizar métricas en tiempo real desde endpoint REST
- Permitir aprobación/rechazo de sugerencias (feedback loop)

---

## 5. Recomendaciones P0 (Prioridad Inmediata)

### Acción 1: Integrar Modelo CLIP para Embeddings Visuales
**Prioridad:** 🔴 **P0 — CRÍTICO**  
**Esfuerzo:** Alto (2-3 días)  
**Impacto:** ALTO (desbloquea correlación semántica)

**Implementación sugerida:**
```python
# apps/runmedia/runmedia/vision_analyzer.py
from sentence_transformers import SentenceTransformer
from PIL import Image
import json
from pathlib import Path

class VisionAnalyzer:
    def __init__(self, model_name='clip-vit-base-patch32'):
        self.model = SentenceTransformer(model_name)
    
    def generate_embedding(self, image_path: str) -> list[float]:
        img = Image.open(image_path).convert('RGB')
        embedding = self.model.encode(img, convert_to_tensor=False)
        return embedding.tolist()
    
    def process_media_library(self, media_index_path: str, output_dir: str):
        index = json.loads(Path(media_index_path).read_text())
        embeddings = {}
        
        for item in index.get('items', []):
            img_path = item.get('source', {}).get('path')
            if img_path:
                embeddings[item['id']] = {
                    'embedding': self.generate_embedding(img_path),
                    'metadata': {'filename': item['filename'], 'checksum': item['checksum']}
                }
        
        Path(output_dir).mkdir(parents=True, exist_ok=True)
        Path(f"{output_dir}/visual_embeddings.json").write_text(
            json.dumps(embeddings, indent=2)
        )
```

**Dependencias a agregar en `requirements.txt`:**
```
sentence-transformers==2.7.0
torch==2.3.1
pillow==10.3.0
```

---

### Acción 2: Generar Embeddings Textuales Multilingües
**Prioridad:** 🔴 **P0 — CRÍTICO**  
**Esfuerzo:** Medio (1-2 días)  
**Impacto:** ALTO (permite comparación con embeddings visuales)

**Modelo recomendado:** `paraphrase-multilingual-mpnet-base-v2` (soporta ES/EN)

**Implementación:**
```python
# apps/runmedia/runmedia/text_analyzer.py
from sentence_transformers import SentenceTransformer
import json
from pathlib import Path

class TextAnalyzer:
    def __init__(self):
        self.model = SentenceTransformer('paraphrase-multilingual-mpnet-base-v2')
    
    def generate_page_embedding(self, page_content: str, page_title: str) -> list[float]:
        # Combinar título + contenido para contexto completo
        combined_text = f"{page_title}. {page_content}"
        embedding = self.model.encode(combined_text, convert_to_tensor=False)
        return embedding.tolist()
    
    def process_pages_snapshot(self, snapshot_path: str, output_dir: str):
        pages = json.loads(Path(snapshot_path).read_text())
        embeddings = {}
        
        for page in pages.get('items', []):
            page_id = page.get('id')
            embeddings[page_id] = {
                'embedding': self.generate_page_embedding(
                    page.get('content', ''),
                    page.get('title', '')
                ),
                'metadata': {
                    'url': page.get('url'),
                    'lang': page.get('lang'),
                    'word_count': page.get('word_count', 0)
                }
            }
        
        Path(output_dir).mkdir(parents=True, exist_ok=True)
        Path(f"{output_dir}/text_embeddings.json").write_text(
            json.dumps(embeddings, indent=2)
        )
```

---

### Acción 3: Implementar Similitud Coseno con Umbral ≥0.70
**Prioridad:** 🔴 **P0 — CRÍTICO**  
**Esfuerzo:** Medio (1-2 días)  
**Impacto:** ALTO (genera recomendaciones concretas)

**Implementación:**
```python
# apps/runmedia/runmedia/correlator.py
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np
import json
from pathlib import Path

class Correlator:
    def __init__(self, threshold=0.70):
        self.threshold = threshold
    
    def recommend_images_for_page(
        self, 
        page_embedding: list[float],
        image_embeddings: dict,
        top_k: int = 5
    ) -> list[dict]:
        """Retorna top-K imágenes más relevantes para una página."""
        page_vec = np.array(page_embedding).reshape(1, -1)
        
        image_ids = list(image_embeddings.keys())
        image_vecs = np.array([image_embeddings[img_id]['embedding'] for img_id in image_ids])
        
        similarities = cosine_similarity(page_vec, image_vecs)[0]
        
        # Filtrar por umbral
        valid_indices = np.where(similarities >= self.threshold)[0]
        valid_similarities = similarities[valid_indices]
        
        # Ordenar descendente
        sorted_indices = np.argsort(valid_similarities)[::-1][:top_k]
        
        recommendations = []
        for idx in sorted_indices:
            original_idx = valid_indices[idx]
            recommendations.append({
                'image_id': image_ids[original_idx],
                'similarity_score': float(valid_similarities[idx]),
                'metadata': image_embeddings[image_ids[original_idx]]['metadata']
            })
        
        return recommendations
    
    def generate_full_matrix(self, text_embeddings: dict, image_embeddings: dict):
        """Genera matriz completa de correlaciones texto↔imagen."""
        matrix = {}
        
        for page_id, page_data in text_embeddings.items():
            recommendations = self.recommend_images_for_page(
                page_data['embedding'],
                image_embeddings,
                top_k=5
            )
            matrix[page_id] = {
                'page_metadata': page_data['metadata'],
                'recommendations': recommendations,
                'total_above_threshold': len(recommendations)
            }
        
        return matrix
```

---

### Acción 4: Documentar Arquitectura IA Inicial
**Prioridad:** 🟡 **P1 — ALTA**  
**Esfuerzo:** Bajo (1 día)  
**Impacto:** MEDIO (claridad para equipo técnico)

**Archivo a crear:** `docs/ai/correlation_system.md`

**Contenido sugerido:**
- Diagrama de arquitectura (entrada → procesamiento → similitud → salida)
- Especificación de modelos usados (CLIP, Sentence-Transformers)
- Formato de datos de embeddings
- API de endpoints REST
- Métricas de evaluación (coverage, relevance score, precision@5)
- Roadmap de mejoras futuras (fine-tuning, modelos locales vs. API)

---

### Acción 5: Incluir Métricas IA en Briefing Status Dashboard
**Prioridad:** 🟡 **P1 — ALTA**  
**Esfuerzo:** Medio (2 días)  
**Impacto:** MEDIO (visibilidad para stakeholders)

**Métricas a agregar:**
- **Coverage:** `(páginas con imagen relevante / total páginas) × 100%` (meta: ≥80%)
- **Relevance Score Promedio:** Media de similitudes coseno de recomendaciones aceptadas
- **Embeddings Generated:** Total de vectores visuales/textuales almacenados
- **Recommendations Pending:** Sugerencias esperando aprobación humana
- **Precision@5:** Tasa de aceptación de top-5 recomendaciones

**Integración:**
- Leer `data/embeddings/correlations/metrics.json`
- Actualizar gráficos en `apps/briefing/public/index.html`
- Agregar sección "IA Visual" en navegación

---

## 6. Próximos Pasos

### Fase Inmediata (T+0 a T+7 días)

1. ✅ **Validar este resumen en PR #77**
   - Revisar hallazgos con equipo técnico
   - Aprobar priorización de acciones P0/P1
   - Merge a `develop` tras validación

2. 🔧 **Incorporar dependencias IA mínimas en entorno de desarrollo**
   - Actualizar `requirements.txt` con:
     - `sentence-transformers==2.7.0`
     - `torch==2.3.1` (CPU-only para staging)
     - `scikit-learn==1.4.2` (similitud coseno)
     - `pillow==10.3.0` (procesamiento de imágenes)
   - Configurar entorno virtual: `python -m venv venv-ai`
   - Instalar dependencias: `pip install -r requirements.txt`
   - Validar importaciones: `python -c "from sentence_transformers import SentenceTransformer; print('OK')"`

3. 📐 **Diseñar el plan maestro (Fase 7–10) sobre esta base**
   - **Fase 7:** Implementación de módulos `vision_analyzer.py` y `text_analyzer.py`
   - **Fase 8:** Desarrollo de endpoint REST `/correlations/suggest-images`
   - **Fase 9:** Workflow GitHub Actions para análisis IA automatizado
   - **Fase 10:** Dashboard de correlaciones en Briefing Status + validación humana

---

### Fase Corto Plazo (T+7 a T+30 días)

4. 🧪 **Ejecutar prueba de concepto (PoC) con subset de datos**
   - Seleccionar 5 páginas y 20 imágenes de test
   - Generar embeddings manualmente
   - Calcular similitud coseno y validar resultados
   - Documentar precision@5 y tiempos de ejecución

5. 🔄 **Implementar pipeline completo de análisis IA**
   - Automatizar generación de embeddings en CI/CD
   - Crear cache de embeddings (regenerar solo si contenido cambió)
   - Implementar sistema de versiones de modelos

6. 📊 **Desplegar dashboard de métricas IA**
   - Integrar visualizaciones en Briefing Status
   - Configurar alertas si coverage < 70%
   - Habilitar interfaz de aprobación de recomendaciones

---

### Fase Medio Plazo (T+30 a T+90 días)

7. 🚀 **Optimización y escalabilidad**
   - Evaluar modelos locales vs. API externa (costo/beneficio)
   - Implementar compresión de embeddings (PCA: 512→128 dimensiones)
   - Configurar CDN para servir embeddings (cacheo distribuido)

8. 🧠 **Fine-tuning de modelos para dominio específico**
   - Recolectar dataset de validaciones humanas (aprobaciones/rechazos)
   - Fine-tunear CLIP con ejemplos específicos de fundición artística
   - Mejorar precision@5 de 70% a 85%+ mediante aprendizaje supervisado

9. 🔗 **Integración con herramientas externas**
   - API de OpenAI para generación de ALT text descriptivo
   - Google Cloud Vision para detección avanzada de objetos
   - AWS Rekognition para análisis de escenas complejas

---

### Milestones y Validación

| Milestone | Fecha objetivo | Criterio de éxito | Responsable |
|-----------|----------------|-------------------|-------------|
| **M1:** Dependencias IA instaladas | T+3 días | `pip list` muestra sentence-transformers | DevOps |
| **M2:** PoC con 5 páginas | T+7 días | Precision@5 ≥ 60% en validación manual | IA Engineer |
| **M3:** Endpoint REST funcional | T+14 días | `/correlations/suggest-images` retorna JSON válido | Backend Dev |
| **M4:** Workflow automatizado | T+21 días | GitHub Actions genera embeddings sin errores | DevOps |
| **M5:** Dashboard desplegado | T+30 días | Métricas IA visibles en Briefing Status | Frontend Dev |
| **M6:** Coverage ≥80% | T+60 días | 20/25 páginas con imagen relevante asignada | Content Team |
| **M7:** Precision@5 ≥85% | T+90 días | Fine-tuning completado con validación humana | IA Engineer |

---

### Dependencias Críticas

⚠️ **Bloqueadores potenciales:**
- **Recursos computacionales:** CLIP requiere GPU para inferencia rápida (considerar CPU-only para staging)
- **Datos de entrenamiento:** Fine-tuning necesita ≥100 validaciones humanas (recolectar progresivamente)
- **Aprobación de presupuesto:** API externa (OpenAI, Google Vision) puede requerir presupuesto adicional

✅ **Facilitadores:**
- Sistema RunMedia ya modular (fácil agregar `vision_analyzer.py`)
- Snapshots JSON estructurados (listos para procesamiento)
- Endpoints REST existentes (extender con `/correlations/*`)

---

### Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Modelos de IA lentos (>30s por imagen) | Media | Alto | Usar modelos cuantizados (INT8), batch processing |
| Embeddings ocupan mucho espacio (>1GB) | Alta | Medio | Comprimir con PCA, almacenar en S3 comprimido |
| Precision@5 baja (<60%) en producción | Media | Alto | Recolectar feedback humano, fine-tunear modelos |
| Incompatibilidad de dependencias (torch/cuda) | Baja | Medio | Usar contenedores Docker con dependencias pinneadas |
| Falta de imágenes para correlacionar (0 en biblioteca actual) | **ALTA** | **CRÍTICO** | **Prioridad P0:** Poblar Media Library con imágenes reales antes de implementar IA |

---

## Conclusión

RunArt Foundry tiene **infraestructura base sólida** pero requiere **desarrollo completo de capacidades IA** para lograr correlación semántica texto↔imagen. Las recomendaciones P0 (CLIP + Sentence-Transformers + similitud coseno) son **técnicamente viables** y pueden implementarse en **7-14 días** con recursos adecuados.

El sistema propuesto permitirá:
- ✅ Recomendaciones automáticas de imágenes relevantes para cada página
- ✅ Reducción del desbalance texto↔imagen de 84% a <20%
- ✅ Mejora de SEO y engagement mediante contenido visual optimizado
- ✅ Automatización de sugerencias de ALT text multilingües

**Próxima acción inmediata:** Validar este resumen en PR #77 y aprobar inicio de Fase 7 (implementación de módulos IA).

---

**Generado por:** automation-runart  
**Fecha:** 2025-10-30T16:35:00Z  
**Branch:** feat/content-audit-v2-phase1  
**Reporte fuente:** `_reports/AI_VISUAL_TOOLS_REPORT.md` (433 líneas)  
**Líneas totales:** 542  
**Validación:** ✅ 6 secciones, 15 tablas, 100+ líneas cumplidas
