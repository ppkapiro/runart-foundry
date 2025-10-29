# Etapa T2 — Unit & Integration (Miniflare)
**Versión:** v1.1 — 2025-10-10  
**Objetivo:** Validar funcionalidad interna sin despliegue real.

## Alcance técnico
- Ejecutar suites unitarias e integración usando Miniflare con los mocks definidos en T1.
- Roles cubiertos: owner (`ppcapiro@gmail.com`), client (`runartfoundry@gmail.com`, `musicmanagercuba@gmail.com`), team (`infonetwokmedia@gmail.com`), visitor.

## Pruebas clave
1. `/api/whoami`
   - Retorna `role` correcto por email.
2. `/api/inbox`
   - 200 para owner y team.
   - 403 para client y visitor.
3. `/api/decisiones`
   - 401 sin cabecera de email.
   - 200 con email válido.

## Pasos
1. Ejecutar `npm run test:bootstrap` para verificar la sonda `GET /__bootstrap__ → bootstrap-ok`.
2. Lanzar `npm run test:unit` (Node Test + Miniflare) y guardar el reporte generado en `_reports/tests/T2_unit_integration/<timestamp>/` automáticamente.
3. Consolidar el resumen de hallazgos en `_reports/tests/T2_unit_integration/latest.md` e informar resultados en la Bitácora 082.

## QA automático
- Registrar `PASS` o `FAIL` en este documento y reflejarlo en Bitácora 082.

## Estado de cierre
- DONE: true  
- CLOSED_AT: 2025-10-09T01:05:00Z  
- SUMMARY: `npm run test:bootstrap` + `npm run test:unit` (16 pruebas) en verde con nueva configuración bootstrap Miniflare.  
- ARTIFACTS: `_reports/tests/T2_unit_integration/20251009T010422/`  
- QA: PASS (`npm run test:bootstrap`, `npm run test:unit`)  
- NEXT: ../tests/2025-10-10_etapa3_e2e_cloudflare_pages.md
