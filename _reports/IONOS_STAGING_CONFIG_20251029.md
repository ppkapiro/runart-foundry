# Configuración IONOS Staging - RunArt Foundry

**Fecha:** 2025-10-29  
**Servidor:** access958591985.webspace-data.io  
**Usuario:** u11876951

---

## ⚠️ Limitaciones de Acceso

### SSH/SFTP Directo: BLOQUEADO
- **Protocolo mostrado:** SFTP + SSH (puerto 22)
- **Estado:** ❌ Login failed - Políticas IONOS bloquean acceso SSH directo
- **Intentos realizados:**
  - `ssh u11876951@access958591985.webspace-data.io` → Permission denied
  - `sftp` → Login incorrect
  - `lftp sftp://` → Login failed
  - `lftp ftp://` → (cancelado)

### ✅ Acceso Disponible: WordPress REST API + Application Password
**Método confirmado y VERIFICADO:** WordPress REST API con Application Password  
**Estado:** ✅ FUNCIONANDO (probado 2025-10-29)

**Credenciales configuradas:**
```bash
export WP_USER="runart-admin"
export WP_APP_PASSWORD="WNoAVgiGzJiBCfUUrMI8GZnx"
export WP_REST_URL="https://staging.runartfoundry.com/wp-json"
```

**Test de autenticación exitoso:**
```bash
curl -u "runart-admin:WNoAVgiGzJiBCfUUrMI8GZnx" \
  "https://staging.runartfoundry.com/wp-json/wp/v2/users/me"
# ✅ Response: {"id":6,"name":"runart-admin",...}
```

**Ventajas:**
- Acceso completo a WordPress sin SSH directo
- API REST completa: themes, plugins, posts, media, users
- Autenticación segura via Application Password
- Integración con scripts automatizados
- Ya usado en CI/CD (GitHub Actions workflows)

---

## 🔧 Métodos de Deployment Disponibles

### Opción 1: WordPress REST API (RECOMENDADO Y VERIFICADO)
**Estado:** ✅ FUNCIONANDO

**Uso básico:**
```bash
# Source credentials
source ~/.runart_staging_env

# Listar themes
curl -u "$WP_USER:$WP_APP_PASSWORD" \
  "https://staging.runartfoundry.com/wp-json/wp/v2/themes"

# Listar plugins  
curl -u "$WP_USER:$WP_APP_PASSWORD" \
  "https://staging.runartfoundry.com/wp-json/wp/v2/plugins"

# Info del sitio
curl -u "$WP_USER:$WP_APP_PASSWORD" \
  "https://staging.runartfoundry.com/wp-json/"
```

**Deployment theme files:**
- Método actual: Subir vía wp-admin Theme Editor (manual)
- Método futuro: Plugin Bridge con endpoint custom para upload

### Opción 2: FTP Manual con FileZilla (FALLBACK)
**Credenciales FTP:**
```
Host: access958591985.webspace-data.io
Protocol: SFTP (puerto 22) o FTP/SSL  
Usuario: u11876951
Password: Tomeguin19$
```

**Proceso:**
1. Conectar con FileZilla
2. Navegar a `/wp-content/themes/runart-base/`
3. Subir archivos modificados
4. Verificar permisos (644 archivos, 755 directorios)

### Opción 3: wp-admin Theme Editor (RÁPIDO para CSS/PHP)
**URL:** https://staging.runartfoundry.com/wp-admin/theme-editor.php

**Ideal para:**
- `responsive.overrides.css` (cambios v0.3.1)
- `functions.php` (enqueue CSS)
- Hotfixes rápidos sin FTP

### Opción 4: WP-CLI Remoto via Panel IONOS
**Acceso vía:** Panel IONOS → WordPress → WP-CLI terminal

**Comandos útiles:**
```bash
# Verificar versión y acceso
wp --version
wp core version
wp theme list

# Actualizar theme desde Git/URL
wp theme install https://github.com/RunArtFoundry/runart-foundry/archive/refs/tags/v0.3.1-responsive-final.zip --force

# O actualizar archivos específicos del theme activo
wp theme get runart-base --field=status
wp theme update runart-base

# Cache flush
wp cache flush
wp transient delete --all

# Verificar archivos
ls -la wp-content/themes/runart-base/
```

### Opción 2: Panel Web (wp-admin File Manager)
**Acceso:** https://staging.runartfoundry.com/wp-admin/  
**Ruta:** Appearance → Theme File Editor  
**Limitaciones:**
- Solo archivos individuales (no bulk upload)
- Sin backup automático
- Propenso a errores humanos

### Opción 3: FTP via Panel IONOS
**Si FTP está habilitado:**
- Verificar en panel IONOS si FTP (no SFTP) está disponible
- Puerto estándar: 21
- Puede requerir activación explícita

---

## 📋 Plan de Deployment v0.3.1 (Actualizado)

### Pre-requisitos
- [x] Credenciales IONOS configuradas en `~/.runart_staging_env`
- [x] Acceso SSH directo: ❌ BLOQUEADO
- [ ] Acceso WP-CLI verificado (requiere login panel IONOS)
- [ ] Estructura remota documentada

### Estrategia Recomendada: WP-CLI + Manual Upload

#### Paso 1: Preparar Package Local
```bash
cd /home/pepe/work/runartfoundry
git archive --format=zip --output=/tmp/runart-base-v0.3.1.zip v0.3.1-responsive-final:wp-content/themes/runart-base/
ls -lh /tmp/runart-base-v0.3.1.zip
```

#### Paso 2A: Upload vía Panel IONOS File Manager
1. Login: https://my.ionos.com/
2. Web Hosting → File Manager
3. Navegar a: `/wp-content/themes/`
4. Crear backup manual: renombrar `runart-base` a `runart-base.backup.20251029`
5. Upload ZIP y extraer
6. Verificar permisos (755 directorios, 644 archivos)

#### Paso 2B: O usar WP-CLI (si accesible vía panel)
```bash
# En WP-CLI terminal del panel IONOS:
cd wp-content/themes/

# Backup
mv runart-base runart-base.backup.$(date +%Y%m%d_%H%M%S)

# Upload nuevo theme (si GitHub release es público)
wget https://github.com/RunArtFoundry/runart-foundry/archive/refs/tags/v0.3.1-responsive-final.tar.gz
tar -xzf v0.3.1-responsive-final.tar.gz
mv runart-foundry-v0.3.1-responsive-final/wp-content/themes/runart-base ./
rm -rf runart-foundry-v0.3.1-responsive-final*

# O si es privado, subir ZIP previamente vía File Manager
unzip runart-base-v0.3.1.zip -d runart-base/
```

#### Paso 3: Cache Flush (WP-CLI recomendado)
```bash
# Vía WP-CLI en panel IONOS
wp cache flush
wp transient delete --all

# O vía wp-admin si WP-CLI no disponible
# Performance → Cache → Purge All
```

#### Paso 4: Verificación
```bash
# Local smoke test
for route in / /en/ /es/; do
  url="https://staging.runartfoundry.com${route}?v=now"
  status=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  echo "$status - $url"
done
```

---

## 🎯 Alternativa: GitHub Actions Deployment

### Crear Workflow Automatizado
**Path:** `.github/workflows/deploy-staging-ionos.yml`

**Ventajas:**
- Automatizado en cada push a `main`
- Usa WP-CLI vía SSH tunnel o API REST
- Backup automático pre-deployment
- Rollback automático si falla

**Requisitos:**
- GitHub Secrets con credenciales IONOS
- WP-CLI accesible vía API REST (plugin `wp-cli-rest-api`)
- O tunnel SSH/VPN si IONOS lo permite para CI/CD

**Template básico:**
```yaml
name: Deploy to IONOS Staging

on:
  push:
    branches: [main]
    paths:
      - 'wp-content/themes/runart-base/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Create theme package
        run: |
          cd wp-content/themes/runart-base
          zip -r /tmp/runart-base.zip .
      
      - name: Deploy via WP-CLI REST API
        env:
          WP_URL: ${{ secrets.STAGING_URL }}
          WP_USER: ${{ secrets.WP_ADMIN_USER }}
          WP_PASS: ${{ secrets.WP_ADMIN_PASS }}
        run: |
          # Install WP-CLI
          curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
          chmod +x wp-cli.phar
          
          # Deploy (si REST API disponible)
          # O subir vía FTP si disponible
          
      - name: Smoke test
        run: |
          curl -f https://staging.runartfoundry.com/ || exit 1
```

---

## 🔑 Credenciales Almacenadas

**Archivo:** `~/.runart_staging_env` (chmod 600)

```bash
export IONOS_SSH_HOST="u11876951@access958591985.webspace-data.io"
export IONOS_SSH_USER="u11876951"
export SSH_PORT=22
export IONOS_SFTP_HOST="access958591985.webspace-data.io"
# Password: Tomeguin19$ (almacenado de forma segura)
```

**Nota:** SSH/SFTP directo NO funciona. Usar WP-CLI o panel web.

---

## ✅ Próximos Pasos INMEDIATOS

1. **Verificar acceso WP-CLI:**
   - Login panel IONOS: https://my.ionos.com/
   - Buscar: WordPress → WP-CLI terminal
   - Ejecutar: `wp --version` y documentar output

2. **Preparar package theme v0.3.1:**
   ```bash
   cd /home/pepe/work/runartfoundry
   git archive --format=zip --output=/tmp/runart-base-v0.3.1.zip v0.3.1-responsive-final:wp-content/themes/runart-base/
   ```

3. **Deployment manual (primera vez):**
   - Vía File Manager IONOS o WP-CLI según disponibilidad
   - Backup previo OBLIGATORIO
   - Cache flush post-deployment

4. **Smoke tests:**
   - 12 rutas con `?v=now`
   - Lighthouse re-audit

5. **Automatizar (si WP-CLI disponible):**
   - Crear script `tools/deploy_wpcli_staging.sh`
   - O GitHub Action si REST API disponible

---

**Última actualización:** 2025-10-29 (SSH bloqueado confirmado, WP-CLI identificado como alternativa)
