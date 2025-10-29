# Estado Deployment SSH/SFTP — RunArt Foundry v0.3.1

**Fecha revisión:** 2025-10-28 19:45:00 -04:00  
**Versión actual main:** v0.3.1-responsive-final (commit a098d6c)  
**Target deployment:** IONOS staging.runartfoundry.com  

---

## ✅ Completado Hasta Ahora

### 1. Merge y Release
- ✅ PR `fix/responsive-v0.3.1` mergeado a `main` (fast-forward, 4 commits)
- ✅ Tag `v0.3.1-responsive-final` creado y pusheado
- ✅ Lighthouse audits: Performance 96.5-100, Accessibility 90-93, LCP 1.50-2.05s
- ✅ 54 archivos modificados (+436K inserciones)
- ✅ Documentación completa generada:
  - `_reports/ACTUALIZACION_MAIN_20251028.md`
  - `_reports/INVENTARIO_RAMAS_20251028.json` (37 ramas)
  - `_reports/RESUMEN_EJECUTIVO_20251028.md`

### 2. Fase 2 Imaging Pipeline
- ✅ Rama `feat/imaging-pipeline` creada y pusheada
- ✅ Estructura inicializada (NO implementada):
  - `docs/imaging/00-roadmap.md` (roadmap completo)
  - `wp-content/themes/runart-base/assets/assets.json` (stub)
  - `wp-content/themes/runart-base/assets/img/` (directorio)
  - `wp-content/themes/runart-base/inc/helpers/images.php` (stubs)
  - `tools/validate_images.sh` (script validación stub)

### 3. Branch Alignment
- ✅ Inventario de 37 ramas completado con estado (behind/ahead main)
- ⚠️ `develop` branch: bloqueada por protección GitHub (requiere PR vía UI)
- ⏳ `preview` branch: 311 commits stale (pendiente decisión)

---

## ⏳ Pendiente: Deployment WordPress a Staging

### Estado Actual
**NO HAY DEPLOYMENT AUTOMÁTICO** para cambios en `wp-content/themes/**`

### Scripts Disponibles

#### 1. `tools/deploy_fase2_staging.sh`
**Propósito:** Deployment i18n Fase 2 (navegación bilingüe)  
**Método:** Manual copy/paste o FTP/SSH  
**Configuración requerida:** ❌ No configurado con credenciales SSH/SFTP

**Funcionalidad:**
- Verificación de staging accesible (curl)
- Verificación Polylang activo (API REST)
- Preparación de functions.php con i18n
- ⚠️ Requiere deployment manual vía:
  - FTP/SSH a `/wp-content/themes/generatepress_child/`
  - wp-admin Theme Editor copy/paste

#### 2. `tools/staging_privacy.sh`
**Propósito:** Crear robots.txt anti-index en staging  
**Método:** SSH directo  
**Configuración:** ❌ Requiere variables de entorno

```bash
export IONOS_SSH_HOST="usuario@host.ionos.de"
export SSH_PORT=22  # opcional, default 22
```

**Comando:**
```bash
ssh -p 22 usuario@host.ionos.de "printf 'User-agent: *\nDisallow: /\n' > /staging/robots.txt"
```

#### 3. `tools/remote_run_autodetect.sh`
**Propósito:** Ejecutar scripts de reparación en servidor remoto vía SSH  
**Método:** SSH + bash remote execution  
**Configuración:** ❌ Requiere SSH key sin password o agent

**Uso:**
```bash
./tools/remote_run_autodetect.sh usuario@servidor.ionos.com ~/.runart_env
```

---

## 🚧 Bloqueadores Identificados (ACTUALIZADO 2025-10-29)

### 1. **SSH/SFTP Directo BLOQUEADO por IONOS**
**Impacto:** ALTO (pero SOLUCIONABLE)  
**Estado:** ✅ **RESUELTO** - Alternativa WP-CLI identificada

**Descripción:** 
- ❌ SSH directo bloqueado por políticas IONOS hosting compartido
- ❌ SFTP authentication failed (usuario/password correctos pero acceso denegado)
- ✅ **WP-CLI disponible** vía panel IONOS → método alternativo confirmado

**Credenciales configuradas:**
```bash
# Archivo: ~/.runart_staging_env (chmod 600) ✅ CREADO
export IONOS_SSH_HOST="u11876951@access958591985.webspace-data.io"
export IONOS_SSH_USER="u11876951"
export SSH_PORT=22
# Password: Tomeguin19$ (confirmado pero SSH bloqueado)
```

**Solución:** Deployment vía WP-CLI o File Manager web (ver IONOS_STAGING_CONFIG_20251029.md)

### 2. **Deployment vía WP-CLI o File Manager (Actualizado)**
**Impacto:** MEDIO (requiere acceso manual)  
**Descripción:** 

**Métodos disponibles confirmados:**

#### ✅ Opción 1: WP-CLI (RECOMENDADO)
- Acceso vía panel IONOS → WordPress → Terminal WP-CLI
- Permite comandos: `wp theme`, `wp cache flush`, upload desde URL
- **Package preparado:** `/tmp/runart-base-v0.3.1-responsive.zip` (5.6KB) ✅

#### ✅ Opción 2: File Manager Web
- Panel IONOS → Web Hosting → File Manager
- Upload ZIP manual a `/wp-content/themes/`
- Backup manual previo requerido

#### ❌ Opción 3: rsync/scp sobre SSH
- NO DISPONIBLE (SSH bloqueado)

**Necesidad:** Documentar acceso WP-CLI exacto en panel IONOS (pendiente login usuario)

### 3. **Estructura remota IONOS - Pendiente exploración vía WP-CLI**
**Impacto:** BAJO (WP-CLI abstrae paths)  
**Descripción:** 
- Path WordPress root: (detectar con `wp core version --extra`)
- WP-CLI disponibilidad: ✅ Confirmado por usuario
- Permisos archivos: (verificar post-upload)

**Acción requerida:** Login panel IONOS y ejecutar comandos WP-CLI para documentar:
```bash
wp --info
wp core version --extra
wp theme list --path=full
ls -la wp-content/themes/
```

---

## 📋 Checklist Pre-Deployment

### Configuración Inicial (UNA VEZ)
- [ ] Obtener credenciales SSH/SFTP de IONOS
- [ ] Configurar SSH key sin password (o usar ssh-agent)
- [ ] Verificar acceso SSH: `ssh usuario@host.ionos.de`
- [ ] Explorar estructura remota: `ls -la /html/`, `which wp`
- [ ] Documentar paths en `_reports/IONOS_STAGING_CONFIG.md`
- [ ] Crear `.env` con credenciales (NO commitear, añadir a `.gitignore`)

### Pre-Flight Checks (CADA DEPLOYMENT)
- [ ] Backup remoto de `wp-content/themes/runart-base/` actual
- [ ] Verificar staging accesible: `curl -I https://staging.runartfoundry.com`
- [ ] Verificar versión git local: `git status`, `git log -1`
- [ ] Lighthouse audit local (baseline): `RUNS=1 node tools/lighthouse_mobile/runner.js`

### Deployment
- [ ] Ejecutar script SSH/SFTP (TBD: crear `deploy_theme_ssh.sh`)
- [ ] Verificar upload exitoso (checksum o diff remoto)
- [ ] Purgar cache WordPress: `wp cache flush` o via wp-admin
- [ ] Purgar cache Cloudflare (si aplica): API o dashboard

### Post-Deployment Validation
- [ ] Smoke test 12 rutas con `?v=now`:
  - `/`, `/en/`, `/es/`
  - `/en/about/`, `/es/about/`
  - `/en/services/`, `/es/services/`
  - `/en/projects/`, `/es/projects/`
  - `/en/blog/`, `/es/blog-2/`
  - `/en/contact/`, `/es/contacto/`
- [ ] Lighthouse re-audit: Performance ≥95, Accessibility ≥90
- [ ] Visual QA: hero sin overflow 360-430px, CTAs bilingües visibles
- [ ] Rollback plan: restaurar backup si falla

---

## 🎯 Plan de Acción Inmediato

### Paso 1: Configurar SSH Access (BLOQUEANTE)
**Responsable:** Usuario (pepe)  
**Tiempo estimado:** 15-30 min  

1. Obtener credenciales IONOS:
   - Login a panel IONOS
   - SSH/SFTP section
   - Copiar: host, usuario, obtener/generar password o SSH key

2. Crear archivo config local:
   ```bash
   cat > ~/.runart_staging_env << 'EOF'
   export IONOS_SSH_HOST="u111876951@access958591985.webspace-data.io"
   export IONOS_SSH_KEY="~/.ssh/ionos_runart"
   export SSH_PORT=22
   export STAGING_WP_PATH="/html/staging/wp-content"
   EOF
   chmod 600 ~/.runart_staging_env
   ```

3. Setup SSH key (si no existe):
   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/ionos_runart -C "runart-staging-deploy"
   ssh-copy-id -i ~/.ssh/ionos_runart.pub usuario@host.ionos.de
   ```

4. Test conexión:
   ```bash
   source ~/.runart_staging_env
   ssh -i "$IONOS_SSH_KEY" -p "$SSH_PORT" "$IONOS_SSH_HOST" "pwd && which wp"
   ```

### Paso 2: Explorar Estructura Remota
**Comando:**
```bash
ssh usuario@host.ionos.de << 'EOSSH'
  echo "=== WordPress Root ==="
  find ~ -name "wp-config.php" -type f 2>/dev/null | head -3
  
  echo "=== Theme Path ==="
  find ~ -path "*/wp-content/themes/runart-base" -type d 2>/dev/null
  
  echo "=== WP-CLI ==="
  which wp || echo "WP-CLI no disponible"
  
  echo "=== Disk Space ==="
  df -h ~ | tail -1
  
  echo "=== PHP Version ==="
  php -v | head -1
EOSSH
```

**Documentar output en:** `_reports/IONOS_STAGING_EXPLORATION_20251028.md`

### Paso 3: Crear Script `deploy_theme_ssh.sh`
**Path:** `tools/deploy_theme_ssh.sh`  
**Template básico:**

```bash
#!/bin/bash
set -euo pipefail

# Source credenciales
source ~/.runart_staging_env

THEME_LOCAL="./wp-content/themes/runart-base"
THEME_REMOTE="$STAGING_WP_PATH/themes/runart-base"
BACKUP_REMOTE="$STAGING_WP_PATH/themes/runart-base.backup.$(date +%Y%m%d_%H%M%S)"

echo "🚀 Deploying RunArt theme to IONOS staging"
echo "Local:  $THEME_LOCAL"
echo "Remote: $THEME_REMOTE"

# Backup remoto
echo "📦 Backing up remote theme..."
ssh -i "$IONOS_SSH_KEY" "$IONOS_SSH_HOST" "cp -r $THEME_REMOTE $BACKUP_REMOTE"

# Sync con rsync (preserva permisos, excluye .git)
echo "📤 Syncing theme files..."
rsync -avz --delete \
  --exclude='.git' --exclude='node_modules' --exclude='*.log' \
  -e "ssh -i $IONOS_SSH_KEY -p $SSH_PORT" \
  "$THEME_LOCAL/" \
  "$IONOS_SSH_HOST:$THEME_REMOTE/"

# Purge cache (si WP-CLI disponible)
echo "🗑️  Purging cache..."
ssh -i "$IONOS_SSH_KEY" "$IONOS_SSH_HOST" "cd $(dirname $STAGING_WP_PATH) && wp cache flush" || echo "WP-CLI not available"

echo "✅ Deployment complete"
echo "🔍 Verify: https://staging.runartfoundry.com/?v=now"
```

### Paso 4: Ejecutar Deployment
```bash
cd /home/pepe/work/runartfoundry
git status  # asegurar en main, commit a098d6c
./tools/deploy_theme_ssh.sh 2>&1 | tee logs/deploy_v0.3.1_$(date +%Y%m%d_%H%M%S).log
```

### Paso 5: Smoke Tests
```bash
# Test automatizado básico
for route in / /en/ /es/ /en/about/ /es/about/ /en/services/ /es/services/; do
  url="https://staging.runartfoundry.com${route}?v=now"
  status=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  echo "$status - $url"
done
```

### Paso 6: Lighthouse Re-Audit
```bash
cd /home/pepe/work/runartfoundry
BASE=https://staging.runartfoundry.com RUNS=2 node tools/lighthouse_mobile/runner.js
cat _reports/RESPONSIVE_LH_SUMMARY.json | jq '.pages[] | {route, perf: .performance.avg, acc: .accessibility.avg}'
```

---

## 📚 Referencias

### Documentación Existente
- Merge details: `_reports/ACTUALIZACION_MAIN_20251028.md`
- Branch inventory: `_reports/INVENTARIO_RAMAS_20251028.json`
- Executive summary: `_reports/RESUMEN_EJECUTIVO_20251028.md`
- Fase 2 roadmap: `docs/imaging/00-roadmap.md`

### Scripts Relacionados
- `tools/deploy_fase2_staging.sh` (i18n manual)
- `tools/staging_privacy.sh` (robots.txt SSH)
- `tools/remote_run_autodetect.sh` (remote execution template)
- `tools/verify_fase2_deployment.sh` (post-deploy validation)
- `tools/lighthouse_mobile/runner.js` (Lighthouse automation)

### Comandos Útiles
```bash
# Verificar staging accesible
curl -I https://staging.runartfoundry.com

# Test SSH (después de configurar)
ssh -i ~/.ssh/ionos_runart usuario@host.ionos.de "pwd"

# Lighthouse quick test (1 run, 3 páginas)
BASE=https://staging.runartfoundry.com RUNS=1 PAGES_JSON='["/","/en/","/es/"]' node tools/lighthouse_mobile/runner.js

# Git status check
git log --oneline -5
git describe --tags
```

---

## 🔐 Seguridad

### Variables de Entorno Sensibles
**NO COMMITEAR:**
- `IONOS_SSH_HOST`
- `IONOS_SSH_KEY`
- `IONOS_SFTP_PASS`

**Almacenar en:**
- `~/.runart_staging_env` (chmod 600)
- GitHub Secrets (si se automatiza en CI/CD futuro)
- 1Password / LastPass vault

### SSH Key Best Practices
- Usar `ed25519` o `rsa 4096` (no `rsa 2048`)
- Proteger con passphrase (usar ssh-agent)
- Rotar cada 6 meses
- No reusar keys entre proyectos

### Backup Strategy
- Backup automático pre-deployment (script debe incluir)
- Retention: últimos 5 backups remotos
- Backup local del staging completo mensual (opcional)

---

## ✅ Success Criteria Post-Deployment

### Funcional
- [ ] Todas las 12 rutas devuelven HTTP 200
- [ ] No hay errores PHP en logs (`wp-content/debug.log`)
- [ ] Hero images cargan correctamente (no 404)
- [ ] CTAs bilingües visibles y clickeables
- [ ] Language switcher funcional (si aplica Fase 2)

### Performance
- [ ] Lighthouse Performance ≥95 (móvil)
- [ ] Lighthouse Accessibility ≥90 (móvil)
- [ ] LCP ≤2.0s en hero pages (/, /en/, /es/)
- [ ] No horizontal overflow 360-430px viewport

### Rollback
- [ ] Backup remoto accesible
- [ ] Procedimiento de rollback documentado y testeado
- [ ] Tiempo de rollback ≤5 min

---

**Última actualización:** 2025-10-28 19:45:00 -04:00  
**Estado:** ⚠️ BLOQUEADO por falta de credenciales SSH/SFTP  
**Next Action:** Configurar `~/.runart_staging_env` con credenciales IONOS
