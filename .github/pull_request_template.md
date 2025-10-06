## Release
- Rama: `{{ branch }}`
- Tag (si aplica): `briefing-cleanup-20251007` / `v1.0.0`

## Checks esperados
- MkDocs (--strict) ✅
- lint_docs.py ✅
- validate_structure.sh ✅
- check_env.py --mode config ✅
- Endpoints preview: whoami 200 / inbox 403 / decisiones 401 ✅

## Pages
- Preview: (Cloudflare agrega enlace automático)
- Producción: https://briefing.runartfoundry.com

## Bitácora y Changelog
- 082: apps/briefing/docs/082_reestructuracion_local.md
- CHANGELOG: apps/briefing/CHANGELOG.md
