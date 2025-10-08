# Redeploy a Cloudflare Pages (runart-foundry)

- **Fecha y hora (UTC)**: 2025-10-07T23:35:00Z (aprox.)
- **Comando**: `npx wrangler pages deploy --project-name runart-foundry site`
- **Contexto**: Publicación de UI avanzada por rol y middleware con ACL 403.

## Salida del comando
```
⛅️ wrangler 4.42.0 (update available 4.42.1)
─────────────────────────────────────────────
▲ [WARNING] Warning: Your working directory is a git repo y tiene cambios sin commitear

  To silence this warning, pass in --commit-dirty=true


✨ Compiled Worker successfully
✨ Success! Uploaded 3 files (144 already uploaded) (2.30 sec)

✨ Uploading Functions bundle
🌎 Deploying...
✨ Deployment complete! Take a peek over at https://7825ba91.runart-foundry.pages.dev
✨ Deployment alias URL: https://feat-ui-userbar-access.runart-foundry.pages.dev
```

## Notas
- Solo se subieron assets modificados y el nuevo bundle de Functions.
- Alias corresponde a la rama `feat/ui-userbar-access`.
