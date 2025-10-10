# Auditoría posterior — `wrangler.toml`

Fecha (UTC): 2025-10-08T14:45:30Z
Fuente: rama `fix/kv-roles-binding`

```toml
name = "runart-foundry"
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

[[kv_namespaces]]
binding = "RUNART_ROLES"
id = "26b8c3ca432946e2a093dcd33163f9e2"
preview_id = "7d80b07de98e4d9b9d5fd85516901ef6"

[vars]
MOD_REQUIRED = "1"
ORIGIN_ALLOWED = "https://runart-foundry.pages.dev"
ACCESS_ADMINS = "ppcapiro@gmail.com"
ACCESS_EQUIPO_DOMAINS = "runart.com,studio.com"
RUNART_ENV = "production"
ACCESS_DEV_OVERRIDE = "0"
```

Observaciones:
- Se añade el binding `RUNART_ROLES` apuntando al namespace creado.
- Se alinea `ORIGIN_ALLOWED` con el dominio público real.
- Se incorporan variables `RUNART_ENV` y `ACCESS_DEV_OVERRIDE` coherentes con el entorno productivo.
