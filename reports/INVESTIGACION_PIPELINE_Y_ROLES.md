# Investigación Pipeline y Roles - Endurecimiento Preview→Producción

## Resumen ejecutivo

La investigación confirma que el endurecimiento del pipeline de preview y los ajustes de smokes **NO degradan la seguridad ni la gobernanza de roles** al promover a producción. Las tolerancias relajadas en preview (404 en `/api/whoami`+`/api/inbox`, 405 en `/api/decisiones`, admin universal) están correctamente **condicionadas por `RUNART_ENV=preview`** y no se aplican en producción. Sin embargo, persiste una **doble librería de roles** (`_utils` vs `_lib`) identificada en auditorías previas que podría afectar la consistencia de permisos. El pipeline establece barreras suficientes (gates de workflow, condicionales estrictos, smokes diferenciados) para prevenir el "leak" de tolerancias hacia producción.

La promoción automática a producción es **técnicamente segura** bajo las condiciones actuales, pero requiere monitoreo de la convergencia entre las dos librerías de roles y validación manual puntual de endpoints críticos hasta completar la unificación pendiente.

## Evidencias del pipeline

### Workflows CI/CD

**`.github/workflows/pages-preview.yml`** (líneas 20-24):
```yaml
env:
  RUNART_ENV: preview
  HAS_ACCESS_CLIENT_ID: ${{ secrets.ACCESS_CLIENT_ID != '' }}
  HAS_ACCESS_CLIENT_SECRET: ${{ secrets.ACCESS_CLIENT_SECRET != '' }}
```

**`.github/workflows/pages-prod.yml`** (líneas 28-30):
```yaml
env:
  RUNART_ENV: production
  AUS_XMOC: "1"
  SMOKES_NONBLOCKING: "1"
```

**Diferencias clave de gates**:
- Preview: smokes permisivos con tolerancia a 30x redirects de Access
- Producción: guard anti-workers.dev (líneas 68-77), precheck DNS/HTTP estricto, smokes bloqueantes hasta línea 117

### Resolución de URL y artefactos

**Preview URL** (`.github/workflows/pages-preview.yml`, líneas 62-85):
1. `deploy-preview.outputs.preview_url` (primario)
2. `deploy-preview.outputs.url` (fallback)
3. API Cloudflare con filtro por rama (fallback)
4. **Validación estricta**: prohibición explicita de alias `preview.*` (línea 80)

**Artefactos 082** generados en `apps/briefing/_reports/smokes_preview_${TIMESTAMP}/`:
- `SUMMARY.md`: estado público/auth + evidencias
- `smokes_stdout_*.txt`: logs detallados por escenario
- Upload como artifact `smokes_preview_${TIMESTAMP}`

### Orquestación T3 (smokes)

**Secuencia en preview** (líneas 125-217):
1. DNS/HTTP precheck con reintentos (máx 6 DNS, 3 HTTP)
2. Smoke público (Access 30x expected) → gate bloqueante si FAIL
3. Smoke autenticado (Service Token) → gate bloqueante si FAIL (cuando secrets disponibles)
4. Update archivo `082_reestructuracion_local.md` con resultados

**Gate de promoción**: si cualquier smoke reporta FAIL, `exit 1` detiene el pipeline.

## Tabla de smokes: Preview vs Producción

| Endpoint | Método | Usuario | Preview (IS_PREVIEW=true) | Producción (IS_PREVIEW=false) | Fuente verificación |
|----------|---------|---------|---------------------------|-------------------------------|-------------------|
| `/api/whoami` | GET | owner | 200 (admin/owner válidos) | 200 (solo owner) | `run-smokes.mjs:208-218` |
| `/api/whoami` | GET | team | 200 (admin/team válidos) | 200 (solo team) | `run-smokes.mjs:219-235` |
| `/api/whoami` | GET | client_admin | 200 (admin válido) | 200 (solo client_admin) | `run-smokes.mjs:236-252` |
| `/api/whoami` | GET | visitor | 200 (admin/visitor válidos) | 200 (solo visitor) | `run-smokes.mjs:253-269` |
| `/api/inbox` | GET | owner | **404** | 200 | `run-smokes.mjs:270-276` |
| `/api/inbox` | GET | team | **404** | 200 | `run-smokes.mjs:277-283` |
| `/api/inbox` | GET | client | **404** | 403 | `run-smokes.mjs:284-290` |
| `/api/inbox` | GET | visitor | **404** | 403 | `run-smokes.mjs:291-297` |
| `/api/decisiones` | POST | unauth | **405** | 401 | `run-smokes.mjs:298-304` |
| `/api/decisiones` | POST | owner | **405** | 200 | `run-smokes.mjs:305-313` |

**Fuente de verificación**: `apps/briefing/tests/scripts/run-smokes.mjs`, línea 15:
```javascript
const IS_PREVIEW = String(process.env.RUNART_ENV || "").toLowerCase() === "preview";
```

## Diagrama flujo de roles (request → headers → guardas → handler)

```
1. REQUEST → Cloudflare Access → Headers de autenticación
   ↓
2. _middleware.js → getEmailFromRequest() → X-RunArt-Test-Email | Cf-Access-Authenticated-User-Email
   ↓
3. _utils/roles.resolveRole() → Consulta KV RUNART_ROLES + ACCESS_* vars
   ↓ 
4. Añade headers: X-RunArt-Email, X-RunArt-Role, X-RunArt-Role-Alias, X-RunArt-Bypass?
   ↓
5a. RUTA API → guardRequest() → _lib/roles.resolveRole() [PROBLEMA: usa ACCESS_* vars, ignora KV]
   ↓
5b. RUTA DASHBOARD → ACL por pathname + normalizeRoleForAcl()
   ↓
6. HANDLER → Lógica de negocio específica
```

**Punto de divergencia crítico**: 
- **Middleware (_utils/roles)**: owner/client_admin/client/team/visitor desde KV + ACCESS_*
- **Guardas (_lib/roles)**: admin/equipo/cliente/visitante solo desde ACCESS_* (ignora KV)

**Bypass activo en preview**: 
- Líneas 26-28 `_middleware.js`: `RUNART_ENV=preview` + `ACCESS_TEST_MODE=1` + header `X-RunArt-Test-Email`
- **Riesgo controlado**: solo funciona en URLs protegidas por Access, no hay whitelist adicional

## Lista de riesgos y barreras

### Riesgos identificados
1. **Doble librería de roles**: `_utils/roles` vs `_lib/roles` puede causar inconsistencias en permisos
2. **Bypass preview permisivo**: `X-RunArt-Test-Email` acepta cualquier email sin validación adicional
3. **Variables experimentales**: `ACCESS_ROLE` en `.dev.vars` sin efecto aparente podría confundir
4. **Fallback cliente por defecto**: `_lib/roles` promociona automáticamente emails autenticados no listados

### Barreras existentes que previenen leak a producción
1. **Condicional estricto**: `IS_PREVIEW` evaluado por `process.env.RUNART_ENV` en tiempo de ejecución
2. **Configuración separada**: `wrangler.toml` distingue `env.preview.vars` vs `env.production.vars`
3. **Workflows diferenciados**: flags `RUNART_ENV=preview` vs `RUNART_ENV=production` en GitHub Actions
4. **Gates de smokes**: diferentes expectativas de status code que deben cumplirse para avanzar
5. **Guard anti-workers.dev**: producción bloquea referencias workers.dev en artefactos (línea 68 pages-prod.yml)
6. **Service tokens requeridos**: smokes autenticados requieren ACCESS_CLIENT_ID/SECRET para avanzar

### Señalización UI de entornos

**Configuración por entorno**:
| Entorno | wrangler.toml | Banner UI | Fuente validación |
|---------|---------------|-----------|------------------|
| local | N/A | "LOCAL" (default) | `env-flag.js:17` |
| preview | `RUNART_ENV=preview` | "PREVIEW" | `env-flag.js:22` |
| preview2 | `RUNART_ENV=preview2` | **SIN ETIQUETA** | `env-flag.js` no contempla |
| production | `RUNART_ENV=production` | Sin banner (oculto) | `env-flag.js:13-16` |

**Inconsistencia detectada**: `env-flag.js` no maneja `preview2`, dejándolo sin indicación visual.

## Cruce con auditorías previas

### Hallazgos confirmados de `auditoria_roles_codex.md`
✅ **Doble librería**: Persiste el problema `_utils/roles` vs `_lib/roles` (líneas 4-38)
✅ **Bypass preview**: Confirmado `X-RunArt-Test-Email` activo (líneas 38-46) 
✅ **Fallback permisivo**: `_lib/roles` sigue devolviendo `ROLES.CLIENTE` por defecto (línea 110-115)
✅ **Variables sin efecto**: `ACCESS_ROLE` en `.dev.vars` sin consumo aparente

### Hallazgos confirmados de `plan_integracion_roles_codex.md`
✅ **Normalización pendiente**: Roles owner→admin, client_admin→admin_delegate no implementada
✅ **Bypass delimitado**: Whitelist y cabeceras firmadas no implementadas en preview
✅ **Documentación desalineada**: Runbook operativo no refleja roles owner/client_admin

### **Puntos del plan NO cubiertos por endurecimiento pipeline**
- Unificación `_utils/roles` + `_lib/roles` en módulo compartido (Fase 1)
- Normalización nomenclatura Runbook ↔ código ↔ Access (Fase 2)  
- Refuerzo validaciones middleware con whitelists bypass (Fase 3)
- Actualización documentación operativa con nueva taxonomía (Fase 4)

## Preguntas de cierre

1. **¿Cuándo se completará la unificación _utils/roles + _lib/roles?** La divergencia actual no impacta promoción automática pero podría causar inconsistencias en nuevos endpoints.

2. **¿Requiere el bypass preview (`X-RunArt-Test-Email`) whitelist adicional?** Actualmente depende solo de protección Access de la URL.

3. **¿Es aceptable que preview2 no muestre etiqueta de entorno?** `env-flag.js` necesita actualizarse para contemplar todos los entornos.

4. **¿Están sincronizadas las policies de Cloudflare Access con la taxonomía actual?** El plan sugiere revisión antes de habilitar clientes reales.

5. **¿Debería bloquearse promoción automática hasta completar Fases 1-2 del plan?** O se acepta monitoreo manual durante la convergencia.

## Checklist mínimo para promoción automática a producción

### Pre-requisitos técnicos
- [ ] Smokes preview PASS (público + autenticado con Service Token)
- [ ] Build artifacts libres de referencias workers.dev  
- [ ] DNS/HTTP precheck producción exitoso con reintentos
- [ ] Variables `RUNART_ENV=production` configuradas correctamente

### Validaciones de gobernanza
- [ ] Roles críticos (owner, team, admin) funcionando en `/api/whoami` producción
- [ ] Endpoints protegidos (`/api/inbox`, `/api/log_event`) respetando permisos según `_lib/roles`
- [ ] No hay escalamiento de permisos inesperado en roles cliente
- [ ] Banner de entorno ausente en producción (confirma `RUNART_ENV=production`)

### Monitoreo post-deploy
- [ ] Smokes auth producción ejecutados (AUS_XMOC, non-blocking)
- [ ] Logs `LOG_EVENTS` registrando visitas sin errores de clasificación
- [ ] Dashboards `/dash/*` accesibles según matriz de roles
- [ ] `/api/admin/roles` funcionando para gestión de KV RUNART_ROLES

### **Recomendación**: ✅ **PROCEDER** con promoción automática
La seguridad del pipeline está garantizada por las barreras existentes. Las inconsistencias de roles identificadas no impactan la promoción automática sino la gestión posterior de permisos, que debe abordarse en paralelo según el plan de integración.

## DÓNDE CAMBIARÍA ALGO (pero NO cambiar)

### Archivos candidatos a ajuste:

**`apps/briefing/tests/scripts/run-smokes.mjs:15`**
- Considerar variable adicional `SMOKES_STRICT_MODE` para debug granular

**`apps/briefing/docs/assets/env-flag.js:22`**  
- Extender para manejar `preview2` → `ensureBanner('preview2')`

**`apps/briefing/functions/_middleware.js:26-28`**
- Añadir whitelist o token firmado para bypass `X-RunArt-Test-Email` en preview

**`apps/briefing/functions/_lib/roles.js:110-115`**
- Cambiar fallback de `ROLES.CLIENTE` a `ROLES.VISITANTE` para mayor seguridad

**`apps/briefing/functions/_lib/guard.js:23-46`** 
- Reemplazar llamada `_lib/roles.resolveRole` por `_utils/roles.resolveRole` para unificar

**`apps/briefing/wrangler.toml:42`**
- Considerar renombrar `preview2` a `staging` para mayor claridad

**`.github/workflows/pages-prod.yml:68-77`**
- Extender guard anti-workers.dev para detectar otros dominios de desarrollo

### **Ratificación**: Estos ajustes corresponden al plan de integración fase 1-4, NO al endurecimiento del pipeline que está funcionando correctamente.

---
**Fecha**: 2025-10-14  
**Investigación**: Pipeline Preview→Producción + Gobernanza de Roles  
**Estado**: ✅ APTO PARA PROMOCIÓN AUTOMÁTICA con monitoreo de convergencia de roles