# ❓ Deployment FAQ — Preguntas Frecuentes

> **Propósito:** Respuestas rápidas a preguntas comunes sobre el Deploy Framework de RunArt Base.  
> **Última actualización:** 2025-01-29

---

## 📋 Índice por Categoría

- [General](#general)
- [Seguridad y Permisos](#seguridad-y-permisos)
- [Activación y Flags](#activación-y-flags)
- [CI y Automation](#ci-y-automation)
- [Logs y Debugging](#logs-y-debugging)
- [Backups y Rollback](#backups-y-rollback)
- [Producción](#producción)
- [Troubleshooting](#troubleshooting)

---

## General

### ¿Cuál es la diferencia entre simulación y deployment real?

**Simulación (`DRY_RUN=1`):**
- Rsync con `--dry-run`: muestra qué se copiaría pero NO copia archivos
- WP-CLI comandos se registran en logs pero NO se ejecutan
- No genera backup (no hay cambios reales)
- Útil para: validación previa, CI checks, testing de scripts

**Deployment Real (`REAL_DEPLOY=1`):**
- Genera backup automático antes de iniciar
- Rsync copia archivos realmente al servidor
- WP-CLI comandos se ejecutan en servidor remoto
- Genera reporte completo con archivos modificados

---

### ¿Puedo deployar a producción directamente?

**No.** El script `deploy_theme.sh` bloqueará cualquier deployment a producción si no se cumplen:

1. Label `maintenance-window` en PR
2. Issue con checklist de `DEPLOY_ROLLOUT_PLAN.md` completado
3. Aprobación manual de Admin/Owner

**Razón:** Producción requiere planificación, comunicación a stakeholders, y procedimientos rigurosos.

---

### ¿Por qué solo se puede deployar RunArt Base?

El script valida que `THEME_DIR=runart-base` y aborta si es diferente. Esto es intencional:

- **Canon establecido:** RunArt Base es el tema oficial de producción
- **Child theme policy:** No se permite usar child themes en producción (complejidad, mantenimiento)
- **Governance:** Ver `_reports/TEMA_ACTIVO_STAGING_20251029.md` para detalles

Si necesitas deployar otro tema, actualiza el canon en `docs/deploy/DEPLOY_FRAMEWORK.md` y modifica validación en script.

---

### ¿Cuánto tarda un deployment típico?

**Simulación:** 1-2 minutos  
**Real a Staging:** 5-10 minutos (depende de cantidad de archivos)  
**Real a Producción:** 15-30 minutos (incluye validaciones manuales)

---

## Seguridad y Permisos

### ¿Qué pasa si olvido configurar SSH key?

El script detectará que no hay SSH key configurada y:

1. Si `SKIP_SSH=1` (default para CI): continúa sin validar SSH (solo simulación)
2. Si `SKIP_SSH=0` (deployment real): aborta con mensaje de error indicando cómo configurar key

**Configurar SSH key:**
```bash
# Generar key si no existe
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_ionos -C "deploy@runartfoundry"

# Copiar al servidor
ssh-copy-id -i ~/.ssh/id_rsa_ionos u111876951@access958591985.webspace-data.io

# Validar conexión
ssh -i ~/.ssh/id_rsa_ionos u111876951@access958591985.webspace-data.io "echo 'SSH OK'"
```

---

### ¿Cómo funcionan los permisos de archivos después de deployment?

Rsync preserva permisos de archivos originales. Recomendaciones:

- **Archivos:** `644` (rw-r--r--)
- **Directorios:** `755` (rwxr-xr-x)
- **Scripts PHP:** `644` (no necesitan +x en web server)

Si hay problemas de permisos post-deploy:
```bash
ssh ${STAGING_USER}@${STAGING_HOST}
cd /homepages/7/d958591985/htdocs/staging/wp-content/themes/runart-base
chmod -R 755 .
chown -R ${STAGING_USER}:${STAGING_USER} .
```

---

### ¿Qué labels de GitHub son obligatorios?

**Staging:**
- `deployment-approved`: Obligatorio para `REAL_DEPLOY=1` a staging
- `media-review`: Obligatorio si hay cambios en `wp-content/uploads/`

**Producción:**
- `maintenance-window`: Obligatorio para cualquier deployment (automáticamente bloqueado sin label)
- `deployment-approved`: También requerido
- `media-review`: Si aplica

**Crear labels en GitHub:**
```bash
gh label create deployment-approved --color 00FF00 --description "Deployment autorizado a staging"
gh label create maintenance-window --color FF0000 --description "Window de mantenimiento aprobado"
gh label create media-review --color FFAA00 --description "Cambios en media requieren revisión"
gh label create staging-only --color 0000FF --description "Solo deployar a staging"
```

---

## Activación y Flags

### ¿Cómo activo deployment real a staging?

**Paso 1:** Verifica que tu PR tiene label `deployment-approved`

**Paso 2:** Merge PR a `develop`

**Paso 3:** Ejecuta:
```bash
source ~/.runart_staging_env
READ_ONLY=0 DRY_RUN=0 REAL_DEPLOY=1 TARGET=staging ./tools/deploy/deploy_theme.sh
```

**Validación automática:** El script verifica que:
- `THEME_DIR=runart-base`
- SSH key configurada
- Servidor accesible
- PR tiene labels correctos (si ejecutas desde CI)

---

### ¿Puedo ejecutar deployment desde CI/GitHub Actions?

Sí, pero con limitaciones:

**CI puede ejecutar:**
- Simulaciones (`DRY_RUN=1`) ✅
- Validaciones de políticas ✅
- Generación de logs ✅

**CI NO puede ejecutar:**
- Deployments reales (`REAL_DEPLOY=1`) ❌ (requiere SSH key privada, no seguro en CI)

**Recomendación:** Usa CI para validar, ejecuta deployments reales desde máquina local segura.

---

### ¿Qué hace el flag `ROLLBACK_ON_FAIL`?

Si `ROLLBACK_ON_FAIL=1` (default), el script ejecuta rollback automático si:

- Smoke tests fallan (páginas no responden 200 OK)
- WP-CLI comandos críticos fallan
- Rsync reporta errores

Si `ROLLBACK_ON_FAIL=0`, el script reporta error pero NO revierte cambios. Útil para debugging (inspeccionas estado fallido).

---

### ¿Puedo deployar solo archivos específicos?

El script actual deploya todo el tema `runart-base/`. Para deployar archivos específicos:

**Opción 1: Rsync manual selectivo**
```bash
rsync -avz --dry-run \
  runart-base/style.css \
  runart-base/functions.php \
  ${STAGING_USER}@${STAGING_HOST}:/path/to/themes/runart-base/
```

**Opción 2: Modificar script** (avanzado)
Añade argumento `--files` al script para especificar lista de archivos.

---

## CI y Automation

### ¿Qué valida el CI guard `deploy_guard.yml`?

**Job 1: lint-docs**
- Verifica que `docs/deploy/` tiene todos los archivos requeridos
- Valida sintaxis Markdown
- Revisa enlaces rotos

**Job 2: policy-enforcement**
- Falla si `REAL_DEPLOY=1` sin label `deployment-approved`
- Falla si `TARGET=production` sin label `maintenance-window`
- Valida que `THEME_DIR=runart-base`

**Job 3: simulation**
- Ejecuta `deploy_theme.sh` en modo `DRY_RUN=1`
- Publica logs como artifact
- Reporta archivos que se modificarían

---

### ¿Por qué el CI guard falla en mi PR?

**Error común 1:** `REAL_DEPLOY=1` pero falta label `deployment-approved`

**Solución:** Añade label en GitHub:
```bash
gh pr edit <PR_NUMBER> --add-label deployment-approved
```

---

**Error común 2:** Cambios en `wp-content/uploads/` pero falta label `media-review`

**Solución:** Añade label `media-review` O revierte cambios en media files (deben deployarse separadamente, no vía Git).

---

**Error común 3:** Docs lint falla

**Solución:** Ejecuta localmente:
```bash
npx markdownlint-cli docs/deploy/*.md
```
Corrige errores reportados (enlaces rotos, sintaxis inválida).

---

### ¿Cómo veo los logs de la simulación en CI?

1. Ve a tu PR en GitHub
2. Clicks en "Checks" tab
3. Selecciona workflow `Deploy Guard`
4. Expande job `simulation`
5. Descarga artifact `simulation-logs`

El artifact incluye `DEPLOY_DRYRUN_*.md` con output completo de rsync y validaciones.

---

## Logs y Debugging

### ¿Dónde se guardan los logs de deployment?

**Directorios:**
```
_reports/deploy_logs/
├── DEPLOY_DRYRUN_20250129T143022Z.md      # Simulaciones
├── DEPLOY_REAL_20250129T150845Z.md        # Deployments reales
├── DEPLOY_FRAMEWORK_STATUS_20250129.md    # Status checks
├── backups/                                # Backups pre-deploy
└── rollbacks/                              # Logs de rollback
```

**Versionado:** Logs en `_reports/` se commitean a Git (excepto backups, que son muy grandes).

---

### ¿Qué información contiene un reporte de deployment?

Cada reporte incluye:

1. **Metadata:** Timestamp, usuario, target, modo (simulación/real)
2. **Configuration:** Variables de entorno (READ_ONLY, DRY_RUN, etc.)
3. **Validation:** Checklist de requisitos pre-deploy
4. **Execution Log:** Output completo de rsync y WP-CLI
5. **Results Summary:** Archivos modificados, bytes transferidos, timing
6. **Backup Info:** Path y checksum de backup generado
7. **Smoke Tests:** Resultado de validaciones post-deploy
8. **Next Steps:** Acciones recomendadas

---

### ¿Cómo debugging un deployment fallido?

**Paso 1:** Lee el reporte completo en `_reports/deploy_logs/DEPLOY_REAL_*.md`

**Paso 2:** Identifica sección donde falló (Validation, Rsync, WP-CLI, Smoke Tests)

**Paso 3:** Revisa logs detallados del servidor:
```bash
ssh ${STAGING_USER}@${STAGING_HOST}
cd /homepages/7/d958591985/htdocs/staging
tail -n 200 logs/error_log
```

**Paso 4:** Si es error de rsync, ejecuta manualmente con verbose:
```bash
rsync -avz --verbose --dry-run runart-base/ \
  ${STAGING_USER}@${STAGING_HOST}:/path/to/themes/runart-base/
```

**Paso 5:** Si es error de WP-CLI, ejecuta comando manualmente en servidor:
```bash
ssh ${STAGING_USER}@${STAGING_HOST}
cd /homepages/7/d958591985/htdocs/staging
wp theme list --debug
```

---

### ¿Los backups ocupan mucho espacio?

Depende del tamaño del tema. RunArt Base típico:

- **Sin media:** ~5-10 MB comprimido (.tar.gz)
- **Con media:** ~50-200 MB comprimido

**Retención:** Backups se mantienen por 7 días por defecto (`BACKUP_RETENTION=7`). Limpieza automática cada deployment.

**Limpieza manual:**
```bash
# Eliminar backups más antiguos que 7 días
find _reports/deploy_logs/backups/ -name "*.tar.gz" -mtime +7 -delete
```

---

## Backups y Rollback

### ¿Cuándo se generan backups automáticos?

**Siempre que `REAL_DEPLOY=1`**, antes de copiar archivos:

1. Script conecta vía SSH a servidor
2. Crea tarball de `wp-content/themes/runart-base/`
3. Descarga tarball a `_reports/deploy_logs/backups/`
4. Genera checksum SHA256
5. Valida integridad del backup
6. Solo entonces procede con rsync

Si generación de backup falla, deployment aborta (fail-safe).

---

### ¿Puedo generar backup manualmente?

Sí, usa el script auxiliar:

```bash
./tools/backup_staging.sh --target=staging --output=_reports/deploy_logs/backups/

# Argumentos:
# --target: staging o production
# --output: directorio donde guardar backup
# --name: (opcional) nombre custom para archivo
```

---

### ¿Cómo funciona el rollback automático?

Si `ROLLBACK_ON_FAIL=1` y smoke tests fallan:

1. Script detecta error (exit code ≠ 0)
2. Identifica backup más reciente en `_reports/deploy_logs/backups/`
3. Valida checksum del backup
4. Ejecuta `tools/rollback_staging.sh` automáticamente
5. Restaura archivos desde backup
6. Re-ejecuta smoke tests
7. Genera reporte de rollback en `_reports/deploy_logs/ROLLBACK_*.md`

Todo esto ocurre sin intervención manual (completa en ~2 min).

---

### ¿Puedo rollback manualmente?

Sí, ver procedimientos completos en **[DEPLOY_ROLLBACK.md](./DEPLOY_ROLLBACK.md)**.

**Comando rápido:**
```bash
./tools/rollback_staging.sh \
  --backup=_reports/deploy_logs/backups/staging_20250129T150840Z.tar.gz \
  --target=staging
```

---

### ¿El rollback incluye base de datos?

**No por defecto.** El rollback automático solo restaura archivos de tema.

**Rollback de DB** requiere:
- Backup de DB generado manualmente antes de deployment
- Procedimiento manual (ver `DEPLOY_ROLLBACK.md` sección "Rollback de Base de Datos")
- Poner sitio en maintenance mode durante restore

**Razón:** Rollback de DB puede causar pérdida de datos (contenido creado tras deployment se pierde).

---

## Producción

### ¿Cómo solicito un deployment a producción?

**Paso 1:** Valida que cambios funcionan en staging

**Paso 2:** Crea issue en GitHub usando template `DEPLOY_ROLLOUT_PLAN.md`:
```bash
cp docs/deploy/DEPLOY_ROLLOUT_PLAN.md .github/ISSUE_TEMPLATE/deployment_plan.md
gh issue create --template deployment_plan.md --label maintenance-window
```

**Paso 3:** Completa checklist en el issue (backups, comunicación, rollback plan)

**Paso 4:** Solicita aprobación de Admin/Owner como comentario en issue

**Paso 5:** Admin programa window y ejecuta deployment manual paso a paso

**Duración estimada:** 2-3 días desde solicitud hasta ejecución

---

### ¿Puedo automatizar deployments a producción?

**No recomendado.** Producción requiere:

- Comunicación previa a stakeholders
- Ventana de mantenimiento planificada
- Validación manual paso a paso
- Monitoreo activo durante y post-deploy

Automatizar esto introduce riesgos innecesarios. Mejor: automatiza staging, mantén producción manual.

---

### ¿Qué pasa si el deployment a producción falla?

**Paso 1:** No pánico. Rollback está disponible.

**Paso 2:** Admin ejecuta rollback siguiendo `DEPLOY_ROLLBACK.md`

**Paso 3:** Valida que producción vuelve a estado funcional

**Paso 4:** Comunica incidente a stakeholders

**Paso 5:** Crea post-mortem issue (ver template en `DEPLOY_ROLLBACK.md`)

**Paso 6:** Investiga causa raíz y aplica correcciones

**Paso 7:** Reprograma deployment tras corrección

---

## Troubleshooting

### Error: "SSH key not found"

**Causa:** Variable `SSH_KEY_PATH` no apunta a key válida.

**Solución:**
```bash
# Verificar path
echo $SSH_KEY_PATH
ls -la $SSH_KEY_PATH

# Si no existe, generar
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_ionos

# Actualizar env file
echo "export SSH_KEY_PATH=$HOME/.ssh/id_rsa_ionos" >> ~/.runart_staging_env
```

---

### Error: "Permission denied (publickey)"

**Causa:** SSH key no está en servidor remoto.

**Solución:**
```bash
# Copiar key al servidor
ssh-copy-id -i ~/.ssh/id_rsa_ionos u111876951@access958591985.webspace-data.io

# Validar
ssh -i ~/.ssh/id_rsa_ionos u111876951@access958591985.webspace-data.io "echo 'OK'"
```

---

### Error: "THEME_DIR must be runart-base"

**Causa:** Intentando deployar tema diferente.

**Solución:** Solo RunArt Base está permitido. Si necesitas deployar otro tema:

1. Actualiza canon en `docs/deploy/DEPLOY_FRAMEWORK.md`
2. Modifica validación en `tools/deploy/deploy_theme.sh`
3. Crea PR con justificación
4. Solicita aprobación de Admin

---

### Error: "Target must be staging when REAL_DEPLOY=1"

**Causa:** Intentando deployment real a producción sin seguir procedimiento.

**Solución:** Producción requiere:
1. Label `maintenance-window` en PR
2. Issue con `DEPLOY_ROLLOUT_PLAN.md` completado
3. Deployment manual por Admin

No hay workaround (intencional para proteger producción).

---

### Error: "rsync: failed to set times"

**Causa:** Permisos insuficientes en servidor.

**Solución:**
```bash
# Verificar ownership
ssh ${STAGING_USER}@${STAGING_HOST}
ls -la /homepages/7/d958591985/htdocs/staging/wp-content/themes/

# Corregir
chown -R ${STAGING_USER}:${STAGING_USER} runart-base/
```

---

### Error: "wp: command not found"

**Causa:** WP-CLI no disponible o no en PATH.

**Solución:**
```bash
# Intentar path absoluto
ssh ${STAGING_USER}@${STAGING_HOST} "which wp"
# Output: /usr/local/bin/wp

# Actualizar script para usar path absoluto
# O instalar WP-CLI si no existe:
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
```

---

## ¿No encuentras tu pregunta?

**Crea issue en GitHub:**
```bash
gh issue create \
  --title "[FAQ] ¿Cómo...?" \
  --body "Descripción de tu pregunta..." \
  --label documentation
```

O contacta al equipo: [Crear issue](https://github.com/RunArtFoundry/runart-foundry/issues/new)

---

**Última actualización:** 2025-01-29  
**Mantenido por:** RunArt Foundry Team  
**Versión:** 1.0.0
