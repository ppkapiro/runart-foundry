# Smokes simulados con cabeceras cf-access-*

Se intentó ejecutar:

```
curl -I https://runart-foundry.pages.dev/
curl -s https://runart-foundry.pages.dev/api/whoami \
  -H "cf-access-email: owner@example.com"
```

**Resultado**: ambos comandos retornaron `curl: (6) Could not resolve host: runart-foundry.pages.dev`.

## Interpretación
- El entorno automatizado no tiene resolución DNS externa habilitada en este momento.
- El middleware y deploy fueron exitosos (ver `redeploy_log.md`), por lo que se espera que las rutas funcionen en producción.
- Acciones siguientes: repetir desde una máquina con conectividad o tras habilitar DNS y pegar salidas aquí.
