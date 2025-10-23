# GUÍA DE DEPLOY - FASE 2 i18n RUNART FOUNDRY

## 🎯 OBJETIVO
Implementar menús bilingües y language switcher en staging https://staging.runartfoundry.com usando integración completa con Polylang.

## ✅ PREREQUISITES CONFIRMADOS
- [x] **Polylang instalado**: Plugin operativo con API `/wp-json/pll/v1/languages`
- [x] **Idiomas configurados**: English (default, `/`) + Español (`/es/`)
- [x] **Flags disponibles**: us.png y es.png en directorio Polylang
- [x] **Theme activo**: generatepress_child
- [x] **Fase 1 completa**: Text domain y helper functions implementados

## 📋 PASOS DE DEPLOYMENT

### Paso 1: Backup del functions.php actual
```bash
# Conectar a staging via SSH/FTP y hacer backup
cp /path/to/staging/wp-content/themes/generatepress_child/functions.php \
   /path/to/staging/wp-content/themes/generatepress_child/functions.php.backup.$(date +%Y%m%d_%H%M%S)
```

### Paso 2: Actualizar functions.php en staging
**Archivo a subir**: `docs/i18n/functions_php_staging_update.php`  
**Destino**: `/wp-content/themes/generatepress_child/functions.php`

**Contenido actualizado incluye**:
- ✅ Todas las funciones de Fase 1 (text domain, helpers)
- ✅ Nuevas funciones menús bilingües (`runart_display_bilingual_menu`)
- ✅ Language switcher completo (`runart_language_switcher`)
- ✅ Integración automática en header GeneratePress
- ✅ CSS básico para styling del switcher
- ✅ Shortcode `[runart_language_switcher]`
- ✅ Debug mode para validación (`?runart_debug=1`)

### Paso 3: Configurar menús en WordPress Admin
Acceder a: `https://staging.runartfoundry.com/wp-admin/nav-menus.php`

**Crear menús separados**:
1. **Main Menu (Spanish)** → Asignar a "Main Menu (Spanish)"
2. **Main Menu (English)** → Asignar a "Main Menu (English)"  
3. **Footer Menu (Spanish)** → Asignar a "Footer Menu (Spanish)"
4. **Footer Menu (English)** → Asignar a "Footer Menu (English)"

### Paso 4: Validación inmediata post-deploy

#### 4.1 Verificar carga sin errores PHP
```bash
curl -s "https://staging.runartfoundry.com/" | grep -i "fatal\|error\|warning" || echo "✅ No errors found"
curl -s "https://staging.runartfoundry.com/es/" | grep -i "fatal\|error\|warning" || echo "✅ No errors found"
```

#### 4.2 Verificar language switcher visible
```bash
curl -s "https://staging.runartfoundry.com/" | grep -o "runart-language-switcher" && echo "✅ Language switcher found"
curl -s "https://staging.runartfoundry.com/es/" | grep -o "runart-language-switcher" && echo "✅ Language switcher found"
```

#### 4.3 Verificar flags y enlaces idiomas
```bash
curl -s "https://staging.runartfoundry.com/" | grep -o 'class="runart-lang-link' | wc -l  # Debería mostrar 2
curl -s "https://staging.runartfoundry.com/" | grep -o 'us.png\|es.png' | wc -l  # Debería mostrar 2
```

#### 4.4 Testing debug mode
Acceder a: `https://staging.runartfoundry.com/?runart_debug=1`  
**Verificar output**:
- Current Language: en (en raíz) / es (en /es/)
- Polylang Active: Yes
- Available Languages: English + Español con flags
- Registered Menu Locations: primary-es, primary-en, footer-es, footer-en

## 🧪 TESTING COMPLETO

### Test 1: Navegación coherente entre idiomas
1. **Desde raíz (EN)**: Verificar enlace a `/es/` funciona
2. **Desde /es/**: Verificar enlace a `/` funciona  
3. **Language switcher**: Cambiar idioma mantiene navegación

### Test 2: Menús por idioma
1. **Configurar contenido diferente** en cada menú (ES/EN)
2. **Verificar rendering** correcto según idioma activo
3. **Fallback**: Verificar menú por defecto si no configurado

### Test 3: Styling y responsive
1. **Desktop**: Language switcher integrado en header
2. **Mobile**: Verificar no rompe layout responsive
3. **Flags**: Imágenes cargan correctamente (us.png/es.png)

### Test 4: Validación técnica
1. **HTML válido**: W3C Validator sin errores críticos
2. **Console browser**: Sin errores JavaScript
3. **Performance**: No impacto significativo en carga

## ⚠️ ROLLBACK PLAN
Si hay problemas post-deploy:

```bash
# Restaurar backup inmediatamente
cp /path/to/staging/wp-content/themes/generatepress_child/functions.php.backup.TIMESTAMP \
   /path/to/staging/wp-content/themes/generatepress_child/functions.php
```

## 📊 MÉTRICAS DE ÉXITO
- [ ] ✅ **Carga sin errores PHP** en ambos idiomas
- [ ] ✅ **Language switcher visible** en header  
- [ ] ✅ **Flags renderizadas** correctamente (us.png/es.png)
- [ ] ✅ **URLs bilingües funcionales** (/ ↔ /es/)
- [ ] ✅ **Menús separados operativos** (primary-es/en, footer-es/en)
- [ ] ✅ **Debug mode confirmación** configuración correcta
- [ ] ✅ **No conflictos CSS** con theme GeneratePress
- [ ] ✅ **Responsive compatible** mobile/desktop

---

**READY FOR DEPLOYMENT** 🚀  
**Tiempo estimado**: 30-45 minutos deployment + testing  
**Archivo clave**: `functions_php_staging_update.php` → `functions.php`