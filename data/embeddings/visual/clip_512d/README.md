# Visual Embeddings — CLIP ViT-B/32 (512D)

**Modelo:** `clip-vit-base-patch32` via Sentence-Transformers  
**Dimensiones:** 512  
**Generado por:** `apps/runmedia/runmedia/vision_analyzer.py`

---

## Estructura

- **index.json** — Índice maestro con metadatos de todas las imágenes procesadas
- **embeddings/** — Archivos JSON individuales por imagen (formato: `{image_id}.json`)

---

## Formato de Embedding

```json
{
  "id": "abc123def456",
  "source": {
    "path": "content/media/bronze-sculpture.jpg",
    "filename": "bronze-sculpture.jpg",
    "checksum_sha256": "d4a5e6f7c8b9a0e1f2d3c4b5a6e7d8c9"
  },
  "model": {
    "name": "clip-vit-base-patch32",
    "version": "2.7.0",
    "dimensions": 512
  },
  "embedding": [
    0.123456, -0.234567, 0.345678, ...
  ],
  "metadata": {
    "width": 1920,
    "height": 1080,
    "format": "JPEG",
    "generated_at": "2025-11-05T10:30:00Z"
  }
}
```

---

## Generación

```bash
python apps/runmedia/runmedia/vision_analyzer.py \
  --image-dir content/media/ \
  --output-dir data/embeddings/visual/clip_512d/embeddings/
```

---

**Última actualización:** 2025-10-30 (F7)
