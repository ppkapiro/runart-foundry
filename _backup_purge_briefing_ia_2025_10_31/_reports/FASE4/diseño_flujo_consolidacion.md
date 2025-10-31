# Diseño de Flujo de Consolidación IA-Visual
## FASE 4.D - Algoritmo y Resolución de Conflictos

**Fecha:** 2025-10-31  
**Objetivo:** Definir proceso determinístico para consolidar 5 capas de datos IA-Visual en fuente única  
**Fuente de verdad elegida:** `wp-content/runart-data/assistants/rewrite/`

---

## 1. Resumen del Problema

### 1.1 Estado Actual
- **5 capas** con contenido teóricamente idéntico
- **Desincronización temporal:** Capa 5 (Oct 31 11:56) vs. Capas 2-4 (Oct 30 18:45)
- **Sin mecanismo de validación:** No hay checksums ni detección automática de diferencias
- **Riesgo de conflictos:** Si dataset real llega a diferentes capas simultáneamente

### 1.2 Objetivo de Consolidación
Producir un **dataset consolidado único** en capa 2 que:
1. Contenga TODAS las páginas únicas de TODAS las capas
2. Use la versión más reciente de cada página individual
3. Preserve integridad de referencias (index.json ↔ page_*.json)
4. Registre origen de cada página consolidada
5. Genere reporte de operaciones para auditoría

---

## 2. Orden de Lectura de Capas

### 2.1 Secuencia de Exploración

El algoritmo debe leer capas en este orden de prioridad:

```
1. Capa 5: tools/runart-ia-visual-unified/data/             [PRIORIDAD 1]
   └─ Razón: Versión más reciente detectada (Oct 31 11:56)

2. Capa 2: wp-content/runart-data/                          [PRIORIDAD 2]
   └─ Razón: Fuente de verdad objetivo, puede tener ediciones manuales

3. Capa 4: wp-content/plugins/runart-wpcli-bridge/data/     [PRIORIDAD 3]
   └─ Razón: Fallback de distribución plugin bridge

4. Capa 3: wp-content/uploads/runart-data/                  [PRIORIDAD 4]
   └─ Razón: Capa deprecada, solo leer si faltan datos

5. Capa 1: data/assistants/rewrite/                         [PRIORIDAD 5]
   └─ Razón: Desarrollo/Git, puede estar desactualizada vs. WordPress
```

**Justificación del orden:**
- **Capa 5 primero:** Tiene timestamp más reciente, probable versión más actualizada
- **Capa 2 segundo:** Es el objetivo final, preservar si tiene modificaciones manuales recientes
- **Resto:** Orden decreciente de confiabilidad según timestamp y propósito

### 2.2 Estrategia de Lectura

Para cada capa:
1. Verificar existencia del directorio `assistants/rewrite/`
2. Si existe, leer `index.json`
3. Validar estructura JSON (schema v1.0)
4. Extraer lista de páginas del campo `pages[]`
5. Leer cada `page_*.json` referenciado
6. Calcular checksum SHA256 de cada archivo
7. Registrar timestamp de última modificación

---

## 3. Comparación de index.json

### 3.1 Campos a Comparar

```json
{
  "version": "1.0",              // ← Debe ser igual en todas
  "generated_at": "timestamp",   // ← Usar más reciente
  "pages": [...],                // ← Unión de todos los items
  "notes": "...",                // ← Preservar más descriptivo
  "metadata": {
    "total_pages": N,            // ← Recalcular tras consolidación
    "bilingual": true/false,     // ← Detectar automáticamente
    "enrichment_source": "...",  // ← Preservar
    "visual_references": N       // ← Recalcular
  }
}
```

### 3.2 Criterios de Comparación

#### A) Por Número de Páginas

```python
def compare_by_count(indexes):
    """
    Regla: Si un index tiene MÁS páginas → marcar como "más completo"
    """
    max_pages = max(len(idx['pages']) for idx in indexes)
    most_complete = [idx for idx in indexes if len(idx['pages']) == max_pages]
    return most_complete
```

**Ejemplo:**
- Capa 5: 3 páginas (page_42, page_43, page_44)
- Capa 2: 3 páginas (page_42, page_43, page_44)
- Capa 4: 2 páginas (page_42, page_43) ← **Incompleto**

**Resultado:** Capas 5 y 2 empatan, capa 4 descartada para index base.

#### B) Por Timestamp

```python
def compare_by_timestamp(indexes):
    """
    Regla: Si hay empate en páginas, usar generated_at más reciente
    """
    return max(indexes, key=lambda idx: idx['generated_at'])
```

**Ejemplo:**
- Capa 5: `"generated_at": "2025-10-31T11:56:24Z"` ← **MÁS RECIENTE**
- Capa 2: `"generated_at": "2025-10-30T18:45:19Z"`

**Resultado:** Capa 5 gana como base para index.json consolidado.

#### C) Por Conjunto de page_id

```python
def get_all_unique_pages(indexes):
    """
    Regla: Crear conjunto UNIÓN de todos los page_id hallados
    """
    all_pages = set()
    for idx in indexes:
        all_pages.update(page['id'] for page in idx['pages'])
    return sorted(all_pages)
```

**Ejemplo:**
- Capa 5: {page_42, page_43, page_44}
- Capa 2: {page_42, page_43, page_44}
- Capa 4: {page_42, page_43}
- Capa 1: {page_42, page_43, page_44, page_45} ← **¡Contiene página extra!**

**Resultado:** Conjunto consolidado = {page_42, page_43, page_44, page_45} (4 páginas)

### 3.3 Resolución de Conflictos (index.json)

**Algoritmo de decisión:**

```
PASO 1: Filtrar por número máximo de páginas
  └─ Si solo 1 capa → Usar esa como base
  └─ Si múltiples capas → IR A PASO 2

PASO 2: Desempate por timestamp más reciente
  └─ Si solo 1 capa → Usar esa como base
  └─ Si múltiples capas (mismo timestamp) → IR A PASO 3

PASO 3: Desempate por prioridad de capa
  └─ Usar orden: Capa 5 > Capa 2 > Capa 4 > Capa 3 > Capa 1

PASO 4: Crear unión de page_id de TODAS las capas
  └─ Si hay páginas en otras capas NO presentes en base → Añadirlas

RESULTADO: index.json base + páginas adicionales halladas
```

**Ejemplo práctico:**

```
Capa 5: 3 páginas, timestamp 2025-10-31T11:56:24Z  ← GANA (más reciente)
Capa 2: 3 páginas, timestamp 2025-10-30T18:45:19Z
Capa 1: 4 páginas, timestamp 2025-10-30T14:32:38Z  ← Tiene page_45 adicional

Decisión:
  - Base: index.json de Capa 5
  - Añadir: page_45 de Capa 1 (no presente en Capa 5)
  - Resultado: 4 páginas en index consolidado
```

---

## 4. Comparación de page_*.json Individuales

### 4.1 Campos a Comparar

```json
{
  "id": "page_42",               // ← Debe coincidir con nombre archivo
  "source_text": "...",          // ← Comparar longitud
  "lang": "es",                  // ← Debe ser consistente
  "enriched_es": {...},          // ← Comparar por cantidad visual_references
  "enriched_en": {...},          // ← Comparar por cantidad visual_references
  "meta": {
    "origin": "...",             // ← Preservar origen
    "generated_at": "...",       // ← Usar más reciente
    "version": "1.0"             // ← Debe ser igual
  }
}
```

### 4.2 Criterios de Selección

#### A) Regla Primaria: Timestamp de Archivo

```python
def select_page_by_file_mtime(page_files):
    """
    Regla: Para el mismo page_id, usar el archivo con mtime más reciente
    """
    return max(page_files, key=lambda f: f.stat().st_mtime)
```

**Ejemplo:**
- Capa 5: `page_42.json` mtime=2025-10-31 11:56:24 ← **MÁS RECIENTE**
- Capa 2: `page_42.json` mtime=2025-10-30 18:45:19

**Resultado:** Usar `page_42.json` de Capa 5.

#### B) Regla Secundaria: Timestamp Interno (meta.generated_at)

Si mtimes iguales (improbable), usar `meta.generated_at`:

```python
def select_page_by_metadata(pages):
    """
    Regla: Si mtimes iguales, usar meta.generated_at más reciente
    """
    return max(pages, key=lambda p: p['meta']['generated_at'])
```

#### C) Regla Terciaria: Cantidad de Referencias Visuales

Si timestamps iguales, usar página con MÁS referencias visuales:

```python
def count_visual_refs(page):
    """
    Contar visual_references en enriched_es + enriched_en
    """
    refs_es = len(page.get('enriched_es', {}).get('visual_references', []))
    refs_en = len(page.get('enriched_en', {}).get('visual_references', []))
    return refs_es + refs_en

def select_page_by_content(pages):
    """
    Regla: Usar página con más referencias visuales (más enriquecida)
    """
    return max(pages, key=count_visual_refs)
```

**Ejemplo:**
- Capa 5 page_42: 1 ref visual (ES) + 1 ref visual (EN) = 2 total
- Capa 2 page_42: 1 ref visual (ES) + 1 ref visual (EN) = 2 total ← **EMPATE**
- Capa 1 page_42: 2 refs visuales (ES) + 2 refs visuales (EN) = 4 total ← **MÁS ENRIQUECIDA**

**Resultado:** Usar page_42 de Capa 1 (si empatan en timestamp).

#### D) Regla Cuaternaria: Prioridad de Capa

Si todos los criterios anteriores empatan:

```python
def select_page_by_layer_priority(pages, layer_priority):
    """
    Regla: Usar orden de prioridad de capas
    """
    # layer_priority = [5, 2, 4, 3, 1]  # Capa 5 > Capa 2 > ...
    for layer in layer_priority:
        matching = [p for p in pages if p['source_layer'] == layer]
        if matching:
            return matching[0]
```

### 4.3 Política de Páginas Faltantes

**Caso: Página referenciada en index pero NO existe archivo**

```python
def handle_missing_page(page_id, index_entry):
    """
    Regla: Si index.json referencia page_XX pero no existe page_XX.json
    """
    # 1. Buscar en TODAS las capas
    found_in_layers = search_page_in_all_layers(page_id)
    
    if found_in_layers:
        # 2. Usar el más reciente encontrado
        return select_page_by_file_mtime(found_in_layers)
    else:
        # 3. Marcar como "pending import" en reporte
        return {
            'status': 'missing',
            'page_id': page_id,
            'referenced_in': index_entry,
            'action': 'REQUIRE_MANUAL_IMPORT'
        }
```

**Ejemplo:**
```
index.json (Capa 5) referencia:
  - page_42.json ✅ Existe en Capa 5
  - page_43.json ✅ Existe en Capa 5
  - page_44.json ✅ Existe en Capa 5
  - page_45.json ❌ NO existe en Capa 5

Búsqueda en otras capas:
  - Capa 2: page_45.json ❌ NO
  - Capa 4: page_45.json ❌ NO
  - Capa 3: page_45.json ❌ NO
  - Capa 1: page_45.json ✅ SÍ (mtime 2025-10-30 14:32:38)

Decisión:
  - Copiar page_45.json de Capa 1 a dataset consolidado
  - Actualizar index.json consolidado para incluir page_45
```

---

## 5. Algoritmo Completo de Consolidación

### 5.1 Pseudocódigo

```python
def consolidate_ia_visual_data():
    """
    Proceso completo de consolidación de 5 capas → Capa 2 única
    """
    
    # FASE 1: DISCOVERY
    layers = discover_all_layers()  # [5, 2, 4, 3, 1]
    
    # FASE 2: LEER INDEX.JSON DE CADA CAPA
    indexes = []
    for layer in layers:
        index = read_index_json(layer)
        if index:
            indexes.append({
                'layer': layer,
                'data': index,
                'path': layer.path,
                'mtime': layer.mtime
            })
    
    # FASE 3: SELECCIONAR INDEX BASE
    base_index = select_base_index(indexes)
    # Aplicar algoritmo 3.3: max páginas → max timestamp → prioridad
    
    # FASE 4: CREAR CONJUNTO UNIÓN DE PAGE_IDS
    all_page_ids = get_all_unique_page_ids(indexes)
    
    # FASE 5: CONSOLIDAR CADA PÁGINA
    consolidated_pages = {}
    for page_id in all_page_ids:
        # 5.1 Buscar page_id en todas las capas
        page_files = find_page_in_all_layers(page_id, layers)
        
        if not page_files:
            # Página referenciada pero no existe en ninguna capa
            report_missing_page(page_id)
            continue
        
        # 5.2 Seleccionar versión a usar (aplicar 4.2)
        selected_page = select_best_page_version(page_files)
        # Criterios: mtime > meta.generated_at > visual_refs > layer priority
        
        # 5.3 Guardar en diccionario consolidado
        consolidated_pages[page_id] = selected_page
    
    # FASE 6: GENERAR INDEX.JSON CONSOLIDADO
    consolidated_index = generate_consolidated_index(
        base=base_index,
        pages=consolidated_pages
    )
    # Recalcular metadata.total_pages, visual_references, etc.
    
    # FASE 7: ESCRIBIR A CAPA 2 (SI --write)
    if args.write:
        target_dir = "wp-content/runart-data/assistants/rewrite/"
        
        # 7.1 Backup de capa 2 actual
        backup_current_layer_2()
        
        # 7.2 Escribir index.json
        write_json(f"{target_dir}/index.json", consolidated_index)
        
        # 7.3 Escribir cada page_*.json
        for page_id, page_data in consolidated_pages.items():
            write_json(f"{target_dir}/{page_id}.json", page_data)
    
    # FASE 8: GENERAR REPORTE
    report = generate_consolidation_report(
        layers_scanned=layers,
        base_index_source=base_index['layer'],
        pages_consolidated=len(consolidated_pages),
        pages_missing=[...],
        checksums={...},
        timestamps={...}
    )
    
    write_json("/_reports/FASE4/consolidacion_resultados.json", report)
    
    return report
```

### 5.2 Estructura del Reporte

```json
{
  "consolidation_timestamp": "2025-10-31T15:00:00Z",
  "operation": "consolidate",
  "mode": "write",
  "layers_scanned": [
    {
      "layer_id": 5,
      "path": "tools/runart-ia-visual-unified/data/assistants/rewrite/",
      "status": "present",
      "index_found": true,
      "pages_found": 3,
      "mtime": "2025-10-31T11:56:24Z"
    },
    {
      "layer_id": 2,
      "path": "wp-content/runart-data/assistants/rewrite/",
      "status": "present",
      "index_found": true,
      "pages_found": 3,
      "mtime": "2025-10-30T18:45:19Z"
    }
    // ... resto de capas
  ],
  "consolidation_decisions": {
    "base_index": {
      "source_layer": 5,
      "reason": "most_recent_timestamp",
      "timestamp": "2025-10-31T11:56:24Z"
    },
    "pages": {
      "page_42": {
        "source_layer": 5,
        "reason": "most_recent_mtime",
        "mtime": "2025-10-31 11:56:24",
        "checksum": "a1b2c3d4..."
      },
      "page_43": {
        "source_layer": 5,
        "reason": "most_recent_mtime",
        "mtime": "2025-10-31 11:56:24",
        "checksum": "e5f6g7h8..."
      },
      "page_44": {
        "source_layer": 5,
        "reason": "most_recent_mtime",
        "mtime": "2025-10-31 11:56:24",
        "checksum": "i9j0k1l2..."
      }
    }
  },
  "result": {
    "pages_consolidated": 3,
    "pages_missing": 0,
    "pages_added": 0,
    "index_updated": true,
    "target_layer": "wp-content/runart-data/assistants/rewrite/",
    "backup_created": "wp-content/uploads/runart-backups/ia-visual/20251031_150000/"
  },
  "validation": {
    "all_references_resolved": true,
    "index_pages_match_files": true,
    "checksums_valid": true
  },
  "warnings": [],
  "errors": []
}
```

---

## 6. Casos Especiales y Edge Cases

### 6.1 Caso: Dataset Real Llega de Staging

**Escenario:** Admin ejecuta `wp-json/runart/v1/export-enriched` en staging y entrega `enriched_export.json`

**Flujo:**
```bash
# Script de importación con --from-remote
python tools/consolidate_ia_visual_data.py --from-remote enriched_export.json --write
```

**Algoritmo modificado:**
1. Leer `enriched_export.json` como **Capa 0 (prioridad máxima)**
2. Validar estructura (schema, campos obligatorios)
3. Tratar como capa adicional en proceso de consolidación
4. Aplicar mismo algoritmo de selección (Capa 0 > Capa 5 > ...)
5. Escribir a Capa 2

**Política:**
- Dataset remoto SIEMPRE gana sobre capas locales (si timestamps válidos)
- Páginas en remoto NO presentes localmente → añadir
- Páginas locales NO presentes en remoto → preservar (no borrar)

### 6.2 Caso: Página Corrupta o JSON Inválido

**Escenario:** `page_42.json` en Capa 5 tiene JSON mal formado

**Manejo:**
```python
def handle_corrupted_page(page_file, error):
    """
    Regla: Si JSON inválido, buscar en siguiente capa
    """
    log_error(f"Corrupted JSON in {page_file}: {error}")
    
    # Buscar en otras capas
    alternative_sources = find_page_in_other_layers(page_file.id)
    
    if alternative_sources:
        # Usar siguiente capa válida
        return select_best_page_version(alternative_sources)
    else:
        # No hay alternativa válida
        return {
            'status': 'error',
            'page_id': page_file.id,
            'error': 'corrupted_json_no_fallback',
            'action': 'REQUIRE_MANUAL_FIX'
        }
```

### 6.3 Caso: Conflicto de Idioma

**Escenario:** Página page_42 en Capa 5 tiene `"lang": "es"`, pero en Capa 2 tiene `"lang": "en"`

**Regla de resolución:**
```python
def resolve_lang_conflict(pages):
    """
    Regla: Si lang difiere, usar el de la capa más reciente
           + marcar warning en reporte
    """
    selected = select_page_by_file_mtime(pages)
    
    langs_found = set(p['lang'] for p in pages)
    if len(langs_found) > 1:
        report_warning({
            'type': 'language_conflict',
            'page_id': selected['id'],
            'languages_found': list(langs_found),
            'selected_lang': selected['lang'],
            'reason': 'used_most_recent_version'
        })
    
    return selected
```

### 6.4 Caso: Página Solo en Capa Deprecada (Capa 3)

**Escenario:** page_99 existe SOLO en `wp-content/uploads/runart-data/` (capa deprecada)

**Decisión:**
```python
def handle_deprecated_layer_only_page(page_id):
    """
    Regla: Si página solo existe en capa deprecada, preservarla
           pero marcar warning
    """
    report_warning({
        'type': 'page_in_deprecated_layer_only',
        'page_id': page_id,
        'layer': 3,
        'action': 'preserved_with_warning',
        'recommendation': 'verify_if_intentional_or_orphan'
    })
    
    return read_page_from_layer(page_id, layer=3)
```

---

## 7. Validaciones Post-Consolidación

### 7.1 Integridad de Referencias

```python
def validate_references(consolidated_index, consolidated_pages):
    """
    Verificar que todas las páginas en index.json existen como archivos
    """
    errors = []
    
    for page_entry in consolidated_index['pages']:
        page_id = page_entry['id']
        page_file = page_entry['file']  # "page_42.json"
        
        if page_id not in consolidated_pages:
            errors.append({
                'type': 'missing_page_file',
                'page_id': page_id,
                'referenced_in': 'index.json',
                'file_expected': page_file
            })
    
    # Verificar que no hay archivos huérfanos (sin referencia en index)
    for page_id in consolidated_pages:
        if page_id not in [p['id'] for p in consolidated_index['pages']]:
            errors.append({
                'type': 'orphan_page_file',
                'page_id': page_id,
                'action': 'add_to_index_or_remove'
            })
    
    return errors
```

### 7.2 Checksums

```python
def calculate_checksums(consolidated_pages):
    """
    Generar SHA256 de cada archivo consolidado
    """
    checksums = {}
    
    for page_id, page_data in consolidated_pages.items():
        content_str = json.dumps(page_data, sort_keys=True, ensure_ascii=False)
        checksum = hashlib.sha256(content_str.encode('utf-8')).hexdigest()
        checksums[page_id] = checksum
    
    return checksums
```

### 7.3 Metadata Recalculada

```python
def recalculate_metadata(consolidated_index, consolidated_pages):
    """
    Actualizar metadata en index.json consolidado
    """
    # Total de páginas
    consolidated_index['metadata']['total_pages'] = len(consolidated_pages)
    
    # Bilingüe (detectar si hay páginas ES y EN)
    langs = set(page['lang'] for page in consolidated_pages.values())
    consolidated_index['metadata']['bilingual'] = len(langs) > 1
    
    # Total de referencias visuales
    total_refs = 0
    for page in consolidated_pages.values():
        refs_es = len(page.get('enriched_es', {}).get('visual_references', []))
        refs_en = len(page.get('enriched_en', {}).get('visual_references', []))
        total_refs += refs_es + refs_en
    
    consolidated_index['metadata']['visual_references'] = total_refs
    
    return consolidated_index
```

---

## 8. Modos de Ejecución del Script

### 8.1 Modo --dry-run (Solo Reporta)

```bash
python tools/consolidate_ia_visual_data.py --dry-run
```

**Comportamiento:**
- Lee todas las capas
- Ejecuta algoritmo de consolidación
- Genera reporte completo
- **NO escribe** ningún archivo
- **NO crea** backups
- **NO modifica** capa 2

**Salida:**
```
=== CONSOLIDATION DRY-RUN ===

Layers scanned: 5
Base index source: Layer 5 (tools/runart-ia-visual-unified/data/)
Pages to consolidate: 3

Decisions:
  - page_42.json: Use from Layer 5 (most recent mtime)
  - page_43.json: Use from Layer 5 (most recent mtime)
  - page_44.json: Use from Layer 5 (most recent mtime)

Warnings: 0
Errors: 0

Report saved to: /_reports/FASE4/consolidacion_resultados_dryrun.json

[DRY-RUN] No files were modified.
```

### 8.2 Modo --write (Escribe a Capa 2)

```bash
python tools/consolidate_ia_visual_data.py --write
```

**Comportamiento:**
- Lee todas las capas
- Ejecuta algoritmo de consolidación
- **CREA BACKUP** de capa 2 actual
- **ESCRIBE** index.json consolidado a capa 2
- **ESCRIBE** todos los page_*.json consolidados a capa 2
- Valida escrituras (checksums)
- Genera reporte final

**Confirmación interactiva:**
```
=== CONSOLIDATION WRITE MODE ===

WARNING: This will modify files in:
  wp-content/runart-data/assistants/rewrite/

Backup will be created in:
  wp-content/uploads/runart-backups/ia-visual/20251031_150000/

Proceed? [y/N]: _
```

### 8.3 Modo --from-remote (Importa Dataset Externo)

```bash
python tools/consolidate_ia_visual_data.py --from-remote enriched_export.json --write
```

**Comportamiento:**
- Lee archivo JSON remoto
- Valida estructura (schema, campos obligatorios)
- Trata como Capa 0 (prioridad máxima)
- Consolida con capas locales
- Escribe a capa 2 (si --write)

**Validaciones adicionales:**
- Verificar campos obligatorios: `version`, `pages[]`, `metadata`
- Validar que cada `page_*.json` tenga estructura correcta
- Detectar páginas corruptas o incompletas
- Reportar si dataset remoto es MENOR que local (posible error)

---

## 9. Restricciones y Precauciones

### 9.1 Restricciones Obligatorias

1. **NUNCA borrar capas originales**
   - Solo escribir a capa 2
   - Preservar capas 1, 4, 5 como estaban
   - Capa 3 solo se elimina MANUALMENTE tras validación

2. **SIEMPRE crear backup antes de escribir**
   - Backup de capa 2 completa antes de modificar
   - Nombre con timestamp: `backup_20251031_150000/`
   - Incluir en backup: index.json + todos los page_*.json

3. **NO modificar estructura de archivos existentes**
   - No cambiar nombres de archivos
   - No cambiar rutas de directorios
   - Solo actualizar contenido JSON

4. **Validar ANTES de escribir**
   - Verificar que JSON consolidado es válido
   - Verificar integridad de referencias
   - Calcular y registrar checksums

### 9.2 Precauciones Operacionales

1. **Permisos de escritura:**
   ```bash
   # Verificar antes de ejecutar
   test -w wp-content/runart-data/assistants/rewrite/ || echo "ERROR: No write permission"
   ```

2. **Espacio en disco:**
   ```bash
   # Verificar espacio suficiente para backup
   required_space=$(du -sb wp-content/runart-data/assistants/rewrite/ | cut -f1)
   available_space=$(df --output=avail -B1 wp-content/uploads/runart-backups/ | tail -1)
   [[ $available_space -gt $required_space ]] || echo "ERROR: Insufficient disk space"
   ```

3. **Proceso atómico:**
   - Escribir archivos a directorio temporal primero
   - Validar integridad en temporal
   - Mover (rename) de temporal a definitivo (operación atómica)
   - Si falla, rollback desde backup

---

## 10. Próximos Pasos

### 10.1 Implementación del Script

**Archivo:** `tools/consolidate_ia_visual_data.py`

**Estructura sugerida:**
```python
#!/usr/bin/env python3
"""
Consolidation script for IA-Visual data layers.
FASE 4.D - RunArt Foundry
"""

import argparse
import json
import hashlib
from pathlib import Path
from datetime import datetime

# Configuración
LAYERS = [
    {'id': 5, 'path': 'tools/runart-ia-visual-unified/data/assistants/rewrite'},
    {'id': 2, 'path': 'wp-content/runart-data/assistants/rewrite'},
    {'id': 4, 'path': 'wp-content/plugins/runart-wpcli-bridge/data/assistants/rewrite'},
    {'id': 3, 'path': 'wp-content/uploads/runart-data/assistants/rewrite'},
    {'id': 1, 'path': 'data/assistants/rewrite'},
]

TARGET_LAYER = 'wp-content/runart-data/assistants/rewrite'
BACKUP_DIR = 'wp-content/uploads/runart-backups/ia-visual'

def main():
    parser = argparse.ArgumentParser(description='Consolidate IA-Visual data layers')
    parser.add_argument('--dry-run', action='store_true', help='Report only, do not write')
    parser.add_argument('--write', action='store_true', help='Write consolidated data to target')
    parser.add_argument('--from-remote', type=str, help='Import from external JSON file')
    
    args = parser.parse_args()
    
    # Implementar algoritmo de consolidación aquí
    # ...
    
if __name__ == '__main__':
    main()
```

### 10.2 Testing del Algoritmo

**Casos de prueba:**
1. Consolidación con 5 capas idénticas → debe elegir capa 5 (más reciente)
2. Consolidación con página adicional en capa 1 → debe añadirla al resultado
3. Consolidación con JSON corrupto en capa 5 → debe usar capa 2 como fallback
4. Importación de dataset remoto → debe priorizar sobre capas locales
5. Dry-run → debe reportar sin modificar archivos

### 10.3 Documentación Asociada

**Crear:**
- `tools/consolidate_ia_visual_data.py` (script completo)
- `tools/README_CONSOLIDATION.md` (guía de uso del script)
- `tests/test_consolidation.py` (tests unitarios)

**Actualizar:**
- `docs/IA_VISUAL_REST_REFERENCE.md` (añadir endpoint health-extended)
- `_reports/FASE4/consolidacion_ia_visual_registro_capas.md` (referenciar este doc)

---

**Fin del documento de diseño**

---

**Generado:** 2025-10-31  
**Fase:** 4.D - Consolidación  
**Estado:** ✅ Diseño completo de algoritmo  
**Próximo paso:** Implementación del script Python
