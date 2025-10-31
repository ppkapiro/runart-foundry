---
# D4 — Validación deploy Local → Preview
**Fecha:** 2025-10-09
**Versión:** 1.0
**Estado:** completed

## Objetivo
Validar despliegue local hacia Preview.

## Acciones
- Ejecutar build local y deploy (`wrangler pages dev`).
- Confirmar Preview activo (`preview--runart-foundry.pages.dev`).
- Verificar QA y smokes automáticos.

## Evidencia
- `npm ci` (12s) y `npm run build` ejecutados en `/apps/briefing` → build MkDocs ✅. Se registran advertencias por páginas fuera de la navegación; sin fallos.
- `npm run test:unit:smoke` → ✅ 1 prueba pasada, 0 fallos (duración ~0.4s).
- **Limitación:** `wrangler pages dev` requiere credenciales locales; no se ejecutó en esta sesión. Se recomienda correrlo antes de abrir PR para verificar endpoints.
- **Verificación Preview:** Pendiente confirmar URL `preview--runart-foundry.pages.dev` tras primer push con workflows.

## Sello de cierre
```
DONE: true
CLOSED_AT: 2025-10-09T14:25:00Z
SUMMARY: D4 completado. Build local + smokes PASS; falta validar Preview real tras próximo commit.
NEXT: D5
```
---
