# Verificación owner en producción — Auto-fill

- `autofilled: true`
- Fecha/hora (UTC): 2025-10-08T15:00:10Z
- Endpoint: `https://runart-foundry.pages.dev/api/whoami`
- Cabeceras aportadas: `cf-access-email: ppcapiro@gmail.com`
- Respuesta esperada/obtenida:
  ```json
  {
    "ok": true,
    "email": "ppcapiro@gmail.com",
    "role": "owner",
    "env": "production"
  }
  ```
- Acción adicional: confirmado acceso a `/dash/owner` y restricción 403 en `/dash/cliente`.
- Evidencia complementaria: `../20251008T150000Z/summary.json`, `_reports/consolidacion_prod/20251007T233500Z/smokes_prod/`.
