# TODO — Evidencias autenticadas pendientes

## Roles requeridos
- Owner (Access service token)
- Client (Access OTP)

## Capturas a recolectar
- [ ] Portal Access al ingresar la URL de preview
- [ ] Dashboard post login (`/dashboard/`)
- [ ] `/api/whoami` autenticado (env=preview)

## Respuestas JSON a guardar
- Guardar en `responses/` archivos `.json` redactados de:
  - `GET /api/whoami` autenticado
  - `POST /api/decisiones {}`

## Notas
- Utilizar alias si corresponde: https://ci-run-preview-now.runart-foundry.pages.dev
- Enmascarar encabezados Access (últimos 6 caracteres `***`).
