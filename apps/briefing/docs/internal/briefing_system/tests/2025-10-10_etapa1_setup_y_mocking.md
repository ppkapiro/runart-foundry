# Etapa T1 — Setup & Mocking
**Versión:** v1.1 — 2025-10-10  
**Objetivo:** Preparar entorno de pruebas sin levantar servidor real.

## Alcance técnico
- Configurar Miniflare para emular Cloudflare Pages Functions (incluyendo `_middleware.js`).
- Mockear cabeceras `Cf-Access-Authenticated-User-Email` y bindings KV (`RUNART_ROLES`, `LOG_EVENTS`, `DECISIONES`).
- Validar carga de handlers `whoami`, `inbox`, `decisiones` en entorno local.

## Pasos
1. Instalar dependencias de testing (`pnpm install -D miniflare@latest`).
2. Crear configuración `tests/miniflare.config.ts` con mocks de KV y variables de entorno.
3. Ejecutar script `pnpm test:setup` que:
   - Levante Miniflare en modo aislado.
   - Inyecte cabeceras y valores KV por rol.
   - Verifique carga de módulos (sin ejecutar lógica de red).
4. Registrar resultado en `_reports/tests/T1_setup/`.

## QA automático
- `make lint`  
- `mkdocs build --strict`

## Resultado esperado
- LOG `setup_mocking.log` con detalle de mocks generados.
- Paso final: `QA: PASS`.

## Estado de cierre
- DONE: true  
- CLOSED_AT: 2025-10-09T01:13:23Z  
- SUMMARY: `npm run test:setup` generó mocks y seeds KV para roles Access (owner/client_admin/client/team/visitor).  
- ARTIFACTS: `_reports/tests/T1_setup/20251009T011323Z/`  
- QA: PASS (`npm run test:setup`)  
- NEXT: ../tests/2025-10-10_etapa2_unit_integration_miniflare.md
