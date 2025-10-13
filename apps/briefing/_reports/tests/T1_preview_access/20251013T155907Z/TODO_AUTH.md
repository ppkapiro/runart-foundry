# TODO — Evidencias autenticadas pendientes

## Roles requeridos
- Owner (Access service token)
- Client (Access OTP)

## Capturas a recolectar
- [ ] Captura pantalla del portal Access al ingresar la URL de preview
- [ ] Captura del dashboard post login (`/dashboard/`)
- [ ] Captura de recurso protegido `/api/whoami` mostrando `env=preview`

## Respuestas JSON a guardar
- Guardar en `responses/` archivos `.json` con el payload redacted de:
  - `GET /api/whoami` autenticado (maskear campos secretos)
  - `GET /api/version` si aplica

## Notas
- Utilizar el alias https://ci-run-preview-now.runart-foundry.pages.dev para pruebas autenticadas.
- Documentar encabezados Access empleados (ID y Secret) en `responses/` con valores enmascarados (ej. `***` para los últimos 6 caracteres).
