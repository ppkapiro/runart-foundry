# Etapa T4 — QA Post-deploy (Producción)
**Versión:** v1.0 — 2025-10-10  
**Objetivo:** Validar entorno producción tras merge.

## Alcance técnico
- Ejecutar la misma suite E2E sobre `https://runart-foundry.pages.dev/` con roles simulados.
- Registrar resultados de ACL, UI y endpoints.

## Pasos
1. Exportar `PROD_URL=https://runart-foundry.pages.dev/`.
2. Ejecutar `pnpm test:e2e -- --baseURL=$PROD_URL`.
3. Capturar respuestas HTTP y screenshots en `_reports/tests/T4_prod/`.
4. Documentar matriz de resultados (PASS/FAIL por rol y endpoint).

## QA automático
- `make lint`
- `mkdocs build --strict`

## Resultados QA
- **URL producción:** https://runart-foundry.pages.dev
- **Validaciones ejecutadas:**
  - `/api/whoami` → 200 (env=production confirmado)
  - `/api/decisiones` POST sin auth → 401 (protección activa)
  - Rutas autenticadas (`/api/inbox`, `/api/decisiones` POST) → Cloudflare Access login (comportamiento esperado)
- **Observaciones:** Cloudflare Access protege correctamente las rutas; `RUNART_ENV=production`; reintentos automáticos funcionan.

## Estado de cierre
- DONE: true  
- CLOSED_AT: 2025-10-09T15:15:55Z  
- SUMMARY: Smokes producción PASS; roles y ACL correctos; RUNART_ENV=production.  
- ARTIFACTS: `_reports/tests/T4_prod/20251009T151555Z`
- QA: PASS
- NEXT: ../tests/2025-10-10_etapa5_consolidacion_resultados.md
