# Referencia de Proveedores de Traducción

**Sistema Multi-Provider**: DeepL + OpenAI con selección automática y fallback

## 📋 Índice

1. [Proveedores Disponibles](#proveedores-disponibles)
2. [Variables de Configuración](#variables-de-configuración)
3. [Modos de Operación](#modos-de-operación)
4. [Comparativa de Proveedores](#comparativa-de-proveedores)
5. [Límites y Precios](#límites-y-precios)
6. [Ejemplos de Configuración](#ejemplos-de-configuración)
7. [Calidad de Traducción](#calidad-de-traducción)
8. [Troubleshooting](#troubleshooting)

---

## Proveedores Disponibles

### 1. DeepL

**API**: https://www.deepl.com/pro-api  
**Planes**: Free (500K chars/mes) | Pro ($5.49+/mes)

**Características**:
- ✅ Traducción de alta calidad especializada
- ✅ Preserva formato HTML
- ✅ Soporte para 31 idiomas
- ✅ Rate limit: ~10 req/s (Free), ~100 req/s (Pro)
- ✅ Mejor para textos largos y técnicos

**Detección de plan**:
- API Free: key contiene `:fx`
- API Pro: key sin `:fx`

**Endpoints**:
- Free: `https://api-free.deepl.com/v2/translate`
- Pro: `https://api.deepl.com/v2/translate`

---

### 2. OpenAI

**API**: https://platform.openai.com/docs/api-reference  
**Modelos**: gpt-4o-mini (recomendado), gpt-4, gpt-3.5-turbo

**Características**:
- ✅ Traducción contextual con IA
- ✅ Personalizable via temperature
- ✅ Soporte para 100+ idiomas
- ✅ Rate limit: 3,500 RPM (Tier 1), 10,000 RPM (Tier 2)
- ✅ Mejor para textos creativos y conversacionales

**Modelos disponibles**:
```
gpt-4o-mini        → $0.150/1M tokens input, $0.600/1M output (recomendado)
gpt-4o             → $5.00/1M tokens input, $15.00/1M output
gpt-4-turbo        → $10.00/1M tokens input, $30.00/1M output
gpt-3.5-turbo      → $0.50/1M tokens input, $1.50/1M output
```

**Endpoint**:
- `https://api.openai.com/v1/chat/completions`

---

## Variables de Configuración

### Variables Requeridas (GitHub Variables)

```bash
# Modo de selección
TRANSLATION_PROVIDER=auto  # deepl | openai | auto

# Control general
AUTO_TRANSLATE_ENABLED=false
DRY_RUN=true
TRANSLATION_BATCH_SIZE=3

# WordPress
WP_BASE_URL=https://staging.runartfoundry.com
APP_ENV=staging
```

### Secrets Requeridos (GitHub Secrets)

```bash
# Credenciales WordPress
WP_USER=github-actions
WP_APP_PASSWORD=xxxx xxxx xxxx xxxx

# API Keys (al menos una necesaria)
DEEPL_API_KEY=tu_deepl_key       # Opcional si usas OpenAI
OPENAI_API_KEY=sk-proj-xxxx      # Opcional si usas DeepL
```

### Variables Opcionales (OpenAI)

```bash
# Configuración OpenAI (solo si provider=openai o auto)
OPENAI_MODEL=gpt-4o-mini          # Default: gpt-4o-mini
OPENAI_TEMPERATURE=0.3            # Default: 0.3 (0.0-1.0)
```

---

## Modos de Operación

### 1. Modo DeepL Exclusivo

**Configuración**:
```bash
TRANSLATION_PROVIDER=deepl
DEEPL_API_KEY=tu_clave_deepl
```

**Comportamiento**:
- ✅ Solo usa DeepL
- ❌ Falla si DeepL no está disponible o no hay key
- ✅ No consume créditos OpenAI

**Casos de uso**:
- Textos técnicos, legales, académicos
- Traducción de alta precisión requerida
- Plan DeepL Pro disponible

---

### 2. Modo OpenAI Exclusivo

**Configuración**:
```bash
TRANSLATION_PROVIDER=openai
OPENAI_API_KEY=sk-proj-xxxx
OPENAI_MODEL=gpt-4o-mini
OPENAI_TEMPERATURE=0.3
```

**Comportamiento**:
- ✅ Solo usa OpenAI
- ❌ Falla si OpenAI no está disponible o no hay key
- ✅ No consume créditos DeepL

**Casos de uso**:
- Contenido creativo, marketing, blogs
- Traducción contextual con tono específico
- Múltiples idiomas no soportados por DeepL

---

### 3. Modo Auto (Recomendado)

**Configuración**:
```bash
TRANSLATION_PROVIDER=auto
DEEPL_API_KEY=tu_clave_deepl      # Preferido
OPENAI_API_KEY=sk-proj-xxxx       # Fallback
```

**Comportamiento**:
1. **Intenta DeepL primero** (si key disponible)
2. **Si DeepL falla** → fallback automático a OpenAI
3. **Si OpenAI falla** → reporta error
4. **Si ninguna key** → modo dry-run

**Ventajas**:
- ✅ Máxima disponibilidad (redundancia)
- ✅ Usa DeepL cuando posible (mejor calidad)
- ✅ Fallback automático sin intervención
- ✅ Logs registran qué proveedor se usó

**Casos de uso**:
- Producción (máxima confiabilidad)
- Entornos con múltiples APIs configuradas
- Testing de proveedores

---

## Comparativa de Proveedores

| Característica | DeepL | OpenAI (gpt-4o-mini) |
|----------------|-------|----------------------|
| **Calidad técnica** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Calidad creativa** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Velocidad** | ~1-2s | ~2-4s |
| **Preserva HTML** | ✅ Excelente | ✅ Bueno |
| **Contexto** | ❌ Limitado | ✅ Excelente |
| **Idiomas** | 31 | 100+ |
| **Rate limit** | 10-100 req/s | 3,500 RPM |
| **Costo (500 pgs)** | Gratis (Free) | ~$0.50 |
| **Consistencia** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

**Recomendación**:
- **DeepL**: Traducción de contenido técnico, legal, documentación
- **OpenAI**: Traducción de contenido marketing, blogs, creativos
- **Auto**: Producción (usa DeepL, fallback OpenAI)

---

## Límites y Precios

### DeepL

#### Plan Free
```
Límite: 500,000 caracteres/mes
Precio: $0
Caracteres por página (promedio): 3,000
Páginas mensuales: ~166 páginas
Rate limit: ~10 req/s
```

#### Plan Pro
```
Precio base: $5.49/mes (100,000 chars)
Adicional: $24.99/millón chars
Páginas mensuales: ~33 páginas (base)
Rate limit: ~100 req/s
```

**Cálculo de páginas**:
```bash
# Página promedio: 3,000 caracteres (título + contenido)
# DeepL Free: 500,000 / 3,000 = 166 páginas/mes
# DeepL Pro base: 100,000 / 3,000 = 33 páginas/mes
```

---

### OpenAI

#### Modelo: gpt-4o-mini (Recomendado)
```
Input: $0.150 / 1M tokens
Output: $0.600 / 1M tokens
Tokens por página (promedio): 1,500 input + 1,500 output = 3,000 total
Costo por página: ~$0.001
```

**Cálculo de costos**:
```python
# Página promedio: 3,000 caracteres
# Tokens: ~750 palabras = 1,500 tokens (1 token ≈ 0.75 palabras)

# Input (traducir EN→ES): 1,500 tokens × $0.150/1M = $0.000225
# Output (texto ES): 1,500 tokens × $0.600/1M = $0.000900
# Total por página: $0.001125 ≈ $0.001

# 500 páginas: $0.50
# 1,000 páginas: $1.00
```

#### Otros modelos
```
gpt-3.5-turbo: ~$0.002/página (más económico, menor calidad)
gpt-4o: ~$0.030/página (mejor calidad, más caro)
gpt-4-turbo: ~$0.060/página (máxima calidad, muy caro)
```

---

## Ejemplos de Configuración

### Ejemplo 1: Staging con DeepL Free

**GitHub Variables**:
```bash
APP_ENV=staging
WP_BASE_URL=https://staging.runartfoundry.com
TRANSLATION_PROVIDER=deepl
AUTO_TRANSLATE_ENABLED=false
DRY_RUN=true
TRANSLATION_BATCH_SIZE=3
```

**GitHub Secrets**:
```bash
WP_USER=github-actions
WP_APP_PASSWORD=xxxx xxxx xxxx
DEEPL_API_KEY=tu_clave_deepl_free:fx
```

**Workflow dispatch**:
```bash
# Test dry-run
dry_run: true
batch_size: 3

# Traducción real (después de test)
dry_run: false
batch_size: 5
```

---

### Ejemplo 2: Producción con Auto-Fallback

**GitHub Variables**:
```bash
APP_ENV=production
WP_BASE_URL=https://runartfoundry.com
TRANSLATION_PROVIDER=auto           # DeepL principal + OpenAI fallback
AUTO_TRANSLATE_ENABLED=true
DRY_RUN=false
TRANSLATION_BATCH_SIZE=5
OPENAI_MODEL=gpt-4o-mini
OPENAI_TEMPERATURE=0.3
```

**GitHub Secrets**:
```bash
WP_USER=github-actions
WP_APP_PASSWORD=xxxx xxxx xxxx
DEEPL_API_KEY=tu_clave_deepl_pro    # Sin :fx
OPENAI_API_KEY=sk-proj-xxxx
```

---

### Ejemplo 3: Testing Multi-Provider

**Test 1: Solo DeepL**
```bash
TRANSLATION_PROVIDER=deepl
DEEPL_API_KEY=tu_clave
# OpenAI key no configurada
```

**Test 2: Solo OpenAI**
```bash
TRANSLATION_PROVIDER=openai
OPENAI_API_KEY=sk-proj-xxxx
# DeepL key no configurada
```

**Test 3: Auto con ambos**
```bash
TRANSLATION_PROVIDER=auto
DEEPL_API_KEY=tu_clave
OPENAI_API_KEY=sk-proj-xxxx
# Usa DeepL, fallback OpenAI si falla
```

---

## Calidad de Traducción

### Características Preservadas

**DeepL y OpenAI conservan**:
- ✅ Tags HTML (`<p>`, `<strong>`, `<a>`, etc.)
- ✅ Atributos HTML (`class`, `id`, `href`)
- ✅ Saltos de línea (`\n`)
- ✅ Formato básico
- ✅ Números y URLs

**No se preserva** (ambos proveedores):
- ❌ Shortcodes WordPress (`[gallery]`, etc.)
- ❌ Bloques Gutenberg complejos
- ❌ CSS inline complejo
- ❌ JavaScript inline

### Calidad por Tipo de Contenido

| Tipo de Contenido | DeepL | OpenAI | Recomendación |
|-------------------|-------|--------|---------------|
| Técnico/Legal | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | DeepL |
| Marketing/Creativo | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | OpenAI |
| Blog/Noticias | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | DeepL |
| Páginas corporativas | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | DeepL |
| Redes sociales | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | OpenAI |
| E-commerce | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | DeepL |

---

## Troubleshooting

### Problema: "No API keys available"

**Síntoma**:
```json
{
  "errors": ["No API keys found for DeepL or OpenAI"],
  "provider_selected": null
}
```

**Solución**:
1. Verificar que al menos una API key esté configurada en Secrets
2. Comprobar nombres exactos: `DEEPL_API_KEY` o `OPENAI_API_KEY`
3. Regenerar key si está expirada

---

### Problema: DeepL "403 Forbidden"

**Síntoma**:
```
DeepL error 403: Authorization failed
```

**Causas**:
- API key incorrecta o expirada
- Plan Free agotado (500K chars/mes)
- IP bloqueada

**Solución**:
```bash
# 1. Verificar key en DeepL console
# 2. Verificar uso mensual (Free tiene límite)
# 3. Si modo auto, fallback automático a OpenAI
# 4. Regenerar key si necesario
```

---

### Problema: OpenAI "429 Rate Limit"

**Síntoma**:
```
OpenAI rate limit (429); waiting 2s
```

**Causas**:
- RPM (requests per minute) excedido
- Tier bajo (Tier 1: 3,500 RPM)
- Múltiples workflows concurrentes

**Solución**:
```bash
# 1. Reducir TRANSLATION_BATCH_SIZE (de 5 a 3)
# 2. Esperar retry automático (2^n segundos)
# 3. Upgrade a Tier 2 en OpenAI (10,000 RPM)
# 4. Espaciar ejecuciones de workflows
```

---

### Problema: Traducción incompleta

**Síntoma**:
```
created: 2 de 5 páginas candidatas
```

**Causas**:
- Timeout de API (30s DeepL, 60s OpenAI)
- Contenido muy largo (>5000 chars)
- Rate limit alcanzado

**Solución**:
```bash
# 1. Reducir batch_size
# 2. Script ya limita a 5000 chars por página
# 3. Reejecutar workflow para páginas restantes
# 4. Revisar logs JSON para identificar páginas fallidas
```

---

### Problema: Fallback no funciona en modo auto

**Síntoma**:
```json
{
  "provider": "auto",
  "provider_selected": "deepl",
  "errors": ["Translation failed for page 123"]
}
```

**Causa**:
- Fallback solo se activa si primera traducción falla completamente
- Si DeepL devuelve texto vacío, no se considera fallo

**Solución**:
```bash
# 1. Verificar ambas keys están configuradas
# 2. Ejecutar test manual con cada proveedor
# 3. Revisar logs TXT para detalles de error
```

---

## Logs JSON por Proveedor

El sistema genera logs estructurados con información del proveedor usado:

```json
{
  "timestamp": "20251023T180000Z",
  "environment": "staging",
  "provider": "auto",
  "provider_selected": "deepl",
  "model": null,
  "enabled": true,
  "dry_run": false,
  "created": [
    {
      "source_id": 3521,
      "target_id": 3650,
      "title_en": "Blog",
      "title_es": "Blog",
      "content_length": 2500,
      "provider": "deepl",
      "model": null,
      "status": "created"
    },
    {
      "source_id": 3520,
      "target_id": 3651,
      "title_en": "Contact",
      "title_es": "Contacto",
      "content_length": 1800,
      "provider": "openai",
      "model": "gpt-4o-mini",
      "status": "created"
    }
  ],
  "stats": {
    "candidates_found": 3,
    "created": 2
  }
}
```

**Campos clave**:
- `provider`: Modo configurado (deepl | openai | auto)
- `provider_selected`: Proveedor realmente usado
- `model`: Modelo OpenAI si aplica
- `created[].provider`: Proveedor por cada página traducida
- `created[].status`: Estado de cada traducción

---

## Mejores Prácticas

### 1. Testing

```bash
# Siempre comenzar con dry-run
DRY_RUN=true
AUTO_TRANSLATE_ENABLED=false

# Test incremental
batch_size: 1  # Primera ejecución
batch_size: 3  # Si funciona
batch_size: 5  # Producción
```

### 2. Monitoreo

```bash
# Revisar logs después de cada ejecución
# Verificar:
# - provider_selected (qué proveedor se usó)
# - created.length (cuántas páginas traducidas)
# - errors.length (cuántos errores)

# Configurar alertas si errors.length > 0
```

### 3. Costos

```bash
# DeepL Free: ~166 páginas/mes gratis
# OpenAI gpt-4o-mini: ~$1 por 1,000 páginas
# Modo auto: Usa DeepL hasta agotar, luego OpenAI (fallback)

# Recomendación: DeepL Free + OpenAI backup
# Costo mensual estimado: $0-2 para sitio mediano
```

### 4. Seguridad

```bash
# ✅ Keys en GitHub Secrets (nunca en código)
# ✅ Rotar WP_APP_PASSWORD cada 90 días
# ✅ Revisar uso de API keys mensualmente
# ✅ Logs JSON no incluyen textos completos (solo longitud)
# ❌ No exponer artifacts públicamente
```

---

## Referencias Externas

- **DeepL API**: https://www.deepl.com/docs-api
- **OpenAI API**: https://platform.openai.com/docs/api-reference
- **Pricing DeepL**: https://www.deepl.com/pro-api
- **Pricing OpenAI**: https://openai.com/pricing
- **Rate Limits OpenAI**: https://platform.openai.com/docs/guides/rate-limits

---

**Actualizado**: 2025-10-23  
**Versión**: 2.0 (Multi-Provider)  
**Autor**: Orquestación Copaylo - Fase F2
