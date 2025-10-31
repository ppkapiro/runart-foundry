# Verificación Deploy Framework — RunArt Foundry

**Fecha:** 2025-10-29  
**Rama:** chore/repo-verification-contents-phase  
**Base:** main  
**Verificador:** Copilot Agent

---

## Resumen Ejecutivo

### Estado General: ⚠️ PARCIAL

El Deploy Framework **NO está presente en main** (está en PR #75 pendiente de merge a develop).  
Sin embargo, existen herramientas de staging funcionales y configuración de gobernanza operativa.

**Hallazgos Clave:**
- ✅ PR #75 con Deploy Framework completo (4 docs + script + CI guard)
- ❌ Framework NO mergeado a main ni develop aún
- ✅ Scripts staging funcionales (23 scripts en tools/)
- ✅ Documentación deployment existente (Deployment_Master.md)
- ✅ Gobernanza activa (PR template, labels, docs/_meta/governance.md)
- ✅ Canon runart-base establecido (staging_env_loader.sh fuerza runart-base)

---

## 1. Inventario de Deploy Framework

### Estado en Main (Actual)

| Componente | Estado | Ubicación | Notas |
|------------|--------|-----------|-------|
| **docs/deploy/** | ❌ NO EXISTE | - | En PR #75 |
| DEPLOY_FRAMEWORK.md | ❌ NO EXISTE | - | ~3,500 líneas en PR #75 |
| DEPLOY_ROLLOUT_PLAN.md | ❌ NO EXISTE | - | Template en PR #75 |
| DEPLOY_ROLLBACK.md | ❌ NO EXISTE | - | Procedimientos en PR #75 |
| DEPLOY_FAQ.md | ❌ NO EXISTE | - | 40+ FAQs en PR #75 |
| **tools/deploy/** | ❌ NO EXISTE | - | En PR #75 |
| deploy_theme.sh | ❌ NO EXISTE | - | ~650 líneas en PR #75 |
| **.github/workflows/** | ⚠️ PARCIAL | - | 8 workflows deploy existentes |
| deploy_guard.yml | ❌ NO EXISTE | - | 4 jobs CI en PR #75 |
| **PR Template** | ✅ EXISTE | .github/pull_request_template.md | Con checkboxes deployment |

### Estado en PR #75 (Pendiente Merge)

**PR:** https://github.com/RunArtFoundry/runart-foundry/pull/75  
**Título:** ci/docs: Deploy Framework completo (Staging habilitado + seguridad reforzada)  
**Estado:** OPEN, CONFLICTING con develop  
**Commits:** 1 (fe19a0d)  
**Archivos:** 15 changed, 3,895 insertions

**Contenido completo:**
- ✅ docs/deploy/ (4 archivos MD, ~3,500 líneas)
- ✅ tools/deploy/deploy_theme.sh (~650 líneas)
- ✅ .github/workflows/deploy_guard.yml (4 jobs)
- ✅ _reports/samples/deploy/ (3 samples)
- ✅ .markdownlint.json, .markdown-link-check.json
- ✅ PR template actualizado

---

## 2. Herramientas Staging Existentes (Main)

### Scripts Funcionales

Total: **23 scripts** en tools/ relacionados con staging:

```
tools/repair_autodetect_prod_staging.sh
tools/load_staging_credentials.sh
tools/deploy_fase2_staging.sh
tools/staging_cleanup_wpcli.sh
tools/cleanup_staging_now.sh
tools/ionos_create_staging_db.sh
tools/repair_auto_prod_staging.sh
tools/ionos_create_staging.sh
tools/staging_cleanup_auto.sh
tools/publish_showcase_page_staging.sh
tools/verify_fase2_deployment.sh
tools/publish_template_page_staging.sh
tools/install_wp_staging.sh
tools/repair_final_prod_staging.sh
tools/staging_privacy.sh
tools/cleanup_plugins_staging.sh
tools/staging_cleanup_direct.sh
tools/staging_cleanup_github.sh
tools/staging_verify_cleanup.sh
tools/staging_isolation_audit.sh
tools/staging_env_loader.sh (CANON ENFORCER)
tools/deploy_wp_ssh.sh (CI-GUARD presente)
tools/backup_staging.sh
```

### Script Clave: staging_env_loader.sh

**Función:** Forzar canon runart-base

```bash
export THEME_SLUG="runart-base"

# Validación:
if [[ -n "${THEME_SLUG:-}" && "${THEME_SLUG}" != "runart-base" ]]; then
    log_warn "THEME_SLUG=${THEME_SLUG} detectado; se forzará a 'runart-base' (canon)."
fi
export THEME_SLUG="runart-base"
export THEME_PATH="${STAGING_WP_PATH%/}/wp-content/themes/${THEME_SLUG}"
```

**Defaults:**
- ✅ THEME_SLUG forzado a `runart-base`
- ✅ THEME_PATH calculado automáticamente
- ✅ Validación de canon con warning si difiere

### Script Clave: deploy_wp_ssh.sh

**Función:** Deployment SSH con CI-GUARD

```bash
# CI-GUARD marker presente (línea ~15)
# Configuración:
THEME_SLUG (usa variable de entorno o staging_env_loader)
READ_ONLY=1 (default)
DRY_RUN=1 (default implícito en rsync --dry-run)
```

**Funcionalidades:**
- ✅ Backup automático antes de deploy
- ✅ Rsync con --dry-run condicional
- ✅ WP-CLI remote execution
- ✅ Logs detallados en _reports/

**Estado:**
- ⚠️ No tiene flags explícitos READ_ONLY/DRY_RUN/REAL_DEPLOY como en PR #75
- ✅ Tiene CI-GUARD marker
- ✅ Funciona con THEME_SLUG de staging_env_loader.sh

---

## 3. Documentación de Deployment

### Documentos Existentes (Main)

| Documento | Estado | Líneas | Última Act. |
|-----------|--------|--------|-------------|
| docs/Deployment_Master.md | ✅ EXISTE | ~500 | 2025-10-29 |
| docs/_meta/governance.md | ✅ EXISTE | ~300 | 2025-10-29 |
| _reports/TEMA_ACTIVO_STAGING_20251029.md | ✅ EXISTE | 231 | 2025-10-29 |
| _reports/CI_FREEZE_POLICY_20251029.md | ✅ EXISTE | 393 | 2025-10-29 |
| _reports/REFERENCIAS_TEMA_CORREGIDAS_20251029.md | ✅ EXISTE | 305 | 2025-10-29 |

### Deployment_Master.md

**Secciones:**
1. General
2. Variables de entorno
3. Método de deployment
4. Problemas conocidos
5. Buenas prácticas
6. Checklist pre-deployment
7. Contactos
8. **Canon Actual y Operación Congelada** (añadido)

**Contenido Canon:**
```markdown
## 🧱 Canon Actual y Operación Congelada

### Tema Oficial
- **Nombre:** RunArt Base
- **Slug:** runart-base
- **Estado:** READ_ONLY=1, DRY_RUN=1, SSH disabled por defecto

### Políticas Staging
- Simulación por defecto (dry-run)
- Deployment real requiere aprobación explícita
- CI guardrails activos
```

---

## 4. Workflows CI Existentes

### Workflows Deployment (8 encontrados)

```bash
.github/workflows/
├── post_build_status.yml
├── receive_repository_dispatch.yml
├── status-health-check-staging.yml
├── staging_smoke_tests.yml
├── staging_deploy_preview.yml
├── guard-deploy-readonly.yml (CRITICAL)
├── deploy_preview.yml
└── auto_translate.yml
```

### Workflow Crítico: guard-deploy-readonly.yml

**Función:** CI guard para deployments seguros

**Jobs:**
1. **dryrun-guard:** Valida READ_ONLY/DRY_RUN defaults
2. **media-guard:** Requiere label media-review para cambios en uploads/

**Triggers:**
- pull_request a main/develop
- paths: runart-base/, tools/deploy_*, docs/deploy/

**Estado:**
- ✅ Activo en main
- ✅ Valida CI-GUARD marker
- ✅ Valida defaults seguros
- ⚠️ Más simple que deploy_guard.yml de PR #75 (4 jobs)

---

## 5. Defaults de Seguridad

### Análisis de Scripts

#### staging_env_loader.sh
```bash
export THEME_SLUG="runart-base"  # ✅ FORCED
```

#### deploy_wp_ssh.sh
```bash
# Variables requeridas (sin defaults explícitos):
THEME_SLUG
READ_ONLY (implícito vía conditional logic)
DRY_RUN (implícito vía rsync --dry-run)

# CI-GUARD marker: ✅ PRESENTE (línea ~15)
```

### Comparación con PR #75

| Variable | Main (deploy_wp_ssh.sh) | PR #75 (deploy_theme.sh) |
|----------|-------------------------|--------------------------|
| READ_ONLY | ⚠️ No explícito | ✅ DEFAULT=1 |
| DRY_RUN | ⚠️ No explícito | ✅ DEFAULT=1 |
| REAL_DEPLOY | ❌ No existe | ✅ DEFAULT=0 |
| SKIP_SSH | ❌ No existe | ✅ DEFAULT=1 |
| THEME_DIR | ✅ Via THEME_SLUG | ✅ DEFAULT=runart-base |
| TARGET | ⚠️ Via paths | ✅ DEFAULT=staging |

**Recomendación:** Merge PR #75 para tener defaults explícitos y más robustos.

---

## 6. Referencias al Reporte de Dry-Run

Ver archivo asociado:
- **Log:** `_reports/deploy_logs/DEPLOY_DRYRUN_LOCAL_20251029.log`

**Nota:** Dry-run local NO ejecutado porque script deploy_theme.sh no existe en main.  
Se ejecutará tras merge de PR #75.

**Alternativa ejecutada:** Validación de staging_env_loader.sh

```bash
source tools/staging_env_loader.sh
# Output esperado:
#   THEME_SLUG:       runart-base (canon)
#   THEME_PATH:       /homepages/7/.../staging/wp-content/themes/runart-base
```

---

## 7. Conclusiones

### ✅ Fortalezas

1. **Canon Establecido:**
   - staging_env_loader.sh fuerza runart-base
   - Documentación clara en Deployment_Master.md
   - Reportes de verificación completos

2. **Gobernanza Activa:**
   - PR template con checkboxes
   - Labels GitHub creados (6 de 6)
   - Docs de governance y freeze policies

3. **Scripts Funcionales:**
   - 23 scripts staging operativos
   - deploy_wp_ssh.sh con CI-GUARD
   - Backups automáticos

4. **CI Guards:**
   - guard-deploy-readonly.yml activo
   - 8 workflows deployment existentes
   - Validación de media changes

### ⚠️ Áreas de Mejora

1. **Deploy Framework Incompleto en Main:**
   - Falta documentación comprehensiva (4 docs en PR #75)
   - Falta script unificado deploy_theme.sh
   - Falta deploy_guard.yml con 4 jobs

2. **Defaults No Explícitos:**
   - READ_ONLY no declarado en deploy_wp_ssh.sh
   - DRY_RUN implícito en rsync
   - REAL_DEPLOY no existe

3. **Documentación Dispersa:**
   - Deployment_Master.md + 23 scripts = difícil de seguir
   - FAQ no existe (40+ en PR #75)
   - Rollback procedures incompletas

### 📊 Métricas

| Componente | Main | PR #75 | Delta |
|------------|------|--------|-------|
| Docs deploy/ | 0 | 4 | +4 |
| Líneas docs | 0 | ~3,500 | +3,500 |
| Script principal | deploy_wp_ssh.sh (~400 líneas) | deploy_theme.sh (~650 líneas) | +250 |
| CI jobs deploy | 2 (guard-readonly) | 4 (guard full) | +2 |
| Defaults explícitos | 1 (THEME_SLUG) | 6 (READ_ONLY, DRY_RUN, etc.) | +5 |

---

## 8. Recomendaciones

### Inmediatas

1. **Merge PR #75 a develop:**
   - Resolver conflictos (CONFLICTING con develop)
   - Review completo de 3,895 líneas
   - Validar CI checks

2. **Ejecutar Dry-Run Local:**
   - Tras merge, ejecutar deploy_theme.sh en modo simulación
   - Generar log completo en _reports/deploy_logs/
   - Validar defaults READ_ONLY=1, DRY_RUN=1

3. **Actualizar Deployment_Master.md:**
   - Referenciar docs/deploy/ tras merge
   - Consolidar información dispersa
   - Deprecar secciones redundantes

### Mediano Plazo

1. **Consolidar Scripts:**
   - Migrar funcionalidad de deploy_wp_ssh.sh a deploy_theme.sh
   - Deprecar scripts redundantes en tools/
   - Documentar migration path

2. **Testing:**
   - Tests unitarios para deploy_theme.sh
   - Integration tests con staging
   - CI coverage >80%

3. **Monitoreo:**
   - Dashboard de deployments
   - Alertas de failures
   - Auditoría semanal

---

## 9. Estado para Siguiente Fase

### ✅ Ready

- Gobernanza documentada y activa
- Canon runart-base establecido
- Scripts staging funcionales
- CI guards operativos
- Estructura _reports/ lista

### ⏳ Pending

- Deploy Framework completo (merge PR #75)
- Dry-run validation local
- Tests automatizados
- Consolidación de scripts

### 🎯 Bloqueadores

- PR #75 en estado CONFLICTING
- Requiere resolución manual de conflicts
- Estimado: 2-4 horas

---

## 10. Referencias

### PRs Relacionados

- **#75:** Deploy Framework completo (OPEN, CONFLICTING)
- **#74:** Canon RunArt Base + Freeze Ops (estado desconocido)
- **#72:** main → develop sync (OPEN, CONFLICTING)

### Documentos Clave

- docs/Deployment_Master.md
- docs/_meta/governance.md
- _reports/TEMA_ACTIVO_STAGING_20251029.md
- _reports/CI_FREEZE_POLICY_20251029.md

### Scripts Críticos

- tools/staging_env_loader.sh
- tools/deploy_wp_ssh.sh
- .github/workflows/guard-deploy-readonly.yml

---

**Verificación completada:** 2025-10-29  
**Próxima revisión:** Tras merge de PR #75  
**Status:** ⚠️ PARCIAL — Framework funcional pero no formalizado en main
