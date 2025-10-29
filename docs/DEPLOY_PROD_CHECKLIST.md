# Checklist de Deploy a Producción - RunArt Foundry

**Versión**: 1.1  
**Fecha preparación**: 2025-10-23  
**Estado**: 🟡 **PREPARADO - PENDIENTE ACTIVACIÓN**

---

## 📋 Resumen Ejecutivo

Este documento contiene todos los pasos, variables y secrets necesarios para activar RunArt Foundry en producción. **No requiere cambios de código**, solo actualización de configuración.

---

## ⚠️ Pre-requisitos Críticos

Antes de comenzar el deploy, confirmar:

- [ ] **Staging completamente validado**
  - Auto-traducción tested (Test 1-4)
  - SEO bilingüe verificado
  - Endpoints operativos
  - Cache funcional
  
- [ ] **Dominio producción configurado**
  - DNS apunta a servidor prod
  - HTTPS/SSL activo y válido
  - WordPress instalado en prod (NO copia de staging)
  
- [ ] **Accesos disponibles**
  - SSH a servidor producción
  - wp-admin producción (usuario administrador)
  - GitHub repo con permisos Secrets/Variables
  
- [ ] **Plugins instalados en prod**
  - Polylang 3.7.3+
  - Plugin SEO (Yoast/RankMath)
  - LiteSpeed Cache (opcional, si servidor soporta)

---

## 🔐 FASE 1: Configurar GitHub Secrets (Producción)

Ve a: **Repo → Settings → Secrets and variables → Actions → Secrets**

### Secrets Requeridos

```bash
# WordPress Credentials
PROD_WP_USER = github-actions
PROD_WP_APP_PASSWORD = [generar en wp-admin prod]

# Translation APIs (al menos una requerida)
PROD_DEEPL_API_KEY = [tu_clave_deepl_prod]
PROD_OPENAI_API_KEY = [tu_clave_openai_prod]

# SSH Deploy (si aplica)
PROD_SSH_PASSWORD = [password SSH servidor prod]

# Endpoint Tokenizado (opcional)
PROD_API_GATEWAY_TOKEN = [generar token seguro]

# Cache Purge (opcional)
PROD_CACHE_PURGE_URL = https://runartfoundry.com/wp-json/wp/v2/cache/purge
```

### Cómo Generar App Password en Producción

1. Accede a: `https://runartfoundry.com/wp-admin/`
2. **Users** → **Your Profile**
3. Scroll hasta **Application Passwords**
4. Nombre: `GitHub Actions Production`
5. Clic **Add New Application Password**
6. **Copia inmediatamente** (se muestra una sola vez)
7. Formato: `xxxx xxxx xxxx xxxx`
8. Pégala en GitHub Secret `PROD_WP_APP_PASSWORD`

---

## 🔧 FASE 2: Configurar GitHub Variables (Producción)

Ve a: **Repo → Settings → Secrets and variables → Actions → Variables**

### Variables Requeridas

```bash
# Environment
APP_ENV = production  # IMPORTANTE: cambiar de staging

# WordPress
WP_BASE_URL = https://runartfoundry.com  # SIN www, SIN trailing slash
PROD_WP_BASE_URL = https://runartfoundry.com  # Alias explícito

# Translation
TRANSLATION_PROVIDER = auto  # Recomendado: deepl|openai|auto
AUTO_TRANSLATE_ENABLED = false  # Cambiar a true cuando esté listo
DRY_RUN = true  # Cambiar a false para traducción real
TRANSLATION_BATCH_SIZE = 5  # 3-5 recomendado

# OpenAI (si provider=openai o auto)
OPENAI_MODEL = gpt-4o-mini  # Modelo recomendado
OPENAI_TEMPERATURE = 0.3  # 0.0-1.0

# Deploy
WP_CLI_AVAILABLE = true  # Para cache purge
```

---

## 📦 FASE 3: Deploy de Archivos a Producción

### Opción A: Deploy Manual (Recomendado Primera Vez)

```bash
# 1. Clonar repo en local
cd /ruta/temporal
git clone https://github.com/[owner]/runartfoundry.git
cd runartfoundry

# 2. Rsync a producción (ajustar rutas)
rsync -avz --delete \
  --exclude='.git' \
  --exclude='node_modules' \
  --exclude='_tmp' \
  --exclude='logs' \
  wp-content/themes/runart-base/ \
  user@servidor:/path/to/wp-content/themes/runart-base/

rsync -avz \
  wp-content/mu-plugins/ \
  user@servidor:/path/to/wp-content/mu-plugins/

# 3. Verificar permisos
ssh user@servidor "chown -R www-data:www-data /path/to/wp-content"
```

### Opción B: Deploy Automatizado (Después de validar)

**Crear workflow**: `.github/workflows/deploy_to_production.yml`

```yaml
name: Deploy to Production

on:
  workflow_dispatch:
    inputs:
      confirm:
        description: 'Type "DEPLOY PROD" to confirm'
        required: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    if: github.event.inputs.confirm == 'DEPLOY PROD'
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to Production
        env:
          SSH_HOST: ${{ secrets.PROD_SSH_HOST }}
          SSH_USER: ${{ secrets.PROD_SSH_USER }}
          SSH_PASS: ${{ secrets.PROD_SSH_PASSWORD }}
          WP_PATH: ${{ secrets.PROD_WP_PATH }}
        run: |
          # Instalar sshpass
          sudo apt-get install -y sshpass
          
          # Rsync theme
          sshpass -p "$SSH_PASS" rsync -avz --delete \
            -e "ssh -o StrictHostKeyChecking=no" \
            wp-content/themes/runart-base/ \
            $SSH_USER@$SSH_HOST:$WP_PATH/wp-content/themes/runart-base/
          
          # Rsync MU-plugins
          sshpass -p "$SSH_PASS" rsync -avz \
            -e "ssh -o StrictHostKeyChecking=no" \
            wp-content/mu-plugins/ \
            $SSH_USER@$SSH_HOST:$WP_PATH/wp-content/mu-plugins/
          
          # Cache purge
          sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no \
            $SSH_USER@$SSH_HOST \
            "cd $WP_PATH && wp cache flush"
```

---

## 🔍 FASE 4: Validación Post-Deploy

### Test 1: Endpoint Briefing Status

```bash
curl https://runartfoundry.com/wp-json/briefing/v1/status | jq .
```

**Esperado**:
```json
{
  "site": {
    "name": "R.U.N. Art Foundry",
    "url": "https://runartfoundry.com/",
    "theme": "RunArt Base"
  },
  "i18n": {
    "active": true,
    "languages": [
      {"slug": "en", "home": "https://runartfoundry.com/"},
      {"slug": "es", "home": "https://runartfoundry.com/es/"}
    ]
  }
}
```

### Test 2: Hreflang Tags

```bash
curl -s https://runartfoundry.com/ | grep hreflang
```

**Esperado**:
```html
<link rel="alternate" href="https://runartfoundry.com/" hreflang="en" />
<link rel="alternate" href="https://runartfoundry.com/es/" hreflang="es" />
<link rel="alternate" hreflang="x-default" href="https://runartfoundry.com/" />
```

⚠️ **CRÍTICO**: URLs deben apuntar a `runartfoundry.com` (NO `staging.runartfoundry.com`)

### Test 3: Language Switcher

1. Visita: `https://runartfoundry.com/`
2. Clic en switcher **Español**
3. Verifica redirección a: `https://runartfoundry.com/es/`
4. Clic en switcher **English**
5. Verifica redirección a: `https://runartfoundry.com/`

### Test 4: Auto-Translate Dry-Run

```bash
# En GitHub Actions
# Actions → Auto Translate Content → Run workflow
# - dry_run: true
# - batch_size: 3

# Descargar artifact JSON y verificar:
# - base_url: "https://runartfoundry.com"
# - provider: "auto"
# - candidates_found: > 0
```

---

## 🌍 FASE 5: Google Search Console

### Registro en Search Console

1. Ve a: https://search.google.com/search-console
2. Clic **Add Property** → `https://runartfoundry.com`
3. **Método de verificación** (elegir uno):
   - **HTML file**: Subir archivo verificación a raíz
   - **DNS record**: Añadir TXT en DNS
   - **HTML tag**: Añadir meta tag en `<head>`
   - **Google Analytics**: Si ya instalado
4. Clic **Verify**

### Envío de Sitemap

1. En Search Console → **Sitemaps** (sidebar)
2. **Add a new sitemap**: `sitemap_index.xml`
3. Clic **Submit**
4. Esperar indexación (24-48 horas)

### Validación Hreflang

1. Search Console → **Settings** → **International Targeting**
2. Verificar que detecta idiomas EN y ES
3. Esperar 7-14 días para ver datos hreflang
4. Revisar errores en **Coverage** report

**Ver guía completa**: `docs/seo/SEARCH_CONSOLE_README.md`

---

## 🚀 FASE 6: Activar Auto-Traducción en Producción

### Solo Después de Validar Tests 1-4

```bash
# GitHub Variables → Edit
AUTO_TRANSLATE_ENABLED = true
DRY_RUN = false
```

### Ejecutar Primera Traducción Real

```bash
# Actions → Auto Translate Content → Run workflow
# - dry_run: false
# - batch_size: 1  # Primera vez con 1 para validar
```

### Verificar Resultado

1. Descargar artifact JSON
2. Verificar:
   ```json
   {
     "provider_selected": "deepl",  # O "openai"
     "created": [{
       "source_id": 123,
       "target_id": 456,
       "title_es": "Título traducido",
       "status": "created"
     }],
     "stats": {"created": 1}
   }
   ```
3. Verificar en wp-admin:
   - **Pages** → Draft → ver página ES creada
   - Revisar calidad de traducción
   - Publicar manualmente si OK

### Ajustar Batch Size

Si primer test OK:
```bash
TRANSLATION_BATCH_SIZE = 5  # Aumentar gradualmente
```

---

## 📊 FASE 7: Monitoreo Post-Deploy

### Dashboards a Configurar

1. **Google Analytics**:
   - Vista por idioma (filtro `/es/`)
   - Conversiones por idioma
   - Bounce rate por idioma

2. **Search Console**:
   - Alertas de errores hreflang
   - Impresiones por país/idioma
   - CTR por idioma

3. **API Providers**:
   - **DeepL Console**: Uso mensual (límite 500K chars Free)
   - **OpenAI Dashboard**: Costos diarios (alertar si >$X)

### Alertas Recomendadas

```yaml
# GitHub Actions
- Workflow auto-translate falla → Email inmediato
- Error rate > 20% → Slack alert
- Dry-run detecta > 50 candidatos → Notificar equipo

# Search Console
- Errores hreflang > 10 → Email semanal
- Páginas no indexadas > 5% → Investigar

# API Providers
- DeepL Free > 80% usado → Considerar upgrade
- OpenAI costo > $10/mes → Revisar batch_size
```

---

## 🔄 FASE 8: Rollback Plan (Por si acaso)

### Si Algo Falla en Producción

#### Opción A: Revertir Deploy

```bash
# Restaurar backup anterior
ssh user@servidor
cd /path/to/wp-content/themes
cp -r runart-base-backup-YYYYMMDD runart-base

# Purgar cache
wp cache flush

# Verificar
curl https://runartfoundry.com/wp-json/briefing/v1/status
```

#### Opción B: Deshabilitar Auto-Traducción

```bash
# GitHub Variables
AUTO_TRANSLATE_ENABLED = false
DRY_RUN = true

# Esto no afecta sitio ya desplegado, solo futuros workflows
```

#### Opción C: Revertir Theme

```bash
# Activar tema anterior en wp-admin
# Dashboard → Appearance → Themes → Activate [Previous Theme]
```

---

## 📋 Checklist Global de Deploy

### Pre-Deploy
- [ ] Staging validado completamente (Fases 1-6)
- [ ] Backup completo de producción creado
- [ ] Dominio prod apunta a servidor correcto
- [ ] WordPress instalado y Polylang activo
- [ ] Secrets prod configurados en GitHub
- [ ] Variables prod configuradas en GitHub

### Deploy
- [ ] Archivos subidos a prod (theme + MU-plugins)
- [ ] Permisos correctos (`www-data:www-data`)
- [ ] Cache purgado

### Validación
- [ ] Test 1: Endpoint briefing (200 OK)
- [ ] Test 2: Hreflang apunta a prod (NO staging)
- [ ] Test 3: Language switcher funciona
- [ ] Test 4: Auto-translate dry-run exitoso

### SEO
- [ ] Search Console registrado
- [ ] Sitemap enviado
- [ ] Hreflang validación iniciada (esperar 7-14 días)
- [ ] Analytics configurado con vistas por idioma

### Auto-Traducción
- [ ] Test dry-run OK con proveedor selected
- [ ] `AUTO_TRANSLATE_ENABLED=true` activado
- [ ] Primera traducción real exitosa (1 página)
- [ ] Batch size ajustado según capacidad

### Monitoreo
- [ ] Alertas configuradas (GitHub + Search Console)
- [ ] Dashboards DeepL/OpenAI monitoreados
- [ ] Revisión diaria programada (primeros 7 días)

---

## 📞 Soporte y Contactos

### Documentación de Referencia

- **Este checklist**: `docs/DEPLOY_PROD_CHECKLIST.md`
- **Orquestador**: `docs/integration_wp_staging_lite/ORQUESTADOR_DE_INTEGRACION.md`
- **Guía i18n**: `docs/i18n/I18N_README.md`
- **Proveedores**: `docs/i18n/PROVIDERS_REFERENCE.md`
- **Tests**: `docs/i18n/TESTS_AUTOMATION_STAGING.md`
- **SEO**: `docs/seo/VALIDACION_SEO_FINAL.md`
- **Search Console**: `docs/seo/SEARCH_CONSOLE_README.md`

### APIs Externas

- **DeepL Console**: https://www.deepl.com/pro-api
- **OpenAI Dashboard**: https://platform.openai.com/
- **Google Search Console**: https://search.google.com/search-console

### Troubleshooting Rápido

| Problema | Solución |
|----------|----------|
| Hreflang apunta a staging | Verificar `WP_BASE_URL` en Variables |
| Auto-translate falla | Revisar Secrets (DEEPL/OPENAI keys) |
| Language switcher no funciona | Verificar Polylang activo en prod |
| 404 en `/es/` | Flush permalinks: `wp rewrite flush` |
| Endpoint 404 | Verificar MU-plugins subidos |

---

## 🎯 Criterios de Éxito Final

Deploy a producción considerado exitoso cuando:

- [x] Sitio accesible en `https://runartfoundry.com` (200 OK)
- [x] Versiones EN (`/`) y ES (`/es/`) funcionan
- [x] Hreflang apunta a dominio prod (NO staging)
- [x] Language switcher cambia idiomas correctamente
- [x] Endpoint briefing devuelve datos correctos
- [x] Auto-translate dry-run detecta candidatos
- [x] Search Console registrado y sitemap enviado
- [x] Primera traducción real exitosa
- [x] Monitoreo activo configurado

---

**Preparado por**: Copaylo (Cierre de Integración)  
**Fecha**: 2025-10-23  
**Versión**: 1.1  
**Estado**: 🟡 **LISTO PARA ACTIVACIÓN** (pendiente solo configurar secrets/variables)
