# Text Embeddings — Multilingual MPNet (768D)

**Modelo:** `paraphrase-multilingual-mpnet-base-v2` via Sentence-Transformers  
**Dimensiones:** 768  
**Idiomas soportados:** ES, EN (y 50+ más)  
**Generado por:** `apps/runmedia/runmedia/text_encoder.py`

---

## Estructura

- **index.json** — Índice maestro con metadatos de todas las páginas procesadas
- **embeddings/** — Archivos JSON individuales por página (formato: `page_{id}.json`)

---

## Formato de Embedding

```json
{
  "id": "page_42",
  "source": {
    "page_id": 42,
    "title": "Lost-Wax Bronze Casting Technique",
    "language": "en",
    "word_count": 850,
    "url": "https://runartfoundry.com/bronze-casting/"
  },
  "model": {
    "name": "paraphrase-multilingual-mpnet-base-v2",
    "version": "2.7.0",
    "dimensions": 768
  },
  "embedding": [
    0.789012, -0.234567, 0.456789, ...
  ],
  "metadata": {
    "generated_at": "2025-11-05T10:32:00Z",
    "content_preview": "The lost-wax process, also known as..."
  }
}
```

---

## Generación

```bash
python apps/runmedia/runmedia/text_encoder.py \
  --wp-json-url https://runartfoundry.com/wp-json/runart/audit/pages \
  --output-dir data/embeddings/text/multilingual_mpnet/embeddings/
```

---

**Última actualización:** 2025-10-30 (F7)
