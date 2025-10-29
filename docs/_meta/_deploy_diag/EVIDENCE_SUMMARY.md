# Deploy Diagnosis — Evidence Summary

**Fecha:** 2025-10-24T14:15Z  
**Operación:** FIX DEPLOYS & STAGING — Access-aware Verify + Unificación site

---

## HTTP Headers de Producción

Todas las rutas principales retornan **HTTP 302** → Cloudflare Access login required:

### `/` (home)
- Status: `HTTP/2 302`
- Location: `https://runart-briefing-pages.cloudflareaccess.com/cdn-cgi/access/login/...`
- **Ver:** `docs/_meta/_deploy_diag/head___.txt`

### `/status/`
- Status: `HTTP/2 302`
- **Ver:** `docs/_meta/_deploy_diag/head__status__.txt`

### `/news/`
- Status: `HTTP/2 302`
- **Ver:** `docs/_meta/_deploy_diag/head__news__.txt`

### `/status/history/`
- Status: `HTTP/2 302`
- **Ver:** `docs/_meta/_deploy_diag/head__status_history__.txt`

---

## Configuración Deploy Actual

### Workflow canónico
- **Archivo:** `.github/workflows/pages-deploy.yml`
- **Trigger:** `push` a `main` en paths `apps/briefing/**`, `docs/**`
- **Permissions:** `contents: write`, `deployments: write` ✅
- **Concurrency:** `group: deploy-prod`, `cancel-in-progress: true` ✅

### Build
- **Working directory:** `apps/briefing`
- **Comando:** `mkdocs build -d site`
- **Output:** `apps/briefing/site/` ✅
- **Verificación:** `test -d site && test -f site/index.html` ✅

### Deploy
- **Action:** `cloudflare/pages-action@v1`
- **Project:** `runart-foundry`
- **Directory:** `apps/briefing/site` ✅
- **Branch:** `main`

---

## Secrets Disponibles

### GitHub Secrets
- ✅ `CLOUDFLARE_API_TOKEN`
- ✅ `CLOUDFLARE_ACCOUNT_ID`
- ✅ `ACCESS_CLIENT_ID_PREVIEW`
- ✅ `ACCESS_CLIENT_SECRET_PREVIEW`
- ❌ `CF_ACCESS_CLIENT_ID` (requerido para prod verify con Access)
- ❌ `CF_ACCESS_CLIENT_SECRET` (requerido para prod verify con Access)
- ❌ `CF_ZONE_ID` (opcional para purge cache)

**Ver detalle:** `docs/_meta/_deploy_diag/SECRETS_AUDIT.md`

---

## Workflows Actualizados

### `.github/workflows/deploy-verify.yml`
**Cambios:**
- ✅ Detecta disponibilidad de `CF_ACCESS_CLIENT_ID/SECRET` o `ACCESS_CLIENT_ID_PROD/SECRET_PROD`
- ✅ Usa headers `CF-Access-Client-Id` y `CF-Access-Client-Secret` si disponibles
- ✅ Verifica `/`, `/status/`, `/news/`, `/status/history/` con autenticación
- ✅ Skip graceful si secrets no existen (no falla el workflow)
- ✅ Log diferenciado: "OK (Access-auth)" vs "SKIP (Access protegido, no service token)"

### `.github/workflows/monitor-deploys.yml`
**Cambios:**
- ✅ Tolera verify SKIP por Access protegido (no alarma falsos positivos)
- ✅ Solo alarma si deploy FAIL o verify FAIL real (no por 302/Access)
- ✅ Comprueba log de meta para detectar "SKIP (Access protegido"

### `.github/workflows/pages-deploy.yml`
**Cambios:**
- ✅ Añadido step opcional "Purge Cloudflare Cache" que:
  - Comprueba si `CF_ZONE_ID` existe
  - Purga cache con `purge_everything` si disponible
  - Skip sin error si no configurado
  - `continue-on-error: true` para no bloquear deploy

---

## Próximos Pasos

1. **Crear CF Access Service Token para PROD:**
   - Dashboard → Zero Trust → Access → Service Tokens → Create
   - Guardar como `CF_ACCESS_CLIENT_ID` y `CF_ACCESS_CLIENT_SECRET` en GitHub Secrets
   - **Issue:** https://github.com/RunArtFoundry/runart-foundry/issues/69

2. **Opcional: Configurar CF_ZONE_ID** para purge de cache automático post-deploy

3. **Verificar deploy post-merge** de estos cambios:
   - Deploy debe completar ✅
   - Verify debe SKIP con mensaje "Access protegido, no service token"
   - Monitor no debe alarmar por SKIP

---

## Estado Operativo

| Componente | Estado | Notas |
|------------|--------|-------|
| Deploy workflow | ✅ OK | Permisos y concurrency correctos |
| Build (mkdocs) | ✅ OK | Genera `apps/briefing/site/` |
| Cloudflare Pages publish | ✅ OK | Publica a `runart-foundry` |
| Verify workflow | ⚠️  PENDING | Requiere Access secrets para prod |
| Monitor workflow | ✅ OK | Tolerante a Access 302 |
| Cloudflare Access | 🔒 ACTIVO | Protege todas las rutas con login |

**Conclusión:** Deploy funciona; verificación post-deploy requiere Service Token para bypassar Access en CI.
