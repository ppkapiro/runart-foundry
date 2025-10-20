# Pages Functions: cierre producción + smokes (NO-AUTH)

Este PR cierra la fase de hardening y promoción a producción de Pages Functions para Briefing, integrando smoke tests de producción (no-auth) en CI/CD y dejando preparada la Fase AUTH.

## Resumen
- Deploy Preview reparado y validado (wrangler.toml, KV preview)
- Promoción a producción verificada (run 18657958933)
- Smokes de producción (no-auth) implementados en Node 22, con:
  - redirect manual, timeouts, HEAD→GET fallback
  - artefactos: log.txt y SUMMARY.md
  - salida con código !=0 si falla
- Workflow de producción invoca smokes y sube artefactos
- Variables unificadas: PROD_BASE_URL (runner admite PROD_URL como fallback)
- Documentación y cambio de estado en PROBLEMA y Bitácora 082
- Template creada para Fase AUTH (Access Service Token) y RUN_AUTH_SMOKES

## Cambios
- apps/briefing/tests/scripts/lib/http.js (nuevo)
- apps/briefing/tests/scripts/run-smokes-prod.mjs (nuevo)
- apps/briefing/package.json: scripts smokes:prod y smokes:prod:auth
- apps/briefing/Makefile: targets smokes-prod y smokes-prod-auth
- .github/workflows/pages-prod.yml: paso post-deploy de smokes + upload de artefactos
- Documentos: _reports/PROBLEMA_pages_functions_preview.md, 082 bitácora, CHANGELOG
- .github/ISSUE_TEMPLATE/fase_auth_access_service_token.md (nuevo)

## Verificación local
- Node: v22.19.0
- Resultado: PASS 3/3 (A:/, B:/api/whoami, C:/robots.txt)
- Artefactos locales bajo apps/briefing/_reports/tests/smokes_prod_<timestamp>/

## Qué ocurrirá tras merge
- pages-prod.yml ejecutará deploy + smokes (no-auth)
- Se subirán artefactos bajo un nombre estable por run
- Sin secretos; AUTH queda pendiente para próxima fase

## Próxima fase (AUTH)
- Configurar Access Service Token seguro en GitHub Secrets
- Habilitar RUN_AUTH_SMOKES y añadir checks autenticados
- Revertir códigos temporales y ampliar evidencias en docs

---
Checklist:
- [x] Deploy Preview ok
- [x] Prod deploy ok
- [x] Smokes no-auth en CI
- [x] Docs/Changelog actualizados
- [x] Template Fase AUTH
