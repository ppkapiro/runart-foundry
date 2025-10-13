# T3 — Smokes autenticados (Preview & Preview2)

Fecha (UTC): 20251013T170900Z

## Runs
- Preview: https://github.com/RunArtFoundry/runart-foundry/actions/runs/18473160346 (FAIL en Auth smoke)
- Preview2: https://github.com/RunArtFoundry/runart-foundry/actions/runs/18472917793 (PASS)

## URLs
- Preview base URL: https://8f745766.runart-foundry.pages.dev
- Preview2 base URL: https://1d18c874.runart-foundry.pages.dev

## Artifacts
- Preview: Artifact `smokes_preview_20251013T170812Z`
- Preview2: Artifact `smokes_preview2_20251013T165921Z`

## Diagnóstico
- Auth Preview: Los escenarios de `/api/whoami` reportan `role: "admin"` para distintos correos (owner/team/client_admin/visitor), disparando "Role inesperado".
- Es probable que la configuración de `ACCESS_ADMINS`/`RUNART_ROLES` en Preview marque admin por defecto o que las bindings difieran de Producción.
- El runner ya envía Service Token (`CF-Access-Client-Id`/`CF-Access-Client-Secret`).

## Próximos pasos sugeridos
- Revisar en Cloudflare Pages (Preview):
  - Variables ENV (`ACCESS_ADMINS`, `ACCESS_CLIENT_ADMINS`, `RUNART_ROLES`).
  - Audience del Service Token para el dominio hash de Preview.
- Alternativa temporal: ajustar smokes para aceptar `admin` como equivalente de `owner` en Preview.
