# Plan de Migración Gradual (Fase B)

## Objetivo

Evolucionar el monorepo hacia la estructura modular propuesta sin interrumpir CI/CD ni previews existentes. La migración se realizará mediante PRs pequeños, cada uno con checklist explícito, métricas y rollback definido.

## Fases

### F1 — Fundaciones documentales

- **Entregables**: `Makefile` raíz (delegado), documentos de arquitectura (esta iteración), directorio `/workflows/` vacío con README.
- **Acciones**:
  1. Añadir `Makefile` raíz con targets delegados (sin mover archivos).
  2. Crear `/workflows/README.md` describiendo objetivo.
  3. Actualizar documentación y comunicar al equipo.
- **Pruebas/Criterios**:
  - `make build MODULE=briefing` funciona igual que comando interno.
  - `make serve MODULE=briefing` sigue levantando preview.
  - CI existente (`ci.yml`, `briefing_deploy.yml`) sigue verde.
- **Rollback**: revertir PR eliminando `Makefile` raíz y docs nuevas (sin afectar contenido productivo).

### F2 — Rationalizar herramientas (`/tools`)

- **Entregables**: mover scripts independientes (`scripts/check_env.py`, `scripts/validate_structure.sh`, etc.) a `tools/` con empaquetado mínimo.
- **Acciones**:
  1. Crear `tools/env_check` (Python) y `tools/structure_guard` (shell/Python).
  2. Actualizar `briefing/Makefile` para consumir `tools/env_check` via `pipx`/`python -m`.
  3. Ajustar `structure-guard.yml` para apuntar a nueva ruta.
- **Pruebas/Criterios**:
  - `make test-env MODULE=apps/briefing` usa tool compartido.
  - `structure-guard.yml` pasa en CI.
- **Rollback**: copiar scripts de vuelta a rutas originales y revertir references en Makefiles/workflows.

### F3 — Primer paquete compartido (`/packages`)

- **Entregables**: crear `packages/env-banner` (CSS/JS) y `packages/ui-tokens` si aplica; `apps/briefing` lo consume.
- **Acciones**:
  1. Extraer `overrides/extra.css` + banner JS a `packages/env-banner`.
  2. Publicar README con instrucciones de consumo (symlink o copy via Make target `make sync-assets`).
  3. Actualizar `apps/briefing` (ahora renombrado) para instalar paquete durante `make build`.
- **Pruebas/Criterios**:
  - `mkdocs serve` sigue cargando CSS y banner (curl 200).
  - `make build` genera `site/` sin 404 en `/overrides/extra.css`.
  - `ci.yml` y deploy a Pages completan en < 3 min.
- **Rollback**: revertir commit; apuntar `mkdocs.yml` a assets locales previos.

### F4 — Workflows reusables

- **Entregables**: `workflows/lint-build.yml`, `workflows/preview.yml`, `workflows/release.yml`; `ci.yml` actualizado a plantillas.
- **Acciones**:
  1. Implementar plantillas en `/workflows/`.
  2. Refactorizar `ci.yml` para consumir `workflow_call` (mantener jobs/outputs).
  3. Crear PR canary para un workflow (p.ej. `ci.yml`) antes de migrar el resto.
- **Pruebas/Criterios**:
  - CI de PR y push a `main` funciona con plantillas nuevas.
  - Artefactos (MkDocs site) se suben como before.
  - `briefing_deploy.yml` se mantiene sin cambios en esta fase (deprecar en F5+).
- **Rollback**: reinstaurar versión anterior de `ci.yml` y eliminar plantillas (sin afectar `Makefile`).

### F5 — Reubicación de módulos (piloto)

- **Entregables**: `apps/briefing` y `services/briefing-api` creados; `briefing/` legacy se convierte en wrapper temporal.
- **Acciones**:
  1. Mover contenido de MkDocs a `apps/briefing` (manteniendo rutas via symlink o `git mv`).
  2. Extraer Workers (`functions/api/`) a `services/briefing-api` con `wrangler.toml` propio.
  3. Actualizar workflows para apuntar a rutas nuevas (seguir checklist en `065_switch_pages.md`).
- **Pruebas/Criterios**:
  - `make build MODULE=apps/briefing` produce el mismo `site/` (diff mínimo).
  - `wrangler pages deploy` desde CI usa `apps/briefing`.
  - `/api/whoami` responde vía nuevo módulo (Workers preview/local `wrangler dev`).
  - Preview (PR) en Cloudflare Pages opera sin incidentes.
- **Rollback**:
  - Paso 1: revertir rename y restaurar `briefing/` monolítico.
  - Paso 2: revertir updates en workflows y `wrangler.toml`.

## Checklist por PR

Cada PR debe incluir:

1. `build` y `test` locales usando `make` unificado.
2. Evidencia de CI verde (workflow correspondiente).
3. Validación de preview cuando aplique (`CF_PAGES_URL`).
4. Registro en `docs/architecture/CHANGELOG.md` (por crear) con resumen.
5. Plan de rollback explícito.

## Comunicación y gobernanza

- Reunión semanal de revisión Fase B (15 min).
- Dashboard en `docs/architecture/STATUS.md` (pendiente) con progreso por fase.
- Stakeholders: Producto (briefing), DevOps, QA.

Este plan permite avanzar con cambios controlados, manteniendo la operación actual del micrositio y APIs.
