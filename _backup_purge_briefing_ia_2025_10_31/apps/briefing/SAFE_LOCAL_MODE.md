# SAFE_LOCAL_MODE — Briefing sin autenticación (Local Mode)

Este documento lista los puntos donde existen verificaciones de autenticación o dependencias de entorno cloud, y cómo se encapsulan para permitir ejecutar el micrositio Briefing 100% en local (sin Access, Workers ni tokens).

## Bandera de modo
- Variable: `AUTH_MODE`
- Valores:
  - `none`: Local Mode, sin autenticación ni llamadas a APIs en la nube.
  - `cloud`: Comportamiento actual/por defecto (CI/Pages/Prod), respeta Access.
- Fuente: `.env.local` (no versionado) y/o entorno.
- Inyección en frontend: `apps/briefing/docs/assets/auth-mode.js` define `window.__AUTH_MODE__`. El target `serve-local` la sobreescribe con `none`.

## Puntos de autenticación detectados

1) Frontend — Exportaciones
- Archivo: `apps/briefing/docs/assets/exports/exports.js`
- Antes: llamaba a `/api/inbox` y exigía sesión de Access.
- Local Mode: si `AUTH_MODE=none`, no llama a `/api/*`, habilita UI y muestra mensaje "Modo local: exportaciones desactivadas (sin APIs)".

2) Frontend — Dashboard de KPIs (cliente)
- Archivo: `apps/briefing/docs/assets/dashboards/cliente.js`
- Antes: llamaba a `/api/inbox` para KPIs.
- Local Mode: si `AUTH_MODE=none`, no llama a `/api/*` y muestra placeholders.

3) MkDocs — Hook de verificación de acceso interno
- Script: `apps/briefing/scripts/mark_internal.py`
- Antes: fallaba el build si documentos "internos" no tenían la marca `.interno`.
- Local Mode: si `AUTH_MODE=none`, se genera `access_map.json` pero no se interrumpe el serve.

4) Worker (Cloudflare)
- Archivo: `apps/briefing/workers/decisiones.js`
- Observación: ya tolera ausencia de cabeceras Access (email local por defecto). No se usa en local.

5) GitHub Actions / Access
- Workflows afectados: no se tocan para producción/preview.
- Observación: Local Mode no ejecuta CI; no requiere tokens.

## Cómo activar/desactivar el Local Mode

- Activar local: `make -C apps/briefing serve-local`
  - Establece `AUTH_MODE=none`, sobreescribe `docs/assets/auth-mode.js` y levanta `mkdocs serve` en 127.0.0.1:8000
- Desactivar local: ejecutar `make -C apps/briefing serve` (sin `AUTH_MODE`) o borrar `.env.local`.
- Producción/CI: por defecto `AUTH_MODE=cloud` (no cambia ningún comportamiento).

## Limitaciones conocidas en local
- Secciones que dependen de `/api/*` (ej. bandejas/exports/KPIs) muestran mensajes y placeholders (no hay datos reales).
- Acciones que requieren Cloudflare KV/Workers no funcionan en local.

## Validación rápida
- `make -C apps/briefing serve-local`
- Abrir `http://127.0.0.1:8000` sin credenciales.
- Verificar:
  - Home, UI por rol, dashboards, bitácoras cargan sin redirecciones.
  - Exportaciones: UI visible, mensaje de modo local.
  - KPIs: placeholders.

## Rollback
- Revertir la rama `feat/local-no-auth-briefing` o ejecutar en modo `cloud`.
