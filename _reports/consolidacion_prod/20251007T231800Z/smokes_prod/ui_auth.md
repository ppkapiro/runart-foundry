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
