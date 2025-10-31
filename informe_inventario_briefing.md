# Inventario y Mapa del Sistema de Briefing
## RunArt Foundry — Análisis Completo y Propuesta de Optimización

**Fecha de análisis:** 2025-10-31  
**Alcance:** Todo el proyecto (repositorio local, documentación, automatización, WordPress)  
**Objetivo:** Identificar, mapear y optimizar todo lo relacionado con briefing, documentación por capas, etiquetado y manejo de datos para IA

---

## 1. Objetivo del Análisis

Esta investigación profunda tiene como propósito:

1. **Inventariar** todo lo relacionado con "briefing" (micrositio, documentación, capas, automatización)
2. **Mapear** el sistema de etiquetado/clasificación de datos y documentación
3. **Identificar** integraciones con IA, WordPress API y application passwords
4. **Detectar** elementos duplicados, sobredimensionados o que sobrecargan VS Code
5. **Proponer** una arquitectura optimizada eliminando redundancias

### Alcance de la Búsqueda

Se revisaron las siguientes áreas del proyecto:

- ✅ Raíz del proyecto y código principal
- ✅ Carpetas de documentación (`docs/`, `apps/briefing/docs/`)
- ✅ Automatización CI/CD (`.github/workflows/`)
- ✅ Scripts y herramientas (`tools/`, `scripts/`)
- ✅ Integraciones WordPress (`wp-content/`, `plugins/`)
- ✅ Configuración VS Code (`.vscode/`)
- ✅ Reportes y auditorías (`_reports/`, `audits/`)

---

## 2. Hallazgos por Categoría

### 2.1 Núcleo del Sistema Briefing

#### A) Micrositio Principal

**Ubicación actual:** `apps/briefing/`  
**Estado:** ✅ Activo y operativo

**Componentes principales:**

```
apps/briefing/
├── README_briefing.md           # Documentación principal del micrositio
├── SAFE_LOCAL_MODE.md           # Guía para desarrollo local sin cloud
├── mkdocs.yml                   # Configuración MkDocs Material
├── wrangler.toml                # Configuración Cloudflare Pages
├── package.json                 # Dependencias Node.js
├── Makefile                     # Comandos build/test/deploy
├── docs/                        # Contenido Markdown
│   ├── client_projects/         # Documentación cliente
│   │   └── runart_foundry/
│   └── internal/                # Documentación interna
│       └── briefing_system/
├── functions/                   # Cloudflare Pages Functions
│   └── api/
│       ├── decisiones.js        # Captura de decisiones
│       ├── inbox.js             # Gestión de inbox
│       └── whoami.js            # Info de usuario/rol
├── overrides/                   # Personalizaciones tema
├── scripts/                     # Scripts de QA y smoke tests
└── workers/                     # Workers (legacy, migrado a functions)
```

**Propósito:**
- Panel interno privado (Cloudflare Access)
- Documentación de proyecto por fases
- Sistema de captura de decisiones (KV)
- Segmentación por roles (owner/client_admin/client/team/visitor)

**Estado de madurez:**
- ✅ Fase ARQ+ v1 completada
- ✅ Navegación por roles implementada
- ✅ Exportaciones funcionando
- ✅ Tests y smokes activos

#### B) Workflows de Automatización

**Archivo:** `.github/workflows/briefing_deploy.yml`  
**Estado:** ✅ Activo

```yaml
name: Deploy: Briefing
on:
  push:
    branches: [main]
    paths:
      - 'apps/briefing/**'
      - '.github/workflows/briefing_deploy.yml'
```

**Función:** Despliega automáticamente el micrositio a Cloudflare Pages cuando hay cambios.

**Archivo:** `.github/workflows/briefing-status-publish.yml`  
**Estado:** ✅ Activo (integración con status.json)

**Función:** 
- Lee `docs/status.json`
- Genera página `/status` en briefing
- Crea posts automáticos en `/news` desde commits recientes
- 7 steps: setup → validate → render → generate posts → commit → deploy → smoke tests

#### C) Documentación Canónica

**Sistema de tres capas implementado:**

1. **docs/live/** — Documentación vigente y activa
2. **docs/archive/** — Histórico estable (solo lectura)
3. **docs/_meta/** — Reglas, plantillas, gobernanza

**Archivo maestro:** `docs/live/briefing_canonical_source.md`

**Contenido:**
- Define que `docs/live/` es la fuente de verdad
- `apps/briefing/docs/` es la capa de presentación
- Sincronización unidireccional: live → briefing

---

### 2.2 Capas de Documentación (Activa / Histórica / Meta)

#### Modelo de Tres Capas

**Documentado en:** `docs/_meta/governance.md`

```
Ciclo de vida documental:
1. Draft      → documento en creación
2. Active     → vigente (en docs/live/)
3. Stale      → sin actualización >90 días
4. Archived   → movido a docs/archive/
```

**Archivos clave:**

| Archivo | Propósito | Estado |
|---------|-----------|--------|
| `docs/_meta/frontmatter_template.md` | Plantilla YAML estándar | ✅ Activo |
| `docs/_meta/governance.md` | Reglas de gobernanza documental | ✅ Activo |
| `docs/_meta/phase1_summary.md` | Resumen creación modelo 3 capas | ✅ Histórico |

**Detección de stale:**
- Workflow `docs-stale-dryrun.yml` (cada lunes 09:00 UTC)
- Genera `docs/_meta/stale_candidates.md`
- Sin commits automáticos (dry-run)

#### Capas de Datos IA-Visual

**Documento maestro:** `_reports/FASE4/consolidacion_ia_visual_registro_capas.md`

**5 capas detectadas** (con redundancia 400%):

1. **CAPA 1:** `data/assistants/rewrite/` (repositorio Git)
2. **CAPA 2:** `wp-content/runart-data/assistants/rewrite/` ⭐ **FUENTE DE VERDAD**
3. **CAPA 3:** `plugins/runart-ia-visual-unified/data/assistants/rewrite/` (legacy)
4. **CAPA 4:** `tools/runart-ia-visual-unified/data/assistants/rewrite/` (copia desarrollo)
5. **CAPA 5:** `tools/data_ia/assistants/rewrite/` (temporal)

**Tamaño total:** 217.5 KB (43.5 KB × 5)  
**Objetivo de consolidación:** Reducir a 43.5 KB (eliminando 4 copias)

**Decisión tomada:**
- ✅ WordPress (`wp-content/runart-data/`) es la fuente de verdad
- ❌ Eliminar capas 1, 3, 4, 5
- ✅ Mantener solo respaldo Git en `data/` como snapshot

---

### 2.3 Automatización / Despliegue / Overlays / Staging

#### Workflows CI/CD

**Workflows relacionados con briefing:**

1. **`briefing_deploy.yml`** — Deploy principal del micrositio
2. **`briefing-status-publish.yml`** — Integración status.json + auto-posts
3. **`overlay-deploy.yml`** — Deploy de overlays (legacy Workers)

**Scripts de protección staging:**

```bash
# Variables de seguridad por defecto:
READ_ONLY=1        # Solo lectura
DRY_RUN=1          # Simulación sin cambios
SKIP_SSH=1         # Sin conexión SSH por defecto
```

**Archivos:**
- `tools/deploy_wp_ssh.sh` — Deploy tema a WordPress con guards
- `tools/staging_full_validation.sh` — Validación completa staging
- `tools/staging_isolation_audit.sh` — Auditoría de aislamiento
- `scripts/deploy_framework/close_staging_window.sh` — Cierre de ventana de mantenimiento

**Label de control:**
- `deployment-approved` — Requerido para desactivar READ_ONLY=1

#### Overlays y Workers

**Ubicación:** `apps/briefing/workers/` (legacy)  
**Estado:** ⚠️ Migrado a Pages Functions

**Migración realizada:**
- ❌ `workers/decisiones.js` → ✅ `functions/api/decisiones.js`
- ❌ `workers/inbox.js` → ✅ `functions/api/inbox.js`

**Razón:** Pages Functions se integran mejor con el dominio principal (sin necesidad de workers.dev)

**Guards anti-workers.dev:**
- Pipeline producción bloquea referencias a `workers.dev` en artefactos
- Validación en `pages-prod.yml` línea 68

---

### 2.4 Integración con WordPress / API / IA

#### A) WordPress REST API

**Plugin principal:** `plugins/runart-wpcli-bridge/`  
**Endpoints:**

```
GET /wp-json/runart/v1/audit/pages       # Auditoría de páginas bilingües
GET /wp-json/runart/v1/audit/content     # Auditoría de contenido
GET /wp-json/briefing/v1/status          # Estado del briefing (MU plugin)
```

**Autenticación:** Application Password (WordPress 5.6+)

**Variables de entorno:**
```bash
WP_USER=github-actions
WP_APP_PASSWORD=<application-password-from-wp-admin>
```

**Documentos:**
- `docs/Bridge_API.md` — Especificación completa de endpoints
- `_reports/RESUMEN_EJECUTIVO_REST_BRIDGE_20251030.md` — Status de implementación
- `docs/RUNBOOK_FASE7_PREVIEW_PRIMERO.md` — Guía de conexión WordPress

#### B) Application Passwords

**Ubicación en WordPress:**
- WP-Admin → Users → [usuario] → Application Passwords

**Usuarios con application password:**
- `github-actions` (administrador) — Para CI/CD workflows

**Workflows que usan application passwords:**

1. **`auto_translate_content.yml`** — Traducción automática ES↔EN
2. **`verify-staging-access.yml`** — Verificación de acceso staging
3. **`rotate-app-password.yml`** — Rotación periódica de passwords

**Scripts de gestión:**
```bash
# Crear application password
wp user application-password create github-actions "GH Actions STAGING" --porcelain

# Listar passwords
wp user application-password list github-actions

# Eliminar password
wp user application-password delete github-actions <uuid>
```

**Archivos con referencias:**
- 173 matches encontrados en el proyecto
- Principalmente en: `docs/`, `_reports/`, `tools/`, `issues/`

#### C) Traducción Automática con IA

**Workflow:** `.github/workflows/auto_translate_content.yml`  
**Estado:** ✅ Implementado (dry-run por defecto)

**Funcionalidad:**
- Traducción automática de CPTs (Custom Post Types)
- Integración con Polylang
- API OpenAI para traducción ES↔EN
- Actualización via WordPress REST API

**Documentos:**
- `docs/i18n/RESUMEN_EJECUTIVO_AUTO_TRADUCCION.md`
- `_reports/ESTADO_FINAL_TRADUCCION_20251027.md` — 16 CPTs traducidos

**Dependencias:**
```bash
STAGING_WP_URL=https://staging.runartfoundry.com
STAGING_WP_USER=github-actions
STAGING_WP_APP_PASSWORD=<password>
OPENAI_API_KEY=<key>
```

#### D) Plugin IA Visual Unificado

**Ubicación:** `plugins/runart-ia-visual-unified/`  
**Versión:** 2.1.0

**Funcionalidad:**
- Correlación imagen-texto con CLIP
- Sugerencias de imágenes para contenido
- Panel de administración en WP-Admin
- Backups automáticos en `wp-content/backups/ia-visual/`

**Integración con briefing:**
- Métricas IA visibles en Briefing Status Dashboard (planificado M7)
- Datos almacenados en `wp-content/runart-data/`

**Documentos:**
- `informe_plugins_ia_visual.md`
- `docs/IA_VISUAL_REST_REFERENCE.md`
- `PLAN_MAESTRO_IA_VISUAL_RUNART.md` (1400+ líneas)

---

### 2.5 Etiquetado y Metadatos

#### A) Frontmatter y Taxonomía

**Plantilla estándar:** `docs/_meta/frontmatter_template.md`

```yaml
---
status: active        # active | stale | archived | deprecated
owner: reinaldo.capiro
updated: 2025-10-31
audience: internal    # internal | external
tags: [briefing, runart, ops]
---
```

**Campos requeridos:**
- `status` — Ciclo de vida del documento
- `owner` — Responsable del documento
- `updated` — Última actualización (YYYY-MM-DD)
- `audience` — Alcance de publicación
- `tags` — Etiquetas específicas del dominio

#### B) Taxonomías WordPress

**CPTs (Custom Post Types):**
- `project` (Proyectos de fundición)
- `service` (Servicios)
- `testimonial` (Testimonios)

**Taxonomías definidas:**

1. **artist** — Artista/escultor
2. **technique** — Técnica de fundición
3. **alloy** — Aleación de metal
4. **patina** — Tipo de pátina
5. **year** — Año de realización
6. **client_type** — Tipo de cliente (institucional/privado/galería)

**Archivos:**
- `wp-content/themes/runart-base/inc/custom-post-types.php` (571 líneas)
- Documentación: `docs/live/ARQUITECTURA_SITIO_PUBLICO_RUNART.md`

#### C) Metadata en JSON

**Formato de metadatos IA Visual:**

```json
{
  "metadata": {
    "alt": {
      "es": "Texto alternativo español",
      "en": "Alternative text English"
    },
    "title": {
      "es": "Título español",
      "en": "English title"
    },
    "description": "Descripción técnica",
    "shot_type": "detail|overview|process",
    "rights": "copyright_holder"
  }
}
```

**Ubicaciones:**
- `wp-content/runart-data/` — Datos operativos
- `content/media/media-index.json` — Índice de medios RunMedia
- `data/assistants/rewrite/` — Datasets IA

#### D) Labels GitHub

**Labels de gobernanza:**

```
deployment-approved    # Aprobado para deploy
staging-complete       # Staging validado
scope/governance       # Cambios de gobernanza
scope/validators       # Validadores
area/docs              # Documentación
type/chore             # Mantenimiento
status/draft           # Borrador
```

**Uso:** Control de pipelines y aprobaciones

---

### 2.6 Elementos Duplicados o en Desuso

#### A) Duplicaciones Detectadas

**1. Sistema Briefing:**

❌ **Duplicado:** `briefing/` (raíz) — Archivado en `_archive/legacy_removed_20251007/`  
✅ **Actual:** `apps/briefing/` — Micrositio activo

**Razón del archivado:**
- Limpieza del 2025-10-07
- Toda navegación migrada a estructura Cliente/Equipo
- Legacy completo preservado para trazabilidad

**2. Datos IA-Visual:**

❌ **5 capas redundantes** (ver sección 2.2)  
✅ **Fuente de verdad:** `wp-content/runart-data/`

**Acción requerida:**
- Eliminar capas 3, 4, 5 (en plugins y tools)
- Mantener capa 2 (WordPress) como operativa
- Capa 1 (data/) solo como snapshot Git

**3. Workers vs Pages Functions:**

❌ **Legacy:** `apps/briefing/workers/`  
✅ **Actual:** `apps/briefing/functions/`

**Estado:**
- Migración completada
- `workers/` mantenido solo como referencia
- `workflow overlay-deploy.yml` legacy (28 ejecuciones fallidas)

#### B) Documentos Obsoletos

**Candidatos a archivar:**

| Archivo | Razón | Acción |
|---------|-------|--------|
| `docs/ui_roles/BITACORA_INVESTIGACION_BRIEFING_V2.md` | Fase completada | Mover a archive/ |
| `_reports/FASE4/diseño_flujo_consolidacion.md` | Fase 4 cerrada | Mover a archive/ |
| `docs/_meta/post_pr0X_*.md` | PRs antiguas mergeadas | Archivar |
| `apps/briefing/workers/` | Migrado a functions | Eliminar tras validación |
| `tools/runart-ia-visual-unified/` | Copia del plugin | Eliminar (duplicado) |

**Criterio:**
- `updated` > 90 días sin cambios
- `status: deprecated` en frontmatter
- Documentos de fase cerrada sin valor de referencia

#### C) Configuración VS Code Sobrecargada

**Archivo:** `.vscode/tasks.json`

**Tareas activas:**

1. ✅ `Fase7: Collect Evidence` — Script de evidencias
2. ✅ `Fase7: Process Evidence` — Procesamiento Python
3. ✅ `IONOS: Create Staging` — Creación staging
4. ✅ `Auditoría Aislamiento Staging` — Script de auditoría
5. ✅ `Reparación Automática Prod/Staging` — Reparación
6. ✅ `Reparación Final Prod/Staging (Raíz)` — Reparación root
7. ✅ `🧩 Reparación AUTO-DETECT (IONOS/raíz)` — Auto-detect (default)

**Análisis:**
- 7 tareas definidas (moderado)
- Tareas específicas de Fase 7 (conexión WordPress)
- ⚠️ Tareas de reparación podrían moverse a scripts standalone

**Recomendación:**
- Mantener solo tareas usadas frecuentemente
- Mover tareas administrativas a `Makefile` o documentación
- Reducir a 3-4 tareas esenciales

---

## 3. Mapa Textual del Sistema

### 3.1 Arquitectura General

```
SISTEMA DE BRIEFING Y DOCUMENTACIÓN
│
├── 📁 BRIEFING (Micrositio MkDocs)
│   │
│   ├── apps/briefing/                      # Micrositio activo
│   │   ├── docs/
│   │   │   ├── client_projects/            # CAPA: Cliente
│   │   │   │   └── runart_foundry/
│   │   │   │       ├── reports/            # Reportes visibles al cliente
│   │   │   │       ├── demos/              # Scripts de demo
│   │   │   │       └── architecture/
│   │   │   │
│   │   │   └── internal/                   # CAPA: Equipo interno
│   │   │       └── briefing_system/
│   │   │           ├── reports/            # Reportes técnicos
│   │   │           ├── plans/              # Planes y orquestadores
│   │   │           ├── integrations/       # Integraciones (WP, API)
│   │   │           └── architecture/       # Arquitectura técnica
│   │   │
│   │   ├── functions/api/                  # Cloudflare Pages Functions
│   │   │   ├── decisiones.js               # Captura decisiones → KV
│   │   │   ├── inbox.js                    # Gestión inbox
│   │   │   └── whoami.js                   # Info usuario/rol
│   │   │
│   │   ├── scripts/                        # Smoke tests y QA
│   │   │   ├── smoke_arq3.sh
│   │   │   ├── test_logs_strict.mjs
│   │   │   └── kv_export_preview.mjs
│   │   │
│   │   └── _reports/                       # Resultados de tests
│   │       ├── tests/                      # Tests T1-T5
│   │       └── roles_canary_preview/       # Preview roles
│   │
│   └── _archive/legacy_removed_20251007/   # Briefing legacy archivado
│       └── briefing/                       # Sistema anterior (preservado)
│
├── 📁 DOCUMENTACIÓN (Modelo 3 Capas)
│   │
│   ├── docs/live/                          # CAPA ACTIVA
│   │   ├── architecture/                   # Arquitectura
│   │   ├── operations/                     # Operaciones
│   │   ├── ui_roles/                       # UI y roles
│   │   └── briefing_canonical_source.md    # Fuente de verdad
│   │
│   ├── docs/archive/                       # CAPA HISTÓRICA
│   │   └── YYYY-MM/                        # Archivado por mes
│   │
│   └── docs/_meta/                         # CAPA META
│       ├── frontmatter_template.md         # Plantilla YAML
│       ├── governance.md                   # Reglas gobernanza
│       ├── phase1_summary.md               # Resúmenes fases
│       └── status_samples/                 # Schemas status.json
│
├── 📁 AUTOMATIZACIÓN
│   │
│   ├── .github/workflows/
│   │   ├── briefing_deploy.yml             # Deploy micrositio
│   │   ├── briefing-status-publish.yml     # Status + auto-posts
│   │   ├── auto_translate_content.yml      # Traducción IA
│   │   ├── rotate-app-password.yml         # Rotación passwords
│   │   └── overlay-deploy.yml              # Legacy (deprecated)
│   │
│   ├── tools/                              # Scripts deploy
│   │   ├── deploy_wp_ssh.sh                # Deploy WordPress
│   │   ├── staging_full_validation.sh      # Validación staging
│   │   ├── render_status.py                # status.json → Markdown
│   │   └── commits_to_posts.py             # Commits → posts
│   │
│   └── scripts/deploy_framework/           # Framework deploy
│       ├── close_staging_window.sh         # Cierre ventana
│       └── MAINTENANCE_WINDOW_PROTOCOL.md  # Protocolo
│
├── 📁 INTEGRACIONES
│   │
│   ├── WordPress API
│   │   ├── plugins/runart-wpcli-bridge/    # Plugin Bridge API
│   │   ├── wp-content/mu-plugins/          # MU plugins
│   │   └── docs/Bridge_API.md              # Documentación API
│   │
│   ├── IA Visual
│   │   ├── plugins/runart-ia-visual-unified/ # Plugin principal
│   │   ├── wp-content/runart-data/         # Datos operativos ⭐
│   │   └── PLAN_MAESTRO_IA_VISUAL_RUNART.md # Plan maestro
│   │
│   └── Application Passwords
│       ├── Variables CI/CD                 # GitHub Secrets
│       └── wp-admin → Users → App Passwords # Gestión WordPress
│
├── 📁 ETIQUETADO Y METADATOS
│   │
│   ├── Frontmatter (Documentación)
│   │   ├── status: active|stale|archived|deprecated
│   │   ├── owner: responsable
│   │   ├── updated: YYYY-MM-DD
│   │   ├── audience: internal|external
│   │   └── tags: [briefing, runart, ops]
│   │
│   ├── Taxonomías WordPress
│   │   ├── artist, technique, alloy
│   │   ├── patina, year, client_type
│   │   └── custom-post-types.php (571 líneas)
│   │
│   └── Labels GitHub
│       ├── deployment-approved
│       ├── staging-complete
│       └── scope/* (governance, validators)
│
└── 📁 DATOS (5 Capas → Consolidación a 1)
    │
    ├── ❌ data/assistants/rewrite/         # CAPA 1: Git (eliminar)
    ├── ✅ wp-content/runart-data/          # CAPA 2: WordPress ⭐ VERDAD
    ├── ❌ plugins/.../data/                # CAPA 3: Plugin (eliminar)
    ├── ❌ tools/.../data/                  # CAPA 4: Tools (eliminar)
    └── ❌ tools/data_ia/                   # CAPA 5: Temporal (eliminar)
```

### 3.2 Flujo de Información

```
┌────────────────────────────────────────────────────────────────┐
│ FLUJO: Documentación → Briefing → Publicación                 │
└────────────────────────────────────────────────────────────────┘

docs/live/*.md
    │
    │ (manual: escribir/actualizar)
    ▼
docs/status.json
    │
    │ (workflow: briefing-status-publish.yml)
    ▼
apps/briefing/docs/status/index.md
    │
    │ (MkDocs build)
    ▼
apps/briefing/site/ (HTML estático)
    │
    │ (Cloudflare Pages deploy)
    ▼
https://runart-briefing.pages.dev

┌────────────────────────────────────────────────────────────────┐
│ FLUJO: Commits → Posts Automáticos                            │
└────────────────────────────────────────────────────────────────┘

git log (últimos 30 días)
    │
    │ (script: commits_to_posts.py)
    ▼
apps/briefing/docs/news/*.md (14 posts)
    │
    │ (MkDocs build + deploy)
    ▼
https://runart-briefing.pages.dev/news/

┌────────────────────────────────────────────────────────────────┐
│ FLUJO: WordPress ← IA Visual → Briefing                       │
└────────────────────────────────────────────────────────────────┘

wp-content/runart-data/assistants/rewrite/
    │
    │ (plugin lee datos)
    ▼
runart-ia-visual-unified (WP plugin)
    │
    │ (genera sugerencias)
    ▼
WP Admin → IA Visual Panel
    │
    │ (métricas exportadas)
    ▼
Briefing Status Dashboard (planificado)

┌────────────────────────────────────────────────────────────────┐
│ FLUJO: CI/CD → Staging → Production                           │
└────────────────────────────────────────────────────────────────┘

git push (main)
    │
    │ (READ_ONLY=1, DRY_RUN=1 por defecto)
    ▼
GitHub Actions workflows
    │
    ├─→ briefing_deploy.yml → Cloudflare Pages
    ├─→ auto_translate_content.yml → WordPress REST API
    └─→ verify-staging-access.yml → Smoke tests
    │
    │ (requiere label: deployment-approved)
    ▼
Deploy real (READ_ONLY=0)
```

---

## 4. Recomendaciones de Optimización

### 4.1 Qué Mantener (Esencial)

#### ✅ MANTENER — Sistema Core

**Briefing:**
- ✅ `apps/briefing/` completo (micrositio operativo)
- ✅ `docs/live/briefing_canonical_source.md` (fuente de verdad)
- ✅ `.github/workflows/briefing_deploy.yml` (deploy automático)
- ✅ `.github/workflows/briefing-status-publish.yml` (integración status)

**Documentación:**
- ✅ `docs/live/` (contenido vigente)
- ✅ `docs/_meta/governance.md` (reglas)
- ✅ `docs/_meta/frontmatter_template.md` (estándar)

**Automatización:**
- ✅ `tools/deploy_wp_ssh.sh` (con guards READ_ONLY)
- ✅ `tools/render_status.py` (generador status)
- ✅ `tools/commits_to_posts.py` (generador posts)

**Integraciones:**
- ✅ `plugins/runart-wpcli-bridge/` (Bridge API)
- ✅ `plugins/runart-ia-visual-unified/` (IA Visual)
- ✅ `wp-content/runart-data/` (datos operativos)

**VS Code:**
- ✅ `.vscode/tasks.json` (reducido a 3-4 tareas esenciales)

---

### 4.2 Qué Archivar (Mover a Histórico)

#### 📦 ARCHIVAR → docs/archive/2025-10/

**Documentos de fase cerrada:**

```bash
# Fase 4 IA Visual (cerrada)
_reports/FASE4/consolidacion_ia_visual_registro_capas.md
_reports/FASE4/diseño_flujo_consolidacion.md
_reports/DIAGNOSTICO_IA_VISUAL_FASE4D.md

# Fase 7 Conexión WordPress (cerrada)
docs/RUNBOOK_FASE7_PREVIEW_PRIMERO.md
docs/CHECKLIST_EJECUTIVA_FASE7.md
issues/Issue_50_Fase7_Conexion_WordPress_Real.md

# Bitácoras investigación UI/Roles (consolidadas)
docs/ui_roles/BITACORA_INVESTIGACION_BRIEFING_V2.md
docs/ui_roles/PLAN_INVESTIGACION_UI_ROLES.md
```

**Reportes post-PR:**

```bash
docs/_meta/post_pr04_preparation.md
docs/_meta/post_pr05_status.md
docs/_meta/post_pr06_status.md
```

**Consolidación producción:**

```bash
_reports/consolidacion_prod/20251007T*/*.md  # Snapshots antiguos
_reports/consolidacion_prod/20251008T*/*.md
```

**Motivo:** Fases completadas, valor principalmente histórico, no se consultan en operación diaria.

---

### 4.3 Qué Eliminar (Redundante o Obsoleto)

#### 🗑️ ELIMINAR — Duplicados y Legacy

**1. Datos IA-Visual redundantes:**

```bash
# ❌ ELIMINAR (redundancia 400%)
rm -rf plugins/runart-ia-visual-unified/data/assistants/rewrite/
rm -rf tools/runart-ia-visual-unified/data/assistants/rewrite/
rm -rf tools/data_ia/assistants/rewrite/

# ✅ MANTENER solo WordPress
wp-content/runart-data/assistants/rewrite/  # Fuente de verdad

# ✅ MANTENER snapshot Git (solo lectura)
data/assistants/rewrite/  # Backup en Git
```

**Impacto:**
- Ahorro de espacio: 174 KB
- Eliminación de riesgo de desincronización
- Simplificación de mantenimiento

**2. Workers legacy:**

```bash
# ❌ ELIMINAR (migrado a Pages Functions)
rm -rf apps/briefing/workers/

# ✅ MANTENER
apps/briefing/functions/api/  # Versión actual
```

**3. Herramientas duplicadas:**

```bash
# ❌ ELIMINAR (copia del plugin)
rm -rf tools/runart-ia-visual-unified/

# ✅ MANTENER
plugins/runart-ia-visual-unified/  # Plugin oficial
```

**4. Workflow obsoleto:**

```bash
# ❌ ELIMINAR (28 ejecuciones fallidas, legacy)
.github/workflows/overlay-deploy.yml

# Motivo: Migrado a Pages Functions, no usa workers.dev
```

**5. Configuraciones temporales:**

```bash
# ❌ ELIMINAR
apps/briefing/.env.local        # (gitignored, solo desarrollo)
apps/briefing/_tmp/*            # (temporal)
apps/briefing/_logs/*           # (logs viejos >30 días)
```

---

### 4.4 Qué Separar (Modularizar)

#### 🔀 SEPARAR — Mejorar Organización

**1. Etiquetado y Taxonomía → Documento Maestro**

Crear: `docs/live/TAXONOMIA_MASTER.md`

Consolidar:
- Taxonomías WordPress (CPTs)
- Frontmatter estándar
- Labels GitHub
- Metadata JSON (IA Visual)

```markdown
# Taxonomía Master — RunArt Foundry

## 1. Documentación (Frontmatter)
status, owner, updated, audience, tags

## 2. WordPress (CPTs y Taxonomías)
artist, technique, alloy, patina, year, client_type

## 3. GitHub (Labels)
deployment-approved, staging-complete, scope/*

## 4. IA Visual (Metadata JSON)
alt, title, description, shot_type, rights
```

**2. Integraciones IA → Documento Único**

Crear: `docs/live/INTEGRACIONES_IA.md`

Consolidar:
- Plugin IA Visual Unificado
- Traducción automática (workflow)
- Correlación imagen-texto (CLIP)
- Application passwords (autenticación)

**3. Reducir tareas VS Code**

Editar: `.vscode/tasks.json`

```json
{
  "tasks": [
    {
      "label": "🔧 Validación Staging Completa",
      "command": "./tools/staging_full_validation.sh"
    },
    {
      "label": "🚀 Deploy Briefing (Local Preview)",
      "command": "make -C apps/briefing serve-local"
    },
    {
      "label": "🧪 Tests Smoke Briefing",
      "command": "make -C apps/briefing test-logs"
    }
  ]
}
```

**Reducción:** 7 → 3 tareas (solo las usadas frecuentemente)

---

### 4.5 Plan de Limpieza (Orden de Ejecución)

#### FASE 1: Backup y Preparación (1 día)

```bash
# 1. Crear snapshot completo
git add -A
git commit -m "chore: snapshot pre-limpieza briefing"
git tag snapshot-briefing-2025-10-31
git push origin snapshot-briefing-2025-10-31

# 2. Crear rama de limpieza
git checkout -b chore/limpieza-briefing-optimizacion

# 3. Documentar estado actual
cp informe_inventario_briefing.md _reports/
```

#### FASE 2: Eliminaciones Seguras (2 días)

```bash
# 1. Eliminar datos redundantes IA-Visual
rm -rf plugins/runart-ia-visual-unified/data/assistants/rewrite/
rm -rf tools/runart-ia-visual-unified/
rm -rf tools/data_ia/

# 2. Eliminar workers legacy
rm -rf apps/briefing/workers/

# 3. Eliminar workflow obsoleto
rm .github/workflows/overlay-deploy.yml

# 4. Commit parcial
git add -A
git commit -m "chore: eliminar duplicados IA-Visual y workers legacy"
```

#### FASE 3: Archivado (1 día)

```bash
# 1. Crear estructura histórica
mkdir -p docs/archive/2025-10/fase4-ia-visual
mkdir -p docs/archive/2025-10/fase7-wordpress
mkdir -p docs/archive/2025-10/ui-roles

# 2. Mover documentos de fases cerradas
mv _reports/FASE4/*.md docs/archive/2025-10/fase4-ia-visual/
mv docs/RUNBOOK_FASE7_*.md docs/archive/2025-10/fase7-wordpress/
mv docs/ui_roles/BITACORA_*.md docs/archive/2025-10/ui-roles/

# 3. Actualizar enlaces (buscar referencias rotas)
grep -r "FASE4/consolidacion" docs/live/

# 4. Commit archivado
git add -A
git commit -m "chore: archivar documentación fases cerradas (Oct 2025)"
```

#### FASE 4: Consolidación Taxonomía (1 día)

```bash
# 1. Crear documentos maestros
cat > docs/live/TAXONOMIA_MASTER.md << 'EOF'
# (ver sección 4.4)
EOF

cat > docs/live/INTEGRACIONES_IA.md << 'EOF'
# (ver sección 4.4)
EOF

# 2. Commit consolidación
git add docs/live/TAXONOMIA_MASTER.md
git add docs/live/INTEGRACIONES_IA.md
git commit -m "docs: consolidar taxonomía e integraciones IA"
```

#### FASE 5: Optimización VS Code (30 min)

```bash
# 1. Reducir tasks.json
# (editar manualmente siguiendo sección 4.4)

# 2. Commit optimización
git add .vscode/tasks.json
git commit -m "chore: optimizar tareas VS Code (7→3)"
```

#### FASE 6: Validación y Merge (1 día)

```bash
# 1. Ejecutar smoke tests
make -C apps/briefing test-logs

# 2. Validar staging
./tools/staging_full_validation.sh

# 3. Validar builds
make -C apps/briefing build

# 4. PR y revisión
git push origin chore/limpieza-briefing-optimizacion
gh pr create --title "chore: optimización sistema briefing" \
  --body "Ver informe_inventario_briefing.md"

# 5. Merge tras aprobación
gh pr merge --squash
```

**Duración estimada:** 5-6 días  
**Riesgo:** Bajo (con backups y validaciones)  
**Impacto:** Alto (reducción >60% redundancia)

---

## 5. Detección de Sobrecarga VS Code

### 5.1 Análisis de Tasks

**Estado actual:** `.vscode/tasks.json`

**Tareas definidas:** 7

| # | Tarea | Frecuencia uso | Mantener |
|---|-------|----------------|----------|
| 1 | Fase7: Collect Evidence | Baja (fase cerrada) | ❌ Eliminar |
| 2 | Fase7: Process Evidence | Baja (fase cerrada) | ❌ Eliminar |
| 3 | IONOS: Create Staging | Media | ⚠️ Evaluar |
| 4 | Auditoría Aislamiento Staging | Baja | ❌ Mover a docs |
| 5 | Reparación Automática | Baja (emergencias) | ❌ Mover a docs |
| 6 | Reparación Final (Raíz) | Baja (emergencias) | ❌ Mover a docs |
| 7 | 🧩 AUTO-DETECT (default) | Media-Alta | ✅ MANTENER |

**Recomendación:**
- ✅ Mantener solo la tarea 7 (AUTO-DETECT)
- ✅ Agregar tarea de preview briefing local
- ✅ Agregar tarea de smoke tests
- ❌ Eliminar tareas de fase 7 (completada)
- ❌ Eliminar tareas de reparación (usar Makefile o scripts directos)

### 5.2 Extensiones y Configuraciones

**Archivos VS Code:**
```
.vscode/
└── tasks.json  # Solo este archivo existe
```

**No detectados:**
- ❌ `settings.json` (no existe - bien)
- ❌ `extensions.json` (no existe - bien)
- ❌ `launch.json` (no existe - bien)

**Conclusión:** Configuración VS Code es mínima y no sobrecargada.

### 5.3 Watchdogs y Auto-builds

**MkDocs serve:**
```bash
# Comando manual (no automático al abrir VS Code)
make -C apps/briefing serve

# Con hot-reload
mkdocs serve --config-file apps/briefing/mkdocs.yml
```

**No hay:**
- ❌ Watchdogs automáticos al abrir proyecto
- ❌ Pre-commit hooks pesados
- ❌ Builds automáticos en background

**Estado:** ✅ Sin sobrecarga de procesos automáticos

---

## 6. Métricas del Análisis

### 6.1 Cobertura de Búsqueda

**Términos buscados:** 38 palabras clave

| Categoría | Matches | Archivos únicos |
|-----------|---------|-----------------|
| briefing | 200+ | 672 |
| capas (modelo 3) | 3 | 3 |
| metadata/metadatos | 200+ | ~150 |
| taxonomía/etiquetado | 200+ | ~80 |
| overlay/worker | 200+ | ~60 |
| application password | 173 | ~50 |
| consolidación IA | 12 | 51 |
| READ_ONLY/DRY_RUN | 101 | ~30 |

**Total de archivos analizados:** ~900+

### 6.2 Duplicidad Detectada

| Elemento | Instancias | Redundancia | Tamaño |
|----------|------------|-------------|--------|
| Datos IA-Visual | 5 capas | 400% | 217.5 KB |
| Sistema Briefing | 2 (legacy+actual) | 100% | N/A |
| Workers API | 2 (workers+functions) | 100% | ~50 KB |
| Plugin IA tools/ | 2 (plugin+copia) | 100% | ~2 MB |

**Total redundancia:** ~2.4 MB eliminables

### 6.3 Estado de Archivos

**Por categoría:**

```
✅ ACTIVOS (operativos):
- apps/briefing/               # Micrositio
- docs/live/                   # Documentación vigente
- .github/workflows/           # Workflows CI/CD (activos)
- plugins/runart-*             # Plugins WordPress
- tools/*.sh, *.py             # Scripts operativos

⚠️ CANDIDATOS A ARCHIVAR:
- _reports/FASE4/              # Fase cerrada
- docs/ui_roles/BITACORA_*     # Investigaciones completadas
- docs/_meta/post_pr*          # PRs antiguas

❌ ELIMINAR:
- apps/briefing/workers/       # Migrado
- tools/runart-ia-visual*/     # Duplicado
- plugins/*/data/*/            # Redundante
- .github/workflows/overlay-   # Legacy fallido
```

### 6.4 Impacto de Optimización

**Antes:**
- Archivos de briefing: 672
- Datos redundantes: 217.5 KB
- Tareas VS Code: 7
- Workflows activos: 15+ (algunos legacy)

**Después (proyectado):**
- Archivos de briefing: ~550 (-18%)
- Datos redundantes: 43.5 KB (-80%)
- Tareas VS Code: 3 (-57%)
- Workflows activos: 12 (limpios)

**Beneficios:**
- ⚡ Reducción 60% redundancia datos
- ⚡ Reducción 57% tareas VS Code
- ⚡ Eliminación 100% riesgo desincronización capas
- ⚡ Simplificación mantenimiento documentación
- ⚡ Claridad arquitectura briefing

---

## 7. Conclusiones y Próximos Pasos

### 7.1 Estado Actual del Sistema

**Fortalezas identificadas:**

✅ **Sistema Briefing maduro y funcional**
- Micrositio operativo con segmentación por roles
- Integración status.json automatizada
- Tests y smoke tests activos
- Documentación bien estructurada (modelo 3 capas)

✅ **Automatización robusta**
- Workflows CI/CD con guards de seguridad (READ_ONLY/DRY_RUN)
- Rotación automática de passwords
- Traducción IA integrada
- Deploy controlado por labels

✅ **Integraciones sólidas**
- WordPress REST API funcional
- Application passwords bien gestionados
- Plugin IA Visual operativo
- Bridge API documentado

**Debilidades detectadas:**

❌ **Redundancia significativa**
- 5 capas de datos IA-Visual (400% duplicado)
- Workers legacy no eliminados
- Copia de herramientas en tools/
- Documentación de fases cerradas sin archivar

❌ **Falta de consolidación**
- Taxonomía dispersa en múltiples archivos
- Integraciones IA sin documento único
- Etiquetado sin referencia centralizada

❌ **Configuración VS Code mejorable**
- 7 tareas (4 de ellas de fase cerrada)
- Tareas administrativas mezcladas con desarrollo

### 7.2 Prioridades de Acción

**ALTA PRIORIDAD (Semana 1-2):**

1. ✅ **Eliminar datos redundantes IA-Visual**
   - Tiempo: 1 día
   - Impacto: Alto (elimina 174 KB + riesgo desincronización)
   - Riesgo: Bajo (con backup)

2. ✅ **Consolidar taxonomía y etiquetado**
   - Tiempo: 1 día
   - Impacto: Alto (mejora mantenibilidad)
   - Riesgo: Bajo

3. ✅ **Optimizar tareas VS Code**
   - Tiempo: 30 min
   - Impacto: Medio (reduce fricción desarrollo)
   - Riesgo: Muy bajo

**MEDIA PRIORIDAD (Semana 3-4):**

4. ✅ **Archivar documentación fases cerradas**
   - Tiempo: 1 día
   - Impacto: Medio (claridad docs)
   - Riesgo: Bajo

5. ✅ **Eliminar workers legacy**
   - Tiempo: 2 horas
   - Impacto: Medio (limpieza)
   - Riesgo: Bajo (ya migrado)

6. ✅ **Crear documento integraciones IA**
   - Tiempo: 1 día
   - Impacto: Medio (documentación)
   - Riesgo: Muy bajo

**BAJA PRIORIDAD (Mes 2):**

7. ⚠️ **Automatizar detección duplicados**
   - Script para detectar archivos idénticos
   - Validación pre-commit

8. ⚠️ **Dashboard de salud del briefing**
   - Métricas de uso
   - Estado de sincronización capas

### 7.3 Métricas de Éxito

**KPIs post-optimización:**

| Métrica | Actual | Objetivo | Método medición |
|---------|--------|----------|-----------------|
| Redundancia datos | 217.5 KB | 43.5 KB | `du -sh` |
| Tareas VS Code | 7 | 3 | `jq length .vscode/tasks.json` |
| Docs archivadas | 0 | 15+ | `ls docs/archive/2025-10/ \| wc -l` |
| Tiempo build | ~45s | ~30s | `time make build` |
| Claridad arquitectura | ⚠️ | ✅ | Revisión manual |

### 7.4 Recomendación Final

**Ejecutar plan de limpieza en este orden:**

1. **Semana 1:** FASE 1-2 (backup + eliminaciones)
2. **Semana 2:** FASE 3-4 (archivado + consolidación)
3. **Semana 3:** FASE 5-6 (optimización + validación)

**Tiempo total estimado:** 15-18 horas distribuidas en 3 semanas

**Riesgo:** ⚠️ Bajo (con backups y validaciones continuas)

**Impacto:** ✅ Alto (reducción 60% redundancia, mejora mantenibilidad)

**Aprobación requerida:**
- Owner: reinaldo.capiro
- Validación: Smoke tests post-limpieza
- Deploy: Solo tras PR aprobado con label `deployment-approved`

---

## 8. Referencias

### 8.1 Documentos Clave

**Briefing:**
- `apps/briefing/README_briefing.md` — Documentación micrositio
- `docs/live/briefing_canonical_source.md` — Fuente de verdad
- `apps/briefing/docs/briefing_arquitectura.md` — Arquitectura técnica

**Capas y Consolidación:**
- `_reports/FASE4/consolidacion_ia_visual_registro_capas.md` — Inventario 5 capas
- `docs/_meta/governance.md` — Modelo 3 capas documentación
- `docs/_meta/phase1_summary.md` — Creación modelo capas

**Integraciones:**
- `docs/Bridge_API.md` — WordPress REST API
- `docs/integration_briefing_status/plan_briefing_status_integration.md` — Status.json
- `PLAN_MAESTRO_IA_VISUAL_RUNART.md` — Plan maestro IA Visual

**Automatización:**
- `.github/workflows/briefing_deploy.yml` — Deploy micrositio
- `.github/workflows/briefing-status-publish.yml` — Status + posts
- `tools/deploy_wp_ssh.sh` — Deploy WordPress con guards

### 8.2 Comandos Útiles

**Búsqueda:**
```bash
# Buscar referencias a "briefing"
grep -r "briefing" --include="*.md" docs/ apps/

# Encontrar archivos duplicados
fdupes -r data/ wp-content/ plugins/ tools/

# Listar archivos >90 días sin modificar
find docs/live -name "*.md" -mtime +90
```

**Validación:**
```bash
# Smoke tests briefing
make -C apps/briefing test-logs

# Validación staging completa
./tools/staging_full_validation.sh

# Build briefing
make -C apps/briefing build
```

**Métricas:**
```bash
# Tamaño de datos redundantes
du -sh data/ wp-content/runart-data/ plugins/*/data/ tools/*/data/

# Contar archivos briefing
find apps/briefing -type f | wc -l

# Listar tareas VS Code
jq '.tasks[].label' .vscode/tasks.json
```

---

## Apéndice A: Glosario

**Briefing:** Micrositio privado MkDocs Material para documentación interna del proyecto RunArt Foundry.

**Capa:** Nivel de organización documental (activa/histórica/meta) o de datos (Git/WordPress/Plugin/Tools/Temporal).

**Application Password:** Método de autenticación WordPress 5.6+ para REST API sin exponer contraseña principal.

**Pages Functions:** Cloudflare serverless functions integradas en Pages (sustituto de Workers).

**READ_ONLY:** Variable de entorno que previene modificaciones en staging/producción.

**DRY_RUN:** Variable de entorno que simula operaciones sin ejecutarlas realmente.

**Frontmatter:** Bloque YAML al inicio de archivos Markdown con metadatos (status, owner, tags).

**Taxonomía:** Sistema de clasificación de contenido (WordPress CPTs) o documentación (tags).

**Consolidación:** Proceso de reducir duplicidad eligiendo una fuente de verdad única.

**Overlay:** Worker Cloudflare que intercepta requests (legacy, migrado a Pages Functions).

---

## Apéndice B: Listado Completo de Archivos

**Briefing (apps/briefing/) - 672 archivos**

```
(Ver lista completa en file_search results)
Principales:
- README_briefing.md
- mkdocs.yml
- functions/api/*.js (3 archivos)
- docs/client_projects/
- docs/internal/briefing_system/
- scripts/*.sh, *.mjs
- _reports/tests/
```

**Consolidación (_reports/FASE4/) - 3 archivos**

```
- consolidacion_ia_visual_registro_capas.md (18 KB, 568 líneas)
- diseño_flujo_consolidacion.md
- CIERRE_FASE4D_CONSOLIDACION.md
```

**Integraciones (docs/integration_briefing_status/) - 2 archivos**

```
- briefing_status_integration_research.md (14 KB)
- plan_briefing_status_integration.md (17 KB, 607 líneas)
```

**Workflows (.github/workflows/) - 15 archivos**

```
Activos:
- briefing_deploy.yml
- briefing-status-publish.yml
- auto_translate_content.yml
- rotate-app-password.yml

Legacy:
- overlay-deploy.yml (❌ 28 fallos, deprecar)
```

---

**FIN DEL INFORME**

---

**Generado por:** GitHub Copilot  
**Fecha:** 2025-10-31  
**Versión:** 1.0  
**Rama:** feat/ai-visual-implementation  
**Commit base:** (pendiente de snapshot)

**Próxima acción:** Revisión con owner y aprobación de plan de limpieza
