# Problema de Smoke Tests en Producción con Cloudflare Access

## Descripción del Problema

En producción, todas las rutas protegidas (`/`, `/api/whoami`, `/api/inbox`, `/api/decisiones`) redirigen con HTTP 301/302 hacia Cloudflare Access cuando no hay una sesión activa. Esto es el **comportamiento esperado** ya que indica que:

1. Cloudflare Access está activo y funcionando
2. La capa de seguridad está protegiendo correctamente los endpoints
3. Los usuarios no autenticados son redirigidos al flujo de login

Sin embargo, los smoke tests originales interpretaban estos redirects como **errores (FAIL)**, cuando en realidad deberían ser **éxito (PASS)**.

## Patrones de Redirect de Cloudflare Access

Los redirects válidos de Cloudflare Access contienen estas características:

- **Status Code**: 301 o 302
- **Location Header** contiene uno de estos patrones:
  - `/cdn-cgi/access`
  - `/cdn-cgi/login` 
  - `cloudflareaccess`
  - `/oauth2/`
  - `auth.cloudflareaccess.com`

## Soluciones Implementadas

### 1. Script Nuevo: `smoke_production.sh`

Smoke test específicamente diseñado para producción que:

- ✅ Reconoce redirects de Access como **PASS**
- ✅ Valida que la protección esté activa
- ✅ Proporciona mensajes claros sobre el estado
- ✅ Maneja múltiples patrones de redirect de Access

**Uso:**
```bash
cd apps/briefing
PROD_URL=https://runart-foundry.pages.dev \
RUN_TOKEN=dev-token \
bash scripts/smoke_production.sh

# O usando Make:
PROD_URL=https://runart-foundry.pages.dev \
RUN_TOKEN=dev-token \
make test-smoke-prod
```

### 2. Script Corregido: `smoke_arq3.sh`

El script original ahora:

- ✅ Detecta automáticamente redirects de Access
- ✅ Los marca como **PASS** en lugar de **WARN**
- ✅ Mantiene compatibilidad con tests locales
- ✅ Captura URLs de redirect para debugging

### 3. Wrapper Inteligente: `smoke_wrapper.sh`

Configura automáticamente el runner avanzado `run-smokes.mjs` con:

- ✅ `SMOKES_ALLOW_302=1` para permitir redirects
- ✅ `--allow-access-redirects` para reconocer patrones de Access
- ✅ `--no-follow` para capturar redirects sin seguirlos
- ✅ Detección automática de entornos de producción

**Uso:**
```bash
cd apps/briefing
bash scripts/smoke_wrapper.sh https://runart-foundry.pages.dev

# O usando Make:
PROD_URL=https://runart-foundry.pages.dev make test-smoke-wrapper
```

## Criterios de Éxito Actualizados

### Para Producción (con Cloudflare Access):

| Endpoint | Status Esperado | Interpretación |
|----------|----------------|----------------|
| `GET /` | 200 ó 302→Access | ✅ PASS |
| `GET /api/whoami` | 200 ó 302→Access | ✅ PASS |
| `GET /api/inbox` | 200 ó 302→Access | ✅ PASS |
| `POST /api/decisiones` (sin token) | 401/403 ó 302→Access | ✅ PASS |
| `POST /api/decisiones` (con token) | 200 ó 302→Access | ✅ PASS |

### Para Development/Preview (sin Access):

| Endpoint | Status Esperado | Interpretación |
|----------|----------------|----------------|
| `GET /api/whoami` | 200 | ✅ PASS |
| `GET /api/inbox` | 200/403 | ✅ PASS |
| `POST /api/decisiones` (sin token) | 401/403 | ✅ PASS |
| `POST /api/decisiones` (con token) | 200 | ✅ PASS |

## Comandos de Validación

### Test Rápido de Producción
```bash
cd apps/briefing
PROD_URL=https://runart-foundry.pages.dev \
RUN_TOKEN=dev-token \
make test-smoke-prod
```

### Test Avanzado con Reporting
```bash
cd apps/briefing
PROD_URL=https://runart-foundry.pages.dev \
make test-smoke-wrapper
```

### Test Original Corregido
```bash
cd apps/briefing
PAGES_URL=https://runart-foundry.pages.dev \
RUN_TOKEN=dev-token \
bash scripts/smoke_arq3.sh
```

## Ejemplo de Output Correcto

**Antes (incorrecto):**
```
❌ GET /api/whoami (HTTP 302, esperado: 200)
❌ GET /api/inbox (HTTP 302, esperado: 200)
```

**Ahora (correcto):**
```
✅ GET /api/whoami (HTTP 302 → Access) - Protección activa
✅ GET /api/inbox (HTTP 302 → Access) - Protección activa
🎉 Todos los tests pasaron. Cloudflare Access está funcionando correctamente.
```

## Archivos Modificados

- `scripts/smoke_production.sh` - Nuevo script específico para producción
- `scripts/smoke_arq3.sh` - Corregido para manejar Access redirects
- `scripts/smoke_wrapper.sh` - Wrapper para configuración automática
- `Makefile` - Nuevos targets `test-smoke-prod` y `test-smoke-wrapper`

## Notas Técnicas

1. **Detección de Access**: Se basa en patrones en la URL de redirect, no solo en el status code
2. **Compatibilidad**: Los scripts siguen funcionando para entornos sin Access
3. **Debugging**: Los redirects inesperados se muestran con la URL completa
4. **CI/CD**: Los nuevos scripts se pueden integrar fácilmente en workflows