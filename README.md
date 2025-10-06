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

## Release 2025-10-07 — Limpieza Briefing Local

- Legacy `briefing/` archivado íntegro en `_archive/legacy_removed_20251007/` para trazabilidad.
- Navegación MkDocs y contenido reubicados en `apps/briefing/docs/client_projects/runart_foundry/` (cliente) e `apps/briefing/docs/internal/briefing_system/` (equipo).
- Documentación actualizada: `mkdocs.yml`, `README_briefing.md` y bitácora `082` para reflejar la separación Cliente/Equipo.
- Check suite revalidada (`tools/lint_docs.py`, `scripts/validate_structure.sh`, `tools/check_env.py --mode config`, `mkdocs build --strict`).

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
**Última actualización**: 2 de octubre de 2025
# runart-foundry
