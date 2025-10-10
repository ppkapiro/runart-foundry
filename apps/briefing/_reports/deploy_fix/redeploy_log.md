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

  - 2025-10-08T16:30Z — PR #22 `build: mkdocs strict + fallback deploy` mergeada; se disparó Pages Deploy Fallback run `18351563555`, que no llegó a ejecutar fallback por timeout y falta de `CF_PROJECT_NAME`.
  - 2025-10-08T16:55Z — PR #23 `ci: fix pages fallback trigger` mergeada; fallback job reintentado (`18351954739`) pero falló por falta de secreto `CF_PROJECT_NAME`.
  - 2025-10-08T17:10Z — PR #24 `ci: skip pages fallback when secrets missing` mergeada; Pages Deploy Fallback run `18352398884`:
    - Native Cloudflare Pages deploy volvió a marcar timeout.
    - Fallback detectó secretos mínimos y ejecutó deploy con `projectName=runart-foundry` → **Success**.
    - Logs: https://github.com/ppkapiro/runart-foundry/actions/runs/18352398884
    - Evidencia: job `Cloudflare Pages fallback deploy` completado en 47 s.

- Próximos pasos:
  - Confirmar en Cloudflare Pages el estado "Success" del deployment Git (tras fallback).
  - Capturar evidencias Access (owner/client) en `apps/briefing/_reports/consolidacion_prod/20251008T1750Z/` (whoami, admin roles GET/PUT, inbox, snapshots UI) cuando haya sesión disponible.
  - Registrar eventos `LOG_EVENTS` recientes y bindings Pages tras las sesiones anteriores.
