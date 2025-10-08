# Changelog

All notable changes to this repository will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) when version tags sean necesarios.

## [Unreleased]

*No hay cambios pendientes.*

## [Released — 2025-10-08] (ops)
### Added
- Dashboards por rol (`/dash/owner|cliente|equipo|visitante`) servidos desde Pages Functions con resolución basada en Cloudflare Access y KV `RUNART_ROLES`.
- Endpoint `/api/whoami` renovado para exponer contexto de sesión (rol, email, variables RUNART/ACCESS).
- Logging básico de visitas en `LOG_EVENTS` para trazabilidad mínima.
- Layout compartido y navegación contextual por rol (owner/cliente/equipo/visitante) con ACL centralizada (`_utils/ui.js`, `_utils/acl.js`).

### Ops
- Redeploy de Cloudflare Pages (`runart-foundry`) con middleware de Access reactivado y evidencia en `_reports/consolidacion_prod/20251007T215004Z/`.
- Smoke test CLI comprobando redirección a Cloudflare Access para visitantes no autenticados.
- Deploy adicional del 2025-10-07 (23:18Z) publicando dashboards por rol; evidencias en `_reports/consolidacion_prod/20251007T231800Z/`.
- Deploy adicional del 2025-10-07 (23:35Z) habilitando layout unificado y ACL 403; evidencias en `_reports/consolidacion_prod/20251007T233500Z/`.

### Pending
- Purga manual de caché desde Dashboard o API para completar checklist de post-deploy.
- Smokes autenticados OTP (redir `/dash/<rol>`, validación `/api/whoami`) y pruebas ACL 403 pendientes de ejecución manual.

## [Released — 2025-10-07] (briefing)
### Changed
- Se archiva la capa legacy `briefing/` completa en `_archive/legacy_removed_20251007/`.
- Navegación y contenidos reorganizados en `apps/briefing/docs/` separando vistas de cliente (`client_projects/runart_foundry/`) y equipo (`internal/briefing_system/`).
- `apps/briefing/mkdocs.yml` actualiza rutas, evitando warnings en build estricta.
- `tools/check_env.py` acepta la nueva ruta de "Entornos" en la navegación.
- `README.md` y `apps/briefing/README_briefing.md` documentan la separación Cliente/Equipo y el estado post-limpieza.

## [Released — 2025-10-06] (ops)
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
