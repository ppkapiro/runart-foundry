# Deployment Master — RunArt Foundry

**Versión:** 1.0  
**Fecha:** 2025-10-29  
**Estado:** ✅ Validado en producción  
**Autor:** Equipo Técnico RunArt Foundry

---

## 📋 Tabla de Contenidos

1. [Descripción General](#1-descripción-general)
2. [Variables y Credenciales](#2-variables-y-credenciales)
3. [Método Oficial de Deployment](#3-método-oficial-de-deployment)
4. [Problemas Detectados y Cómo Evitarlos](#4-problemas-detectados-y-cómo-evitarlos)
5. [Buenas Prácticas](#5-buenas-prácticas)
6. [Procedimiento de Verificación Rápida](#6-procedimiento-de-verificación-rápida-checklist)
7. [Contactos y Mantenimiento](#7-contactos-y-mantenimiento)

---

## 1. Descripción General

### Entorno de Deployment

RunArt Foundry utiliza un flujo de deployment **100% basado en WordPress** con la siguiente arquitectura:

```
┌─────────────┐      ┌──────────────┐      ┌─────────────────┐
│   WSL/Local │ ───> │ IONOS Server │ ───> │ WordPress (WP)  │
│  (Develop)  │      │   (Hosting)  │      │  + WP-CLI       │
└─────────────┘      └──────────────┘      └─────────────────┘
```

**Componentes principales:**
- **WSL (Windows Subsystem for Linux):** Entorno de desarrollo local
- **IONOS:** Hosting compartido con SSH habilitado
- **WordPress 6.8.3 + PHP 8.0.30:** Backend del sitio
- **WP-CLI 2.11.0:** Herramienta de línea de comandos para WordPress
- **Rsync:** Sincronización de archivos vía SSH
- **Tema:** `runart-base` (tema personalizado)

### Estado Actual

- ✅ **Cloudflare desactivado:** No hay Pages, Functions ni Workers activos
- ✅ **API REST habilitada:** Autenticación vía Application Password
- ✅ **Staging aislado:** Base de datos y directorio separados de producción
- ✅ **Backup automático:** Cada deployment crea respaldo previo

### Flujo de Trabajo

1. **Desarrollo local** → Modificaciones en tema/plugins
2. **Staging deployment** → Pruebas en entorno staging
3. **Verificación** → Smoke tests, cache flush, validación de rutas
4. **Producción** (opcional) → Solo tras aprobación explícita

---

## 2. Variables y Credenciales

### Secretos de GitHub Actions

Todas las credenciales sensibles están almacenadas en **GitHub → Settings → Actions → Secrets and Variables → Actions**.

| Nombre del Secreto | Ubicación | Propósito | Rotación |
|-------------------|-----------|-----------|----------|
| `WP_SSH_HOST` | GitHub Secrets | Host SSH de IONOS | Cambiar si se migra servidor |
| `WP_SSH_USER` | GitHub Secrets | Usuario SSH (staging) | Contactar IONOS para cambiar |
| `WP_SSH_PASS` | GitHub Secrets | Contraseña SSH | Rotar cada 90 días vía panel IONOS |
| `WP_BASE_PATH` | GitHub Secrets | Ruta raíz staging | Solo si cambia estructura |
| `WP_URL_STAGING` | GitHub Secrets | URL staging | Actualizar si cambia dominio |
| `THEME_SLUG` | Variable local | Nombre del tema (`runart-base`) | Raramente cambia |

### Variables de Entorno (Locales)

Para ejecutar deployment local, exportar variables:

```bash
export WP_SSH_HOST="access958591985.webspace-data.io"
export WP_SSH_USER="u111876951"
export WP_SSH_PASS="[REDACTED]"  # Ver secretos de GitHub
export SSHPASS="$WP_SSH_PASS"
export WP_BASE_PATH="/homepages/7/d958591985/htdocs/staging"
export WP_URL_STAGING="https://staging.runartfoundry.com"
export THEME_SLUG="runart-base"
```

### Ubicaciones Críticas

**Servidor staging (IONOS):**
- Raíz WP: `/homepages/7/d958591985/htdocs/staging`
- Tema: `/homepages/7/d958591985/htdocs/staging/wp-content/themes/runart-base`
- Backups: `/tmp/runart-base_backup_[timestamp].tgz`
- Logs WP: `/homepages/7/d958591985/htdocs/staging/wp-content/debug.log`

**Repositorio local:**
- Tema: `wp-content/themes/runart-base/`
- Scripts: `tools/deploy_wp_ssh.sh`
- Reportes: `_reports/WP_SSH_DEPLOY*.md`
- Logs: `logs/deploy_*.log`

---

### Nota de Gobernanza del Tema (Staging)

- Canon documental y de scripts: tema activo esperado en Staging es **RunArt Base** (`runart-base`).
- Modo actual: solo lectura. No se ejecutan cambios en el servidor hasta aprobación explícita (READ_ONLY=1, DRY_RUN=1).
- Evidencia y paths canónicos: ver `_reports/IONOS_STAGING_THEME_CHECK_20251029.md`.

---

## 3. Método Oficial de Deployment

### 3.1. Preparación Local (WSL)

#### Paso 1: Validar tema completo

```bash
cd /path/to/runart-foundry

# Verificar archivos esenciales
ls -lh wp-content/themes/runart-base/{style.css,index.php,header.php,footer.php,functions.php}

# Contar archivos (debe ser ~18 PHP)
find wp-content/themes/runart-base -name "*.php" | wc -l

# Verificar CSS responsive en ubicación correcta
ls -lh wp-content/themes/runart-base/assets/css/responsive.overrides.css
```

**Checklist de archivos críticos:**
- ✅ `style.css` (con cabecera de tema)
- ✅ `index.php` (fallback obligatorio)
- ✅ `header.php`, `footer.php`
- ✅ `functions.php`
- ✅ `page.php`, `front-page.php`
- ✅ `assets/css/responsive.overrides.css`

#### Paso 2: Configurar variables de entorno

```bash
# Opción A: Exportar manualmente
export WP_SSH_HOST="access958591985.webspace-data.io"
export WP_SSH_USER="u111876951"
export WP_SSH_PASS="[SOLICITAR_A_ADMIN]"
export SSHPASS="$WP_SSH_PASS"
export WP_BASE_PATH="/homepages/7/d958591985/htdocs/staging"
export WP_URL_STAGING="https://staging.runartfoundry.com"
export THEME_SLUG="runart-base"

# Opción B: Cargar desde .env (NO versionar)
source .env.secrets
```

### 3.2. Subida a Servidor (IONOS)

#### Paso 3: Ejecutar script de deployment

```bash
cd /path/to/runart-foundry

# Deployment a staging (recomendado)
./tools/deploy_wp_ssh.sh staging

# Deployment a producción (solo tras validación)
./tools/deploy_wp_ssh.sh prod
```

**Qué hace el script:**
1. ✅ Valida conectividad SSH
2. ✅ Verifica WordPress instalado
3. ✅ Crea backup del tema actual → `/tmp/runart-base_backup_[timestamp].tgz`
4. ✅ Sincroniza archivos vía rsync (sin `--delete`)
5. ✅ Ejecuta `wp rewrite flush`
6. ✅ Ejecuta `wp cache flush`
7. ✅ Publica páginas requeridas (si están en draft)
8. ✅ Ejecuta smoke tests en 12 rutas
9. ✅ Genera reportes en `_reports/`

### 3.3. Backup Automático

**Ubicación:** `/tmp/runart-base_backup_[timestamp].tgz`

**Formato del timestamp:** `20251029T143535Z` (UTC)

**Contenido del backup:**
- Todo el directorio del tema (PHP, CSS, JS, assets)
- Archivos de configuración (acf-json, languages)
- Archivos .bak y respaldos previos

#### Restaurar desde backup

```bash
# Conectar al servidor
ssh u111876951@access958591985.webspace-data.io

# Listar backups disponibles
ls -lht /tmp/runart-base_backup_*.tgz | head -n 5

# Restaurar backup específico
cd /homepages/7/d958591985/htdocs/staging/wp-content/themes
mv runart-base runart-base.failed_$(date +%Y%m%d_%H%M%S)
tar -xzf /tmp/runart-base_backup_20251029T143535Z.tgz

# Limpiar cache
cd /homepages/7/d958591985/htdocs/staging
wp cache flush --allow-root
wp rewrite flush --allow-root
```

### 3.4. Sincronización y Validación

**Filtros de rsync (definidos en script):**

```bash
# Incluidos por defecto
SYNC_INCLUDE="assets/**,templates/**,*.php,*.css"

# Excluidos por defecto
SYNC_EXCLUDE=".git,node_modules,*.map,_artifacts,_reports"
```

**⚠️ IMPORTANTE:** El rsync **NO usa `--delete`**, por lo que:
- ✅ No borrará archivos remotos que no existan localmente
- ✅ Solo actualiza archivos existentes o agrega nuevos
- ⚠️ Archivos huérfanos remotos no se eliminan automáticamente

**Comando rsync real:**

```bash
rsync -av \
  --rsync-path="mkdir -p [remote_dir] && rsync" \
  --rsh="ssh -o StrictHostKeyChecking=no" \
  --filter="merge [exclude_file]" \
  --filter="merge [include_file]" \
  wp-content/themes/runart-base/ \
  user@host:/path/to/staging/wp-content/themes/runart-base/
```

### 3.5. Verificación Post-Deploy

#### Cache flush (obligatorio)

```bash
ssh user@host "cd /path/staging && wp cache flush --allow-root"
ssh user@host "cd /path/staging && wp rewrite flush --allow-root"
```

#### Smoke tests (12 rutas)

El script ejecuta smoke tests automáticamente:

| Idioma | Ruta | Expectativa |
|--------|------|-------------|
| EN | `/en/home/` | HTTP 200, H1 detectado |
| EN | `/en/about/` | HTTP 200, H1 detectado |
| EN | `/en/services/` | HTTP 200, H1 detectado |
| EN | `/en/projects/` | HTTP 200, H1 detectado |
| EN | `/en/contact/` | HTTP 200, H1 detectado |
| EN | `/en/blog/` | HTTP 200, H1 detectado |
| ES | `/es/inicio/` | HTTP 200, H1 detectado |
| ES | `/es/sobre-nosotros/` | HTTP 200, H1 detectado |
| ES | `/es/servicios/` | HTTP 200, H1 detectado |
| ES | `/es/projects/` | HTTP 200, H1 detectado |
| ES | `/es/contacto/` | HTTP 200, H1 detectado |
| ES | `/es/blog-2/` | HTTP 200, H1 detectado |

**Verificación manual adicional:**

```bash
# Verificar CSS responsive carga
curl -I https://staging.runartfoundry.com/wp-content/themes/runart-base/assets/css/responsive.overrides.css
# Esperado: HTTP/2 200, Content-Type: text/css

# Verificar tamaño HTML no vacío
curl -s https://staging.runartfoundry.com/es/inicio/ | wc -c
# Esperado: > 20000 bytes

# Verificar H1 presente
curl -s https://staging.runartfoundry.com/es/inicio/ | grep -oP '<h1[^>]*>\K[^<]+'
# Esperado: "R.U.N. Art Foundry — Excelencia en Fundición Artística"
```

### 3.6. Rollback

#### Rollback rápido (tema únicamente)

```bash
# 1. Conectar al servidor
ssh u111876951@access958591985.webspace-data.io

# 2. Identificar backup previo al problema
ls -lht /tmp/runart-base_backup_*.tgz | head -n 5

# 3. Respaldar tema actual (por si acaso)
cd /homepages/7/d958591985/htdocs/staging/wp-content/themes
tar -czf /tmp/runart-base_before_rollback_$(date +%Y%m%d_%H%M%S).tgz runart-base

# 4. Restaurar backup
rm -rf runart-base
tar -xzf /tmp/runart-base_backup_20251029T143535Z.tgz

# 5. Limpiar cache
cd /homepages/7/d958591985/htdocs/staging
wp cache flush --allow-root
wp rewrite flush --allow-root

# 6. Verificar
wp theme status runart-base --allow-root
```

#### Rollback completo (WordPress + DB)

⚠️ **Solo en caso de desastre total. Requiere backup de base de datos.**

```bash
# 1. Restaurar DB desde backup
# (Contactar IONOS o usar phpMyAdmin)

# 2. Restaurar archivos WordPress
ssh user@host "cd /homepages/7/d958591985/htdocs/staging && tar -xzf /backup/wordpress_full_[date].tgz"

# 3. Verificar wp-config.php
# 4. Cache flush
# 5. Probar rutas principales
```

---

## 4. Problemas Detectados y Cómo Evitarlos

### 4.1. 🔴 WSOD (White Screen of Death) — Página Completamente Vacía

**Síntomas:**
- HTML responde 0 bytes
- Sin errores visibles en navegador
- `/wp-json` puede o no funcionar

**Causas:**
1. **Tema sin `style.css`:** WordPress no reconoce el tema
2. **Faltan plantillas esenciales:** `index.php`, `header.php`, `footer.php`
3. **Fatal error en PHP:** Revisión en `debug.log`
4. **Archivo `.maintenance` presente:** WordPress en modo mantenimiento

**Solución:**

```bash
# 1. Verificar existencia de style.css con cabecera
ssh user@host "cat /path/tema/style.css | head -n 10"
# Debe contener:
# /*
# Theme Name: RunArt Base
# */

# 2. Verificar plantillas críticas
ssh user@host "ls -lh /path/tema/{index.php,header.php,footer.php}"

# 3. Habilitar debug
ssh user@host "cd /path/staging && wp config set WP_DEBUG true --allow-root"
ssh user@host "cd /path/staging && wp config set WP_DEBUG_LOG true --allow-root"

# 4. Reproducir error y revisar log
ssh user@host "tail -n 50 /path/staging/wp-content/debug.log"

# 5. Eliminar .maintenance si existe
ssh user@host "rm -f /path/staging/.maintenance"
```

**Prevención:**
- ✅ Nunca sincronizar tema incompleto
- ✅ Validar archivos locales antes de rsync
- ✅ Mantener backup previo a cualquier cambio

### 4.2. 🟡 CSS Responsive No Carga (404)

**Síntomas:**
- HTML carga correctamente
- En `<head>` aparece enlace a `responsive.overrides.css`
- Al acceder a la URL del CSS: HTTP 404

**Causa:**
- Archivo CSS en ubicación incorrecta (raíz del tema en lugar de `assets/css/`)

**Solución:**

```bash
# 1. Verificar ubicación actual
ssh user@host "find /path/tema -name 'responsive.overrides.css'"

# 2. Mover a ubicación correcta
ssh user@host "mv /path/tema/responsive.overrides.css /path/tema/assets/css/"

# 3. Verificar que functions.php encola desde assets/css/
grep "responsive.overrides.css" wp-content/themes/runart-base/functions.php
# Debe contener: get_template_directory_uri() . '/assets/css/responsive.overrides.css'

# 4. Cache flush
ssh user@host "cd /path/staging && wp cache flush --allow-root"

# 5. Verificar carga
curl -I https://staging.runartfoundry.com/wp-content/themes/runart-base/assets/css/responsive.overrides.css
```

**Prevención:**
- ✅ Mantener estructura: `assets/css/` para todos los CSS
- ✅ Validar rutas en `functions.php` coinciden con archivos

### 4.3. 🟡 Rsync Elimina Archivos del Servidor

**Síntomas:**
- Tras deployment, archivos remotos desaparecen
- Tema queda incompleto

**Causa:**
- Uso de rsync con flag `--delete`
- Tema local incompleto sincronizado con `--delete`

**Solución:**

```bash
# 1. Verificar que el script NO usa --delete
grep "rsync" tools/deploy_wp_ssh.sh | grep -v "delete"

# 2. Si se usó --delete por error, restaurar backup
ssh user@host "cd /path/themes && rm -rf runart-base && tar -xzf /tmp/runart-base_backup_[timestamp].tgz"

# 3. Cache flush
ssh user@host "cd /path/staging && wp cache flush --allow-root"
```

**Prevención:**
- ✅ **NUNCA usar `--delete` en rsync**
- ✅ Validar tema local completo antes de sincronizar
- ✅ Siempre crear backup antes de rsync

### 4.4. 🟡 Páginas en Estado "Draft" No Aparecen

**Síntomas:**
- Smoke test muestra HTTP 404 en algunas rutas
- Página existe en admin pero no en frontend

**Causa:**
- Páginas creadas pero nunca publicadas (estado `draft` o `pending`)

**Solución:**

```bash
# 1. Listar páginas y estado
ssh user@host "cd /path/staging && wp post list --post_type=page --fields=ID,post_title,post_status,post_name --allow-root"

# 2. Publicar página específica
ssh user@host "cd /path/staging && wp post update [ID] --post_status=publish --allow-root"

# 3. Verificar URL
curl -I https://staging.runartfoundry.com/[slug]/
```

**Prevención:**
- ✅ Script `deploy_wp_ssh.sh` ya intenta publicar rutas críticas
- ✅ Revisar lista de páginas antes de smoke test

### 4.5. 🟡 Cache No Se Limpia

**Síntomas:**
- Cambios en CSS/PHP no se reflejan en frontend
- HTML muestra versión antigua

**Causa:**
- Cache de WordPress activo
- Cache de plugins (WP Super Cache, W3 Total Cache)
- Cache de servidor (Varnish, NGINX)

**Solución:**

```bash
# 1. Flush cache WordPress
ssh user@host "cd /path/staging && wp cache flush --allow-root"

# 2. Flush rewrite rules
ssh user@host "cd /path/staging && wp rewrite flush --allow-root"

# 3. Desactivar plugins de cache (temporal)
ssh user@host "cd /path/staging && wp plugin deactivate wp-super-cache --allow-root"

# 4. Verificar con parámetro nocache
curl -I "https://staging.runartfoundry.com/es/inicio/?nocache=$(date +%s)"
```

**Prevención:**
- ✅ Siempre ejecutar `wp cache flush` post-deployment
- ✅ Considerar deshabilitar cache en staging

### 4.6. 🔴 Pérdida de Conexión SSH Durante Deployment

**Síntomas:**
- Rsync se interrumpe
- Deployment queda a medias

**Causa:**
- Timeout de conexión SSH
- Políticas de firewall IONOS
- Contraseña SSH expirada

**Solución:**

```bash
# 1. Verificar conectividad básica
ssh -o ConnectTimeout=10 u111876951@access958591985.webspace-data.io "echo 'SSH OK'"

# 2. Aumentar timeout en rsync
rsync -av --timeout=300 ...

# 3. Usar KeepAlive
ssh -o ServerAliveInterval=60 -o ServerAliveCountMax=3 ...

# 4. Restaurar desde backup si deployment se interrumpió
ssh user@host "cd /path/themes && tar -xzf /tmp/runart-base_backup_[timestamp].tgz"
```

**Prevención:**
- ✅ Verificar SSH antes de deployment
- ✅ Ejecutar deployment en red estable
- ✅ No ejecutar múltiples deployments en paralelo

### 4.7. 🟡 Sobrescritura Parcial por Filtros Rsync

**Síntomas:**
- Algunos archivos no se sincronizan
- Subdirectorios faltantes

**Causa:**
- Filtros de rsync demasiado restrictivos
- Patterns mal configurados

**Solución:**

```bash
# 1. Revisar filtros actuales
grep "SYNC_INCLUDE\|SYNC_EXCLUDE" tools/deploy_wp_ssh.sh

# 2. Ajustar si es necesario
SYNC_INCLUDE="assets/**,templates/**,*.php,*.css,inc/**,languages/**"

# 3. Reejecutar deployment
./tools/deploy_wp_ssh.sh staging
```

**Prevención:**
- ✅ Incluir patrones para subdirectorios: `inc/**`, `languages/**`
- ✅ Probar rsync con `--dry-run` antes de ejecutar

### 4.8. 🔴 Deploy Sin Backup Previo

**Síntomas:**
- Deployment falla
- No hay forma de revertir

**Causa:**
- Script ejecutado con flag `--no-backup` (si existiera)
- Backup automático falló silenciosamente

**Solución:**

```bash
# 1. Verificar backups disponibles
ssh user@host "ls -lht /tmp/runart-base_backup_*.tgz | head -n 5"

# 2. Si no hay backups, buscar en respaldos del tema
ssh user@host "find /path/themes -name 'runart-base.broken_*' -o -name '*.backup'"

# 3. En caso extremo, restaurar desde repositorio Git
cd /path/to/repo
git log --oneline -n 10  # Buscar commit estable
# Sincronizar ese commit manualmente
```

**Prevención:**
- ✅ **Siempre verificar que el backup se creó** antes de continuar
- ✅ Conservar últimos 5 backups en `/tmp/`
- ✅ Hacer backup manual adicional antes de cambios críticos

### 4.9. ⚪ Cloudflare Residual Genera Conflictos

**Síntomas:**
- Errores relacionados con tokens CF
- Logs mencionan Pages/Functions

**Causa:**
- Configuración antigua de Cloudflare aún presente

**Solución:**

```bash
# 1. Ignorar errores de Cloudflare
# 2. NO usar jobs de deployment relacionados con CF
# 3. Enfocarse en WordPress + WP-CLI

# 4. Si persiste, limpiar configuración CF (solo si es necesario)
# Contactar admin o eliminar archivos .cloudflare/ del repo
```

**Prevención:**
- ✅ Cloudflare está desactivado → no mezclar flujos
- ✅ Usar solo `deploy_wp_ssh.sh` para WordPress

---

## 5. Buenas Prácticas

### 5.1. Seguridad

- ✅ **Nunca exponer contraseñas en comandos ni logs**
  ```bash
  # MAL
  ssh user:password@host "..."
  
  # BIEN
  export SSHPASS="$WP_SSH_PASS"
  sshpass -e ssh user@host "..."
  ```

- ✅ **Rotar credenciales cada 90 días**
  - Cambiar `WP_SSH_PASS` en panel IONOS
  - Actualizar secreto en GitHub Actions

- ✅ **Usar Application Password para API REST**
  - No usar contraseña principal de WordPress
  - Revocar passwords no utilizados

- ✅ **Restringir accesos SSH**
  - Solo usuarios autorizados
  - Considerar claves SSH en lugar de passwords

### 5.2. Backups

- ✅ **Mantener copias locales y remotas**
  ```bash
  # Descargar backup remoto a local
  scp user@host:/tmp/runart-base_backup_[timestamp].tgz ~/backups/
  ```

- ✅ **Conservar últimos 3 releases o backups**
  ```bash
  # Limpiar backups antiguos (conservar 5 más recientes)
  ssh user@host "cd /tmp && ls -t runart-base_backup_*.tgz | tail -n +6 | xargs rm -f"
  ```

- ✅ **Backup de base de datos antes de cambios estructurales**
  ```bash
  ssh user@host "cd /path/staging && wp db export /tmp/db_backup_$(date +%Y%m%d_%H%M%S).sql --allow-root"
  ```

### 5.3. Testing

- ✅ **Probar primero en staging, nunca directo a producción**
  ```bash
  # SIEMPRE
  ./tools/deploy_wp_ssh.sh staging
  # Validar smoke tests
  # Validar manualmente rutas críticas
  
  # SOLO SI TODO OK
  ./tools/deploy_wp_ssh.sh prod
  ```

- ✅ **Ejecutar smoke tests tras cada deployment**
  - Verificar 12 rutas principales (EN/ES)
  - Confirmar H1 detectados
  - Validar tamaño HTML > 20KB

- ✅ **Validar CSS responsive carga**
  ```bash
  curl -I https://staging.runartfoundry.com/wp-content/themes/runart-base/assets/css/responsive.overrides.css
  ```

### 5.4. Documentación

- ✅ **Documentar cada deployment en logs**
  - Script genera automáticamente: `_reports/WP_SSH_DEPLOY_LOG.json`
  - Revisar logs tras deployment

- ✅ **Mantener changelog actualizado**
  - Anotar cambios realizados en tema/plugins
  - Referenciar commits de Git

- ✅ **Reportar incidencias en `_reports/`**
  - Crear archivo markdown con timestamp
  - Incluir causa, solución, prevención

### 5.5. Versionado

- ✅ **Hacer commit antes de deployment**
  ```bash
  git add wp-content/themes/runart-base
  git commit -m "feat(theme): Add responsive overrides CSS"
  git push origin main
  ```

- ✅ **Crear tags para releases importantes**
  ```bash
  git tag -a v1.1.0 -m "Release 1.1.0 - Responsive CSS"
  git push origin v1.1.0
  ```

- ✅ **Referenciar commits en reportes de deployment**

---

## 6. Procedimiento de Verificación Rápida (Checklist)

### Pre-Deployment

| ✓ | Paso | Acción | Resultado Esperado |
|---|------|--------|--------------------|
| ☐ | 1 | Validar tema local completo | 18 archivos PHP presentes |
| ☐ | 2 | Verificar CSS responsive en `assets/css/` | Archivo existe con 3KB |
| ☐ | 3 | Commit cambios a Git | Commit exitoso, push OK |
| ☐ | 4 | Exportar variables de entorno | Todas las variables definidas |
| ☐ | 5 | Verificar conectividad SSH | `ssh user@host "echo OK"` |

### Durante Deployment

| ✓ | Paso | Acción | Resultado Esperado |
|---|------|--------|--------------------|
| ☐ | 6 | Backup creado | Archivo `.tgz` en `/tmp/` |
| ☐ | 7 | Rsync ejecutado | Sin errores, archivos sincronizados |
| ☐ | 8 | Rewrite flush | `Success: Rewrite rules flushed.` |
| ☐ | 9 | Cache flush | `Success: The cache was flushed.` |
| ☐ | 10 | Smoke tests iniciados | Script ejecuta curl en 12 rutas |

### Post-Deployment

| ✓ | Paso | Acción | Resultado Esperado |
|---|------|--------|--------------------|
| ☐ | 11 | HTTP 200 en rutas principales | 12/12 rutas responden 200 |
| ☐ | 12 | H1 detectados | 12/12 rutas con H1 válido |
| ☐ | 13 | CSS responsive carga | HTTP 200, Content-Type: text/css |
| ☐ | 14 | Tamaño HTML correcto | > 20KB en páginas principales |
| ☐ | 15 | Backup restaurable | Verificar integridad `.tgz` |
| ☐ | 16 | Logs generados | Archivos en `_reports/` creados |

### Verificación Manual Adicional

```bash
# 1. Verificar tema activo
ssh user@host "cd /path/staging && wp theme status runart-base --allow-root"
# Esperado: Status: Active

# 2. Verificar páginas publicadas
ssh user@host "cd /path/staging && wp post list --post_type=page --post_status=publish --format=count --allow-root"
# Esperado: >= 12

# 3. Verificar plugins activos
ssh user@host "cd /path/staging && wp plugin list --status=active --format=count --allow-root"
# Esperado: 5 (ACF, CF7, Polylang, RankMath, Bridge)

# 4. Verificar versión WordPress
ssh user@host "cd /path/staging && wp core version --allow-root"
# Esperado: 6.8.3

# 5. Verificar PHP
ssh user@host "cd /path/staging && wp eval 'echo phpversion();' --allow-root"
# Esperado: 8.0.30
```

---

## 7. Contactos y Mantenimiento

### Responsable Técnico

- **Nombre:** Equipo Técnico RunArt Foundry
- **Email:** [Contactar via GitHub Issues]
- **GitHub:** https://github.com/ppkapiro/runart-foundry

### Ubicación de Logs y Bitácoras

**Repositorio local:**
- Logs de deployment: `logs/deploy_v*.log`
- Reportes de deployment: `_reports/WP_SSH_DEPLOY*.md`
- Reportes de smoke tests: `_reports/SMOKE_STAGING.md`
- Checklist de entorno: `_reports/WP_ENV_CHECKLIST.md`

**Servidor remoto:**
- Backups de tema: `/tmp/runart-base_backup_*.tgz`
- Logs de WordPress: `/homepages/7/d958591985/htdocs/staging/wp-content/debug.log`
- Logs de servidor: `/homepages/7/d958591985/htdocs/staging/error_log`

### Frecuencia de Revisión

- **Mensual:** Revisar backups disponibles, limpiar antiguos
- **Trimestral:** Rotar credenciales SSH y Application Passwords
- **Antes de cada release:** Ejecutar checklist completo
- **Post-incidente:** Actualizar sección de problemas detectados

### Recursos Adicionales

- **Script de deployment:** `tools/deploy_wp_ssh.sh`
- **Documentación IONOS:** [Panel de control](https://www.ionos.es/hosting)
- **WP-CLI Handbook:** https://make.wordpress.org/cli/handbook/
- **Rsync Manual:** `man rsync`

### Actualizaciones de Este Documento

| Versión | Fecha | Cambios |
|---------|-------|---------|
| 1.0 | 2025-10-29 | Creación inicial tras deployment exitoso |
| 1.1 | 2025-10-29 | Agregada sección v0.3.1.1 — Fix Language Switcher |

---

## 8. Deployments Específicos — Casos Reales

### 8.1. v0.3.1.1 — Fix Responsive Header (Language Switcher)

**Fecha:** 2025-10-29  
**Tipo:** Hotfix CSS  
**Archivos modificados:** `responsive.overrides.css`, `functions.php`

#### Qué se cambió

~90 líneas agregadas en `responsive.overrides.css` para contener el language switcher dentro del header y corregir overflow horizontal en móvil/desktop.

**Selectores tocados:**
- `.site-lang-switcher` — Contenedor principal (inline-flex, max-width, overflow:hidden)
- `.site-lang-switcher > li, .site-lang-switcher li` — Items sin wrapper `<ul>`
- `.site-lang-switcher a` — Enlaces con tap targets ≥40px
- `.site-lang-switcher a img` — Íconos con tamaño fluido (`clamp()` + `aspect-ratio`)
- Media queries: `@media (hover: none)`, `@media (max-width: 430px)`, `@media (max-width: 380px)`

#### Por qué era necesario

**Problema:** El language switcher (banderas EN/ES) se salía del contenedor del header en Chrome móvil y desktop, generando scroll horizontal. Los íconos tenían tamaño fijo (24px) y los tap targets eran <40px.

**Impacto:** UX degradada en móviles; incumplimiento WCAG 2.1 AA (tap targets); CLS potencial por saltos en hover.

#### Criterios de aceptación

- ✅ Sin overflow horizontal en viewports 320–430px y desktop
- ✅ Tap targets ≥ 40px (36px mínimo en móvil extremo)
- ✅ Sticky del header estable (sin romper anclas con `scroll-margin-top`)
- ✅ Sin saltos de layout en hover móvil (transform desactivado con media query)
- ✅ Íconos responsivos con `aspect-ratio: 16/11`

#### Checklist de deployment para este fix

**Pre-deployment:**
1. ☐ Confirmar ruta correcta del CSS: `wp-content/themes/runart-base/assets/css/responsive.overrides.css`
2. ☐ Verificar que NO existan duplicados en raíz del tema: `ls -lh wp-content/themes/runart-base/responsive.overrides.css` → debe fallar
3. ☐ Version bump en `functions.php`: cambiar versión de `0.3.1` a `0.3.1.1` en el enqueue del CSS responsive

**Durante deployment:**
4. ☐ Rsync del tema (solo archivos modificados, sin `--delete`)
   ```bash
   rsync -av wp-content/themes/runart-base/assets/css/responsive.overrides.css user@host:/path/staging/wp-content/themes/runart-base/assets/css/
   rsync -av wp-content/themes/runart-base/functions.php user@host:/path/staging/wp-content/themes/runart-base/
   ```
5. ☐ Cache flush + rewrite flush
   ```bash
   wp cache flush --allow-root
   wp rewrite flush --allow-root
   wp transient delete --all --allow-root
   ```

**Post-deployment:**
6. ☐ Verificar 6 URLs principales (EN/ES):
   - `/en/home/`, `/en/services/`, `/en/blog/`
   - `/es/inicio/`, `/es/servicios/`, `/es/blog-2/`
   - Todos deben responder HTTP 200 con H1 detectado
7. ☐ Confirmar CSS cargado:
   ```bash
   curl -s https://staging.runartfoundry.com/wp-content/themes/runart-base/assets/css/responsive.overrides.css | grep "v0.3.1.1"
   ```
8. ☐ Validar reglas aplicadas:
   ```bash
   curl -s https://staging.runartfoundry.com/.../responsive.overrides.css | grep "max-width.*clamp.*12vw"
   ```
9. ☐ Guardar capturas (opcional pero recomendado):
   - Viewports: 360, 390, 414, 1280
   - Guardar en `_artifacts/screenshots_uiux_[YYYYMMDD]/lang-switcher_fix/`

#### Pitfalls aprendidos (CRÍTICOS)

##### 1. **Archivo duplicado en raíz del tema**
**Síntoma:** El CSS responsive no se aplica a pesar de estar actualizado en `assets/css/`.  
**Causa:** Existe un archivo `responsive.overrides.css` en la raíz del tema (`wp-content/themes/runart-base/responsive.overrides.css`) que WordPress carga primero.  
**Solución:**
```bash
# Verificar duplicados
ssh user@host "find /path/staging/wp-content/themes/runart-base -name 'responsive.overrides.css'"
# Si aparecen 2 archivos, eliminar el de la raíz:
ssh user@host "rm -f /path/staging/wp-content/themes/runart-base/responsive.overrides.css"
```
**Prevención:** Siempre verificar que el CSS esté SOLO en `assets/css/` antes de deployment.

##### 2. **Sin version bump en enqueue**
**Síntoma:** Navegadores sirven CSS viejo desde cache.  
**Causa:** La versión en `wp_enqueue_style` no cambió (`0.3.1` → `0.3.1.1`).  
**Solución:** Actualizar versión en `functions.php` línea 73:
```php
wp_enqueue_style(
    'runart-responsive-overrides',
    get_template_directory_uri() . '/assets/css/responsive.overrides.css',
    array('runart-base-style'),
    '0.3.1.1'  // ← Cambiar aquí
);
```
**Prevención:** Siempre incrementar versión al modificar CSS/JS; WordPress agregará `?ver=0.3.1.1` automáticamente.

##### 3. **Hover en móvil causa saltos de layout**
**Síntoma:** En dispositivos táctiles, tocar una bandera hace que el header "salte".  
**Causa:** La regla `:hover` con `transform: scale()` sigue activa en móvil.  
**Solución:** Desactivar transforms en coarse pointers:
```css
@media (hover: none) and (pointer: coarse) {
  .site-lang-switcher a:hover {
    transform: none;
    filter: none;
  }
}
```
**Prevención:** Siempre usar media queries `(hover: none)` para desactivar efectos hover en móvil.

##### 4. **Íconos sin aspect-ratio y ancho fijo**
**Síntoma:** Banderas se deforman o rompen layout en viewports extremos.  
**Causa:** `width: 24px` fijo sin `height` ni `aspect-ratio`.  
**Solución:** Usar tamaños fluidos con proporción:
```css
.site-lang-switcher a img {
  width: clamp(18px, 2.4vw, 22px) !important;
  height: clamp(13px, 1.8vw, 16px) !important;
  aspect-ratio: 16 / 11;
  object-fit: cover;
}
```
**Prevención:** Siempre definir `aspect-ratio` para imágenes responsivas.

##### 5. **Cache de WordPress no purgado completamente**
**Síntoma:** Cambios CSS no se ven a pesar de version bump.  
**Causa:** Cache de objetos o transients obsoletos.  
**Solución:** Purga agresiva:
```bash
wp cache flush --allow-root
wp transient delete --all --allow-root
# Si hay plugin de cache:
wp cache-enabler clear --allow-root  # o equivalente
```
**Prevención:** Siempre ejecutar flush de transients tras cambios en enqueues.

#### Rollback rápido

Si el fix causa problemas:

```bash
# 1. Restaurar backup del tema (si existe)
ssh user@host "cd /path/staging/wp-content/themes && rm -rf runart-base && tar -xzf /tmp/runart-base_backup_[timestamp].tgz"

# 2. O revertir solo el CSS responsive
# Copiar versión anterior desde backup local o Git
git show HEAD~1:wp-content/themes/runart-base/assets/css/responsive.overrides.css > responsive.overrides.css.old
rsync -av responsive.overrides.css.old user@host:/path/staging/wp-content/themes/runart-base/assets/css/responsive.overrides.css

# 3. Revertir version bump en functions.php
# Cambiar '0.3.1.1' de vuelta a '0.3.1'

# 4. Cache flush
ssh user@host "cd /path/staging && wp cache flush --allow-root"

# 5. Verificar rollback exitoso
curl -I https://staging.runartfoundry.com/es/inicio/
```

#### Logs y evidencias

- **Deployment log:** `_reports/WP_SSH_DEPLOY_LOG.json` (entrada timestamped)
- **Smoke test:** `_reports/SMOKE_STAGING.md` (6 URLs validadas)
- **Capturas:** `_artifacts/screenshots_uiux_20251029/lang-switcher_fix/`
- **Metadata CSS:** Tamaño 5244 bytes, fecha 2025-10-29 11:44 UTC

---

## 8.2. v0.3.1.2 — Chrome Overflow Fix (fit-content → flex)

### Síntoma

En **Chrome** (móvil y desktop), el language switcher causaba **scroll horizontal** (overflow-x) en el header, con banderas parcialmente ocultas. En **Edge/Firefox** el problema no ocurría.

**Evidencia:**
- Viewport 360px: `.site-header .container` tenía `offsetWidth: 384px` (excede viewport en +24px)
- Viewport 1280px: overflow de 4px en `body`, `.site-header`, `.site-header .container`
- Capturas pre-fix: `_artifacts/screenshots_uiux_20251029/chrome-audit-pre-fix/`

### Causas Raíz

#### 1. `min-width: fit-content` en flex item

**Ubicación:** `responsive.overrides.css` línea 85 (v0.3.1.1)

```css
.site-lang-switcher {
  min-width: fit-content;  /* ⚠️ Problema en Chrome */
  max-width: clamp(96px, 12vw, 140px);
}
```

**Por qué falla en Chrome:**
- En Chrome/Blink, `min-width: fit-content` dentro de un flex container causa que el navegador calcule el tamaño intrínseco del contenido **antes** de aplicar `overflow: hidden`.
- Chrome interpreta `fit-content` como "nunca comprimir debajo del tamaño intrínseco" → expande el container.
- Edge/Firefox aplican heurística adicional en contextos flex: "shrink si overflow está presente" → comprimen automáticamente.

#### 2. `.site-header .container` sin límites estrictos

El flex container no tenía `box-sizing: border-box` ni `inline-size: 100%` explícito, permitiendo que los flex items sumaran más del viewport.

#### 3. `.site-nav` sin límite de ancho en móvil

En viewports ≤430px, el menú horizontal con `overflow-x: auto` no tenía `max-inline-size`, causando que su scroll interno se propagara al container padre.

### Fix Aplicado (v0.3.1.2)

#### A. Reemplazar `fit-content` con `flex: 0 0 auto`

```css
.site-lang-switcher {
  /* Chrome fix: flex:0 0 auto en vez de min-width:fit-content */
  flex: 0 0 auto;  /* No grow, no shrink, auto basis */
  max-inline-size: 9rem; /* ≈ 144px — Chrome-safe con unidades lógicas */
  overflow: clip;
  white-space: nowrap;
}

/* Fallback para navegadores sin soporte de overflow:clip */
@supports not (overflow: clip) {
  .site-lang-switcher {
    overflow: hidden;
  }
}
```

**Justificación:**
- `flex: 0 0 auto` es consistente en todos los navegadores (Blink, WebKit, Gecko).
- `overflow: clip` es más estable que `overflow: hidden` (evita crear contexto de apilamiento).
- Unidades lógicas (`max-inline-size` en vez de `max-width`) mejoran compatibilidad con modos de escritura RTL.

#### B. Estabilizar `.site-header .container`

```css
.site-header .container {
  inline-size: 100%;
  max-inline-size: var(--container-max, 1400px);
  box-sizing: border-box;
}
```

**Justificación:**
- `inline-size: 100%` (nunca `100vw`) evita incluir scrollbar en el cálculo de ancho.
- `box-sizing: border-box` asegura que padding no se sume al ancho total.

#### C. Limitar `.site-nav` en móvil

```css
@media (max-width: 430px) {
  .site-nav {
    max-inline-size: calc(100vw - 10rem);
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
  }
}

@media (max-width: 380px) {
  .site-nav {
    max-inline-size: calc(100vw - 9rem);
  }
}
```

**Justificación:**
- Limita scroll interno del nav sin afectar container padre.
- `100vw - 10rem` reserva espacio para branding + switcher + gaps.

#### D. Íconos de banderas: aspect-ratio 1:1

```css
.site-lang-switcher img {
  inline-size: clamp(18px, 2.2vw, 22px) !important;
  block-size: clamp(18px, 2.2vw, 22px) !important;
  aspect-ratio: 1 / 1; /* Cuadrado estable cross-UA */
}
```

**Justificación:**
- `aspect-ratio: 1/1` (antes 16/11) evita deformación entre navegadores.
- Unidades lógicas (`inline-size`, `block-size`) mejoran RTL support.

### Checklist de Deployment v0.3.1.2

**Pre-deployment:**
- [x] Auditoría Chrome completada (Puppeteer/Headless): `tools/chrome_overflow_audit.js`
- [x] Reporte diagnóstico generado: `_reports/CHROME_OVERFLOW_AUDIT.md`
- [x] Capturas pre-fix guardadas: `_artifacts/screenshots_uiux_20251029/chrome-audit-pre-fix/`
- [x] Backup local del CSS v0.3.1.1 (Git: `git show HEAD:...`)

**Durante deployment:**
- [x] Modificar `responsive.overrides.css` (eliminar `min-width: fit-content`, añadir reglas A-D)
- [x] Version bump en `functions.php`: `'0.3.1.1'` → `'0.3.1.2'`
- [x] Rsync archivos: `responsive.overrides.css`, `functions.php`
- [x] SSH + WP-CLI: `wp cache flush && wp transient delete --all && wp rewrite flush --hard`

**Post-deployment:**
- [x] Smoke test: 4 URLs (EN/ES home, services) → HTTP 200, CSS cargado
- [x] Verificar CSS servido: `curl .../responsive.overrides.css | head -6` → muestra v0.3.1.2
- [x] Re-auditoría Puppeteer: overflow eliminado en `.site-header`, `.site-header .container`
- [x] Desktop (1280px): ✅ Sin overflow en ningún selector
- [x] Móvil (360-414px): overflow residual solo en `body` y `.site-nav` (esperado, nav tiene scroll interno)

### Resultados de Validación

#### Pre-fix (v0.3.1.1)

| Viewport | Selector | offsetWidth | scrollWidth | hasOverflow |
|----------|----------|-------------|-------------|-------------|
| 360px | `.site-header` | 360px | **384px** | ✅ Sí |
| 360px | `.site-header .container` | **384px** | 384px | ✅ Sí |
| 1280px | `body` | 1280px | **1284px** | ✅ Sí |
| 1280px | `.site-header .container` | **1284px** | 1284px | ✅ Sí |

#### Post-fix (v0.3.1.2)

| Viewport | Selector | offsetWidth | scrollWidth | hasOverflow |
|----------|----------|-------------|-------------|-------------|
| 360px | `.site-header` | 360px | 360px | ❌ No |
| 360px | `.site-header .container` | 360px | 360px | ❌ No |
| 1280px | `body` | 1280px | 1280px | ❌ No |
| 1280px | `.site-header` | 1280px | 1280px | ❌ No |
| 1280px | `.site-header .container` | 1280px | 1280px | ❌ No |

**Mejora cuantificada:**
- Eliminado overflow de +24px en móvil 360px
- Eliminado overflow de +4px en desktop 1280px
- `.site-header` y `.site-header .container` ahora perfectamente contenidos en todos los viewports

**Overflow residual esperado:**
- `body` y `.site-nav` en móvil: scroll interno del menú horizontal (comportamiento correcto)

### Regla Práctica: Evitar `fit-content` en Flex Items

**❌ NO usar:**
```css
.flex-item {
  min-width: fit-content; /* Inconsistente en Chrome vs Edge */
}
```

**✅ SÍ usar:**
```css
.flex-item {
  flex: 0 0 auto; /* Consistente cross-browser */
  max-inline-size: 9rem; /* Límite con unidades lógicas */
}
```

**Cuándo es seguro `fit-content`:**
- En elementos **no-flex** (block, inline-block, grid items)
- Cuando se usa `width: fit-content` (no `min-width`) y hay límite con `max-width`

**Por qué falla en flex:**
- `min-width: fit-content` + `overflow: hidden` → Chrome ignora el overflow, Edge/Firefox lo respetan.
- Discrepancia en especificación CSS Flexbox (UA-dependent behavior).

### Pitfalls Específicos de Esta Versión

#### 1. Overflow residual en `.site-nav` (no es bug)

**Síntoma:** Puppeteer reporta overflow en `body` y `.site-nav` en móvil.

**Causa:** `.site-nav` tiene `overflow-x: auto` intencionalmente para scroll horizontal del menú.

**Solución:** No aplicar. Es comportamiento esperado. El fix de `max-inline-size` en `@media (max-width: 430px)` previene que el scroll del nav se propague al header.

#### 2. Cache de navegador resistente en Chrome

**Síntoma:** Tras deployment, Chrome mobile sigue mostrando overflow.

**Causa:** Hard cache de CSS (no respeta `Cache-Control`).

**Solución:**
```bash
# 1. Version bump obligatorio en functions.php
'0.3.1.1' → '0.3.1.2'

# 2. Hard refresh en Chrome
# Desktop: Ctrl+Shift+R
# Mobile: Settings → Privacy → Clear browsing data → Cached images

# 3. Validar con curl (bypass cache)
curl -s "https://staging.../responsive.overrides.css" | head -6
```

#### 3. Íconos de banderas se ven cuadrados (no rectangulares)

**Síntoma:** Tras aplicar `aspect-ratio: 1/1`, banderas pasan de 16:11 a 1:1.

**Causa:** Cambio intencional para estabilidad cross-UA.

**Solución:** No es bug. Si se requieren banderas rectangulares, usar `aspect-ratio: 16/11` pero agregar `object-fit: cover` y asegurar `max-inline-size` más generoso.

### Rollback Procedure

```bash
# 1. Restaurar CSS v0.3.1.1 desde Git
cd /home/pepe/work/runartfoundry
git show HEAD~1:wp-content/themes/runart-base/assets/css/responsive.overrides.css > responsive.overrides.css.v0.3.1.1
rsync -avz responsive.overrides.css.v0.3.1.1 user@host:/path/staging/wp-content/themes/runart-base/assets/css/responsive.overrides.css

# 2. Revertir version bump en functions.php
# Cambiar línea 73: '0.3.1.2' → '0.3.1.1'
rsync -avz wp-content/themes/runart-base/functions.php user@host:/path/staging/wp-content/themes/runart-base/

# 3. Cache flush
ssh user@host "cd /path/staging && wp cache flush && wp transient delete --all"

# 4. Verificar rollback
curl -s "https://staging.../responsive.overrides.css" | head -6
# Debe mostrar: "v0.3.1.1"
```

### Logs y Evidencias

- **Auditoría pre-fix:** `_reports/CHROME_OVERFLOW_AUDIT.md`
- **Capturas pre-fix:** `_artifacts/screenshots_uiux_20251029/chrome-audit-pre-fix/` (16 capturas)
- **Capturas post-fix:** Screenshots autogeneradas en re-auditoría JSON
- **Resultados JSON:** `_artifacts/chrome_overflow_audit_results.json` (mediciones post-fix)
- **Log post-fix:** `_artifacts/chrome_audit_post_fix.log`
- **Deployment log:** Entrada en `docs/Deployment_Log.md` (v0.3.1.2, 2025-10-29)
- **Metadata CSS:** Tamaño 6185 bytes, fecha 2025-10-29 12:23 UTC

---

## 8.3. v0.3.1.3 — Chrome Mobile Nav Overflow Encapsulation

Fecha: 2025-10-29
Tipo: Hotfix CSS (solo STAGING)
Archivos modificados: `wp-content/themes/runart-base/assets/css/responsive.overrides.css`, `wp-content/themes/runart-base/functions.php`

### Qué se cambió

Encapsular el scroll horizontal del menú `.site-nav` exclusivamente dentro del propio nav en Chrome móvil, eliminando el scroll lateral del `body`, manteniendo intacto el fix del language switcher (v0.3.1.2):

- `.site-header` y `.site-header .container`: `overflow-x: clip` (fallback `hidden`), `max-inline-size: 100%`, `inline-size: 100%` y `box-sizing: border-box` donde aplica; `contain: paint` e `isolation: isolate` para aislar el contexto de pintura.
- `html, body` (≤430px): `overscroll-behavior-inline: none`, `touch-action: pan-y pinch-zoom`, `overflow-x: hidden` para impedir pan-x a nivel de página en Chrome móvil.
- `.site-nav` (≤430px): `max-inline-size: calc(100% - 9rem)`; en ≤380px → `calc(100% - 8rem)`; `overflow-x: auto`, `-webkit-overflow-scrolling: touch`, `overscroll-behavior-inline: contain`, `contain: size layout paint`, `min-inline-size: 0`, `flex-shrink: 1`, `flex-grow: 0`, `touch-action: pan-x`.
- `.site-nav ul`: `inline-size: max-content`, `white-space: nowrap`, `display: flex`, sin padding/margin-inline para evitar anchuras fantasma.
- Contenedores globales: `.container, .wrap, .inner` → `inline-size: min(100%, var(--container-max))` + `box-sizing: border-box` para que el padding no dispare el `scrollWidth`.

### Criterios de aceptación

- A) Sin overflow horizontal en `.site-header` y `.site-header .container` en 360/390/414 y 1280 → ✅
- B) Scroll horizontal encapsulado en `.site-nav` sin propagación al `body` (verificación visual real en Chrome móvil) → ✅ auditor/DOM; 👀 verificación manual realizada
- C) Mantener tap targets del switcher ≥ 36px en móvil (≥ 40px desktop) → ✅ (heredado de v0.3.1.2)
- D) Reglas Chrome-safe: `overflow: clip` con fallback, unidades lógicas (`inline-size`), sin `100vw` en contenedores del header → ✅
- E) Evidencias y documentación actualizadas → ✅

### Checklist de deployment v0.3.1.3 (STAGING)

Pre-deployment:
1) Confirmar única ubicación del CSS: `wp-content/themes/runart-base/assets/css/responsive.overrides.css` (sin duplicados en raíz del tema)
2) Version bump en `functions.php`: `0.3.1.2` → `0.3.1.3`
3) Backup remoto del tema (tar.gz en `/tmp`)

Durante deployment:
4) Rsync selectivo sin `--delete`: solo `responsive.overrides.css` y `functions.php`
5) WP-CLI: `wp cache flush && wp transient delete --all && wp rewrite flush`

Post-deployment:
6) Verificar 10–12 URLs EN/ES (HTTP 200, H1 presente)
7) Confirmar cabecera CSS `v0.3.1.3` y query `?ver=0.3.1.3`
8) Ejecutar auditoría headless (Puppeteer) y guardar JSON/logs y capturas
9) Registrar evidencias en `_artifacts/` y actualizar `docs/Deployment_Log.md` y `_reports/CHROME_OVERFLOW_AUDIT.md`

### Resultados de validación (resumen)

- Móvil 360/390/414px: `html/body` sin overflow; `.site-header` y `.site-header .container` sin overflow; `.site-nav` con overflow interno (esperado).
- Desktop 1280px: sin overflow en `body/header/container/nav`.
- Artefactos: `_artifacts/chrome_overflow_audit_results.json` + capturas header.

### Pitfalls relevantes

- No usar `100dvw/100vw` para limitar el nav en contenedores con padding → usar `%` del contenedor.
- Asegurar `box-sizing: border-box` en contenedores con padding para evitar +N px de `scrollWidth`.
- Prevenir scroll chaining con `overscroll-behavior-inline: contain` y limitar `touch-action`.

### Rollback

1) Restaurar backup del tema o rsync del CSS previo (v0.3.1.2) y revertir versión en `functions.php`.
2) `wp cache flush && wp transient delete --all && wp rewrite flush`.
3) Verificar que el CSS servido vuelve a `v0.3.1.2`.

### Logs y evidencias

- JSON: `_artifacts/chrome_overflow_audit_results.json` (solo `.site-nav` con overflow en móvil, esperado)
- Reporte: `_reports/CHROME_OVERFLOW_AUDIT.md` (update v0.3.1.3)
- Capturas: `_artifacts/screenshots_uiux_20251029/`
- Deployment log: `docs/Deployment_Log.md` (entrada v0.3.1.3)

---

## 📚 Referencias Rápidas

### Comandos Esenciales

```bash
# Deployment completo
./tools/deploy_wp_ssh.sh staging

# Verificar tema remoto
ssh user@host "cd /path/staging && wp theme status runart-base --allow-root"

# Cache flush
ssh user@host "cd /path/staging && wp cache flush --allow-root"

# Listar backups
ssh user@host "ls -lht /tmp/runart-base_backup_*.tgz | head -n 5"

# Restaurar backup
ssh user@host "cd /path/themes && tar -xzf /tmp/runart-base_backup_[timestamp].tgz"

# Smoke test manual
curl -I https://staging.runartfoundry.com/es/inicio/
```

### URLs Críticas

- **Staging Home (ES):** https://staging.runartfoundry.com/es/inicio/
- **Staging Home (EN):** https://staging.runartfoundry.com/en/home/
- **WP Admin Staging:** https://staging.runartfoundry.com/wp-admin/
- **REST API:** https://staging.runartfoundry.com/wp-json/

---

**🎯 Este documento es la referencia oficial para cualquier operación de deployment en RunArt Foundry. Mantenerlo actualizado es responsabilidad del equipo técnico.**
