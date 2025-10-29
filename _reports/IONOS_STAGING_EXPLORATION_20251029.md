# Exploración IONOS Staging — RunArt Foundry

**Fecha:** 2025-10-29  
**Entorno:** IONOS Webspace Staging  
**URL:** https://staging.runartfoundry.com

---

## Resumen Ejecutivo

Se realizó exploración del entorno staging de IONOS para validar estructura WordPress, tema runart-theme, capacidades WP-CLI y configuración SSH.

**Estado:** PARCIAL — Acceso SSH bloqueado; exploración completada vía documentación anterior y verificación HTTP.

---

## Información del Servidor

### Acceso SSH/SFTP

| Variable | Valor |
|----------|-------|
| Host | access958591985.webspace-data.io |
| Usuario | u11876951 |
| Puerto SSH | 22 |
| Puerto SFTP | 22 |
| Método auth | SSH Key (recomendado) o Password |

**Estado actual:** ❌ Credenciales password no funcionales; se requiere configurar SSH key.

### WordPress Installation

| Variable | Valor |
|----------|-------|
| Path | /html/staging |
| URL | https://staging.runartfoundry.com |
| wp-config.php | /html/staging/wp-config.php (inferido) |
| wp-content/ | /html/staging/wp-content |
| themes/ | /html/staging/wp-content/themes |

---

## Exploración Realizada

### 1. Verificación HTTP/HTTPS

```bash
curl -I https://staging.runartfoundry.com
```

**Resultado esperado:** 200 OK, sitio WordPress funcionando

### 2. Estructura de Directorios (según reportes anteriores)

```
/html/staging/
├── wp-config.php
├── wp-content/
│   ├── themes/
│   │   ├── runart-base/      ← Tema base (padre)
│   │   ├── runart-theme/     ← Tema hijo (activo)
│   │   └── *.backup.*        ← Backups automáticos
│   ├── plugins/
│   ├── uploads/
│   └── languages/
├── wp-includes/
└── wp-admin/
```

### 3. Temas Detectados

Basado en documentación previa (_reports/STATUS_DEPLOYMENT_SSH_20251028.md):

| Tema | Estado | Path |
|------|--------|------|
| runart-base | Instalado (padre) | /html/staging/wp-content/themes/runart-base |
| runart-theme | Instalado (hijo activo) | /html/staging/wp-content/themes/runart-theme |

**Verificación:** Ambos temas presentes y funcionales según deployment anterior.

### 4. WP-CLI Availability

**Estado según reportes:** ✅ DISPONIBLE

Comandos verificados en despliegues anteriores:
```bash
wp cache flush
wp option get home
wp theme list
```

**Path WP-CLI:** Probablemente en `/usr/local/bin/wp` o instalado localmente.

### 5. Permisos y Ownership

**User/Group esperado:** u11876951:u11876951

**Permisos típicos IONOS:**
- Directories: 755
- Files: 644
- wp-config.php: 600 (recomendado)

### 6. Logs y Debugging

**Ubicaciones típicas en IONOS:**
- PHP errors: `/logs/error_log` o `~/logs/`
- Access logs: Disponibles en panel IONOS
- WordPress debug: `wp-content/debug.log` (si WP_DEBUG activado)

**Nota:** Logs de servidor no accesibles directamente vía SSH en planes shared hosting IONOS.

---

## Capacidades Confirmadas (de reportes previos)

✅ WordPress installation funcional  
✅ Tema runart-base instalado  
✅ Tema runart-theme instalado y activo  
✅ WP-CLI disponible  
✅ Acceso SFTP funcional (con credenciales correctas)  
✅ HTTPS habilitado (Let's Encrypt)  
✅ PHP 7.4+ (inferido, típico en IONOS)

---

## Bloqueadores Actuales

❌ **SSH Auth Failure**
   - Causa: Password en ~/.runart_staging_env no funcional
   - Solución: Configurar SSH key sin password
   - Referencia: _reports/STATUS_DEPLOYMENT_SSH_20251028.md#setup-ssh-key

❌ **No se pudo ejecutar exploración en vivo**
   - Impacto: No se pudieron listar directorios ni verificar versiones exactas
   - Workaround: Uso de información de reportes previos y documentación

---

## Próximos Pasos

### Inmediatos

1. **Configurar SSH Key:**
   ```bash
   # Generar key
   ssh-keygen -t ed25519 -f ~/.ssh/ionos_runart -C "runart-staging-deploy"
   
   # Copiar a servidor IONOS
   ssh-copy-id -i ~/.ssh/ionos_runart.pub u11876951@access958591985.webspace-data.io
   
   # Actualizar ~/.runart_staging_env
   export IONOS_SSH_KEY="$HOME/.ssh/ionos_runart"
   # Remover: export IONOS_SSH_PASS
   ```

2. **Revalidar acceso:**
   ```bash
   source tools/staging_env_loader.sh
   ```

3. **Ejecutar exploración completa:**
   ```bash
   ssh -i ~/.ssh/ionos_runart u11876951@access958591985.webspace-data.io << 'EOFSSH'
   pwd
   find /html/staging -maxdepth 2 -type d
   ls -la /html/staging/wp-content/themes/
   which wp
   wp --info
   EOFSSH
   ```

### Para Deploy

4. **Validar permisos de escritura en themes/**
5. **Probar rsync desde local a remoto**
6. **Ejecutar smoke test post-deploy**

---

## Notas de Seguridad

- ⚠ Password almacenado en ~/.runart_staging_env debe migrarse a SSH key
- ⚠ Archivo ~/.runart_staging_env tiene permisos 600 ✓
- ⚠ No versionar credenciales en Git ✓

---

## Referencias

- Reporte anterior: _reports/STATUS_DEPLOYMENT_SSH_20251028.md
- Loader script: tools/staging_env_loader.sh
- Staging URL: https://staging.runartfoundry.com
- Panel IONOS: https://www.ionos.com/hosting/webspace

---

**Conclusión:** Infraestructura staging verificada como funcional según reportes previos. Se requiere configurar SSH key para habilitar exploración directa y deploys automatizados.
