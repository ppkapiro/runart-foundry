# 🧩 GUÍA RÁPIDA - HERRAMIENTAS DE AISLAMIENTO Y REPARACIÓN

**Fecha:** 21 de Octubre, 2025  
**Proyecto:** Run Art Foundry  
**Herramientas disponibles:** 2 scripts complementarios  

---

## 📋 SCRIPTS DISPONIBLES

### 1️⃣ **Auditor de Aislamiento** (Solo lectura/reporte)
**Archivo:** `tools/staging_isolation_audit.sh`  
**Propósito:** Verificar estado actual sin modificar nada  
**Política:** 🛡️ **CERO modificaciones** - Solo diagnóstico y reporte  

### 2️⃣ **Reparador Automático** (Lectura + corrección)
**Archivo:** `tools/repair_auto_prod_staging.sh`  
**Propósito:** Corregir problemas detectados de forma segura  
**Política:** 🔧 **Reparaciones inteligentes** - Con respaldos automáticos  

---

## 🎯 ¿CUÁNDO USAR CADA UNO?

### Usar **AUDITOR** cuando:
- ✅ Quieres **verificar** el estado actual sin tocar nada
- ✅ Primera vez que revisas los entornos
- ✅ Necesitas **documentación** del problema
- ✅ Quieres **confirmar** que todo está bien después de cambios

### Usar **REPARADOR** cuando:
- ✅ Ya confirmaste que hay problemas (con el auditor)
- ✅ Necesitas **corregir** URLs mezcladas entre entornos
- ✅ Hay enlaces simbólicos problemáticos en uploads
- ✅ Quieres **restaurar** el aislamiento completo

---

## 🚀 EJECUCIÓN RÁPIDA

### En servidor local/desarrollo (modo seguro)
```bash
# Auditoría (siempre seguro)
./tools/staging_isolation_audit.sh

# Reparación (modo seguro automático si no hay archivos WP)
./tools/repair_auto_prod_staging.sh
```

### En servidor de hosting (modo activo)
```bash
# 1. Configurar variables de entorno
export DB_USER="usuario_bd"
export DB_PASSWORD="password_bd"
export DB_HOST="host_bd"
export WP_USER="admin_wp"
export WP_APP_PASSWORD="app_password"
export CLOUDFLARE_API_TOKEN="token_cf"
export CF_ZONE_ID="zone_id"

# 2. Ejecutar auditoría primero
./tools/staging_isolation_audit.sh

# 3. Si hay problemas, ejecutar reparación
./tools/repair_auto_prod_staging.sh
```

---

## 📊 REPORTES GENERADOS

### Auditor genera:
- `_reports/isolation/isolacion_staging_YYYYMMDD_HHMMSS.md`
- `_reports/isolation/check_urls_YYYYMMDD_HHMMSS.txt`

### Reparador genera:
- `_reports/repair_auto/repair_summary_YYYYMMDD_HHMMSS.md`
- `_reports/repair_auto/wp-config-*-backup-YYYYMMDD_HHMMSS.php`
- `_reports/repair_auto/htaccess-backup-YYYYMMDD_HHMMSS`
- `_reports/repair_auto/prod_url_before.txt`
- `_reports/repair_auto/stag_url_before.txt`

---

## 🛡️ CARACTERÍSTICAS DE SEGURIDAD

### Ambos scripts incluyen:
- ✅ **Detección automática** de modo seguro vs activo
- ✅ **Validación crítica** de BD diferentes antes de cualquier cambio
- ✅ **Respaldos automáticos** de archivos modificados
- ✅ **Logs detallados** de todas las operaciones
- ✅ **Rollback fácil** mediante git y respaldos

### Protecciones específicas del reparador:
- 🚨 **ABORT si BD son iguales** (evita corrupción de datos)
- 📋 **Respaldo antes de modificar** (wp-config, .htaccess)
- 🔄 **Operaciones idempotentes** (se puede ejecutar múltiples veces)
- 🎯 **Solo corrige URLs/enlaces**, nunca elimina contenido

---

## 🔍 PROBLEMAS TÍPICOS QUE DETECTAN Y CORRIGEN

### ⚠️ Problemas detectables:
1. **BD compartida** entre prod y staging (CRÍTICO)
2. **URLs mezcladas** (staging apunta a prod o viceversa)
3. **Enlaces simbólicos** de uploads compartidos
4. **Redirecciones cruzadas** en .htaccess
5. **Cachés contaminadas** entre entornos

### ✅ Correcciones aplicadas:
1. **Forzar URLs correctas** en wp-config.php
2. **Actualizar siteurl/home** en bases de datos
3. **Independizar uploads** (copiar en lugar de enlace)
4. **Limpiar .htaccess** de redirecciones problemáticas
5. **Purgar cachés** local y Cloudflare
6. **Regenerar permalinks** en staging

---

## 📈 FLUJO DE TRABAJO RECOMENDADO

```
1. AUDITORÍA INICIAL
   ↓
2. REVISAR REPORTE
   ↓
3. ¿HAY PROBLEMAS? → SÍ: REPARACIÓN → NO: ✅ LISTO
   ↓
4. VALIDAR REPARACIÓN
   ↓
5. AUDITORÍA FINAL (confirmar)
   ↓
6. ✅ ENTORNOS AISLADOS
```

### Comandos específicos:
```bash
# Paso 1: Auditoría inicial
./tools/staging_isolation_audit.sh

# Paso 2: Revisar reporte
cat _reports/isolation/isolacion_staging_*.md

# Paso 3: Si hay problemas, reparar
./tools/repair_auto_prod_staging.sh

# Paso 4: Validar resultados
cat _reports/repair_auto/repair_summary_*.md

# Paso 5: Auditoría final
./tools/staging_isolation_audit.sh

# Paso 6: Confirmar aislamiento
curl -I https://runartfoundry.com
curl -I https://staging.runartfoundry.com
```

---

## 📞 TROUBLESHOOTING

### Error: "No se encontraron archivos wp-config"
**Causa:** Estructura de hosting diferente o ejecución local  
**Solución:** Normal en desarrollo. En hosting, verificar rutas reales  

### Error: "No se pudo acceder a la base de datos"
**Causa:** Credenciales no configuradas o incorrectas  
**Solución:** Configurar variables DB_USER, DB_PASSWORD, DB_HOST  

### Error: "Ambas instancias apuntan a la misma BD"
**Causa:** Configuración peligrosa detectada  
**Resultado:** Script se aborta automáticamente (protección)  
**Solución:** Configurar BD separadas antes de continuar  

### Warning: "Credenciales WP no disponibles"
**Causa:** WP_USER/WP_APP_PASSWORD no configurados  
**Impacto:** Permalinks no se regeneran, pero resto funciona  
**Solución:** Configurar Application Password de WordPress  

---

## 🎯 CASOS DE USO COMUNES

### Caso 1: "Sospecho que staging y prod están mezclados"
```bash
./tools/staging_isolation_audit.sh
# Revisar reporte generado para confirmar problema
```

### Caso 2: "Quiero separar los entornos de una vez"
```bash
./tools/repair_auto_prod_staging.sh
# Revisar reporte para confirmar correcciones aplicadas
```

### Caso 3: "Apliqué cambios manualmente, quiero verificar"
```bash
./tools/staging_isolation_audit.sh
# Confirmar que el aislamiento es correcto
```

### Caso 4: "Algo se rompió, quiero volver atrás"
```bash
# Los respaldos están en _reports/repair_auto/
cp _reports/repair_auto/wp-config-*-backup-*.php /ruta/original/
# O hacer rollback via git
git log --oneline | grep "Reparación automática"
git revert <commit_hash>
```

---

## 📁 ESTRUCTURA DE ARCHIVOS

```
tools/
├── staging_isolation_audit.sh      # Auditor (solo lectura)
└── repair_auto_prod_staging.sh     # Reparador (con correcciones)

_reports/
├── isolation/                       # Reportes de auditoría
│   ├── isolacion_staging_*.md
│   ├── check_urls_*.txt
│   └── RESUMEN_EJECUTIVO_AISLAMIENTO.md
└── repair_auto/                     # Reportes de reparación
    ├── repair_summary_*.md
    ├── wp-config-*-backup-*.php
    ├── htaccess-backup-*
    ├── prod_url_before.txt
    └── stag_url_before.txt
```

---

## ✅ CHECKLISTPARAOWNER/ADMIN

### Antes de ejecutar en producción:
- [ ] Hacer backup completo del servidor
- [ ] Verificar que BD de prod y staging son diferentes
- [ ] Configurar todas las variables de entorno necesarias
- [ ] Tener acceso SSH al servidor de hosting
- [ ] Verificar permisos de escritura en directorios WordPress

### Después de la reparación:
- [ ] Verificar que https://runartfoundry.com funciona correctamente
- [ ] Verificar que https://staging.runartfoundry.com funciona independientemente
- [ ] Confirmar que uploads/imágenes funcionan en ambos sitios
- [ ] Probar login de admin en ambos entornos
- [ ] Ejecutar auditoría final para confirmar aislamiento

---

**NOTA IMPORTANTE:** Estos scripts están diseñados con múltiples capas de seguridad y nunca eliminarán contenido. En caso de duda, siempre ejecutar el auditor primero para entender el estado actual antes de aplicar reparaciones.