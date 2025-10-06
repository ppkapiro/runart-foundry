# Cloudflare Access — Estado y Plan de Acción
**Fecha de verificación**: 2 de octubre de 2025  
**Proyecto**: RUN Art Foundry — Micrositio Briefing  
**URL actual**: https://runart-briefing.pages.dev

---

## Resumen Ejecutivo (5 puntos clave)

1. ✅ **Infraestructura desplegada**: Cloudflare Pages con Pages Functions operativas (`/api/decisiones` POST, `/api/inbox` GET) + Workers KV namespace `DECISIONES`
2. 🔴 **Access NO activado**: El micrositio es público — cualquier persona puede acceder a https://runart-briefing.pages.dev
3. ✅ **Código preparado para Access**: Los endpoints leen el header `Cf-Access-Authenticated-User-Email` con fallback a `uldis@local`
4. ⚠️ **Sin dominio personalizado configurado**: Actualmente usa subdominio `*.pages.dev` — Access requiere cuenta con Zero Trust o dominio propio
5. ✅ **Cuenta con método de pago activa**: Se puede proceder con activación directa de Access en Pages

---

## Artefactos Detectados

| Archivo | Rol | Hallazgo |
|---------|-----|----------|
| `briefing/wrangler.toml` | Config principal Pages | ✅ Activo: `name="runart-briefing"`, `pages_build_output_dir="site"`, KV binding `DECISIONES` |
| `briefing/workers/wrangler.toml` | Config Workers legacy | ⚠️ Obsoleto (conservado para referencia, no usado tras migración a Pages Functions) |
| `briefing/functions/api/decisiones.js` | Pages Function POST | ✅ Operativo: Lee `Cf-Access-Authenticated-User-Email`, guarda en KV |
| `briefing/functions/api/inbox.js` | Pages Function GET | ✅ Operativo: Lista decisiones desde KV con `prefix: 'decision:'` |
| `briefing/.github/workflows/briefing_pages.yml` | CI/CD GitHub Actions | ✅ Configurado: `cloudflare/pages-action@v1`, requiere secrets `CF_API_TOKEN` y `CF_ACCOUNT_ID` |
| `briefing/mkdocs.yml` | Config MkDocs | ✅ Site URL: `example.pages.dev` (placeholder), meta `noindex` activo |
| `briefing/README_briefing.md` | Documentación | ✅ Instrucciones de activación de Access documentadas |
| `briefing/_logs/briefing_summary_*.txt` | Logs deployment | ✅ Historial completo: migraciones, tests E2E, deployments exitosos |

---

## Configuración Wrangler (No sensible)

### Archivo activo: `briefing/wrangler.toml`

| Campo | Valor |
|-------|-------|
| `name` | `runart-briefing` |
| `compatibility_date` | `2025-10-01` |
| `pages_build_output_dir` | `site` |
| **KV namespace binding** | `DECISIONES` |
| KV ID (production) | `6418ac6ace59487c97bda9c3a50ab10e` |
| KV ID (preview) | `e68d7a05dce645478e25c397d4c34c08` |

**Nota**: No se detectó `account_id` en wrangler.toml (se usa el de la sesión autenticada de Wrangler CLI). Según logs, el account_id es `a2c7fc66f00eab69373e448193ae7201`.

---

## Functions/Endpoints Detectados

### 1. POST `/api/decisiones`

- **Archivo**: `briefing/functions/api/decisiones.js`
- **Método**: POST
- **Función**: Guardar decisión en Workers KV
- **KV Binding**: `env.DECISIONES`
- **Headers leídos**: 
  - `Cf-Access-Authenticated-User-Email` (opcional, default: `uldis@local`)
- **Lógica clave**:
  ```javascript
  const user = request.headers.get('Cf-Access-Authenticated-User-Email') || 'uldis@local';
  const key = `decision:${body.decision_id}:${ts}`;
  await env.DECISIONES.put(key, value);
  ```
- **Respuesta**: `{"ok": true}` (200) o `{"ok": false, "error": "..."}` (500)
- **URL pública**: https://runart-briefing.pages.dev/api/decisiones

### 2. GET `/api/inbox`

- **Archivo**: `briefing/functions/api/inbox.js`
- **Método**: GET
- **Función**: Listar todas las decisiones guardadas
- **KV Binding**: `env.DECISIONES`
- **Lógica clave**:
  ```javascript
  const list = await env.DECISIONES.list({ prefix: 'decision:' });
  items.sort((a, b) => (a.ts < b.ts ? 1 : -1));
  ```
- **Respuesta**: Array JSON con decisiones ordenadas por timestamp descendente
- **URL pública**: https://runart-briefing.pages.dev/api/inbox

---

## Workflows y Secrets/Variables

### GitHub Actions: `.github/workflows/briefing_pages.yml`

| Campo | Valor |
|-------|-------|
| **Nombre workflow** | `Deploy RUNART Briefing to Cloudflare Pages` |
| **Trigger** | Push a rama `main` con cambios en `briefing/**` |
| **Runner** | `ubuntu-latest` |
| **Working directory** | `briefing` |

#### Steps:
1. **Checkout**: `actions/checkout@v4`
2. **Setup Python**: `actions/setup-python@v5` (Python 3.11)
3. **Install & Build**:
   ```bash
   pip install mkdocs mkdocs-material
   mkdocs build
   ```
4. **Deploy**: `cloudflare/pages-action@v1`

#### Secrets referenciados (NOMBRES ÚNICAMENTE):
- `CF_API_TOKEN` — Token de API de Cloudflare (permisos: Account > Cloudflare Pages > Edit, Workers KV Storage > Edit)
- `CF_ACCOUNT_ID` — ID de cuenta Cloudflare (valor esperado: `a2c7fc66f00eab69373e448193ae7201`)
- `GITHUB_TOKEN` — Secret automático de GitHub Actions

#### Parámetros del action:
- `projectName`: `runart-briefing`
- `directory`: `briefing/site`

**Estado actual**: ⚠️ Workflow configurado pero requiere añadir secrets en GitHub Repository Settings

---

## Qué Hacer en Cloudflare AHORA

### Contexto de decisión:
- ✅ Cuenta con método de pago activa
- ❌ NO hay dominio personalizado configurado (usa `runart-briefing.pages.dev`)
- 🎯 **Opción recomendada**: Activar **Cloudflare Access para Pages** directamente (requiere cuenta con Zero Trust, disponible en cuentas de pago)

---

## CHECKLIST: Activar Access → Cloudflare → Pages (Opción A)

### Prerrequisitos:
- [ ] Cuenta Cloudflare con método de pago activo ✅ (confirmado)
- [ ] Acceso al dashboard: https://dash.cloudflare.com/
- [ ] Email del usuario autorizado (ej: `uldis@example.com`)

---

### Paso 1: Verificar que Zero Trust está disponible

1. Abrir dashboard: https://dash.cloudflare.com/
2. Buscar en menú lateral izquierdo: **"Zero Trust"** o **"Cloudflare One"**
3. Si NO aparece:
   - Ir a: https://one.dash.cloudflare.com/
   - Click **"Get Started"** → Seguir wizard de activación (gratuito para uso personal)
4. Si ya existe: Continuar al Paso 2

**Ruta exacta**: `Dashboard → Zero Trust` (menú lateral)

---

### Paso 2: Navegar al proyecto Pages

1. Dashboard: https://dash.cloudflare.com/
2. Menú lateral: **Workers & Pages**
3. Buscar proyecto: **`runart-briefing`**
4. Click en el nombre del proyecto

**Ruta exacta**: `Dashboard → Workers & Pages → runart-briefing`

---

### Paso 3: Habilitar Access en el proyecto Pages

1. Dentro de `runart-briefing`, ir a: **Settings** (pestaña superior)
2. Scroll hasta sección: **"Access Policy"** o **"Cloudflare Access"**
3. Click botón: **"Enable Cloudflare Access"** o **"Manage Access"**
4. Si pregunta por subdominio/ruta:
   - Dejar vacío o usar: `*` (proteger todo el sitio)

**Ruta exacta**: `Workers & Pages → runart-briefing → Settings → Access Policy → Enable`

**Alternativa si no aparece Access en Settings**:
- Ir directamente a: https://one.dash.cloudflare.com/ → Access → Applications → Add an application
- Seleccionar tipo: **"Self-hosted"**
- Dominio: `runart-briefing.pages.dev` (o el dominio completo)

---

### Paso 4: Crear política de acceso (Access Policy)

1. En la pantalla de configuración de Access, click: **"Add a policy"** o **"Create policy"**
2. **Policy name**: `Uldis Only - Briefing Private`
3. **Action**: Seleccionar **"Allow"**
4. **Configure rules**:
   - Click **"Add include"**
   - Selector: **"Emails"**
   - Ingresar: `uldis@example.com` (reemplazar con email real)
   - Click **"Save"**
5. Configurar método de autenticación:
   - En **"Authentication methods"**: Marcar **"One-time PIN"**
   - (Opcional) También puedes habilitar Google, GitHub, etc.
6. Click: **"Save policy"** o **"Next"** → **"Save application"**

**Ruta exacta**: `Zero Trust → Access → Applications → (tu app) → Policies → Add policy`

**Configuración recomendada**:
- **Session duration**: `24 hours` (ajustar según necesidad)
- **Purpose**: "Micrositio privado para briefing de cliente"

---

### Paso 5: Verificar configuración de Access

1. Volver a: https://one.dash.cloudflare.com/ → Access → Applications
2. Buscar aplicación: `runart-briefing.pages.dev` (o el nombre dado)
3. Verificar:
   - ✅ **Status**: Enabled/Active
   - ✅ **Domain**: `runart-briefing.pages.dev`
   - ✅ **Policy**: "Allow" con email configurado
   - ✅ **Authentication**: One-time PIN habilitado

**Ruta exacta**: `Zero Trust → Access → Applications → (ver lista)`

---

### Paso 6: Probar acceso con navegador privado

1. Abrir navegador en **modo incógnito/privado**
2. Ir a: https://runart-briefing.pages.dev
3. **Resultado esperado**: 
   - Debe aparecer pantalla de Cloudflare Access
   - Pedir email para autenticación
4. Ingresar email autorizado (ej: `uldis@example.com`)
5. Revisar correo → Click en link o ingresar código PIN
6. **Resultado esperado**: Acceso permitido al micrositio

**Si NO aparece Access**:
- Esperar 2-3 minutos (propagación de configuración)
- Limpiar caché del navegador: `Ctrl+Shift+Del` → Clear cache
- Probar con otro navegador

---

### Paso 7: Probar bloqueo con email NO autorizado

1. Abrir navegador en modo incógnito
2. Ir a: https://runart-briefing.pages.dev
3. Ingresar email NO autorizado (ej: `test@example.com`)
4. **Resultado esperado**: 
   - Cloudflare Access muestra: **"Access Denied"** o **"Forbidden"**
   - NO permite acceso al sitio

**Si permite acceso**:
- Revisar política en `Zero Trust → Access → Applications → (app) → Policies`
- Verificar que la regla es **"Allow"** (no "Bypass") y tiene el email correcto

---

### Paso 8: Verificar que Functions reciben header de Access

1. Después de autenticarse con Access, abrir: https://runart-briefing.pages.dev/decisiones/contenido-sitio-viejo/
2. Llenar formulario de decisión
3. Enviar formulario (POST a `/api/decisiones`)
4. Abrir: https://runart-briefing.pages.dev/inbox/
5. **Verificar**: En la lista de decisiones, el campo `usuario` debe mostrar el email real (no `uldis@local`)

**Alternativa con curl** (después de obtener cookie de sesión):
```bash
# Reemplazar COOKIE con el valor de CF_Authorization de tu navegador
curl -X POST https://runart-briefing.pages.dev/api/decisiones \
  -H "Cookie: CF_Authorization=VALOR_DE_COOKIE" \
  -H "Content-Type: application/json" \
  -d '{"decision_id":"test-access","seleccion":"opcion_a","prioridad":3,"comentario":"Test con Access activo"}'
```

**Resultado esperado**: La decisión se guarda con el email del usuario autenticado en Access.

---

## Validaciones Post-Activación

### ✅ Checklist de validación:

- [ ] **Navegador incógnito** → Requiere autenticación antes de acceder
- [ ] **Email autorizado** → Puede acceder tras autenticación One-time PIN
- [ ] **Email NO autorizado** → Recibe "Access Denied"
- [ ] **Formulario funciona** → POST a `/api/decisiones` guarda correctamente
- [ ] **Inbox funciona** → GET a `/api/inbox` lista decisiones
- [ ] **Header Access correcto** → Campo `usuario` en decisiones muestra email real (no `uldis@local`)
- [ ] **Sesión expira** → Después de 24h (o duración configurada), requiere re-autenticación

### 🔍 Pruebas adicionales:

1. **Test de expiración de sesión**:
   - Autenticarse → Acceder al sitio
   - Esperar tiempo de sesión configurado
   - Refrescar página → Debe pedir re-autenticación

2. **Test multi-dispositivo**:
   - Autenticarse en desktop → Funciona
   - Abrir mismo link en móvil → Debe pedir autenticación separada

3. **Test de revocación**:
   - En `Zero Trust → Access → Authentication → Sessions`, buscar sesiones activas
   - Revocar sesión → Usuario debe ser deslogueado inmediatamente

---

## Nota de Reversión

### Cómo DESACTIVAR Access si es necesario:

1. Dashboard: https://one.dash.cloudflare.com/
2. Menú: **Zero Trust → Access → Applications**
3. Buscar aplicación: `runart-briefing.pages.dev`
4. Click en los **3 puntos** (⋮) → **"Delete application"** o **"Disable"**
5. Confirmar acción

**Efecto**: El sitio vuelve a ser público inmediatamente (sin autenticación requerida).

**Alternativa temporal (sin borrar)**:
- Editar política → Cambiar de **"Allow"** a **"Bypass"** temporalmente
- Esto permite acceso sin autenticación mientras se mantiene la configuración

---

## Alternativa: Opción B (Dominio Personalizado + Access)

**Si prefieres usar dominio propio** (ej: `briefing.runartfoundry.com`) en lugar de `*.pages.dev`:

### Pasos adicionales previos:

1. **Registrar dominio** (o usar subdominio de dominio existente)
2. **Añadir dominio a Cloudflare**:
   - Dashboard → Add a Site → Ingresar dominio → Configurar nameservers
3. **Conectar dominio a Pages**:
   - Workers & Pages → `runart-briefing` → Custom domains → Add domain
   - Configurar CNAME: `briefing.runartfoundry.com` → `runart-briefing.pages.dev`
4. **Crear aplicación Access**:
   - Zero Trust → Access → Applications → Add application
   - Self-hosted → Domain: `briefing.runartfoundry.com`
   - Política: Allow → Emails → `uldis@example.com`
5. **Actualizar URLs en código**:
   - `briefing/mkdocs.yml`: `site_url: https://briefing.runartfoundry.com`
   - `briefing/docs/decisiones/contenido-sitio-viejo.md`: Form action
   - `briefing/docs/inbox/index.md`: Fetch URL
6. **Rebuild y redeploy**:
   ```bash
   cd briefing
   mkdocs build
   npx wrangler pages deploy
   ```

**Ventaja**: Más control sobre el dominio, profesional.  
**Desventaja**: Requiere comprar/poseer dominio (~$10-15/año).

---

## Comandos Útiles (CLI)

```bash
# Ver proyectos Pages
npx wrangler pages project list

# Ver deployments recientes
npx wrangler pages deployment list --project-name runart-briefing

# Logs en tiempo real
npx wrangler pages deployment tail --project-name runart-briefing

# Listar keys en KV
npx wrangler kv key list --namespace-id 6418ac6ace59487c97bda9c3a50ab10e

# Ver sesiones activas de Access (requiere API token con permisos adecuados)
# https://developers.cloudflare.com/api/operations/access-users-get-users-with-access-policies

# Deploy manual
cd briefing
mkdocs build
npx wrangler pages deploy site --project-name runart-briefing
```

---

## Resumen de Hallazgos Críticos

### 6 puntos principales:

1. 🔴 **Cloudflare Access NO está activado** — Sitio público actualmente
2. ✅ **Código backend preparado** — Lee header `Cf-Access-Authenticated-User-Email`
3. ✅ **Pages Functions operativas** — POST `/api/decisiones` y GET `/api/inbox` funcionando
4. ✅ **KV namespace configurado** — `DECISIONES` con IDs prod y preview
5. ⚠️ **Workflow CI/CD configurado pero sin secrets** — Requiere `CF_API_TOKEN` y `CF_ACCOUNT_ID` en GitHub
6. ✅ **Cuenta con pago activa** — Puede proceder con activación de Access en Pages

---

## Próxima Acción Recomendada

**Ejecutar CHECKLIST completo de "Activar Access → Cloudflare → Pages (Opción A)"** siguiendo los 8 pasos detallados arriba.

**Tiempo estimado**: 15-20 minutos  
**Dificultad**: Baja (solo configuración en dashboard, sin código)  
**Reversible**: Sí (se puede desactivar Access en cualquier momento)

---

**Fin del reporte de estado**

**Última actualización**: 2 de octubre de 2025  
**Archivo generado**: `cloudflare_access_status.md` (raíz del repositorio)
