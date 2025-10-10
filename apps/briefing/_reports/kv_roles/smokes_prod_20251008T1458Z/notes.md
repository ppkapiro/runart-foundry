# Smokes OTP — estado

- **Visitor**: Acceso sin sesión redirige a Cloudflare Access (302). Se requiere completar OTP para obtener respuestas 200/403 según caso.
- **Owner / Client**: No ejecutados en esta sesión; necesitan autenticación Access real. Pendiente capturar evidencias (`whoami_owner.json`, `admin_roles_get_owner.json`, etc.).
- **Acción sugerida**: Operador con correo autorizado debe completar OTP, ejecutar smokes y sobrescribir los archivos correspondientes con resultados reales.
