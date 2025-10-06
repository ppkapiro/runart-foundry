---
title: 082 — Reestructuración local Briefing
---
# 082 — Reestructuración local Briefing

Bitácora para coordinar la separación "Cliente vs Equipo" en la documentación local, manteniendo la compatibilidad con enlaces históricos y automatizaciones.

## Contexto

- Objetivo: replicar en local la vista dual Cliente/Equipo sin mover código productivo.
- Alcance de esta fase: reubicar documentación, agregar simulador de roles, configurar redirecciones y actualizar navegación.
- Estado de rama: `feat/estructura-local-briefing`.

## Cambios estructurales

1. **Navegación dual** en `mkdocs.yml` con secciones "Cliente · RunArt Foundry" y "Equipo Técnico · Briefing System".
2. **Reubicación de documentación** cliente a `docs/client_projects/runart_foundry/` y material interno a `docs/internal/briefing_system/`.
3. **Redirects** configurados con `mkdocs-redirects` para rutas heredadas críticas (`architecture/`, `ops/`, `reports/`, entre otras).
4. **Simulador de roles** (`assets/dev/role-sim.js`) que alterna clases `.only-internal` en entornos locales.
5. **Actualización de portadas** y catálogos (`client_projects/runart_foundry/index.md`, fichas y reportes).

## Pendientes y validaciones

- [x] Ejecutar `mkdocs build --strict`.
- [x] Correr `tools/lint_docs.py`.
- [x] Ejecutar `scripts/validate_structure.sh`.
- [x] Ejecutar `tools/check_env.py` (modo `config`).
- [x] Verificar `wrangler dev` (smoke local) con simulador de roles (`scripts/check_wrangler_dev.sh`).
- [x] Documentar resultados y capturas relevantes.
- [x] Barrer enlaces legacy en `docs/client_projects/runart_foundry/reports/`.

## Validaciones (2025-10-06)

- `mkdocs build --strict` → ✅ sin advertencias tras alinear `redirects` y navegación.
- `tools/lint_docs.py` → ✅ ejecutó build estricta + validaciones de snippets.
- `scripts/validate_structure.sh` → ✅ "All checks passed".
- `tools/check_env.py --mode config` → ✅ tras reintroducir alias `Entornos: ops/environments.md`.
- `wrangler dev` → ✅ `scripts/check_wrangler_dev.sh` confirma `/api/whoami` 200 (env `local`). `/api/inbox` → 403 esperado sin token Access; `/api/decisiones` → 401 sin credenciales editor (documentado como comportamiento previsto en local).

## Validaciones (2025-10-07)

- Barrido de enlaces en informes cliente (`docs/client_projects/runart_foundry/reports/`) → ✅ referencias actualizadas a `apps/briefing/...` y grep sin coincidencias `../briefing` pendientes.
- Limpieza de duplicados legacy → ✅ `briefing/` completo archivado en `_archive/legacy_removed_20251007/briefing/` (220 archivos).
- Snapshots de comprobación → `apps/briefing/_tmp/legacy_files.txt` (36 entradas) y `apps/briefing/_tmp/legacy_refs.txt` (sin coincidencias `../briefing`).
- Validaciones post-limpieza → `tools/lint_docs.py`, `scripts/validate_structure.sh`, `tools/check_env.py --mode config` y `mkdocs build --strict` ejecutados sin errores.

### Limpieza de duplicados (2025-10-07)

1. Identificación de duplicados en `briefing/docs/**` (`find` + `grep`).
2. Resguardo temporal en `_archive/legacy_removed_20251007/briefing/` (mantiene estructura completa para auditoría).
3. Confirmación de que no existen referencias activas a `../briefing` ni rutas legacy antes del merge.
4. Builds estrictas re-ejecutadas para asegurar ausencia de regresiones.

## Incidencias conocidas

- Advertencias previas de MkDocs por enlaces a archivos `.js` (resuelto).
- Revisar enlaces residuales a rutas antiguas dentro de informes históricos (pendiente de barrido completo) → ✅ barrido inicial en informes cliente; duplicado `briefing/` archivado en `_archive/legacy_removed_20251007/`.

## Próximos pasos

- Una vez verificados los checks, preparar changelog y nota para `README_briefing.md`.
- Coordinar con equipo ARQ para planificar despliegue en Pages tras validaciones.
