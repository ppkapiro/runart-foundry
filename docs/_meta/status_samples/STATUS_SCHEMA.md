# Esquema status.json — RunArt Foundry

**Fuente:** `scripts/gen_status.py`  
**Ubicación:** `docs/status.json`  
**Formato:** JSON con métricas operativas del repositorio

## Estructura

```json
{
  "generated_at": "string (ISO 8601 UTC timestamp)",
  "preview_ok": "boolean (estado del endpoint de preview)",
  "prod_ok": "boolean (estado del endpoint de producción)",
  "last_ci_ref": "string (commit hash completo del último CI run)",
  "docs_live_count": "integer (número de archivos .md en docs/live/)",
  "archive_count": "integer (número de archivos .md en docs/archive/)"
}
```

## Descripción de campos

| Campo | Tipo | Descripción | Ejemplo |
|-------|------|-------------|---------|
| `generated_at` | `string` | Timestamp UTC de generación (ISO 8601) | `"2025-10-23T21:58:56.920849+00:00"` |
| `preview_ok` | `boolean` | Estado del endpoint de preview (TODO: detectar automáticamente) | `true` |
| `prod_ok` | `boolean` | Estado del endpoint de producción (TODO: detectar automáticamente) | `true` |
| `last_ci_ref` | `string` | Hash SHA-1 completo del último commit procesado por CI | `"3ec7926a7d1f8a29dca267abf29a2388f204dde8"` |
| `docs_live_count` | `integer` | Cantidad de documentos Markdown en `docs/live/` (recursivo) | `6` |
| `archive_count` | `integer` | Cantidad de documentos Markdown en `docs/archive/` (recursivo) | `1` |

## Ejemplo real

```json
{
  "generated_at": "2025-10-23T21:58:56.920849+00:00",
  "preview_ok": true,
  "prod_ok": true,
  "last_ci_ref": "3ec7926a7d1f8a29dca267abf29a2388f204dde8",
  "docs_live_count": 6,
  "archive_count": 1
}
```

## Extensiones futuras

### Propuestas para v2 del esquema

- **CI metrics:** `ci_last_run_date`, `ci_success_rate_7d`, `ci_avg_duration_ms`
- **Stale tracking:** `stale_docs_count`, `stale_docs_list: [{ path, updated, owner }]`
- **Link health:** `broken_links_count`, `external_links_checked`, `external_links_failed`
- **Tag analytics:** `unique_tags_count`, `most_used_tags: [{tag, count}]`
- **Ownership:** `docs_by_owner: {owner: count}`, `orphaned_docs_count`
- **Validator stats:** `last_strict_validation: {errors, warnings, timestamp}`

### Compatibilidad

Extensiones deben añadirse sin romper lectores existentes:
- Campos nuevos **opcionales** (con defaults sensibles)
- Tipos primitivos o estructuras simples (evitar nested profundo)
- Versionado explícito con campo `schema_version: "1.0"`

## Uso en integración Briefing

El esquema actual es suficiente para PoC inicial con MkDocs macros:

```jinja
{% set status = load_json('docs/status.json') %}

## KPIs Operativos

- **Documentos activos:** {{ status.docs_live_count }}
- **Documentos archivados:** {{ status.archive_count }}
- **Último commit CI:** `{{ status.last_ci_ref[:8] }}`
- **Generado:** {{ status.generated_at }}
```

Para publicaciones automatizadas, se puede extender con commits recientes:

```python
# tools/commits_to_posts.py
def get_recent_commits(since_hours=24):
    # git log --since="24 hours ago" --pretty=format:'{...}'
    # Extraer: hash, author, date, message, files_changed
    pass
```

---

**Fecha:** 2025-10-23T22:00:00Z  
**Commit:** (pendiente de PR)  
**Autor:** GitHub Copilot (Briefing Status Integration Research)
