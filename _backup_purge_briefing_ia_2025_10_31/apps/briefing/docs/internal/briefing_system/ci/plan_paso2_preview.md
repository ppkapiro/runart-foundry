# Plan Paso 2 — Preview real (Access + ENV)

## Objetivo
- Validar el entorno Preview con el mismo estándar que Producción.
- Confirmar que la protección Cloudflare Access responde con 30x para tráfico anónimo y 200 para tráfico autenticado vía Service Token.
- Garantizar que las evidencias se almacenen en `_reports/smokes_preview_<TS>/` y que la bitácora 082 registre cada ejecución.

## Checklist operativo
- [ ] Confirmar variables en Cloudflare Pages Preview: `RUNART_ENV=preview`, sin banderas de bypass activas.
- [ ] Ejecutar smoke **público** (no-follow, espera 30x hacia `/cdn-cgi/access/...`).
- [ ] Ejecutar smoke **autenticado** (Service Token, espera 200 en `/api/whoami`).
- [ ] Guardar artefactos en `_reports/smokes_preview_<TS>/` y actualizar 082.

## Criterio de salida
- Ambos smokes (público y autenticado) en estado PASS.
- Evidencias y 082 actualizadas, listas para habilitar gate en Preview igual que en Producción.

<!-- TODO(paso2-preview): revisar con Cloudflare que `ACCESS_TEST_MODE` siga en "0" para preview real; hoy wrangler.toml deja `ACCESS_TEST_MODE="1"` en env.preview. Validar también que la UI muestre banner PREVIEW (ver overrides/main.html y env-flag.js). -->

> Nota: El gate de preview ejecuta prechecks DNS/HTTP (nslookup + curl) antes de lanzar los smokes; si falla, corta con mensaje específico para evitar falsos negativos por DNS.
