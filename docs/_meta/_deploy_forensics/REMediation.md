# Remediación Definitiva — Forensics Investigation

**Fecha**: 2025-10-24T15:25Z  
**Investigación**: Contenido viejo en `runart-foundry.pages.dev`

## Root Cause Identificado

### 🔴 Git Integration ACTIVO causando doble build

**Evidencia**:
- `cf_project_settings.json` muestra `source.type: "github"` con Git Integration conectado
- TODOS los deploys recientes son `source: github`, NINGUNO es `direct_upload` (Action)
- Build config en Pages: `npm run build` desde `apps/briefing` → `site/`
- Build caching activo: `build_caching: true`

**Impacto**:
- GitHub Action `pages-deploy.yml` sube artefactos pero Git Integration los sobreescribe inmediatamente
- Build automático en Pages puede usar cache viejo o fallar silenciosamente
- Dual-source de deploys causa inconsistencias y race conditions

### 🔴 Access Service Tokens para PREVIEW no autorizan PROD

**Evidencia**:
- `fingerprint_diff.txt`: ambos archivos descargados de prod están vacíos (0 bytes)
- `ACCESS_CLIENT_ID_PREVIEW` / `ACCESS_CLIENT_SECRET_PREVIEW` no autorizan `runart-foundry.pages.dev`
- Fingerprint de prod: `da39a3ee5e6b4b0d3255bfef95601890afd80709` (archivo vacío)
- Fingerprint local: `ffaa3d1b...` (build válido)

**Impacto**:
- No podemos verificar contenido real servido en prod con autenticación
- Verificación post-deploy retorna OK pero puede estar validando headers solamente, no contenido

## Remediaciones Aplicadas

### ✅ 1. Forensics Data Collection

- Workflow `forensics-collect.yml` creado y ejecutado
- Archivos generados:
  - `cf_projects.json` (lista de proyectos Pages)
  - `cf_deploys.json` (últimos 10 deploys)
  - `cf_project_settings.json` (config del proyecto)
  - `correlation.txt` (SHA mismatch confirmado)
  - `fingerprint_diff.txt` (MISMATCH confirmado)
  - `WORKFLOW_AUDIT_DEPLOY.md` (análisis completo)

### ✅ 2. Build Local y Fingerprints

- MkDocs build local ejecutado: `apps/briefing/site/`
- Fingerprints locales calculados:
  - `index.html`: `ffaa3d1b27050a1734d10e0498b0765afa31261a`
  - `status/index.html`: `30b7b0901c80d93b4ea739acb5e159da9fb5476a`
- Script `tools/compare_prod_fingerprints.sh` creado

## Remediaciones Pendientes (Requieren Acción Manual)

### 🔧 1. Desconectar Git Integration

**Ubicación**: Cloudflare Dashboard → Pages → `runart-foundry` → Settings → **Builds & deployments**

**Pasos**:
1. Acceder a [Cloudflare Dashboard - Pages](https://dash.cloudflare.com/?to=/:account/pages/view/runart-foundry/settings/builds-deployments)
2. Scroll a "Production and preview branches"
3. Clic en **"Disconnect"** junto al repo `ppkapiro/runart-foundry`
4. Confirmar desconexión

**Resultado esperado**:
- `source.type` cambiará de `github` a `null` o `direct`
- Próximos deploys serán **solo** via GitHub Action con `pages-action`
- Source en API mostrará `direct_upload` en vez de `github`

### 🔧 2. Crear Access Service Token para PROD

**Ubicación**: Cloudflare Dashboard → Zero Trust → Access → Service Auth → Service Tokens

**Pasos**:
1. Acceder a [Cloudflare Zero Trust - Service Tokens](https://one.dash.cloudflare.com/)
2. Navigate: Access → Service Auth → **Create Service Token**
3. Name: `GitHub Actions CI — Prod runart-foundry`
4. Duration: Does not expire
5. Clic "Generate token" → **Copiar Client ID y Client Secret**
6. Agregar secrets a GitHub:
   ```bash
   gh secret set CF_ACCESS_CLIENT_ID -b "<CLIENT_ID>"
   gh secret set CF_ACCESS_CLIENT_SECRET -b "<CLIENT_SECRET>"
   ```
7. En Cloudflare Access → Applications → `runart-foundry.pages.dev`
8. Edit Policy → Add Rule: **Service Auth** → Select token "GitHub Actions CI — Prod runart-foundry"
9. Save

**Resultado esperado**:
- Workflow `deploy-verify.yml` usará secretos PROD (no fallback a PREVIEW)
- Curls con headers retornarán contenido real (no 0 bytes)
- Fingerprints de prod coincidirán con build local

### 🔧 3. Re-deploy Canónico Post-Disconnect

**Trigger**: Automático al push nuevo commit a `main`, O manual via:
```bash
gh workflow run "Deploy to Cloudflare Pages (Briefing)"
```

**Validación**:
1. Workflow completa exitosamente
2. `cf_deploys.json` actualizado mostrará `source.type: direct_upload` o `upload`
3. Verify workflow retorna OK con fingerprints válidos
4. Meta-log muestra:
   ```
   - Deploy: <timestamp> | SHA: <commit> | source: direct_upload | dir: site
   - Verify: <timestamp> | auth: with-Access | result: OK | fingerprint: MATCH
   ```

## Criterios de DONE

- [ ] Git Integration desconectado (confirmado en Dashboard)
- [ ] Access Service Token PROD creado y agregado a policy
- [ ] Deploy canónico ejecutado post-disconnect
- [ ] Deploy API muestra `source: direct_upload` o `upload`
- [ ] Fingerprints de prod MATCH con local
- [ ] Verify workflow retorna 200 en todas las rutas con contenido válido
- [ ] Meta-log actualizado con "Forensics OK — root cause: Git Integration — fix: disconnected — source: direct_upload"

## Issues Relacionados

- **Issue #69**: Configure prod Access Service Tokens (ya existía)
- **Issue #70**: Disconnect Pages Git Integration (NUEVO - crear)

## Notas Técnicas

### MkDocs Strict Mode Failure

Build local falló inicialmente con `--strict` por warnings:
- Links absolutos a `/docs/live/` (no existente en Briefing)
- Links relativos rotos en `proceso/index.md` y `projects/index.md`

**Solución temporal**: Build sin `--strict` para generar fingerprints
**Recomendación**: Limpiar links rotos en próximo ciclo de mantenimiento

### Cache CDN

`CF_ZONE_ID` no configurado → purge CDN opcional no ejecutó  
**Recomendación**: Agregar `CF_ZONE_ID` secret para purge post-deploy automático si Access policy permite

---

**Documento creado**: 2025-10-24T15:30Z  
**Próxima acción**: Desconectar Git Integration manualmente (owner) + crear Issue #70
