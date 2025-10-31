# Briefing App

Aplicación MkDocs que alimenta el micrositio privado del cliente RUNArt Foundry. Esta versión vive en `apps/briefing` y se despliega actualmente en Cloudflare Pages mediante la capa de compatibilidad `../briefing` mientras se concreta el cambio de directorio en Pages.

## Flujos principales

- `make build`: genera el sitio estático en `site/`.
- `make serve`: levanta MkDocs en http://127.0.0.1:8000.
- `make lint-docs`: delega al linter global (`make -C ../.. lint-docs`).
- `make test-env*`: usa `tools/check_env.py` para validar banners y endpoints.

Consulta `docs/architecture/065_switch_pages.md` para el plan de migración que cambiará el directorio de build de Cloudflare Pages a `apps/briefing` de forma definitiva.
