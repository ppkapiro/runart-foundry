---
status: active
owner: reinaldo.capiro
updated: 2025-10-23
audience: internal
tags: [briefing, runart, ops]
---

# Proyecto RUN Art Foundry — Estructura y Gobernanza
**Fecha de creación**: 2 de octubre de 2025  
**Última actualización**: 2 de octubre de 2025  
**Propósito**: Documento maestro de organización del repositorio, reglas de colocación de archivos y control de cambios

---

## 1. Mapa Actual del Repositorio

### Resumen Ejecutivo

El proyecto **RUN Art Foundry** es un **monorepo** que contiene múltiples "cámaras" o módulos independientes:

| Módulo | Propósito | Tamaño | Estado |
|--------|-----------|--------|--------|
| **briefing/** | Micrositio privado (MkDocs Material) con Cloudflare Pages + Access | 157 MB | ✅ Operativo |
| **audits/** | Auditorías del sitio del cliente (rendimiento, SEO, accesibilidad) | 5.5 MB | ✅ Operativo |
| **mirror/** | Snapshots del sitio del cliente (descargas SFTP/wget) | 760 MB | ⚠️ Contiene 759 MB de wp-content |
| **docs/** | Documentación del proyecto (especificaciones, gobernanza) | 8 KB | 📝 En construcción |
| **source/** | Código editable (temas/plantillas) del sitio del cliente | 4 KB | 📦 Vacío/preparado |
| **.tools/** | Dependencias npm para auditorías (Lighthouse, Axe) | 237 MB | ⚠️ node_modules pesado |

**Total del repositorio**: ~1.16 GB

### Hallazgos Clave (Desorden Detectado)

1. **🔴 Mirror con 759 MB de wp-content**: `mirror/raw/2025-10-01/wp-content` contiene archivos binarios pesados (imágenes, plugins, uploads) que NO deberían ir a Git.

2. **⚠️ .tools/node_modules con 237 MB**: Dependencias de Lighthouse/Axe correctamente ignoradas en `.gitignore`, pero ocupan espacio local significativo.

3. **⚠️ briefing/site/ compilado (2.7 MB)**: Carpeta de build de MkDocs que NO debe subirse a Git (ya está en `.gitignore`).

4. **📋 Reporte suelto en raíz**: `cloudflare_repo_fs_overview.md` (12 KB) en raíz — debería estar en `docs/` o `briefing/_reports/`.

5. **⚠️ .env en raíz**: Archivo `.env` (384 bytes) con credenciales — correctamente ignorado en `.gitignore` pero presente localmente.

6. **✅ Logs correctamente ignorados**: `audits/*.log`, `briefing/_logs/*.txt` están en `.gitignore`, no irán a Git.

### Árbol de Directorios (Niveles 1-3)

**Ver árbol completo**: [docs/_artifacts/repo_tree.txt](/_artifacts/repo_tree.txt)

**Resumen estructurado**:

```
runartfoundry/
├── .github/                         # (NO existe en raíz, solo en briefing/)
├── .tools/                          # Dependencias npm para auditorías
│   ├── node_modules/                # 237 MB (ignorado en .gitignore)
│   ├── package.json
│   └── package-lock.json
├── audits/                          # Auditorías del sitio del cliente
│   ├── _structure/                  # Análisis de estructura (CSV, TXT)
│   ├── inventory/                   # Plugins, temas, imágenes pesadas
│   ├── reports/                     # Informes estratégicos/técnicos
│   ├── seo/                         # Auditoría SEO (títulos, H1, meta)
│   ├── axe/                         # (vacío, futuro: accesibilidad)
│   ├── lighthouse/                  # (vacío, futuro: Core Web Vitals)
│   ├── scripts/                     # (vacío, futuro: scripts de auditoría)
│   ├── security/                    # (vacío, futuro: análisis seguridad)
│   ├── *.md                         # Reportes de auditoría con fecha
│   ├── *.log                        # Logs de ejecución (ignorados)
│   ├── README.md
│   └── checklist.md
├── briefing/                        # Micrositio privado (Cloudflare Pages)
│   ├── .github/workflows/           # CI/CD con cloudflare/pages-action
│   │   └── briefing_pages.yml
│   ├── _logs/                       # Logs de deployment (ignorados)
│   ├── _reports/                    # Reportes del briefing (Access, etc.)
│   │   ├── README.md
│   │   ├── cloudflare_access_*.md   # 4 reportes de configuración Access
│   │   └── zero_trust_*.md
│   ├── docs/                        # Contenido Markdown del micrositio
│   │   ├── acerca/
│   │   ├── auditoria/
│   │   ├── decisiones/
│   │   ├── fases/
│   │   ├── galeria/
│   │   ├── inbox/
│   │   ├── plan/
│   │   ├── proceso/
│   │   ├── index.md
│   │   └── robots.txt
│   ├── functions/api/               # Pages Functions (serverless endpoints)
│   │   ├── decisiones.js            # POST /api/decisiones → KV
│   │   ├── inbox.js                 # GET /api/inbox → lista KV
│   │   └── whoami.js                # GET /api/whoami → diagnóstico Access
│   ├── overrides/                   # Personalizaciones MkDocs Material
│   │   ├── extra.css
│   │   └── main.html
│   ├── workers/                     # (obsoleto, migrado a Pages Functions)
│   │   ├── decisiones.js
│   │   └── wrangler.toml
│   ├── site/                        # Build de MkDocs (ignorado, 2.7 MB)
│   ├── mkdocs.yml                   # Config MkDocs
│   ├── wrangler.toml                # Config Cloudflare Pages (ACTIVO)
│   └── README_briefing.md
├── docs/                            # Documentación del proyecto
│   ├── _artifacts/                  # Artefactos generados (árboles, etc.)
│   │   └── repo_tree.txt
│   ├── proyecto_estructura_y_gobernanza.md  # Este documento
│   └── README.md
├── mirror/                          # Snapshots del sitio del cliente
│   ├── normalized/                  # (vacío, futuro: archivos procesados)
│   └── raw/                         # Descargas brutas
│       └── 2025-10-01/              # Snapshot del 1 de octubre
│           ├── db_dump.sql          # 0 bytes (vacío)
│           ├── site_static/         # 956 KB
│           └── wp-content/          # 759 MB (plugins, uploads, themes)
├── source/                          # Código editable del cliente (vacío)
├── .env                             # Credenciales (ignorado en .gitignore)
├── .env.example                     # Plantilla de variables de entorno
├── .gitignore                       # Exclusiones de Git
├── README.md                        # README principal
├── cloudflare_repo_fs_overview.md   # Reporte suelto (mover a docs/)
├── escaneo_estructura_completa.sh   # Script de análisis
├── fase3_auditoria.sh               # Script de auditoría completa
├── fase3_auditoria_simplificada.sh  # Script de auditoría simplificada
├── generar_informes_maestros.sh     # Script de generación de informes
└── test_lighthouse.sh               # Script de prueba Lighthouse
```

---

## 2. Estructura Objetivo (Propuesta)

### Principios de Organización

1. **Separación de responsabilidades**: Cada módulo debe ser autocontenido.
2. **Un archivo por tarea, siempre sobrescribible**: No crear versiones `_v2`, `_backup`, `_final` — usar Git para historial.
3. **Prefijos de fecha ISO**: Archivos con timestamp → formato `YYYY-MM-DD_nombre.ext`.
4. **Ubicación predecible**: Un tipo de archivo = una ubicación. Nunca dispersar reportes, logs o configs.
5. **Ignorar artefactos generados**: Carpetas de build, node_modules, logs → `.gitignore`.

### Estructura Objetivo Detallada

```
runartfoundry/                       # Raíz del proyecto
├── .github/                         # GitHub Actions (workflows del monorepo)
│   └── workflows/
│       ├── briefing_pages.yml       # CI/CD del micrositio briefing
│       └── audits.yml               # (futuro) CI para auditorías automatizadas
│
├── .tools/                          # Herramientas npm para auditorías
│   ├── node_modules/                # (ignorado, 237 MB)
│   ├── package.json
│   └── package-lock.json
│
├── audits/                          # Auditorías del sitio del cliente
│   ├── _logs/                       # Logs de ejecución (ignorados)
│   ├── _structure/                  # Análisis estructural (CSV, TXT)
│   ├── inventory/                   # Inventarios (plugins, temas, imágenes)
│   ├── reports/                     # Informes estratégicos y técnicos
│   │   ├── YYYY-MM-DD_informe_tecnico.md
│   │   └── YYYY-MM-DD_informe_estrategico.md
│   ├── seo/                         # Auditoría SEO
│   │   ├── YYYY-MM-DD_titulos.txt
│   │   ├── YYYY-MM-DD_sin_meta_description.txt
│   │   └── YYYY-MM-DD_multiples_h1.txt
│   ├── performance/                 # (futuro) Lighthouse, Core Web Vitals
│   ├── accessibility/               # (futuro) Axe, WCAG
│   ├── security/                    # (futuro) Análisis de vulnerabilidades
│   ├── scripts/                     # Scripts de auditoría
│   │   ├── run_lighthouse.sh
│   │   ├── run_axe.sh
│   │   └── analyze_seo.sh
│   ├── README.md                    # Documentación del módulo audits
│   └── checklist.md                 # Checklist de auditoría
│
├── briefing/                        # Micrositio privado (Cloudflare Pages)
│   ├── .github/workflows/           # CI/CD del briefing
│   │   └── briefing_pages.yml
│   ├── _logs/                       # Logs de deployment (ignorados)
│   ├── _reports/                    # Reportes del briefing (Access, etc.)
│   │   ├── README.md
│   │   ├── cloudflare_access_audit.md
│   │   ├── cloudflare_access_plan.md
│   │   ├── cloudflare_access_closure.md
│   │   └── zero_trust_pin_diagnostics.md
│   ├── docs/                        # Contenido Markdown del micrositio
│   │   ├── (secciones del micrositio)
│   │   └── index.md
│   ├── functions/api/               # Pages Functions (serverless)
│   │   ├── decisiones.js
│   │   ├── inbox.js
│   │   └── whoami.js
│   ├── overrides/                   # Personalizaciones MkDocs Material
│   │   ├── extra.css
│   │   └── main.html
│   ├── site/                        # (ignorado) Build de MkDocs
│   ├── mkdocs.yml                   # Config MkDocs
│   ├── wrangler.toml                # Config Cloudflare Pages
│   └── README_briefing.md
│
├── docs/                            # Documentación del proyecto
│   ├── _artifacts/                  # Artefactos generados (árboles, etc.)
│   │   └── repo_tree.txt
│   ├── proyecto_estructura_y_gobernanza.md  # Este documento
│   ├── cloudflare_repo_fs_overview.md       # (mover aquí desde raíz)
│   └── README.md
│
├── mirror/                          # Snapshots del sitio del cliente
│   ├── normalized/                  # Archivos procesados/normalizados
│   │   └── YYYY-MM-DD/
│   └── raw/                         # Descargas brutas (NO subir binarios pesados)
│       └── YYYY-MM-DD/
│           ├── db_dump.sql          # (considerar compresión .sql.gz)
│           ├── site_static/         # HTML estático
│           └── wp-content/          # ⚠️ NO subir a Git si >25 MB
│
├── source/                          # Código editable del cliente
│   ├── themes/                      # (futuro) Temas personalizados
│   └── plugins/                     # (futuro) Plugins personalizados
│
├── scripts/                         # Scripts globales del proyecto
│   ├── escaneo_estructura_completa.sh
│   ├── fase3_auditoria.sh
│   ├── fase3_auditoria_simplificada.sh
│   ├── generar_informes_maestros.sh
│   └── test_lighthouse.sh
│
├── tmp/                             # Artefactos temporales (ignorado)
├── .env                             # Variables de entorno (ignorado)
├── .env.example                     # Plantilla de .env (SÍ subir)
├── .gitignore                       # Exclusiones de Git
├── LICENSE                          # (futuro) Licencia del proyecto
└── README.md                        # README principal
```

### Cambios Propuestos

| Cambio | Razón |
|--------|-------|
| **Mover `cloudflare_repo_fs_overview.md` de raíz a `docs/`** | Reportes de documentación NO van en raíz |
| **Mover scripts de raíz a `scripts/`** | Agrupar scripts ejecutables en una carpeta dedicada |
| **Crear `audits/performance/`, `audits/accessibility/`** | Preparar para futuras auditorías Lighthouse/Axe |
| **Crear `mirror/_ignore_large_files.txt`** | Lista de rutas a NO subir (wp-content/uploads/, etc.) |
| **Crear `.github/` en raíz** | Mover workflow de `briefing/.github/` al nivel superior si hay múltiples workflows |
| **Añadir `tmp/` a `.gitignore`** | Carpeta para artefactos temporales |

---

## 3. Reglas de Colocación de Archivos

### Tabla de Decisión: ¿Dónde va este archivo?

| Tipo de Archivo | Ubicación | Ejemplo | Sube a Git |
|-----------------|-----------|---------|------------|
| **Reportes del micrositio** | `briefing/_reports/` | `cloudflare_access_closure.md` | ✅ Sí |
| **Reportes de auditoría** | `audits/reports/` | `2025-10-01_informe_tecnico.md` | ✅ Sí |
| **Logs de auditoría** | `audits/_logs/` o `briefing/_logs/` | `2025-10-01_db_check.log` | ❌ No (.gitignore) |
| **Snapshots del sitio (texto)** | `mirror/raw/YYYY-MM-DD/` | `db_dump.sql`, `index.html` | ✅ Sí (si <25 MB) |
| **Snapshots del sitio (binarios)** | `mirror/raw/YYYY-MM-DD/` | `wp-content/uploads/*.jpg` | ❌ No (>25 MB) |
| **Documentación del proyecto** | `docs/` | `proyecto_estructura_y_gobernanza.md` | ✅ Sí |
| **Scripts ejecutables** | `scripts/` (raíz) o `audits/scripts/` | `fase3_auditoria.sh` | ✅ Sí |
| **Código del micrositio** | `briefing/docs/`, `briefing/functions/` | `index.md`, `decisiones.js` | ✅ Sí |
| **Build de MkDocs** | `briefing/site/` | `index.html` compilado | ❌ No (.gitignore) |
| **node_modules** | `.tools/node_modules/` | `lighthouse/` | ❌ No (.gitignore) |
| **Credenciales** | `.env`, `secrets/` | `.env`, `api_token.key` | ❌ No (.gitignore) |
| **Artefactos temporales** | `tmp/`, `sandbox/` | `test_output.txt` | ❌ No (.gitignore) |
| **Configs del proyecto** | Raíz o carpeta del módulo | `.gitignore`, `wrangler.toml` | ✅ Sí |

### Reglas de Nomenclatura

#### Carpetas
- **kebab-case**: `briefing/`, `audits/`, `mirror/` (minúsculas, guiones).
- **Prefijo `_` para metadatos**: `_logs/`, `_reports/`, `_structure/`, `_artifacts/` (indica que contiene artefactos generados o de soporte).

#### Archivos
- **Reportes con fecha**: `YYYY-MM-DD_descripcion.md` (ej: `2025-10-01_informe_tecnico.md`).
- **Logs con fecha**: `YYYY-MM-DD_operacion.log` (ej: `2025-10-01_db_check.log`).
- **Configs sin fecha**: `wrangler.toml`, `mkdocs.yml`, `.gitignore`.
- **Scripts ejecutables**: `verbo_sustantivo.sh` (ej: `generar_informes_maestros.sh`).
- **Markdown de documentación**: `sustantivo_y_contexto.md` (ej: `proyecto_estructura_y_gobernanza.md`).

### Prohibiciones Estrictas

| ❌ Prohibido | ✅ Permitido | Razón |
|-------------|-------------|-------|
| Reportes en raíz | Reportes en `docs/`, `briefing/_reports/`, `audits/reports/` | Organización |
| Logs en Git | Logs en `.gitignore` (`_logs/`) | No versionar salidas |
| Archivos >25 MB en Git | Storage externo o .gitignore | GitHub limita repos |
| `.env` con credenciales | `.env.example` sin credenciales | Seguridad |
| `node_modules/` en Git | `package.json` + `.gitignore` | Reproducibilidad |
| `site/` (MkDocs build) | `docs/` (fuente) + build en CI/CD | No versionar builds |
| Versiones `_v2`, `_final` | Un archivo sobrescribible + Git | Historial en Git |
| Nombres con espacios | `kebab-case` o `snake_case` | Compatibilidad shell |

### Límite de Tamaño por Archivo

- **≤ 1 MB**: Subir a Git sin restricciones.
- **1-10 MB**: Revisar si es necesario (logs, dumps).
- **10-25 MB**: Comprimir (.gz, .zip) o considerar exclusión.
- **≥ 25 MB**: **NO subir a Git**. Usar storage externo (Cloudflare R2, S3) o `.gitignore`.

**Ejemplo**: `mirror/raw/2025-10-01/wp-content/` (759 MB) → **NO va a Git**.

---

## 4. Control de Cambios

### Opción Recomendada: Monorepo

**Decisión**: Mantener **un solo repositorio** para todos los módulos (`briefing`, `audits`, `mirror`, `docs`).

#### Ventajas del Monorepo

| Beneficio | Justificación |
|-----------|---------------|
| **Control unificado** | Un solo `.gitignore`, un historial, una rama `main` |
| **Visibilidad cruzada** | Fácil referenciar `docs/` desde `briefing/_reports/` |
| **CI/CD simplificado** | Workflows en `.github/workflows/` con paths filters |
| **Menos overhead** | No sincronizar múltiples repos, no submodules |

#### Desventajas (Mitigadas)

| Desventaja | Mitigación |
|------------|------------|
| **Repo grande (1+ GB)** | `.gitignore` estricto: excluir `mirror/raw/`, `.tools/node_modules/`, `briefing/site/` |
| **Commits mezclados** | Usar paths filters en workflows + commits descriptivos |
| **Permisos granulares** | GitHub permite branch protection, CODEOWNERS para carpetas |

### Alternativa: Repos Separados (NO Recomendada)

Si los módulos tuvieran ciclos de vida **muy diferentes** (ej: `briefing` se despliega cada hora, `audits` se actualiza cada mes), podrían separarse:

- `runart-briefing` (micrositio Cloudflare Pages)
- `runart-audits` (auditorías del cliente)
- `runart-mirror` (snapshots del sitio)
- `runart-docs` (documentación interna)

**Consecuencias**:
- ❌ 4 repos → 4 `.gitignore`, 4 historiales, 4 ramas `main`.
- ❌ Dificultad para referenciar `docs/` desde `briefing/_reports/`.
- ❌ CI/CD más complejo (coordinar deployments entre repos).

**Conclusión**: **Mantener monorepo** con `.gitignore` estricto y workflows con path filters.

---

### Estrategia de Ramas

#### Rama Principal: `main`

- **Protección**: Requerir PR y aprobación para merge.
- **Commits directos**: Deshabilitados.
- **Estado**: Siempre "verde" (deployable).

#### Ramas de Trabajo

```
feature/nombre-descriptivo       # Nueva funcionalidad
fix/correccion-bug              # Corrección de bug
docs/actualizacion-documento    # Actualización de documentación
audit/YYYY-MM-DD-tipo           # Nueva auditoría
refactor/reorg-carpetas         # Refactorización de estructura
```

**Convención**: `tipo/descripcion-kebab-case`

#### Flujo de Trabajo

1. **Crear rama** desde `main`:
   ```bash
   git checkout -b feature/nueva-funcion-briefing
   ```

2. **Commits frecuentes** con mensajes descriptivos:
   ```bash
   git commit -m "briefing: Añadir endpoint /api/export-decisiones"
   ```

3. **Push a rama remota**:
   ```bash
   git push origin feature/nueva-funcion-briefing
   ```

4. **Crear Pull Request** en GitHub.

5. **Revisión** con checklist (ver más abajo).

6. **Merge a `main`** → CI/CD despliega automáticamente.

7. **Eliminar rama** tras merge.

---

### Convención de Commits

#### Formato

```
<módulo>: <verbo> <descripción corta>

<descripción detallada opcional>
```

#### Ejemplos

```
briefing: Añadir endpoint /api/whoami para diagnóstico Access
audits: Generar reporte 2025-10-02 con métricas Core Web Vitals
docs: Actualizar proyecto_estructura_y_gobernanza.md con reglas de tamaño
mirror: Excluir wp-content/uploads de snapshot 2025-10-02
scripts: Refactorizar fase3_auditoria.sh para soportar argumentos
```

#### Prefijos de Módulo

| Prefijo | Módulo |
|---------|--------|
| `briefing:` | Micrositio Cloudflare Pages |
| `audits:` | Auditorías del sitio del cliente |
| `mirror:` | Snapshots del sitio |
| `docs:` | Documentación del proyecto |
| `scripts:` | Scripts globales |
| `ci:` | GitHub Actions workflows |
| `chore:` | Tareas de mantenimiento (.gitignore, deps) |

---

### Protección de `main`

#### Reglas Sugeridas (GitHub Branch Protection)

```yaml
Rama: main
Protecciones:
  - Require a pull request before merging: ✅
    - Require approvals: 1 (o más si es equipo)
    - Dismiss stale reviews: ✅
  - Require status checks to pass: ✅
    - Status checks: briefing-build, audits-lint (si existen)
  - Require conversation resolution: ✅
  - Require signed commits: ⚠️ (opcional, aumenta seguridad)
  - Include administrators: ✅ (nadie bypasea las reglas)
```

---

### Workflows de CI/CD

#### Workflow Actual: `briefing/.github/workflows/briefing_pages.yml`

**Estado**: ✅ Configurado para deployment a Cloudflare Pages.

**Triggers**:
```yaml
on:
  push:
    paths:
      - 'briefing/**'
    branches: [ main ]
```

**Acción**: Build de MkDocs + deploy con `cloudflare/pages-action@v1`.

#### Workflow Futuro: `audits.yml` (Propuesta)

**Propósito**: Ejecutar auditorías automatizadas (Lighthouse, Axe) en PR.

```yaml
name: Run Audits
on:
  pull_request:
    paths:
      - 'audits/**'
jobs:
  lighthouse:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Lighthouse
        run: |
          cd .tools
          npm ci
          npx lighthouse https://runartfoundry.com --output=json --output-path=../audits/lighthouse/report.json
      - name: Upload report
        uses: actions/upload-artifact@v3
        with:
          name: lighthouse-report
          path: audits/lighthouse/report.json
```

---

## 5. Qué Sube y Qué NO Sube a GitHub

### Tabla de Decisión Completa

| Tipo de Archivo | ¿Sube a Git? | Ubicación | Motivo |
|-----------------|--------------|-----------|--------|
| **Código fuente** | ✅ Sí | `briefing/functions/`, `briefing/docs/` | Reproducibilidad |
| **Configs del proyecto** | ✅ Sí | `wrangler.toml`, `mkdocs.yml`, `.gitignore` | Configuración compartida |
| **Documentación** | ✅ Sí | `docs/`, `briefing/_reports/`, `audits/reports/` | Documentación del proyecto |
| **Scripts ejecutables** | ✅ Sí | `scripts/`, `audits/scripts/` | Automatización compartida |
| **Plantilla de .env** | ✅ Sí | `.env.example` | Sin credenciales |
| **Dependencias (package.json)** | ✅ Sí | `.tools/package.json`, `briefing/package.json` | Reproducibilidad |
| **Reportes de auditoría (texto)** | ✅ Sí | `audits/reports/*.md`, `audits/seo/*.txt` | Historial de auditorías |
| **Snapshots HTML estáticos (<25 MB)** | ✅ Sí | `mirror/raw/YYYY-MM-DD/site_static/` | Análisis de cambios |
| **Dumps SQL (<10 MB comprimidos)** | ✅ Sí (comprimidos) | `mirror/raw/YYYY-MM-DD/db_dump.sql.gz` | Backups livianos |
| **LICENSE, README** | ✅ Sí | Raíz | Metadatos del proyecto |
| **Logs de ejecución** | ❌ No | `audits/_logs/`, `briefing/_logs/` | Salidas no reproducibles |
| **Build de MkDocs** | ❌ No | `briefing/site/` | Generado en CI/CD |
| **node_modules** | ❌ No | `.tools/node_modules/` | 237 MB, reproducible |
| **.env con credenciales** | ❌ No | `.env` | Seguridad |
| **Binarios pesados (imágenes, videos)** | ❌ No | `mirror/raw/*/wp-content/uploads/` | >25 MB |
| **Archivos temporales** | ❌ No | `tmp/`, `sandbox/`, `*.tmp` | Artefactos locales |
| **Backups/Caches** | ❌ No | `.cache/`, `backup/`, `*.bak` | No versionables |
| **Secrets (tokens, keys)** | ❌ No | `secrets/`, `*.key`, `*.pem` | Seguridad |
| **Datos sensibles del cliente** | ❌ No | `mirror/raw/*/wp-config.php` | Credenciales DB |

### `.gitignore` Actual

**Estado**: ✅ Correctamente configurado para casos principales.

**Contenido actual**:
```gitignore
# Sensibles / entorno
.env
.env.*
secrets/
credentials/
*.key
*.pem

# Artefactos temporales
*.log
tmp/
.cache/
dist/
node_modules/
__pycache__/
*.pyc

# SO / Editor
.DS_Store
.vscode/
```

### `.gitignore` Propuesto (Actualizado)

**Añadir**:
```gitignore
# Sensibles / entorno
.env
.env.*
secrets/
credentials/
*.key
*.pem

# Artefactos temporales
*.log
tmp/
sandbox/
.cache/
dist/
node_modules/
__pycache__/
*.pyc
*.tmp
*.bak

# Builds generados
briefing/site/
**/site/
build/
out/

# Mirror: Excluir binarios pesados
mirror/raw/*/wp-content/uploads/
mirror/raw/*/wp-content/cache/
mirror/raw/*/wp-content/backup*/
mirror/raw/*/*.tar.gz
mirror/raw/*/*.zip

# Mirror: Excluir configs con credenciales
mirror/raw/*/wp-config.php
mirror/raw/*/.env

# Auditorías: Excluir logs y reportes binarios
audits/_logs/
audits/**/*.log
audits/**/*.pid

# Briefing: Excluir logs
briefing/_logs/
briefing/**/*.log

# SO / Editor
.DS_Store
.vscode/
.idea/
*.swp
*.swo
*~

# Lighthouse/Axe: Excluir reportes JSON grandes
audits/lighthouse/*.json
audits/axe/*.json
```

---

## 6. Checklist Previo a Commit/PR

### Checklist Individual (Antes de `git commit`)

```markdown
[ ] **Ubicación correcta**: ¿El archivo está en la carpeta adecuada según reglas de colocación?
[ ] **Nomenclatura**: ¿El archivo sigue convenciones (kebab-case, prefijo de fecha si aplica)?
[ ] **Tamaño**: ¿El archivo es <10 MB? (Si >10 MB, ¿está justificado o debería excluirse?)
[ ] **Contenido sensible**: ¿El archivo NO contiene credenciales, tokens, API keys, IPs privadas?
[ ] **Logs**: ¿Los archivos .log están en carpetas `_logs/` y excluidos en .gitignore?
[ ] **Build artifacts**: ¿NO estoy subiendo `site/`, `node_modules/`, `dist/`, `.cache/`?
[ ] **Mensaje de commit**: ¿El commit tiene prefijo de módulo y descripción clara? (ej: `briefing: Añadir endpoint /api/export`)
[ ] **Archivos relacionados**: ¿Actualicé README o documentación si corresponde?
[ ] **Tests locales**: ¿Probé el código localmente antes de commit? (si aplica)
```

### Checklist de Pull Request (Antes de Merge)

```markdown
[ ] **Título descriptivo**: PR tiene formato `[módulo] Verbo + descripción` (ej: `[briefing] Añadir autenticación JWT`)
[ ] **Descripción completa**: PR describe QUÉ cambia, POR QUÉ y CÓMO probar
[ ] **Checklist individual completado**: Todos los items del checklist individual están marcados
[ ] **Branch actualizada**: La rama está sincronizada con `main` (rebase o merge)
[ ] **Conflicts resueltos**: No hay conflictos de merge
[ ] **Tests pasan**: CI/CD (workflows) pasan sin errores
[ ] **Código revisado**: Al menos 1 reviewer aprobó el PR (si hay equipo)
[ ] **Documentación actualizada**: Si el PR cambia comportamiento, se actualizó `README.md` o `docs/`
[ ] **No rompe otros módulos**: Si el PR modifica código compartido, se verificó impacto en otros módulos
[ ] **Archivos excluidos**: `.gitignore` actualizado si se añaden nuevas carpetas/archivos temporales
[ ] **Tamaño del PR**: <500 líneas cambiadas (si >500, considerar dividir en PRs más pequeños)
```

### Checklist de Auditoría (Nuevo Snapshot/Reporte)

```markdown
[ ] **Fecha en nombre**: Archivos tienen prefijo `YYYY-MM-DD_` (ej: `2025-10-02_informe_tecnico.md`)
[ ] **Ubicación**: Reportes en `audits/reports/`, logs en `audits/_logs/`, datos en `audits/seo/`, etc.
[ ] **Logs excluidos**: Archivos `.log` están en `.gitignore` y NO se suben
[ ] **Tamaño de mirror**: Si hay snapshot en `mirror/raw/YYYY-MM-DD/`, verificar que NO incluye `wp-content/uploads/` (>25 MB)
[ ] **Compresión**: Dumps SQL están comprimidos (`.sql.gz`) si >5 MB
[ ] **README actualizado**: `audits/README.md` lista el nuevo reporte con fecha y resumen
[ ] **Checklist auditoría**: `audits/checklist.md` marcado con items completados
```

---

## 7. Apéndice: Árbol Expandido

**Ver árbol completo de directorios (niveles 1-3)**: [docs/_artifacts/repo_tree.txt](/_artifacts/repo_tree.txt)

**Generado**: 2 de octubre de 2025  
**Comando**: `tree -L 3 -F --dirsfirst -I 'node_modules|.git|__pycache__|*.pyc|site'`

---

## 8. Historial de Cambios de Este Documento

| Fecha | Versión | Cambios |
|-------|---------|---------|
| 2025-10-02 | 1.0 | Creación inicial del documento de gobernanza |

---

## 9. Referencias y Documentos Relacionados

| Documento | Ubicación | Propósito |
|-----------|-----------|-----------|
| **Árbol de directorios** | `docs/_artifacts/repo_tree.txt` | Estructura completa del repo |
| **README principal** | `README.md` | Introducción al proyecto |
| **README Briefing** | `briefing/README_briefing.md` | Documentación del micrositio |
| **README Audits** | `audits/README.md` | Documentación de auditorías |
| **Cloudflare Access Closure** | `briefing/_reports/cloudflare_access_closure.md` | Cierre de fase Access |
| **Cloudflare Repo Overview** | `cloudflare_repo_fs_overview.md` (raíz) | Análisis de estructura Cloudflare (mover a `docs/`) |

---

## 10. Contacto y Responsables

**Mantenedor del documento**: Equipo RUN Art Foundry  
**Última revisión**: 2 de octubre de 2025  
**Próxima revisión**: Tras próxima reorganización mayor o cada 3 meses

---

**Fin del documento**

---

## Bootstrap Git — Conexión a Repositorio

**Fecha**: 2025-10-02 15:10:24
**Repositorio**: `git@github.com:ppkapiro/runart-foundry.git`
**Rama inicial**: `main`

Estructura mínima confirmada, guardarraíles implementados, plantillas MIRROR creadas.
Repositorio listo para el primer commit y PR inicial.

---

## Bootstrap Git — Release Note

**Fecha**: 2025-10-02T15:30:00-03:00  
**PR Bootstrap**: #1 (merged)  
**Commits clave**:
- Base commit: `6c45ac7` (first commit)
- Bootstrap commit: `ea2e72b` (chore(bootstrap): estructura monorepo + guardarraíles + política MIRROR)
- Merge commit: `bfaf210` (Merge pull request #1)

**Estado**:
- ✅ PR #1 mergeado exitosamente
- ✅ 86 archivos añadidos (+65,562 líneas)
- ✅ CI/CD workflow "Structure & Governance Guard" ejecutado y pasado
- ✅ Guardarraíles implementados y funcionando
- ✅ Política MIRROR aplicada (sin payload en Git)
- ⚠️  Branch protection no disponible (requiere GitHub Pro para repos privados)

**Limpieza post-bootstrap**:
- PR #2: Limpieza de warnings (scripts movidos a `scripts/`)
- Resultado: 0 warnings, 0 errors en validación

**Próximos pasos**:
1. Configurar secrets de Cloudflare (CF_ACCOUNT_ID, CF_API_TOKEN)
2. Merge PR #2 (limpieza de warnings)
3. Documentar proceso de deployment de briefing a Cloudflare Pages


---

## Release — Deploy CI/CD Briefing

**Fecha**: 2025-10-02T21:15:00-04:00

**Objetivo**: Implementar pipeline CI/CD completo para despliegue automático del micrositio `briefing/` a Cloudflare Pages.

**Commits clave**:
- Main: `aa00740` - "ci(briefing): actualiza workflow a modo explícito mkdocs_briefing"
- PR #5: `2785fb9` - "docs(briefing): trigger workflow preview PR #5"

**Workflow implementado**: `Briefing — Deploy to Cloudflare Pages`
- **Modo**: `mkdocs_briefing` (explícito, sin heurísticas)
- **Config**: `briefing/mkdocs.yml`
- **Output**: `briefing/site/`
- **Triggers**: 
  - Push a `main` (carpeta `briefing/**`) → Deploy a producción
  - Pull request a `main` → Deploy preview automático

**Simplificaciones técnicas**:
- ❌ Eliminada autodetección heurística (mkdocs/npm/static)
- ❌ Eliminados pasos dinámicos con condicionales complejos
- ✅ Build explícito con validaciones de archivos
- ✅ Logs detallados del proceso de build
- ✅ Permisos: `contents:read`, `deployments:write`, `pull-requests:write`

**Resultados**:
- **Build time**: ~0.37 segundos (MkDocs)
- **Deploy time**: ~47-51 segundos (total)
- **Páginas generadas**: 11 archivos HTML
- **Preview URL** (PR #5): https://5af456b3.runart-briefing.pages.dev
- **Production URL**: https://086808df.runart-briefing.pages.dev

**Estructura publicada**:
```
briefing/site/
├── index.html (15K)
├── acerca/
├── auditoria/
├── decisiones/
├── fases/
├── galeria/
├── inbox/
├── plan/
├── proceso/
├── assets/ (CSS, JS, fonts)
├── search/
├── robots.txt
└── sitemap.xml
```

**Lecciones aprendidas**:
1. Workflows deben estar en rama base (`main`) para ejecutarse en PRs
2. Cloudflare Pages requiere permisos `deployments:write` explícitos
3. Builds explícitos son más predecibles que autodetección heurística
4. Validaciones tempranas (archivos clave) previenen errores silenciosos

**Próximos pasos**:
1. Configurar dominio custom (opcional): `briefing.runartfoundry.com`
2. Implementar workflows para otros módulos (`audits/`, `mirror/`)
3. Configurar Cloudflare Analytics
4. Documentar proceso de actualización de contenido

