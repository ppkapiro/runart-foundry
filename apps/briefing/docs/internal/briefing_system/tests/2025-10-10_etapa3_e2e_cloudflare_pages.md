# Etapa T3 — E2E (Cloudflare Pages Preview)
**Versión:** v1.1 — 2025-10-10  
**Objetivo:** Validar entorno real (Pages Preview) de forma automatizada.

## Alcance técnico
- Ejecutar Playwright (headless) o `smokes.js` contra la URL de Preview generada por Cloudflare Pages.
- Simular cabeceras Access para roles owner, client_admin, team y visitor.

## Pruebas clave
- `/api/whoami` devuelve payload correcto.
- Userbar muestra chip y enlace “Mi pestaña” según rol.
- Navegación Cliente vs Interna refleja permisos.

## Pasos
1. Definir `PREVIEW_URL` (o `CF_PAGES_URL`) apuntando al despliegue activo de Cloudflare Pages.
2. Ejecutar `npm run test:bootstrap` para validar la sonda local antes de apuntar al entorno remoto.
3. Lanzar `npm run test:e2e -- --baseURL=$PREVIEW_URL` (usa `tests/scripts/run-smokes.mjs`).
4. Guardar capturas/logs adicionales en `_reports/tests/T3_e2e/<timestamp>/` (el script genera `results.json`).
5. Registrar “Smokes simulados: PASS/FAIL” en este documento.

## QA automático
- `make lint`
- `mkdocs build --strict`

## Resultados reales
- **URLs de preview:**
  - Directa: https://d46dd024.runart-foundry.pages.dev
  - Alias: https://preview.runart-foundry.pages.dev
- **Validaciones ejecutadas:**
  - `npm run test:bootstrap` → PASS (env=preview)
  - `npm run test:e2e -- --baseURL=https://preview.runart-foundry.pages.dev` → PASS (con reintentos automáticos)
- **Reporte final:** `_reports/tests/T3_e2e/20251009T144345`
- **Observaciones:** Incorporados reintentos con backoff en `run-smokes.mjs` para mitigar timeouts intermitentes; warning benigno de KV preview (Cloudflare no admite IDs específicos en preview).

## Estado de cierre
- DONE: true  
- CLOSED_AT: 2025-10-09T14:44:00Z  
- SUMMARY: E2E Preview PASS con reintentos; preview re-desplegado con vars; evidencias archivadas.  
- ARTIFACTS: `_reports/tests/T3_e2e/20251009T144345`  
- QA: PASS
- NEXT: ../tests/2025-10-10_etapa4_postdeploy_produccion.md
