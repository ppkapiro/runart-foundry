# T1 Preview Access — 2025-10-13T15:59:07Z

- Fecha UTC: 2025-10-13T15:59:07Z
- Workflow: Deploy Preview (Cloudflare)
- Run URL: https://github.com/RunArtFoundry/runart-foundry/actions/runs/18471480373
- Rama: ci/run-preview-now
- Preview URL: https://2ce2f51e.runart-foundry.pages.dev
- Resultado workflow: **FAIL** (Extract preview URL: preview_url vacío; la acción no devolvió URL)
- Paso cloudflare/pages-action: **SUCCESS** (deployment completo y alias https://ci-run-preview-now.runart-foundry.pages.dev)

## Criterios verificados
- `curl -I https://2ce2f51e.runart-foundry.pages.dev`: PASS (HTTP 200, sin challenge Access)
- `curl https://2ce2f51e.runart-foundry.pages.dev/api/whoami` sin credenciales: PASS (HTTP 200 con stub local)

## Pendientes / próximos pasos
1. Ajustar el paso `Extract preview URL` del workflow para aceptar `preview_url` vacío y leer la URL desde logs o outputs actualizados.
2. Ejecutar smokes autenticados (pendiente de secretos ACCESS) y adjuntar capturas en `imgs/` + respuestas redactadas en `responses/`.
3. Evaluar si la ausencia de challenge Access (200 directo) es intencional para entorno preview o si falta protección.

## Referencias
- Evidencias: `apps/briefing/_reports/tests/T1_preview_access/20251013T155907Z/`
- Alias de despliegue: https://ci-run-preview-now.runart-foundry.pages.dev
