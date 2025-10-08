# Smoke test con Access (OTP)

- **Estado**: Pendiente — se requiere autenticación real mediante Cloudflare Access.
- **Instrucciones**:
  1. Abrir ventana incógnita y navegar a `https://runart-foundry.pages.dev/`.
  2. Completar el challenge OTP con un correo autorizado.
  3. Validar que `/` redirige a `/dash/<rol>` según el correo.
  4. Intentar acceder a `/dash/<otroRol>` y confirmar respuesta `403` HTML (`errors/forbidden.js`).
  5. Visitar `/api/whoami` y guardar la respuesta JSON en `whoami.json`.
  6. Documentar observaciones y, si es posible, adjuntar screenshots.
- **Acciones realizadas en esta sesión**: no se pudo ejecutar OTP ni acceder a la UI por ausencia de navegador interactivo.

## 2025-10-08T00:05Z — Estado
- Sin cambios: continúa pendiente intervención manual con OTP real.
