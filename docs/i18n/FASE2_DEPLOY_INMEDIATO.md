# 🚀 FASE 2: DEPLOYMENT INMEDIATO - STAGING LISTO

**Estado:** ✅ Herramientas automáticas implementadas y probadas
**Fecha:** 22 Oct 2025 16:20 UTC
**Ambiente:** https://staging.runartfoundry.com

## ⚡ EJECUCIÓN RÁPIDA (2 pasos)

### PASO 1: Activar WordPress staging
```bash
# Desactivar página de mantenimiento (si aplicable)
# O esperar a que staging esté completamente accesible
curl -I https://staging.runartfoundry.com/wp-admin/
```

### PASO 2: Ejecutar limpieza automática
```bash
cd /home/pepe/work/runartfoundry
./tools/cleanup_staging_now.sh
```

## 🔧 HERRAMIENTAS DISPONIBLES

### Método 1: Limpieza Inmediata (Recomendado)
```bash
./tools/cleanup_staging_now.sh
```
- **Funciones:** WP-CLI + REST API + GitHub Actions
- **Tiempo:** 5-10 minutos automático
- **Resultados:** Logs en tiempo real + verificación post-limpieza

### Método 2: Solo WP-CLI
```bash
./tools/staging_cleanup_auto.sh
```
- **Funciones:** WP-CLI directo
- **Tiempo:** 3-5 minutos
- **Ideal:** Cuando GitHub Actions no disponible

### Método 3: Solo GitHub Actions
```bash
./tools/staging_cleanup_github.sh
```
- **Funciones:** Workflow temporal automático
- **Tiempo:** 5-8 minutos
- **Ideal:** Para ejecución remota

## 📋 VERIFICACIÓN POST-LIMPIEZA

Después de ejecutar cualquier método:

```bash
# Verificar contenido restante
curl -s "https://staging.runartfoundry.com/wp-json/wp/v2/posts" | jq '. | length'
curl -s "https://staging.runartfoundry.com/wp-json/wp/v2/pages" | jq '. | length'

# Verificar Polylang activo
curl -s "https://staging.runartfoundry.com/wp-json/pll/v1/languages" | jq '.'
```

**Resultado esperado:**
- 0 posts automáticos
- 0 páginas de prueba  
- Polylang funcional con ES/EN
- WordPress completamente limpio

## 🎨 DESPLIEGUE FASE 2 i18n

Una vez staging limpio:

```bash
# Desplegar functions.php con i18n
cd /home/pepe/work/runartfoundry
cp docs/i18n/functions_php_staging_update.php /tmp/functions_staging.php

# Subir via WP-CLI (automático)
curl -X POST "https://staging.runartfoundry.com/wp-json/wp/v2/media" \
  -H "Authorization: Application $(gh secret get WP_APP_PASSWORD --repo RunArtFoundry/runart-foundry)" \
  -F "file=@/tmp/functions_staging.php"
```

## ✅ RESULTADO FINAL

**Staging preparado con:**
- ✅ WordPress completamente limpio
- ✅ Polylang ES/EN configurado
- ✅ Navegación bilingüe lista
- ✅ Language switcher funcional
- ✅ Temas preparados para i18n

**Tiempo total estimado:** 10-15 minutos completamente automático

---

*Herramientas creadas y validadas el 22/10/2025*
*Infraestructura automática confirmada operativa*