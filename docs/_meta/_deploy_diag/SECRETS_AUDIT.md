# Auditoría de Secrets — Cloudflare Access para CI/CD

**Fecha:** 2025-10-24T14:04Z  
**Estado:** PREVIEW secrets disponibles; PROD secrets FALTANTES

---

## Secrets Disponibles (GitHub)

### Cloudflare Access (Preview/Staging)
- ✅ `ACCESS_CLIENT_ID_PREVIEW` — último update: 2025-10-15T17:48:13Z
- ✅ `ACCESS_CLIENT_SECRET_PREVIEW` — último update: 2025-10-15T17:48:41Z

### Cloudflare API
- ✅ `CLOUDFLARE_API_TOKEN`
- ✅ `CLOUDFLARE_ACCOUNT_ID`

### Otros
- ✅ `NAMESPACE_ID_RUNART_ROLES_PREVIEW`
- ✅ `WP_APP_PASSWORD`
- ✅ `WP_USER`

---

## Secrets FALTANTES para verificación autenticada PROD

### Requeridos
- ❌ `CF_ACCESS_CLIENT_ID` (o `ACCESS_CLIENT_ID_PROD`)
- ❌ `CF_ACCESS_CLIENT_SECRET` (o `ACCESS_CLIENT_SECRET_PROD`)

### Impacto
Sin estos secrets, el workflow `deploy-verify.yml` **NO puede** verificar producción con headers de Cloudflare Access.

**Opciones:**
1. **Crear Access Service Token para PROD** en Cloudflare Dashboard:
   - Dashboard → Zero Trust → Access → Service Tokens → Create Service Token
   - Nombre: `GitHub Actions CI — Prod Verify`
   - Guardar `Client ID` y `Client Secret` en GitHub Secrets como `CF_ACCESS_CLIENT_ID` y `CF_ACCESS_CLIENT_SECRET`

2. **Desactivar Cloudflare Access en runart-foundry.pages.dev** (no recomendado para prod si requiere protección).

3. **Usar bypass condicional**: el workflow detecta la ausencia de secrets y salta verificación autenticada, solo logeando "SKIP (Access protected)".

---

## Nomenclatura Recomendada

Para mantener consistencia con secrets existentes:
- PROD: `ACCESS_CLIENT_ID_PROD`, `ACCESS_CLIENT_SECRET_PROD`
- PREVIEW: `ACCESS_CLIENT_ID_PREVIEW`, `ACCESS_CLIENT_SECRET_PREVIEW` (✅ ya existen)

O usar nombres genéricos si solo aplican a prod:
- `CF_ACCESS_CLIENT_ID`
- `CF_ACCESS_CLIENT_SECRET`

---

## Próximos pasos

1. Crear Issue "Configure CF Access Service Token for Production Verify"
2. Actualizar `deploy-verify.yml` para usar nomenclatura consistente
3. Documentar en WORKFLOW_AUDIT_DEPLOY.md el estado de Access en prod vs preview
