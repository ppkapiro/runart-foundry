# Embeddings Storage — RunArt IA-Visual

**Propósito:** Almacenamiento centralizado de embeddings generados por modelos de IA para correlación semántica texto↔imagen.

**Estructura:**

```
embeddings/
├── visual/               # Embeddings de imágenes
│   └── clip_512d/       # CLIP ViT-B/32 (512 dimensiones)
│       ├── index.json   # Índice maestro de embeddings visuales
│       └── embeddings/  # Archivos JSON individuales por imagen
├── text/                # Embeddings de texto
│   └── multilingual_mpnet/  # Sentence-Transformers multilingual (768 dims)
│       ├── index.json   # Índice maestro de embeddings textuales
│       └── embeddings/  # Archivos JSON individuales por página
└── correlations/        # Matrices de similitud y recomendaciones
    ├── similarity_matrix.json      # Matriz completa de similitudes
    ├── recommendations_cache.json  # Cache de recomendaciones top-K
    └── validation_log.json         # Log de validaciones humanas
```

---

## Formato de Embeddings

### Visual (CLIP)
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
  "embedding": [0.123, -0.456, ...],  // 512 floats
  "metadata": {
    "width": 1920,
    "height": 1080,
    "generated_at": "2025-11-05T10:30:00Z"
  }
}
```

### Textual (Sentence-Transformers)
```json
{
  "id": "page_42",
  "source": {
    "page_id": 42,
    "title": "Lost-Wax Bronze Casting Technique",
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

## Uso

### Generar embeddings visuales
```bash
python apps/runmedia/runmedia/vision_analyzer.py --image-dir content/media/
```

### Generar embeddings textuales
```bash
python apps/runmedia/runmedia/text_encoder.py --wp-json-url https://runartfoundry.com/wp-json/runart/audit/pages
```

### Calcular correlaciones
```bash
python apps/runmedia/runmedia/correlator.py --threshold 0.70 --top-k 5
```

---

## Endpoints REST

- **GET** `/wp-json/runart/correlations/suggest-images?page_id=42&top_k=5&threshold=0.70`
- **POST** `/wp-json/runart/embeddings/update` (body: `{"type":"image","ids":[123,456]}`)

---

**Generado:** 2025-10-30 (F7 — Arquitectura IA-Visual)
