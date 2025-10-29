## Release
- Rama: `{{ branch }}`
- Tag (si aplica): `briefing-cleanup-20251007` / `v1.0.0`

## Checks esperados
- MkDocs (--strict) ✅
- lint_docs.py ✅
- validate_structure.sh ✅
- check_env.py --mode config ✅
- Endpoints preview: whoami 200 / inbox 403 / decisiones 401 ✅

## Pages
- Preview: (Cloudflare agrega enlace automático)
- Producción: https://briefing.runartfoundry.com

## Bitácora y Changelog
- 082: apps/briefing/docs/082_reestructuracion_local.md
- CHANGELOG: apps/briefing/CHANGELOG.md

---

## 🚀 Deployment (si aplica)

### Pre-Deployment Checklist

- [ ] **Simulación ejecutada:** Log revisado en `_reports/deploy_logs/DEPLOY_DRYRUN_*.md`
- [ ] **Tema validado:** Solo `runart-base` (canon oficial)
- [ ] **Cambios revisados:** Sin modificaciones en `wp-content/uploads/` O label `media-review` añadido
- [ ] **CI guards passed:** Todos los checks de Deploy Guard aprobados
- [ ] **Backups preparados:** Retention configurada (default 7 días)

### Deployment Target

- [ ] **Staging** (requiere label `deployment-approved`)
- [ ] **Producción** (requiere label `maintenance-window` + issue con `DEPLOY_ROLLOUT_PLAN.md` completado)

### Post-Deployment Validation

- [ ] **Smoke tests passed:** Home, About, Contact, Polylang (EN/ES)
- [ ] **Logs revisados:** Sin errores críticos en Apache error_log
- [ ] **Performance validada:** Response times <2s
- [ ] **Reporte generado:** Documentado en `_reports/deploy_logs/DEPLOY_REAL_*.md`

### Rollback Plan

- [ ] **Backup confirmado:** Path y checksum validados
- [ ] **Rollback script disponible:** `tools/rollback_staging.sh` ejecutable
- [ ] **Procedimiento revisado:** Ver `docs/deploy/DEPLOY_ROLLBACK.md`

### Referencias

- **Framework completo:** `docs/deploy/DEPLOY_FRAMEWORK.md`
- **Plan de deployment:** `docs/deploy/DEPLOY_ROLLOUT_PLAN.md`
- **FAQ:** `docs/deploy/DEPLOY_FAQ.md`

---
