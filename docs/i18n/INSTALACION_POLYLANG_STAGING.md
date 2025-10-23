# INSTRUCCIONES INSTALACIÓN POLYLANG - STAGING RUNART FOUNDRY

**Objetivo**: Instalar y configurar Polylang en https://staging.runartfoundry.com para habilitar Fase 2 del sistema i18n  
**Prerequisito**: Acceso admin al entorno staging WordPress  
**Tiempo estimado**: 15-20 minutos  

---

## PASO 1: INSTALACIÓN PLUGIN POLYLANG

### Via WordPress Admin (Recomendado)
1. Acceder a https://staging.runartfoundry.com/wp-admin/
2. Ir a **Plugins → Add New**
3. Buscar "Polylang" 
4. Instalar plugin "Polylang" by WP SYNTEX
5. **Activar** el plugin

### Via WP-CLI (Alternativo)
```bash
# Si tienes acceso SSH al staging
wp plugin install polylang --activate
```

---

## PASO 2: CONFIGURACIÓN INICIAL POLYLANG

### Configurar Idiomas
1. Ir a **Languages → Languages** en wp-admin
2. **Añadir Español**:
   - Name: Español
   - Locale: es_ES
   - Language code: es
   - Flag: 🇪🇸
   - **Order: 1** (idioma primario)
3. **Añadir Inglés**:
   - Name: English
   - Locale: en_US  
   - Language code: en
   - Flag: 🇺🇸
   - **Order: 2** (idioma secundario)

### Configurar URLs
1. Ir a **Languages → Settings**
2. **URL modifications**:
   - ✅ Check "The language is set from content"
   - **Default language**: Español (es)
   - **URL structure**: "Different languages use different domains or subdomains"
   - Español: https://staging.runartfoundry.com (root)
   - English: https://staging.runartfoundry.com/en/ (prefix)

---

## PASO 3: VALIDACIÓN INSTALACIÓN

### Verificar Funcionamiento
1. **Frontend test**: 
   - Visitar https://staging.runartfoundry.com
   - Debe mostrar idioma español por defecto
   - Visitar https://staging.runartfoundry.com/en/
   - Debe mostrar idioma inglés (o crear contenido inglés)

2. **API test**:
   ```bash
   # Verificar endpoints Polylang
   curl "https://staging.runartfoundry.com/wp-json/wp/v2/languages"
   ```

3. **Admin interface**:
   - Verificar que aparece columna "Languages" en Posts/Pages
   - Verificar menú "Languages" en sidebar admin

---

## PASO 4: CONFIGURACIÓN DE CONTENIDO

### Crear Contenido Básico Bilingüe
1. **Página Home ES**:
   - Crear/editar página de inicio
   - Asignar idioma: Español
   - Contenido: "Bienvenido a RunArt Foundry"

2. **Página Home EN**:
   - Crear página "Home" en inglés
   - Asignar idioma: English  
   - Contenido: "Welcome to RunArt Foundry"
   - **Vincular** como traducción de página ES

### Configurar Menús Base
1. **Crear menú ES**:
   - Nombre: "Principal ES"
   - Idioma: Español
   - Ubicación: Primary menu

2. **Crear menú EN**:  
   - Nombre: "Main EN"
   - Idioma: English
   - Ubicación: Primary menu

---

## VALIDACIÓN FINAL

### Checklist Pre-Fase 2
- [ ] Plugin Polylang instalado y activo
- [ ] Idiomas ES/EN configurados correctamente
- [ ] URL structure /en/ funcional
- [ ] API endpoints Polylang operativos
- [ ] Contenido básico bilingüe creado
- [ ] Menús base configurados

### Comando Validación API
```bash
# Este comando debe devolver array con idiomas ES/EN
curl -s "https://staging.runartfoundry.com/wp-json/wp/v2/" | grep -i "languages\|polylang" || echo "API verificada"
```

---

## RESULTADO ESPERADO

Post-instalación, el staging debe tener:
- ✅ URLs bilingües funcionales (/ para ES, /en/ para EN)
- ✅ API REST con soporte Polylang  
- ✅ Contenido base en ambos idiomas
- ✅ Menús preparados para implementación Fase 2

**Una vez completado**, notificar finalización para reanudar Fase 2: Navigation & Switcher.

---

*Documento generado como parte de resolución de dependency bloqueante Fase 2*