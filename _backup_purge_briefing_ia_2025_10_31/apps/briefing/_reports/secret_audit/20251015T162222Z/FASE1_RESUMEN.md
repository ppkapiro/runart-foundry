# Auditoría de Secretos/KV/Access — FASE 1 Resumen

**Fecha:** 2025-10-15 16:27 UTC  
**Auditor:** GitHub Copilot  
**Objetivo:** Inventario completo de credenciales y configuración para diagnosticar desalineación CI/Local

---

## Hallazgos Principales

### ✅ Local (~/.runart/env)
- **CLOUDFLARE_API_TOKEN**: PRESENTE (40 caracteres) ✅
- **CLOUDFLARE_ACCOUNT_ID**: PRESENTE (32 caracteres) ✅
- **NAMESPACE_ID_RUNART_ROLES_PREVIEW**: PRESENTE (32 caracteres) ✅
- **ACCESS_CLIENT_ID**: PRESENTE (40 caracteres) ✅
- **ACCESS_CLIENT_SECRET**: PRESENTE (64 caracteres) ✅
- **ACCESS_CLIENT_ID_PREVIEW**: AUSENTE ⚠️
- **ACCESS_CLIENT_SECRET_PREVIEW**: AUSENTE ⚠️

### ⚠️ GitHub Actions Secrets
**Secrets existentes:**
- ACCESS_CLIENT_ID (2025-10-13)
- ACCESS_CLIENT_SECRET (2025-10-13)
- CF_ACCOUNT_ID (2025-10-13) ← DUPLICADO
- CF_API_TOKEN (2025-10-13) ← DUPLICADO
- CLOUDFLARE_ACCOUNT_ID (2025-10-13) ✅
- CLOUDFLARE_API_TOKEN (2025-10-13) ✅
- RUNART_ROLES_KV_PREVIEW (2025-10-13) ← NOMBRE INCORRECTO
- RUNART_ROLES_KV_PROD (2025-10-13)

**Secrets faltantes para estándar:**
- ❌ ACCESS_CLIENT_ID_PREVIEW (necesita sufijo)
- ❌ ACCESS_CLIENT_SECRET_PREVIEW (necesita sufijo)
- ❌ NAMESPACE_ID_RUNART_ROLES_PREVIEW (nombre correcto)

**Duplicados a eliminar:**
- CF_ACCOUNT_ID → usar solo CLOUDFLARE_ACCOUNT_ID
- CF_API_TOKEN → usar solo CLOUDFLARE_API_TOKEN

### ⚠️ wrangler.toml
**Producción:**
- RUNART_ROLES id: `26b8c3ca432946e2a093dcd33163f9e2` ✅

**Preview (global):**
- RUNART_ROLES preview_id: `7d80b07de98e4d9b9d5fd85516901ef6` ⚠️

**DESALINEACIÓN DETECTADA:**
- Local/scripts configurados con: `26b8c3ca432946e2a093dcd33163f9e2` (namespace producción)
- wrangler.toml preview_id: `7d80b07de98e4d9b9d5fd85516901ef6` (namespace preview)
- **Causa raíz:** Estábamos sembrando en el namespace de producción en vez del namespace de preview

### ✅ Cloudflare API
**Token:** Activo y válido ✅  
**Cuenta:** a2c7fc66f00eab69373e448193ae7201 (Ppcapiro@gmail.com's Account) ✅

**Namespaces KV disponibles:**
| ID | Título | Uso |
|----|--------|-----|
| 26b8c3ca432946e2a093dcd33163f9e2 | RUNART_ROLES | Producción ✅ |
| 7d80b07de98e4d9b9d5fd85516901ef6 | RUNART_ROLES_preview | Preview (correcto) ✅ |
| d451f02b0c9e4e0db1c28116c04f1cb1 | runart_roles_preview | Legacy preview |
| 61a106d64d07458e9fc919d8582438fd | runart_roles_prod | Legacy prod |
| 3d40c644267b4d93aa58c6a471eb5f22 | preview2-RUNART_ROLES_preview2 | Preview2 ✅ |

**Sonda KV:** PUT/GET/DELETE exitosos en namespace `26b8c3ca432946e2a093dcd33163f9e2` ✅

---

## Diagnóstico

### Problema Principal
**El workflow de CI falla porque:**
1. Secretos tienen nombres inconsistentes (duplicados CF_ vs CLOUDFLARE_)
2. El namespace ID usado en scripts locales (`26b8c3ca432946e2a093dcd33163f9e2`) es el de **producción**, no el de **preview** (`7d80b07de98e4d9b9d5fd85516901ef6`)
3. GitHub Actions no tiene `NAMESPACE_ID_RUNART_ROLES_PREVIEW` con el valor correcto
4. Access service token no tiene sufijo `_PREVIEW` en los secretos de CI

### Acciones Correctivas FASE 2

#### A) Actualizar namespace ID local y secretos CI
- **Local:** Cambiar `NAMESPACE_ID_RUNART_ROLES_PREVIEW` de producción a preview: `7d80b07de98e4d9b9d5fd85516901ef6`
- **CI:** Crear `NAMESPACE_ID_RUNART_ROLES_PREVIEW=7d80b07de98e4d9b9d5fd85516901ef6`
- **CI:** Renombrar `RUNART_ROLES_KV_PREVIEW` → eliminar (nombre legacy)

#### B) Normalizar nombres de secretos CI
- Mantener: `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`
- Eliminar duplicados: `CF_API_TOKEN`, `CF_ACCOUNT_ID`
- Renombrar: `ACCESS_CLIENT_ID` → `ACCESS_CLIENT_ID_PREVIEW`
- Renombrar: `ACCESS_CLIENT_SECRET` → `ACCESS_CLIENT_SECRET_PREVIEW`

#### C) Validar Access policy
- Verificar que el service token en `ACCESS_CLIENT_ID_PREVIEW` esté en la policy de `runart-foundry.pages.dev/api/whoami`
- Sin "Require One-time PIN" para CI

---

## Próximos Pasos

✅ **FASE 1 completada:** Inventario y diagnóstico  
🔄 **FASE 2 en progreso:** Normalización de secretos  
⏳ **FASE 3 pendiente:** Siembra KV en namespace preview correcto  
⏳ **FASE 4 pendiente:** CI diagnóstico con secretos alineados  
⏳ **FASE 5 pendiente:** Gobernanza y blindaje

**Archivo de evidencias:** `apps/briefing/_reports/secret_audit/20251015T162222Z/`
