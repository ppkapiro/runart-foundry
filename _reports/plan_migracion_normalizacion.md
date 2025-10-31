# Plan — Migración y normalización del dataset real (Opción B preparada)

Fecha: 2025-10-31
Autor: automation-runart
Ámbito: Transformar el dataset real a formato canónico consumible por el plugin unificado.

## 1) Supuestos y objetivos

- Supuesto: el dataset real existe como `index.json` + `page_*.json` bajo `uploads/runart-jobs/enriched/` o en una ruta similar.
- Objetivo: producir un `index.json` canónico y `page_*.json` compatibles con el panel/REST actuales.

## 2) Detección de formato (dialectos)

Al cargar el índice fuente (`source_index`):
- Si contiene `pages[]` con `page_id`, `lang`, `title`, `visual_references_count` → compatible directo.
- Si contiene claves alternas (p. ej. `items[]`, `id`, `locale`, `name`, `images[]`) → mapear a canónico:
  - `page_id` ← `id|slug`
  - `lang` ← `lang|locale|language`
  - `title` ← `title|name`
  - `visual_references_count` ← longitud de `visual_references|images|media`

## 3) Transformación

Pseudocódigo:

```
load source_index
pages = []
for item in source_index[items|pages]:
  pid = item[id|slug]
  lang = item[lang|locale]
  title = item[title|name]
  vr_count = len(item[visual_references|images] or [])
  pages.append({page_id: pid, lang, title, visual_references_count: vr_count})

write canonical index.json { version, generated_at, total_pages: len(pages), pages }

for pid in pages:
  src = load source_page(pid)
  out = {
    id: pid,
    lang: src[lang|locale],
    enriched_es: src.get('enriched_es'),
    enriched_en: src.get('enriched_en'),
    visual_references: normalize_refs(src[visual_references|images])
  }
  write page_{pid}.json
```

`normalize_refs()` debe mapear a:
- `{ image_id?, attachment_id?, filename?, url?, alt?, role?, score? }`

## 4) Validación

- Checksums: SHA‑256 del `index.json` y conteo de páginas.
- Esquema: validar claves mínimas (`page_id`, `lang`, `title`) y tipos.
- Muestreo manual: abrir 3 páginas al azar y revisar `visual_references`.

## 5) Publicación (activación)

- Ubicación preferida de lectura: mantener la cascada y añadir `uploads/runart-jobs/enriched/index.json` como origen (read‑only).
- Feature flag simple (constante/option) para activar la nueva ruta y rollback inmediato si hay inconsistencias.

## 6) Backups y reversibilidad

- Antes de activar lectura nueva: snapshot de la ruta canónica anterior (ZIP + checksum) a `_artifacts/`.
- Registrar en `_reports/` un `ACTIVACION_DATASET_REAL_YYYYMMDD.md` con hash y métricas (total_pages, campos opcionales).

## 7) Scripts sugeridos

- `tools/normalize_enriched_dataset.py` (propuesto):
  - Args: `--source /path/to/uploads/runart-jobs/enriched` `--target data/assistants/rewrite` `--dry-run` `--limit N`.
  - Salida: índice canónico y páginas normalizadas listas para consumo o comparación.

## 8) Controles post‑activación

- Re‑ejecutar `GET /wp-json/runart/content/enriched-list` y validar `total_pages` esperado.
- Alinear embeddings y correlaciones si hay nuevas páginas.
