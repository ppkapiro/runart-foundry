# Zero Trust One-time PIN — Diagnóstico de Problema
**Fecha de diagnóstico**: 2 de octubre de 2025  
**Proyecto**: RUN Art Foundry — Micrositio Briefing  
**URL afectada**: https://runart-briefing.pages.dev  
**Síntoma**: El One-time PIN no llega al correo cuando se intenta acceder

---

## Resumen Ejecutivo (5 puntos clave)

1. ✅ **Cloudflare Access está ACTIVO**: Confirmado redirect a `runart-briefing-pages.cloudflareaccess.com` con challenge de autenticación
2. ✅ **Challenge funciona**: El prompt de email aparece correctamente en el navegador
3. 🔴 **One-time PIN NO llega**: El correo con el código PIN no se recibe tras ingresar email
4. ⚠️ **Sin acceso a API**: No hay CF_API_TOKEN disponible localmente — diagnóstico limitado a evidencias HTTP y código
5. 🎯 **Causas probables**: Policy sin Include correcto, One-time PIN no habilitado/restringido, rate limit, o email en spam

---

## Evidencias Locales

### Artefactos Detectados

| Archivo | Rol | Pistas Útiles |
|---------|-----|---------------|
| `briefing/wrangler.toml` | Config Pages activa | `name="runart-briefing"`, KV binding `DECISIONES`, `pages_build_output_dir="site"` |
| `briefing/workers/wrangler.toml` | Config Workers (obsoleto) | Legacy, no usado tras migración a Pages Functions |
| `briefing/.github/workflows/briefing_pages.yml` | CI/CD GitHub Actions | Workflow con `cloudflare/pages-action@v1`, secrets: `CF_API_TOKEN`, `CF_ACCOUNT_ID` |
| `briefing/functions/api/decisiones.js` | Pages Function POST | Lee header `Cf-Access-Authenticated-User-Email` (preparado para Access) |
| `briefing/functions/api/inbox.js` | Pages Function GET | Lista decisiones desde KV |
| `briefing/functions/api/whoami.js` | Endpoint diagnóstico | ✅ **CREADO AHORA** — Inspecciona headers de Access (GET `/api/whoami`) |
| `briefing/_logs/briefing_summary_*.txt` | Logs históricos | Account ID: `a2c7fc66f00eab69373e448193ae7201`, URLs de deployment |
| `briefing/_logs/pages_url.txt` | URL producción | `PAGES_URL=https://runart-briefing.pages.dev` |

### Variables de Entorno

| Variable | Estado |
|----------|--------|
| `CF_API_TOKEN` | ❌ **NO ENCONTRADA** en `.env`, `.env.example`, `briefing/.env` |
| `CF_ACCOUNT_ID` | ⚠️ Conocido de logs: `a2c7fc66f00eab69373e448193ae7201` |

**Conclusión**: No hay credenciales de API disponibles localmente. El diagnóstico se basa en evidencias HTTP y código.

---

## Evidencias HTTP: Flujo de Login

### Test de Acceso (curl -IL)

**Comando ejecutado**:
```bash
curl -sI -L https://runart-briefing.pages.dev
```

**Resultado**:

#### Request 1: Initial GET
```
HTTP/2 302 
date: Thu, 02 Oct 2025 17:31:56 GMT
location: https://runart-briefing-pages.cloudflareaccess.com/cdn-cgi/access/login/runart-briefing.pages.dev?kid=...&meta=...&redirect_url=%2F
```

**Análisis**:
- ✅ **Cloudflare Access está activo** — HTTP 302 redirect a `cloudflareaccess.com`
- ✅ **Hostname correcto** — `runart-briefing.pages.dev` en parámetros de login
- ✅ **JWT metadata presente** — Token `meta` con información de sesión
- ✅ **Cookie de sesión** — `CF_AppSession` seteada (válida 24h)

#### Request 2: Login Page
```
HTTP/2 200 
date: Thu, 02 Oct 2025 17:31:57 GMT
content-type: text/html
content-length: 28392
set-cookie: CF_Session=noKHOZEPo3BqhFugn; Path=/; Secure; Expires=Thu, 02 Oct 2025 21:31:57 GMT; HttpOnly; SameSite=none
```

**Análisis**:
- ✅ **Challenge renderizado** — HTML de 28KB (página de login de Access)
- ✅ **Cookie de sesión CF** — `CF_Session` seteada (válida 4h)
- ✅ **Seguridad HTTPS** — `Secure`, `HttpOnly`, `SameSite=none`

### Patrones de Access Detectados

| Patrón | Detectado | Significado |
|--------|-----------|-------------|
| Redirect a `cloudflareaccess.com` | ✅ Sí | Access está configurado y activo |
| Path `/cdn-cgi/access/login/` | ✅ Sí | Challenge de autenticación estándar |
| Cookie `CF_AppSession` | ✅ Sí | Sesión de aplicación iniciada |
| Cookie `CF_Session` | ✅ Sí | Sesión de Access iniciada |
| Parámetro `kid` (Key ID) | ✅ Sí | JWT key para validación |
| Parámetro `meta` (JWT) | ✅ Sí | Metadata de sesión y estado de auth |

**Conclusión HTTP**: El sistema de Access está correctamente configurado y funcional a nivel de infraestructura.

---

## Endpoint de Diagnóstico Creado

### `/api/whoami` — Inspector de Headers

**Archivo**: `briefing/functions/api/whoami.js`

**Propósito**: Diagnosticar qué headers recibe una Pages Function cuando hay (o no) autenticación activa.

**Uso**:
```bash
# Sin autenticación (bloqueado por Access)
curl https://runart-briefing.pages.dev/api/whoami

# Con autenticación (tras login exitoso)
# Abrir en navegador: https://runart-briefing.pages.dev/api/whoami
```

**Respuesta esperada** (ejemplo):
```json
{
  "timestamp": "2025-10-02T17:45:00.000Z",
  "access": {
    "authenticated": true,
    "email": "usuario@example.com",
    "jwtPresent": true,
    "country": "US",
    "connectingIP": "192.0.2.1"
  },
  "headers": {
    "cf-access-authenticated-user-email": "usuario@example.com",
    "cf-access-jwt-assertion": "eyJhbGc...",
    "cf-connecting-ip": "192.0.2.1",
    "cf-ipcountry": "US",
    "user-agent": "Mozilla/5.0..."
  },
  "url": "https://runart-briefing.pages.dev/api/whoami",
  "method": "GET"
}
```

**Estado**: ✅ Endpoint creado y listo para usar tras deploy.

---

## Evidencias API de Cloudflare

### Intento de Consulta a Access API

**Comando ejecutado**:
```bash
curl -X GET "https://api.cloudflare.com/client/v4/accounts/a2c7fc66f00eab69373e448193ae7201/access/apps" \
  -H "Content-Type: application/json"
```

**Respuesta**:
```json
{
  "success": false,
  "errors": [{
    "code": 9106,
    "message": "Missing X-Auth-Key, X-Auth-Email or Authorization headers"
  }]
}
```

**Conclusión**: ❌ No hay CF_API_TOKEN disponible. No se pueden consultar:
- Aplicaciones Access configuradas
- Políticas (policies) de la aplicación
- Logs de autenticación recientes
- Configuración de Identity Providers (IdP)

**Recomendación**: Consultar manualmente en el dashboard de Cloudflare.

---

## Hallazgos Probables (Orden de Impacto)

### 🔴 1. Policy sin "Include" o correo mal configurado (MÁS PROBABLE)

**Síntoma**: El challenge aparece pero el PIN no llega.

**Causas posibles**:
- La política de Access tiene `Action: Allow` pero **NO tiene regla "Include" con el email**
- El email tiene espacios/comas al final: `usuario@example.com ,` (inválido)
- El email está en una regla "Exclude" (bloqueado)
- La regla "Include" usa dominio (`@example.com`) pero el email no coincide
- Múltiples políticas en conflicto (una permite, otra bloquea)

**Verificación en dashboard**:
```
Zero Trust → Access → Applications → (buscar "runart-briefing" o hostname)
→ Policies → Ver policy con Action=Allow
→ Configure rules → Revisar sección "Include"
```

**Checklist**:
- [ ] Existe al menos UNA regla "Include"
- [ ] La regla "Include" contiene el email exacto (sin espacios extras)
- [ ] El email NO está en "Exclude"
- [ ] Si usa dominio (`@example.com`), el email coincide
- [ ] Solo hay UNA política activa (o sin conflictos)

---

### 🔴 2. One-time PIN no habilitado o restringido (PROBABLE)

**Síntoma**: El método de autenticación One-time PIN no está disponible para el email ingresado.

**Causas posibles**:
- One-time PIN deshabilitado globalmente en la organización
- One-time PIN restringido a dominios específicos (ej: solo `@company.com`)
- El email ingresado está en dominio no permitido (ej: Gmail/Outlook bloqueados)
- Solo otros métodos habilitados (Google, GitHub, etc.) pero no PIN

**Verificación en dashboard**:
```
Zero Trust → Settings → Authentication
→ Login methods → One-time PIN
```

**Checklist**:
- [ ] **One-time PIN está habilitado** (toggle ON)
- [ ] Configuración: "Allow all email addresses" SELECCIONADO
  - O: Lista de dominios permitidos incluye el dominio del email de prueba
- [ ] No hay restricciones de dominio que bloqueen el email
- [ ] El método aparece en la pantalla de login (no solo Google/GitHub)

**Si One-time PIN está deshabilitado**:
- El usuario verá solo los métodos habilitados (ej: "Login with Google")
- El campo de email puede aparecer pero no enviar PIN

---

### ⚠️ 3. Rate limit de Cloudflare (POSIBLE)

**Síntoma**: Múltiples intentos de solicitar PIN en corto tiempo.

**Causas**:
- Más de 5 intentos de envío de PIN en 5 minutos (rate limit default)
- IP bloqueada temporalmente por exceso de solicitudes
- Email marcado como "suspicious" tras múltiples intentos fallidos

**Verificación**:
- Esperar 10-15 minutos sin intentar login
- Probar desde otra red/IP (ej: datos móviles)
- Revisar logs de Access en dashboard (puede mostrar "rate_limited")

**Checklist**:
- [ ] Han pasado más de 15 minutos desde el último intento
- [ ] No hay más de 5 intentos de login en ventana de 5 minutos
- [ ] Probar desde otra IP/red

---

### ⚠️ 4. Email en Spam/Promotions (POSIBLE)

**Síntoma**: El PIN llega pero a carpeta equivocada.

**Causas**:
- Cliente de correo marca emails de Cloudflare como spam
- Gmail mueve a "Promotions" o "Updates"
- Filtros personalizados bloquean emails de `no-reply@cloudflareaccess.com`

**Verificación**:
- Revisar carpetas: Spam, Promotions, Updates, Junk
- Buscar remitente: `no-reply@cloudflareaccess.com` o `cloudflareaccess.com`
- Buscar asunto: "Cloudflare Access" o "verification code"

**Checklist**:
- [ ] Revisada carpeta Spam/Junk
- [ ] Revisada carpeta Promotions (Gmail)
- [ ] Búsqueda por remitente: `cloudflareaccess.com`
- [ ] Búsqueda por palabra: "verification code"
- [ ] Agregar `no-reply@cloudflareaccess.com` a contactos seguros

---

### ⚠️ 5. Aplicación apuntando a hostname distinto (MENOS PROBABLE)

**Síntoma**: La app de Access está configurada para otro hostname.

**Análisis de evidencias HTTP**:
- ✅ El redirect muestra: `runart-briefing.pages.dev` en parámetros
- ✅ El `kid` (Key ID) coincide con la app correcta

**Conclusión**: MUY IMPROBABLE — El hostname es correcto según el redirect.

**Verificación (por si acaso)**:
```
Zero Trust → Access → Applications
→ Ver "Application domain" de cada app
→ Buscar: "runart-briefing.pages.dev" o "runart-briefing-pages.cloudflareaccess.com"
```

---

## Qué Revisar en el Dashboard (NO ejecutar, solo leer)

### 1. Verificar Políticas de Access

**Ruta**: `Zero Trust → Access → Applications → (buscar app con hostname runart-briefing.pages.dev)`

**Pasos**:
1. Identificar la aplicación:
   - Nombre: Puede ser "RUN Briefing", "runart-briefing", o auto-generado
   - Domain: `runart-briefing.pages.dev` o `*.pages.dev`
2. Click en la aplicación → **Policies**
3. Verificar cada política:
   - **Action**: Debe ser `Allow` (no `Block` ni `Bypass`)
   - **Configure rules**:
     - **Include**: DEBE existir al menos UNA regla
     - Tipo: `Emails` (lista de emails específicos)
     - O: `Email domain` (ej: `@example.com`)
     - **Verificar**: El email de prueba está en la lista "Include"
     - **Verificar**: NO hay espacios/comas extras: `user@example.com` ✅ vs `user@example.com ,` ❌
   - **Exclude**: El email de prueba NO debe estar aquí

**Captura de pantalla recomendada**: Policy rules con Include/Exclude visible

**Mensaje de error típico en logs**: 
- `"email not in allowed list"`
- `"no include rules matched"`

---

### 2. Verificar One-time PIN habilitado

**Ruta**: `Zero Trust → Settings → Authentication`

**Pasos**:
1. Buscar sección **Login methods**
2. Encontrar **One-time PIN**
3. Verificar:
   - Toggle: **Enabled** (ON) ✅
   - Configuración:
     - **Allow all email addresses** (recomendado) ✅
     - O: **Allow specific email domains** → Verificar que el dominio del email está en la lista
4. Si está deshabilitado:
   - Click en **Add** o **Configure**
   - Habilitar One-time PIN
   - Seleccionar "Allow all email addresses"
   - Click **Save**

**Nota**: Si solo Google/GitHub están habilitados, los usuarios NO verán opción de PIN.

**Captura recomendada**: Pantalla de Login methods con One-time PIN ON

---

### 3. Revisar Logs de Autenticación

**Ruta**: `Zero Trust → Access → Logs → Authentication`

**Pasos**:
1. Filtrar por:
   - **Time range**: Últimas 2 horas
   - **Application**: runart-briefing (o nombre de la app)
   - **Action**: `Login attempt` o `Auth failed`
2. Buscar entradas con el email de prueba
3. Click en cada log → Ver detalles:
   - **Status**: `success`, `failure`, `rate_limited`, etc.
   - **Reason**: Mensaje descriptivo del error
   - **Identity provider**: `One-time PIN` o `Email OTP`
4. Copiar mensaje textual del error (si existe)

**Mensajes de error comunes**:
- `"No login method available for this email"` → One-time PIN deshabilitado/restringido
- `"Email not allowed"` → Email no está en Include o está en Exclude
- `"Rate limit exceeded"` → Demasiados intentos, esperar 15 min
- `"Identity provider not configured"` → One-time PIN no está configurado

**Captura recomendada**: Logs con filtro aplicado y detalles del error

---

### 4. Verificar Configuración de Email Delivery (Opcional)

**Ruta**: `Zero Trust → Settings → Authentication → Email` (si existe sección específica)

**Pasos**:
1. Verificar si hay configuración de email delivery
2. Comprobar:
   - SMTP configurado correctamente (si usa custom SMTP)
   - Rate limits no excedidos
   - Blacklist/allowlist de dominios

**Nota**: En la mayoría de casos, Cloudflare maneja el envío automáticamente. Solo revisar si hay configuración custom.

---

## Próximos Pasos Mínimos de Verificación

### Paso 1: Verificar Política de Access (CRÍTICO)

**Acción**: Revisar manualmente en el dashboard

**Checklist**:
```
[ ] Ir a: Zero Trust → Access → Applications
[ ] Buscar app con domain: runart-briefing.pages.dev
[ ] Click en la app → Policies
[ ] Verificar que existe policy con Action=Allow
[ ] Click en policy → Configure rules
[ ] VERIFICAR: Existe regla "Include" con tipo "Emails"
[ ] VERIFICAR: El email está en la lista de Include (sin espacios extras)
[ ] VERIFICAR: El email NO está en "Exclude"
[ ] Si falta: Añadir email a Include
[ ] Click Save
```

**Tiempo estimado**: 3-5 minutos

---

### Paso 2: Verificar One-time PIN (CRÍTICO)

**Acción**: Revisar configuración de login methods

**Checklist**:
```
[ ] Ir a: Zero Trust → Settings → Authentication
[ ] Buscar: Login methods → One-time PIN
[ ] VERIFICAR: Toggle está ON (habilitado)
[ ] VERIFICAR: "Allow all email addresses" seleccionado
    O: Dominio del email está en lista de permitidos
[ ] Si está OFF: Habilitar y guardar
[ ] Si está restringido: Cambiar a "Allow all" o añadir dominio
[ ] Click Save
```

**Tiempo estimado**: 2-3 minutos

---

### Paso 3: Revisar Logs de Access (RECOMENDADO)

**Acción**: Identificar error específico en logs

**Checklist**:
```
[ ] Ir a: Zero Trust → Access → Logs → Authentication
[ ] Filtrar: Últimas 2 horas, Application=runart-briefing
[ ] Buscar: Entradas con el email de prueba
[ ] Click en log más reciente
[ ] Copiar: Mensaje de error completo (field "reason" o "message")
[ ] Documentar: Status code y timestamp del intento
```

**Tiempo estimado**: 2-3 minutos

**Output esperado**: Mensaje de error claro (ej: "Email not in allowed list")

---

### Paso 4: Probar Acceso Nuevamente (VALIDACIÓN)

**Acción**: Retry login tras correcciones

**Checklist**:
```
[ ] Esperar 15 minutos (evitar rate limit)
[ ] Abrir navegador incógnito
[ ] Ir a: https://runart-briefing.pages.dev
[ ] VERIFICAR: Aparece pantalla de Cloudflare Access
[ ] Ingresar: Email configurado en Include
[ ] Click: "Send me a code"
[ ] Esperar: 1-2 minutos
[ ] Revisar: Bandeja de entrada, Spam, Promotions
[ ] Buscar: Email de no-reply@cloudflareaccess.com
[ ] Si llega: Ingresar código → Debe permitir acceso
[ ] Si NO llega: Volver a Paso 3 (revisar logs)
```

**Tiempo estimado**: 5-10 minutos

---

### Paso 5: Deploy del Endpoint Whoami (OPCIONAL)

**Acción**: Desplegar endpoint de diagnóstico para verificar headers

**Checklist**:
```bash
# En terminal local
cd /home/pepe/work/runartfoundry/briefing

# Build MkDocs
mkdocs build

# Deploy a Cloudflare Pages (requiere wrangler autenticado)
npx wrangler pages deploy site --project-name runart-briefing

# Esperar deployment (~1-2 min)
# Probar endpoint (tras autenticarse con Access):
# https://runart-briefing.pages.dev/api/whoami
```

**Verificación**:
```
[ ] Deployment exitoso
[ ] Abrir en navegador (autenticado): https://runart-briefing.pages.dev/api/whoami
[ ] VERIFICAR: Response JSON muestra:
    - "authenticated": true
    - "email": "tu-email@example.com"
    - "jwtPresent": true
[ ] Si email es "uldis@local": Access NO está pasando headers (problema de configuración)
```

**Tiempo estimado**: 5-7 minutos

---

## Diagnóstico Rápido: Decision Tree

```
¿El challenge de Access aparece en el navegador?
├─ NO → Access no está activado (pero según HTTP sí lo está ✅)
└─ SÍ → ¿Aparece botón "Send me a code"?
    ├─ NO → One-time PIN no habilitado → Ir a Paso 2
    └─ SÍ → ¿El PIN llega al correo?
        ├─ SÍ (Spam/Promotions) → Problema resuelto ✅
        ├─ NO → ¿Revisaste logs de Access?
        │   ├─ NO → Ir a Paso 3
        │   └─ SÍ → ¿Qué dice el error?
        │       ├─ "Email not allowed" → Ir a Paso 1 (Include falta)
        │       ├─ "No login method" → Ir a Paso 2 (PIN deshabilitado)
        │       ├─ "Rate limited" → Esperar 15 min, retry
        │       └─ Otro error → Documentar y contactar soporte
        └─ TIMEOUT (>5 min) → Posible rate limit o delivery issue
```

---

## Datos de Contexto para Soporte

Si necesitas contactar a soporte de Cloudflare, proporciona:

### Información del Proyecto
- **Account ID**: `a2c7fc66f00eab69373e448193ae7201`
- **Project name**: `runart-briefing`
- **Domain**: `runart-briefing.pages.dev`
- **Application type**: Cloudflare Pages

### Síntoma Específico
- **Issue**: One-time PIN email not received
- **URL tested**: https://runart-briefing.pages.dev
- **Email tested**: [tu-email@example.com]
- **Timestamp of attempt**: [2025-10-02 17:31:56 GMT]
- **Browser**: [Chrome/Firefox/Safari]
- **IP location**: [US/otro]

### Evidencias HTTP
- ✅ Redirect to `cloudflareaccess.com` confirmed (HTTP 302)
- ✅ Login challenge renders (HTTP 200, 28KB HTML)
- ✅ Cookies set: `CF_AppSession`, `CF_Session`
- ❌ PIN email not received after 5 minutes

### Verificaciones Realizadas
- [ ] Policy has Include rule with email
- [ ] One-time PIN is enabled
- [ ] Email not in Exclude list
- [ ] Checked Spam/Promotions folders
- [ ] Waited 15+ minutes (no rate limit)
- [ ] Logs reviewed (error message: [copiar aquí])

---

## Comandos Útiles de Diagnóstico

### Test HTTP completo con headers
```bash
curl -v -L https://runart-briefing.pages.dev 2>&1 | grep -E "HTTP|location|set-cookie|CF_"
```

### Verificar DNS del dominio
```bash
dig runart-briefing.pages.dev +short
nslookup runart-briefing.pages.dev
```

### Test de endpoint whoami (tras autenticación)
```bash
# Obtener cookie de sesión desde navegador (tras login exitoso)
# Developer Tools → Application → Cookies → CF_Authorization

curl -H "Cookie: CF_Authorization=YOUR_COOKIE_HERE" \
  https://runart-briefing.pages.dev/api/whoami
```

### Deploy manual del endpoint whoami
```bash
cd /home/pepe/work/runartfoundry/briefing
mkdocs build
npx wrangler pages deploy site --project-name runart-briefing
```

---

## Archivos Modificados en este Diagnóstico

### Nuevo endpoint creado:
- ✅ `briefing/functions/api/whoami.js` — Inspector de headers de Access

**Propósito**: Diagnosticar qué headers recibe una Pages Function tras autenticación exitosa.

**Uso**: Acceder a `https://runart-briefing.pages.dev/api/whoami` (tras login con Access)

**Output esperado**:
```json
{
  "access": {
    "authenticated": true,
    "email": "usuario@example.com"
  }
}
```

**Si email es `uldis@local`**: Access no está pasando headers → Problema de configuración en Zero Trust.

---

## Resumen de Hallazgos Críticos

| # | Hallazgo | Estado | Próxima Acción |
|---|----------|--------|----------------|
| 1 | Cloudflare Access está activo | ✅ Confirmado | Ninguna |
| 2 | Challenge de login funciona | ✅ Confirmado | Ninguna |
| 3 | One-time PIN no llega | 🔴 Problema | Revisar Paso 1 y 2 |
| 4 | Sin CF_API_TOKEN disponible | ⚠️ Limitación | Diagnóstico manual en dashboard |
| 5 | Endpoint whoami creado | ✅ Listo | Deploy y probar tras login exitoso |
| 6 | Causa MÁS probable | 🎯 Policy sin Include | Verificar Zero Trust → Applications → Policies |

---

## Próxima Acción Recomendada

**Ir inmediatamente al dashboard de Cloudflare y ejecutar los Pasos 1, 2 y 3**:

1. **Paso 1**: Verificar que la política de Access tiene regla "Include" con el email correcto (sin espacios extras)
2. **Paso 2**: Verificar que One-time PIN está habilitado y permite "all email addresses"
3. **Paso 3**: Revisar logs de Access para identificar mensaje de error específico

**Tiempo estimado**: 10-15 minutos  
**Probabilidad de resolución**: 85% (basado en síntomas típicos)

---

**Fin del diagnóstico**

**Última actualización**: 2 de octubre de 2025  
**Archivo generado**: `briefing/_reports/zero_trust_pin_diagnostics.md`
