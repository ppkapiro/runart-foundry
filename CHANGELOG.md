# Changelog

All notable changes to this repository will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) when version tags sean necesarios.

## [Unreleased]
### Added
- Script de lint de documentación (`tools/lint_docs`) — en construcción.
- Dashboard vivo en `STATUS.md` con semáforo por módulo.
- Plan de switch para Cloudflare Pages en `docs/architecture/065_switch_pages.md` (incluido en la navegación de MkDocs).
- Integración Operativa — CI Workflows y reporting
	- Nuevo workflow `docs-lint.yml` para validar documentación en PRs.
	- Nuevo workflow `status-update.yml` que promueve `Unreleased` y actualiza `STATUS.md`.
	- Nuevo workflow `env-report.yml` para publicar resultados de `tools/check_env.py` en las PRs.
	- Documentación complementaria en `docs/ops/integracion_operativa.md`.

### Docs
- Lineamientos para incidentes en `INCIDENTS.md` (plantilla inicial).
- `docs/architecture/{000,010,050}` actualizados con la nueva estructura modular (`apps/briefing` como fuente canónica y capa `briefing/` de compatibilidad).
- `apps/briefing/README_briefing.md` alineado con rutas `apps/briefing/**` y referencias al switch plan.
- Registro de estado previo al switch de Cloudflare Pages (pendiente de ejecución) y plan de limpieza de la capa `briefing/` tras la validación en producción.

### CI
- Borrador del job `docs-lint` pendiente de implementación en GitHub Actions.
- `tools/lint_docs.py` ahora construye MkDocs para `apps/briefing` y `briefing` en paralelo y valida ambos árboles.

### DX
- Plantilla de Pull Request actualizada con chequeos específicos para `apps/briefing` y la capa de compatibilidad.

## [Iteración Arquitectura — Iteración 1] - 2025-10-04
### Added
- Índice `docs/architecture/_index.md` para navegar por el dossier de arquitectura.

### Changed
- Navegación de MkDocs actualizada con la sección “Arquitectura”.

### Docs
- Documentos `000` a `070` que cubren estado actual, inventario, estructura objetivo, convenciones, workflows compartidos, targets Make, plan de migración y registro de riesgos.

### CI
- Validación de navegación ampliada ejecutando `make build` dentro de `briefing/`.
