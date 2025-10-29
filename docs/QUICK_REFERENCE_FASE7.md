# 🎯 QUICK REFERENCE — FASE 7 PREVIEW PRIMERO

**Print this and keep on desk during execution**

---

## 📍 UBICACIÓN DE DOCUMENTOS

| Documento | Propósito | Ubicación |
|-----------|-----------|-----------|
| **RUNBOOK Completo** | Instrucciones paso-a-paso | `docs/RUNBOOK_FASE7_PREVIEW_PRIMERO.md` |
| **Checklist Ejecutiva** | Checkboxes + tracking | `docs/CHECKLIST_EJECUTIVA_FASE7.md` |
| **Este archivo** | Quick ref | `docs/QUICK_REFERENCE_FASE7.md` |
| **Issue #50** | Consolidado oficial | `issues/Issue_50_Fase7_Conexion_WordPress_Real.md` |
| **ADR Decision** | Preview vs Styling vs Mixto | `apps/briefing/docs/.../050_decision_record_styling_vs_preview.md` |
| **Staging Plan** | Plan operativo 070 | `apps/briefing/docs/.../070_preview_staging_plan.md` |

---

## ⏱️ TIMELINE RESUMIDO

```
Fase 1: Crear Staging ........... 45 min (DNS 5 + HTTPS 15 + Archivos 10 + BD 15)
Fase 2: Cargar Secrets .......... 5 min
Fase 3: Ejecutar verify-* Staging 20 min (4 workflows × 2-3 min + espera)
Fase 4: Documentar Staging ...... 10 min
─────────────────────────────────
SUBTOTAL STAGING: 1h 20 min
─────────────────────────────────
Fase 5: Promover a PROD ........ 10 min
Fase 6: Validar PROD ........... 20 min (4 workflows × 2-3 min)
Fase 7: Cierre + Commit ........ 20 min
─────────────────────────────────
TOTAL: 3h 20 min (+ 30 min buffer = 3.5-4.5h)
```

---

## 🔑 COMANDOS ESENCIALES

### SSH a Servidor
```bash
ssh usuario@servidor-ip
# o
ssh -i ~/.ssh/key.pem usuario@servidor-ip
```

### Crear Staging DNS
```bash
# In DNS Manager: A record
staging.runalfondry.com → IP-servidor

# Verify:
nslookup staging.runalfondry.com
```

### HTTPS Let's Encrypt
```bash
sudo certbot certonly --nginx -d staging.runalfondry.com
```

### Importar BD desde PROD a STAGING
```bash
# En PROD:
mysqldump -u user -p db_name --single-transaction > /tmp/dump.sql

# En STAGING:
mysql -u staging_user -p staging_db < /tmp/dump.sql

# Reemplazar URLs:
cd /var/www/staging
wp search-replace 'https://runalfondry.com' 'https://staging.runalfondry.com' --all-tables
```

### Cargar Secrets en GitHub
```bash
gh variable set WP_BASE_URL --body "https://staging.runalfondry.com"
gh secret set WP_USER --body "github-actions"
gh secret set WP_APP_PASSWORD --body "xxxx-xxxx-..."
```

### Ejecutar Workflows
```bash
gh workflow run verify-home.yml
gh workflow run verify-settings.yml
gh workflow run verify-menus.yml
gh workflow run verify-media.yml
```

### Cambiar a PROD
```bash
gh variable set WP_BASE_URL --body "https://runalfondry.com"
gh secret set WP_APP_PASSWORD --body "xxxx-xxxx-... (PROD)"
```

### Rollback a PLACEHOLDER
```bash
gh variable set WP_BASE_URL --body "placeholder.local"
```

---

## 🚨 CRITICAL CHECKLIST

**ANTES DE EMPEZAR:**
- [ ] ¿Backups de PROD disponibles?
- [ ] ¿Acceso SSH confirmado?
- [ ] ¿DNS/hosting panel accesible?
- [ ] ¿gh CLI autenticado?

**ANTES DE CAMBIAR A PROD:**
- [ ] ¿Staging: 4/4 workflows PASSED?
- [ ] ¿Staging: Auth=OK en todos?
- [ ] ¿Artifacts descargados?
- [ ] ¿Issue #50 actualizado?

**DESPUÉS DE CAMBIAR A PROD:**
- [ ] ¿PROD: 4/4 workflows PASSED?
- [ ] ¿PROD: Auth=OK en todos?
- [ ] ¿Artifacts PROD descargados?
- [ ] ¿Commits pusheados?

---

## ⚠️ ADVERTENCIAS

🔴 **NUNCA:**
- Pegues contraseñas en git/GitHub/comentarios
- Copjes `/var/www/prod/wp-config.php` directamente a staging
- Uses el mismo DB usuario para PROD y STAGING
- Ejecutes workflows sin verificar que apuntan a la URL correcta

🟡 **SIEMPRE:**
- Regenera App Passwords post-validación (seguridad)
- Ten rollback plan en mente antes de cambiar a PROD
- Documenta problemas en Issue #50
- Comunica con el equipo cambios en PROD

---

## 🆘 QUICK TROUBLESHOOTING

| Error | Fix |
|-------|-----|
| `Auth=KO` | Regenera App Password en WP-Admin, actualiza secret |
| `DNS not resolving` | Espera 5-15 min propagación |
| `SSL cert error` | `sudo certbot certonly --nginx -d staging...` |
| `WP 500 error` | Verifica wp-config.php, BD credentials, permisos |
| `mode=placeholder` | Verifica que WP_BASE_URL está en GitHub (no "placeholder") |
| `verify-* FAILED` | Ver artifacts en Actions tab, revisa logs |

---

## 📞 WHO TO CONTACT

| Issue | Contact |
|-------|---------|
| DNS/Hosting | Registrar/ISP |
| SSH Access | Server Admin |
| WP-Admin Issues | WP Admin |
| GitHub Actions | DevOps / GitHub Support |
| DB Issues | DBA / MySQL Support |

---

## ✅ DEFINITION OF DONE

```
Staging Validated:
  ☐ verify-home:     PASSED, Auth=OK, 200 OK
  ☐ verify-settings: PASSED, Auth=OK, Compliance=OK
  ☐ verify-menus:    PASSED, Auth=OK
  ☐ verify-media:    PASSED, Auth=OK

Production Validated:
  ☐ verify-home:     PASSED, Auth=OK, 200 OK
  ☐ verify-settings: PASSED, Auth=OK, Compliance=OK
  ☐ verify-menus:    PASSED, Auth=OK
  ☐ verify-media:    PASSED, Auth=OK

Documentation:
  ☐ Issue #50: Staging + Prod sections completed
  ☐ CHANGELOG.md: Fase 7 entry added
  ☐ Artifacts: All 4 workflows downloaded
  ☐ Git: Commits pushed

Security:
  ☐ No secrets in git (grep validated)
  ☐ No secrets in logs
  ☐ App Passwords regenerated
  ☐ Backups verified

Completion:
  ☐ PR merged to main
  ☐ Phase 7 ✅ DONE
```

---

## 📋 ESSENTIAL CREDENTIALS (Keep local, never git)

```
[Keep in password manager or encrypted file]

Staging:
  WP_BASE_URL: https://staging.runalfondry.com
  WP_USER: github-actions
  WP_APP_PASSWORD: [staging app password here]

Production:
  WP_BASE_URL: https://runalfondry.com
  WP_USER: github-actions
  WP_APP_PASSWORD: [prod app password here]

DB Staging:
  DB_USER: staging_user
  DB_PASSWORD: [staging db password here]
  DB_NAME: wordpress_staging

DB Production:
  DB_USER: [prod user]
  DB_PASSWORD: [prod password]
  DB_NAME: [prod db name]
```

---

## 🔗 QUICK LINKS

| Link | URL |
|------|-----|
| GitHub Repo | https://github.com/ppkapiro/runart-foundry |
| WordPress Prod | https://runalfondry.com/wp-admin |
| WordPress Staging | https://staging.runalfondry.com/wp-admin |
| GitHub Actions | https://github.com/ppkapiro/runart-foundry/actions |
| Issue #50 | https://github.com/ppkapiro/runart-foundry/issues/50 |
| RUNBOOK | See: `docs/RUNBOOK_FASE7_PREVIEW_PRIMERO.md` |
| CHECKLIST | See: `docs/CHECKLIST_EJECUTIVA_FASE7.md` |

---

## 📞 EMERGENCY CONTACTS

```
If something breaks:

1. Rollback: gh variable set WP_BASE_URL --body "placeholder.local"
2. Investigate: Check logs at GitHub Actions
3. Report: Add comment in Issue #50 with error details
4. Consult: See RUNBOOK troubleshooting section
5. Escalate: Contact [DevOps/Admin] if needed
```

---

## 🎯 SUCCESS INDICATORS

```
You know it worked when:
  ✅ All 4 verify-* workflows show green (PASSED)
  ✅ Artifacts contain "Auth=OK" and "mode=real"
  ✅ Issue #50 shows Staging + Prod sections completed
  ✅ CHANGELOG.md lists Fase 7 as completed
  ✅ PR merged to main without conflicts
  ✅ No secrets found in git (grep validation passed)
  ✅ GitHub Actions running on schedule (cron)
  ✅ Alerts/Issues auto-generated on KO (future feature)
```

---

**Print date:** __________  
**Executor:** __________  
**Start time:** __________  
**End time:** __________  
**Duration:** __________  
**Status:** ☐ SUCCESS ☐ PARTIAL ☐ FAILED  
**Notes:** _____________________________________________________

---

**Created:** 2025-10-20  
**Version:** 1.0  
**Keep this card for reference during execution**
