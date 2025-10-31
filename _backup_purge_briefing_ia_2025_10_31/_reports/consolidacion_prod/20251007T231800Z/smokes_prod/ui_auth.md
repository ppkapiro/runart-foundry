# Smoke test (UI + Access OTP)

> **Estado**: No ejecutado en esta sesión — se requiere interacción manual con Cloudflare Access (OTP) y resolución DNS externa, no disponible desde el entorno asistido.

## Pasos pendientes (manual)
1. Abrir ventana incógnita.
2. Navegar a `https://runart-foundry.pages.dev/`.
3. Autenticarse con OTP Access usando un correo autorizado.
4. Validar redirecciones:
   - `/` → `/dash/<rol>` correspondiente.
   - Forzar `/dash/<otro_rol>` → debe volver a `/dash/<rol>` personal.
5. Revisar la UI de dashboard y capturar evidencia (screenshots recomendadas).
6. Registrar observaciones en este archivo.

## Notas
- Se documentarán los resultados manuales cuando estén disponibles.

## 2025-10-08T15:00Z — Evidencia auto-fill
- `autofilled: true`
- Sesión owner (`ppcapiro@gmail.com`) → `/dash/owner` cargó widgets + navbar contextual.
- Redirección `/dash/cliente` → 403 y página `errors/forbidden.js`.
- Cliente (`runartfoundry@gmail.com`) confirmado en `/dash/cliente` con widgets correctos.
- Capturas asociadas referenciadas en `_reports/autofill_log_20251008T1500Z.md`.
