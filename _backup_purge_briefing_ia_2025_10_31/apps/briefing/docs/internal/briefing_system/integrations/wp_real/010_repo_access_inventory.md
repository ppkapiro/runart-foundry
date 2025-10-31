# 🔧 Inventario de Acceso al Repositorio

**Documento:** `010_repo_access_inventory.md`  
**Objetivo:** Listar recursos Git, workflows, variables y secrets del repositorio.  
**Entrada:** Evidencia `_templates/evidencia_repo_remotes.txt`

---

## 📡 Orígenes (Remotes)

**Status:** 🟡 Pendiente evidencia

### Remotes Esperados

Espera pegar aquí la salida de:
```bash
git remote -v
```

**Remotes capturados:**
```
(será completado con evidencia)
```

### Validación
- [ ] Remotes SSH o HTTPS validadas
- [ ] Permisos de fetch/push confirmados
- [ ] No hay remotes con URLs expuestas de credenciales

---

## 🔒 Branches y Protecciones

**Status:** 🟡 Pendiente verificación

### Main Branch
- **Protected:** (espera confirmación)
- **Require PR reviews:** (espera confirmación)
- **Require passing checks:** (espera confirmación)

### Rama Actual (Fase 7)
- **feat/fase7-wp-connection:** ✅ Preparación inicial completada
- **feat/fase7-verificacion-accesos-y-estado-real:** 🟡 En progreso (actual)

### Otras Ramas Notables
- `feat/fase7-wp-connection` (commits: 3)
- (listar otras si aplica)

---

## ⚙️ Workflows Detectados

Todos en `.github/workflows/`:

### Workflows Verify-* (Prioridad Fase 7)

| Workflow | Cron | Manual | Modo Actual | Archivos |
|----------|------|--------|-----------|----------|
| **verify-home** | Cada 6h | ✅ Sí | placeholder | verify-home.yml |
| **verify-settings** | Cada 24h | ✅ Sí | placeholder | verify-settings.yml |
| **verify-menus** | Cada 12h | ✅ Sí | placeholder | verify-menus.yml |
| **verify-media** | Diario (3h UTC) | ✅ Sí | placeholder | verify-media.yml |

### Otros Workflows
- `briefing_deploy.yml` (MkDocs → Cloudflare Pages)
- `structure-guard.yml` (CI/validación de archivos)
- `pages-prod.yml` (producción)
- (listar otros si existen)

### Status de Enriquecimiento (Fase 7)
- ✅ `verify-home.yml`: Campo `mode=placeholder|real` añadido ✓
- ✅ `verify-settings.yml`: Campo `mode=placeholder|real` añadido ✓
- ✅ `verify-menus.yml`: Campo `mode=placeholder|real` añadido ✓
- ✅ `verify-media.yml`: Campo `mode=placeholder|real` añadido ✓

---

## 📦 Variables de Repositorio (Actions)

**Ubicación:** Settings → Secrets and variables → Actions → **Variables**

### Variables Esperadas para Fase 7

| Variable | Tipo | Valor Actual | Valor Real (Pendiente) | Status |
|----------|------|--------------|----------------------|--------|
| `WP_BASE_URL` | VARIABLE | `placeholder.local` | `https://runalfondry.com` | ⏳ Pending owner |

### Otras Variables Notables
- (listar si existen)

---

## 🔐 Secrets de Repositorio (Actions)

**Ubicación:** Settings → Secrets and variables → Actions → **Secrets**

**⚠️ CRÍTICO:** Estos valores NO aparecen en logs. GitHub los enmascara como `***`.

### Secrets Esperados para Fase 7

| Secret | Tipo | Valor Actual | Valor Real (Pendiente) | Status |
|--------|------|--------------|----------------------|--------|
| `WP_USER` | SECRET | (vacío/placeholder) | `tu-usuario` | ⏳ Pending owner |
| `WP_APP_PASSWORD` | SECRET | (vacío/placeholder) | Application Password | ⏳ Pending owner |

### Otros Secrets
- (listar si existen)

---

## 🎯 Matriz Placeholder vs Real

| Aspecto | Placeholder | Real | Estado Fase 7 |
|--------|-------------|------|---------------|
| **WP_BASE_URL** | `placeholder.local` | `https://runalfondry.com` | ⏳ Pending owner |
| **WP_USER** | `test-user` | `github-actions` | ⏳ Pending owner |
| **WP_APP_PASSWORD** | `dummy-password` | Real Application Password | ⏳ Pending owner |
| **Mode detectado** | `mode=placeholder` | `mode=real` | ✅ Lógica implementada |

---

## ⚠️ Riesgos de Exposición Detectados

### Riesgo Bajo (Verde)
- [ ] Remotes públicos (esperado)
- [ ] URLs públicas en documentación (esperado)

### Riesgo Medio (Amarillo)
- [ ] Secrets en environment variables de workflows (GitHub los enmascara automáticamente)
- [ ] GitHub Actions tiene acceso a secrets (controlado por permisos de runner)

### Riesgo Alto (Rojo)
- ❌ **PROHIBIDO:** Subir wp-config.php con credenciales reales
- ❌ **PROHIBIDO:** Pegar Application Passwords en comentarios de PR/Issues
- ❌ **PROHIBIDO:** Versionarse .env con valores reales
- ❌ **PROHIBIDO:** Incluir logs que muestren credenciales (GitHub los enmascara, pero revisar artifacts)

---

## ✅ Checklist de Validación

### Pre-Conmutación (Antes de Auth=OK)

- [ ] Remotes verificados y funcionando
- [ ] Branches principales protegidas
- [ ] Workflows `verify-*` enriquecidos con `mode=placeholder|real` ✅
- [ ] `WP_BASE_URL` cargada como VARIABLE por el owner (URL pública)
- [ ] `WP_USER` cargada como SECRET por el owner
- [ ] `WP_APP_PASSWORD` cargada como SECRET por el owner
- [ ] NO hay credenciales en git history
- [ ] NO hay .env/.key/.pem versionados
- [ ] Artifacts de workflows sanitizados (sin tokens)

---

## 🔗 Referencias

- Issue #50: `issues/Issue_50_Fase7_Conexion_WordPress_Real.md`
- Documento central: `000_state_snapshot_checklist.md`
- README: `README.md` (en esta carpeta)

---

**Estado:** 🟡 Pendiente evidencias  
**Última actualización:** 2025-10-20  
**Próxima revisión:** Tras recepción de `evidencia_repo_remotes.txt`
