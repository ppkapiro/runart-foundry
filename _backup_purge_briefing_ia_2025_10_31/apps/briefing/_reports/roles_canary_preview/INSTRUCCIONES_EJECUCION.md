# INSTRUCCIONES PARA EJECUCIÓN REAL
**COPILOT NEXT ACTIONS** - Canario por Whitelist

## SITUACIÓN ACTUAL ✅
**Pipeline 100% preparado**, configuración poblada con valores reales, scripts funcionales validados con datos simulados.

**BLOQUEADOR:** Falta `CF_API_TOKEN` para ejecutar contra Cloudflare KV real.

## COMANDO LISTO PARA EJECUTAR
```bash
cd /home/pepe/work/runartfoundry/apps/briefing

# 1. Establecer token (obtener desde Cloudflare Dashboard)
export CF_API_TOKEN=your_token_here

# 2. Ejecutar pipeline completo
node scripts/canary_pipeline.mjs \
  --host https://2bea88ae.runart-briefing.pages.dev \
  --owner ppcapiro@gmail.com \
  --team team@runart.com \
  --client_admin admin@runart.com \
  --client client@runartfoundry.com
```

## QUE HACE EL PIPELINE
1. **Export KV** → Genera `kv_snapshot_preview_YYYYMMDDTHHMMSSZ.json`
2. **Audit Roles** → Analiza datos y genera `kv_audit_preview_YYYYMMDDTHHMMSSZ.md`
3. **Set Whitelist** → Configura `CANARY_ROLE_RESOLVER_EMAILS` en KV
4. **Smoke Tests** → Verifica headers en 4 emails + 1 control
5. **Report** → Genera `canary_pipeline_report_YYYYMMDDTHHMMSSZ.md`

## DECISIÓN GO/NO-GO

### ✅ GO CRITERIA
- **4/4 emails whitelisteados** muestran:
  - `X-RunArt-Canary: 1`
  - `X-RunArt-Resolver: unified` 
  - Roles correctos
- **Email control** muestra `X-RunArt-Resolver: legacy`

### 🔴 NO-GO CRITERIA  
- Cualquier whitelisteado falla
- Headers incorrectos
- Roles inconsistentes

## SI GO → ACTIVAR GLOBAL
```bash
# Actualizar wrangler.toml
sed -i 's/ROLE_RESOLVER_SOURCE = "codex"/ROLE_RESOLVER_SOURCE = "utils"/' wrangler.toml

# Commit + deploy
git add wrangler.toml
git commit -m "feat: activate unified resolver in preview (canary GO)"
git push origin hotfix/roles-canary-datacheck

# Deploy preview
npx wrangler pages deploy --env preview
```

## SI NO-GO → DOCUMENTAR ISSUES
```bash
# Crear incident folder
mkdir -p _reports/roles_resolver_incident_$(date +%Y%m%d)

# Copiar evidencia de falla
cp _reports/roles_canary_preview/* _reports/roles_resolver_incident_$(date +%Y%m%d)/

# Crear GitHub issue para fixes
```

## ARCHIVOS CLAVE PREPARADOS
- `scripts/canary.config.json` - Config con valores reales
- `scripts/canary_pipeline.mjs` - Pipeline automatizado  
- `package.json` - NPM shortcuts añadidos
- `_reports/roles_canary_preview/CANARY_PIPELINE_DECISION.md` - Framework decisión

**TODO LISTO PARA EJECUCIÓN** 🚀