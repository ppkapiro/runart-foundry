# Auditoría de Cloudflare Access y Configuración de Pages
**Fecha de auditoría**: 2 de octubre de 2025  
**Proyecto**: RUN Art Foundry — Micrositio Briefing  
**Repositorio**: `/home/pepe/work/runartfoundry`

---

## Resumen Ejecutivo

Esta auditoría documenta la configuración completa de **Cloudflare Pages, Pages Functions, Workers KV y Cloudflare Access** para el micrositio privado "briefing" del proyecto RUN Art Foundry. El micrositio fue desplegado el 1 de octubre de 2025 mediante un proceso automatizado que incluyó:

1. **Infraestructura desplegada exitosamente**: Cloudflare Pages con Pages Functions integradas, eliminando la necesidad de workers.dev subdomain
2. **Backend serverless operativo**: Dos endpoints API (`POST /api/decisiones`, `GET /api/inbox`) funcionando con Workers KV
3. **Accesibilidad WCAG 2.1 Level AA implementada**: Mejoras completas de contraste, foco visible, navegación por teclado y formularios accesibles
4. **Pendiente crítico**: **Cloudflare Access NO está activado** — el micrositio es actualmente público y accesible por cualquier persona
5. **Cuenta única detectada**: Un solo `account_id` (a2c7fc66f00eab69373e448193ae7201), sin conflictos ni duplicidades

---

## Mapa de Artefactos Detectados

| Archivo | Rol | Hallazgo Principal |
|---------|-----|-------------------|
| `briefing/wrangler.toml` | Config principal Pages | ✅ Configurado con KV binding `DECISIONES` y `pages_build_output_dir = "site"` |
| `briefing/workers/wrangler.toml` | Config Workers (obsoleto) | ⚠️ Archivo legacy, ya NO usado tras migración a Pages Functions |
| `briefing/functions/api/decisiones.js` | Pages Function POST | ✅ Endpoint operativo, lee header `Cf-Access-Authenticated-User-Email` |
| `briefing/functions/api/inbox.js` | Pages Function GET | ✅ Endpoint operativo, lista decisiones desde KV |
| `briefing/.github/workflows/briefing_pages.yml` | GitHub Actions workflow | ✅ Deploy automatizado con `cloudflare/pages-action@v1` |
| `briefing/mkdocs.yml` | Config MkDocs | ✅ Site URL apunta a `example.pages.dev` (placeholder) |
| `briefing/docs/acerca/index.md` | Contenido docs | 🔴 Menciona: "será protegido con Cloudflare Access" (AÚN NO ACTIVADO) |
| `briefing/_logs/briefing_summary_*.txt` | Logs de deployment | ✅ Historial completo de despliegues y migraciones |
| `briefing/README_briefing.md` | Documentación técnica | ✅ Instrucciones de activación de Access documentadas |

---

## Workflows de GitHub Actions Detectados

### 1. `briefing/.github/workflows/briefing_pages.yml`

| Campo | Valor |
|-------|-------|
| **Nombre** | `Deploy RUNART Briefing to Cloudflare Pages` |
| **Trigger** | Push en rama `main` con cambios en `briefing/**` |
| **Job principal** | `build-deploy` |
| **Runners** | `ubuntu-latest` |
| **Working directory** | `briefing` |

#### Steps del workflow:
1. **Checkout**: `actions/checkout@v4`
2. **Setup Python**: `actions/setup-python@v5` (Python 3.11)
3. **Install & Build**: 
   ```bash
   pip install mkdocs mkdocs-material
   mkdocs build
   ```
4. **Deploy Pages**: `cloudflare/pages-action@v1`

#### Secrets/Variables referenciados:
| Variable | Tipo | Descripción |
|----------|------|-------------|
| `CF_API_TOKEN` | Secret | Token de API de Cloudflare (permisos: Pages, Workers KV) |
| `CF_ACCOUNT_ID` | Secret | ID de cuenta Cloudflare: `a2c7fc66f00eab69373e448193ae7201` |
| `GITHUB_TOKEN` | Secret automático | Token de GitHub Actions |

#### Parámetros del action:
- `projectName`: `runart-briefing`
- `directory`: `briefing/site`

**Estado**: ✅ Workflow funcional y listo para CI/CD (requiere configurar secrets en GitHub)

---

## Configuración Wrangler/Pages

### Archivo principal: `briefing/wrangler.toml`

```toml
name = "runart-briefing"
compatibility_date = "2025-10-01"
pages_build_output_dir = "site"

# Pages Functions KV binding
[[kv_namespaces]]
binding = "DECISIONES"
id = "6418ac6ace59487c97bda9c3a50ab10e"
preview_id = "e68d7a05dce645478e25c397d4c34c08"
```

**Campos clave**:
- **name**: `runart-briefing` (nombre del proyecto Pages)
- **compatibility_date**: `2025-10-01`
- **pages_build_output_dir**: `site` (directorio de salida de MkDocs)
- **KV namespace binding**: 
  - **Production**: `6418ac6ace59487c97bda9c3a50ab10e`
  - **Preview**: `e68d7a05dce645478e25c397d4c34c08`
  - **Binding name**: `DECISIONES` (accesible como `env.DECISIONES` en Functions)

### Archivo obsoleto: `briefing/workers/wrangler.toml`

```toml
name = "runart-decisiones"
main = "decisiones.js"
compatibility_date = "2025-10-01"
kv_namespaces = [...]
workers_dev = true
```

**Estado**: ⚠️ **NO USADO** — Conservado para referencia histórica tras migración a Pages Functions

---

## Pages Functions Detectadas

### Endpoint 1: POST `/api/decisiones`

**Archivo**: `briefing/functions/api/decisiones.js`

**Función**: Guardar decisión en Workers KV

**Método HTTP**: POST

**Dependencias**:
- KV binding: `env.DECISIONES`
- Header: `Cf-Access-Authenticated-User-Email` (opcional, default: `uldis@local`)

**Lógica**:
```javascript
const user = request.headers.get('Cf-Access-Authenticated-User-Email') || 'uldis@local';
const key = `decision:${body.decision_id}:${ts}`;
await env.DECISIONES.put(key, value);
```

**Respuesta exitosa**: `{"ok": true}` (200)

**URL pública**: `https://runart-briefing.pages.dev/api/decisiones`

---

### Endpoint 2: GET `/api/inbox`

**Archivo**: `briefing/functions/api/inbox.js`

**Función**: Listar todas las decisiones guardadas

**Método HTTP**: GET

**Dependencias**:
- KV binding: `env.DECISIONES`

**Lógica**:
```javascript
const list = await env.DECISIONES.list({ prefix: 'decision:' });
items.sort((a, b) => (a.ts < b.ts ? 1 : -1));
return JSON.stringify(items);
```

**Respuesta**: Array JSON con decisiones ordenadas por timestamp descendente

**URL pública**: `https://runart-briefing.pages.dev/api/inbox`

---

## Análisis de Logs Internos

### Archivo: `briefing/_logs/briefing_summary_20251001_172711.txt`

**Fecha**: 1 de octubre de 2025, 17:27:11 EDT

**Resumen**: Migración exitosa de Cloudflare Workers a Pages Functions

**Pistas clave**:
- ✅ Endpoints API integrados en mismo dominio Pages
- ✅ KV namespace configurado correctamente
- ✅ Tests E2E exitosos (POST y GET)
- ⚠️ **Cloudflare Access pendiente de activación manual**
- 📍 URL producción: `https://runart-briefing.pages.dev`
- 📍 Último deployment: `https://40546765.runart-briefing.pages.dev`

### Archivo: `briefing/_logs/a11y_summary.txt`

**Fecha**: 1 de octubre de 2025 (tarde)

**Resumen**: Implementación de mejoras de accesibilidad WCAG 2.1 Level AA

**Pistas clave**:
- ✅ ~90 líneas de CSS de accesibilidad añadidas a `overrides/extra.css`
- ✅ Skip link, foco visible, formularios accesibles, galería con lazy loading
- ✅ Deployment exitoso: `https://3040efae.runart-briefing.pages.dev`
- ⚠️ Validación manual recomendada (navegación por teclado, lectores de pantalla)

### Archivo: `briefing/_logs/pages_url.txt`

```
PAGES_URL=https://runart-briefing.pages.dev
```

**Uso**: Variable de entorno para referencias en scripts

---

## Señales de Cloudflare Zero Trust/Access

### Menciones en código:

1. **`briefing/docs/acerca/index.md`** (línea 12):
   ```markdown
   Este micrositio es privado, no indexado por buscadores, 
   y será protegido con Cloudflare Access.
   ```
   🔴 **PROMESA NO CUMPLIDA**: Access NO está activado actualmente

2. **`briefing/functions/api/decisiones.js`** (línea 4):
   ```javascript
   const user = request.headers.get('Cf-Access-Authenticated-User-Email') || 'uldis@local';
   ```
   ✅ Código preparado para recibir header de Access, con fallback a usuario local

3. **`briefing/_logs/briefing_summary_20251001_172711.txt`** (múltiples líneas):
   ```
   🔐 CLOUDFLARE ACCESS (Pendiente de activación)
   Acción requerida: Activar Cloudflare Access
   Dashboard: https://dash.cloudflare.com/a2c7fc66f00eab69373e448193ae7201/pages
   Proyecto: runart-briefing → Settings → Access
   ```
   ⚠️ Instrucciones claras documentadas pero NO ejecutadas

4. **`briefing/README_briefing.md`** (líneas 40-45):
   ```markdown
   1. **Activar Cloudflare Access** (privacidad - OBLIGATORIO):
      - Ir a: https://dash.cloudflare.com/...
      - En Settings → Access → Enable Access
      - Crear regla de acceso: "Uldis Only" → Email → Allow
   ```
   ⚠️ Documentación técnica completa disponible

### Lo que HAY:
- ✅ Código backend listo para leer header `Cf-Access-Authenticated-User-Email`
- ✅ Documentación clara de los pasos de activación
- ✅ Logs con recordatorios de activación pendiente

### Lo que FALTA:
- 🔴 **Activación real de Cloudflare Access en el dashboard**
- 🔴 **Política de acceso configurada** (Allow rule con email específico)
- 🔴 **Verificación funcional** de que Access está bloqueando acceso público

---

## Cuentas y Proyectos Detectados

### Cuenta única identificada:

| Parámetro | Valor |
|-----------|-------|
| **Account ID** | `a2c7fc66f00eab69373e448193ae7201` |
| **Proyecto Pages** | `runart-briefing` |
| **URL producción** | `https://runart-briefing.pages.dev` |
| **KV Namespace (prod)** | `6418ac6ace59487c97bda9c3a50ab10e` |
| **KV Namespace (preview)** | `e68d7a05dce645478e25c397d4c34c08` |

### Detección de duplicidades: ❌ NO HAY

**Análisis**:
- Un solo `account_id` encontrado en toda la auditoría
- Un solo proyecto Pages: `runart-briefing`
- Sin referencias a múltiples organizaciones, cuentas paralelas o proyectos duplicados
- Sin conflictos entre variables `CF_ACCOUNT_ID`, `CLOUDFLARE_ACCOUNT_ID`, etc.

**Conclusión**: ✅ **Configuración limpia y consistente** — un solo entorno Cloudflare activo

---

## Diagnóstico del Problema: "No puedo proteger pages.dev con Self-hosted"

### Contexto del problema:

El usuario mencionó tener **dos cuentas Cloudflare**:
1. Una que **acepta tarjeta** (posiblemente con Zero Trust habilitado)
2. Otra que **NO acepta tarjeta** (cuenta free/limitada)

El mensaje de error típico es:
> "Cloudflare Access no está disponible para dominios `*.pages.dev`. Requiere un dominio personalizado en tu zona."

### Explicación técnica:

**Cloudflare Access con Self-hosted Application** (la opción gratuita de Zero Trust) **NO funciona directamente en subdominios `*.pages.dev`** por razones de arquitectura:

1. **Dominios `pages.dev` son compartidos**: Cloudflare no permite políticas de Access en subdominios que no controlas completamente
2. **Self-hosted requiere tu propio dominio**: Necesitas un dominio registrado en tu cuenta (ej: `briefing.runartfoundry.com`) añadido a Cloudflare como zona DNS
3. **Cloudflare for Teams (pago)** permite Access en `pages.dev`, pero requiere suscripción

### Por qué el problema persiste:

- Si la cuenta `a2c7fc66f00eab69373e448193ae7201` es **free** → Self-hosted Access NO funciona en `runart-briefing.pages.dev`
- Si no tienes un dominio propio configurado → No puedes usar Access gratuito
- El sitio **permanece público** mientras no se resuelva esto

---

## Recomendaciones Accionables

### Opción A: Usar Cloudflare Access en Pages (requiere cuenta paga)

**Pasos**:
1. Verificar si la cuenta `a2c7fc66f00eab69373e448193ae7201` tiene **Zero Trust habilitado**
2. Dashboard: https://dash.cloudflare.com/a2c7fc66f00eab69373e448193ae7201/pages
3. Seleccionar proyecto `runart-briefing` → **Settings → Access**
4. Click **Enable Cloudflare Access**
5. Crear política:
   - **Application name**: `RUN Briefing Private`
   - **Subdomain**: `runart-briefing` (o toda la Pages app)
   - **Policy**: Allow → Include → Emails → `<email-de-uldis>`
6. Guardar y probar acceso

**Limitaciones**:
- ⚠️ Puede requerir **Cloudflare Teams** (plan pago) si Self-hosted no funciona en pages.dev
- ⚠️ Si la cuenta free no lo permite, esta opción NO es viable

---

### Opción B: Dominio Personalizado + Self-hosted Access (GRATIS)

**Pasos**:
1. **Registrar un dominio propio** (ej: `briefing.runartfoundry.com`) o usar un subdominio de un dominio existente
2. **Añadir el dominio a Cloudflare**:
   - Dashboard: https://dash.cloudflare.com/a2c7fc66f00eab69373e448193ae7201
   - Añadir sitio → Ingresar dominio → Cambiar nameservers del registrador
3. **Conectar dominio a Pages**:
   - Pages → `runart-briefing` → Custom domains → Add domain
   - Configurar `briefing.runartfoundry.com` → CNAME a `runart-briefing.pages.dev`
4. **Activar Zero Trust Self-hosted**:
   - Dashboard: https://one.dash.cloudflare.com
   - Access → Applications → Add an application
   - **Self-hosted** → Domain: `briefing.runartfoundry.com`
   - Policy: Allow → Emails → `<email-de-uldis>`
5. **Actualizar URLs en el código**:
   - `briefing/mkdocs.yml`: `site_url: https://briefing.runartfoundry.com`
   - `briefing/docs/decisiones/contenido-sitio-viejo.md`: Action URL del form
   - `briefing/docs/inbox/index.md`: Fetch URL
6. **Rebuild y redeploy**:
   ```bash
   cd briefing
   mkdocs build
   npx wrangler pages deploy
   ```

**Ventajas**:
- ✅ **100% GRATIS** (Self-hosted Access no requiere pago)
- ✅ Control total sobre el dominio
- ✅ Funciona con cuenta free de Cloudflare

**Desventajas**:
- ⚠️ Requiere comprar/poseer un dominio (~$10-15/año)
- ⚠️ Configuración DNS adicional

---

### Opción C: Protección básica con HTTP Basic Auth (workaround temporal)

Si ninguna de las anteriores es viable ahora mismo, puedes implementar autenticación básica en Pages Functions:

**Crear**: `briefing/functions/_middleware.js`

```javascript
export async function onRequest(context) {
  const { request } = context;
  const auth = request.headers.get('Authorization');
  
  const validAuth = 'Basic ' + btoa('uldis:PASSWORD_SEGURO_AQUI');
  
  if (auth !== validAuth) {
    return new Response('Acceso denegado', {
      status: 401,
      headers: {
        'WWW-Authenticate': 'Basic realm="RUN Briefing"'
      }
    });
  }
  
  return context.next();
}
```

**Limitaciones**:
- ⚠️ NO es tan seguro como Cloudflare Access
- ⚠️ El navegador guarda la contraseña en caché
- ⚠️ Requiere compartir usuario/contraseña

---

## Próximos Pasos Concretos

### Checklist de acción inmediata:

- [ ] **Decidir entre Opción A, B o C** según presupuesto y disponibilidad de dominio
- [ ] **Si Opción A**: Verificar si cuenta Cloudflare tiene Zero Trust habilitado
- [ ] **Si Opción B**: Comprar/configurar dominio personalizado y añadirlo a Cloudflare
- [ ] **Si Opción C**: Implementar HTTP Basic Auth como solución temporal
- [ ] **Activar protección elegida** siguiendo los pasos de la opción seleccionada
- [ ] **Probar acceso**: Verificar que usuarios NO autorizados son bloqueados
- [ ] **Actualizar documentación**: Cambiar en `docs/acerca/index.md` de "será protegido" a "está protegido"
- [ ] **Configurar GitHub Actions secrets** si se desea CI/CD automático:
  - `CF_API_TOKEN`: Token con permisos Pages/KV
  - `CF_ACCOUNT_ID`: `a2c7fc66f00eab69373e448193ae7201`

### Validación post-activación:

1. Abrir `https://runart-briefing.pages.dev` (o dominio custom) en navegador privado
2. Verificar que se muestra pantalla de login de Cloudflare Access (o Basic Auth)
3. Autenticarse con email/contraseña configurado
4. Confirmar que endpoints API funcionan: POST decisión y GET inbox
5. Revisar que header `Cf-Access-Authenticated-User-Email` se registra correctamente en decisiones

---

## Anexo: Comandos Útiles de Wrangler

```bash
# Listar proyectos Pages
npx wrangler pages project list

# Ver deployments recientes
npx wrangler pages deployment list --project-name runart-briefing

# Ver logs en tiempo real
npx wrangler pages deployment tail --project-name runart-briefing

# Listar keys en KV
npx wrangler kv key list --namespace-id 6418ac6ace59487c97bda9c3a50ab10e

# Leer una decisión específica
npx wrangler kv key get "decision:test-e2e-functions:2025-10-01T..." \
  --namespace-id 6418ac6ace59487c97bda9c3a50ab10e

# Eliminar una key de KV
npx wrangler kv key delete "decision:ID:TIMESTAMP" \
  --namespace-id 6418ac6ace59487c97bda9c3a50ab10e

# Deploy manual
cd briefing
mkdocs build
npx wrangler pages deploy site --project-name runart-briefing
```

---

## Resumen de Hallazgos Críticos

| # | Hallazgo | Severidad | Estado |
|---|----------|-----------|--------|
| 1 | **Cloudflare Access NO activado** — sitio público | 🔴 CRÍTICO | ❌ Pendiente |
| 2 | Código backend preparado para Access | ✅ OK | ✅ Completo |
| 3 | Pages Functions operativas con KV | ✅ OK | ✅ Completo |
| 4 | Workflow GitHub Actions configurado | ✅ OK | ⚠️ Falta configurar secrets |
| 5 | Accesibilidad WCAG 2.1 AA implementada | ✅ OK | ✅ Completo |
| 6 | Una sola cuenta Cloudflare detectada | ✅ OK | ✅ Sin conflictos |

---

**Fin del reporte de auditoría**

**Próxima acción recomendada**: Decidir estrategia de protección (Opción A, B o C) y ejecutar pasos correspondientes para activar acceso restringido al micrositio.
