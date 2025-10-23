# 🚀 LIMPIEZA MANUAL STAGING - INSTRUCCIONES EXACTAS

**El problema:** Los scripts automáticos no pueden eliminar contenido sin credenciales válidas.
**La solución:** Limpieza manual desde wp-admin + verificación automática.

## 📋 PASOS PARA LIMPIEZA MANUAL

### PASO 1: Acceso a WordPress Admin
```
URL: https://staging.runartfoundry.com/wp-admin/
```

### PASO 2: Eliminar Posts (35 elementos)
1. Ir a **Posts → All Posts**
2. Seleccionar **todos los posts** (checkbox superior)
3. Cambiar **Bulk Actions** a **"Move to Trash"**
4. Click **Apply**
5. Ir a **Posts → Trash**
6. Seleccionar **todos** y **"Delete Permanently"**

### PASO 3: Eliminar Páginas (23 elementos)
1. Ir a **Pages → All Pages**  
2. Seleccionar **todas las páginas** EXCEPTO:
   - Sample Page (si existe)
   - Privacy Policy (si existe)
3. **Bulk Actions → Move to Trash**
4. **Pages → Trash → Delete Permanently**

### PASO 4: Eliminar Medios (99 elementos)
1. Ir a **Media → Library**
2. Cambiar vista a **List View** (más fácil)
3. Seleccionar **todos los medios** (checkbox superior)
4. **Bulk Actions → Delete Permanently**
5. Confirmar eliminación

### PASO 5: Vaciar Papeleras
1. **Posts → Trash → Empty Trash**
2. **Pages → Trash → Empty Trash**

## 🔍 VERIFICACIÓN AUTOMÁTICA

Después de la limpieza manual, ejecuta:

```bash
cd /home/pepe/work/runartfoundry
./tools/staging_verify_cleanup.sh
```

**Resultado esperado:**
- ✅ 0 posts
- ✅ 0-2 páginas (solo sistema)
- ✅ 0 medios
- ✅ Polylang ES/EN preservado

## ⚡ ALTERNATIVA: Limpieza con Credenciales

Si tienes credenciales de wp-admin, puedes usar:

```bash
# Con Application Password
export WP_USER="tu_usuario"
export WP_APP_PASSWORD="tu_password"
./tools/staging_cleanup_auth.sh
```

## 🎯 DESPUÉS DE LA LIMPIEZA

Una vez staging esté limpio:

```bash
# Desplegar Fase 2 i18n automáticamente
./docs/i18n/DEPLOY_FASE2_STAGING.md
```

## 📊 ESTADO ACTUAL

**Contenido detectado en staging:**
- **Posts:** 10+ (incluyendo contenido de R.U.N Art Foundry)
- **Páginas:** 10+ (páginas de prueba y contenido)
- **Medios:** 10+ (imágenes y archivos)
- **Polylang:** ✅ Activo con ES/EN

**Tiempo estimado limpieza manual:** 5-10 minutos
**Tiempo total hasta Fase 2 desplegada:** 15-20 minutos

---

*La limpieza manual es la forma más confiable cuando no se tienen credenciales automáticas configuradas correctamente.*