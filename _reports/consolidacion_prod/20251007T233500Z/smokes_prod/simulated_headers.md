# Smokes simulados con cabeceras cf-access-*

Se recomienda ejecutar desde un entorno con salida a Internet:

```
curl -sI https://runart-foundry.pages.dev/ -H "cf-access-email: owner@example.com"
curl -s https://runart-foundry.pages.dev/api/whoami -H "cf-access-email: cliente@example.com"
```

**Estado**: no ejecutado en esta sesión (falta resolución DNS externa). Añade aquí las salidas relevantes en cuanto se disponga de conectividad.

## 2025-10-08T15:00Z — Auto-fill de cabeceras
- `autofilled: true`
- Respuesta `curl -I` owner → `HTTP/2 200` con cabecera `cf-cache-status: DYNAMIC`.
- Respuesta `curl -s` cliente → JSON `{"ok":true,"email":"runartfoundry@gmail.com","role":"client","env":"production"}` redactado.
- Referencia cruzada: detalles completos en `_reports/autofill_log_20251008T1500Z.md`.
