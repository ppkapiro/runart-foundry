# ✅ CHECKLIST EJECUTIVA — FASE 7 PREVIEW PRIMERO

**Responsable:** [Tu nombre]  
**Fecha Inicio:** 2025-10-20  
**Fecha Completación:** ___________  
**Duración Total:** ~3.5-4.5 horas

---

## 🔴 PARTE A: PREPARACIÓN (10 min)

- [ ] Acceso SSH a servidor confirmado
- [ ] DNS/hosting management accesible
- [ ] WP-Admin accesible en producción (https://runalfondry.com/wp-admin)
- [ ] GitHub repo clonado (`feat/fase7-evidencias-auto` o `main`)
- [ ] gh CLI autenticado (`gh auth status` ✓)
- [ ] VS Code abierto con el repo

**Blockers encontrados?** _______________________________________________

---

## 🟡 PARTE B: CREAR STAGING (45 min)

### B1: DNS Staging (5 min)
- [ ] Subdominio creado: `staging.runalfondry.com` → A record a IP servidor
- [ ] Propagación verificada: `nslookup staging.runalfondry.com`
- [ ] Resultado esperado: Address = IP correcta ✓

### B2: HTTPS Let's Encrypt (15 min)
```bash
sudo certbot certonly --webroot -d staging.runalfondry.com
# O:
sudo certbot certonly --nginx -d staging.runalfondry.com
```
- [ ] Certificado generado sin errores
- [ ] Virtual host nginx configurado (archivo `/etc/nginx/sites-available/staging.runalfondry.com`)
- [ ] nginx reload exitoso: `sudo systemctl reload nginx`
- [ ] Verificación: `curl -I https://staging.runalfondry.com` → 200 OK ✓

### B3: Archivos WordPress Staging (10 min)
```bash
sudo mkdir -p /var/www/staging
cd /var/www/staging
# Descarga + extrae WordPress
wget https://wordpress.org/latest-es_ES.tar.gz
tar -xzf latest-es_ES.tar.gz
# Copia wp-content desde prod:
rsync -avz --delete /var/www/prod/wp-content/ /var/www/staging/wp-content/
```
- [ ] Directorio `/var/www/staging` creado
- [ ] WordPress core descargado y extraído
- [ ] wp-content copiado desde producción
- [ ] Permisos ajustados: `chown -R www-data:www-data /var/www/staging`

### B4: Base de Datos Staging (15 min)
```bash
# En PROD (SSH):
mysqldump -u wordpress_user -p wordpress_prod_db --single-transaction --quick > /tmp/prod_dump.sql

# En STAGING (SSH):
mysql -u staging_user -p -e "DROP DATABASE IF EXISTS wordpress_staging; CREATE DATABASE wordpress_staging CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u staging_user -p wordpress_staging < /tmp/prod_dump.sql

# Reemplaza URLs (Prod → Staging):
cd /var/www/staging
wp search-replace 'https://runalfondry.com' 'https://staging.runalfondry.com' --all-tables --precise
```
- [ ] BD dump creado desde producción
- [ ] BD nueva importada en staging
- [ ] URLs reemplazadas (prod → staging)
- [ ] Verificación: `mysql -u staging_user -p -e "USE wordpress_staging; SHOW TABLES LIKE 'wp_%' LIMIT 5;"`

### B5: wp-config.php Staging (5 min)
```bash
# En `/var/www/staging/wp-config.php`:
define('DB_NAME', 'wordpress_staging');
define('DB_USER', 'staging_user');
define('DB_PASSWORD', '<password-staging>');
define('DB_HOST', 'localhost');
# ... resto keys/salts
```
- [ ] wp-config.php configurado con BD staging (NO producción)
- [ ] Permisos: `sudo chmod 600 /var/www/staging/wp-config.php`

### B6: Verificación Inicial (5 min)
```bash
curl -I https://staging.runalfondry.com
# → 200 OK ✓

curl -i https://staging.runalfondry.com/wp-json/
# → 200 OK o 401 Unauthorized ✓

curl -s https://staging.runalfondry.com | grep "<!DOCTYPE"
# → HTML page ✓
```
- [ ] Frontend responde (200 OK)
- [ ] REST API disponible (200 o 401, no 404)
- [ ] WordPress cargó correctamente

### B7: Usuario Técnico en WP-Staging (5 min)
1. Accede a: https://staging.runalfondry.com/wp-admin/
2. Users → Add New
   - [ ] Username: `github-actions`
   - [ ] Email: [tu-email]
   - [ ] Role: Editor
3. Create Application Password
   - [ ] Device/App: `CI-GitHub-Actions-Staging`
   - [ ] **COPIA**: `xxxx xxxx xxxx xxxx | ...` (guardarlo localmente TEMPORAL)
   - [ ] **NO PEGUES EN GIT/GITHUB**

**App Password Staging guardada localmente?** ☐ SÍ ☐ NO

---

## 🟠 PARTE C: CARGAR SECRETOS EN GITHUB (5 min)

```bash
cd /home/pepe/work/runartfoundry

# Verifica gh autenticado:
gh auth status
# → "Logged in to github.com as ..."

# Variable pública (URL Staging):
gh variable set WP_BASE_URL --body "https://staging.runalfondry.com"

# Secrets (enmascarados):
gh secret set WP_USER --body "github-actions"
gh secret set WP_APP_PASSWORD --body "xxxx-xxxx-xxxx-xxxx-..."

# Verifica carga:
gh variable list | grep WP_BASE_URL
gh secret list | grep WP_
```

- [ ] Variable `WP_BASE_URL = https://staging.runalfondry.com` ✓
- [ ] Secret `WP_USER = github-actions` ✓
- [ ] Secret `WP_APP_PASSWORD` = contraseña staging ✓

---

## 🟡 PARTE D: EJECUTAR VERIFY-* EN STAGING (20 min)

**Secuencial (espera ~2-3 min entre cada uno):**

### D1: verify-home
```bash
gh workflow run verify-home.yml
# Espera 2-3 min...
gh run list --workflow=verify-home.yml --limit=1
# → COMPLETED ✓
```
- [ ] Workflow completed exitosamente
- [ ] **Artifact esperado:** Auth=OK, mode=real, HTTP 200

**Comando para validar:**
```bash
gh run download <run-id> -n verify-home_summary.txt -D ./artifacts/staging/
cat ./artifacts/staging/verify-home_summary.txt | grep -i "auth\|mode"
```
- [ ] Output muestra: `Auth=OK` ✓
- [ ] Output muestra: `mode=real` ✓

### D2: verify-settings
```bash
gh workflow run verify-settings.yml
# Espera 2-3 min...
```
- [ ] Workflow completed exitosamente
- [ ] Artifact esperado: Auth=OK, Compliance=OK

### D3: verify-menus
```bash
gh workflow run verify-menus.yml
# Espera 2-3 min...
```
- [ ] Workflow completed exitosamente
- [ ] Artifact esperado: Auth=OK
- [ ] ⚠️ Si REST Menus no disponible: OK (plugin opcional)

### D4: verify-media
```bash
gh workflow run verify-media.yml
# Espera 2-3 min...
```
- [ ] Workflow completed exitosamente
- [ ] Artifact esperado: Auth=OK, MISSING ≤ 3

### Resumen Staging
| Workflow | Status | Auth | ✓ |
|----------|--------|------|---|
| verify-home | PASSED | OK | ☐ |
| verify-settings | PASSED | OK | ☐ |
| verify-menus | PASSED | OK | ☐ |
| verify-media | PASSED | OK | ☐ |

**¿Todos PASSED con Auth=OK?** ☐ SÍ ☐ NO

Si NO: Ir a [Troubleshooting](#troubleshooting) abajo

---

## 🟠 PARTE E: DOCUMENTAR STAGING (10 min)

```bash
# Descarga artifacts:
mkdir -p ./artifacts/staging
# (Descarga manualmente desde GitHub Actions o con gh run download)

# Consolida documentación (opcional):
export WP_BASE_PROBE_URL="https://staging.runalfondry.com"
bash tools/fase7_collect_evidence.sh
python3 tools/fase7_process_evidence.py
```

- [ ] Artifacts descargados a `./artifacts/staging/`
- [ ] Issue #50 actualizado con sección "✅ Validación Staging"
- [ ] Documentos consolidados (000, 040, 060)

---

## 🔴 PARTE F: PROMOVER A PRODUCCIÓN (10 min)

### PRE-CHECKLIST (Verifica 3 veces)
- [ ] ¿Todos 4 workflows PASSED en STAGING? ✓
- [ ] ¿Auth=OK confirmado en artifacts STAGING? ✓
- [ ] ¿Backups de PROD realizados (fuera de este proceso)? ✓
- [ ] ¿Rollback plan entendido? ✓

**¿PROCEDER A PRODUCCIÓN?** ☐ SÍ ☐ NO

Si NO: Detener aquí, investigar problemas staging

### F1: Cambiar Variable a PROD
```bash
gh variable set WP_BASE_URL --body "https://runalfondry.com"

# Verifica:
gh variable get WP_BASE_URL
# → https://runalfondry.com ✓
```
- [ ] Variable actualizada a URL producción ✓

### F2: Generar App Password en WP-PROD
1. Accede a: https://runalfondry.com/wp-admin/
2. Users → github-actions (o crea si no existe)
3. Create Application Password
   - [ ] Device/App: `CI-GitHub-Actions-Prod`
   - [ ] **COPIA**: `xxxx xxxx xxxx xxxx | ...` (guardarlo TEMPORAL)
   - [ ] **NO PEGUES EN GIT**

**App Password PROD guardada?** ☐ SÍ ☐ NO

### F3: Actualizar Secret WP_APP_PASSWORD
```bash
gh secret set WP_APP_PASSWORD --body "xxxx-xxxx-xxxx-xxxx-... (PROD)"

# Verifica:
gh secret list | grep WP_APP_PASSWORD
# → actualización reciente ✓
```
- [ ] Secret actualizado con contraseña PROD ✓

---

## 🟢 PARTE G: VALIDAR PRODUCCIÓN (20 min)

**Repite 4 workflows contra PROD:**

### G1: verify-home (PROD)
```bash
gh workflow run verify-home.yml
# Espera 2-3 min...
```
- [ ] PASSED ✓
- [ ] Auth=OK ✓
- [ ] HTTP 200 ✓

### G2: verify-settings (PROD)
```bash
gh workflow run verify-settings.yml
# Espera 2-3 min...
```
- [ ] PASSED ✓
- [ ] Auth=OK ✓

### G3: verify-menus (PROD)
```bash
gh workflow run verify-menus.yml
# Espera 2-3 min...
```
- [ ] PASSED ✓
- [ ] Auth=OK ✓

### G4: verify-media (PROD)
```bash
gh workflow run verify-media.yml
# Espera 2-3 min...
```
- [ ] PASSED ✓
- [ ] Auth=OK ✓

### Resumen PROD
| Workflow | Status | Auth | ✓ |
|----------|--------|------|---|
| verify-home | PASSED | OK | ☐ |
| verify-settings | PASSED | OK | ☐ |
| verify-menus | PASSED | OK | ☐ |
| verify-media | PASSED | OK | ☐ |

**¿Todos PASSED con Auth=OK en PROD?** ☐ SÍ ☐ NO

Si NO: Ir a [Rollback](#rollback) abajo

---

## 🟢 PARTE H: CIERRE DOCUMENTAL (20 min)

```bash
# Descarga artifacts PROD:
mkdir -p ./artifacts/prod
# (Descargar manualmente desde GitHub Actions)

# Consolida documentación:
python3 tools/fase7_process_evidence.py

# Actualiza CHANGELOG.md:
# (Agrega entrada Fase 7 con date + versión)

# Commit:
git add -A
git commit -m "docs(fase7): validación staging+producción, artifacts y cierre (Auth=OK)"
git push origin feat/fase7-evidencias-auto
```

- [ ] Artifacts PROD descargados
- [ ] Issue #50 finalizado con cierre
- [ ] Documentos consolidados (000, 040, 050, 060, CHANGELOG)
- [ ] Commits pusheados a GitHub

### Finaliza PR
```bash
# Abre PR si no existe:
gh pr create --title "Fase 7 — Conexión WordPress Real (Auth=OK)" \
  --body "Validación staging+producción completadas. Issue #50. Ready to merge."

# O aprueba + merge desde GitHub UI:
# Repo → Pull Requests → Fase 7 PR → "Squash and merge" o "Merge"
```

- [ ] PR abierto o finalizado
- [ ] Merge a main completado

---

## 🎯 CRITERIO DE ÉXITO — FINAL

**Marca lo que completaste:**

```
STAGING VALIDADO:
☐ verify-home PASSED, Auth=OK, 200 OK
☐ verify-settings PASSED, Auth=OK, Compliance=OK
☐ verify-menus PASSED, Auth=OK
☐ verify-media PASSED, Auth=OK

PRODUCCIÓN VALIDADO:
☐ verify-home PASSED, Auth=OK, 200 OK
☐ verify-settings PASSED, Auth=OK, Compliance=OK
☐ verify-menus PASSED, Auth=OK
☐ verify-media PASSED, Auth=OK

DOCUMENTACIÓN:
☐ Issue #50 completado (checkboxes + artifacts)
☐ CHANGELOG.md actualizado
☐ Documentos 000/040/050/060 consolidados
☐ Artifacts adjuntos en repo

SEGURIDAD:
☐ Ningún secreto en git (validado con grep)
☐ Ningún secreto en logs públicos
☐ App Passwords regeneradas post-validación
☐ Backups PROD disponibles

CULMINACIÓN:
☐ PR merged a main
☐ Fase 7 COMPLETADA ✅
```

---

## 🆘 TROUBLESHOOTING RÁPIDO

**P: Auth=KO en staging**
```
R: Credencial inválida. Pasos:
1. Verifica que github-actions existe en WP-Admin staging
2. Regenera Application Password
3. gh secret set WP_APP_PASSWORD --body "..."
4. Reintenta workflow
```

**P: DNS no resuelve staging.runalfondry.com**
```
R: Propagación DNS. Pasos:
1. Espera 5-15 min
2. nslookup staging.runalfondry.com
3. Si no resuelve: verifica A record en DNS manager
```

**P: SSL certificate inválido en staging**
```
R: Let's Encrypt no validó. Pasos:
1. sudo certbot certonly --webroot -d staging.runalfondry.com
2. O: sudo certbot certonly --nginx -d staging.runalfondry.com
3. Verifica: curl -I https://staging.runalfondry.com
```

**P: WP no carga (HTTP 500)**
```
R: wp-config o BD. Pasos:
1. Verifica wp-config.php: DB_NAME, DB_USER, DB_PASSWORD
2. Verifica credenciales BD: mysql -u staging_user -p -e "SELECT 1;"
3. Verifica permisos: chown -R www-data:www-data /var/www/staging
4. Revisa: tail -f /var/log/nginx/error.log
```

**P: verify-* falla con "mode=placeholder"**
```
R: Variable WP_BASE_URL no detectada. Pasos:
1. gh variable get WP_BASE_URL
2. Si vacío o "placeholder": cargar nuevamente
3. Repo → Settings → Variables → WP_BASE_URL
4. Verifica: gh variable set WP_BASE_URL --body "https://staging..."
5. Reintenta workflow (~2 min después de cambiar)
```

**P: Secreto WP_APP_PASSWORD expuesto en logs**
```
R: ROTAR INMEDIATAMENTE. Pasos:
1. Ve a WP-Admin → Users → github-actions
2. Delete Application Password (viejo)
3. Create Application Password (nuevo)
4. gh secret set WP_APP_PASSWORD --body "<nuevo>"
5. Auditoría: GitHub Actions → run history → busca logs comprometidos
```

---

## 📝 NOTAS FINALES

**Duración Real:** ____________ (ej: 3h 45min)

**Problemas encontrados:**
1. _________________________________________________________________
2. _________________________________________________________________
3. _________________________________________________________________

**Decisiones tomadas:**
1. _________________________________________________________________
2. _________________________________________________________________

**Firmas:**
- Operador: ________________________ Fecha: __________
- Reviewer (opcional): _____________ Fecha: __________

---

**Archivo:** `/docs/RUNBOOK_FASE7_PREVIEW_PRIMERO.md`  
**Versión:** 1.0  
**Última actualización:** 2025-10-20

