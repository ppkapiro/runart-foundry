# 🚨 INFORME CRÍTICO: Producción y Staging comparten BASE DE DATOS

**Fecha**: 2025-10-21 16:26  
**Servidor**: IONOS u111876951@access958591985.webspace-data.io  
**Estado**: ❌ **PROBLEMA DETECTADO - Reparación detenida**

---

## 🔍 Diagnóstico ejecutado

He ejecutado el script de auto-detección en tu servidor IONOS:

```
[16:26:22] ✓ BASE_PATH detectado: /homepages/7/d958591985/htdocs
[16:26:22] Configuración detectada:
[16:26:22]   Producción DB: dbs10646556 @ db5012671937.hosting-data.io
[16:26:22]   Staging   DB: dbs10646556 @ db5012671937.hosting-data.io
[16:26:22] 
[16:26:22] ❌ ERROR: Producción y staging usan la misma base de datos
```

### Configuración actual (PELIGROSA)

**Producción** (`/homepages/7/d958591985/htdocs/wp-config.php`):
```php
define('DB_NAME', 'dbs10646556');
define('DB_USER', 'dbu2309272');
define('DB_HOST', 'db5012671937.hosting-data.io');
```

**Staging** (`/homepages/7/d958591985/htdocs/staging/wp-config.php`):
```php
define('DB_NAME', 'dbs10646556');  ← ❌ MISMA BASE
define('DB_USER', 'dbu2309272');
define('DB_HOST', 'db5012671937.hosting-data.io');
```

---

## 🔴 Por qué es peligroso

Ambos WordPress (producción y staging) escriben y leen de **la misma tabla `wp_options`**:

1. **Cambios en staging afectan producción**:
   - Si cambias una URL en staging → producción se rompe
   - Si instalas un plugin en staging → producción lo ve
   - Si modificas un post en staging → aparece en producción

2. **El problema original se explica**:
   - Cuando "arreglabas" las URLs de uno, rompías el otro
   - No es que hubiera redirects mal configurados (eso también)
   - Es que **literalmente comparten la misma configuración en DB**

3. **No se puede reparar automáticamente**:
   - Cualquier UPDATE a `wp_options` afectaría a ambos
   - El script abortó por seguridad (diseñado así)

---

## ✅ Solución: Crear base de datos separada para staging

### Paso 1: Crear nueva base en panel IONOS

Accede al panel de IONOS:
- URL: https://www.ionos.es/hosting
- Sección: **Bases de datos** → **MySQL**
- Acción: **Crear nueva base de datos**

Te dará:
- Nombre: `dbs[NUEVO_ID]` (ejemplo: `dbs10646557`)
- Usuario: `dbu[ID]` (puede ser nuevo o reutilizar `dbu2309272`)
- Password: [nueva password segura]
- Host: `db5012671937.hosting-data.io` (mismo que producción)

### Paso 2: Ejecutar script de migración

He creado `tools/ionos_create_staging_db.sh` que:

1. ✓ Exporta la base de producción (dump SQL)
2. ✓ Importa a la nueva base staging
3. ✓ Actualiza `wp-config.php` de staging con nuevas credenciales
4. ✓ Cambia las URLs en staging a `staging.runartfoundry.com`
5. ✓ Guarda backups de todo

**Cómo ejecutarlo**:

```bash
# Copiar script al servidor
sshpass -p 'Tomeguin19$' scp tools/ionos_create_staging_db.sh u111876951@access958591985.webspace-data.io:~/

# Ejecutar en servidor
sshpass -p 'Tomeguin19$' ssh u111876951@access958591985.webspace-data.io 'chmod +x ~/ionos_create_staging_db.sh && ~/ionos_create_staging_db.sh'
```

El script te pedirá:
- Nombre de la nueva base staging (la que creaste en IONOS)
- Usuario y password
- Confirmación antes de cada paso

### Paso 3: Volver a ejecutar reparación auto-detect

Una vez que staging tenga su propia base:

```bash
./tools/remote_run_autodetect.sh u111876951@access958591985.webspace-data.io
```

Ahora sí detectará bases separadas y ejecutará la reparación completa.

---

## 🎯 Estado actual del servidor

**Archivos en servidor**:
```
~/repair_autodetect_prod_staging.sh  ← Ya copiado, listo para re-ejecutar
```

**WordPress detectado**:
```
BASE_PATH: /homepages/7/d958591985/htdocs
├── wp-config.php                    ← Producción (DB: dbs10646556)
├── staging/
│   └── wp-config.php                ← Staging (DB: dbs10646556 ❌)
```

**Próxima acción**:
1. Crear base staging en panel IONOS
2. Copiar y ejecutar `ionos_create_staging_db.sh`
3. Re-ejecutar `repair_autodetect_prod_staging.sh`

---

## 🔐 Configuración objetivo (después de migración)

**Producción** (`/homepages/7/d958591985/htdocs/wp-config.php`):
```php
define('DB_NAME', 'dbs10646556');     ← Producción
define('DB_USER', 'dbu2309272');
define('DB_HOST', 'db5012671937.hosting-data.io');
define('WP_HOME', 'https://runartfoundry.com');
define('WP_SITEURL', 'https://runartfoundry.com');
```

**Staging** (`/homepages/7/d958591985/htdocs/staging/wp-config.php`):
```php
define('DB_NAME', 'dbs10646557');     ← Nueva base staging ✓
define('DB_USER', 'dbu2309272');      ← Mismo usuario OK
define('DB_HOST', 'db5012671937.hosting-data.io');
define('WP_HOME', 'https://staging.runartfoundry.com');
define('WP_SITEURL', 'https://staging.runartfoundry.com');
```

---

## 📊 Comparación: Antes vs Después

| Aspecto | ANTES (actual) | DESPUÉS (objetivo) |
|---------|----------------|-------------------|
| **Prod DB** | dbs10646556 | dbs10646556 ✓ |
| **Staging DB** | dbs10646556 ❌ | dbs10646557 ✓ |
| **Aislamiento** | ❌ Ninguno | ✅ Total |
| **Cambios staging** | Afectan prod ❌ | Independientes ✓ |
| **URLs prod** | Mezcladas ❌ | runartfoundry.com ✓ |
| **URLs staging** | Mezcladas ❌ | staging.runartfoundry.com ✓ |

---

## ⚠️ Advertencias importantes

1. **NO ejecutes scripts de reparación hasta separar las bases**:
   - Podrían romper ambos entornos simultáneamente

2. **El script de migración es seguro**:
   - Hace backup de wp-config.php antes de modificar
   - Guarda el dump SQL completo
   - No toca la base de producción (solo lectura)

3. **Tiempo estimado**:
   - Crear base en IONOS: 5 min
   - Ejecutar migración: 2-5 min (depende del tamaño de BD)
   - Verificar: 2 min
   - **Total: ~10-15 minutos**

4. **Si algo falla**:
   - El dump SQL se guarda en el servidor
   - Los backups de wp-config.php están disponibles
   - Puedes restaurar todo fácilmente

---

## 📝 Checklist de ejecución

- [ ] **1. Crear base en panel IONOS**
  - [ ] Acceder a https://www.ionos.es/hosting
  - [ ] Bases de datos → Crear nueva
  - [ ] Anotar: nombre, usuario, password

- [ ] **2. Ejecutar script de migración**
  - [ ] Copiar `ionos_create_staging_db.sh` al servidor
  - [ ] Ejecutar y seguir prompts interactivos
  - [ ] Verificar que completa sin errores

- [ ] **3. Validar staging**
  - [ ] Abrir https://staging.runartfoundry.com en navegador
  - [ ] Verificar que carga (puede tener URLs rotas aún, normal)

- [ ] **4. Ejecutar reparación auto-detect**
  - [ ] `./tools/remote_run_autodetect.sh u111876951@...`
  - [ ] Verificar reporte generado

- [ ] **5. Validación final**
  - [ ] https://runartfoundry.com → Sitio del cliente
  - [ ] https://staging.runartfoundry.com → Staging independiente
  - [ ] Verificar que cambios en uno no afectan al otro

---

## 🆘 Soporte

Si tienes dudas o problemas durante el proceso:

1. **Revisa los logs**: El script es muy verboso, te dice exactamente qué hace
2. **Backups disponibles**: Todo se respalda antes de modificar
3. **Rollback**: Los backups tienen timestamp, fácil de restaurar

**Archivos de soporte**:
- Este informe: `_reports/INFORME_BD_COMPARTIDA_20251021.md`
- Script migración: `tools/ionos_create_staging_db.sh`
- Script reparación: `tools/repair_autodetect_prod_staging.sh`

---

## 🎯 Resumen ejecutivo

**Problema**: Producción y staging comparten base de datos (dbs10646556)  
**Causa**: Configuración incorrecta desde el inicio  
**Impacto**: Cambios en staging rompen producción y viceversa  
**Solución**: Crear base staging separada + migrar datos + actualizar wp-config.php  
**Tiempo**: ~15 minutos  
**Riesgo**: Bajo (con backups automáticos)  
**Próximo paso**: Crear base en panel IONOS y ejecutar `ionos_create_staging_db.sh`

---

**Estado del script auto-detect**: ✅ Funcionando correctamente  
**Razón de detención**: ✅ Protección de seguridad activada (diseño correcto)  
**Acción requerida**: 🔧 Crear base staging separada primero
