# GUÍA DE LIMPIEZA MANUAL - STAGING RUNART FOUNDRY

## 🎯 OBJETIVO
Eliminar todo el contenido residual del entorno staging manteniendo únicamente la estructura técnica necesaria para la Fase 2 i18n.

## ⚠️ PREREQUISITOS
- Acceso administrativo a https://staging.runartfoundry.com/wp-admin/
- Confirmación previa de que staging está completamente aislado de producción
- Backup de la configuración Polylang antes de proceder

## 📋 PROCESO DE LIMPIEZA PASO A PASO

### PASO 1: Backup Configuración Polylang
```
WP Admin → Idiomas → Configuración
- Exportar configuración actual de idiomas ES/EN
- Anotar estructura de URLs (/ para English, /es/ para Español)
```

### PASO 2: Eliminar Posts/Entradas
**Ubicación**: WP Admin → Entradas → Todas las entradas
**Contenido a eliminar** (10 posts):
```
✅ Beautiful bronze sculpture, Carole Feuerman, Ballerina whith ribbon
✅ Dancer III & IV Bronze Sculptures by Carole Feuerman
✅ Modeling Enlargement Process of The Dancers
✅ Final Patina Touches By Pedro Pablo Oliva
✅ Armando Perez Aleman's bronze sculpture
✅ Mold Destruction
✅ Moments in the making of some of the Dancers
✅ Carlos Artime «Guardian de la Felicidad»
✅ Lawrence Holofcener «Faces of Golf»
✅ Assembling «Contracorriente» by The Merger
```
**Acción**: Seleccionar todos → Mover a papelera → Vaciar papelera

### PASO 3: Eliminar Páginas
**Ubicación**: WP Admin → Páginas → Todas las páginas  
**Contenido a eliminar** (22 páginas):
```
✅ Contact Us, Home, Projects, About, Services, Blog
✅ Wood Crates, Dewax, Ceramic Shell, Engineering
✅ Wax Casting, Resine Casting Services, Marble Sculpture
✅ Silicon & Rubber Molding, Patina (Indoor & Outdoor)
✅ Conservancy Maintenance & Restoration, Sculpture Enlargement
✅ Granite Bases & Mounting, Custom Bronze Fixtures & Accessories
✅ Welding & Polish, Water Jet, Sculpture & Modeling, Oil In Bronze
```
**Acción**: Seleccionar todos → Mover a papelera → Vaciar papelera

### PASO 4: Eliminar Medios/Attachments
**Ubicación**: WP Admin → Medios → Biblioteca
**Contenido detectado**: 10 archivos multimedia
**Acción**: Seleccionar todos los medios → Eliminar permanentemente

### PASO 5: Limpiar Menús
**Ubicación**: WP Admin → Apariencia → Menús
**Menús detectados**: 3 menús existentes
**Acción**: 
- Eliminar todos los menús actuales
- NO crear menús nuevos (se crearán en Fase 2)

### PASO 6: Limpiar Comentarios
**Ubicación**: WP Admin → Comentarios
**Acción**: Eliminar todos los comentarios (si existen)

### PASO 7: Verificar Usuarios  
**Ubicación**: WP Admin → Usuarios
**Estado detectado**: 1 usuario administrador
**Acción**: MANTENER usuario admin - NO eliminar

## ✅ VERIFICACIONES POST-LIMPIEZA

### Verificación 1: Contenido Eliminado
```bash
# Verificar posts = 0
curl -s "https://staging.runartfoundry.com/wp-json/wp/v2/posts" | jq 'length'
# Debe retornar: 0

# Verificar páginas = 0  
curl -s "https://staging.runartfoundry.com/wp-json/wp/v2/pages" | jq 'length'
# Debe retornar: 0

# Verificar medios = 0
curl -s "https://staging.runartfoundry.com/wp-json/wp/v2/media" | jq 'length'  
# Debe retornar: 0
```

### Verificación 2: Polylang Preservado
```bash
# Verificar configuración idiomas intacta
curl -s "https://staging.runartfoundry.com/wp-json/pll/v1/languages"
# Debe retornar: English + Español con URLs correctas
```

### Verificación 3: Sitio Operativo
- **Frontend**: https://staging.runartfoundry.com debe cargar sin errores
- **Admin Panel**: https://staging.runartfoundry.com/wp-admin/ accesible
- **Polylang**: Configuración idiomas visible en admin

## 🔒 PROTECCIÓN POST-LIMPIEZA

### Deshabilitar Sincronización Automática
**Ubicación**: WP Admin → Plugins → WP Staging  
**Acción**: 
- Desactivar cualquier sync automático con producción
- Configurar modo manual únicamente
- Documentar que staging está bajo control manual

### Configurar Mantenimiento
**Medidas**:
- Cambiar contraseña admin si es necesaria
- Confirmar que no hay cron jobs de sincronización  
- Bloquear acceso público si es posible (opcional)

## 📊 CHECKLIST FINAL

- [ ] **Posts eliminados**: 0 entradas restantes
- [ ] **Páginas eliminadas**: 0 páginas restantes  
- [ ] **Medios eliminados**: 0 archivos multimedia
- [ ] **Menús limpiados**: Sin menús activos
- [ ] **Comentarios eliminados**: Sin comentarios
- [ ] **Usuario admin**: PRESERVADO y operativo
- [ ] **Polylang**: Configuración ES/EN intacta
- [ ] **Frontend**: Carga sin errores (sitio vacío)
- [ ] **Backend**: Panel admin accesible
- [ ] **Sincronización**: DESHABILITADA con producción

---

**RESULTADO ESPERADO**: Staging completamente limpio, operativo, con Polylang funcional y listo para implementación Fase 2 i18n.

**TIEMPO ESTIMADO**: 15-20 minutos de limpieza manual + 5 minutos verificaciones.