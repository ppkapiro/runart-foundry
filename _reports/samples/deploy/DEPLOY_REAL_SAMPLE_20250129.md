# Deployment Real Report — Staging

**Timestamp:** 20250129T150845Z  
**User:** operator@deploy-machine  
**Mode:** REAL DEPLOYMENT  
**Target:** staging  
**Theme:** runart-base

---

## Configuration

```bash
READ_ONLY=0
DRY_RUN=0
REAL_DEPLOY=1
SKIP_SSH=0
TARGET=staging
THEME_DIR=runart-base
ROLLBACK_ON_FAIL=1
BACKUP_RETENTION=7
LOG_LEVEL=INFO
SMOKE_TESTS=1
```

---

## Execution Log

[INFO] Reporte inicializado: _reports/deploy_logs/DEPLOY_REAL_20250129T150845Z.md
[INFO] Modo: REAL DEPLOYMENT
[INFO] Target: staging
[INFO] Theme: runart-base
[INFO] READ_ONLY=0 | DRY_RUN=0 | REAL_DEPLOY=1
[INFO] Validando configuración...
[SUCCESS] Validación de configuración: OK
[INFO] Validando acceso SSH...
[SUCCESS] Validación SSH: OK
[INFO] Generando backup pre-deploy...
[INFO] Creando tarball en servidor...
[INFO] Descargando backup...
[INFO] Generando checksum...
[INFO] Limpiando backup remoto...
[SUCCESS] Backup guardado: _reports/deploy_logs/backups/staging_20250129T150840Z.tar.gz
[INFO] Checksum: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
[INFO] Limpiando backups antiguos (retención: 7 días)...
BACKUP_PATH=_reports/deploy_logs/backups/staging_20250129T150840Z.tar.gz
BACKUP_CHECKSUM=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
[INFO] Ejecutando rsync...
[INFO] Origen: /home/pepe/work/runartfoundry/runart-base/
[INFO] Destino: u111876951@access958591985.webspace-data.io:/homepages/7/d958591985/htdocs/staging/wp-content/themes/runart-base/
[SUCCESS] Rsync completado exitosamente
[INFO] Archivos modificados: 42

### Rsync Output
```
building file list ... done
./
404.php
archive.php
comments.php
footer.php
functions.php
header.php
index.php
page.php
screenshot.png
search.php
searchform.php
sidebar.php
single.php
style.css
assets/css/main.css
assets/css/responsive.css
assets/js/main.js
inc/customizer.php
inc/template-functions.php
languages/es_ES.mo
templates/content-page.php
template-parts/header/site-branding.php
template-parts/footer/site-info.php

sent 289,456 bytes  received 1,834 bytes  97,096.67 bytes/sec
total size is 287,945  speedup is 0.99
```

[INFO] Ejecutando comandos WP-CLI en servidor remoto...
[INFO] Activando tema: runart-base
Success: Switched to 'RunArt Base' theme.
[SUCCESS] Tema activado
[INFO] Limpiando cache...
Success: The cache was flushed.
[SUCCESS] Cache limpiado
[INFO] Flushing rewrite rules...
Success: Rewrite rules flushed.
[SUCCESS] Rewrite rules actualizadas
[INFO] Ejecutando smoke tests...
[INFO] Testing: https://staging.runartfoundry.com/
[SUCCESS]   → 200 OK
[INFO] Testing: https://staging.runartfoundry.com/about/
[SUCCESS]   → 200 OK
[INFO] Testing: https://staging.runartfoundry.com/contact/
[SUCCESS]   → 200 OK
[INFO] Testing: https://staging.runartfoundry.com/es/
[SUCCESS]   → 200 OK
[SUCCESS] Smoke tests: Todos pasados
[SUCCESS] Deployment completado exitosamente en 87 segundos

---

## Results Summary

**Status:** SUCCESS
**Duration:** 87 seconds
**Timestamp:** 20250129T150845Z
**Backup:** _reports/deploy_logs/backups/staging_20250129T150840Z.tar.gz

---

## Next Steps

- [ ] Verificar sitio manualmente: https://staging.runartfoundry.com
- [ ] Monitorear logs de servidor por 10 minutos
- [ ] Documentar deployment en issue correspondiente

---

**Reporte generado por:** tools/deploy/deploy_theme.sh v1.0.0
