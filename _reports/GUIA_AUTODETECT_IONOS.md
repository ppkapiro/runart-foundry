# 🧩 Guía: Reparación AUTO-DETECT para IONOS

## Resumen ejecutivo

Script inteligente que:
- **Detecta automáticamente** la ubicación de WordPress (raíz `/`, `/htdocs`, `/homepages/.../htdocs`)
- **Repara producción** (runartfoundry.com): restaura URLs, limpia redirects a staging
- **Aísla staging** (staging.runartfoundry.com): garantiza independencia total
- **Modo seguro**: Si no encuentra WordPress, genera diagnóstico sin tocar nada
- **Backups automáticos**: Copia wp-config.php y .htaccess antes de modificar

---

## Archivo creado

**`tools/repair_autodetect_prod_staging.sh`**

### Qué hace

1. **Auto-detección de rutas**:
   - Busca `wp-config.php` en `/`, `/htdocs`, `/homepages/*/*/htdocs`
   - Valida que existan producción (`/wp-config.php`) y staging (`/staging/wp-config.php`)

2. **Extracción de credenciales**:
   - Lee DB_NAME, DB_USER, DB_PASSWORD, DB_HOST desde cada wp-config.php
   - Permite sobrescribir con variables de entorno

3. **Reparación producción**:
   - Fuerza `WP_HOME`/`WP_SITEURL` a `https://runartfoundry.com`
   - Actualiza `siteurl`/`home` en la base de datos
   - Limpia `.htaccess` de redirects a staging
   - Purga caché local
   - Regenera permalinks (si hay WP_USER/WP_APP_PASSWORD)
   - Purga Cloudflare (si hay CLOUDFLARE_API_TOKEN)

4. **Reparación staging**:
   - Fuerza `WP_HOME`/`WP_SITEURL` a `https://staging.runartfoundry.com`
   - Actualiza `siteurl`/`home` en la base staging
   - Convierte symlink `uploads` a carpeta física independiente
   - Purga caché local
   - Regenera permalinks
   - Purga Cloudflare

5. **Seguridad**:
   - Aborta si producción y staging usan la misma base de datos
   - Backups de wp-config.php y .htaccess antes de modificar
   - Modo safe si no encuentra WordPress

---

## Uso

### Opción 1: Ejecución local (en el servidor)

```bash
# SSH al servidor IONOS
ssh u111876951@access958591985.webspace-data.io

# Copiar script (desde tu máquina local)
scp tools/repair_autodetect_prod_staging.sh usuario@servidor:/tmp/

# Ejecutar en el servidor
chmod +x /tmp/repair_autodetect_prod_staging.sh
/tmp/repair_autodetect_prod_staging.sh
```

### Opción 2: Runner remoto (recomendado)

**Archivo**: `tools/remote_run_autodetect.sh`

```bash
# Desde tu máquina local
./tools/remote_run_autodetect.sh usuario@servidor.ionos.com
```

Con variables de entorno (si tienes un envfile remoto):

```bash
./tools/remote_run_autodetect.sh usuario@servidor.ionos.com ~/.runart_env
```

El runner:
1. Copia el script al servidor
2. Lo ejecuta (con envfile si lo proporcionas)
3. Descarga automáticamente el reporte a `_reports/repair_autodetect/`

---

## Variables de entorno opcionales

Exporta o incluye en un envfile remoto (`~/.runart_env`):

```bash
# Credenciales de base de datos (si no quieres usar las del wp-config.php)
export DB_USER="dbuXXXXX"
export DB_PASSWORD="tu_password"
export DB_HOST="localhost"

# WordPress REST API (para regenerar permalinks)
export WP_USER="github-actions"
export WP_APP_PASSWORD="xxxx xxxx xxxx xxxx"

# Cloudflare (para purgar caché)
export CLOUDFLARE_API_TOKEN="tu_token"
export CF_ZONE_ID="tu_zone_id"

# Sobrescribir directorio de reportes
export REPORT_DIR="_reports/repair_autodetect"
```

---

## Ejemplo: IONOS con credenciales del .env.staging.local

Desde tu `.env.staging.local` (local, no versionado):

```bash
IONOS_SSH_HOST=u111876951@access958591985.webspace-data.io
SSH_PORT=22
STAGING_DOMAIN=staging.runartfoundry.com
DB_USER=dbu207439
# ...
```

### Crear envfile en el servidor

```bash
# Desde tu máquina
ssh $IONOS_SSH_HOST << 'EOF'
cat > ~/.runart_env << 'ENVEOF'
export DB_USER="dbu207439"
export DB_PASSWORD="TU_PASSWORD_AQUI"
export DB_HOST="localhost"
export WP_USER="github-actions"
export WP_APP_PASSWORD="xxxx xxxx xxxx xxxx"
ENVEOF
chmod 600 ~/.runart_env
EOF
```

### Ejecutar

```bash
# Usando el runner remoto con envfile
./tools/remote_run_autodetect.sh $IONOS_SSH_HOST ~/.runart_env
```

---

## Salidas

### Modo seguro (sin WordPress real)

Si ejecutas localmente sin WordPress:

```
[16:18:58] === 🧩 REPARACIÓN AUTO-DETECT PROD/STAGING ===
[16:18:58] Fecha: 20251021_161858
[16:18:58] ⚠️ No se localizaron wp-config.php de prod y staging en rutas conocidas.
[16:18:58]    Ejecutando en modo SAFE (solo reporte de diagnóstico).
...
[16:18:58] ✔ Reporte de diagnóstico creado: _reports/repair_autodetect/repair_autodetect_safe_20251021_161858.md
```

### Modo activo (en servidor con WordPress)

```
[16:20:00] === 🧩 REPARACIÓN AUTO-DETECT PROD/STAGING ===
[16:20:00] ✓ BASE_PATH detectado: /homepages/7/d958591985/htdocs
[16:20:00] → Extrayendo credenciales de producción…
[16:20:00] → Extrayendo credenciales de staging…
[16:20:00] Configuración detectada:
[16:20:00]   Producción DB: db_prod @ localhost (user: dbuXXXXX)
[16:20:00]   Staging   DB: db_stag @ localhost (user: dbuXXXXX)
...
[16:20:05] ═══════════════════════════════════════════════════════════
[16:20:05]   REPARANDO PRODUCCIÓN (https://runartfoundry.com)
[16:20:05] ═══════════════════════════════════════════════════════════
[16:20:05] ✓ WP_HOME/WP_SITEURL forzados a: https://runartfoundry.com
[16:20:05] ✓ URLs actualizadas en BD prod
[16:20:05] ✓ .htaccess sin redirecciones problemáticas
[16:20:05] ✓ Caché purgada: /homepages/.../htdocs/wp-content/cache
...
[16:20:10] ✔ Reparación completada exitosamente
[16:20:10] ✔ Reporte guardado: _reports/repair_autodetect/repair_autodetect_20251021_162000.md
```

---

## Reporte generado

**`_reports/repair_autodetect/repair_autodetect_YYYYMMDD_HHMMSS.md`**

Contiene:
- BASE_PATH detectado
- Rutas de wp-config.php (prod y staging)
- Acciones realizadas en cada entorno
- Backups creados
- Siguiente paso: validar sitios

**Archivos adicionales**:
- `prod_urls_before_YYYYMMDD_HHMMSS.txt`: URLs antes de la corrección (producción)
- `staging_urls_before_YYYYMMDD_HHMMSS.txt`: URLs antes de la corrección (staging)
- `htaccess_backup_YYYYMMDD_HHMMSS.txt`: Backup de .htaccess (si se modificó)

---

## Validación post-reparación

```bash
# Verificar headers HTTP
curl -I https://runartfoundry.com
curl -I https://staging.runartfoundry.com

# Verificar en navegador
# - https://runartfoundry.com (debe mostrar sitio del cliente)
# - https://staging.runartfoundry.com (debe mostrar staging independiente)

# Verificar que NO hay redirects cruzados
curl -L https://staging.runartfoundry.com | grep -i "runartfoundry.com"
# (no debe mostrar nada o solo menciones en contenido, NO en headers)
```

---

## Rollback (si algo falla)

Los backups están en el servidor:

```bash
# Restaurar wp-config.php de producción
cp /homepages/.../htdocs/wp-config.php.bak.20251021_162000 \
   /homepages/.../htdocs/wp-config.php

# Restaurar wp-config.php de staging
cp /homepages/.../htdocs/staging/wp-config.php.bak.20251021_162000 \
   /homepages/.../htdocs/staging/wp-config.php

# Restaurar .htaccess (si existe backup)
cp _reports/repair_autodetect/htaccess_backup_20251021_162000.txt \
   /homepages/.../htdocs/.htaccess
```

---

## Integración con VS Code

**Task agregada**: `🧩 Reparación AUTO-DETECT (IONOS/raíz)`

Para ejecutar:
1. `Ctrl+Shift+P` (o `Cmd+Shift+P` en Mac)
2. Escribe: `Tasks: Run Task`
3. Selecciona: `🧩 Reparación AUTO-DETECT (IONOS/raíz)`

⚠️ **Nota**: La task ejecuta localmente (modo seguro). Para ejecutar en el servidor real, usa el runner remoto.

---

## Comparación con scripts anteriores

| Característica | `repair_final_prod_staging.sh` | `repair_autodetect_prod_staging.sh` |
|----------------|--------------------------------|-------------------------------------|
| Detección de rutas | Manual (BASE_PATH) | **Automática** (/, /htdocs, /homepages) |
| Modo seguro | No | **Sí** (diagnóstico si no encuentra WP) |
| IONOS friendly | Configurable | **Nativo** (busca patrones IONOS) |
| Backups | Manual | **Automático** (wp-config + .htaccess) |
| Validación DBs | No | **Sí** (aborta si prod=staging) |
| Regeneración permalinks | Sí | Sí |
| Cloudflare purge | Sí | Sí |

**Recomendación**: Usar `repair_autodetect_prod_staging.sh` como primera opción; si necesitas control fino de BASE_PATH, usa `repair_final_prod_staging.sh`.

---

## Próximos pasos

1. **Primera ejecución** (diagnóstico):
   ```bash
   ./tools/remote_run_autodetect.sh $IONOS_SSH_HOST
   ```

2. **Si diagnóstico OK**: Ejecutar con envfile:
   ```bash
   # Crear envfile en servidor (ver sección anterior)
   ./tools/remote_run_autodetect.sh $IONOS_SSH_HOST ~/.runart_env
   ```

3. **Validar sitios** (ver sección Validación)

4. **Documentar** en `_reports/` el resultado

5. **Rotación de credenciales** (si SSH_PASS o App Passwords quedaron expuestos)

---

## Soporte y troubleshooting

### Error: "No se localizaron wp-config.php"

- Verifica que WordPress esté instalado en el servidor
- Prueba proporcionar BASE_PATH manualmente:
  ```bash
  BASE_PATH=/tu/ruta/real ./tools/repair_autodetect_prod_staging.sh
  ```

### Error: "Producción y staging usan la misma base de datos"

- **PELIGRO**: No ejecutes el script si las bases son iguales
- Primero crea una base staging independiente:
  - Dump de producción → importar a nueva base → actualizar wp-config.php de staging

### Error: "No se pudo actualizar BD"

- Verifica credenciales en wp-config.php o variables de entorno
- Comprueba conectividad: `mysql -u$DB_USER -p$DB_PASSWORD -h$DB_HOST -e "SHOW DATABASES;"`

### Permalinks no se regeneran

- Verifica que `WP_USER` y `WP_APP_PASSWORD` estén exportados
- Prueba manualmente: `curl -I https://staging.runartfoundry.com/wp-json/`
- Si REST API está deshabilitada, regenera permalinks desde WP-Admin

---

## Seguridad

- ✅ `.env.staging.local` (con SSH_PASS) ya está ignorado por Git
- ✅ Backups automáticos de wp-config.php antes de modificar
- ✅ Validación de bases de datos separadas
- 🔄 **Pendiente**: Rotar SSH_PASS y migrar a autenticación por clave SSH
- 🔄 **Pendiente**: Rotar WP_APP_PASSWORD si quedó expuesto en logs/mensajes

---

## Referencias

- Script principal: `tools/repair_autodetect_prod_staging.sh`
- Runner remoto: `tools/remote_run_autodetect.sh`
- VS Code task: `.vscode/tasks.json` → "🧩 Reparación AUTO-DETECT (IONOS/raíz)"
- Reportes: `_reports/repair_autodetect/`
- Variables locales (no versionadas): `.env.staging.local`

---

**Creado**: 2025-10-21  
**Autor**: GitHub Copilot (basado en tus scripts previos)  
**Versión**: 1.0
