# WP SSH Deployment (20251029T152317Z)
Environment: staging

## Resumen
- Host: access958591985.webspace-data.io
- Ruta base: /homepages/7/d958591985/htdocs/staging
- Tema: runart-base
- Archivo log JSON: _reports/WP_SSH_DEPLOY_LOG.json
- Smoke test: _reports/SMOKE_STAGING.md

## Páginas publicadas
- services: publish
- servicios: publish
- blog: publish
- blog-2: publish
- home: publish
- inicio: publish
- about: publish
- sobre-nosotros: publish
- contact: publish
- contacto: publish

## Acciones ejecutadas
- rsync controlado (backup previo, filtros)
- wp rewrite flush --hard
- wp cache flush
- Publicación de páginas críticas (si aplicó)
- Smoke test EN/ES
