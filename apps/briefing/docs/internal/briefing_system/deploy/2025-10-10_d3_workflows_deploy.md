---
# D3 — Configuración workflows
**Fecha:** 2025-10-09
**Versión:** 1.0
**Estado:** completed

## Objetivo
Crear o actualizar workflows para preview, preview2 y producción.

## Acciones
- Crear `.github/workflows/pages-preview.yml`, `pages-preview2.yml`, `pages-prod.yml`.
- Asegurar triggers correctos: PR, develop, main.
- Incluir secrets requeridos en cada job.

## Evidencia
- Se añadieron los workflows:
	- `pages-preview.yml` → dispara en `pull_request` (ramas `develop`, `main`, `deploy/**`) y ejecuta build + smoke antes de publicar la vista previa usando `cloudflare/pages-action`.
	- `pages-preview2.yml` → dispara en `push` a `develop` o `deploy/preview2`, despliega a rama `preview2` (CloudFed) tras build y smoke.
	- `pages-prod.yml` → dispara en `push` a `main`, corre build + smokes y publica producción.
- Todos los workflows validan la presencia de `CLOUDFLARE_API_TOKEN` y `CLOUDFLARE_ACCOUNT_ID` antes de desplegar.
- `CF_PROJECT_NAME` se fija en `runart-foundry`; `RUNART_ENV` se parametriza por entorno.
- Pendiente: cargar/enlazar secrets en GitHub (`Settings > Secrets and variables > Actions`).

## Sello de cierre
```
DONE: true
CLOSED_AT: 2025-10-09T14:05:00Z
SUMMARY: D3 completado. Workflows preview/preview2/prod creados y listos para pruebas reales.
NEXT: D4
```
---
