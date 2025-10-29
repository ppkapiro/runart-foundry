# Staging/Preview — Cloudflare Access y Dominios

**Fecha:** 2025-10-24T14:12Z  
**Estado:** Documentado

---

## Dominios y Políticas de Access

### Production
- **URL:** https://runart-foundry.pages.dev
- **Access Policy:** `runart-briefing-pages` (activa)
- **Estado:** HTTP 302 → login required
- **Service Token para CI:**
  - ❌ `CF_ACCESS_CLIENT_ID` — NO configurado
  - ❌ `CF_ACCESS_CLIENT_SECRET` — NO configurado
  - ✅ Workflow `deploy-verify.yml` actualizado para detectar y usar si existen

### Preview (Staging)
- **URL pattern:** `https://<branch>.<project>.pages.dev` (generadas automáticamente por Cloudflare Pages)
- **Access Policy:** Separada de prod (si existe)
- **Service Token para CI:**
  - ✅ `ACCESS_CLIENT_ID_PREVIEW` — configurado (2025-10-15)
  - ✅ `ACCESS_CLIENT_SECRET_PREVIEW` — configurado (2025-10-15)

### Recomendación
Para staging/preview protegidas con Access, crear workflow `verify-preview.yml` similar a `deploy-verify.yml` que:
1. Se dispare en `pull_request` o `workflow_dispatch`
2. Use `ACCESS_CLIENT_ID_PREVIEW` y `ACCESS_CLIENT_SECRET_PREVIEW`
3. Verifique la URL de preview generada por Cloudflare Pages action

---

## Workflow verify-preview.yml (propuesta)

```yaml
name: Verify Preview (Briefing)

on:
  pull_request:
    paths:
      - 'apps/briefing/**'
      - 'docs/**'
  workflow_dispatch:
    inputs:
      preview_url:
        description: 'URL de preview a verificar'
        required: true

permissions:
  contents: read

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - name: Determinar URL de preview
        id: url
        run: |
          if [ -n "${{ github.event.inputs.preview_url }}" ]; then
            echo "url=${{ github.event.inputs.preview_url }}" >> $GITHUB_OUTPUT
          else
            # Construir URL de preview desde PR branch
            BRANCH="${{ github.head_ref }}"
            SANITIZED=$(echo "$BRANCH" | tr '/' '-' | tr '_' '-' | tr '[:upper:]' '[:lower:]')
            echo "url=https://${SANITIZED}.runart-foundry.pages.dev" >> $GITHUB_OUTPUT
          fi

      - name: Verify with Access headers (Preview)
        env:
          CF_CLIENT_ID: ${{ secrets.ACCESS_CLIENT_ID_PREVIEW }}
          CF_CLIENT_SECRET: ${{ secrets.ACCESS_CLIENT_SECRET_PREVIEW }}
          PREVIEW_URL: ${{ steps.url.outputs.url }}
        run: |
          curl -sSf -H "CF-Access-Client-Id: $CF_CLIENT_ID" -H "CF-Access-Client-Secret: $CF_CLIENT_SECRET" \
            "${PREVIEW_URL}/" >/dev/null && echo "✅ ${PREVIEW_URL}/ OK"
          curl -sS -H "CF-Access-Client-Id: $CF_CLIENT_ID" -H "CF-Access-Client-Secret: $CF_CLIENT_SECRET" \
            "${PREVIEW_URL}/status/" | grep -E "KPIs|Estado Operativo" >/dev/null && echo "✅ ${PREVIEW_URL}/status/ OK"
```

---

## Verificación local (con Access)

Para verificar localmente con Service Token:

```bash
export CF_CLIENT_ID="<client_id>"
export CF_CLIENT_SECRET="<client_secret>"

curl -H "CF-Access-Client-Id: $CF_CLIENT_ID" \
     -H "CF-Access-Client-Secret: $CF_CLIENT_SECRET" \
     https://runart-foundry.pages.dev/ | head -n 50
```

---

## Issue relacionado

- [ ] Crear `CF_ACCESS_CLIENT_ID` y `CF_ACCESS_CLIENT_SECRET` para PROD
- [ ] Implementar `verify-preview.yml` si staging/preview están protegidas con Access

**Ver:** https://github.com/RunArtFoundry/runart-foundry/issues/69
