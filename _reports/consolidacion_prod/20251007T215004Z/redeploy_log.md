# Redeploy a Cloudflare Pages (runart-foundry)

- **Fecha y hora (UTC)**: 2025-10-07T22:35:00Z (aprox.)
- **Operación**: `npx wrangler pages deploy --project-name runart-foundry site`
- **Contexto**: Deploy posterior a consolidación de producción; objetivo activar middleware y enlazar build MkDocs.

## Salida del comando
```
⛅️ wrangler 4.42.0 (update available 4.42.1)
─────────────────────────────────────────────
▲ [WARNING] Warning: Your working directory is a git repo and has uncommitted changes

  To silence this warning, pass in --commit-dirty=true


✨ Compiled Worker successfully
✨ Success! Uploaded 70 files (77 already uploaded) (4.17 sec)

✨ Uploading Functions bundle
🌎 Deploying...
✨ Deployment complete! Take a peek over at https://3ec32f35.runart-foundry.pages.dev
✨ Deployment alias URL: https://feat-ui-userbar-access.runart-foundry.pages.dev
```

## Notas
- Warning esperado porque la bitácora y evidencia aún no se han committeado.
- Alias corresponde a rama actual (`feat-ui-userbar-access`).
- Deploy confirma subida de bundle de Pages Functions (middleware activo).
