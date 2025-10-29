# CI Freeze Policy — RunArt Foundry

**Fecha:** 2025-10-29  
**Versión:** 1.0  
**Estado:** ✅ Activo

---

## 📋 Resumen Ejecutivo

Política de congelación operacional para prevenir deployments accidentales y proteger el entorno de staging mediante guardas automatizadas en CI.

**Principios:**
1. Scripts en modo seguro por defecto (`READ_ONLY=1`, `DRY_RUN=1`)
2. Validación automática en PRs (main/develop)
3. Protección de biblioteca de medios
4. Trazabilidad de operaciones

---

## 🔒 Operación Congelada (Freeze Mode)

### Flags de Seguridad

| Flag | Default | Descripción | Ubicación |
|------|---------|-------------|-----------|
| `READ_ONLY` | `1` | Deshabilita operaciones mutadoras | `tools/staging_env_loader.sh`, `tools/deploy_wp_ssh.sh` |
| `DRY_RUN` | `1` | rsync con `--dry-run`, sin cambios reales | `tools/deploy_wp_ssh.sh` |
| `SKIP_SSH` | `1` | Omite comprobaciones SSH (para CI/docs) | `tools/staging_env_loader.sh` |

### Operaciones Deshabilitadas con READ_ONLY=1

- ✅ Backup remoto de tema
- ✅ rsync efectivo (se usa `--dry-run`)
- ✅ `wp rewrite flush`
- ✅ `wp cache flush`
- ✅ Publicación de páginas (`wp post update`)
- ✅ Comandos SSH que modifiquen archivos

### Operaciones Permitidas

- ✅ Lectura de estado (HTTP, WP-CLI read-only)
- ✅ Smoke tests (solo verificación)
- ✅ Generación de reportes locales
- ✅ Validación de estructura y lint

---

## 🛡️ CI Guardrails

### 1. Dry-run Guard

**Workflow:** `.github/workflows/guard-deploy-readonly.yml`  
**Job:** `dryrun-guard`

**Validaciones:**
```yaml
- Verifica existencia de tools/deploy_wp_ssh.sh
- Busca marcador: "CI-GUARD: DRY-RUN-CAPABLE"
- Valida defaults:
  - READ_ONLY=${READ_ONLY:-1}
  - DRY_RUN=${DRY_RUN:-1}
```

**Resultado esperado:** ✅ PASS si todas las validaciones OK

**Falla si:**
- ❌ Falta marcador CI-GUARD
- ❌ Defaults cambiados a 0 sin justificación
- ❌ Script eliminado o renombrado

**Ejemplo de output:**
```bash
OK: deploy_wp_ssh.sh defaults detected
✓ CI-GUARD marker found
✓ READ_ONLY=${READ_ONLY:-1} found
✓ DRY_RUN=${DRY_RUN:-1} found
```

---

### 2. Media Review Guard

**Workflow:** `.github/workflows/guard-deploy-readonly.yml`  
**Job:** `media-guard`

**Objetivo:** Proteger biblioteca de medios de cambios no revisados

**Rutas vigiladas:**
- `wp-content/uploads/`
- `runmedia/`
- `content/media/`

**Lógica:**
```javascript
const mediaPatterns = [
  /^wp-content\/uploads\//,
  /^runmedia\//,
  /^content\/media\//
];

const touchesMedia = files.some(f => 
  mediaPatterns.some(r => r.test(f.filename))
);

const hasLabel = pr.labels.some(l => 
  l.name.toLowerCase() === 'media-review'
);

if (touchesMedia && !hasLabel) {
  core.setFailed('Requiere etiqueta "media-review"');
}
```

**Resultado esperado:** ✅ PASS si:
- PR no toca media, O
- PR toca media Y tiene label `media-review`

**Falla si:**
- ❌ PR modifica media sin label
- ❌ Label escrito incorrectamente (case-sensitive después de lowercase)

**Cómo aprobar un PR con cambios en media:**
1. Revisar cambios en archivos de media
2. Añadir etiqueta `media-review` al PR
3. Re-ejecutar workflow si ya falló

---

### 3. Structure Guard (Existente)

**Workflow:** `.github/workflows/structure-guard.yml`

**Validaciones:**
- Estructura de directorios conforme a `docs/_meta/governance.md`
- Archivos en ubicaciones permitidas
- Sin rutas prohibidas (ej: docs fuera de docs/)

**Resultado esperado:** ✅ PASS si estructura OK

---

## 📊 Matriz de Validación CI

| Check | Workflow | Trigger | Bloqueante | Descripción |
|-------|----------|---------|------------|-------------|
| Dry-run Guard | guard-deploy-readonly.yml | PR, push | ✅ Sí | Verifica defaults READ_ONLY/DRY_RUN |
| Media Guard | guard-deploy-readonly.yml | PR | ✅ Sí | Exige label media-review |
| Structure Guard | structure-guard.yml | PR, push | ✅ Sí | Valida estructura docs |
| Docs Lint | docs-lint.yml | PR, push | ✅ Sí | Lint estricto de markdown |
| Status Update | status-update.yml | PR | ⚠️ Soft | Actualiza STATUS.md |

---

## 🚀 Desactivar Freeze (Deployment Aprobado)

### Requisitos Previos

1. ✅ Issue aprobado con ventana de mantenimiento
2. ✅ SSH key configurado en servidor
3. ✅ Backup verificado
4. ✅ Smoke tests OK en staging
5. ✅ Sign-off del owner técnico

### Procedimiento

```bash
# 1. Cargar entorno con flags desactivados
export READ_ONLY=0
export DRY_RUN=0
source tools/staging_env_loader.sh

# 2. Verificar estado antes de deployment
./tools/deploy_wp_ssh.sh staging

# 3. Ejecutar deployment real
READ_ONLY=0 DRY_RUN=0 ./tools/deploy_wp_ssh.sh staging

# 4. Smoke tests post-deployment
curl -I https://staging.runartfoundry.com/en/home/
curl -I https://staging.runartfoundry.com/es/inicio/

# 5. Reactivar freeze
export READ_ONLY=1
export DRY_RUN=1
```

### Documentación Post-Deployment

Crear reporte en `_reports/DEPLOYMENT_YYYYMMDD_HHMMSS.md` con:
- Timestamp y duración
- Issue de aprobación
- Cambios ejecutados
- Smoke tests resultados
- Rollback plan si aplica

---

## 📝 Bypass Temporal (Solo Emergencias)

**⚠️ USAR SOLO EN EMERGENCIAS CRÍTICAS**

### Autorización Requerida

- Owner técnico del proyecto
- Documentación del incidente
- Issue de emergencia creado

### Procedimiento

```bash
# Bypass temporal (máximo 1 hora)
EMERGENCY_BYPASS=1 READ_ONLY=0 DRY_RUN=0 ./tools/deploy_wp_ssh.sh staging

# Documentar inmediatamente
cat > _reports/EMERGENCY_BYPASS_$(date +%Y%m%d_%H%M%S).md << 'EOF'
# Emergency Bypass

- Timestamp: $(date -u +%FT%TZ)
- Razón: [DESCRIBIR EMERGENCIA]
- Autorizado por: [NOMBRE + CARGO]
- Issue: #XXX
- Acciones ejecutadas: [LISTAR]
- Rollback plan: [DESCRIBIR]
EOF

# Reactivar freeze inmediatamente
export READ_ONLY=1
export DRY_RUN=1
```

---

## 🔍 Auditoría y Monitoreo

### Logs de CI

Todos los workflows generan logs en GitHub Actions:
- URL: https://github.com/RunArtFoundry/runart-foundry/actions
- Retención: 90 días
- Acceso: miembros del repositorio

### Reportes Locales

Scripts generan reportes en `_reports/`:
- `WP_SSH_DEPLOY_LOG.json` (JSON estructurado)
- `WP_SSH_DEPLOY.md` (resumen legible)
- `SMOKE_STAGING.md` (smoke tests)

### Alertas

- ❌ CI falla → notificación automática en PR
- ❌ Deployment falla → log en `_reports/` + issue automático (futuro)

---

## 📚 Referencias

- **Deployment Master:** `docs/Deployment_Master.md`
- **Governance:** `docs/_meta/governance.md`
- **Canon del Tema:** `_reports/TEMA_ACTIVO_STAGING_20251029.md`
- **Normalización:** `_reports/REFERENCIAS_TEMA_CORREGIDAS_20251029.md`

---

## 🔄 Historial de Cambios

| Versión | Fecha | Cambios | Autor |
|---------|-------|---------|-------|
| 1.0 | 2025-10-29 | Creación inicial, freeze policy, guardas CI | GitHub Copilot + Equipo Técnico |

---

## ✅ Criterio de Éxito

- [x] Flags de seguridad documentados
- [x] CI guardrails implementados y probados
- [x] Procedimiento de desactivación claro
- [x] Bypass de emergencia controlado
- [x] Auditoría y logs establecidos

---

**🎯 Esta política es obligatoria para todos los PRs a main/develop y debe cumplirse estrictamente. Solo el owner técnico puede autorizar bypasses de emergencia con documentación completa.**
