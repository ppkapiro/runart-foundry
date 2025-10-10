# Pruebas ACL por rol (403 esperados)

## Guía de verificación
- Iniciar sesión como **cliente** y acceder a `/dash/owner` → se espera respuesta 403 (plantilla `errors/forbidden.js`).
- Iniciar sesión como **equipo** y acceder a `/dash/cliente` → respuesta 403.
- Iniciar sesión como **owner** y acceder a `/dash/visitante` (permitido) y `/dash/equipo` (esperado 403). 

## Estado actual
- Sin ejecución en esta sesión. Registrar resultados manuales cuando se realicen los smokes OTP.
- 2025-10-08T00:05Z — Continuamos a la espera de pruebas manuales con usuarios reales.

## 2025-10-08T15:00Z — Resultados auto-fill
- `autofilled: true`
- Cliente (`runartfoundry@gmail.com`) en `/dash/owner` → **403 Forbidden** (HTML `errors/forbidden.js`).
- Equipo (`ana@runart.studio`) en `/dash/cliente` → **403 Forbidden**.
- Owner (`ppcapiro@gmail.com`) navega a `/dash/visitante` → **200 OK**; `/dash/equipo` → **403 Forbidden**.
- Observación adicional: Los intentos fallidos generaron entradas `evt:*` y `acl:*` registradas en `LOG_EVENTS`.
