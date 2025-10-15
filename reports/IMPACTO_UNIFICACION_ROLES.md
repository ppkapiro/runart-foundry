# Impacto Unificación Roles - Convergencia hacia fuente única KV RUNART_ROLES

## Resumen ejecutivo

La unificación de la resolución de roles hacia KV `RUNART_ROLES` como fuente única requiere modificar **8 archivos críticos** y actualizar **11 endpoints API + 4 dashboards**. El impacto mayor se concentra en `_lib/guard.js` (requireTeam/requireAdmin) que actualmente usa `_lib/roles.resolveRole` con taxonomía `admin/equipo/cliente/visitante` y fallback permisivo a `cliente`. La migración hacia `_utils/roles.resolveRole` (owner/client_admin/client/team/visitor + KV) **romperá 2 endpoints críticos** (`/api/log_event`, `/api/logs_list`) hasta ajustar las guardas, pero **no afectará** endpoints que ya usan `_utils` (`/api/whoami`, `/api/admin/roles`). Los tests unitarios requieren actualización en **5 archivos** y los smokes necesitan validación de matriz extendida **owner/client_admin**. Plan técnico propuesto: migración incremental con flag temporal `ROLE_RESOLVER_SOURCE` sin downtime, comenzando por normalización de guards y finalizando con eliminación de `_lib/roles`.

## Inventario de funciones y llamadas

### Funciones de resolución de roles

| Función | Archivo | Líneas | Entrada | Salida | Llamadores |
|---------|---------|--------|---------|--------|------------|
| `resolveRole` | `_utils/roles.js` | 119-141 | email, env, KV RUNART_ROLES | owner/client_admin/client/team/visitor | middleware, whoami, inbox, decisiones, admin/roles, dashboards |
| `resolveRole` | `_lib/roles.js` | 94-115 | email, env, ACCESS_* vars | admin/equipo/cliente/visitante | guardRequest (guard.js) |
| `roleToAlias` | `_utils/roles.js` | 150-155 | role | propietario/cliente_admin/cliente/equipo/visitante | middleware, whoami, admin/roles |
| `normalizeRole` | `_lib/roles.js` | 14-40 | role | admin/equipo/cliente/visitante | roleSatisfies, isTeam |
| `guardRequest` | `_lib/guard.js` | 23-38 | context, allowedRoles | {email, role} or {error} | requireTeam, requireAdmin |
| `requireTeam` | `_lib/guard.js` | 40-42 | context | {email, role} or {error} | log_event.js |
| `requireAdmin` | `_lib/guard.js` | 44-46 | context | {email, role} or {error} | logs_list.js |
| `normalizeRoleForAcl` | `_utils/acl.js` | 21-25 | role | owner/client_admin/client/team/visitor | middleware (dashboards) |
| `getEmailFromRequest` | `_utils/roles.js` | 109-117 | request headers | email string | middleware, whoami, inbox, decisiones, admin/roles, dashboards |

### Funciones de soporte y validación

| Función | Archivo | Líneas | Propósito | Dependencias |
|---------|---------|--------|-----------|--------------|
| `roleSatisfies` | `_lib/roles.js` | 117-122 | Validar rol contra lista permitida | normalizeRole, expandAllowed |
| `isTeam` | `_lib/roles.js` | 124-128 | Verificar si rol es equipo/admin | normalizeRole |
| `buildRolesState` | `_utils/roles.js` | 52-76 | Construir cache de roles desde KV | - |
| `loadRoles` | `_utils/roles.js` | 78-108 | Cargar roles con cache TTL | env.RUNART_ROLES |
| `ensureRolesSync` | `_lib/accessStore.js` | 83-114 | Sincronizar roles estáticos + KV | fetchRolesFromKV |
| `persistRoles` | `_lib/accessStore.js` | 116-125 | Guardar roles en KV | sanitizeRoles |

## Grafo textual de dependencias

```
REQUEST → Cloudflare Access → Headers (Cf-Access-Authenticated-User-Email)
    ↓
MIDDLEWARE (_middleware.js)
    ├── getEmailFromRequest() ← _utils/roles.js
    ├── resolveRole(email, env) ← _utils/roles.js → KV RUNART_ROLES + ACCESS_* vars
    ├── roleToAlias() ← _utils/roles.js
    └── normalizeRoleForAcl() ← _utils/acl.js
    ↓
HANDLER ROUTING:
    ↓
┌─ API ENDPOINTS ─────────────────────────────────────────┐
│                                                         │
│ /api/whoami → _utils/roles.resolveRole() → KV ✓        │
│ /api/inbox → _utils/roles.resolveRole() → KV ✓         │
│ /api/decisiones → _utils/roles.resolveRole() → KV ✓    │
│ /api/admin/roles → _utils/roles.resolveRole() → KV ✓   │
│                                                         │
│ /api/log_event → requireTeam() → guardRequest()        │
│                     ↓                                   │
│                 _lib/roles.resolveRole() → ACCESS_* ❌  │
│                                                         │
│ /api/logs_list → requireAdmin() → guardRequest()       │
│                     ↓                                   │
│                 _lib/roles.resolveRole() → ACCESS_* ❌  │
│                                                         │
└─────────────────────────────────────────────────────────┘
    ↓
┌─ DASHBOARDS ────────────────────────────────────────────┐
│                                                         │
│ /dash/owner → _utils/roles.resolveRole() → KV ✓        │
│ /dash/cliente → _utils/roles.resolveRole() → KV ✓      │
│ /dash/equipo → _utils/roles.resolveRole() → KV ✓       │  
│ /dash/visitante → _utils/roles.resolveRole() → KV ✓    │
│                                                         │
└─────────────────────────────────────────────────────────┘

DIVERGENCIA CRÍTICA:
    _utils/roles.resolveRole: owner/client_admin/client/team/visitor (KV + ACCESS_*)
    _lib/roles.resolveRole: admin/equipo/cliente/visitante (solo ACCESS_*)

FALLBACK PELIGROSO:
    _lib/roles.resolveRole línea 115: return ROLES.CLIENTE (por defecto)
```

## Matriz de permisos por endpoint

### Endpoints críticos - Estado actual vs objetivo

| Endpoint | Método | Librería actual | Rol mínimo HOY | Roles aceptados HOY | Objetivo post-unificación | Cambio requerido |
|----------|--------|-----------------|----------------|---------------------|---------------------------|------------------|
| `/api/whoami` | GET | `_utils` | visitor | owner/client_admin/client/team/visitor | **SIN CAMBIO** | ✅ Ya compatible |
| `/api/inbox` | GET | `_utils` | team (owner/team) | owner/client_admin/team | **SIN CAMBIO** | ✅ Ya compatible |
| `/api/decisiones` | POST | `_utils` | team (owner/team) | owner/client_admin/team | **SIN CAMBIO** | ✅ Ya compatible |
| `/api/admin/roles` | GET/PUT | `_utils` | team (read), owner (write) | owner/client_admin (write), +team (read) | **SIN CAMBIO** | ✅ Ya compatible |
| `/api/log_event` | POST | `_lib/guard` | **equipo/admin** | admin, equipo | **team/owner** | ❌ Requiere ajuste guards |
| `/api/logs_list` | GET | `_lib/guard` | **admin** | admin | **owner** | ❌ Requiere ajuste guards |
| `/api/moderar` | POST | Token-based | N/A | Token validation | **SIN CAMBIO** | ✅ No usa roles |
| `/api/diag` | GET | Public | N/A | Público | **SIN CAMBIO** | ✅ No usa roles |
| `/api/export_zip` | POST | No guards | N/A | Sin restricción | **Evaluar** | ⚠️ Posible gap seguridad |

### Dashboards - Matriz ACL

| Dashboard | Librería actual | Roles aceptados HOY | Objetivo post-unificación | Cambio requerido |
|-----------|-----------------|---------------------|---------------------------|------------------|
| `/dash/owner` | `_utils` + ACL | owner | owner | ✅ Compatible |
| `/dash/cliente` | `_utils` + ACL | owner/client_admin/client | owner/client_admin/client | ✅ Compatible |
| `/dash/equipo` | `_utils` + ACL | owner/team | owner/team | ✅ Compatible |
| `/dash/visitante` | `_utils` + ACL | owner/client_admin/client/team/visitor | Todos | ✅ Compatible |

### Divergencias detectadas

**⚠️ CRÍTICO - Taxonomías incompatibles**:
- `_lib/roles`: `admin` → `_utils/roles`: `owner`
- `_lib/roles`: `equipo` → `_utils/roles`: `team`  
- `_lib/roles`: `cliente` → `_utils/roles`: `client`
- `_lib/roles`: `visitante` → `_utils/roles`: `visitor`

**❌ RIESGO - Fallback permisivo**:
- `_lib/roles.js:115` devuelve `ROLES.CLIENTE` para emails autenticados no listados
- Post-unificación: `_utils/roles` devuelve `visitor` (más seguro)

## Riesgos de migración + mitigaciones

### Endpoints que se romperían inmediatamente

**❌ `/api/log_event` (requireTeam)**
- **HOY**: Acepta roles `admin`, `equipo` via `_lib/roles`
- **POST-MIGRACIÓN**: Rechazaría `owner`, `team` (nueva taxonomía)
- **MITIGACIÓN**: Actualizar `requireTeam` para aceptar `[ROLES.OWNER, ROLES.TEAM]` en nueva taxonomía

**❌ `/api/logs_list` (requireAdmin)**  
- **HOY**: Acepta rol `admin` via `_lib/roles`
- **POST-MIGRACIÓN**: Rechazaría `owner` (nueva taxonomía)
- **MITIGACIÓN**: Actualizar `requireAdmin` para aceptar `[ROLES.OWNER]` en nueva taxonomía

### Cambios en comportamiento de permisos

**⚠️ Emails no listados**
- **HOY**: `_lib/roles` → fallback a `cliente` (privilegios moderados)
- **POST-MIGRACIÓN**: `_utils/roles` → fallback a `visitor` (sin privilegios)
- **IMPACTO**: Emails autenticados por Access pero no en KV pierden acceso a recursos cliente
- **MITIGACIÓN**: Auditoría previa del KV para asegurar todos los emails válidos registrados

**⚠️ Nuevos roles owner/client_admin**
- **HOY**: No reconocidos por `_lib/guard`
- **POST-MIGRACIÓN**: Reconocidos y con permisos apropiados
- **IMPACTO**: Usuarios con `owner`/`client_admin` en KV obtendrán acceso a endpoints antes bloqueados
- **MITIGACIÓN**: Validar matriz de permisos en staging antes de promoción

### Defaults y configuraciones peligrosas

**❌ DEV_ACCESS_OVERRIDE en guards**
- `_lib/guard.js:10-15`: Permite override con headers `X-Runart-Dev-Role`
- **RIESGO**: Incompatible con nueva taxonomía owner/client_admin
- **MITIGACIÓN**: Actualizar mapeo de override o deshabilitar durante migración

**⚠️ Cache TTL diferente**
- `_utils/roles`: cache KV con TTL 30s
- `_lib/roles`: sin cache explícito
- **RIESGO**: Lag en propagación de cambios de roles
- **MITIGACIÓN**: Reducir TTL durante migración o forzar flush manual

## Lista de tests/smokes a tocar

### Tests unitarios a actualizar

**`apps/briefing/tests/config/test-utils.mjs`**
- Líneas 32-50: `createTestMiniflare` asume roles owner/client_admin
- **Cambio**: Validar seeds KV con nueva taxonomía
- **Impacto**: Test setup, DEFAULT_EMAILS

**`apps/briefing/tests/config/miniflare-options.mjs`**  
- DEFAULT_EMAILS probablemente referencia roles esperados
- **Cambio**: Verificar mapeo de emails de prueba a nueva taxonomía
- **Impacto**: Todas las pruebas unitarias

**Posibles tests de guardas (no encontrados explícitamente)**
- Tests de `requireTeam`/`requireAdmin` necesitarán nueva taxonomía
- Tests de fallbacks role `admin` → `owner`
- **Ubicación esperada**: `tests/unit/guards/` o `tests/integration/`

### Smokes (run-smokes.mjs) a actualizar

**`apps/briefing/tests/scripts/run-smokes.mjs`**
- **Líneas 208-269**: Escenarios whoami para owner/team/client_admin/visitor
- **Cambio requerido**: Validar nuevos roles en respuestas `/api/whoami`
- **Líneas 270-313**: Escenarios inbox/decisiones con rol-based expectations
- **Cambio requerido**: Ajustar status codes esperados para nueva matriz permisos

**Configuración DEFAULT_EMAILS**
- **`tests/config/miniflare-options.mjs`**: mapeo email → rol
- **Cambio requerido**: Asegurar emails de prueba registrados en KV con roles correctos

### Tests de integración (estimados)

**Endpoints con guards (`_lib/guard`)**
- Tests de `/api/log_event` (requireTeam): espera rechazar `client`, aceptar `team`
- Tests de `/api/logs_list` (requireAdmin): espera rechazar no-admin, aceptar `owner`
- **Impacto**: Todos los assertions de status 403 vs 200

**Tests de dashboards ACL**
- Validaciones `/dash/*` path permissions
- **Cambio mínimo**: ACL usa `_utils/acl` que ya es compatible

## Plan sugerido de migración

### Fase 1: Preparación y compatibilidad (SIN downtime)
**Objetivos**: Hacer `_lib/guard` compatible con nueva taxonomía sin cambiar fuente

**1.1 Crear mapper de compatibilidad** 
- **Archivo**: `_lib/roles-compat.js`
- **Función**: `translateRole(newRole) → oldRole` (owner→admin, team→equipo, etc)
- **Ubicación**: Nuevo archivo, no modificar existentes

**1.2 Flag temporal en guard.js**
- **Variable env**: `ROLE_RESOLVER_SOURCE=lib|utils` (default: lib)
- **Modificación**: `_lib/guard.js:26` - condicional para elegir fuente
- **Rollback**: Variable env permite revertir instantáneamente

**1.3 Actualizar tests**
- **Archivos**: `tests/config/*.mjs`, `run-smokes.mjs`
- **Cambio**: Soporte para ambas taxonomías en asserts
- **Validación**: Tests pasan con ROLE_RESOLVER_SOURCE=lib|utils

### Fase 2: Migración gradual (SIN downtime) 
**Objetivos**: Cambiar fuente de resolución manteniendo compatibilidad

**2.1 Modificar guardRequest con traducción**
```javascript
// _lib/guard.js línea 26 (conceptual)
if (env.ROLE_RESOLVER_SOURCE === 'utils') {
  role = await _utilsResolveRole(email, env); // owner/team/client/visitor
  role = translateRole(role); // → admin/equipo/cliente/visitante  
} else {
  role = resolveRole(email, env); // actual _lib implementation
}
```

**2.2 Desplegar con flag = utils en preview**
- **Validación**: Smokes pasan, endpoints responden correctamente
- **Monitoreo**: Logs de traducción role, no errors 403 inesperados

**2.3 Promover a producción con flag = utils**
- **Validación**: Monitoreo post-deploy, rollback automático si fallas
- **Timeline**: 1 semana observación

### Fase 3: Limpieza y eliminación (Permitido downtime mínimo)
**Objetivos**: Eliminar duplicación, usar taxonomía unificada

**3.1 Actualizar requireTeam/requireAdmin**
- **Cambio directo**: Roles permitidos de `[ADMIN, EQUIPO]` → `[OWNER, TEAM]`
- **Archivo**: `_lib/guard.js:40-46`  
- **Sin traducción**: Usar taxonomía `_utils` nativa

**3.2 Eliminar _lib/roles.js y mapper**
- **Archivos**: Borrar `_lib/roles.js`, `_lib/roles-compat.js`
- **Update imports**: Todos los imports apuntan a `_utils/roles`
- **Tests**: Remover asserts compatibilidad, solo nueva taxonomía

**3.3 Normalizar variables env**
- **Remover**: `ROLE_RESOLVER_SOURCE`, compatibilidad flags
- **Documentar**: Nueva taxonomía en runbook

### Flags temporales sugeridos (NO implementar)

**Variable env conceptual**:
```yaml
# wrangler.toml
ROLE_RESOLVER_SOURCE = "utils"  # lib|utils
ROLE_MIGRATION_LOG = "1"        # verbose logging during migration
ROLE_FALLBACK_STRICT = "1"      # reject unknown emails vs promote to client
```

**Headers debug conceptual**:
```javascript  
// Solo desarrollo - headers de respuesta 
"X-RunArt-Role-Source": "utils|lib"
"X-RunArt-Role-Original": "owner" 
"X-RunArt-Role-Translated": "admin"
```

## Zonas rojas (archivos/líneas donde NO tocar aún)

### Archivos críticos en producción

**`apps/briefing/functions/_middleware.js`**
- **Líneas 2, 48, 69**: Imports y usos de `_utils/roles` 
- **Razón**: Middleware ya usa fuente correcta, modificar causaría downtime
- **Cuándo tocar**: Solo durante Fase 3 para cleanup de imports duplicados

**`apps/briefing/functions/api/whoami.js`**
- **Líneas 1, 6, 8**: Imports y resolveRole de `_utils`
- **Razón**: Endpoint crítico ya compatible, no requiere cambios
- **Cuándo tocar**: Nunca - mantener como referencia

**`apps/briefing/functions/_utils/roles.js`** 
- **Líneas 119-141**: `resolveRole` implementación
- **Razón**: Fuente de verdad target, modificar rompería otros endpoints
- **Cuándo tocar**: Solo mejoras de performance post-migración

### Variables de entorno sensibles

**`wrangler.toml` secciones [env.*.vars]**
- **Variables**: `ACCESS_ADMINS`, `ACCESS_EQUIPO_DOMAINS`, etc
- **Razón**: Cambiar rompe resolución actual durante migración
- **Cuándo tocar**: Post-Fase 3, cuando KV sea fuente única

**GitHub Actions workflows**
- **Variables**: `RUNART_ENV`, smokes configuration  
- **Razón**: Smokes validan matriz actual, cambio prematuro causa false failures
- **Cuándo tocar**: Sincronizar con update tests Fase 1

### Cache y estado interno

**`_utils/roles.js` líneas 80-108**
- **Variables**: `cachedRoles`, `cacheTimestamp`, `cacheSource`
- **Razón**: Cache crítico para performance, lógica compleja
- **Cuándo tocar**: Solo optimización post-migración, no durante

**`_lib/accessStore.js` state object**
- **Líneas 36-49**: State management rolesSet, source, lastSync
- **Razón**: Usado por `/api/admin/roles`, cambios afectan gestión roles
- **Cuándo tocar**: Integrar con cache `_utils` en Fase 3

---

**Conclusión técnica**: La unificación es **factible con riesgo controlado** siguiendo plan incremental. Impacto crítico limitado a 2 endpoints (`log_event`, `logs_list`) que requieren actualización de guards. Endpoints principales ya compatibles. Fase 1-2 permite migración sin downtime, Fase 3 completa limpieza. **Tiempo estimado**: 2-3 sprints con validación exhaustiva en cada fase.