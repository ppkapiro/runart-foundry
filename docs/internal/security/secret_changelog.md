# Bitácora de Cambios de Secretos — RUNART

Este archivo registra todos los cambios a secretos y credenciales del proyecto.

---

## 2025-10-15 | Validación headers canary preview (bloqueado)

- **Acción:** Ajuste de middleware Pages Functions para fijar las cabeceras `X-RunArt-Canary: preview` y `X-RunArt-Resolver: utils` en `/api/whoami`.
- **Validación:** `tools/diagnostics/run_preview_validation.sh` → `docs/internal/security/evidencia/RUN_PREVIEW_VALIDATION_20251015_2000.log` (HTTP 200 sin headers).
- **CI:** `run_canary_diagnostics.yml` (`run_id=18541050889`) generó `docs/internal/security/evidencia/RESUMEN_PREVIEW_20251015_1601.md` con cabeceras `?`.
- **Seguimiento:** `pages-preview.yml` (`run_id=18540927697`) falló con `Authentication error`; issue `#46` abierto para habilitar `feat-ci-access-service-token-verification.runart-foundry.pages.dev`.
- **Pendiente:** Actualizar token de Cloudflare, redeploy preview y repetir validaciones.

## 2025-10-15 | Normalización Completa de Secretos (Auditoría Inicial)

### CLOUDFLARE_API_TOKEN
- **Acción:** Rotación + actualización CI
- **Quién:** DevOps (GitHub Copilot)
- **Por qué:** Auditoría inicial + token anterior sin permisos KV
- **Nuevo valor:** Token con Workers KV Storage:Edit
- **Validación:** smoke_secret_health.sh ✅
- **Incidentes:** Ninguno

### CLOUDFLARE_ACCOUNT_ID
- **Acción:** Normalización (sin cambio de valor)
- **Quién:** DevOps (GitHub Copilot)
- **Por qué:** Eliminar duplicados (CF_ACCOUNT_ID)
- **Validación:** Presente en CI y local ✅
- **Incidentes:** Ninguno

### NAMESPACE_ID_RUNART_ROLES_PREVIEW
- **Acción:** Corrección de namespace (prod → preview)
- **Quién:** DevOps (GitHub Copilot)
- **Por qué:** Desalineación detectada, apuntaba a namespace de producción
- **Valor anterior:** `26b8c3ca432946e2a093dcd33163f9e2` (producción)
- **Valor nuevo:** `7d80b07de98e4d9b9d5fd85516901ef6` (preview)
- **Validación:** KV sembrado y legible en CI ✅
- **Incidentes:** Ninguno

### ACCESS_CLIENT_ID_PREVIEW
- **Acción:** Renombrado (añadir sufijo _PREVIEW)
- **Quién:** DevOps (GitHub Copilot)
- **Por qué:** Estandarización de nombres
- **Nombre anterior:** `ACCESS_CLIENT_ID`
- **Nombre nuevo:** `ACCESS_CLIENT_ID_PREVIEW`
- **Validación:** Presente en CI ✅
- **Incidentes:** Service token no autorizado en policy (pendiente manual)

### ACCESS_CLIENT_SECRET_PREVIEW
- **Acción:** Renombrado (añadir sufijo _PREVIEW)
- **Quién:** DevOps (GitHub Copilot)
- **Por qué:** Estandarización de nombres
- **Nombre anterior:** `ACCESS_CLIENT_SECRET`
- **Nombre nuevo:** `ACCESS_CLIENT_SECRET_PREVIEW`
- **Validación:** Presente en CI ✅
- **Incidentes:** Service token no autorizado en policy (pendiente manual)

### Secretos Eliminados (Duplicados)
- `CF_ACCOUNT_ID` → migrado a `CLOUDFLARE_ACCOUNT_ID`
- `CF_API_TOKEN` → migrado a `CLOUDFLARE_API_TOKEN`
- `RUNART_ROLES_KV_PREVIEW` → migrado a `NAMESPACE_ID_RUNART_ROLES_PREVIEW`
- `RUNART_ROLES_KV_PROD` → eliminado (no usado)
- `CF_LOG_EVENTS_ID` → eliminado (no usado)
- `CF_LOG_EVENTS_PREVIEW_ID` → eliminado (no usado)
- `CLOUDFLARE_PROJECT_NAME` → eliminado (hardcoded en workflow)

### Resultado
- ✅ 7 secretos duplicados eliminados
- ✅ 5 secretos estándar establecidos
- ✅ KV operacional en CI
- ⚠️ Access pendiente autorización manual

### Evidencias
- Auditoría completa: `apps/briefing/_reports/secret_audit/20251015T162222Z/`
- Run ID diagnóstico exitoso: `18535891873`
- Health check: PASSED ✅

---

## 2025-10-15 | Verificación de Service Token en Preview

### ACCESS_CLIENT_ID_PREVIEW + ACCESS_CLIENT_SECRET_PREVIEW
- **Acción:** Verificación y autorización en policy de Cloudflare Access
- **Quién:** DevOps (GitHub Copilot + Manual)
- **Por qué:** Service token no autorizado en policy, retornaba HTTP 302 en /api/whoami
- **Pasos:**
  1. Crear herramienta de verificación local: `tools/diagnostics/verify_access_service_token.mjs`
  2. Actualizar policy de Access en dashboard de Cloudflare para incluir Service Token `runart-ci-diagnostics`
  3. Ejecutar verificación local: `npm run verify:access:preview`
  4. Disparar workflow CI: `gh workflow run run_canary_diagnostics.yml -f worker_name=run-briefing -f kv_namespace=preview`
  5. Descargar RESUMEN: `npm run canary:post` (o manualmente con `gh run download`)
- **Validación:** Pendiente (requiere autorización manual en Cloudflare)
- **Evidencia esperada:** 
  - RESUMEN con HTTP 200, X-RunArt-Canary y X-RunArt-Resolver presentes
  - Archivo guardado en: `docs/internal/security/evidencia/RESUMEN_PREVIEW_YYYYMMDD_HHMM.md`
  - Run ID: `[PENDIENTE - completar después de ejecución]`
- **TTL actual:** 180 días (próxima rotación: 2026-04-13)
- **Incidentes:** Ninguno (una vez completada la autorización)

---

## Próximas Rotaciones Programadas

| Secreto | Próxima Rotación | Frecuencia |
|---------|------------------|------------|
| CLOUDFLARE_API_TOKEN | 2026-01-13 | 90 días |
| ACCESS_CLIENT_ID_PREVIEW | 2026-04-13 | 180 días |
| ACCESS_CLIENT_SECRET_PREVIEW | 2026-04-13 | 180 días |

---

**Formato de nuevos registros:**

```markdown
## YYYY-MM-DD | NOMBRE_SECRETO
- **Acción:** Rotación / Actualización / Corrección / Eliminación
- **Quién:** Nombre / Equipo
- **Por qué:** Razón del cambio
- **Validación:** Resultado del health check
- **Incidentes:** Descripción o "Ninguno"
```
