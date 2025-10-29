# CI/Access (preview): verificación de service token y cierre de diagnóstico

## 📋 Resumen

Este PR implementa la infraestructura completa para verificar y documentar el Service Token de Cloudflare Access (`runart-ci-diagnostics`) en el entorno preview, permitiendo el cierre del pipeline de diagnóstico canary con evidencia trazable.

## 🎯 Objetivo

Verificar que el Service Token de Access funciona correctamente en el entorno preview, validando que:
- `/api/whoami` responde con HTTP 200
- Los headers `X-RunArt-Canary` y `X-RunArt-Resolver` están presentes
- El token está correctamente autorizado en la policy de Cloudflare Access

## 🔧 Cambios Implementados

### 1. Herramientas de Verificación

#### `tools/diagnostics/verify_access_service_token.mjs`
- **Propósito:** Verificador local del Service Token de Access
- **Uso:** `npm run verify:access:preview` (desde `apps/briefing/`)
- **Valida:**
  - Credenciales `ACCESS_CLIENT_ID_PREVIEW` y `ACCESS_CLIENT_SECRET_PREVIEW` en el entorno
  - Request GET a `/api/whoami` con headers `CF-Access-Client-Id` y `CF-Access-Client-Secret`
  - Status HTTP 200
  - Presencia de headers `X-RunArt-Canary` y `X-RunArt-Resolver`
- **Salida:** Código 0 si exitoso, 1 si falla con diagnóstico detallado

#### `tools/diagnostics/postprocess_canary_summary.sh` (bash)
- **Propósito:** Descarga artifacts del workflow de diagnóstico
- **Uso:** `npm run canary:post` (desde `apps/briefing/`)
- **Acciones:**
  1. Busca el último run exitoso de `run_canary_diagnostics.yml`
  2. Descarga los artifacts usando `gh run download`
  3. Extrae el archivo `RESUMEN_*.md`
  4. Lo copia a `docs/internal/security/evidencia/RESUMEN_PREVIEW_YYYYMMDD_HHMM.md`
  5. Imprime run_id y ruta para documentación en changelog

#### `tools/diagnostics/postprocess_canary_summary.ps1` (PowerShell)
- Versión PowerShell del script anterior para compatibilidad Windows

### 2. Mejoras en Scripts Existentes

#### `apps/briefing/scripts/fetch_whoami_headers.mjs`
- **Mejora:** Soporte para headers de Service Token de Access
- **Cambios:**
  - Lee `CF_ACCESS_CLIENT_ID` y `CF_ACCESS_CLIENT_SECRET` del entorno
  - Incluye headers `CF-Access-Client-Id` y `CF-Access-Client-Secret` en requests
  - Manejo de redirects manual para detectar bloqueos de Access (HTTP 302)
  - Mejor formato de output con status text

### 3. Actualización de package.json

Nuevos scripts en `apps/briefing/package.json`:
```json
"verify:access:preview": "node ../../tools/diagnostics/verify_access_service_token.mjs",
"canary:post": "bash ../../tools/diagnostics/postprocess_canary_summary.sh"
```

### 4. Documentación

#### `docs/internal/security/HOWTO_access_ci_preview.md`
- **Guía completa** con comandos bash para:
  1. Actualizar secrets en GitHub (`gh secret set`)
  2. Verificación local del token
  3. Disparar workflow de diagnóstico
  4. Descargar y procesar artifacts
  5. Actualizar changelog con run_id y evidencia
  6. Commit y push de cambios
- **Troubleshooting:** Diagnóstico de errores comunes (HTTP 302, headers ausentes, etc.)
- **Criterios de aceptación:** Checklist completa para validar la implementación

#### `docs/internal/security/secret_changelog.md`
- **Nueva bitácora** de cambios de secretos del proyecto
- **Incluye:**
  - Auditoría inicial de secretos (2025-10-15)
  - Normalización y renombrado de secrets (eliminación de duplicados)
  - Entrada para verificación de Service Token (con placeholders para run_id y evidencia)
  - Tabla de próximas rotaciones programadas

#### `docs/internal/security/evidencia/.gitkeep`
- Carpeta para almacenar archivos `RESUMEN_PREVIEW_*.md` generados automáticamente

## 🔐 Secrets Requeridos

Los siguientes secrets deben estar configurados en el repositorio GitHub:

- `ACCESS_CLIENT_ID_PREVIEW`: Client ID del Service Token de Cloudflare Access
- `ACCESS_CLIENT_SECRET_PREVIEW`: Client Secret del Service Token

**Para configurar:**
```bash
gh secret set ACCESS_CLIENT_ID_PREVIEW --body "tu_client_id"
gh secret set ACCESS_CLIENT_SECRET_PREVIEW --body "tu_client_secret"
```

## ✅ Criterios de Aceptación

- [x] Verificador local creado y funcional
- [x] Scripts de postprocesamiento (bash y PowerShell) implementados
- [x] Scripts npm agregados a `package.json`
- [x] Documentación HOWTO completa con comandos manuales
- [x] Changelog de secretos creado con entrada para Service Token
- [x] Carpeta de evidencia preparada
- [x] Script `fetch_whoami_headers.mjs` actualizado con soporte para Access
- [ ] Verificación local exitosa (requiere secrets configurados)
- [ ] Workflow CI ejecutado con éxito (pendiente tras merge)
- [ ] Evidencia RESUMEN descargada y documentada (post-ejecución)

## 🚀 Próximos Pasos (Post-Merge)

1. **Configurar secrets en GitHub:**
   ```bash
   gh secret set ACCESS_CLIENT_ID_PREVIEW --body "<valor>"
   gh secret set ACCESS_CLIENT_SECRET_PREVIEW --body "<valor>"
   ```

2. **Autorizar Service Token en Cloudflare Access:**
   - Dashboard → Access → Aplicación "RUN Briefing"
   - Policy → Agregar regla de Allow para Service Token `runart-ci-diagnostics`
   - **Importante:** Colocar la regla ANTES de las reglas de OTP/Login

3. **Verificación local:**
   ```bash
   export ACCESS_CLIENT_ID_PREVIEW="<valor>"
   export ACCESS_CLIENT_SECRET_PREVIEW="<valor>"
   cd apps/briefing
   npm run verify:access:preview
   ```

4. **Ejecutar workflow de diagnóstico:**
   ```bash
   gh workflow run run_canary_diagnostics.yml
   gh run watch --exit-status
   ```

5. **Descargar evidencia:**
   ```bash
   npm run canary:post
   ```

6. **Actualizar changelog:**
   - Editar `docs/internal/security/secret_changelog.md`
   - Agregar run_id y ruta del RESUMEN
   - Commit y push

## 📊 Archivos Modificados

```
apps/briefing/package.json                        | +4 -1 (nuevos scripts)
apps/briefing/scripts/fetch_whoami_headers.mjs    | +24 -5 (soporte Access)
docs/internal/security/HOWTO_access_ci_preview.md | +267 (nuevo)
docs/internal/security/evidencia/.gitkeep         | +2 (nuevo)
docs/internal/security/secret_changelog.md        | +114 (nuevo)
tools/diagnostics/postprocess_canary_summary.ps1  | +134 (nuevo)
tools/diagnostics/postprocess_canary_summary.sh   | +119 (nuevo)
tools/diagnostics/verify_access_service_token.mjs | +149 (nuevo)
---
Total: 8 archivos, +808 inserciones, -5 eliminaciones
```

## 🧪 Testing

**Verificación manual local:**
```bash
cd apps/briefing
export ACCESS_CLIENT_ID_PREVIEW="test_value"
export ACCESS_CLIENT_SECRET_PREVIEW="test_secret"
node ../../tools/diagnostics/verify_access_service_token.mjs
```

**Validación de scripts bash:**
```bash
bash -n tools/diagnostics/postprocess_canary_summary.sh  # syntax check
```

## 📝 Notas

- **TTL del Service Token:** 180 días desde creación
- **Próxima rotación:** ~2026-04-13 (aproximado, verificar en dashboard)
- **Workflow compatible:** `run_canary_diagnostics.yml` ya usa los secrets correctos
- **Cross-platform:** Scripts bash y PowerShell para máxima compatibilidad

## 🔗 Referencias

- Workflow: `.github/workflows/run_canary_diagnostics.yml`
- Cloudflare Access Dashboard: https://one.dash.cloudflare.com/
- GitHub CLI Docs: https://cli.github.com/manual/

---

**Commit:** `b3bfb9e` - `chore(ci/access): verificación de Service Token preview + canary evidence & changelog`
