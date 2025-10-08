# Smoke tests post-redeploy (runart-foundry)

- **Fecha y hora (UTC)**: 2025-10-07T22:55:00Z (aprox.)
- **Objetivos**: Validar que el sitio aplica Cloudflare Access y responde tras el redeploy.

## 1. Access enforcement (sin credenciales)

Comando:
```
curl -I https://runart-foundry.pages.dev/
```

Salida relevante:
```
HTTP/2 302
location: https://runart-briefing-pages.cloudflareaccess.com/cdn-cgi/access/login/runart-foundry.pages.dev?... 
cache-control: private, max-age=0, no-store, no-cache, must-revalidate, post-check=0, pre-check=0
```

✅ Resultado esperado: redirect a Cloudflare Access (`302` hacia dominio `runart-briefing-pages.cloudflareaccess.com`).

## 2. Observaciones adicionales

- El response incluye cabecera `set-cookie: CF_AppSession` indicando challenge Access.
- No se ejecutaron pruebas autenticadas desde CLI (requiere OTP). Se documentará en próximos smokes con UI manual.

## 3. Pendientes

- Purga de caché via API/Dashboard: la CLI actual (`wrangler 4.42.0`) no expone comando directo; se recomienda completar manualmente en Dashboard (Pages → runart-foundry → Purge cache) y adjuntar evidencia visual.
