# Changelog — Briefing (Local)

## [Unreleased]

### Added
- Entorno CloudFed Preview2 desplegado con bindings KV reales (`DECISIONES`, `LOG_EVENTS`, `RUNART_ROLES`).

### Changed
- `wrangler.toml` actualizado con IDs preview2 y documentación acompañante (README, bitácora 082).

## [2025-10-07]
### Added
- Navegación dual Cliente / Equipo.
- Simulador de roles local (`role-sim.js`).
- Alias legacy `ops/environments.md`.

### Fixed
- Redirects antiguos (`architecture/`, `ops/`, `reports/`).
- Barrido de enlaces obsoletos en `reports/`.
- Lint de snippets extendido a rutas briefing/docs.

### Changed
- Reorganización estructural (ver 082).
- Limpieza de duplicados legacy (2025-10-07).

## [2025-10-09]
### Camino Preview→Producción COMPLETED
- Orquestador Camino Preview Real CP1–CP6 ejecutado automáticamente
- Configuración Preview y Producción validada (vars, Access, KV)
- Roles y rutas auditados, userbar y ACL funcionales
- Readiness Preview y Demo Script cliente creados y validados
- Promoción a producción y smoke tests PASS
- Consolidación final, documentación y bitácora sincronizadas
