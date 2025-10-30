# Validación de Permisos en STAGING — RunArt Foundry F10-d

## 📋 Descripción

Suite completa de scripts para diagnosticar y solucionar problemas de permisos en el entorno STAGING del proyecto RunArt Foundry. Estos scripts garantizan que el plugin `runart-wpcli-bridge.php` pueda leer los archivos JSON de contenido enriquecido y escribir solicitudes de aprobación.

## 🎯 Problema identificado

El plugin y la página "Panel Editorial IA-Visual" están instalados correctamente en staging, pero no muestran datos porque:

1. **Entorno protegido**: Variables `READ_ONLY=1` y `DRY_RUN=1` activas
2. **Permisos de lectura**: El plugin no puede leer `data/assistants/rewrite/*.json`
3. **Permisos de escritura**: El plugin no puede escribir en `wp-content/uploads/runart-jobs/`
4. **Usuario web server**: Posible mismatch de permisos con www-data/nginx

## 📦 Scripts incluidos

### 1. `diagnose_staging_permissions.sh`

**Propósito**: Diagnóstico completo del estado actual de permisos.

**Uso**:
```bash
bash tools/diagnose_staging_permissions.sh
```

**Verifica**:
- Variables de entorno `READ_ONLY` y `DRY_RUN`
- Usuario del web server (www-data, nginx, php-fpm)
- Existencia y permisos de rutas críticas:
  - `data/assistants/rewrite/`
  - `data/assistants/rewrite/index.json`
  - `data/assistants/rewrite/page_*.json`
  - `wp-content/uploads/`
  - `wp-content/uploads/runart-jobs/`
- Permisos de archivos y directorios
- Owner y group de cada ruta

**Salida**: 
- Log detallado en `logs/staging_permissions_TIMESTAMP.log`
- Resumen en `logs/env_check_staging.log`

---

### 2. `fix_staging_permissions.sh`

**Propósito**: Ajustar permisos de forma segura y controlada.

**Uso**:
```bash
# Modo simulación (no aplica cambios)
bash tools/fix_staging_permissions.sh --dry-run

# Aplicar cambios reales
bash tools/fix_staging_permissions.sh

# Especificar usuario web server manualmente
bash tools/fix_staging_permissions.sh --web-user=www-data
```

**Acciones**:
- Detecta o usa el usuario web server especificado
- Ajusta owner de `data/assistants/rewrite/` a web server user
- Configura permisos 755 en directorios, 644 en archivos
- Ajusta owner de `wp-content/uploads/` a web server user
- Configura permisos 775 en `uploads/` para permitir escritura
- Crea `wp-content/uploads/runart-jobs/` si no existe
- Copia JSONs al plugin si es necesario

**Salida**: 
- Log en `logs/staging_permissions_fix_TIMESTAMP.log`

**⚠️ IMPORTANTE**: Este script requiere permisos sudo para cambiar owner.

---

### 3. `test_staging_write.sh`

**Propósito**: Probar capacidad de escritura en staging de forma controlada.

**Uso**:
```bash
bash tools/test_staging_write.sh
```

**Proceso**:
1. Guarda estado original de `READ_ONLY` y `DRY_RUN`
2. Deshabilita temporalmente protecciones (`READ_ONLY=0`, `DRY_RUN=0`)
3. Escribe archivo de prueba en `wp-content/uploads/runart-jobs/test_write.json`
4. Verifica lectura del archivo
5. Limpia archivo de prueba
6. Restaura variables originales

**Salida**: 
- Log en `logs/staging_write_test_TIMESTAMP.log`

---

### 4. `validate_staging_endpoints.sh`

**Propósito**: Validar que los endpoints REST del plugin funcionan correctamente.

**Uso**:
```bash
# Sin autenticación (solo endpoints públicos)
bash tools/validate_staging_endpoints.sh https://staging.runartfoundry.com

# Con autenticación (endpoints completos)
bash tools/validate_staging_endpoints.sh \
    https://staging.runartfoundry.com \
    admin \
    password_here
```

**Endpoints probados**:
- `GET /wp-json/runart/content/enriched-list`
- `GET /wp-json/runart/content/enriched?page_id=page_42`
- `GET /wp-json/runart/content/enriched?page_id=page_43`
- `GET /wp-json/runart/content/enriched?page_id=page_44`
- Página: `/en/panel-editorial-ia-visual/`

**Verifica**:
- HTTP status codes (200, 401, 403, 404, 500)
- Estructura de respuesta JSON (`ok: true`, `items[]`)
- Presencia de `visual_references` en contenidos
- Carga correcta de la página del panel
- Metadata de `source` y `paths_tried` desde el plugin

**Salida**: 
- Log en `logs/staging_endpoints_TIMESTAMP.log`

---

### 5. `staging_full_validation.sh` ⭐ **RECOMENDADO**

**Propósito**: Script maestro que ejecuta todo el flujo de validación.

**Uso**:
```bash
# Validación completa con autenticación
bash tools/staging_full_validation.sh \
    --staging-url=https://staging.runartfoundry.com \
    --wp-user=admin \
    --wp-password=secret

# Modo simulación (no aplica cambios)
bash tools/staging_full_validation.sh \
    --staging-url=https://staging.runartfoundry.com \
    --dry-run

# Omitir ajuste de permisos (solo diagnóstico y validación)
bash tools/staging_full_validation.sh \
    --staging-url=https://staging.runartfoundry.com \
    --skip-permissions

# Ver todas las opciones
bash tools/staging_full_validation.sh --help
```

**Opciones**:
- `--staging-url=URL`: URL del sitio staging
- `--wp-user=USER`: Usuario WordPress para pruebas
- `--wp-password=PASS`: Contraseña WordPress
- `--web-user=USER`: Usuario del web server (default: auto-detect)
- `--skip-permissions`: Omitir ajuste de permisos
- `--skip-endpoints`: Omitir validación de endpoints
- `--dry-run`: Modo simulación

**Flujo completo**:
1. 🔍 Diagnóstico inicial de permisos
2. 🔧 Ajuste de permisos (si no se omite)
3. 🧪 Prueba de escritura controlada
4. 🌐 Validación de endpoints REST
5. 🔒 Restauración de modo protegido
6. 📝 Documentación en bitácora

**Salida**: 
- Master log: `logs/staging_full_validation_TIMESTAMP.log`
- Entrada en `_reports/BITACORA_AUDITORIA_V2.md`

---

## 🚀 Flujo de trabajo recomendado

### Paso 1: Diagnóstico inicial

```bash
cd /home/pepe/work/runartfoundry
bash tools/diagnose_staging_permissions.sh
```

Revisar el log generado para identificar problemas específicos.

### Paso 2: Ajuste de permisos (si es necesario)

```bash
# Primero en modo dry-run para ver qué cambios se aplicarían
bash tools/fix_staging_permissions.sh --dry-run

# Si todo se ve bien, aplicar cambios
bash tools/fix_staging_permissions.sh
```

### Paso 3: Prueba de escritura

```bash
bash tools/test_staging_write.sh
```

Confirmar que el plugin puede escribir en `uploads/runart-jobs/`.

### Paso 4: Validación de endpoints

```bash
bash tools/validate_staging_endpoints.sh \
    https://staging.runartfoundry.com \
    USUARIO_WP \
    PASSWORD_WP
```

Verificar que todos los endpoints responden correctamente.

### Paso 5 (ALTERNATIVA): Ejecutar todo en un solo comando

```bash
bash tools/staging_full_validation.sh \
    --staging-url=https://staging.runartfoundry.com \
    --wp-user=USUARIO_WP \
    --wp-password=PASSWORD_WP
```

---

## 📂 Estructura de rutas críticas

### Rutas de lectura (plugin lee JSONs desde aquí)

El plugin `runart-wpcli-bridge.php` intenta leer desde estas ubicaciones en orden de prioridad:

1. **Repositorio**: `../data/assistants/rewrite/` (relativo a wp-content)
2. **WP Content**: `wp-content/runart-data/assistants/rewrite/`
3. **Plugin interno**: `wp-content/plugins/runart-wpcli-bridge/data/assistants/rewrite/`

**Archivos requeridos**:
- `index.json` — Índice de contenidos enriquecidos
- `page_42.json` — Contenido enriquecido de página 42
- `page_43.json` — Contenido enriquecido de página 43
- `page_44.json` — Contenido enriquecido de página 44
- `approvals.json` — Estado de aprobaciones (opcional)

### Rutas de escritura (plugin escribe aquí)

El plugin intenta escribir en estas ubicaciones en orden de prioridad:

1. **WP Content**: `wp-content/runart-data/assistants/rewrite/approvals.json`
2. **Repositorio**: `../data/assistants/rewrite/approvals.json`
3. **Fallback**: `wp-content/uploads/runart-jobs/enriched-approvals.log`

**Permisos requeridos**:
- Directorio: `775` (rwxrwxr-x)
- Owner: usuario del web server (www-data, nginx, etc.)

---

## 🔐 Variables de entorno críticas

### `READ_ONLY`

**Propósito**: Controlar si el framework permite escritura en el repositorio.

**Valores**:
- `READ_ONLY=0` — Permite escritura (solo para pruebas controladas)
- `READ_ONLY=1` — Solo lectura (default en staging/producción)

**Ubicación**: Variables de entorno del servidor, archivo `.env`

### `DRY_RUN`

**Propósito**: Simular operaciones sin aplicar cambios reales.

**Valores**:
- `DRY_RUN=0` — Ejecutar cambios reales (solo para pruebas controladas)
- `DRY_RUN=1` — Solo simulación (default en staging)

**Ubicación**: Variables de entorno del servidor, archivo `.env`

**⚠️ IMPORTANTE**: Después de cualquier prueba con `READ_ONLY=0` o `DRY_RUN=0`, siempre restaurar a `1` para mantener el entorno protegido.

---

## 📊 Interpretación de logs

### Estado OK

```
✓ Directorio uploads es escribible — permisos: 775, owner: www-data:www-data
✓ page_42.json — archivo, permisos: 644, owner: www-data:www-data, legible: SÍ
✓ Prueba de escritura exitosa: /path/to/test_write.json
✓ Endpoint accesible (HTTP 200)
✓ Contenidos encontrados: 3
```

### Problemas comunes

**Problema**: `page_42.json — archivo, permisos: 644, owner: root:root, legible: NO`

**Solución**: 
```bash
sudo chown www-data:www-data /path/to/data/assistants/rewrite/*.json
```

---

**Problema**: `Directorio runart-jobs NO es escribible — permisos: 755, owner: root:root`

**Solución**: 
```bash
sudo chown www-data:www-data /path/to/wp-content/uploads/runart-jobs
sudo chmod 775 /path/to/wp-content/uploads/runart-jobs
```

---

**Problema**: `Error en endpoint (HTTP 404)` para `/wp-json/runart/content/enriched-list`

**Causas posibles**:
1. Plugin no activado en WordPress
2. Rewrite rules de WordPress no actualizadas
3. JSONs no existen en ninguna ubicación accesible

**Solución**: 
```bash
# Verificar plugin activado
wp plugin list --path=/path/to/wordpress

# Flush rewrite rules
wp rewrite flush --path=/path/to/wordpress

# Verificar existencia de JSONs
ls -la /path/to/data/assistants/rewrite/
```

---

## 🧪 Pruebas manuales

### Probar endpoints desde línea de comandos

```bash
# Sin autenticación
curl -s "https://staging.runartfoundry.com/wp-json/runart/content/enriched-list" | jq '.'

# Con autenticación básica
curl -s -u "usuario:password" \
    "https://staging.runartfoundry.com/wp-json/runart/content/enriched-list" | jq '.'

# Endpoint individual
curl -s "https://staging.runartfoundry.com/wp-json/runart/content/enriched?page_id=page_42" | jq '.'
```

### Probar desde el navegador

1. Acceder a: `https://staging.runartfoundry.com/en/panel-editorial-ia-visual/`
2. Iniciar sesión con usuario WordPress
3. Verificar que se muestra el listado de contenidos
4. Hacer clic en un contenido para ver detalles
5. Probar botones de aprobar/rechazar

---

## 📝 Checklist de validación

- [ ] Variables de entorno verificadas (`READ_ONLY`, `DRY_RUN`)
- [ ] Usuario web server detectado correctamente
- [ ] Rutas de datos existen y son legibles
- [ ] Directorio `runart-jobs/` existe y es escribible
- [ ] Prueba de escritura exitosa
- [ ] Endpoint `/enriched-list` responde con HTTP 200
- [ ] Endpoint devuelve lista de contenidos (no vacía)
- [ ] Endpoint `/enriched?page_id=page_42` responde con datos
- [ ] Página Panel Editorial carga correctamente
- [ ] Botones de aprobar/rechazar funcionan
- [ ] Aprobaciones se registran en `runart-jobs/` o `approvals.json`
- [ ] Modo protegido restaurado (`READ_ONLY=1`, `DRY_RUN=1`)
- [ ] Documentación añadida a bitácora

---

## 🔗 Referencias

- **Plugin**: `tools/wpcli-bridge-plugin/runart-wpcli-bridge.php`
- **Datos enriquecidos**: `data/assistants/rewrite/`
- **Bitácora**: `_reports/BITACORA_AUDITORIA_V2.md`
- **Issue tracking**: GitHub PR #1 (feat/ai-visual-implementation)

---

## 📞 Soporte

Si encuentras problemas durante la validación:

1. Revisa los logs generados en `logs/staging_*_TIMESTAMP.log`
2. Verifica la bitácora en `_reports/BITACORA_AUDITORIA_V2.md`
3. Consulta este README para soluciones a problemas comunes
4. Documenta el problema en el PR con etiqueta `🔐 F10-d`

---

**Última actualización**: 2025-10-30  
**Versión**: 1.0  
**Fase**: F10-d — Verificación de permisos staging IA-Visual
