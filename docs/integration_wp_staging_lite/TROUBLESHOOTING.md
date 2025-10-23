# Troubleshooting - WP Staging Lite Integration

## Problema: Sitio Local no accesible / Redirect Loop (HTTP 301)

### Síntomas
- El sitio responde con HTTP 301 Moved Permanently
- Redirecciona a URL incorrecta (ej: `http://localhost/` sin puerto)
- Error "Could not resolve host" o "ERR_CONNECTION_REFUSED"

### Causa
WordPress tiene configuradas URLs incorrectas en:
1. Base de datos (tabla `wp_options`, campos `siteurl` y `home`)
2. O faltan constantes de forzado en `wp-config.php`

### Solución aplicada (blindaje permanente)

Se agregaron constantes en `wp-config.php` que **sobrescriben** valores de BD:

```php
/* URL Configuration - Auto-fixed to prevent redirect loops */
define( 'WP_HOME', 'http://localhost:10010' );
define( 'WP_SITEURL', 'http://localhost:10010' );
```

**Ubicación**: Antes de `/* That's all, stop editing! Happy publishing. */`

### Por qué esto blinda el sitio

1. **Prioridad de constantes**: `WP_HOME` y `WP_SITEURL` en wp-config.php tienen prioridad sobre valores de BD
2. **No depende de plugins**: Se aplica antes de cargar cualquier plugin
3. **Inmune a cambios de BD**: Aunque la BD tenga URLs incorrectas, estas constantes prevalecen

### Script de reparación automática

Si el problema vuelve a ocurrir en otro sitio Local:

```bash
# Ejecutar desde el repo runartfoundry
bash tools/fix_local_wp_urls.sh
```

### Verificación post-fix

```bash
# 1. Verificar que el sitio responda (debe devolver HTTP 200)
curl -I http://localhost:10010/

# 2. Verificar que el endpoint REST funcione
curl http://localhost:10010/wp-json/briefing/v1/status

# 3. Verificar que no haya warnings de PHP
curl -s http://localhost:10010/ | grep -i "warning"
```

### Notas para nuevas instalaciones

Cuando configures un nuevo sitio Local:

1. **Anota el puerto asignado por Local** (ej: 10010, 10020, etc.)
2. **Actualiza `local_site.env`** con:
   ```bash
   WP_PUBLIC_PATH="/mnt/c/Users/TU_USUARIO/Local Sites/NOMBRE_SITIO/app/public"
   BASE_URL="http://localhost:PUERTO"
   ```
3. **Ejecuta el script de setup**:
   ```bash
   bash tools/setup_local_wp_config.sh
   ```

### Backups de seguridad

Cada vez que se modifica `wp-config.php`, se crea un backup automático:
- Ubicación: `/mnt/c/Users/pepec/Local Sites/runart-staging-local/app/public/wp-config.php.backup_YYYYMMDD_HHMMSS`
- Para restaurar: `cp wp-config.php.backup_FECHA wp-config.php`

---

**Última actualización**: 2025-10-22  
**Sitio afectado**: runart-staging-local  
**Estado**: ✅ Resuelto y blindado
