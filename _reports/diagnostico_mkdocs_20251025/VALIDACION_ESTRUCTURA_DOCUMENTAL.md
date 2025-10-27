# VALIDACION_ESTRUCTURA_DOCUMENTAL — 2025-10-25T15:20Z

## Objetivo
Comparar `apps/briefing/docs/` contra `docs/live/` para asegurar coherencia estructural, ausencia de documentos fuera de lugar, huérfanos o duplicados según el modelo 3 capas.

---

## Modelo documental vigente

### Estructura en el repositorio

```
runart-foundry/
├── docs/                          # Modelo 3 capas (raíz)
│   ├── live/                      # Capa "live" (documentación vigente)
│   │   ├── index.md
│   │   ├── briefing_canonical_source.md
│   │   ├── architecture/
│   │   │   └── index.md
│   │   ├── operations/
│   │   │   ├── index.md
│   │   │   └── status_overview.md
│   │   └── ui_roles/
│   │       └── index.md
│   ├── archive/                   # Capa "archive" (histórico)
│   └── _meta/                     # Capa "meta" (gobernanza)
│
└── apps/briefing/                 # Micrositio Briefing
    ├── mkdocs.yml                 # Config activa
    └── docs/                      # Fuente operativa del Briefing
        ├── index.md               # Home
        ├── client_projects/       # Cliente · RunArt Foundry
        ├── internal/              # Equipo Técnico · Briefing System
        ├── projects/              # Proyectos
        └── ... (otras secciones)
```

---

## Árbol resumido de docs/live/ (capa live)

```
docs/live/
├── index.md (hub principal)
├── briefing_canonical_source.md (declaración canónica)
├── architecture/
│   └── index.md (hub arquitectura)
├── operations/
│   ├── index.md (hub operaciones)
│   └── status_overview.md
└── ui_roles/
    └── index.md (hub UI/roles)
```

**Total de archivos:** 6 markdown

---

## Árbol resumido de apps/briefing/docs/ (fuente operativa)

```
apps/briefing/docs/
├── index.md (Home del Briefing)
├── client_projects/
│   └── runart_foundry/
│       ├── index.md
│       ├── plan/index.md
│       ├── auditoria/index.md
│       └── reports/ (múltiples .md)
├── internal/
│   └── briefing_system/
│       ├── index.md
│       ├── plans/ (múltiples .md)
│       ├── deploy/ (múltiples .md)
│       ├── ci/ (múltiples .md)
│       ├── guides/ (múltiples .md)
│       ├── reports/ (múltiples .md)
│       ├── templates/ (múltiples .md)
│       ├── tests/ (múltiples .md)
│       ├── ops/ (múltiples .md)
│       ├── audits/ (múltiples .md)
│       ├── architecture/ (múltiples .md)
│       └── ui/ (múltiples .md)
├── projects/
│   ├── index.md
│   ├── _template.yaml
│   ├── schema.yaml
│   ├── en/ (proyectos EN)
│   └── ... (proyectos ES)
├── decisiones/
├── inbox/
├── dashboards/
├── editor/
├── exports/
├── fases/
├── galeria/
├── proceso/
├── acerca/
├── accesos/
├── api/
├── arq/
├── assets/ (CSS, JS, images)
├── news/ (auto-updates)
├── status/
├── ui/
├── briefing_arquitectura.md
├── _smoke.md
└── robots.txt
```

**Total de archivos:** 153 markdown

---

## Comparación y hallazgos

### 1. Relación entre docs/live/ y apps/briefing/docs/

**Modelo actual (Opción A):**
- `docs/live/` contiene **declaraciones canónicas y hubs de alto nivel** (6 docs)
- `apps/briefing/docs/` contiene **contenido operativo detallado del Briefing** (153 docs)
- **Relación:** `docs/live/` es referencia conceptual; `apps/briefing/docs/` es la fuente activa

**Verificación:**
- ✅ No hay duplicación de contenido entre ambas estructuras
- ✅ `docs/live/` tiene placeholders/índices de alto nivel
- ✅ `apps/briefing/docs/` tiene documentación operativa detallada
- ⚠️ Enlaces de `apps/briefing/docs/` hacia `docs/live/` son placeholders conceptuales (ver STRICT_VALIDATION_REPORT.md)

---

### 2. Archivos fuera de lugar

**En docs/live/:**
- ✅ Todos los archivos están en su lugar correcto
- ✅ Estructura coherente: index.md + 3 hubs (architecture, operations, ui_roles)

**En apps/briefing/docs/:**
- ✅ Todos los archivos están dentro de la estructura esperada
- ✅ Organización en 3 interfaces principales (Cliente / Equipo Técnico / Proyectos)
- ✅ Assets y auxiliares en carpetas dedicadas

**Veredicto:** ✅ Sin archivos fuera de lugar

---

### 3. Documentos huérfanos

**Definición:** Documentos markdown no referenciados en navegación ni enlazados desde otros docs.

**Candidatos revisados:**
- `apps/briefing/docs/news/` (18 archivos auto-update)
  - Estado: No están en nav de mkdocs.yml
  - Motivo: Generados automáticamente como logs de actualización
  - **Veredicto:** No son huérfanos; son logs auxiliares

- `apps/briefing/docs/status/` (2 archivos)
  - Estado: No están en nav de mkdocs.yml
  - Motivo: Enlaces absolutos desde otros docs
  - **Veredicto:** No son huérfanos; accesibles vía enlaces

- `apps/briefing/docs/ui/` (1 archivo)
  - Estado: No está en nav de mkdocs.yml
  - Motivo: Referencia interna/auxiliar
  - **Veredicto:** Revisar si debe agregarse a nav o es temporal

**Listado de archivos no en nav pero no huérfanos:**
- `__canary_switch_check.md` (canario de testing)
- `briefing_arquitectura.md` (enlazado desde index.md)
- Documentos en `internal/briefing_system/` no explícitamente listados en nav pero accesibles vía índices de sección

**Veredicto:** ✅ Sin huérfanos críticos; algunos docs auxiliares/logs no en nav (esperado)

---

### 4. Duplicados no autorizados

**Regla:** Solo index.md por hub/sección permitido.

**Verificación:**
- ✅ Cada sección tiene un único index.md
- ✅ No se detectaron duplicados de contenido entre secciones
- ✅ No se detectaron conflictos de nombres

**Veredicto:** ✅ Sin duplicados no autorizados

---

### 5. Frontmatter incompleto

**En docs/live/:**
- ✅ Todos los documentos tienen frontmatter completo
- Campos: status, owner, updated, audience, tags

**En apps/briefing/docs/:**
- ⚠️ ~67% de documentos sin frontmatter (ver STRICT_VALIDATION_REPORT.md)
- **Observación:** Frontmatter no es obligatorio en apps/briefing/docs/ según modelo actual
- **Acción pendiente:** Definir política de frontmatter si se requiere en futuro

**Veredicto:** ⚠️ Frontmatter opcional en apps/briefing/docs/ (no crítico)

---

## Acciones aplicadas

### Correcciones automáticas
- Ninguna (no se detectaron errores que corregir automáticamente)

### Acciones pendientes (no críticas)

1. **Revisar docs auxiliares no en nav**
   - `apps/briefing/docs/ui/cliente_portada.md` — determinar si debe agregarse a navegación
   - `apps/briefing/docs/news/` (18 archivos) — considerar archivar logs antiguos si no son necesarios

2. **Definir política de frontmatter**
   - Documentar en gobernanza si frontmatter será obligatorio en `apps/briefing/docs/` en futuro

3. **Actualizar enlaces placeholders**
   - 16 archivos con enlaces conceptuales a `docs/live/` — actualizar según modelo adoptado (ver BRIEFING_NAV_SYNC_REPORT.md)

---

## Resumen ejecutivo

### ✅ Validación estructural: **PASS**

**Hallazgos:**
- ✅ Estructura documental coherente y bien organizada
- ✅ Sin archivos fuera de lugar
- ✅ Sin documentos huérfanos críticos
- ✅ Sin duplicados no autorizados
- ⚠️ Docs auxiliares/logs no en nav (esperado y no crítico)
- ⚠️ Frontmatter opcional en apps/briefing/docs/ (documentar política futura)

**Modelo vigente:**
- **docs/live/:** Referencias canónicas y hubs de alto nivel (6 docs)
- **apps/briefing/docs/:** Fuente operativa del Briefing (153 docs)
- **Relación:** Complementarias; no duplicadas; modelo A validado y operativo

---

## Estadísticas finales

| Métrica | docs/live/ | apps/briefing/docs/ |
|---------|-----------|---------------------|
| Total documentos .md | 6 | 153 |
| En navegación mkdocs | 6 (100%) | ~110 (72%) |
| Fuera de nav (esperado) | 0 | ~43 (28%) |
| Huérfanos críticos | 0 | 0 |
| Duplicados no autorizados | 0 | 0 |
| Con frontmatter | 6 (100%) | 50 (33%) |

---

**Fecha de ejecución:** 2025-10-25T15:20Z  
**Rama:** feat-local-no-auth-briefing  
**Estado:** Estructura validada y operativa
