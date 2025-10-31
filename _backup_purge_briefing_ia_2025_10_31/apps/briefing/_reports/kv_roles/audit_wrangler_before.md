# Auditoría inicial — `wrangler.toml`

Fecha (UTC): 2025-10-08T14:45:00Z
Fuente: `origin/main`

```toml
name = "runart-briefing"
compatibility_date = "2025-10-01"
pages_build_output_dir = "site"

[[kv_namespaces]]
binding = "DECISIONES"
id = "6418ac6ace59487c97bda9c3a50ab10e"
preview_id = "e68d7a05dce645478e25c397d4c34c08"

[[kv_namespaces]]
binding = "LOG_EVENTS"
id = "6418ac6ace59487c97bda9c3a50ab10e"
preview_id = "e68d7a05dce645478e25c397d4c34c08"

[vars]
MOD_REQUIRED = "1"
ORIGIN_ALLOWED = "https://runart-briefing.pages.dev"
ACCESS_ADMINS = "tu@correo.com,otra@correo.com"
ACCESS_EQUIPO_DOMAINS = "runart.com,studio.com"
```

Observaciones:
- No existe binding `RUNART_ROLES`.
- `ORIGIN_ALLOWED` apunta a `runart-briefing.pages.dev` en lugar del dominio productivo.
- No se declara `RUNART_ENV` ni `ACCESS_DEV_OVERRIDE`.
