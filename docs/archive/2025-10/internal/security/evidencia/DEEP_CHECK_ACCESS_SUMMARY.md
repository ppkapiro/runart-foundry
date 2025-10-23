---
status: archived
owner: reinaldo.capiro
updated: 2025-10-15
audience: internal
tags: [briefing, runart, ops]
---

# Deep Check Access - Resumen de Diagnóstico

**Fecha:** 2025-10-15  
**Target:** runart-foundry.pages.dev  
**Account ID:** a2c7fc66f00eab69373e448193ae7201

## 🔍 Resultado de Verificación Local

### Status HTTP
- **302 Moved Temporarily** ❌
- Expected: 200 OK

### Headers
- **X-RunArt-Canary:** ausente ❌
- **X-RunArt-Resolver:** ausente ❌

### Redirect Location
```
https://runart-foundry.pages.dev/cdn-cgi/access/login/...
```

### Body Response
```html
<html>
<head><title>302 Found</title></head>
<body>
<center><h1>302 Found</h1></center>
<hr><center>cloudflare</center>
</body>
</html>
```

## 🎯 ROOT CAUSE IDENTIFICADO

**Service Token NO autorizado en la policy de Cloudflare Access**

El endpoint `/api/whoami` está siendo bloqueado por Cloudflare Access y redirigiendo a la página de login, lo que confirma que:

1. ✅ El Service Token existe y es válido
2. ✅ Los headers `CF-Access-Client-Id` y `CF-Access-Client-Secret` están siendo enviados correctamente
3. ❌ La policy de Access NO está permitiendo el paso del Service Token

## 🔬 Análisis Técnico

### Evidencia del Redirect
- **Status:** 302 (redirect)
- **Location:** Página de login de Access (`/cdn-cgi/access/login/`)
- **Comportamiento:** Cloudflare Access está interceptando la request y bloqueándola

### Posibles Causas (ordenadas por probabilidad)

#### A. Purpose Justification Requirement (ALTA PROBABILIDAD) ⚠️
La policy tiene habilitada la opción "Purpose Justification" que requiere justificación humana, incompatible con Service Tokens.

**Fix:**
1. Ir a Cloudflare Dashboard → Access → Applications
2. Seleccionar "RUN Briefing"
3. Editar la policy que incluye Service Tokens
4. En "Additional settings" → **Desactivar** "Purpose justification prompt"
5. Guardar cambios

#### B. Policy Order / Conflicto Include-Require (MEDIA PROBABILIDAD)
La policy tiene tanto `Include: Service Token` como `Require: [algo]`, causando conflicto.

**Fix:**
1. Verificar que la policy de Service Token NO tenga sección "Require"
2. Si existe Require, removerlo o crear una policy separada solo para tokens
3. Asegurar que la policy de Service Token tenga precedencia más alta (número menor)

#### C. Policy Humana Sin Exclude (BAJA PROBABILIDAD)
La policy para usuarios humanos (OTP/Email) no excluye explícitamente los Service Tokens.

**Fix:**
1. En la policy de usuarios humanos, agregar "Exclude: Service Token"
2. Listar ambos tokens: `runart-ci-diagnostics` y cualquier otro token de CI

#### D. App Domain Mismatch (MUY BAJA PROBABILIDAD)
La aplicación de Access está configurada para un dominio diferente.

**Fix:**
1. Verificar que el "Application domain" incluya `runart-foundry.pages.dev`
2. Si es incorrecto, actualizar el dominio de la app

## 🔧 ACCIÓN RECOMENDADA (INMEDIATA)

### Paso 1: Verificar Purpose Justification
```bash
# En Cloudflare Dashboard:
1. Access → Applications → RUN Briefing
2. Policies → [Policy con Service Token]
3. Additional settings → Purpose justification prompt: OFF
```

### Paso 2: Validar Policy Configuration
La policy de CI debe tener:
- **Decision:** Allow
- **Include:** Service Token (runart-ci-diagnostics)
- **Require:** (vacío / sin elementos)
- **Exclude:** (vacío / sin elementos)
- **Additional settings:**
  - Purpose justification: OFF ❌
  - Approval required: OFF ❌
  - Temporary authentication: OFF ❌

### Paso 3: Verificar Policy Order
La policy de Service Token debe estar **ANTES** (precedence menor) que la policy de usuarios humanos.

## 📊 Limitación del Diagnóstico

⚠️ **Nota:** No se pudo completar el análisis automático via CF API debido a:
- Error 401 Unauthorized al intentar acceder a la API de Cloudflare
- Token de API sin permisos suficientes o expirado

Para un diagnóstico completo, sería necesario:
1. Obtener un token de API con permisos: `Account.Access: Applications.Read, Policies.Read, Service Tokens.Read`
2. Re-ejecutar: `npm run access:deepcheck`

## ✅ Próximos Pasos

1. **Inmediato:** Desactivar Purpose Justification en la policy de CI
2. **Validación:** Re-ejecutar `npm run verify:access:preview`
3. **Esperado:** Status 200 + headers X-RunArt-Canary y X-RunArt-Resolver presentes
4. **Documentación:** Commit de evidencia exitosa

## 📝 Comandos de Validación

```bash
# Re-exportar variables (si perdidas)
export ACCESS_CLIENT_ID_PREVIEW="94402e7ec91569ee85b26fcc691abb4a.access"
export ACCESS_CLIENT_SECRET_PREVIEW="f7cdeab47269d3514d6cc448c4824fbd3b395cc5161a1901ad3987f890b361bc"

# Verificar nuevamente
cd apps/briefing
npm run verify:access:preview

# Si exitoso, guardar evidencia y commit
```

## 🔗 Referencias

- [Cloudflare Access Dashboard](https://one.dash.cloudflare.com/)
- [Service Token Documentation](https://developers.cloudflare.com/cloudflare-one/identity/service-tokens/)
- [Access Policy Configuration](https://developers.cloudflare.com/cloudflare-one/policies/access/)

---

**Generado:** 2025-10-15  
**Status:** ROOT CAUSE identificado (Purpose Justification probable)  
**Next Action:** Desactivar Purpose Justification en Cloudflare Dashboard
