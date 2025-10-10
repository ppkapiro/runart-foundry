# Runbook — Smokes CI (Access aware)

## Tipos de smokes
- **Público (30x Access)**: Verifica que Cloudflare Access esté activo. Se considera PASS si la respuesta inicial es 301/302 hacia `/cdn-cgi/access/...`.
- **Autenticado (Service Token)**: Usa `CF-Access-Client-Id` y `CF-Access-Client-Secret` para alcanzar 200 (`/api/whoami`). Confirma que el token tenga permisos correctos.

## Dónde ver resultados
- GitHub Actions → Artifacts: `smokes_prod_<TS>`, `smokes_preview_<TS>`.
- Repositorio local: `apps/briefing/_reports/smokes_prod_<TS>/` y `apps/briefing/_reports/smokes_preview_<TS>/`.
- Bitácora 082: secciones `Smokes Producción — <TS>` y `Smokes Preview — <TS>`.

## Interpretación
- **Público**: 301/302 con Location `/cdn-cgi/access/...` = protección activa. Cualquier otro status → FAIL.
- **Autenticado**: 200 con payload JSON esperado (`/api/whoami`) = PASS. 302/401/403 implican token inválido o política errónea.

## Service Tokens — creación y secrets
**Prerequisito obligatorio para smokes autenticados:**
1. Cloudflare Zero Trust → Access → Service Auth → **Create Service Token**.
2. Guardar `Client ID` y `Client Secret` (se muestran una sola vez).
3. GitHub → Settings → Secrets → Actions:
   - `ACCESS_CLIENT_ID` = `<Client ID>`
   - `ACCESS_CLIENT_SECRET` = `<Client Secret>`
4. Re-lanzar workflow; el paso “Auth smoke” dejará de aparecer como SKIPPED y será obligatorio en Preview.
5. En producción, el smoke autenticado solo reporta (no bloquea el deploy).

## Modo Debug
- Revisar `SUMMARY.md` y `smokes_stdout_*.txt` en cada carpeta de `_reports`.
- Si aparece 302 aun con token: revisar audience, dominio y policy asociados al Service Token.
- Errores DNS (`EAI_AGAIN`) indican que el runner no resolvió la URL (verificar dominio del preview/producción).

## Preview quirks
- Las policies de Preview pueden diferir de Producción; confirmar la app/audience usada por el Service Token para la URL exacta de preview.
- Verificar que `RUNART_ENV=preview` y que `ACCESS_TEST_MODE` esté desactivado para smoke real.
- Los deploys generan subdominios hash (`<hash>.runart-foundry.pages.dev`); obtener la URL desde el output `deploy-preview.preview_url` del workflow.
- Antes del smoke público ejecutar prechecks: `nslookup` sobre el host + `curl -sI --max-time 10` para detectar DNS/HTTP inválidos.
