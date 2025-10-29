# 🔄 Deployment Rollback — Procedures

> **Propósito:** Este documento detalla los procedimientos de rollback para deployments de RunArt Base.  
> **Última actualización:** 2025-01-29  
> **Versión:** 1.0.0

---

## 📋 Tabla de Contenidos

1. [Cuándo Ejecutar Rollback](#cuándo-ejecutar-rollback)
2. [Tipos de Rollback](#tipos-de-rollback)
3. [Prerequisitos](#prerequisitos)
4. [Procedimiento: Rollback Automático](#procedimiento-rollback-automático)
5. [Procedimiento: Rollback Manual](#procedimiento-rollback-manual)
6. [Validación Post-Rollback](#validación-post-rollback)
7. [Troubleshooting](#troubleshooting)
8. [Post-Mortem](#post-mortem)

---

## Cuándo Ejecutar Rollback

### Triggers Automáticos

El script `deploy_theme.sh` ejecuta rollback automático si:

- **Smoke tests fallan:** Páginas principales no responden con 200 OK
- **WP-CLI errors:** Comandos críticos fallan (activación de tema, limpieza de cache)
- **Rsync failures:** Errores durante copia de archivos
- **Disk space issues:** Espacio insuficiente en servidor

**Configuración:** `ROLLBACK_ON_FAIL=1` (default)

### Triggers Manuales

Ejecutar rollback manual si:

- **Funcionalidad crítica rota:** Forms, navigation, login, etc.
- **Performance degradada:** Response times >5s sostenidos
- **Errores visibles:** White screen, 500 errors, fatal errors en logs
- **Stakeholder decision:** Decisión de negocio (producción)
- **Incidentes de seguridad:** Vulnerabilidad descubierta post-deploy

---

## Tipos de Rollback

### 1. Rollback Automático (Script)

**Uso:** Staging deployments con `ROLLBACK_ON_FAIL=1`

**Ventajas:**
- Rápido (completa en <2 min)
- No requiere intervención manual
- Logs automáticos

**Limitaciones:**
- Solo restaura archivos de tema
- No revierte cambios en base de datos
- Requiere backup válido generado por script

---

### 2. Rollback Manual (Completo)

**Uso:** Producción o cuando rollback automático falla

**Ventajas:**
- Control total del proceso
- Permite validación paso a paso
- Puede incluir rollback de DB

**Limitaciones:**
- Requiere más tiempo (5-15 min)
- Requiere acceso SSH y conocimiento técnico

---

### 3. Rollback de Base de Datos (Opcional)

**Uso:** Si deployment incluyó cambios en DB (migraciones, settings)

**Consideraciones:**
- **Datos perdidos:** Contenido creado entre deploy y rollback se pierde
- **Downtime:** Requiere poner sitio en maintenance mode
- **Testing:** Siempre probar restore en staging primero

**Procedimiento:** Ver sección [Rollback de Base de Datos](#rollback-de-base-de-datos)

---

## Prerequisitos

### Para Rollback Automático

- **Backup válido:** Generado por `deploy_theme.sh` durante último deployment
- **Path conocido:** `_reports/deploy_logs/backups/staging_YYYYMMDDTHHMMSSZ.tar.gz`
- **Checksum verificado:** SHA256 sum validado
- **Script disponible:** `tools/rollback_staging.sh` ejecutable

### Para Rollback Manual

- **SSH access:** Key configurada y conexión validada
- **Backup disponible:** Local o en servidor remoto
- **Permisos de escritura:** En directorio `wp-content/themes/`
- **WP-CLI funcional:** Comando `wp` disponible en servidor

### Información Requerida

- **Deployment ID:** `DEPLOY-YYYY-MM-DD-<target>-<incremento>`
- **Backup path:** Path absoluto o relativo al backup a restaurar
- **Backup checksum:** SHA256 para validación
- **Target environment:** `staging` o `production`

---

## Procedimiento: Rollback Automático

### Paso 1: Identificar Backup

```bash
# Listar backups disponibles
ls -lht _reports/deploy_logs/backups/

# Output esperado:
# staging_20250129T150840Z.tar.gz
# staging_20250129T150840Z.sha256
```

**Seleccionar backup:** El más reciente anterior al deployment fallido

---

### Paso 2: Validar Backup

```bash
# Verificar checksum
cd _reports/deploy_logs/backups/
sha256sum -c staging_20250129T150840Z.sha256

# Expected output:
# staging_20250129T150840Z.tar.gz: OK
```

**Si checksum falla:** NO continuar, usar backup anterior o rollback manual

---

### Paso 3: Ejecutar Rollback

```bash
# Cargar entorno
source ~/.runart_staging_env

# Ejecutar script de rollback
./tools/rollback_staging.sh --backup=_reports/deploy_logs/backups/staging_20250129T150840Z.tar.gz --target=staging

# Argumentos:
# --backup: Path al archivo .tar.gz
# --target: staging o production
# --skip-validation: (opcional) omite smoke tests post-rollback
```

**Output esperado:**
```
[INFO] Iniciando rollback a staging
[INFO] Backup: _reports/deploy_logs/backups/staging_20250129T150840Z.tar.gz
[INFO] Checksum validado: OK
[INFO] Extrayendo backup...
[INFO] Copiando archivos vía rsync...
[INFO] 247 archivos restaurados
[INFO] Activando tema: runart-base
[INFO] Limpiando cache...
[INFO] Ejecutando smoke tests...
[SUCCESS] Rollback completado en 87 segundos
```

---

### Paso 4: Validación Automática

El script ejecuta automáticamente:

- Verifica tema activo: `wp theme list --status=active`
- Prueba páginas principales: `curl -I https://staging.runartfoundry.com/`
- Revisa logs: `tail -n 50 error_log`

**Si validación falla:** Proceder a rollback manual

---

### Paso 5: Documentación

```bash
# El script genera automáticamente:
# _reports/deploy_logs/ROLLBACK_20250129T151500Z.md

# Revisar reporte:
cat _reports/deploy_logs/ROLLBACK_20250129T151500Z.md
```

**Contenido del reporte:**
- Timestamp de rollback
- Backup utilizado
- Archivos restaurados
- Resultado de smoke tests
- Logs de errores (si los hubo)

---

## Procedimiento: Rollback Manual

### Caso 1: Rollback de Archivos de Tema

#### Paso 1: Conectar vía SSH

```bash
ssh ${STAGING_USER}@${STAGING_HOST}
# u111876951@access958591985.webspace-data.io
```

---

#### Paso 2: Backup del Estado Actual (Opcional)

```bash
# Crear backup del estado fallido para análisis
cd /homepages/7/d958591985/htdocs/staging/wp-content/themes
tar -czf ~/runart-base-failed-$(date +%Y%m%dT%H%M%SZ).tar.gz runart-base/
```

---

#### Paso 3: Descargar Backup a Servidor

**Opción A: Si backup está local**

```bash
# Desde máquina local
scp _reports/deploy_logs/backups/staging_20250129T150840Z.tar.gz \
  ${STAGING_USER}@${STAGING_HOST}:~/backup_rollback.tar.gz
```

**Opción B: Si backup está en servidor**

```bash
# Ya en SSH del servidor
cd ~
# Ubicar backup generado previamente (si existe)
ls -lht ~/backups/
```

---

#### Paso 4: Extraer y Reemplazar

```bash
# Extraer backup
cd /homepages/7/d958591985/htdocs/staging/wp-content/themes
tar -xzf ~/backup_rollback.tar.gz

# Verificar extracción
ls -la runart-base/
```

---

#### Paso 5: Activar Tema y Limpiar Cache

```bash
# Activar tema
cd /homepages/7/d958591985/htdocs/staging
wp theme activate runart-base

# Limpiar cache (si aplica)
wp cache flush
wp rewrite flush
```

---

#### Paso 6: Validar Manualmente

```bash
# Verificar tema activo
wp theme list --status=active

# Probar páginas
curl -I https://staging.runartfoundry.com/
curl -I https://staging.runartfoundry.com/about/

# Revisar logs
tail -n 100 logs/error_log
```

---

### Caso 2: Rollback de Base de Datos

⚠️ **ADVERTENCIA:** Este procedimiento puede causar pérdida de datos creados tras el deployment.

#### Prerequisitos

- **DB backup:** Backup de base de datos generado antes del deployment
- **Maintenance mode:** Sitio debe estar en mantenimiento
- **Testing validado:** Procedimiento probado en staging

---

#### Paso 1: Activar Maintenance Mode

```bash
ssh ${STAGING_USER}@${STAGING_HOST}
cd /homepages/7/d958591985/htdocs/staging
wp maintenance-mode activate
```

---

#### Paso 2: Descargar DB Dump

```bash
# Si backup está local
scp backups/staging_db_20250129T150840Z.sql.gz \
  ${STAGING_USER}@${STAGING_HOST}:~/db_rollback.sql.gz

# Descomprimir
gunzip ~/db_rollback.sql.gz
```

---

#### Paso 3: Importar DB Backup

```bash
cd /homepages/7/d958591985/htdocs/staging

# Opción A: Usando WP-CLI (recomendado)
wp db import ~/db_rollback.sql

# Opción B: Usando mysql directo
mysql -h <DB_HOST> -u <DB_USER> -p<DB_PASS> <DB_NAME> < ~/db_rollback.sql
```

**Duración estimada:** 2-5 minutos dependiendo de tamaño de DB

---

#### Paso 4: Verificar Integridad

```bash
# Verificar tablas
wp db check

# Verificar opciones críticas
wp option get siteurl
wp option get home
wp option get template
wp option get stylesheet
```

---

#### Paso 5: Desactivar Maintenance Mode

```bash
wp maintenance-mode deactivate
```

---

#### Paso 6: Validación Completa

Repetir todos los smoke tests del deployment original (ver `DEPLOY_ROLLOUT_PLAN.md`)

---

## Validación Post-Rollback

### Checklist de Validación

- [ ] **Tema activo confirmado:** `wp theme list --status=active`
- [ ] **Páginas principales cargan:** Home, About, Contact (HTTP 200)
- [ ] **Polylang funcional:** Cambio de idioma opera correctamente
- [ ] **Formularios operativos:** Contact form, search, etc.
- [ ] **Navegación funcional:** Menús, links internos
- [ ] **Sin errores en logs:** `error_log` limpio de errores críticos
- [ ] **Performance normal:** Response times <2s
- [ ] **Cache limpiado:** CDN/cache plugins invalidados

### Tests Adicionales (Producción)

- [ ] **Google Analytics activo:** Tracking codes presentes
- [ ] **SEO meta tags:** Titles, descriptions correctos
- [ ] **Formularios de conversión:** Payment forms, signup forms
- [ ] **Integrations:** CRM, email marketing, etc.

---

## Troubleshooting

### Problema 1: Backup Corrupto

**Síntoma:** Checksum falla o extracción produce errores

**Solución:**
1. Usar backup anterior disponible
2. Si no hay backups válidos, descargar versión de tema desde Git:
   ```bash
   git archive --format=tar.gz --prefix=runart-base/ main:runart-base > backup_from_git.tar.gz
   ```
3. Realizar rollback manual con archivos de Git

---

### Problema 2: Permisos Insuficientes

**Síntoma:** `Permission denied` durante rsync o tar

**Solución:**
```bash
# Verificar ownership
ssh ${STAGING_USER}@${STAGING_HOST}
ls -la /homepages/7/d958591985/htdocs/staging/wp-content/themes/

# Corregir permisos
chmod -R 755 runart-base/
chown -R ${STAGING_USER}:${STAGING_USER} runart-base/
```

---

### Problema 3: WP-CLI No Disponible

**Síntoma:** `wp: command not found`

**Solución:**
```bash
# Opción A: Usar path absoluto
/usr/local/bin/wp theme activate runart-base

# Opción B: Activar tema vía phpMyAdmin
# UPDATE wp_options SET option_value = 'runart-base' WHERE option_name = 'template';
# UPDATE wp_options SET option_value = 'runart-base' WHERE option_name = 'stylesheet';
```

---

### Problema 4: Rollback Falla pero Sitio Funcional

**Síntoma:** Script reporta error pero sitio parece funcionar

**Acción:**
1. Realizar validación manual completa
2. Revisar logs detallados del script de rollback
3. Si validación manual passed, documentar como "rollback parcialmente exitoso"
4. Investigar causa del error reportado por script

---

### Problema 5: DB Rollback Falla

**Síntoma:** Errores durante importación de DB dump

**Solución:**
1. Verificar espacio en disco: `df -h`
2. Verificar credenciales de DB en `wp-config.php`
3. Intentar importación en partes:
   ```bash
   # Split dump en chunks de 10MB
   split -b 10m db_rollback.sql db_chunk_
   
   # Importar cada chunk
   for chunk in db_chunk_*; do
     wp db query < $chunk
   done
   ```

---

## Post-Mortem

### Documentación Requerida

Tras cualquier rollback, crear issue en GitHub con:

1. **Título:** `[Post-Mortem] Rollback de DEPLOY-YYYY-MM-DD-<target>-<incremento>`
2. **Contexto:**
   - Deployment original (PR, commit, objetivo)
   - Razón del rollback
   - Tipo de rollback ejecutado
3. **Timeline:**
   - Hora de deployment
   - Hora de detección de issue
   - Hora de decisión de rollback
   - Hora de finalización de rollback
4. **Impacto:**
   - Tiempo de downtime
   - Usuarios afectados
   - Funcionalidad impactada
5. **Causa raíz:**
   - Análisis técnico del problema
   - Por qué no se detectó en simulación
6. **Acciones correctivas:**
   - Cambios en proceso
   - Mejoras en scripts
   - Validaciones adicionales
7. **Lessons Learned:**
   - ¿Qué funcionó bien?
   - ¿Qué se puede mejorar?

### Template de Issue

```markdown
## Context
- **Deployment ID:** DEPLOY-YYYY-MM-DD-staging-001
- **PR:** #XX
- **Objetivo:** [descripción breve]
- **Razón de rollback:** [descripción]

## Timeline
- **Deploy started:** YYYY-MM-DD HH:MM UTC
- **Issue detected:** YYYY-MM-DD HH:MM UTC
- **Rollback initiated:** YYYY-MM-DD HH:MM UTC
- **Rollback completed:** YYYY-MM-DD HH:MM UTC
- **Total downtime:** X minutos

## Impact
- **Severity:** [ ] Critical [ ] High [ ] Medium [ ] Low
- **Affected users:** X users / X% traffic
- **Affected functionality:** [lista]

## Root Cause
[Análisis detallado]

## Corrective Actions
- [ ] Acción 1
- [ ] Acción 2
- [ ] Acción 3

## Prevention
- [ ] Cambio en scripts
- [ ] Nueva validación en CI
- [ ] Documentación actualizada

## Lessons Learned
- **What went well:** [lista]
- **What to improve:** [lista]
```

---

## Referencias

- **[DEPLOY_FRAMEWORK.md](./DEPLOY_FRAMEWORK.md):** Documentación completa del framework
- **[DEPLOY_ROLLOUT_PLAN.md](./DEPLOY_ROLLOUT_PLAN.md):** Template de planes de deployment
- **[DEPLOY_FAQ.md](./DEPLOY_FAQ.md):** Preguntas frecuentes

---

**Mantenido por:** RunArt Foundry Team  
**Última revisión:** 2025-01-29  
**Versión:** 1.0.0
