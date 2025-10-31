# 🚀 Plan de Staging/Preview — Opción 2 (Recomendada)

**Título:** Plan operativo para validación de Fase 7 en entorno staging antes de producción  
**Status:** 🟡 **PENDING SETUP** (Owner prepara staging)  
**Fecha:** 2025-10-20  
**Responsables:** Owner (setup), Copilot (validación)

---

## 📌 Objetivo

Crear un entorno de staging paralelo a producción para validar **todos** los workflows `verify-*` con credenciales reales, **sin exponer producción a riesgos técnicos** hasta que se confirme que todo funciona.

**Beneficios:**
- ✅ Valida código (`verify-*`) contra WordPress real
- ✅ Pruebas de autenticación sin afectar producción
- ✅ Fácil rollback si algo falla
- ✅ Confianza antes de producción

---

## 🎯 Requisitos Previos

### Owner debe preparar:

1. **Subdominio o máquina staging**
   - Hostname: `<staging-hostname>` (ej: `staging.runalfondry.com` o `preview.runalfondry.com`)
   - DNS apuntando correctamente
   - SSL/HTTPS válido (auto-renovable, ej: Let's Encrypt)

2. **Base de datos fresca**
   - Backup reciente de prod (no > 7 días)
   - Importar en staging
   - Verificar que WP se levanta sin errores

3. **Archivos WordPress**
   - Copia de `wp-content/` desde prod (especialmente uploads, temas, plugins)
   - Verificar permisos (propietario del web server)

4. **WordPress Funcionando**
   - Acceso `https://<staging-hostname>` en navegador
   - WP-Admin accesible (`/wp-admin/login.php`)
   - REST API disponible (`/wp-json/` responde 200/401)

5. **Credenciales de Staging**
   - Usuario técnico para GitHub Actions (ej: `github-actions`)
   - Generar Application Password en WP-Admin → Settings → Application Passwords
   - Guardar localmente (NO en git, NO en comentarios)

---

## 📋 Checklist de Setup

### Fase 1: Infraestructura (Owner)

- [ ] Subdominio staging registrado y DNS configurado
- [ ] SSL/HTTPS válido (`curl -i https://<staging-hostname>/` → HTTP 200)
- [ ] WordPress instalado en staging
- [ ] BD importada desde prod
- [ ] `wp-content/` replicado (uploads, temas, plugins)
- [ ] Permisos de archivos correctos (`wp-content/` escribible por web server)

**Validación:**
```bash
# Desde staging servidor:
curl -i https://<staging-hostname>/wp-json/
# Esperar: HTTP 200 OK o 401 Unauthorized (no 404)
```

### Fase 2: Credenciales (Owner)

- [ ] Usuario `github-actions` creado en WP-staging
- [ ] Application Password generada en WP-Admin
- [ ] Password guardada localmente (ej: `~/.wp-secrets/staging-app-password.txt`)
- [ ] Confirmar que la app password permite lectura de `/wp-json/wp/v2/users/me`

**Validación (local, SIN GitHub aún):**
```bash
# Desde tu máquina local:
curl -u github-actions:<app-password> \
  -i https://<staging-hostname>/wp-json/wp/v2/users/me
# Esperar: HTTP 200 OK
```

### Fase 3: Variables/Secrets en GitHub (Owner)

**IMPORTANTE:** Configurar TEMPORALMENTE apuntando a staging. Post-validación cambiaremos a prod.

```bash
# Desde tu máquina local (requiere GitHub CLI):

# 1. Set WP_BASE_URL (apuntando a STAGING temporalmente)
gh variable set WP_BASE_URL \
  --body "https://<staging-hostname>"

# 2. Set WP_USER (usuario técnico en staging)
gh secret set WP_USER \
  --body "github-actions"

# 3. Set WP_APP_PASSWORD (copiar del archivo local)
gh secret set WP_APP_PASSWORD \
  --body "<app-password-staging>"
```

**Validación:**
```bash
# Listar variables (verificar)
gh variable list | grep WP_BASE_URL

# Listar secrets (será enmascarado)
gh secret list | grep WP_
```

---

## 🔄 Flujo de Validación (Staging)

### Step 1: verify-home (Staging)

**Acción:** Ejecutar workflow manualmente contra staging

```bash
# En GitHub Actions UI:
# 1. Ir a: repo → Actions → verify-home
# 2. Click "Run workflow"
# 3. Esperar a que complete
# 4. Revisar logs y artifacts
```

**Validación esperada:**
- Status: ✅ Success
- Log: `mode=real; Auth=OK; FrontES/EN=200; Compliance=OK`
- Artifact: `verify-home_summary.txt` adjunted

**Resultado:**
- ✅ Si OK → Proceder a verify-settings
- ❌ Si FAIL → Revisar logs, corregir, reintentar

### Step 2: verify-settings (Staging)

```bash
# En GitHub Actions UI: repo → Actions → verify-settings → Run workflow
```

**Validación esperada:**
- Status: ✅ Success
- Log: `mode=real; Auth=OK; Compliance=OK`

**Resultado:**
- ✅ Si OK → Proceder a verify-menus
- ❌ Si FAIL → Revisar, corregir, reintentar

### Step 3: verify-menus (Staging)

```bash
# En GitHub Actions UI: repo → Actions → verify-menus → Run workflow
```

**Validación esperada:**
- Status: ✅ Success (o ⚠️ si no hay plugin)
- Log: `mode=real; Auth=OK`

**Resultado:**
- ✅ Si OK → Proceder a verify-media
- ⚠️ Si N/A (plugin no instalado) → OK, continuar

### Step 4: verify-media (Staging)

```bash
# En GitHub Actions UI: repo → Actions → verify-media → Run workflow
```

**Validación esperada:**
- Status: ✅ Success
- Log: `mode=real; Auth=OK; MISSING=0 o bajo`

**Resultado:**
- ✅ Si OK → **Staging VALIDADO**, proceder a producción
- ❌ Si FAIL → Revisar, corregir, reintentar

---

## 📊 Adjuntar Artifacts en Issue #50

**Acción:** Copiar los `*_summary.txt` artifacts y adjuntarlos en Issue #50

**Ubicación en GitHub:**
- repo → Actions → [workflow name] → [latest run] → Artifacts

**Qué incluir en Issue #50:**
```markdown
### ✅ Validación Staging (Fase 7)

**Hostname:** https://<staging-hostname>
**Fecha:** 2025-10-20
**Status:** Todos pasaron ✅

#### Artifacts:
- verify-home_summary.txt: Auth=OK, FrontES/EN=200
- verify-settings_summary.txt: Auth=OK, Compliance=OK
- verify-menus_summary.txt: Auth=OK
- verify-media_summary.txt: Auth=OK, MISSING=0
```

---

## 🔄 Transición a Producción

### Step 1: Cambiar Variables (Owner)

Una vez validado en staging:

```bash
# Actualizar WP_BASE_URL a PRODUCCIÓN
gh variable set WP_BASE_URL \
  --body "https://runalfondry.com"

# Crear Application Password en WP PROD
# (en WP-Admin de runalfondry.com)

# Actualizar WP_APP_PASSWORD a la de PROD
gh secret set WP_APP_PASSWORD \
  --body "<app-password-prod>"
```

### Step 2: Validar Producción (Copilot)

```bash
# En GitHub Actions UI: repo → Actions → verify-home → Run workflow
# (Automáticamente ejecutará contra prod ahora)
```

**Validación esperada:**
- Status: ✅ Success
- Log: `mode=real; Auth=OK; FrontES/EN=200; Compliance=OK`

### Step 3: Ejecutar Workflows Completos (Copilot)

Secuencialmente:
1. verify-home (prod)
2. verify-settings (prod)
3. verify-menus (prod)
4. verify-media (prod)

**Todos con resultado ✅ esperado**

### Step 4: Adjuntar Artifacts Finales (Copilot)

En Issue #50, sección "Validación Producción (Fase 7)":
```markdown
### ✅ Validación Producción (Fase 7 — Final)

**Hostname:** https://runalfondry.com
**Fecha:** 2025-10-20
**Status:** Todos pasaron ✅

#### Artifacts:
- verify-home_summary.txt: Auth=OK, FrontES/EN=200
- verify-settings_summary.txt: Auth=OK, Compliance=OK
- verify-menus_summary.txt: Auth=OK
- verify-media_summary.txt: Auth=OK, MISSING=0
```

---

## 🚨 Rollback Plan

**Si algo falla en cualquier punto:**

### Opción A: Revertir a Staging
```bash
# Cambiar WP_BASE_URL back a staging
gh variable set WP_BASE_URL \
  --body "https://<staging-hostname>"

# Cambiar WP_APP_PASSWORD back a staging
gh secret set WP_APP_PASSWORD \
  --body "<app-password-staging>"

# Reintentar workflow
```

### Opción B: Revertir a Placeholder (Nuclear)
```bash
# Si hay riesgos críticos no resueltos:
gh variable set WP_BASE_URL \
  --body "placeholder.local"

# Workflows volverán a modo placeholder (estable)
# Permite investigación sin presión
```

---

## ⏰ Timeline Estimado

| Fase | Responsable | Duración | Hito |
|------|-------------|----------|------|
| Setup infraestructura | Owner | 2-3 horas | Staging respondiendo HTTPS |
| Preparar credenciales | Owner | 30 min | App Password creada y guardada |
| Carga a GitHub | Owner | 15 min | Variables/Secrets en GitHub |
| Validar staging (4 workflows) | Copilot | 20 min | Todos con Auth=OK |
| Adjuntar artifacts staging | Copilot | 15 min | En Issue #50 |
| Cambiar a producción | Owner | 15 min | Variables actualizadas |
| Validar producción (4 workflows) | Copilot | 20 min | Todos con Auth=OK |
| Adjuntar artifacts finales | Copilot | 15 min | En Issue #50 |
| **TOTAL** | | **~4-5 horas** | **Fase 7 ✅** |

---

## 📞 Troubleshooting

### Problema: `/wp-json/` devuelve 404
**Causa posible:** REST API deshabilitada en WordPress
**Solución:**
1. WP-Admin → Settings → (check REST API enabled)
2. O verificar en `wp-config.php` que no está definido `define( 'REST_API_ENABLED', false );`
3. Reintentar

### Problema: `verify-home` falla con Auth=KO
**Causa posible:** WP_USER o WP_APP_PASSWORD incorrectos
**Solución:**
1. Confirmar usuario existe en WP: `wp user list --role=all`
2. Confirmar Application Password: WP-Admin → Settings → Application Passwords
3. Revisar WP_APP_PASSWORD exactamente: sin espacios, caracteres especiales
4. Reintentar

### Problema: SSL certificate error (HTTPS)
**Causa posible:** Certificado autofirmado o expirado
**Solución:**
1. Verificar `curl -I https://<staging-hostname>` directamente
2. Si Let's Encrypt: Renovar certificado
3. Si autofirmado: Reemplazar con válido (Let's Encrypt gratis)
4. Reintentar

### Problema: Staging BD "congelada" (datos outdated)
**Causa posible:** BD importada hace > 7 días
**Solución:**
1. Hacer dump fresco de prod
2. Importar en staging nuevamente
3. Reintentar validación

---

## 📋 Checklist Final

- [ ] Staging infraestructura OK (HTTPS, WordPress, BD, archivos)
- [ ] Credenciales staging guardadas localmente
- [ ] Variables/Secrets en GitHub apuntando a staging
- [ ] verify-* (todos 4) con Auth=OK en staging
- [ ] Artifacts adjuntos en Issue #50 (staging)
- [ ] Variables/Secrets cambiados a producción
- [ ] verify-* (todos 4) con Auth=OK en producción
- [ ] Artifacts adjuntos en Issue #50 (producción)
- [ ] ✅ **Fase 7 COMPLETADA**

---

**Estado:** 🟡 PENDING OWNER SETUP  
**Próxima acción:** Owner prepara staging (siguiendo pasos arriba)  
**Última actualización:** 2025-10-20 14:40 UTC

---

## 🔗 Referencias

- ADR: `050_decision_record_styling_vs_preview.md`
- Checklist central: `000_state_snapshot_checklist.md`
- Issue #50: `issues/Issue_50_Fase7_Conexion_WordPress_Real.md`
- Reportes: `_reports/PROXIMOS_PASOS_FASE7_ESPERA_ACTIVA_20251020.md`

