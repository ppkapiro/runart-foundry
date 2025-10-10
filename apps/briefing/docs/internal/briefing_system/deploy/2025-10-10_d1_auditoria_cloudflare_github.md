---
# D1 — Auditoría Cloudflare & GitHub Secrets
**Fecha:** 2025-10-09
**Versión:** 1.0
**Estado:** completed

## Objetivo
Revisar tokens y variables de entorno en GitHub y Cloudflare.

## Acciones
- Validar `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`, `CF_PROJECT_NAME`, `RUNART_ENV`.
- Confirmar que existen en todos los workflows (`pages-preview.yml`, `pages-preview2.yml`, `pages-prod.yml`).
- Verificar proyectos vinculados en Cloudflare Pages.

## Evidencia
- Revisión de workflows existentes (`.github/workflows/pages-deploy.yml`, `docs-lint.yml`, `structure-guard.yml`, `pages-preview-guard.yml`).
- **Hallazgo:** No existen archivos `pages-preview.yml`, `pages-preview2.yml`, `pages-prod.yml`; la cobertura actual depende de `pages-deploy.yml` (fallback) y del despliegue nativo de Cloudflare Pages.
- **Secrets referenciados:** `CF_API_TOKEN`, `CF_ACCOUNT_ID`, `GITHUB_TOKEN`. No se encontraron usos explícitos de `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`, `CF_PROJECT_NAME`, `RUNART_ENV`, `ACCESS_*`, `KV_*` en los workflows versionados.
- **Limitación:** Sin acceso al panel de GitHub/Cloudflare para validar existencia real de secrets. Se requiere verificación manual fuera del repositorio.
- **Riesgo:** Falta de alineación de nombres de secrets solicitados vs. los que consumen los workflows (`CF_*`). Requiere normalización.

## Sello de cierre
```
DONE: true
CLOSED_AT: 2025-10-09T13:32:00Z
SUMMARY: D1 completado con hallazgos: faltan workflows pages-preview*, páginas-prod y validar secrets en panel.
NEXT: D2
```
---
