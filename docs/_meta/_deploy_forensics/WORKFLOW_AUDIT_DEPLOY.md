# Workflow Deploy Audit — Post-Forensics

**Fecha**: 2025-10-24T15:18Z  
**Contexto**: Investigación de contenido viejo en producción

## Hallazgos Críticos

### 1. Git Integration ACTIVO (DOBLE BUILD)

**Evidencia**: `cf_project_settings.json`
```json
"source": {
  "type": "github",
  "config": {
    "owner": "ppkapiro",
    "repo_name": "runart-foundry",
    "production_branch": "main",
    "deployments_enabled": true,
    "production_deployments_enabled": true
  }
},
"build_config": {
  "build_command": "npm run build",
  "destination_dir": "site",
  "root_dir": "apps/briefing"
}
```

**Problema**:
- Cloudflare Pages tiene **Git Integration** conectado al repo `ppkapiro/runart-foundry`
- Build automático en cada push a `main`: `npm run build` desde `apps/briefing` → `site/`
- **Conflicto**: GitHub Action `pages-deploy.yml` también hace deploy (direct upload)
- **Resultado**: Dos fuentes de build compitiendo; Git Integration prevalece porque es automático y post-commit

### 2. Deploys Recientes (Últimos 5 PROD)

**Fuente**: `cf_deploys.json`
```
ID          | Source  | Commit    | Timestamp              | Status
2c210826    | github  | 893b759   | 2025-10-24T14:58:10Z   | success
5583d937    | github  | 6bfb386   | 2025-10-23T23:48:23Z   | success
be3fedb1    | github  | d530752   | 2025-10-23T22:54:39Z   | success
91c38046    | github  | 10d49f0   | 2025-10-23T22:28:52Z   | success
37d4c7a4    | github  | 2904b08   | 2025-10-23T21:47:42Z   | success
```

**Conclusión**: TODOS los deploys son `source.type: github` (Git Integration), **NINGUNO** es `direct_upload` (GitHub Action).

### 3. Correlación SHA

**Local main**: `a27039a` (forensics workflow commit)  
**Último deploy prod**: `893b759` (test trigger commit)  
**Estado**: ❌ **FAIL** — SHA mismatch (local más adelante que prod)

Esto es normal si prod está en commit anterior, pero confirma que **Git Integration deployed `893b759`**, no la Action.

### 4. GitHub Action `pages-deploy.yml`

**Estado**: Workflow existe y se ejecuta con éxito
```yaml
uses: cloudflare/pages-action@v1
  with:
    apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
    accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
    projectName: runart-foundry
    directory: apps/briefing/site
```

**Problema**: Action sube a `runart-foundry` project como **direct upload**, pero Git Integration sigue activo y posiblemente **sobreescribe** el deploy de Action.

## Root Cause

**Git Integration está activo y ejecutando builds automáticos desde repo, prevaleciendo sobre los deploys manuales de la GitHub Action.**

Posibles razones de contenido viejo:
1. Build command `npm run build` en Pages puede fallar silenciosamente o usar cache viejo
2. `destination_dir: site` puede estar sirviendo build stale si `npm run build` no regenera correctamente
3. Git Integration puede tener `build_caching: true` causando artefactos viejos
4. Action nunca llega a "deploy final" porque Git Integration re-deploya inmediatamente después

## Remediación Recomendada

### Opción A: Desactivar Git Integration (PREFERIDA)

1. Cloudflare Dashboard → Pages → `runart-foundry` → Settings → **Builds & deployments**
2. **Disconnect** from GitHub repo
3. Dejar solo GitHub Action con `pages-action` (direct upload)
4. Beneficios:
   - Control total desde CI/CD pipeline
   - Consistencia con verificación post-deploy
   - Sin builds automáticos no solicitados

---

## ⚠️ UPDATE: 2025-10-24T15:50Z — Git Integration SIGUE ACTIVO

**Pre-check ejecutado antes de redeploy canónico:**

Último deployment Production (`pre_check_deployment.json`):
```json
{
  "id": "c4dadde7-abcb-4d3f-a7f2-606b3ea248ba",
  "source": "github",
  "commit": "b53444df896ab70712dd124c381688ef1f9ec2aa",
  "created_at": "2025-10-24T15:26:54.623689Z",
  "url": "https://c4dadde7.runart-foundry.pages.dev",
  "latest_stage": "success"
}
```

**Estado del proyecto Pages** (`cf_projects.json`):
```json
{
  "source": {
    "type": "github",
    "config": {
      "owner": "ppkapiro",
      "repo_name": "runart-foundry",
      "production_branch": "main",
      "deployments_enabled": true,
      "production_deployments_enabled": true
    }
  }
}
```

### 🔴 BLOQUEO CRÍTICO

**Git Integration NO FUE DESCONECTADO por el owner.**

Según instrucciones de redeploy canónico:
> "Si source ≠ direct_upload: marcar BLOQUEO CRÍTICO en docs/_meta/WORKFLOW_AUDIT_DEPLOY.md (Remediación), detallar causa visible y no continuar con pasos 4–6. Dejar estado como FAILED y finalizar."

**Causa raíz**: Issue #70 requiere acción manual en Cloudflare Dashboard que no ha sido ejecutada.

**Impacto**:
- Cualquier deploy de GitHub Action será sobreescrito por Git Integration
- No se puede certificar source=direct_upload sin desconectar primero
- Deploy canónico sería INÚTIL (Git Integration rebuildeará inmediatamente después)

**Estado**: ❌ **FAILED — BLOCKED ON MANUAL ACTION**

**Próxima acción requerida**:
1. Owner debe acceder a Cloudflare Dashboard
2. Disconnect Git Integration siguiendo pasos de Issue #70
3. Re-ejecutar pre-check para validar `source: null` o ausencia de config GitHub
4. Entonces proceder con deploy canónico

---

## Decisión

**Proceder con Opción A**: Desactivar Git Integration y mantener solo GitHub Action con `pages-action` para deploy controlado desde CI/CD.

**Próximos pasos**:
1. Desconectar Git Integration en Cloudflare Dashboard (manual, requiere UI)
2. Abrir Issue #70: "Disconnect Pages Git Integration — keep only direct upload Action"
3. Re-deploy canónico desde Action después de desconectar
4. Verificar que deploys subsecuentes sean `source.type: direct_upload`
5. Confirmar contenido actualizado con fingerprints

---

**Auditoría por**: GitHub Copilot  
**Validado por**: Forensics API data collection
