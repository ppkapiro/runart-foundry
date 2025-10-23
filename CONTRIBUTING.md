# Contributing to RunArt Foundry Documentation

## Cómo escribir documentación

### Frontmatter obligatorio
Todos los archivos `.md` en `docs/live/` deben incluir frontmatter YAML con estos campos:

```yaml
---
status: active          # active | draft | archived
owner: nombre.apellido  # responsable del documento
updated: YYYY-MM-DD     # última actualización sustancial
audience: internal      # internal | external
tags: [tag1, tag2]      # lowercase, sin duplicados, sin espacios
---
```

### Enlaces relativos
- Usa rutas relativas para enlaces internos: `[texto](../carpeta/archivo.md)`
- Evita enlaces absolutos tipo `/docs/...`
- Los enlaces externos (HTTP/HTTPS) deben ser válidos (validados automáticamente en CI)

### Tags
- Lowercase obligatorio
- Sin duplicados
- Sin valores vacíos
- Ejemplo: `tags: [briefing, runart, ops]`

### Convenciones de naming
- Fechas: `YYYY-MM-DD_nombre.md`
- Fases: `F#_nombre.md` si aplica
- Idioma: sufijos `-es`/`-en` solo si coexisten versiones paralelas
- Evitar espacios; usar `_` o `-` consistentemente

## Flujo de Pull Request

### 1. Crear rama
```bash
git checkout -b feature/tu-cambio
```

### 2. Validación local
Antes de hacer commit, ejecuta:
```bash
# Validación estricta (frontmatter, enlaces, tags)
make validate_strict

# o directamente
python3 scripts/validate_docs_strict.py
```

### 3. Commit y push
```bash
git add .
git commit -m "docs(área): descripción concisa del cambio"
git push -u origin feature/tu-cambio
```

### 4. Abrir PR
- Título: `docs(área): descripción`
- Asignar revisor de gobernanza (owner de carpeta)
- Esperar CI verde (strict validation es bloqueante)

### 5. Merge
- Usar **Squash and merge** preferiblemente
- Mantener mensaje de commit limpio

## CI y validaciones

### Validadores activos
- **Strict validator** (bloqueante): frontmatter, enlaces internos/externos, tags únicos
- **Structure guard**: prohibición de archivos en rutas restringidas
- **Docs lint**: formato y enlaces rotos

### Workflow de poda semanal
- Cada lunes 09:00 UTC se ejecuta `docs-stale-dryrun.yml`
- Detecta documentos con `updated` >90 días
- Genera reporte `docs/_meta/stale_candidates.md` (no hace cambios automáticos)
- El owner debe revisar y actualizar o archivar

## Recursos
- Gobernanza: [`docs/_meta/governance.md`](docs/_meta/governance.md)
- Plantilla de frontmatter: [`docs/_meta/frontmatter_template.md`](docs/_meta/frontmatter_template.md)
- Estado operativo: [`docs/status.json`](docs/status.json) (regenerar con `make status_update`)
