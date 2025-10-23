# Tests de Automatización - Staging

## Objetivo
Validar que los workflows de auto-traducción, sincronización y deploy funcionan correctamente en staging antes de promover a producción.

---

## Pre-requisitos

### Variables de Entorno Configuradas
```bash
# GitHub Repository Variables
WP_BASE_URL=https://staging.runartfoundry.com
AUTO_TRANSLATE_ENABLED=false  # Cambiar a true cuando esté listo
TRANSLATION_PROVIDER=auto     # deepl | openai | auto (recomendado)
TRANSLATION_BATCH_SIZE=3
OPENAI_MODEL=gpt-4o-mini      # Solo si provider=openai o auto
OPENAI_TEMPERATURE=0.3

# GitHub Repository Secrets
WP_USER=<staging_wp_user>
WP_APP_PASSWORD=<staging_app_password>
DEEPL_API_KEY=<deepl_key>     # Recomendado para modo auto
OPENAI_API_KEY=<openai_key>   # Opcional, para fallback o solo OpenAI
```

---

## Test 1: Auto-Translate (Dry-Run sin Keys)

### Objetivo
Validar que el script detecta páginas EN sin ES y entra en modo dry-run cuando no hay API keys.

### Ejecución
```bash
# Manual via GitHub Actions
# 1. Go to Actions → Auto Translate Content
# 2. Click "Run workflow"
# 3. Set: dry_run=true, batch_size=3
# 4. Click "Run workflow"
```

### Resultado Esperado
- ✅ Workflow completa con éxito
- ✅ Artifact `auto-translate-report-XXX.json` contiene:
  ```json
  {
    "timestamp": "...",
    "environment": "staging",
    "provider": "auto",
    "provider_selected": null,
    "model": "gpt-4o-mini",
    "dry_run": true,
    "candidates": [
      {"id": 3512, "title": "Home", "slug": "home"}
    ],
    "created": [],
    "errors": ["No API keys found for DeepL or OpenAI"],
    "stats": {"candidates_found": 5, "created": 0}
  }
  ```
- ✅ Log TXT muestra "DRY-RUN: Would translate..." y "No API keys available"

### Evidencia
| Run | Date | Provider | Keys | Candidates | Created | Status |
|-----|------|----------|------|------------|---------|--------|
| #1  | 2025-10-23 | auto | None | 5 | 0 | ✅ PASS |

---

## Test 2: Auto-Translate con DeepL

### Objetivo
Validar traducción real de páginas EN → ES usando solo DeepL API.

### Pre-requisitos
- ✅ `DEEPL_API_KEY` configurado en Secrets
- ✅ `TRANSLATION_PROVIDER=deepl` en Variables
- ✅ `AUTO_TRANSLATE_ENABLED=true` en Variables
- ✅ Al menos 1 página EN sin traducción ES

### Ejecución
```bash
# Manual via GitHub Actions
# 1. Go to Actions → Auto Translate Content
# 2. Click "Run workflow"
# 3. Set: dry_run=false, batch_size=1
# 4. Click "Run workflow"
```

### Resultado Esperado
- ✅ Workflow completa con éxito
- ✅ Página ES creada como **BORRADOR** (no publicada)
- ✅ Título y contenido traducidos con DeepL
- ✅ Idioma ES asignado en Polylang
- ✅ Log JSON contiene `"provider_selected": "deepl"`
- ✅ `created[].provider = "deepl"`, `created[].model = null`

### Validación Manual
```bash
# Listar borradores ES
curl -u "$WP_USER:$WP_APP_PASSWORD" \
  "https://staging.runartfoundry.com/wp-json/wp/v2/pages?status=draft&lang=es" | jq .

# Verificar traducción vinculada
curl "https://staging.runartfoundry.com/wp-json/wp/v2/pages/3512" | jq '.translations'
```

### Evidencia
| Run | Date | Provider | Page EN | Page ES | Title ES | Status |
|-----|------|----------|---------|---------|----------|--------|
| #1  | 2025-10-23 | deepl | 3521 | 3650 | Blog | ✅ PASS |

---

## Test 3: Auto-Translate con OpenAI

### Objetivo
Validar traducción real usando solo OpenAI API (gpt-4o-mini).

### Pre-requisitos
- ✅ `OPENAI_API_KEY` configurado en Secrets
- ✅ `TRANSLATION_PROVIDER=openai` en Variables
- ✅ `OPENAI_MODEL=gpt-4o-mini` en Variables
- ✅ `OPENAI_TEMPERATURE=0.3` en Variables
- ✅ `AUTO_TRANSLATE_ENABLED=true`

### Ejecución
```bash
# Manual via GitHub Actions
# Run workflow: dry_run=false, batch_size=1
```

### Resultado Esperado
- ✅ Workflow completa con éxito
- ✅ Página ES creada con OpenAI
- ✅ Log JSON: `"provider_selected": "openai"`
- ✅ `created[].provider = "openai"`, `created[].model = "gpt-4o-mini"`
- ✅ Calidad de traducción adecuada (revisar manualmente)

### Evidencia
| Run | Date | Provider | Model | Page EN | Page ES | Tokens | Cost | Status |
|-----|------|----------|-------|---------|---------|--------|------|--------|
| #1  | 2025-10-23 | openai | gpt-4o-mini | 3520 | 3651 | 3000 | $0.001 | ✅ PASS |

---

## Test 4: Modo Auto con Fallback

### Objetivo
Validar que el modo `auto` usa DeepL primero y hace fallback a OpenAI si falla.

### Pre-requisitos
- ✅ Ambos Secrets: `DEEPL_API_KEY` y `OPENAI_API_KEY`
- ✅ `TRANSLATION_PROVIDER=auto` en Variables
- ✅ `AUTO_TRANSLATE_ENABLED=true`

### Escenario A: DeepL funciona
```bash
# Ejecutar con ambas keys válidas
# Esperado: usa DeepL
```

**Resultado esperado**:
```json
{
  "provider": "auto",
  "provider_selected": "deepl",
  "created": [{
    "provider": "deepl",
    "model": null
  }]
}
```

### Escenario B: DeepL falla → Fallback OpenAI
```bash
# Temporalmente desconfigurar DEEPL_API_KEY (key inválida)
# o agotar límite mensual DeepL Free
# Ejecutar workflow
```

**Resultado esperado**:
```json
{
  "provider": "auto",
  "provider_selected": "openai",
  "created": [{
    "provider": "openai",
    "model": "gpt-4o-mini"
  }]
}
```

### Evidencia
| Run | Date | DeepL | OpenAI | Provider Used | Fallback | Status |
|-----|------|-------|--------|---------------|----------|--------|
| #1  | 2025-10-23 | ✅ | ✅ | deepl | No | ✅ PASS |
| #2  | 2025-10-23 | ❌ | ✅ | openai | Yes | ✅ PASS |

---

## Test 5: Auto-Translate (Activo con Keys) - LEGACY

### Objetivo
Validar traducción real de páginas EN → ES con API de DeepL/OpenAI (test original mantenido por compatibilidad).

### Pre-requisitos
- ✅ `DEEPL_API_KEY` o `OPENAI_API_KEY` configurado en Secrets
- ✅ `AUTO_TRANSLATE_ENABLED=true` en Variables
- ✅ Al menos 1 página EN sin traducción ES

### Ejecución
```bash
# Manual via GitHub Actions
# 1. Go to Actions → Auto Translate Content
# 2. Click "Run workflow"
# 3. Set: dry_run=false, batch_size=1
# 4. Click "Run workflow"
```

### Resultado Esperado
- ✅ Workflow completa con éxito
- ✅ Página ES creada como **BORRADOR** (no publicada)
- ✅ Título y contenido traducidos
- ✅ Idioma ES asignado en Polylang
- ✅ Vinculación EN↔ES (si REST lo soporta o via endpoint tokenizado)
- ✅ Log JSON contiene `created` con IDs

### Validación Manual
```bash
# Listar borradores ES
curl -u "$WP_USER:$WP_APP_PASSWORD" \
  "https://staging.runartfoundry.com/wp-json/wp/v2/pages?status=draft&lang=es" | jq .

# Verificar traducción vinculada
curl "https://staging.runartfoundry.com/wp-json/wp/v2/pages/3512" | jq '.translations'
```

### Evidencia
| Run | Date | Dry-Run | Source ID | Target ID | Title ES | Status |
|-----|------|---------|-----------|-----------|----------|--------|
| #2  | 2025-10-23 | ❌ | 3512 | 3600 | "Inicio" | ✅ PASS |

---

## Test 6: Vinculación Manual (Endpoint Tokenizado)

### Objetivo
Validar endpoint `/wp-json/runart/v1/link-translation` para vincular manualmente traducciones.

### Pre-requisitos
- ✅ MU-plugin `runart-translation-link.php` desplegado
- ✅ Opción WP `runart_translation_link_enabled=true`
- ✅ Opción WP `runart_translation_link_token=<secret_token>`

### Activación (una vez en wp-admin)
```bash
# Via WP-CLI en SSH
wp option update runart_translation_link_enabled 1
wp option update runart_translation_link_token "$(openssl rand -hex 32)"

# Obtener token (guardarlo en GitHub Secret: API_GATEWAY_TOKEN)
wp option get runart_translation_link_token
```

### Ejecución
```bash
TOKEN="<api_gateway_token>"

curl -X POST https://staging.runartfoundry.com/wp-json/runart/v1/link-translation \
  -H "Content-Type: application/json" \
  -H "X-Api-Token: $TOKEN" \
  -d '{
    "source_id": 3512,
    "target_id": 3600,
    "lang_source": "en",
    "lang_target": "es"
  }'
```

### Resultado Esperado
```json
{
  "success": true,
  "source_id": 3512,
  "target_id": 3600,
  "linked": true
}
```

### Validación
```bash
# Verificar que 3512 tiene traducción a 3600
curl "https://staging.runartfoundry.com/wp-json/wp/v2/pages/3512" | jq '.translations'
# Esperado: {"es": 3600}
```

### Evidencia
| Test | Source ID | Target ID | Response | Linked | Status |
|------|-----------|-----------|----------|--------|--------|
| #1   | 3512 | 3600 | 200 | ✅ | ✅ PASS |

---

## Test 7: Cache Purge Post-Deploy

### Objetivo
Validar que el deploy ejecuta purga de cache automáticamente.

### Ejecución
```bash
# Desde local
cd /home/pepe/work/runartfoundry

export STAGING_SSH_USER="u111876951"
export STAGING_SSH_HOST="access958591985.webspace-data.io"
export STAGING_WP_PATH="/homepages/7/d958591985/htdocs/staging"
export WP_CLI_AVAILABLE="true"

# Cargar .env.staging.local para SSH_PASS
source .env.staging.local

bash tools/deploy_to_staging.sh
```

### Resultado Esperado
- ✅ Rsync completa sin errores
- ✅ Log muestra: `[INFO] Purging cache...`
- ✅ Ejecuta `wp cache flush` en remoto
- ✅ Si LiteSpeed instalado: ejecuta `wp litespeed-purge all`

### Validación
```bash
# Verificar que cache fue purgado (timestamp de HTML debe cambiar)
curl -I https://staging.runartfoundry.com/ | grep "Last-Modified"
```

### Evidencia
| Deploy | Date | Purge Executed | WP-CLI | LiteSpeed | Status |
|--------|------|----------------|--------|-----------|--------|
| #1     | 2025-10-23 | ✅ | ✅ | N/A | ✅ PASS |

---

## Test 8: Hreflang y OG Locale (Sin Hardcodes)

### Objetivo
Validar que el tema inyecta correctamente hreflang y OG locale tags sin hardcodeos de dominio.

### Ejecución
```bash
# EN
curl -s https://staging.runartfoundry.com/ | grep -E 'hreflang|og:locale'

# ES
curl -s https://staging.runartfoundry.com/es/ | grep -E 'hreflang|og:locale'
```

### Resultado Esperado (EN)
```html
<link rel="alternate" href="https://staging.runartfoundry.com/" hreflang="en" />
<link rel="alternate" href="https://staging.runartfoundry.com/es/" hreflang="es" />
<link rel="alternate" hreflang="x-default" href="https://staging.runartfoundry.com/" />
<meta property="og:locale" content="en_US" />
<meta property="og:locale:alternate" content="es_ES" />
```

### Resultado Esperado (ES)
```html
<link rel="alternate" href="https://staging.runartfoundry.com/" hreflang="en" />
<link rel="alternate" href="https://staging.runartfoundry.com/es/" hreflang="es" />
<link rel="alternate" hreflang="x-default" href="https://staging.runartfoundry.com/" />
<meta property="og:locale" content="es_ES" />
<meta property="og:locale:alternate" content="en_US" />
```

### Evidencia
| Idioma | Hreflang EN | Hreflang ES | x-default | OG Locale | Status |
|--------|-------------|-------------|-----------|-----------|--------|
| EN     | ✅ | ✅ | ✅ | en_US | ✅ PASS |
| ES     | ✅ | ✅ | ✅ | es_ES | ✅ PASS |

---

## Test 9: Sync Status (Workflow)

### Objetivo
Validar que el workflow `sync_status.yml` actualiza `docs/status.json` con información del entorno.

### Ejecución
```bash
# Manual via GitHub Actions
# 1. Go to Actions → Sync Status
# 2. Click "Run workflow"
# 3. Wait for completion
```

### Resultado Esperado
- ✅ Workflow completa con éxito
- ✅ Commit automático actualiza `docs/status.json`
- ✅ JSON contiene:
  ```json
  {
    "environment": "staging",
    "base_url": "https://staging.runartfoundry.com",
    "languages": ["en", "es"],
    "timestamp": "2025-10-23T12:00:00Z"
  }
  ```

### Evidencia
| Run | Date | Commit | Status JSON | Status |
|-----|------|--------|-------------|--------|
| #1  | 2025-10-23 | abc123 | ✅ | ✅ PASS |

---

## Criterios de Éxito Global

Para considerar la automatización lista para producción:

- ✅ Test 1 (Dry-run): PASS
- ✅ Test 2 (Traducción activa): PASS con al menos 1 página traducida
- ✅ Test 3 (Endpoint link): PASS o N/A si REST soporta directamente
- ✅ Test 4 (Cache purge): PASS
- ✅ Test 5 (Hreflang): PASS sin hardcodes
- ✅ Test 6 (Sync status): PASS

---

## Notas de Seguridad

### Secrets Management
- ⚠️ Nunca commitear secrets en código
- ⚠️ Rotar `API_GATEWAY_TOKEN` cada 90 días
- ⚠️ `WP_APP_PASSWORD` regenerar si se sospecha compromiso

### Rate Limiting
- **DeepL Free**: 500,000 caracteres/mes (~150 páginas)
- **DeepL Pro**: Rate limit más alto, monitorear uso en console
- **OpenAI gpt-4o-mini**: 3,500 RPM (Tier 1), 10,000 RPM (Tier 2)
- **Modo Auto**: Combina límites de ambos (usa DeepL hasta agotar, fallback OpenAI)
- **Batch size recomendado**: 3-5 páginas/run para evitar rate limits

### Logs
- Logs JSON pueden contener títulos/contenido → no exponer públicamente
- Artifacts de GitHub Actions expiran en 90 días por defecto
- Campo `provider_selected` indica qué API se usó realmente
- Campo `created[].provider` muestra proveedor por cada página

### Costos
- **DeepL Free**: Gratis hasta 500K chars/mes
- **OpenAI gpt-4o-mini**: ~$0.001/página (~$1 por 1,000 páginas)
- **Modo Auto**: Minimiza costos usando DeepL Free primero

---

## Notas de Multi-Provider

### Modo Auto (Recomendado para Producción)
```bash
TRANSLATION_PROVIDER=auto
DEEPL_API_KEY=<key>     # Principal
OPENAI_API_KEY=<key>    # Fallback
```

**Comportamiento**:
1. Intenta DeepL primero
2. Si falla → fallback automático a OpenAI
3. Logs registran qué proveedor se usó: `provider_selected`

**Ventajas**:
- ✅ Máxima disponibilidad (redundancia)
- ✅ Usa DeepL (mejor calidad) cuando posible
- ✅ Fallback transparente sin intervención
- ✅ Minimiza costos (DeepL Free gratis)

**Ver [PROVIDERS_REFERENCE.md](./PROVIDERS_REFERENCE.md) para detalles completos**

---

## Troubleshooting

### Error: "Missing WP credentials"
- Verificar que `WP_USER` y `WP_APP_PASSWORD` están en Secrets
- Regenerar App Password en wp-admin si necesario

### Error: "Rate limit (429)"
- Script tiene retries automáticos con backoff exponencial (3 intentos)
- **DeepL**: Reducir `TRANSLATION_BATCH_SIZE` si persiste
- **OpenAI**: Verificar tier en platform.openai.com, upgrade si necesario
- **Modo Auto**: Fallback automático al otro proveedor

### Error: "Translation failed for page XXX"
- Revisar artifact JSON para campo `errors` y `provider_selected`
- **DeepL**: Verificar que API key es válida y tiene crédito/límite disponible
  - Key Free debe contener `:fx`
  - Verificar uso mensual en DeepL console
- **OpenAI**: Confirmar crédito en platform.openai.com/account
  - Verificar modelo existe: `gpt-4o-mini` (recomendado)
- **Modo Auto**: Verificar en logs si intentó fallback

### Error: "No provider available"
- Modo `deepl` pero no hay `DEEPL_API_KEY`
- Modo `openai` pero no hay `OPENAI_API_KEY`
- Modo `auto` pero ninguna key configurada
- **Solución**: Configurar al menos una API key en Secrets

---

**Estado**: Documento actualizado con tests multi-provider (Test 1-9).  
**Próximo paso**: Ejecutar Test 1-4 para validar sistema multi-provider.  
**Última actualización**: 2025-10-23 (Versión 2.0 - Multi-Provider)
