# Investigación: Integración Briefing + status.json + Publicaciones Automatizadas

**Fecha:** 2025-10-23  
**Autor:** GitHub Copilot (Research Phase)  
**Rama:** `feat/briefing-status-integration-research`

---

## 1. Resumen Ejecutivo

**Conclusión inicial:** La integración óptima combina **MkDocs con macros Jinja** para renderizar `status.json` en páginas estáticas del Briefing, junto con un **pipeline CI/CD en Python** para generar publicaciones automatizadas a partir de commits documentales.

**Recomendación base:**
- Usar **mkdocs-macros-plugin** o plantillas Jinja directas para integrar `status.json` en `apps/briefing/docs/status/index.md`
- Crear scripts Python (`tools/render_status.py`, `tools/commits_to_posts.py`) ejecutados en GitHub Actions post-merge
- PaperLang queda como opción **opt-in** para papers narrativos complejos (no necesario para PoC)
- Mantener CI verde con validaciones estrictas de frontmatter y formato Markdown

**Ventajas clave:**
- 🚀 Despliegue ≤5min post-merge
- 🔒 100% consistencia entre datos y vista renderizada
- 🛡️ Cero dependencias externas críticas (MkDocs ya usado en proyecto)
- 📊 KPIs operativos visibles en tiempo real
- 🤖 Auto-posts sin intervención manual

---

## 2. Modelos de Integración

### Modelo A: MkDocs Directo (Recomendado para PoC)

**Descripción:** Usar MkDocs con plugins para inyectar datos de `status.json` directamente en Markdown.

**Opciones técnicas:**
1. **mkdocs-macros-plugin** — Jinja macros con acceso a `extra:` en `mkdocs.yml`
   ```yaml
   extra:
     status: !include docs/status.json
   ```
   ```markdown
   {{ status.docs_live_count }} documentos activos
   ```

2. **markdownextradata-plugin** — Similar, pero más explícito para JSON externos
   ```yaml
   plugins:
     - markdownextradata:
         data: docs
   ```
   ```markdown
   {{ status.docs_live_count }}
   ```

3. **Hook Python personalizado** — `on_pre_build` en `mkdocs.yml`
   ```python
   def on_pre_build(config):
       with open('docs/status.json') as f:
           config['extra']['status'] = json.load(f)
   ```

**Pros:**
- ✅ Integración nativa con MkDocs (ya usado en Briefing)
- ✅ Sin compilación adicional (build estándar)
- ✅ Hot-reload funcional en desarrollo (`mkdocs serve`)
- ✅ Fallback sencillo (JSON → defaults si falla carga)
- ✅ Mantenibilidad alta (plantillas Jinja conocidas)

**Contras:**
- ⚠️ Requiere regenerar `status.json` antes de cada build
- ⚠️ No valida esquema JSON automáticamente (necesita script extra)
- ⚠️ Limitado a datos estáticos (no queries dinámicos)

**Caso de uso ideal:** Páginas `/status` con KPIs operativos actualizados post-merge.

---

### Modelo B: PaperLang (Opt-in para Papers)

**Descripción:** Framework especializado para publicaciones científicas/técnicas con narrativa compleja.

**Características:**
- Soporte para referencias cruzadas, bibliografía, diagramas embebidos
- Exportación a PDF, LaTeX, HTML enriquecido
- Templating avanzado con variables y lógica condicional

**Pros:**
- ✅ Ideal para **papers técnicos** con secciones numeradas, citas, gráficos
- ✅ Calidad tipográfica superior (LaTeX backend)
- ✅ Manejo de versiones (drafts, reviews, published)

**Contras:**
- ⚠️ Dependencia externa adicional (npm/pip + configuración)
- ⚠️ Curva de aprendizaje media-alta
- ⚠️ Overkill para publicaciones simples tipo blog
- ⚠️ Build más lento que MkDocs plain

**Caso de uso ideal:** Informes técnicos trimestrales, whitepapers, RFCs extensos.

**Decisión:** **No prioritario para PoC**. Se mantiene como opción para casos específicos donde se requiera formateo académico riguroso.

---

### Modelo C: CI/CD Directo (Recomendado para Auto-posts)

**Descripción:** Scripts Python ejecutados en GitHub Actions que generan Markdown directamente.

**Flujo típico:**
1. **Trigger:** Push a `main` (post-merge)
2. **Paso 1:** Ejecutar `scripts/gen_status.py` → actualiza `docs/status.json`
3. **Paso 2:** Ejecutar `tools/render_status.py` → lee JSON, genera `apps/briefing/docs/status/index.md`
4. **Paso 3:** Ejecutar `tools/commits_to_posts.py` → extrae commits recientes, genera `apps/briefing/docs/news/*.md`
5. **Paso 4:** Validar frontmatter con linters strict
6. **Paso 5:** Commit + push (bot) o PR automático
7. **Paso 6:** Build de MkDocs con archivos actualizados

**Pros:**
- ✅ **Control total** sobre generación de contenido
- ✅ Lógica compleja permitida (filtros, agregaciones, templates dinámicos)
- ✅ Testeable localmente (`python tools/render_status.py`)
- ✅ Auditable (commits bot identificables)
- ✅ Rollback sencillo (revertir commit)

**Contras:**
- ⚠️ Requiere configurar bot account con permisos de escritura
- ⚠️ Riesgo de loops infinitos (commit → CI → commit → ...) — mitigar con `[skip ci]` o condiciones
- ⚠️ Latencia adicional (1-3 min) entre merge y publicación visible

**Caso de uso ideal:** Auto-posts de actualizaciones documentales, summaries de PRs, dashboards dinámicos.

---

## 3. Formatos Compatibles

### JSON → Markdown

**Estrategias de conversión:**

1. **Tablas Markdown** (para métricas estructuradas)
   ```python
   def render_table(data: dict) -> str:
       return f"""
   | Métrica | Valor |
   |---------|-------|
   | Docs activos | {data['docs_live_count']} |
   | Docs archivados | {data['archive_count']} |
   | Último commit | `{data['last_ci_ref'][:8]}` |
   """
   ```

2. **Badges dinámicos** (para CI health)
   ```markdown
   ![Live Docs](https://img.shields.io/badge/live-6-brightgreen)
   ![Archive](https://img.shields.io/badge/archive-1-blue)
   ![CI](https://img.shields.io/badge/build-passing-success)
   ```

3. **Gráficos embebidos** (con Mermaid o Chart.js)
   ```markdown
   ```mermaid
   pie title "Distribución de documentos"
       "Live" : 6
       "Archive" : 1
   ```
   ```

### JSON → HTML (fallback)

Para casos donde Markdown no sea suficiente:
```html
<div class="status-dashboard">
  <h2>Estado Operativo</h2>
  <dl>
    <dt>Documentos activos</dt>
    <dd>{{ docs_live_count }}</dd>
  </dl>
</div>
```

---

## 4. Estrategias de Actualización

### Opción 1: Post-commit (inmediato, riesgoso)

**Trigger:** Pre-commit hook o post-commit
```bash
#!/bin/bash
# .git/hooks/pre-commit
python3 scripts/gen_status.py
git add docs/status.json
```

**Pros:** Actualización instantánea  
**Contras:** Ruido en commits, potencial corrupción si script falla

### Opción 2: Post-merge (recomendado)

**Trigger:** GitHub Actions on push to `main`
```yaml
on:
  push:
    branches: [main]
    paths:
      - 'docs/live/**'
      - 'docs/archive/**'
```

**Pros:**
- Actualizaciones solo en main (no en feature branches)
- CI auditable y testeable
- Rollback sencillo

**Contras:** Latencia de 1-3 min hasta visibilidad

### Opción 3: Scheduled (backup, no principal)

**Trigger:** Cron diario/semanal
```yaml
on:
  schedule:
    - cron: '0 6 * * 1'  # Lunes 06:00 UTC
```

**Uso:** Fallback si post-merge falla, snapshot semanal

---

## 5. Costos y Mantenibilidad

### Dependencias

| Componente | Tipo | Costo de Mantenimiento | Riesgo |
|------------|------|------------------------|--------|
| MkDocs | Runtime | Bajo (versión stable, releases lentos) | Bajo |
| mkdocs-macros-plugin | Plugin | Bajo (comunidad activa) | Bajo |
| markdownextradata | Plugin alternativo | Medio (menos popular) | Medio |
| PaperLang | Opcional | Alto (menos maduro) | Alto |
| Python scripts custom | In-house | Medio (requiere docs) | Medio |
| GitHub Actions | CI/CD | Bajo (plataforma estable) | Bajo |

**Recomendación:** Priorizar MkDocs + scripts Python in-house. Evitar dependencias poco mantenidas.

### Curva de Aprendizaje

- **MkDocs macros:** 1-2 horas (Jinja básico)
- **Scripts Python:** 2-4 horas (lógica de negocio)
- **GitHub Actions:** 2-3 horas (sintaxis YAML, secrets)
- **PaperLang:** 8-12 horas (si se usa en futuro)

**Total estimado (PoC):** 5-9 horas para desarrollador con experiencia Python/CI.

### Gobernanza

**¿Quién ajusta plantillas?**
- Equipo de docs (cambios visuales/estructura)
- Scripts Python → código revisado en PRs con owners en CODEOWNERS

**Versionado de esquema:**
```json
{
  "schema_version": "1.0",
  "generated_at": "...",
  ...
}
```

**Changelog:**
- `docs/_meta/STATUS_SCHEMA.md` documenta cambios entre versiones
- Breaking changes requieren migración documentada

---

## 6. Riesgos y Mitigación

### Riesgo 1: JSON inválido

**Escenario:** `gen_status.py` falla, genera JSON malformado.

**Impacto:** Build de MkDocs falla, Briefing no se publica.

**Mitigación:**
- Validar JSON con `jsonschema` en CI antes de commit
- Fallback a `status.json.bak` (snapshot anterior válido)
- Tests unitarios de `gen_status.py`

```python
# tools/validate_status_schema.py
import jsonschema

schema = {
    "type": "object",
    "required": ["generated_at", "docs_live_count", "archive_count"],
    "properties": {
        "generated_at": {"type": "string"},
        "docs_live_count": {"type": "integer", "minimum": 0},
        ...
    }
}

with open('docs/status.json') as f:
    jsonschema.validate(json.load(f), schema)
```

### Riesgo 2: Drift entre status.json y realidad

**Escenario:** `status.json` muestra 6 docs, pero hay 8 en `docs/live/`.

**Impacto:** Pérdida de confianza en KPIs, debugging manual necesario.

**Mitigación:**
- **Validación periódica:** CI semanal que re-genera status.json y compara con versión committed
- **Alertas:** Si diff > threshold, notificar a owners
- **Auditoría:** Logs de cada generación en `docs/_meta/BRIEFING_STATUS_PIPELINE_RUN.md`

### Riesgo 3: Ruptura de build por cambios en MkDocs

**Escenario:** Actualización de MkDocs 1.x → 2.x rompe macros.

**Impacto:** Briefing no se publica, downtime.

**Mitigación:**
- **Pinning de versiones:** `mkdocs==1.5.3` en `requirements.txt`
- **Renovate/Dependabot:** PRs automáticos de updates, revisión manual
- **Tests de integración:** Build local + CI antes de merge

### Riesgo 4: Loop infinito en CI

**Escenario:** Workflow genera commit → trigger workflow → genera commit → ...

**Impacto:** Miles de commits spam, rate limits de GitHub.

**Mitigación:**
- **Skip CI en commits bot:** `git commit -m "chore: update status [skip ci]"`
- **Condición en workflow:**
  ```yaml
  if: github.event.head_commit.author.name != 'github-actions[bot]'
  ```
- **Rate limiting:** Max 1 ejecución por 5 minutos

---

## 7. PoC Propuesta

### Arquitectura

```
scripts/gen_status.py
    ↓ (genera docs/status.json)
tools/render_status.py
    ↓ (lee JSON, aplica template Jinja, escribe apps/briefing/docs/status/index.md)
tools/commits_to_posts.py
    ↓ (git log → extrae commits docs/*, genera apps/briefing/docs/news/*.md)
MkDocs build
    ↓ (convierte Markdown → HTML estático)
GitHub Pages / Cloudflare Pages
    ↓ (publica sitio)
```

### Componentes mínimos

1. **Template Jinja:** `tools/templates/status_page.md.j2`
   ```jinja
   ---
   title: "Estado Operativo"
   updated: "{{ status.generated_at }}"
   ---
   
   ## KPIs
   
   - **Documentos activos:** {{ status.docs_live_count }}
   - **Documentos archivados:** {{ status.archive_count }}
   - **Último commit CI:** `{{ status.last_ci_ref[:8] }}`
   ```

2. **Script render:** `tools/render_status.py`
   ```python
   from jinja2 import Template
   import json
   
   with open('docs/status.json') as f:
       status = json.load(f)
   
   with open('tools/templates/status_page.md.j2') as f:
       template = Template(f.read())
   
   output = template.render(status=status)
   
   with open('apps/briefing/docs/status/index.md', 'w') as f:
       f.write(output)
   ```

3. **Script posts:** `tools/commits_to_posts.py` (ver sección 8 para detalle)

### Validaciones

- ✅ JSON schema validation (`tools/validate_status_schema.py`)
- ✅ Frontmatter validation (reutilizar `scripts/validate_docs_strict.py`)
- ✅ Link checker (interno + externo)
- ✅ Build de MkDocs exitoso (`mkdocs build --strict`)

---

## 8. Comparativa Final

| Criterio | MkDocs Macros | PaperLang | CI/CD Python |
|----------|---------------|-----------|--------------|
| **Complejidad** | Baja | Media-Alta | Media |
| **Flexibilidad** | Media | Alta | Alta |
| **Mantenibilidad** | Alta | Media | Alta |
| **Curva aprendizaje** | Baja | Alta | Media |
| **Build time** | Rápido (<30s) | Medio (1-2min) | Rápido (<1min) |
| **Fallback** | Sí (defaults) | No | Sí (commits revert) |
| **Testing local** | Sí | Limitado | Sí |
| **Uso ideal** | KPIs estáticos | Papers técnicos | Auto-posts dinámicos |

**Decisión final:** **MkDocs Macros (status) + CI/CD Python (posts)** — balance óptimo entre simplicidad, flexibilidad y mantenibilidad.

---

## 9. Siguiente Paso: Plan de Implementación

Ver `docs/integration_briefing_status/plan_briefing_status_integration.md` para roadmap detallado (S1/S2/S3), KPIs y gobernanza.

---

**Fecha:** 2025-10-23T22:10:00Z  
**Commit:** (pendiente de PR)  
**Autor:** GitHub Copilot (Briefing Status Integration Research)
