# 📅 Deployment Rollout Plan — Template

> **Uso:** Este documento es un template para planificar deployments autorizados a **staging** o **producción**.  
> **Instrucción:** Copiar este template a un issue de GitHub antes de ejecutar deployment real.

---

## 🎯 Información General

### Deployment ID
- **ID único:** `DEPLOY-YYYY-MM-DD-<target>-<incremento>` (ejemplo: `DEPLOY-2025-01-29-staging-001`)
- **Tipo:** [ ] Staging [ ] Production
- **Fecha planificada:** YYYY-MM-DD
- **Hora planificada (UTC):** HH:MM UTC
- **Duración estimada:** X minutos
- **Responsable:** @username

### Objetivo del Deployment
> Describe brevemente qué se despliega y por qué (ejemplo: "Deploy de RunArt Base v1.2.0 con correcciones de responsividad móvil")

---

## 📦 Cambios a Deployar

### Scope Técnico

- **Branch:** `chore/deploy-framework-full`
- **Commit:** `abc1234`
- **PR:** #XX (link)
- **Tema:** `runart-base`
- **Versión tema:** v1.X.X
- **Archivos modificados:** X archivos
- **Tamaño estimado:** X MB

### Categorías de Cambios

- [ ] Plantillas (templates)
- [ ] Estilos (CSS/SCSS)
- [ ] Scripts (JavaScript)
- [ ] Funciones (functions.php)
- [ ] Media (imágenes/fonts)
- [ ] Configuración (theme.json, etc.)
- [ ] Traducciones (i18n)

### Dependencias

- [ ] Plugins actualizados: [lista]
- [ ] WP Core version: X.X.X
- [ ] PHP version: X.X
- [ ] Cambios en base de datos: [ ] Sí [ ] No

---

## ✅ Pre-Deployment Checklist

### Validación Técnica

- [ ] **Simulación exitosa:** Log de simulación revisado (`DEPLOY_DRYRUN_*.md`)
- [ ] **CI guards passed:** Todos los checks de `.github/workflows/deploy_guard.yml` aprobados
- [ ] **PR aprobado:** Al menos 1 reviewer aprobó cambios
- [ ] **Labels presentes:**
  - [ ] `deployment-approved` (staging)
  - [ ] `maintenance-window` (producción only)
  - [ ] `media-review` (si aplica)

### Backups y Rollback

- [ ] **Backup staging/producción generado:** Path y checksum documentados
- [ ] **Rollback plan documentado:** Ver `DEPLOY_ROLLBACK.md`
- [ ] **Backup retention configurada:** X días
- [ ] **Backup restaurado en testing:** Validado que funciona (producción only)

### Comunicación (Producción Only)

- [ ] **Stakeholders notificados:** Email/Slack enviado con fecha/hora
- [ ] **Maintenance window publicado:** Página de status actualizada
- [ ] **Rollback contact list:** Lista de personas a contactar si hay issues
- [ ] **Post-deployment notification preparada:** Draft de email de éxito

### Entorno y Accesos

- [ ] **SSH key validada:** Acceso a servidor confirmado
- [ ] **Environment variables cargadas:** `source ~/.runart_staging_env`
- [ ] **WP-CLI funcional:** Validado con `wp cli info`
- [ ] **Permisos de escritura:** Directorio `wp-content/themes/runart-base/` writable

---

## 🚀 Deployment Execution Plan

### Fase 1: Preparación (5 min)

```bash
# 1.1 Cargar entorno
source ~/.runart_staging_env

# 1.2 Validar configuración
./tools/staging_env_loader.sh

# 1.3 Verificar estado actual
ssh ${STAGING_USER}@${STAGING_HOST} "cd ${STAGING_WP_PATH} && wp theme list"
```

**Expected Output:**
```
runart-base  active  1.X.X  RunArt Base Theme
```

**Validación:**
- [ ] Entorno cargado correctamente
- [ ] SSH conexión exitosa
- [ ] Tema actual identificado

---

### Fase 2: Backup (3 min)

```bash
# 2.1 Generar backup automático
REAL_DEPLOY=1 TARGET=staging ./tools/deploy/deploy_theme.sh
# (El script genera backup antes de ejecutar cambios)
```

**Expected Output:**
```
[INFO] Generando backup pre-deploy...
[INFO] Backup guardado en: _reports/deploy_logs/backups/staging_20250129T150840Z.tar.gz
[INFO] Checksum: abc123def456...
```

**Validación:**
- [ ] Backup generado exitosamente
- [ ] Checksum verificado
- [ ] Path documentado en reporte

---

### Fase 3: Deployment Real (10 min)

```bash
# 3.1 Ejecutar deployment
READ_ONLY=0 DRY_RUN=0 REAL_DEPLOY=1 TARGET=staging ./tools/deploy/deploy_theme.sh
```

**Expected Output:**
```
[INFO] Modo: REAL DEPLOYMENT a staging
[INFO] Ejecutando rsync...
[INFO] XX archivos copiados, YY bytes transferidos
[INFO] Ejecutando WP-CLI comandos...
[INFO] Tema activado: runart-base
[INFO] Cache limpiado
[SUCCESS] Deployment completado en ZZ segundos
```

**Validación:**
- [ ] Rsync completado sin errores
- [ ] Archivos copiados correctamente
- [ ] WP-CLI comandos ejecutados
- [ ] Sin errores en logs

---

### Fase 4: Smoke Tests (7 min)

```bash
# 4.1 Verificar tema activo
ssh ${STAGING_USER}@${STAGING_HOST} "cd ${STAGING_WP_PATH} && wp theme list --status=active"

# 4.2 Verificar páginas principales
curl -I https://staging.runartfoundry.com/
curl -I https://staging.runartfoundry.com/about/
curl -I https://staging.runartfoundry.com/contact/

# 4.3 Verificar Polylang
curl -I https://staging.runartfoundry.com/es/
```

**Expected Output:**
```
HTTP/2 200 OK
...
```

**Validación:**
- [ ] Tema activo confirmado
- [ ] Home page: 200 OK
- [ ] About page: 200 OK
- [ ] Contact page: 200 OK
- [ ] Polylang ES: 200 OK

---

### Fase 5: Validación Manual (5 min)

**Pasos manuales:**
1. Abrir https://staging.runartfoundry.com en navegador
2. Verificar layout y estilos cargados
3. Probar navegación entre páginas
4. Cambiar idioma (EN ↔ ES)
5. Verificar formularios funcionales
6. Revisar console de navegador (sin errores JS)

**Validación:**
- [ ] Layout correcto
- [ ] Estilos aplicados
- [ ] Navegación funcional
- [ ] i18n funcional
- [ ] Formularios operativos
- [ ] Sin errores en console

---

## 📊 Post-Deployment Validation

### Métricas y Logs

```bash
# Revisar logs de Apache
ssh ${STAGING_USER}@${STAGING_HOST} "tail -n 100 ${STAGING_WP_PATH}/logs/error_log"

# Revisar logs de PHP (si disponible)
ssh ${STAGING_USER}@${STAGING_HOST} "tail -n 100 /var/log/php_errors.log"
```

**Validación:**
- [ ] Sin errores críticos en logs
- [ ] Sin warnings persistentes
- [ ] Response times normales (<2s)

### Documentación

- [ ] **Reporte generado:** `_reports/deploy_logs/DEPLOY_REAL_*.md` creado
- [ ] **Commit de logs:** Logs commiteados a repo
- [ ] **Issue actualizado:** Este issue marcado como completado
- [ ] **Stakeholders notificados:** Email/Slack de éxito enviado (producción only)

---

## 🔄 Rollback Plan (Si Necesario)

### Trigger de Rollback

Ejecutar rollback si:
- Smoke tests fallan
- Errores críticos en logs
- Funcionalidad core rota
- Decisión de stakeholder (producción)

### Procedimiento de Rollback

Ver documento completo: **[DEPLOY_ROLLBACK.md](./DEPLOY_ROLLBACK.md)**

**Comando rápido:**
```bash
./tools/rollback_staging.sh --backup=_reports/deploy_logs/backups/staging_20250129T150840Z.tar.gz
```

**Validación post-rollback:**
- [ ] Tema restaurado a versión previa
- [ ] Smoke tests passed
- [ ] Stakeholders notificados de rollback

---

## 📝 Post-Deployment Report

### Resultados

- **Status final:** [ ] Exitoso [ ] Rollback ejecutado [ ] Parcialmente exitoso
- **Duración real:** X minutos
- **Issues encontrados:** [descripción o "Ninguno"]
- **Acciones correctivas:** [descripción o "No aplicable"]

### Lessons Learned (Producción Only)

- **¿Qué funcionó bien?**
- **¿Qué se puede mejorar?**
- **¿Cambios necesarios en proceso?**

### Next Steps

- [ ] Documentar issues en GitHub
- [ ] Actualizar DEPLOY_FAQ.md si hay preguntas recurrentes
- [ ] Programar post-mortem si hubo issues significativos

---

## 📞 Contactos de Emergencia

### Responsable Principal
- **Nombre:** [Nombre completo]
- **GitHub:** @username
- **Email:** email@example.com
- **Teléfono:** +XX XXX XXX XXX (opcional)

### Backup Contact
- **Nombre:** [Nombre completo]
- **GitHub:** @username
- **Email:** email@example.com

### Escalation (Producción Only)
- **Admin/Owner:** @username
- **Email:** admin@example.com

---

## 🏷️ Metadata

- **Template version:** 1.0.0
- **Created:** YYYY-MM-DD HH:MM UTC
- **Last updated:** YYYY-MM-DD HH:MM UTC
- **Issue link:** #XX
- **PR link:** #YY

---

**✅ Deployment Aprobado por:** @reviewer-username  
**📅 Fecha de Aprobación:** YYYY-MM-DD  
**🔒 Status:** [ ] Planificado [ ] En ejecución [ ] Completado [ ] Rollback
