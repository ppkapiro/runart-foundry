# Internacionalización (i18n) - Guía de Activación

## Estado Actual ✅
El sistema de auto-traducción está **preparado y operativo a nivel de código**, pero deshabilitado por defecto (dry-run) hasta que configures las API keys y flags.

---

## Arquitectura

### Componentes
1. **Script de traducción**: `tools/auto_translate_content.py`
   - Soporta DeepL y OpenAI
   - Dry-run por defecto (no crea contenido sin keys)
   - Retries exponenciales y rate-limiting
   - Logs estructurados (JSON)

2. **Workflow**: `.github/workflows/auto_translate_content.yml`
   - Trigger manual y cron (nightly)
   - Parametrizado por entorno (staging/prod)
   - Artifacts: logs JSON y TXT

3. **MU-Plugins**:
   - `runart-i18n-bootstrap.php`: Crea páginas EN/ES, vincula traducciones, menús
   - `runart-briefing-status.php`: Endpoint `/wp-json/briefing/v1/status`
   - `runart-translation-link.php`: Endpoint REST tokenizado para vincular traducciones (desactivado por defecto)

4. **Tema**: `runart-base`
   - Hreflang EN/ES + x-default
   - OG locale tags
   - Language switcher integrado
   - 100% parametrizado (sin hardcodes de dominio)

---

## Activar Auto-Traducción en Staging

### Paso 1: Configurar Secrets en GitHub

Ve a tu repositorio → **Settings** → **Secrets and variables** → **Actions**

#### Variables (públicas, leen el código)
```bash
# Clic en "Variables" tab
WP_BASE_URL = https://staging.runartfoundry.com
AUTO_TRANSLATE_ENABLED = false  # Cambiar a "true" cuando esté listo
TRANSLATION_PROVIDER = deepl    # o "openai"
TRANSLATION_BATCH_SIZE = 3
WP_CLI_AVAILABLE = true         # Para cache purge
APP_ENV = staging
```

#### Secrets (privados, nunca se exponen)
```bash
# Clic en "Secrets" tab → "New repository secret"
WP_USER = github-actions         # Usuario técnico de WordPress
WP_APP_PASSWORD = xxxx xxxx xxxx # App Password generada en wp-admin
DEEPL_API_KEY = tu_clave_deepl   # O OPENAI_API_KEY según proveedor
```

**Nota**: Si usas `TRANSLATION_API_KEY` genérico, el script detecta el proveedor por `TRANSLATION_PROVIDER`.

### Paso 2: Generar App Password en WordPress

1. Accede a: `https://staging.runartfoundry.com/wp-admin/`
2. Ve a: **Users** → **Your Profile**
3. Scroll hasta **Application Passwords**
4. Nombre: `GitHub Actions Auto-Translate`
5. Clic **Add New Application Password**
6. **Copia la password inmediatamente** (solo se muestra una vez)
7. Formato: `xxxx xxxx xxxx xxxx`
8. Pégala en GitHub Secret `WP_APP_PASSWORD` (sin espacios o con espacios, ambos funcionan)

### Paso 3: Obtener API Key del Proveedor

#### Opción A: DeepL (Recomendado para calidad)
1. Crea cuenta en [DeepL API](https://www.deepl.com/pro-api)
2. Plan Free: 500,000 caracteres/mes gratis
3. Copia tu **Authentication Key**
4. Añade como Secret: `DEEPL_API_KEY`
5. Set Variable: `TRANSLATION_PROVIDER = deepl`

#### Opción B: OpenAI (Recomendado para variedad)
1. Crea cuenta en [OpenAI Platform](https://platform.openai.com/)
2. Ve a **API Keys** → **Create new secret key**
3. Copia tu key (empieza con `sk-...`)
4. Añade como Secret: `OPENAI_API_KEY`
5. Set Variables:
   ```bash
   TRANSLATION_PROVIDER = openai
   OPENAI_MODEL = gpt-4o-mini  # Recomendado: económico y eficiente
   OPENAI_TEMPERATURE = 0.3    # 0.0-1.0, menor = más literal
   ```
6. **Importante**: Monitorea costos en OpenAI dashboard (~$0.001/página)

#### Opción C: Multi-Provider Auto (Recomendado para producción)
**Configura ambas APIs para máxima disponibilidad**:
1. Añade ambos Secrets:
   ```bash
   DEEPL_API_KEY = tu_clave_deepl
   OPENAI_API_KEY = sk-proj-xxxx
   ```
2. Set Variables:
   ```bash
   TRANSLATION_PROVIDER = auto  # 🚀 Usa DeepL primero, fallback OpenAI
   OPENAI_MODEL = gpt-4o-mini
   OPENAI_TEMPERATURE = 0.3
   ```
3. **Comportamiento**:
   - ✅ Intenta DeepL primero (mejor calidad técnica)
   - ✅ Si DeepL falla → fallback automático a OpenAI
   - ✅ Logs registran qué proveedor se usó para cada página
   - ✅ Máxima confiabilidad sin intervención manual

**Ver [PROVIDERS_REFERENCE.md](./PROVIDERS_REFERENCE.md) para comparativa completa**

### Paso 4: Test Dry-Run

1. Ve a **Actions** → **Auto Translate Content**
2. Clic **Run workflow**
3. Set:
   - `dry_run`: **true**
   - `batch_size`: **3**
4. Clic **Run workflow**
5. Espera completar (1-2 min)
6. Descarga artifacts:
   - `auto-translate-logs-XXX.zip` (TXT log)
   - `auto-translate-report-XXX.zip` (JSON estructurado)
7. Verifica en JSON:
   ```json
   {
     "dry_run": true,
     "provider": "auto",
     "provider_selected": null,
     "candidates": [...],
     "created": [],
     "stats": {"candidates_found": 5, "created": 0}
   }
   ```
   **Nota**: En dry-run, `provider_selected` será `null` porque no traduce realmente.

### Paso 5: Activar Traducción Real

1. En GitHub Variables, cambia:
   ```bash
   AUTO_TRANSLATE_ENABLED = true
   ```
2. Ve a **Actions** → **Auto Translate Content**
3. Clic **Run workflow**
4. Set:
   - `dry_run`: **false**
   - `batch_size`: **1** (primera vez, para validar)
5. Clic **Run workflow**
6. Espera completar
7. Descarga artifact JSON y verifica:
   ```json
   {
     "provider_selected": "deepl",  # O "openai" si falló DeepL
     "created": [
       {
         "source_id": 3521,
         "target_id": 3650,
         "title_es": "Blog",
         "provider": "deepl",
         "model": null,
         "status": "created"
       }
     ],
     "stats": {"created": 1}
   }
   ```
8. Verifica en wp-admin:
   - **Pages** → filtro "Draft" → buscar página ES recién creada
   - Revisa título y contenido traducidos
   - **Importante**: Verifica qué proveedor se usó (`provider` en log)
   - Publica manualmente después de revisar

### Paso 6: Validar Vinculación EN↔ES

```bash
# Desde terminal
curl "https://staging.runartfoundry.com/wp-json/wp/v2/pages/3512" | jq '.translations'
# Esperado: {"es": 3600}  (o tu ID real)
```

Si `translations` es `null`, necesitas activar el endpoint tokenizado (ver sección "Endpoint Avanzado").

---

## Activar en Producción

### Pre-requisitos
- ✅ Staging tested y funcionando
- ✅ Dominio `runartfoundry.com` apuntando al servidor prod
- ✅ WordPress instalado en prod (no copia de staging)
- ✅ Polylang instalado y configurado EN/ES

### Diferencias con Staging

#### Variables (cambiar en prod)
```bash
WP_BASE_URL = https://runartfoundry.com  # Sin staging
APP_ENV = production
```

#### Secrets (regenerar en prod)
```bash
WP_USER = <prod_wp_user>
WP_APP_PASSWORD = <prod_app_password>  # Nuevo, generado en prod wp-admin
DEEPL_API_KEY = <misma_key>            # Reutilizar si tienes plan Pro
```

#### Deploy a Prod
```bash
# Clonar variables de entorno para prod
export STAGING_SSH_USER="<prod_ssh_user>"
export STAGING_SSH_HOST="<prod_ssh_host>"
export STAGING_WP_PATH="<prod_wp_path>"
export WP_CLI_AVAILABLE="true"

# Ajustar .env (NO commitear)
# Ejecutar deploy
bash tools/deploy_to_staging.sh  # Renombrar script o ajustar vars
```

#### Post-Deploy Prod
1. Ejecutar `wp cache flush` en prod
2. Validar hreflang en prod: `curl https://runartfoundry.com/ | grep hreflang`
3. Registrar en Google Search Console (ver `docs/seo/SEARCH_CONSOLE_README.md`)
4. Enviar sitemap: `https://runartfoundry.com/sitemap_index.xml`

---

## Endpoint Avanzado: Vinculación Manual (Opcional)

Si REST no vincula traducciones automáticamente, usa el endpoint tokenizado.

### Activación (una vez en wp-admin)
```bash
# Via WP-CLI SSH en staging
ssh <user>@<host>
cd /path/to/htdocs/staging
wp option update runart_translation_link_enabled 1
wp option update runart_translation_link_token "$(openssl rand -hex 32)"

# Guardar token en GitHub Secret
wp option get runart_translation_link_token
```

### Uso en Workflows
Añade a `.github/workflows/auto_translate_content.yml`:
```yaml
env:
  API_GATEWAY_TOKEN: ${{ secrets.API_GATEWAY_TOKEN }}
```

Y en `tools/auto_translate_content.py` tras crear página ES:
```python
# Vincular via endpoint tokenizado
link_url = f"{WP_BASE_URL}/wp-json/runart/v1/link-translation"
headers = {"X-Api-Token": os.getenv('API_GATEWAY_TOKEN', '')}
link_data = {
    "source_id": source_id,
    "target_id": new_id,
    "lang_source": "en",
    "lang_target": "es"
}
resp = requests.post(link_url, json=link_data, headers=headers, timeout=30)
```

---

## Monitoreo y Mantenimiento

### Cron Automático
- Workflow ejecuta nightly (3 AM UTC)
- Solo traduce si `AUTO_TRANSLATE_ENABLED=true`
- Respeta `TRANSLATION_BATCH_SIZE` para no saturar API

### Logs y Artifacts
- **JSON**: `docs/ops/logs/auto_translate_YYYYMMDDTHHMMSSZ.json`
- **TXT**: `docs/ops/logs/auto_translate_YYYYMMDDTHHMMSSZ.log`
- Artifacts en GitHub Actions: retención 90 días

### Alertas
- Si workflow falla → email de GitHub Actions
- Revisar artifacts para diagnosticar

### Costos

#### DeepL
- **Free**: 500K caracteres/mes → ~150 páginas de 3000 chars (GRATIS)
- **Pro**: $5.49/mes (100K base) + $24.99/millón adicional
- **Recomendación**: DeepL Free suficiente para sitio mediano

#### OpenAI
- **gpt-4o-mini**: ~$0.001/página (modelo recomendado)
- **gpt-3.5-turbo**: ~$0.002/página
- **gpt-4o**: ~$0.030/página
- **Cálculo**: 500 páginas con gpt-4o-mini ≈ $0.50

#### Modo Auto (Recomendado)
- **Configuración**: DeepL Free + OpenAI backup
- **Costo mensual típico**: $0-2 (usa DeepL gratis hasta agotar, luego OpenAI solo si falla)
- **Páginas/mes**: ~150-200 (mayoría gratis con DeepL)

**Ver detalles en [PROVIDERS_REFERENCE.md](./PROVIDERS_REFERENCE.md)**

---

## Troubleshooting

### "Missing WP credentials"
- Verifica Secrets `WP_USER` y `WP_APP_PASSWORD` en GitHub
- Regenera App Password en wp-admin si cambió

### "Rate limit (429)"
- Script reintenta automáticamente 3 veces con backoff exponencial
- Si persiste:
  - **DeepL**: Reduce `TRANSLATION_BATCH_SIZE` a 1-2
  - **OpenAI**: Verifica tier en platform.openai.com (Tier 1: 3,500 RPM, Tier 2: 10,000 RPM)
  - **Modo Auto**: Fallback automático al otro proveedor
- Espacia ejecuciones: no ejecutar múltiples workflows concurrentes

### "Translation failed for page XXX"
- Revisa artifact JSON → campo `errors` y `provider_selected`
- **DeepL**: 
  - Verifica plan (Free vs Pro) y límite mensual en DeepL console
  - Error 403: API key incorrecta o plan agotado
- **OpenAI**: 
  - Confirma crédito disponible en platform.openai.com/account
  - Error 429: rate limit (ver arriba)
- **Modo Auto**: Verifica en logs si intentó fallback y resultado

### "Translations: null"
- REST no soporta vinculación directa → activa endpoint tokenizado
- O vincula manualmente en wp-admin: Edit Page → Polylang metabox

### Páginas no aparecen en front
- Cache: purga con `wp cache flush` y plugin de cache
- Permalinks: `wp rewrite flush`
- Verifica que página ES esté publicada (no draft)

---

## Checklist de Activación ✅

### Staging
- [ ] Secrets configurados (WP_USER, WP_APP_PASSWORD)
- [ ] API Keys configuradas (DEEPL_API_KEY y/o OPENAI_API_KEY)
- [ ] Variables configuradas (WP_BASE_URL, TRANSLATION_PROVIDER=auto, OPENAI_MODEL, etc.)
- [ ] Test dry-run exitoso (artifacts descargados y revisados)
- [ ] Verificar `provider_selected` en log JSON
- [ ] Test traducción real exitoso (1 página ES creada como draft)
- [ ] Traducción vinculada EN↔ES (verificado en REST)
- [ ] Cache purgado post-deploy

### Producción
- [ ] Staging completamente validado
- [ ] Variables prod configuradas (WP_BASE_URL sin staging, APP_ENV=production)
- [ ] Secrets prod regenerados (nuevo WP_APP_PASSWORD de prod)
- [ ] TRANSLATION_PROVIDER=auto configurado (máxima confiabilidad)
- [ ] Test dry-run en prod
- [ ] Test traducción real en prod (1 página)
- [ ] Search Console configurado (ver [SEARCH_CONSOLE_README.md](../seo/SEARCH_CONSOLE_README.md))
- [ ] Sitemap bilingüe enviado
- [ ] Hreflang validado en prod
- [ ] Monitoreo de costos API configurado (DeepL console + OpenAI dashboard)

---

## Referencias

- **[PROVIDERS_REFERENCE.md](./PROVIDERS_REFERENCE.md)**: Comparativa completa DeepL vs OpenAI, límites, precios
- **[TESTS_AUTOMATION_STAGING.md](./TESTS_AUTOMATION_STAGING.md)**: Plan de pruebas con 10 escenarios
- **[SEARCH_CONSOLE_README.md](../seo/SEARCH_CONSOLE_README.md)**: Configuración Search Console y sitemaps
- **[ORQUESTADOR_DE_INTEGRACION.md](../integration_wp_staging_lite/ORQUESTADOR_DE_INTEGRACION.md)**: Fase F2 - Multi-Provider

---

**Actualizado**: 2025-10-23  
**Versión**: 2.0 (Multi-Provider con auto-fallback)  
**Autor**: Orquestación Copaylo - Fase F2
- [ ] Deploy a prod ejecutado sin errores
- [ ] Hreflang validado en prod HTML
- [ ] Sitemap enviado a Search Console
- [ ] Propiedad verificada en Search Console
- [ ] Monitoreo de costos API configurado

---

## Recursos

- **DeepL API Docs**: https://www.deepl.com/docs-api
- **OpenAI API Docs**: https://platform.openai.com/docs/api-reference
- **Polylang Docs**: https://polylang.pro/doc/
- **Search Console**: `docs/seo/SEARCH_CONSOLE_README.md`
- **Tests**: `docs/i18n/TESTS_AUTOMATION_STAGING.md`

---

**Estado**: Sistema preparado, dry-run por defecto.  
**Próximo paso**: Ejecutar Paso 1-4 para activar traducción en staging.  
**Última actualización**: 2025-10-23
