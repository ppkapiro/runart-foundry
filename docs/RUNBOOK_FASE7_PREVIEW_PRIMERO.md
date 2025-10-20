# 🚀 RUNBOOK OPERACIONAL — FASE 7 PREVIEW PRIMERO

**Versión:** 1.0  
**Fecha:** 2025-10-20  
**Responsable:** Operador/Compañero técnico (acceso DNS, SSH, WP-Admin, GitHub)  
**Duración estimada:** ~4-5 horas (staging: 2-3h, validaciones: 1.5-2h)  
**Status:** 🟡 LISTO PARA EJECUTAR

---

## 📋 ÍNDICE RÁPIDO

1. [Requisitos previos](#requisitos-previos)
2. [Fase 1: Crear Staging](#fase-1-crear-staging)
3. [Fase 2: Cargar Variables/Secrets en GitHub](#fase-2-cargar-variablessecrets-en-github)
4. [Fase 3: Ejecutar verify-* en Staging](#fase-3-ejecutar-verify--en-staging)
5. [Fase 4: Documentar Staging](#fase-4-documentar-staging)
6. [Fase 5: Promover a Producción](#fase-5-promover-a-producción)
7. [Fase 6: Validar Producción](#fase-6-validar-producción)
8. [Fase 7: Cierre Documental](#fase-7-cierre-documental)
9. [Rollback](#rollback-plan)

---

## REQUISITOS PREVIOS

**Acceso necesario:**
- [ ] Acceso SSH a servidor (usuario con permisos web/sudo)
- [ ] DNS/hosting management (crear subdominio)
- [ ] WP-Admin en STAGING (será tu primero)
- [ ] GitHub repo + Actions habilitadas
- [ ] gh CLI o acceso GitHub web (para cargar Secrets/Variables)
- [ ] VS Code con el repo clonado

**Máquina local:**
```bash
# Verifica git clone
cd /home/pepe/work/runartfoundry
git branch -a | grep fase7
# Debe mostrar: feat/fase7-evidencias-auto o main (si ya merged)

# Verifica gh CLI
gh auth status
# Debe mostrar: "Logged in to github.com as <usuario>"
```

**WordPress:**
- [ ] Producción VIVO en https://runalfondry.com (NO tocar aún)
- [ ] BD productiva con datos reales
- [ ] SSH acceso a la máquina servidor

---

## FASE 1 — CREAR STAGING

### Paso 1.1: DNS del Staging

**En tu panel DNS/hosting:**

1. Crea subdominio: `staging.runalfondry.com`
2. Tipo: A record (apunta a la **misma IP** que runalfondry.com)
   ```
   staging.runalfondry.com  A  <IP-del-servidor>
   ```
3. Guarda cambios

**Verifica propagación (local):**
```bash
# Local:
nslookup staging.runalfondry.com
# Esperado: Address: <IP-esperada>

# Si no resuelve aún (TTL), espera 5-15 min y reintenta
```

**Tiempo: 5-15 min**

---

### Paso 1.2: HTTPS en Staging (Let's Encrypt)

**En el servidor (SSH):**

```bash
# Accede al servidor
ssh usuario@tu-servidor-ip

# Instala/renueva certificado Let's Encrypt
# (asume certbot + nginx/apache ya instalados)

sudo certbot certonly --webroot -w /var/www/html -d staging.runalfondry.com

# O si usas nginx:
sudo certbot certonly --nginx -d staging.runalfondry.com

# Configura virtual host en nginx:
sudo nano /etc/nginx/sites-available/staging.runalfondry.com
```

**Archivo nginx mínimo** (`/etc/nginx/sites-available/staging.runalfondry.com`):
```nginx
server {
    listen 443 ssl http2;
    server_name staging.runalfondry.com;

    ssl_certificate /etc/letsencrypt/live/staging.runalfondry.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/staging.runalfondry.com/privkey.pem;

    root /var/www/staging;
    index index.php index.html;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php-fpm.sock; # o tu PHP socket
        fastcgi_index index.php;
        include fastcgi_params;
    }

    location / {
        try_files $uri $uri/ /index.php?$args;
    }
}

server {
    listen 80;
    server_name staging.runalfondry.com;
    return 301 https://$server_name$request_uri;
}
```

**Habilita virtual host:**
```bash
sudo ln -s /etc/nginx/sites-available/staging.runalfondry.com /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

**Verifica localmente:**
```bash
# Desde tu máquina:
curl -I https://staging.runalfondry.com
# Esperado: HTTP/2 200 o 301 (redirect) + certificado válido
```

**Tiempo: 10-20 min**

---

### Paso 1.3: Estructura de Archivos WP en Staging

**En el servidor:**

```bash
# Crea directorio docroot
sudo mkdir -p /var/www/staging
sudo chown www-data:www-data /var/www/staging
sudo chmod 755 /var/www/staging

# Descarga WordPress core (opción A - manual)
cd /var/www/staging
wget https://wordpress.org/latest-es_ES.tar.gz
tar -xzf latest-es_ES.tar.gz
mv wordpress/* .
rm -rf wordpress latest-es_ES.tar.gz

# Copia wp-content desde PRODUCCIÓN (sin wp-config.php)
# Primero, verifica ruta en prod:
ls -la /var/www/prod/  # o la que sea tu ruta prod

# Copia:
rsync -avz --delete /var/www/prod/wp-content/ /var/www/staging/wp-content/

# Ajusta permisos:
sudo chown -R www-data:www-data /var/www/staging/wp-content
sudo chmod -R 755 /var/www/staging/wp-content
```

**Alternativa con WP-CLI** (más rápido):
```bash
cd /var/www/staging
wp core download --locale=es_ES --skip-content
# Copia wp-content desde prod:
rsync -avz --delete /var/www/prod/wp-content/ /var/www/staging/wp-content/
```

**Tiempo: 5-10 min**

---

### Paso 1.4: Base de Datos Staging (Copia Fresca)

**En producción (solo extracción, sin modificaciones):**

```bash
# En PROD (SSH):
cd /var/www/prod

# Extrae dump (sin mostrar password en history):
mysqldump -u wordpress_user -p wordpress_prod_db --single-transaction --quick --routines > /tmp/prod_dump.sql
# Te pedirá password interactivamente

# Verifica tamaño:
ls -lh /tmp/prod_dump.sql
# Esperado: varios MB (depende de tu BD)
```

**Transfiere a staging (desde tu máquina local o del servidor):**

```bash
# Si tienes acceso directo al servidor desde otra terminal:
scp usuario@servidor-ip:/tmp/prod_dump.sql ./prod_dump.sql

# O copia/paste manual en un archivo si es pequeño
```

**En staging:**

```bash
# SSH a staging:
ssh usuario@servidor-ip

# Crea BD nueva:
mysql -u staging_user -p -e "DROP DATABASE IF EXISTS wordpress_staging; CREATE DATABASE wordpress_staging CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
# Te pedirá password de staging_user

# Importa dump:
mysql -u staging_user -p wordpress_staging < /tmp/prod_dump.sql
# Espera varios segundos/minutos según tamaño

# Verifica tablas:
mysql -u staging_user -p -e "USE wordpress_staging; SHOW TABLES LIKE 'wp_%' LIMIT 5;"
```

**Reemplaza URLs (Prod → Staging):**

```bash
cd /var/www/staging

# Instala WP-CLI si no existe:
# curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
# chmod +x wp-cli.phar
# sudo mv wp-cli.phar /usr/local/bin/wp

# Reemplaza URLs:
wp search-replace 'https://runalfondry.com' 'https://staging.runalfondry.com' --all-tables --precise --report-changed-only

# Esperado: "Replacing 'https://runalfondry.com' with 'https://staging.runalfondry.com' in wp_options, wp_postmeta, ... (X replacements)"
```

**Tiempo: 15-30 min** (depende tamaño BD)

---

### Paso 1.5: Configurar wp-config.php en Staging

**En `/var/www/staging/wp-config.php`:**

```php
<?php

// === BD STAGING (NO la de prod) ===
define('DB_NAME', 'wordpress_staging');
define('DB_USER', 'staging_user');
define('DB_PASSWORD', '<password-staging>'); // NO la de prod
define('DB_HOST', 'localhost');

define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', 'utf8mb4_unicode_ci');

// === Security (NO cambies si no sabes) ===
define('AUTH_KEY',         'cambiar-a-valor-aleatorio-1');
define('SECURE_AUTH_KEY',  'cambiar-a-valor-aleatorio-2');
// ... (el rest de las keys/salts — puedes copiar de un generador online)

// === WP Settings ===
define('WP_DEBUG', false);
define('WP_DEBUG_LOG', false);
define('SCRIPT_DEBUG', false);

// Resto estándar:
if ( !defined('ABSPATH') )
    define('ABSPATH', __DIR__ . '/');

require_once(ABSPATH . 'wp-settings.php');
```

**Verifica permisos:**
```bash
sudo chown www-data:www-data /var/www/staging/wp-config.php
sudo chmod 600 /var/www/staging/wp-config.php
```

**Tiempo: 5 min**

---

### Paso 1.6: Verificar Staging Responde

**Localmente:**

```bash
# HTTP status:
curl -I https://staging.runalfondry.com
# Esperado: 200 OK

# REST API disponible:
curl -i https://staging.runalfondry.com/wp-json/
# Esperado: 200 OK (si REST habilitado) o 401 Unauthorized (correcto, sin auth)

# Frontend OK:
curl -s https://staging.runalfondry.com | grep -i "<!DOCTYPE"
# Esperado: HTML page (si wordpress responde correctamente)
```

**Desde navegador (opcional):**
```
https://staging.runalfondry.com/wp-admin/
# Verifica que carga el login de WordPress
```

**Tiempo: 2 min**

---

### Paso 1.7: Crear Usuario Técnico en WP-Staging

**En WP-Admin Staging** (`https://staging.runalfondry.com/wp-admin/`):

1. Usa usuario admin de la BD copiada (o crea new si no existe)
2. Navega a: **Users → Add New**
   - Username: `github-actions`
   - Email: `<tu-email>`
   - Role: **Editor** (suficiente para leer ajustes + crear posts)
   - Clic: **Add New User**

3. En el usuario **github-actions**, baja y clic: **Create Application Password**
   - Device/App name: `CI-GitHub-Actions-Staging`
   - Clic: **Generate Application Password**

4. **COPIA** la contraseña que aparece (UNA sola vez, NO la puedes volver a ver)
   ```
   xxxx xxxx xxxx xxxx | xxxx xxxx xxxx xxxx | xxxx xxxx xxxx xxxx
   ```
   - Guárdala localmente en un archivo TEMPORAL (NO en git)
   - NUNCA la peques en comentarios/logs públicos

5. Clic: **Confirm**

**Verifica funcionando:**
```bash
# Desde local:
curl -u github-actions:xxxx-xxxx-xxxx-xxxx https://staging.runalfondry.com/wp-json/wp/v2/users/me
# Esperado: JSON con tu usuario
```

**Tiempo: 5 min**

---

## FASE 2 — CARGAR VARIABLES/SECRETS EN GITHUB

### Opción A: gh CLI (Recomendado)

```bash
# En tu máquina local, en la raíz del repo:
cd /home/pepe/work/runartfoundry

# Verifica autenticación:
gh auth status
# Esperado: "Logged in to github.com as <tu-usuario>"

# ============================================================
# 1) Variable pública (URL Staging)
# ============================================================
gh variable set WP_BASE_URL --body "https://staging.runalfondry.com"

# Verifica:
gh variable list | grep WP_BASE_URL
# Esperado: WP_BASE_URL   https://staging.runalfondry.com

# ============================================================
# 2) Secret: Usuario
# ============================================================
gh secret set WP_USER --body "github-actions"

# ============================================================
# 3) Secret: Application Password (STAGING)
# ============================================================
gh secret set WP_APP_PASSWORD --body "xxxx-xxxx-xxxx-xxxx-xxxx-xxxx-xxxx-xxxx"
# (Pega la contraseña completa que copiaste de WP-Admin)

# Verifica secrets están cargados (solo nombres, no valores):
gh secret list | grep WP_
# Esperado:
# WP_APP_PASSWORD  Updated 2025-10-20
# WP_USER          Updated 2025-10-20
```

**Tiempo: 3 min**

### Opción B: GitHub Web UI

1. Repo → **Settings → Secrets and variables → Actions**
2. **Variables tab:**
   - Clic: **New repository variable**
   - Name: `WP_BASE_URL`
   - Value: `https://staging.runalfondry.com`
   - Clic: **Add variable**

3. **Secrets tab:**
   - Clic: **New repository secret**
   - Name: `WP_USER`
   - Value: `github-actions`
   - Clic: **Add secret**

4. Repite para `WP_APP_PASSWORD` con la contraseña copiada

**Tiempo: 5 min**

---

## FASE 3 — EJECUTAR VERIFY-* EN STAGING

### Verificación Previa

```bash
# Verifica que workflows existen:
ls -la .github/workflows/verify-*.yml
# Esperado:
# verify-home.yml
# verify-media.yml
# verify-menus.yml
# verify-settings.yml

# Verifica que tienen trigger workflow_dispatch:
grep -A 2 "workflow_dispatch:" .github/workflows/verify-home.yml
# Esperado: event section con workflow_dispatch
```

### Ejecución Secuencial

**En GitHub Actions o con gh CLI:**

#### 1) verify-home

```bash
# Opción A: gh CLI
gh workflow run verify-home.yml

# Opción B: GitHub UI
# Repo → Actions → "verify-home" → "Run workflow" → rama main → "Run workflow"

# Espera 2-3 minutos a que termine
gh run list --workflow=verify-home.yml --limit=1
# Esperado: ✓ COMPLETED (verde)

# Descarga artifact (opcional):
gh run download <run-id> -n verify-home_summary.txt -D ./artifacts/
# O desde GitHub UI: Actions → last run → Artifacts → descargar

# Valida en artifact:
cat artifacts/verify-home_summary.txt | grep -i "auth\|mode"
# Esperado:
# mode=real
# Auth=OK
# HTTP_STATUS_FRONT_ES=200
# HTTP_STATUS_FRONT_EN=200
```

**Esperado en logs:**
```
✓ verify-home PASSED
  - mode=real (detectado WP_BASE_URL != placeholder)
  - Auth=OK (credenciales válidas)
  - Frontend ES: 200 OK
  - Frontend EN: 200 OK (si existe)
```

**Si falla:**
```
✗ verify-home FAILED
  - Auth=KO (credenciales inválidas)
  - Error: 401 Unauthorized

Acciones:
1. Verifica que WP_APP_PASSWORD es la correcta
2. Verifica usuario github-actions existe en WP
3. Regenera Application Password en WP-Admin
4. Actualiza secret: gh secret set WP_APP_PASSWORD --body "..."
5. Reintenta workflow
```

---

#### 2) verify-settings

```bash
# Ejecuta:
gh workflow run verify-settings.yml
# Espera 2-3 min

# Valida:
cat artifacts/verify-settings_summary.txt | grep -i "auth\|compliance"
# Esperado:
# Auth=OK
# Compliance=OK (o Compliance=DRIFT si hay cambios)
```

**Esperado:**
```
✓ verify-settings PASSED
  - Auth=OK
  - Settings validated: 15/15 ✓
  - Compliance=OK
```

---

#### 3) verify-menus

```bash
# Ejecuta:
gh workflow run verify-menus.yml
# Espera 2-3 min

# Valida:
cat artifacts/verify-menus_summary.txt | grep -i "auth"
# Esperado: Auth=OK
```

**Esperado:**
```
✓ verify-menus PASSED
  - Auth=OK
  - REST Menus endpoint available
  - Menus count: 3 ✓
```

**Si ⚠️ Aviso (menus no en REST):**
```
⚠️ verify-menus PARTIAL
  - Auth=OK
  - REST Menus endpoint: NOT AVAILABLE
  - (Plugin REST API Menus puede ser necesario)
```

---

#### 4) verify-media

```bash
# Ejecuta:
gh workflow run verify-media.yml
# Espera 2-3 min

# Valida:
cat artifacts/verify-media_summary.txt | grep -i "auth\|missing"
# Esperado:
# Auth=OK
# MISSING=0 (o MISSING=<número bajo>)
```

**Esperado:**
```
✓ verify-media PASSED
  - Auth=OK
  - Media library readable
  - MISSING attachments: 0
```

### Resumen Staging

| Workflow | Status | Auth | Esperado |
|----------|--------|------|----------|
| verify-home | ✓ PASSED | OK | 200 OK |
| verify-settings | ✓ PASSED | OK | Compliance OK |
| verify-menus | ✓ PASSED | OK | ⚠️ Posible REST issue (OK) |
| verify-media | ✓ PASSED | OK | MISSING ≤ 3 |

**Tiempo: 15 min (4 workflows × 2-3 min + espera)**

---

## FASE 4 — DOCUMENTAR STAGING

### Descarga Artifacts

```bash
# Crea directorio local:
mkdir -p ./artifacts/staging

# Descarga todos los artifacts de los últimos runs:
# (Adapta run-id según tu repo)

gh run list --workflow=verify-home.yml --limit=1 --json databaseId --jq '.[0].databaseId' > /tmp/run_id.txt
RUN_ID=$(cat /tmp/run_id.txt)

gh run download $RUN_ID -n verify-home_summary.txt -D ./artifacts/staging/
gh run download $RUN_ID -n verify-settings_summary.txt -D ./artifacts/staging/
gh run download $RUN_ID -n verify-menus_summary.txt -D ./artifacts/staging/
gh run download $RUN_ID -n verify-media_summary.txt -D ./artifacts/staging/

# Verifica:
ls -la ./artifacts/staging/
```

### Ejecutar Scripts de Procesamiento (Opcional)

```bash
# Si quieres auto-consolidar evidencias en documentos:

# 1) Recolectar evidencias (REST apunta a staging):
export WP_BASE_PROBE_URL="https://staging.runalfondry.com"
bash tools/fase7_collect_evidence.sh

# 2) Procesar:
python3 tools/fase7_process_evidence.py

# Esto actualiza automáticamente:
# - 000_state_snapshot_checklist.md
# - 040_wp_rest_and_authn_readiness.md
# - 060_risk_register_fase7.md
# - Issue #50 (si existe)
```

### Adjuntar Artifacts en Issue #50

**En GitHub (web o local md):**

1. Abre Issue #50 en GitHub
2. En comentario, adjunta los 4 archivos `.txt` de `./artifacts/staging/`
   - O cópiapega el contenido en un bloque `<details>`
3. Escribe:
   ```markdown
   ## ✅ Validación Staging (Preview Primero)

   **Fecha:** 2025-10-20  
   **URL:** https://staging.runalfondry.com  
   **Status:** 🟢 TODOS OK (Auth=OK)

   ### Resultados Workflows

   - verify-home: ✓ PASSED (200 OK, Auth=OK)
   - verify-settings: ✓ PASSED (Auth=OK, Compliance=OK)
   - verify-menus: ✓ PASSED (Auth=OK)
   - verify-media: ✓ PASSED (Auth=OK, MISSING=0)

   ### Artifacts Adjuntos
   - [verify-home_summary.txt](...)
   - [verify-settings_summary.txt](...)
   - [verify-menus_summary.txt](...)
   - [verify-media_summary.txt](...)
   ```

**Tiempo: 10 min**

---

## FASE 5 — PROMOVER A PRODUCCIÓN

**⚠️ PUNTO DE NO RETORNO: Verifica 3 veces antes de cambiar a PROD**

### Pre-Checklist Producción

- [ ] Todos 4 workflows pasaron en STAGING ✓
- [ ] Auth=OK confirmado en artifacts
- [ ] Backups de PROD realizados (fuera de scope, pero importante)
- [ ] Rollback plan entendido (ver abajo)

### Cambiar Variables a Producción

```bash
# 1) URL Base → Producción
gh variable set WP_BASE_URL --body "https://runalfondry.com"

# Verifica:
gh variable get WP_BASE_URL
# Esperado: https://runalfondry.com

# 2) NUEVO: Generar App Password en WP-PROD

# En WP-Admin PROD (https://runalfondry.com/wp-admin/):
# - Users → github-actions (o crea si no existe)
# - Create Application Password
# - Device/App name: CI-GitHub-Actions-Prod
# - Generate
# - COPIA la contraseña (xxxx xxxx xxxx...)

# 3) Actualizar Secret WP_APP_PASSWORD (PROD):
gh secret set WP_APP_PASSWORD --body "xxxx-xxxx-xxxx-xxxx (PROD)"

# Verifica secret está actualizado (solo nombre):
gh secret list | grep WP_APP_PASSWORD
# Esperado: WP_APP_PASSWORD (updated timestamp reciente)
```

**Tiempo: 10 min**

---

## FASE 6 — VALIDAR PRODUCCIÓN

**Repite los 4 workflows, ahora contra PROD:**

```bash
# 1) verify-home
gh workflow run verify-home.yml
# Espera 2-3 min
# Valida: Auth=OK, 200 OK

# 2) verify-settings
gh workflow run verify-settings.yml
# Espera 2-3 min
# Valida: Auth=OK, Compliance=OK

# 3) verify-menus
gh workflow run verify-menus.yml
# Espera 2-3 min
# Valida: Auth=OK

# 4) verify-media
gh workflow run verify-media.yml
# Espera 2-3 min
# Valida: Auth=OK, MISSING≤3
```

### Validación de Resultados

```bash
# Descarga artifacts PROD:
RUN_ID=$(gh run list --workflow=verify-home.yml --limit=1 --json databaseId --jq '.[0].databaseId')
gh run download $RUN_ID -n verify-home_summary.txt -D ./artifacts/prod/

# Verifica Auth=OK en PROD:
cat ./artifacts/prod/verify-home_summary.txt | grep -i "auth\|mode"
# Esperado:
# mode=real
# Auth=OK
# HTTP_STATUS_FRONT_ES=200
```

**Esperado:**
```
✓ verify-home PASSED (PROD)
✓ verify-settings PASSED (PROD)
✓ verify-menus PASSED (PROD)
✓ verify-media PASSED (PROD)

Todos con Auth=OK
```

**Si falla alguno:**
→ Ver [Rollback Plan](#rollback-plan) abajo

**Tiempo: 15 min (4 workflows)**

---

## FASE 7 — CIERRE DOCUMENTAL

### Actualizar Documentación

```bash
# En VS Code, en raíz del repo:

# 1) Actualiza Issue #50 con cierre:
#    - Agrega sección "✅ Validación Producción (Fase 7 — Final)"
#    - Adjunta artifacts PROD
#    - Marca todos los checkboxes completados

# 2) Ejecuta script de consolidación (opcional):
python3 tools/fase7_process_evidence.py
# Actualiza automáticamente:
# - 000_state_snapshot_checklist.md (todos pilares ✓)
# - 040_wp_rest_and_authn_readiness.md (REST = OK PROD)
# - 050_decision_record_styling_vs_preview.md (Status = ACCEPTED)
# - 060_risk_register_fase7.md (R2-R7 = Mitigado)
```

### Actualizar CHANGELOG

En `CHANGELOG.md`, agrega:

```markdown
## [Fase 7] — 2025-10-20

### ✅ Conexión WordPress Real - Preview Primero Completada

**Hito:** Primera integración con WordPress producción (runalfondry.com)

**Validaciones:**
- ✅ Staging: verify-* todos PASSED (Auth=OK)
- ✅ Producción: verify-* todos PASSED (Auth=OK)
- ✅ Workflows en modo real (mode=real)
- ✅ REST API autenticación operativa
- ✅ Alertas automáticas habilitadas

**Documentación:**
- Issue #50: Fase 7 — Conexión WP Real (COMPLETADA)
- 070_preview_staging_plan.md: Implementado
- Artifacts: verify-home/settings/menus/media en PROD

**Próximo:** Fase 8 — Automatización de Contenidos (pendiente)
```

### Commits y PR

```bash
# Prepara commit:
git add -A
git commit -m "docs(fase7): validación staging+producción, artifacts y cierre (Auth=OK)"

# Push:
git push origin feat/fase7-evidencias-auto
# O a main si ya merged

# Abre/Finaliza PR en GitHub:
gh pr create --title "Fase 7 — Conexión WordPress Real (Auth=OK)" \
  --body "Validación staging y producción completadas. Issue #50 adjunto. Listo para merge."

# O finaliza PR existente:
gh pr view --web
# Aprueba y merge desde GitHub UI
```

**Tiempo: 20 min**

---

## ROLLBACK PLAN

**Si algo falla en Staging:**

```bash
# Revert variable:
gh variable set WP_BASE_URL --body "placeholder.local"

# Workflows vuelven a modo simulación (seguro)
# Investigar sin presión
```

**Si algo falla en Producción:**

```bash
# Opción 1: Volver a STAGING
gh variable set WP_BASE_URL --body "https://staging.runalfondry.com"
gh secret set WP_APP_PASSWORD --body "<app-password-staging>"

# Opción 2: Volver a PLACEHOLDER (nuclear)
gh variable set WP_BASE_URL --body "placeholder.local"

# Después:
# 1. Investigar error en logs/artifacts
# 2. Fijar problema en WP-Admin o código
# 3. Reintent
```

**Si se expuso un secreto:**

```bash
# INMEDIATO:
# 1. Regenera App Password en WP-Admin (invalida viejo)
# 2. Actualiza secret:
gh secret set WP_APP_PASSWORD --body "<new-app-password>"
# 3. Re-ejecuta workflows
# 4. Auditoría de logs (GitHub Actions)
```

---

## CRITERIO DE ÉXITO (Definición de Hecho)

✅ **Staging OK:**
- [ ] verify-home: PASSED, Auth=OK, HTTP 200
- [ ] verify-settings: PASSED, Auth=OK, Compliance=OK
- [ ] verify-menus: PASSED, Auth=OK
- [ ] verify-media: PASSED, Auth=OK

✅ **Producción OK:**
- [ ] verify-home: PASSED, Auth=OK, HTTP 200
- [ ] verify-settings: PASSED, Auth=OK, Compliance=OK
- [ ] verify-menus: PASSED, Auth=OK
- [ ] verify-media: PASSED, Auth=OK

✅ **Documentación:**
- [ ] Issue #50 completado (checkboxes + artifacts)
- [ ] CHANGELOG.md actualizado
- [ ] 000/040/050/060 consolidados
- [ ] Artifacts adjuntos en repo

✅ **Seguridad:**
- [ ] Ningún secreto en git
- [ ] Ningún secreto en logs públicos
- [ ] GitHub enmascaró secretos en artifacts
- [ ] Backups de PROD disponibles

---

## TIMELINE ESTIMADO

```
HOY (2025-10-20):
├─ 15:00 → 15:30: Paso 1.1-1.7 (Crear Staging) — 30 min
├─ 15:30 → 15:35: Fase 2 (Cargar Secrets) — 5 min
├─ 15:35 → 16:00: Fase 3 (Ejecutar verify-* Staging) — 25 min
├─ 16:00 → 16:15: Fase 4 (Documentar Staging) — 15 min
├─ 16:15 → 16:20: Fase 5 (Promover a Prod) — 5 min
├─ 16:20 → 16:40: Fase 6 (Validar Prod) — 20 min
└─ 16:40 → 17:00: Fase 7 (Cierre + Commit) — 20 min

TOTAL: ~3 horas (si todo sale bien)
+ 30 min buffer para troubleshooting

DURACIÓN COMPLETA: ~3.5-4.5 horas
```

---

## TROUBLESHOOTING RÁPIDO

| Problema | Síntoma | Solución |
|----------|---------|----------|
| **Auth=KO** | verify-* falla con 401 | Regenera App Password en WP-Admin, actualiza secret |
| **DNS no resuelve** | curl: Could not resolve | Espera propagación DNS (5-15 min) o verifica A record |
| **SSL cert inválido** | curl: certificate verify failed | Renueva Let's Encrypt: certbot certonly --webroot |
| **WP no carga** | HTTP 500 en staging | Verifica wp-config.php, permisos, BD credentials |
| **BD import falla** | mysql error | Verifica sintaxis dump, usuario/permisos BD staging |
| **Workflows no detectan modo=real** | mode=placeholder aún | Verifica que WP_BASE_URL está cargado en GitHub |
| **REST API 404** | /wp-json/ not found | Habilita REST en WP-Admin: Settings → Permalinks → Save |

---

**Creado por:** Copilot Fase 7  
**Status:** 🟢 Listo para usar  
**Próxima revisión:** Post-ejecución 2025-10-20

