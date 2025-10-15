# 🚀 PIPELINE CANARIO - LISTO PARA EJECUCIÓN REAL

## ✅ INFRAESTRUCTURA COMPLETADA

### Scripts Ejecutables Preparados
- **`scripts/run_canary_real.sh`** - Script principal que ejecuta todo el pipeline
- **`scripts/execute_go_action.sh`** - Acción GO: Activar unified resolver en preview  
- **`scripts/execute_nogo_action.sh`** - Acción NO-GO: Documentar incident

### Pipeline Automatizado
1. **Verificación de CF_API_TOKEN** - Busca token o da instrucciones al operador
2. **Ejecución Real** - `canary_pipeline.mjs` con 4 correos representativos
3. **Evaluación Automática** - Lee RESUMEN_*.md y aplica criterios GO/NO-GO
4. **Acción Automática** - Ejecuta GO o NO-GO según resultados

## 🔐 EJECUCIÓN (REQUIERE TOKEN)

```bash
# PASO 1: Obtener CF_API_TOKEN
export CF_API_TOKEN=your_cloudflare_api_token_here

# PASO 2: Ejecutar pipeline completo
cd /home/pepe/work/runartfoundry/apps/briefing
./scripts/run_canary_real.sh
```

## ⚖️ CRITERIOS DE DECISIÓN

### ✅ GO CRITERIA
- **4/4 emails whitelisteados** muestran:
  - `X-RunArt-Canary: 1`  
  - `X-RunArt-Resolver: unified`
  - Roles correctos según utils resolver
- **Email control** (no whitelisteado) muestra `X-RunArt-Resolver: legacy`

### ❌ NO-GO CRITERIA
- Cualquier email whitelisteado falla headers
- Roles inconsistentes o ascensos indebidos
- Errores en smoke tests

## 🎯 ACCIONES AUTOMÁTICAS

### SI GO ✅
1. **Actualizar wrangler.toml**: `ROLE_RESOLVER_SOURCE="utils"` en preview
2. **Commit + Push**: Con mensaje descriptivo y enlace a evidencias
3. **Deploy Preview**: Aplicar cambios con `wrangler pages deploy --env preview`
4. **Smokes Globales**: Verificar resolver unified activo en preview
5. **Documentación**: Crear resumen GO con artefactos y próximos pasos

### SI NO-GO ❌
1. **Conservar Legacy**: `wrangler.toml` sin cambios (ROLE_RESOLVER_SOURCE="codex")
2. **Crear Incident**: Carpeta `INCIDENT_<timestamp>/` con todas las evidencias
3. **Análisis**: Documentar failures, correos afectados, root cause hipótesis
4. **GitHub Issue**: Template preparado para creación de issue de corrección
5. **Fixes Propuestos**: Lista de acciones para resolver los problemas detectados

## 📁 ARTEFACTOS GENERADOS

### Durante Pipeline
- `_reports/kv_snapshot_preview_<TS>.json` - Export completo de KV
- `_reports/kv_audit_preview_<TS>.md` - Análisis de roles y usuarios
- `_reports/canary_allowlist_cmd_<TS>.txt` - Comando de whitelist ejecutado
- `_reports/roles_canary_preview/smokes_<TS>/` - Smoke tests individuales
- `_reports/roles_canary_preview/RESUMEN_<TS>.md` - **Resumen principal para decisión**

### Si GO ✅
- `_reports/roles_canary_preview/global_<TS>/` - Smokes globales post-activación
- `wrangler.toml.backup_<TS>` - Backup del archivo original
- Commit con cambios aplicados

### Si NO-GO ❌
- `_reports/roles_canary_preview/INCIDENT_<TS>/` - Carpeta de incident completa
- `INCIDENT_ANALYSIS.md` - Análisis detallado de failures
- `GITHUB_ISSUE_TEMPLATE.md` - Template para crear issue
- `create_github_issue.sh` - Script para abrir issue automáticamente

## 🔒 SEGURIDAD

- **CF_API_TOKEN**: No se persiste en archivos, solo en memoria durante ejecución
- **Backup**: `wrangler.toml` siempre respaldado antes de cambios
- **Rollback**: Instrucciones de rollback incluidas en caso de problemas
- **No Producción**: Solo afecta preview environment

## 📊 CONFIGURACIÓN ACTUAL

- **Branch**: `hotfix/roles-canary-datacheck`
- **Preview Host**: `https://2bea88ae.runart-briefing.pages.dev`
- **Account ID**: `a2c7fc66f00eab69373e448193ae7201`
- **Namespace ID**: `7d80b07de98e4d9b9d5fd85516901ef6`
- **Emails Test**: `ppcapiro@gmail.com`, `team@runart.com`, `admin@runart.com`, `client@runartfoundry.com`

---

**STATUS**: 🟢 READY TO EXECUTE  
**BLOCKER**: CF_API_TOKEN requerido  
**NEXT**: Obtener token y ejecutar `./scripts/run_canary_real.sh`