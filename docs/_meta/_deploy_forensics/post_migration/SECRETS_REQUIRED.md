# Migración a Direct Upload — Configuración de Secrets Requerida

**Fecha**: 2025-10-24T18:16Z  
**Estado**: BLOCKED — Missing GitHub Secrets

## Problema

El workflow de migración `.github/workflows/pages-deploy-direct.yml` requiere secrets que no están configurados en el repositorio.

## Secrets Actuales

```
✅ CF_ACCESS_CLIENT_ID     (Service Token — Production)
✅ CF_ACCESS_CLIENT_SECRET  (Service Token — Production)
```

## Secrets Faltantes (REQUERIDOS)

### 1. CF_ACCOUNT_ID

**Descripción**: ID de la cuenta de Cloudflare  
**Cómo obtenerlo**:
1. Ir a https://dash.cloudflare.com/
2. En la barra lateral, el Account ID aparece debajo del nombre de la cuenta
3. O ir a cualquier worker/page y copiarlo de la URL: `https://dash.cloudflare.com/<ACCOUNT_ID>/...`

**Formato**: UUID de 32 caracteres hex (ej: `a2c7fc66f00eab69373e448193ae7201`)

### 2. CF_API_TOKEN_PAGES

**Descripción**: API Token con permisos para gestionar Pages  
**Permisos requeridos**:
- `Account.Cloudflare Pages:Edit`
- `Account.Workers KV Storage:Read` (opcional, para futuros bindings)

**Cómo crearlo**:
1. Ir a https://dash.cloudflare.com/profile/api-tokens
2. Click "Create Token"
3. Usar template "Edit Cloudflare Pages" O crear custom token:
   - Permissions:
     - Account → Cloudflare Pages → Edit
     - Account → Workers KV Storage → Read (opcional)
   - Account Resources:
     - Include → \<Tu cuenta\>
4. Click "Continue to summary" → "Create Token"
5. Copiar el token (solo se muestra una vez)

## Configuración en GitHub

Una vez obtenidos los valores:

```bash
# Desde la raíz del repo
gh secret set CF_ACCOUNT_ID --body "<ACCOUNT_ID>"
gh secret set CF_API_TOKEN_PAGES --body "<TOKEN>"
```

O via interfaz web:
1. Ir a https://github.com/RunArtFoundry/runart-foundry/settings/secrets/actions
2. Click "New repository secret"
3. Name: `CF_ACCOUNT_ID`, Secret: `<ACCOUNT_ID>`
4. Repetir para `CF_API_TOKEN_PAGES`

## Verificación

Tras configurar los secrets:

```bash
gh secret list | grep -E "(CF_ACCOUNT_ID|CF_API_TOKEN_PAGES)"
```

Debería mostrar:
```
CF_ACCESS_CLIENT_ID     ...
CF_ACCESS_CLIENT_SECRET ...
CF_ACCOUNT_ID           ...
CF_API_TOKEN_PAGES      ...
```

## Próximo Paso

Una vez configurados los secrets, re-ejecutar:

```bash
gh workflow run "Deploy Briefing to Pages (Direct Upload)" -f environment=production
```

El workflow debería:
1. ✅ Build Briefing
2. ✅ Deploy via Wrangler Direct Upload
3. ✅ Verificar `source=direct_upload`
4. ✅ Registrar evidencia

---

**Documentación relacionada**:
- Cloudflare API Tokens: https://developers.cloudflare.com/fundamentals/api/get-started/create-token/
- Wrangler Pages: https://developers.cloudflare.com/pages/platform/wrangler/
