# Redeploy a Cloudflare Pages (runart-foundry)

- **Fecha y hora (UTC)**: 2025-10-07T23:18:00Z (aprox.)
- **Comando**: `npx wrangler pages deploy --project-name runart-foundry site`
- **Objetivo**: Publicar dashboards por rol y middleware actualizado tras pruebas locales.

## Salida del comando
```
⛅️ wrangler 4.42.0 (update available 4.42.1)
─────────────────────────────────────────────
▲ [WARNING] Warning: Your working directory is a git repo and has uncommitted changes

  To silence this warning, pass in --commit-dirty=true


✨ Compiled Worker successfully
✨ Success! Uploaded 3 files (144 already uploaded) (2.71 sec)

✨ Uploading Functions bundle
🌎 Deploying...
✨ Deployment complete! Take a peek over at https://4abca494.runart-foundry.pages.dev
✨ Deployment alias URL: https://feat-ui-userbar-access.runart-foundry.pages.dev
```

## Notas
- Warning esperado por cambios locales aún sin commit.
- Se subieron únicamente assets modificados y el bundle de Functions.
- Alias coincide con rama de trabajo `feat/ui-userbar-access`.
