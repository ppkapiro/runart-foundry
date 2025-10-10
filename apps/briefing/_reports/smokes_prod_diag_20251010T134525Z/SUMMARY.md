# Diagnóstico de smokes (Producción) — 20251010T134525Z
- Base URL: https://runart-foundry.pages.dev

| endpoint | status_initial | location_initial | status_final | final_url | notes |
|---------|----------------|-------------------|-------------|-----------|-------|
| / | 302 | https://runart-briefing-pages.cloudflareaccess.com/cdn-cgi/access/login/runar... | 302 | https://runart-briefing-pages.cloudflareaccess.com/cdn-cgi/access/login/runar... | access_redirect |
| /api/whoami | 302 | https://runart-briefing-pages.cloudflareaccess.com/cdn-cgi/access/login/runar... | 302 | https://runart-briefing-pages.cloudflareaccess.com/cdn-cgi/access/login/runar... | access_redirect |
| /api/inbox | 302 | https://runart-briefing-pages.cloudflareaccess.com/cdn-cgi/access/login/runar... | 302 | https://runart-briefing-pages.cloudflareaccess.com/cdn-cgi/access/login/runar... | access_redirect |
| /api/decisiones | 302 | https://runart-briefing-pages.cloudflareaccess.com/cdn-cgi/access/login/runar... | 302 | https://runart-briefing-pages.cloudflareaccess.com/cdn-cgi/access/login/runar... | access_redirect |

## Hallazgos:
- / → redirige a Access (302)
- /api/whoami → redirige a Access (302)
- /api/inbox → redirige a Access (302)
- /api/decisiones → redirige a Access (302)

## Recomendación preliminar:
- Todas las rutas redirigen a Access; confirmar que el runner tolere 302 y/o inyectar sesión Access para smokes
