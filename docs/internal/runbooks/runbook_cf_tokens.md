# 🔒 Runbook: Gestión de Tokens Cloudflare

**Versión:** 1.0.0  
**Fecha:** 2025-10-14  
**Alcance:** Verificación, rotación y gestión de tokens Cloudflare en RunArt Foundry

## 🎯 Resumen

Este runbook describe los procedimientos operativos para gestionar tokens de API Cloudflare, verificar scopes, ejecutar rotaciones y responder a incidentes relacionados con credenciales.

## 📋 Tokens Gestionados

### Tokens Canónicos (Activos)
- **`CLOUDFLARE_API_TOKEN`** - Token principal para todas las operaciones
- **`CLOUDFLARE_ACCOUNT_ID`** - ID de cuenta Cloudflare

### Tokens Legacy (En Deprecación)
- **`CF_API_TOKEN`** - ⚠️ DEPRECATED - Eliminar tras migración
- **`CF_ACCOUNT_ID`** - ⚠️ DEPRECATED - Eliminar tras migración

## 🔍 Verificación de Scopes

### Verificación Automática
```bash
# Verificar todos los tokens en repositorio
./tools/ci/check_cf_scopes.sh repo

# Verificar token específico para environment
./tools/ci/check_cf_scopes.sh preview
./tools/ci/check_cf_scopes.sh production
```

### Verificación Manual
```bash
# Con token específico
export CF_API_TOKEN=your_token_here
node scripts/secrets/node/cf_token_verify.mjs
```

### Interpretación de Resultados

#### ✅ Verificación Exitosa
```
✅ CLOUDFLARE_API_TOKEN: OK
  • Compliance: COMPLIANT
  • Scopes faltantes: 0
  • Scopes extra: 2
```

#### ❌ Verificación Fallida
```
❌ CLOUDFLARE_API_TOKEN: FALLÓ
  • Error: HTTP 401
  • Scopes faltantes: 2
    - com.cloudflare.edge.worker.kv:edit
    - com.cloudflare.api.account.zone.page:edit
```

## 🔄 Rotación de Tokens

### Proceso de Rotación Estándar

#### 1. Preparación
```bash
# Verificar estado actual
./tools/ci/check_cf_scopes.sh repo

# Listar secrets actuales
./tools/ci/list_github_secrets.sh
```

#### 2. Crear Nuevo Token en Cloudflare

1. Ir a [Cloudflare Dashboard > API Tokens](https://dash.cloudflare.com/profile/api-tokens)
2. Crear "Custom token" con scopes mínimos:

   | Resource | Permission |
   |----------|-----------|
   | Account | `com.cloudflare.api.account.zone:read` |
   | Workers Scripts | `com.cloudflare.edge.worker.script:read` |
   | Workers KV Storage | `com.cloudflare.edge.worker.kv:edit` |
   | Zone | `com.cloudflare.api.account.zone.page:edit` |

3. **Recursos:** Incluir cuenta específica: `a2c7fc66f00eab69373e448193ae7201`
4. **TTL:** 180 días (6 meses)
5. **Copiar token** (solo se muestra una vez)

#### 3. Actualizar GitHub Secret

```bash
# Opción 1: GitHub Web UI
# Ir a Settings > Secrets and variables > Actions
# Actualizar CLOUDFLARE_API_TOKEN con nuevo valor

# Opción 2: GitHub CLI
gh secret set CLOUDFLARE_API_TOKEN --body "new_token_value_here"
```

#### 4. Validar Nuevo Token

```bash
# Ejecutar workflow de verificación
gh workflow run ci_cloudflare_tokens_verify.yml

# O verificar localmente
export CLOUDFLARE_API_TOKEN="new_token_value"
./tools/ci/check_cf_scopes.sh repo
```

#### 5. Deploy de Prueba

```bash
# Trigger deploy en preview
gh workflow run pages-preview.yml

# Verificar logs del workflow
gh run list --workflow=pages-preview.yml --limit=1
gh run view $(gh run list --workflow=pages-preview.yml --limit=1 --json databaseId --jq '.[0].databaseId')
```

#### 6. Actualizar Política

```bash
# Editar security/credentials/cloudflare_tokens.json
# Actualizar last_rotated con fecha actual
# Calcular next_rotation (+180 días)

git add security/credentials/cloudflare_tokens.json
git commit -m "chore: update token rotation date for CLOUDFLARE_API_TOKEN"
```

#### 7. Revocar Token Anterior

1. Volver a Cloudflare Dashboard > API Tokens
2. Encontrar token anterior por fecha/descripción  
3. Hacer clic en "Delete" 
4. Confirmar revocación

### Rotación de Emergencia

En caso de compromiso de token:

```bash
# 1. Revocar inmediatamente en Cloudflare Dashboard
# 2. Crear nuevo token con scopes mínimos
# 3. Actualizar GitHub secret urgentemente
gh secret set CLOUDFLARE_API_TOKEN --body "emergency_token_here"

# 4. Verificar funcionamiento
gh workflow run ci_cloudflare_tokens_verify.yml

# 5. Documentar incident
echo "$(date): Emergency rotation due to compromise" >> security/rotation_log.txt
```

## 🚨 Resolución de Incidentes

### Token Inválido o Expirado

**Síntomas:**
- Workflows fallan con error 401/403
- Verificación automática crea issues

**Resolución:**
1. Verificar expiración en Cloudflare Dashboard
2. Si expirado: crear nuevo token siguiendo proceso estándar
3. Si no expirado: verificar scopes requeridos

### Scopes Insuficientes

**Síntomas:**
- Verificación reporta `NON_COMPLIANT`
- Deploys fallan en operaciones específicas

**Resolución:**
1. Identificar scopes faltantes en reporte de verificación
2. Ir a Cloudflare Dashboard > API Tokens
3. Editar token existente para añadir permisos faltantes
4. Re-verificar con `./tools/ci/check_cf_scopes.sh`

### Workflow Falla por Secrets Faltantes

**Síntomas:**
- Error: "Missing secrets: CLOUDFLARE_API_TOKEN"
- Job se salta con warning

**Resolución:**
1. Verificar que secret existe en GitHub
   ```bash
   ./tools/ci/list_github_secrets.sh
   ```
2. Si falta, añadir secret siguiendo proceso de rotación
3. Si existe, verificar que workflow referencia nombre correcto

## 📊 Monitoreo y Alertas

### Verificación Automática Semanal

**Workflow:** `ci_cloudflare_tokens_verify.yml`  
**Schedule:** Lunes 09:00 UTC  
**Acción en falla:** Crea issue automático con checklist

### Recordatorio de Rotación

**Workflow:** `ci_secret_rotation_reminder.yml`  
**Schedule:** Primer lunes del mes  
**Threshold:** 30 días antes de expiración  
**Acción:** Crea issue con checklist de rotación

### Monitoreo Manual

```bash
# Verificar próximas rotaciones
jq -r '.tokens | to_entries[] | select(.value.status == "active") | "\(.key): \(.value.next_rotation)"' security/credentials/cloudflare_tokens.json

# Crear issue manual de rotación  
./tools/ci/open_rotation_issue.sh CLOUDFLARE_API_TOKEN 15
```

## 📁 Archivos de Referencia

- **Inventario:** `security/credentials/github_secrets_inventory.md`
- **Auditoría:** `security/credentials/audit_cf_tokens_report.md`
- **Política:** `security/credentials/cloudflare_tokens.json`
- **Scripts:** `tools/ci/check_cf_scopes.sh`, `tools/ci/open_rotation_issue.sh`

## 🔗 Enlaces Útiles

- [Cloudflare API Tokens](https://dash.cloudflare.com/profile/api-tokens)
- [GitHub Secrets Settings](https://github.com/ppkapiro/runart-foundry/settings/secrets/actions)
- [Workflow Runs](https://github.com/ppkapiro/runart-foundry/actions)

## � Validación Final (2025-10-14)

### Reportes de Verificación
- **Preview Scopes:** `security/reports/validation/preview_scopes_check.json`
- **Production Scopes:** `security/reports/validation/prod_scopes_check.json`
- **Deploy Analysis:** `security/reports/validation/*_deploy_summary.log`
- **Workflow Validation:** `security/reports/validation/workflow_validation_report.md`

### Workflows Exitosos Validados
- ✅ **ci_cloudflare_tokens_verify.yml** - Configuración correcta, listo para ejecución
- ✅ **ci_secret_rotation_reminder.yml** - Configuración correcta, cron activo
- ✅ **pages-preview.yml** - Usa tokens canónicos
- ❌ **pages-deploy.yml** - Requiere migración (usa CF_API_TOKEN legacy)

### Issues de Rotación Automática
- **Próximo recordatorio:** 2025-11-04 (primer lunes noviembre)
- **Template disponible:** `tools/ci/open_rotation_issue.sh`
- **Labels automáticas:** automation, cloudflare, tokens, maintenance

## �️ Eliminación de Tokens Legacy

### Procedimiento Automatizado

El script `tools/ci/cleanup_cf_legacy_tokens.sh` gestiona la eliminación segura de tokens legacy tras el período de validación.

#### Ejecución en Dry-Run (Recomendado)
```bash
# Simular eliminación sin cambios reales
./tools/ci/cleanup_cf_legacy_tokens.sh --dry-run
```

#### Ejecución Real
```bash
# Eliminar tokens legacy (requiere confirmación)
./tools/ci/cleanup_cf_legacy_tokens.sh

# El script solicitará escribir 'DELETE' para confirmar
```

### Checklist Pre-Eliminación

Antes de ejecutar la eliminación, verificar:

- [ ] ✅ **Período de validación completado** (14 días post-merge)
- [ ] ✅ **Todos los deploys exitosos** con CLOUDFLARE_API_TOKEN
- [ ] ✅ **Workflows automáticos funcionando** sin errores
- [ ] ✅ **Workflows legacy migrados** (pages-deploy.yml, briefing_deploy.yml)
- [ ] ✅ **Sin issues abiertos** relacionados con tokens CF
- [ ] ✅ **Monitoreo completo** documentado en monitoring_log.md
- [ ] ✅ **GO Decision** aprobada por equipo

### Proceso de Eliminación

1. **Verificación de Seguridad**
   - Confirma que CLOUDFLARE_API_TOKEN existe en todos los environments
   - Lista todos los secrets CF_API_TOKEN a eliminar

2. **Confirmación Manual**
   - Requiere escribir 'DELETE' para confirmar
   - Operación irreversible

3. **Eliminación Progresiva**
   - Repository level
   - Environment: preview
   - Environment: production

4. **Verificación Final**
   - Confirma que todos los secrets fueron eliminados
   - Valida ausencia de CF_API_TOKEN

5. **Documentación Post-Eliminación**
   - Actualizar `github_secrets_inventory.md`
   - Marcar como 'Eliminado' en `legacy_cleanup_plan.md`
   - Registrar en `monitoring_log.md`
   - Cerrar milestone

### Rollback en Emergencia

Si se detectan fallos críticos post-eliminación:

```bash
# Recrear secret desde backup seguro
gh secret set CF_API_TOKEN --body "BACKUP_TOKEN_VALUE" --repo RunArtFoundry/runart-foundry
gh secret set CF_API_TOKEN --body "BACKUP_TOKEN_VALUE" --env preview --repo RunArtFoundry/runart-foundry
gh secret set CF_API_TOKEN --body "BACKUP_TOKEN_VALUE" --env production --repo RunArtFoundry/runart-foundry
```

⚠️ **IMPORTANTE**: Mantener backup seguro de CF_API_TOKEN hasta 30 días post-eliminación.

## �📝 Log de Cambios

| Fecha | Cambio | Responsable |
|-------|--------|-------------|
| 2025-10-14 | Creación inicial del runbook | Automated CI audit |
| 2025-10-14 | Migración a tokens canónicos | Automated CI audit |
| 2025-10-14 | Validación final completada | CI Copilot closure audit |
| 2025-10-14 | Procedimiento de eliminación legacy agregado | CI Copilot post-merge |
| 2025-10-14 | Script automatizado de cleanup creado | CI Copilot post-merge |

---

**Próxima revisión:** 2026-01-14  
**Contacto:** Issues en GitHub para soporte  
**Estado:** ✅ Validado y operacional