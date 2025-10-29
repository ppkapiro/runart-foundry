---
title: "README — RUN Art Foundry"
roles:
  - owner
  - equipo
  - cliente
meta:
  pr: PR-02.1 (Root Alignment Applied)
  fecha: 2025-10-23
  fuente: docs/_meta/plan_pr02_root_alignment.md
crosslinks:
  - STATUS.md
  - NEXT_PHASE.md
  - CHANGELOG.md
  - docs/_meta/plan_pr02_root_alignment.md
  - docs/_meta/checklist_pr02_root_alignment.md
  - docs/_meta/mapa_impacto_pr02.md
---
<!--
Bloque canónico añadido por PR-02.1 (Root Alignment Applied)
Ver documentación y meta en docs/_meta/plan_pr02_root_alignment.md
-->

![Pages Prod](https://github.com/ppkapiro/runart-foundry/actions/workflows/pages-prod.yml/badge.svg)
[![Verify Staging](https://github.com/RunArtFoundry/runart-foundry/actions/workflows/verify-staging.yml/badge.svg)](https://github.com/RunArtFoundry/runart-foundry/actions/workflows/verify-staging.yml)
[![Smoke Tests](https://github.com/RunArtFoundry/runart-foundry/actions/workflows/smoke-tests.yml/badge.svg)](https://github.com/RunArtFoundry/runart-foundry/actions/workflows/smoke-tests.yml)
[![WP-CLI Bridge](https://github.com/RunArtFoundry/runart-foundry/actions/workflows/wpcli-bridge.yml/badge.svg)](https://github.com/RunArtFoundry/runart-foundry/actions/workflows/wpcli-bridge.yml)
[![Bridge Maintenance](https://github.com/RunArtFoundry/runart-foundry/actions/workflows/wpcli-bridge-maintenance.yml/badge.svg)](https://github.com/RunArtFoundry/runart-foundry/actions/workflows/wpcli-bridge-maintenance.yml)

# RUN Art Foundry — Proyecto Local

[![Deploy: Briefing](https://github.com/ppkapiro/runart-foundry/actions/workflows/briefing_deploy.yml/badge.svg)](https://github.com/ppkapiro/runart-foundry/actions/workflows/briefing_deploy.yml)

Este directorio contiene TODO el trabajo local de investigación y automatización del sitio web de RUN Art Foundry.

## Estructura del Proyecto (Monorepo)

Este es un **monorepo** que contiene múltiples módulos:

- **`apps/briefing/`**: Micrositio privado (MkDocs Material) con Cloudflare Pages + Access (`briefing/` legado archivado en `_archive/legacy_removed_20251007/`)
- **`audits/`**: Auditorías del sitio del cliente (rendimiento, SEO, accesibilidad)
- **`mirror/`**: Snapshots del sitio del cliente (descargas SFTP/wget)
- **`docs/`**: Documentación del proyecto (especificaciones, gobernanza)
- **`source/`**: Código editable (temas/plantillas) del sitio del cliente
- **`scripts/`**: Scripts globales del proyecto
- **`.tools/`**: Dependencias npm para auditorías (Lighthouse, Axe)

## Ejecutar Briefing en local sin autenticación (Local Mode)

Para trabajar el micrositio Briefing 100% en local, sin Cloudflare Access ni tokens:

1) Clona el repo y entra al directorio raíz.
2) Inicia el modo local:
  - make -C apps/briefing serve-local
3) Abre http://127.0.0.1:8000 en tu navegador.

Notas:
- Este modo establece AUTH_MODE=none y sobreescribe apps/briefing/docs/assets/auth-mode.js durante la sesión local.
- Las secciones que dependen de /api/* mostrarán placeholders o mensajes; no hay datos remotos ni autenticación.
- Para volver al comportamiento normal, usa make -C apps/briefing serve o elimina .env.local.
- Detalles completos: apps/briefing/SAFE_LOCAL_MODE.md

## Iteración cerrada — Fase 5 · UI contextual y experiencias por rol

- Reporte de fase: `apps/briefing/docs/internal/briefing_system/reports/2025-10-11_fase5_ui_contextual_y_experiencias_por_rol.md` (sello DONE con entregables diferidos documentados).
- Artefactos clave: `_reports/ui_context/20251011T153200Z/`, `_reports/qa_runs/20251008T221533Z/`, `_reports/access_sessions/20251008T222921Z/README.md`.
- Bitácora 082 registra el kickoff y cierre con notas de diferimiento controlado.
- Orquestador actualizado tras el cierre (ver `plans/00_orquestador_fases_runart_briefing.md`).

## Próxima iteración — Preparación Fase 6

- Backlog operativo: `NEXT_PHASE.md` (streams y entregables priorizados post-F5).
- Objetivo: ejecutar sesiones "Ver como" reales, automatizar guardias QA/observabilidad y lanzar `packages/env-banner`.
- `STATUS.md` refleja nuevas prioridades y responsables.

## Release 2025-10-10 — Consolidación y cierre operativo

- Documentación de cierre publicada (`reports/2025-10-10_fase4_consolidacion_y_cierre.md`) y enlazada en la navegación interna.
- `STATUS.md` y `NEXT_PHASE.md` reflejan la finalización de las fases F1–F4 y establecen el backlog de la próxima iteración.
- Changelog y orquestador sincronizados con el sello de cierre; Bitácora 082 registra el handover.
- Validaciones QA (`make lint`, `mkdocs build --strict`) ejecutadas tras las actualizaciones de documentación.

## Release 2025-10-07 — Limpieza Briefing Local

- Legacy `briefing/` archivado íntegro en `_archive/legacy_removed_20251007/` para trazabilidad.
- Navegación MkDocs y contenido reubicados en `apps/briefing/docs/client_projects/runart_foundry/` (cliente) e `apps/briefing/docs/internal/briefing_system/` (equipo).
- Documentación actualizada: `mkdocs.yml`, `README_briefing.md` y bitácora `082` para reflejar la separación Cliente/Equipo.
- Check suite revalidada (`tools/lint_docs.py`, `scripts/validate_structure.sh`, `tools/check_env.py --mode config`, `mkdocs build --strict`).

## Verificaciones Programadas y Alertas

Este proyecto implementa **verificaciones automatizadas** de infraestructura, alertas por Issues y reparación rápida. Ver [`docs/DEPLOY_RUNBOOK.md`](docs/DEPLOY_RUNBOOK.md) para el manual completo de operaciones.

### Workflows de Verificación (Cron + Manual)

| Workflow | Trigger | Checks |
|----------|---------|--------|
| **Verify Home** | Cada 6h + manual | Auth, show_on_front, page_on_front, Home ES/EN (200) |
| **Verify Menus** | Cada 12h + manual | Auth, manifesto menus.json, menús en WP, drift detection |
| **Verify Media** | Diario + manual | Auth, manifesto media_manifest.json, existencia en WP, asignaciones |
| **Verify Settings** | Cada 24h + manual | Auth, timezone, permalink_structure, start_of_week |

### Alertas Automáticas

- Cada verificación crea/actualiza/cierra un **Issue único por área** con etiqueta `area:*` y `monitoring`.
- **Título:** `Alerta verificación <área> — YYYY-MM-DDTHH:MMZ`
- **Cuerpo:** Resumen + checklist de acciones.
- **Cierre automático:** Cuando la verificación vuelve a OK.

### Run Repair (Reparación Rápida)

Workflow `run-repair.yml` con inputs `area` (home/menus/media/settings) y `mode` (plan/apply) para reparar rápidamente problemas detectados.

### Documentación Operativa

- **[DEPLOY_RUNBOOK.md](docs/DEPLOY_RUNBOOK.md)**: Guía completa de operaciones (verificaciones, alertas, run-repair, rotación de password, limpieza)
- **[CIERRE_AUTOMATIZACION_TOTAL.md](docs/CIERRE_AUTOMATIZACION_TOTAL.md)**: Resumen técnico, mapeos, seguridad, lecciones aprendidas

---

## 🔧 Deployment Guide (RunArt Foundry)

**📘 [Deployment Master Guide](docs/Deployment_Master.md)** — Referencia oficial de deployment  
**📋 [Deployment Log](docs/Deployment_Log.md)** — Registro cronológico de deployments

### Deployment Master Guide
Documento completo que centraliza:
- ✅ Método aprobado de deployment (WSL + WP-CLI + IONOS)
- ✅ Variables, credenciales y ubicaciones críticas
- ✅ Procedimientos paso a paso (backup, sincronización, verificación, rollback)
- ✅ Problemas detectados y soluciones (WSOD, CSS 404, cache, SSH, etc.)
- ✅ Buenas prácticas de seguridad, testing y versionado
- ✅ Checklist de verificación pre/durante/post-deployment
- ✅ **NUEVO:** Sección 8.1 — v0.3.1.1 Language Switcher Fix con pitfalls aprendidos

**Última actualización:** 2025-10-29 v1.2 — Chrome overflow fix (fit-content → flex)

---

## 🔐 Integración WP Real (Fase 7 — En progreso)

**Estado:** 🟡 En ejecución  
**Rama:** `feat/fase7-wp-connection`  
**Documentación:** [`issues/Issue_50_Fase7_Conexion_WordPress_Real.md`](issues/Issue_50_Fase7_Conexion_WordPress_Real.md)

La Fase 7 marca la transición de **modo placeholder** (credenciales dummy) a **conexión real** con un sitio WordPress operativo.

### Configuración de Credenciales

Los workflows `verify-*` utilizan las siguientes variables y secrets para conectarse a WordPress:

#### Variables (Repo → Settings → Secrets and variables → Actions → **Variables**)

- **`WP_BASE_URL`**: URL base del sitio WordPress  
  - Ejemplo: `https://tu-wp.com`
  - Tipo: Variable de repositorio (visible en logs enmascarada tras first commit)
  - Estado actual: **Pendiente del owner**

#### Secrets (Repo → Settings → Secrets and variables → Actions → **Secrets**)

- **`WP_USER`**: Usuario con rol Editor o superior  
  - Creado en WordPress Admin → Users
  - Estado actual: **Pendiente del owner**
  
- **`WP_APP_PASSWORD`**: Contraseña de aplicación generada en WordPress  
  - ⚠️ **CRÍTICO:** No exponer este valor en commits, logs, comments ni PRs
  - GitHub enmascara automáticamente los secrets en la salida
  - Se genera en WordPress: Users → Tu usuario → Application Passwords
  - **Owner solo:** Cargar manualmente en repo Settings → Secrets (Copilot NO accede a este campo)
  - Estado actual: **Pendiente del owner**

### Detección de Modo

Cada workflow `verify-*` incluye un campo `mode` en el resumen:
- `mode=real`: Si `WP_BASE_URL ≠ "placeholder.local"`
- `mode=placeholder`: Si `WP_BASE_URL` está vacío o es placeholder

### Flujo de Conmutación

1. **Preparación** (esta rama): Workflows enriquecidos, documentación lista, **credenciales vacías**
2. **Owner carga credenciales**: Ingresa valores reales en repo Settings
3. **Ejecución**: Ejecutar manualmente `verify-home`, luego `verify-settings`, `verify-menus`, `verify-media`
4. **Validación**: Comprobar `Auth=OK` en los artifacts *_summary.txt
5. **Cierre**: Actualizar CHANGELOG y fusionar PR

**⚠️ No crear carpetas nuevas (p.ej., `apps/wordpress/`) hasta fase posterior.**

---

## Guardarraíles de Gobernanza

Este proyecto implementa **validaciones automáticas** para mantener la organización del repositorio según las reglas definidas en [`docs/proyecto_estructura_y_gobernanza.md`](docs/proyecto_estructura_y_gobernanza.md).

### 🤖 Validación Automática en CI/CD

Cada **Pull Request** y **push a `main`** ejecuta el workflow [`structure-guard.yml`](.github/workflows/structure-guard.yml) que valida:

- ✅ Archivos en ubicaciones permitidas (reportes en `apps/briefing/docs/client_projects/runart_foundry/reports/` o `audits/reports/`, NO en raíz)
- ✅ Tamaños de archivo (hard limit: ≥25 MB, warning: 10-25 MB)
- ✅ Exclusión de builds (`apps/briefing/site/`), node_modules, logs, credenciales
- ✅ Exclusión de binarios pesados (`mirror/raw/*/wp-content/uploads/`)

**El PR/push FALLA** si hay violaciones.

### 🛠️ Validación Local (Recomendado)

#### Ejecutar Validador Manualmente

Antes de hacer commit, ejecuta:

```bash
# Validar solo archivos staged
scripts/validate_structure.sh --staged-only

# Validar todo el repositorio
scripts/validate_structure.sh
```

El script reporta:
- ❌ **Errores** (bloqueantes): archivos en rutas prohibidas, tamaños >25 MB
- ⚠️ **Advertencias**: archivos grandes (10-25 MB), scripts en raíz

#### Activar Hooks Locales (Pre-commit Automático)

Para validar **automáticamente antes de cada commit**:

```bash
# Activar hooks locales
git config core.hooksPath .githooks

# Verificar configuración
git config core.hooksPath
```

**Hooks disponibles**:
- **`pre-commit`**: Ejecuta `validate_structure.sh --staged-only` antes de commit
- **`prepare-commit-msg`**: Sugiere prefijo de módulo en mensaje de commit (ej: `briefing:`, `audits:`)

**Bypass del hook** (NO recomendado):
```bash
git commit --no-verify
```

### 📋 Checklist de Pull Request

Al crear un PR, se mostrará automáticamente un **checklist de gobernanza** ([`.github/PULL_REQUEST_TEMPLATE.md`](.github/PULL_REQUEST_TEMPLATE.md)) con:

- [ ] Ubicación correcta de archivos
- [ ] Nomenclatura (kebab-case, fechas ISO)
- [ ] Tamaño <10 MB
- [ ] Sin credenciales ni contenido sensible
- [ ] Sin logs en Git
- [ ] Sin build artifacts
- [ ] Reportes en carpetas designadas
- [ ] Mensaje de commit con prefijo de módulo

### 👥 Revisión por Módulo (CODEOWNERS)

El archivo [`.github/CODEOWNERS`](.github/CODEOWNERS) asigna **revisores por módulo**:

- `/apps/briefing/` → `@owner-briefing`
- `/audits/` → `@owner-audits`
- `/mirror/` → `@owner-mirror`
- `/docs/` → `@owner-docs`
- `/scripts/` y `/.github/` → `@owner-devops`

**PRs que toquen estos módulos requieren aprobación** del dueño correspondiente.

## Documentación

- **[Documento de Gobernanza](docs/proyecto_estructura_y_gobernanza.md)**: Reglas completas de organización, ubicación de archivos, control de cambios
- **[Árbol de Directorios](docs/_artifacts/repo_tree.txt)**: Estructura completa del repositorio (niveles 1-3)
- **[README Briefing](apps/briefing/README_briefing.md)**: Documentación del micrositio Cloudflare Pages
- **[README Audits](audits/README.md)**: Documentación de auditorías

## Gestión de imágenes para fichas

- Cada proyecto usa `assets/{año}/{slug}/` con al menos dos imágenes optimizadas (`img_01`, `img_02`, etc.).
- Formatos recomendados: `.webp` o `.jpg` ≤300 KB para compatibilidad con la web actual.
- Mantener el archivo `.gitkeep` hasta reemplazarlo por media definitiva; eliminarlo al subir las imágenes finales.
- Respaldar el original pesado en `assets/_incoming/` si requiere reprocesamiento antes de optimizar.

## Convención de Commits

Usa prefijo de módulo en tus commits:

```
<módulo>: <verbo> <descripción corta>

briefing: Añadir endpoint /api/export-decisiones
audits: Generar reporte 2025-10-02 con métricas Core Web Vitals
docs: Actualizar proyecto_estructura_y_gobernanza.md
mirror: Excluir wp-content/uploads de snapshot 2025-10-02
scripts: Refactorizar validate_structure.sh
ci: Añadir workflow structure-guard.yml
chore: Actualizar .gitignore con exclusiones adicionales
```

## Estado del Proyecto

- ✅ **Briefing**: Micrositio operativo en https://runart-briefing.pages.dev (estructura local reorganizada Cliente/Equipo)
- ✅ **Audits**: Reportes de auditoría generados (2025-10-01)
- ✅ **Mirror**: Snapshot del sitio descargado (2025-10-01, 760 MB localmente)
- ✅ **Gobernanza**: Guardarraíles implementados (CI + hooks locales)

## Contacto

**Mantenedor**: Equipo RUN Art Foundry  
**Última actualización**: 10 de octubre de 2025
# runart-foundry
