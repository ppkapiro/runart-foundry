# INVENTARIO DE SECRETS GITHUB
**Repositorio:** ppkapiro/runart-foundry  
**Timestamp:** 2025-10-14T18:25:51Z  
**Generado por:** tools/ci/list_github_secrets.sh

## 📦 SECRETS DE REPOSITORIO
Los siguientes secrets están configurados a nivel de repositorio:

| Secret Name | Actualizado | Tipo | Observaciones |
|-------------|-------------|------|---------------|
| `ACCESS_CLIENT_ID` | 2025-10-13T16:48:49Z | Cloudflare Access | Para autenticación |
| `ACCESS_CLIENT_SECRET` | 2025-10-13T16:49:24Z | Cloudflare Access | Para autenticación |
| `CF_ACCOUNT_ID` | 2025-10-13T15:51:37Z | **Cloudflare** | **DEPRECATED (pendiente eliminación 2025-10-28)** |
| `CF_API_TOKEN` | 2025-10-13T22:14:21Z | **Cloudflare** | **DEPRECATED (pendiente eliminación 2025-10-28)** |
| `CF_LOG_EVENTS_ID` | 2025-10-04T15:37:18Z | KV Namespace | Para logs en producción |
| `CF_LOG_EVENTS_PREVIEW_ID` | 2025-10-04T15:50:32Z | KV Namespace | Para logs en preview |
| `CLOUDFLARE_ACCOUNT_ID` | 2025-10-13T15:49:17Z | **Cloudflare** | **CANÓNICO** |
| `CLOUDFLARE_API_TOKEN` | 2025-10-13T22:13:57Z | **Cloudflare** | **CANÓNICO** |
| `CLOUDFLARE_PROJECT_NAME` | 2025-10-13T15:49:50Z | Cloudflare Pages | Nombre del proyecto |
| `RUNART_ROLES_KV_PREVIEW` | 2025-10-13T19:49:06Z | KV Namespace | Para roles en preview |
| `RUNART_ROLES_KV_PROD` | 2025-10-13T19:49:08Z | KV Namespace | Para roles en producción |

## 🌍 ENVIRONMENTS DETECTADOS

### Environments Disponibles
- `runart-briefing (Preview)` - Sin secrets específicos
- `runart-briefing (Production)` - Sin secrets específicos  
- `runart-foundry (Production)` - Sin secrets específicos

**📝 Nota:** Todos los environments están vacíos, utilizan secrets a nivel de repositorio.

## 📊 ANÁLISIS DE USO

### Tokens Cloudflare Duplicados
```
CF_API_TOKEN          ← LEGACY (22:14:21Z)
CLOUDFLARE_API_TOKEN  ← CANÓNICO (22:13:57Z)

CF_ACCOUNT_ID         ← LEGACY (15:51:37Z)
CLOUDFLARE_ACCOUNT_ID ← CANÓNICO (15:49:17Z)
```

### Referencias en Workflows
- **pages-deploy.yml**: Usa `CF_API_TOKEN` + `CF_ACCOUNT_ID` (legacy)
- **pages-preview.yml**: Usa `CLOUDFLARE_API_TOKEN` + `CLOUDFLARE_ACCOUNT_ID` (canónico)
- **pages-preview2.yml**: Usa `CLOUDFLARE_API_TOKEN` + `CLOUDFLARE_ACCOUNT_ID` (canónico)
- **briefing_deploy.yml**: Usa `CF_API_TOKEN` + `CF_ACCOUNT_ID` (legacy)
- **overlay-deploy.yml**: Usa `CLOUDFLARE_API_TOKEN` + `CLOUDFLARE_ACCOUNT_ID` (canónico)

## 🎯 RECOMENDACIONES

### Normalización Inmediata
1. **Migrar workflows legacy** a nombres canónicos:
   - `pages-deploy.yml` → usar `CLOUDFLARE_API_TOKEN`
   - `briefing_deploy.yml` → usar `CLOUDFLARE_API_TOKEN`

### Limpieza Futura
2. **Eliminar secrets legacy** tras validación:
   - `CF_API_TOKEN` (después de migrar workflows)
   - `CF_ACCOUNT_ID` (después de migrar workflows)

### Environment Strategy
3. **Considerar environments específicos** para segregación:
   - Mover secrets de preview a `runart-briefing (Preview)`
   - Mover secrets de producción a `runart-briefing (Production)`

## 🔍 VERIFICACIÓN REQUERIDA
- [ ] Verificar scopes de `CLOUDFLARE_API_TOKEN` con `check_cf_scopes.sh`
- [ ] Confirmar que ambos tokens (legacy/canónico) tienen mismos permisos
- [ ] Validar que workflows funcionan con nombres canónicos