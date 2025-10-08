# Redeploy Log — fix/pages-build-stable

- Branch: fix/pages-build-stable
- Commit base (short SHA): b06850c
- Acciones:
  - Endurecido `apps/briefing/package.json:scripts.build` (upgrade pip + `pip install -r requirements.txt` + `mkdocs build --strict -d site`).
  - Build local ejecutado; artefactos en `apps/briefing/site/` y log `apps/briefing/_reports/deploy_fix/build_local.log`.
  - Creado workflow de fallback `.github/workflows/pages-deploy.yml` con `cloudflare/pages-action@v1` para publicar `apps/briefing/site`.
  - Smokes producción iniciales:
    - Raíz → 302 sin `-L`, 200 con `-L`.
    - `/api/whoami` → 302 a Cloudflare Access (sin sesión), confirmando enforcement.
  - Documentación actualizada: `CHANGELOG.md`, `STATUS.md`, doc `082` sección “Refuerzo de build y deploy”.

- Próximos pasos:
  - Abrir PR y mergear a `main`.
  - Verificar deploy nativo de Pages (6–8 min). Si se estanca, confirmar fallback CI.
  - Repetir smokes y agregar `prod_smokes_003.json` con env:"production" una vez desplegado.
