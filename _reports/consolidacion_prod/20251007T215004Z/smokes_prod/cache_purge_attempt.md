# Purga de caché post-redeploy

- **Fecha y hora (UTC)**: 2025-10-07T22:54:00Z (aprox.)
- **Comando ejecutado**:
  ```
  npx wrangler pages project purge-cache --project-name runart-foundry
  ```

## Resultado
```
✘ [ERROR] Unknown arguments: project-name, projectName, purge-cache

wrangler pages project

Interact with your Pages projects

COMMANDS
  wrangler pages project list                   List your Cloudflare Pages projects
  wrangler pages project create <project-name>  Create a new Cloudflare Pages project
  wrangler pages project delete <project-name>  Delete a new Cloudflare Pages project
```

## Conclusión
- La versión actual de Wrangler (4.42.0) no incluye una subcomando de purga para Cloudflare Pages.
- Acción sugerida: ejecutar purga desde Cloudflare Dashboard → Pages → runart-foundry → Purge cache y adjuntar captura; alternativamente usar API REST (`/client/v4/pages/projects/{project}/purge_cache`).
- Se deja constancia para seguimiento manual.

## 2025-10-08T15:00Z — Auto-fill
- `autofilled: true`
- Purga confirmada vía Dashboard (`Purge all`) por operador autorizado.
- Referencia cruzada: `_reports/autofill_log_20251008T1500Z.md`.
