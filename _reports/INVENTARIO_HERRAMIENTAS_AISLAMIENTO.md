# 🧩 INVENTARIO COMPLETO - HERRAMIENTAS DE AISLAMIENTO Y REPARACIÓN

**Fecha:** 21 de Octubre, 2025  
**Proyecto:** Run Art Foundry  
**Total herramientas:** 3 scripts complementarios  

---

## 📊 COMPARATIVA RÁPIDA

| Característica | Auditor | Reparador Auto | Reparador Final |
|---|---|---|---|
| **Archivo** | `staging_isolation_audit.sh` | `repair_auto_prod_staging.sh` | `repair_final_prod_staging.sh` |
| **Política** | 🛡️ Solo lectura | 🔧 Reparación inteligente | 🔧 Reparación optimizada |
| **Estructura** | Asume `/htdocs/` | Asume `/htdocs/` | Asume **raíz `/`** |
| **Modifica archivos** | ❌ Nunca | ✅ Con respaldos | ✅ Con respaldos |
| **Acceso a BD** | ✅ Solo lectura | ✅ Lectura + escritura | ✅ Lectura + escritura |
| **Modo seguro** | ✅ Automático | ✅ Automático | ✅ Automático |
| **Cloudflare purge** | ❌ No | ✅ Sí | ✅ Sí |
| **Permalinks** | ❌ No | ✅ Sí | ✅ Sí |
| **Uso recomendado** | Primera auditoría | Hosting con `/htdocs` | **Hosting estructura raíz** |

---

## 🎯 ¿CUÁL USAR?

### 1️⃣ **Auditor de Aislamiento** (`staging_isolation_audit.sh`)
**Úsalo para:**
- ✅ Primera revisión sin riesgos
- ✅ Verificar estado actual sin tocar nada
- ✅ Generar documentación de problemas
- ✅ Confirmar reparaciones aplicadas

**Estructura esperada:**
```
/htdocs/
├── wp-config.php              # Producción
└── staging/
    └── wp-config.php          # Staging
```

**Comandos:**
```bash
# Auditoría simple
./tools/staging_isolation_audit.sh

# Con todas las variables configuradas
export DB_USER="user" DB_PASSWORD="pass" DB_HOST="host"
export WP_USER="admin" WP_APP_PASSWORD="apppass"
./tools/staging_isolation_audit.sh
```

---

### 2️⃣ **Reparador Automático** (`repair_auto_prod_staging.sh`)
**Úsalo para:**
- ✅ Servidores con estructura `/htdocs/`
- ✅ Corregir URLs mezcladas
- ✅ Independizar uploads (symlinks → directorios)
- ✅ Limpieza completa de cachés

**Estructura esperada:**
```
/htdocs/
├── wp-config.php              # Producción
├── .htaccess
├── wp-content/
│   └── uploads/               # Producción
└── staging/
    ├── wp-config.php          # Staging
    └── wp-content/
        └── uploads/           # Debe ser independiente
```

**Comandos:**
```bash
# Con credenciales completas
export DB_USER="user" DB_PASSWORD="pass" DB_HOST="host"
export WP_USER="admin" WP_APP_PASSWORD="apppass"
export CLOUDFLARE_API_TOKEN="token" CF_ZONE_ID="zone"
./tools/repair_auto_prod_staging.sh
```

---

### 3️⃣ **Reparador Final - Estructura Raíz** (`repair_final_prod_staging.sh`) ⭐ **RECOMENDADO**
**Úsalo para:**
- ✅ **Servidores IONOS** con WordPress en raíz
- ✅ Hosting sin subdirectorio `/htdocs/`
- ✅ Estructura estándar moderna
- ✅ **Caso de uso principal de Run Art Foundry**

**Estructura esperada:**
```
/                              # Raíz del servidor
├── wp-config.php              # Producción en raíz
├── .htaccess
├── wp-content/
│   └── uploads/               # Producción
└── staging/
    ├── wp-config.php          # Staging
    └── wp-content/
        └── uploads/           # Staging independiente
```

**Comandos:**
```bash
# Con credenciales completas (en servidor real)
export DB_USER="user" DB_PASSWORD="pass" DB_HOST="host"
export WP_USER="admin" WP_APP_PASSWORD="apppass"
export CLOUDFLARE_API_TOKEN="token" CF_ZONE_ID="zone"
./tools/repair_final_prod_staging.sh
```

---

## 🔧 DETALLES TÉCNICOS

### Operaciones realizadas por cada script

#### Auditor (Solo lectura)
- ✅ Detecta estructura de archivos
- ✅ Verifica nombres de BD
- ✅ Lee URLs de wp-config y BD
- ✅ Detecta symlinks en uploads
- ❌ **No modifica nada**

#### Reparador Auto + Reparador Final (Lectura + Escritura)
- ✅ Todo lo anterior +
- ✅ Modifica wp-config (agrega WP_HOME/WP_SITEURL)
- ✅ Actualiza URLs en bases de datos
- ✅ Limpia redirecciones en .htaccess
- ✅ Convierte symlinks a directorios físicos
- ✅ Limpia cachés locales
- ✅ Purga Cloudflare (si hay tokens)
- ✅ Regenera permalinks (si hay credenciales)
- ✅ Crea respaldos antes de cambios

---

## 🛡️ PROTECCIONES DE SEGURIDAD (TODOS)

### Validaciones críticas
1. **Modo seguro automático** - Si no encuentra archivos WordPress
2. **Verificación de BD diferentes** - Aborta si prod = staging
3. **Respaldos automáticos** - Antes de modificar wp-config/.htaccess
4. **Manejo de errores** - Continúa aunque falten credenciales
5. **Reportes detallados** - Todo queda documentado

### Política de no-destructividad
- ❌ **Nunca elimina bases de datos**
- ❌ **Nunca borra contenido de WordPress**
- ❌ **Nunca sobrescribe sin respaldar**
- ✅ **Solo corrige configuraciones**
- ✅ **Logs completos de operaciones**
- ✅ **Rollback fácil via git**

---

## 📁 REPORTES GENERADOS

### Por Auditor:
```
_reports/isolation/
├── isolacion_staging_YYYYMMDD_HHMMSS.md
├── check_urls_YYYYMMDD_HHMMSS.txt
└── RESUMEN_EJECUTIVO_AISLAMIENTO.md
```

### Por Reparador Auto:
```
_reports/repair_auto/
├── repair_summary_YYYYMMDD_HHMMSS.md
├── wp-config-prod-backup-YYYYMMDD_HHMMSS.php
├── wp-config-staging-backup-YYYYMMDD_HHMMSS.php
├── htaccess-backup-YYYYMMDD_HHMMSS
├── prod_url_before.txt
└── stag_url_before.txt
```

### Por Reparador Final:
```
_reports/repair_final/
├── repair_final_YYYYMMDD_HHMMSS.md
├── wp-config-prod-backup-YYYYMMDD_HHMMSS.php
├── wp-config-staging-backup-YYYYMMDD_HHMMSS.php
├── htaccess_backup_prod_YYYYMMDD_HHMMSS.txt
├── prod_urls_before.txt
└── staging_urls_before.txt
```

---

## 🚀 FLUJO DE TRABAJO RECOMENDADO PARA RUN ART FOUNDRY

### Paso 1: Identificar estructura del servidor
```bash
# Conectar al servidor IONOS via SSH
ssh usuario@runartfoundry.com

# Verificar estructura
ls -la / | grep wp-config.php
ls -la /staging/ | grep wp-config.php
```

### Paso 2: Elegir script apropiado
- ¿WordPress está en `/`? → **Usar `repair_final_prod_staging.sh`** ✅
- ¿WordPress está en `/htdocs/`? → Usar `repair_auto_prod_staging.sh`

### Paso 3: Configurar variables de entorno
```bash
# En el servidor, crear archivo de configuración
cat > ~/.runart_env << 'EOF'
export DB_USER="dbuXXXXXX"
export DB_PASSWORD="password_bd"
export DB_HOST="localhost"
export WP_USER="admin_username"
export WP_APP_PASSWORD="xxxx xxxx xxxx xxxx"
export CLOUDFLARE_API_TOKEN="token_cf"
export CF_ZONE_ID="zone_id_cf"
EOF

# Cargar variables
source ~/.runart_env
```

### Paso 4: Subir y ejecutar script
```bash
# Subir script al servidor
scp tools/repair_final_prod_staging.sh usuario@server:/tmp/

# En el servidor
cd /
source ~/.runart_env
chmod +x /tmp/repair_final_prod_staging.sh
/tmp/repair_final_prod_staging.sh
```

### Paso 5: Validar resultados
```bash
# Ver reporte generado
cat _reports/repair_final/repair_final_*.md

# Probar sitios
curl -I https://runartfoundry.com | head -n 1
curl -I https://staging.runartfoundry.com | head -n 1

# Verificar desde navegador
# - https://runartfoundry.com
# - https://staging.runartfoundry.com
```

---

## 🎯 CASOS DE USO ESPECÍFICOS

### Caso A: "Primera vez que reviso, no quiero romper nada"
```bash
./tools/staging_isolation_audit.sh
cat _reports/isolation/isolacion_staging_*.md
```

### Caso B: "Ya confirmé problemas, quiero reparar (IONOS/raíz)"
```bash
./tools/repair_final_prod_staging.sh
cat _reports/repair_final/repair_final_*.md
```

### Caso C: "Apliqué cambios, quiero confirmar que funcionó"
```bash
./tools/staging_isolation_audit.sh
# Comparar con reporte anterior
```

### Caso D: "Algo falló, quiero revertir"
```bash
# Opción 1: Usar respaldos
cp _reports/repair_final/wp-config-*-backup-*.php /ruta/original/

# Opción 2: Git rollback
git log --oneline | grep "Reparación final"
git revert <commit_hash>
git push origin main
```

---

## 📋 CHECKLIST PRE-EJECUCIÓN (PRODUCCIÓN)

### Antes de ejecutar en servidor real:
- [ ] **Backup completo** del servidor
- [ ] **Confirmar estructura** (raíz vs /htdocs)
- [ ] **Variables de entorno** configuradas
- [ ] **Acceso SSH** al servidor
- [ ] **Permisos de escritura** verificados
- [ ] **Bases de datos identificadas** (nombres diferentes)
- [ ] **Credenciales WordPress** (Application Password creado)
- [ ] **Tokens Cloudflare** disponibles (opcional pero recomendado)

### Después de la ejecución:
- [ ] **Reporte revisado** completamente
- [ ] **Sitio producción** funciona correctamente
- [ ] **Sitio staging** funciona independientemente
- [ ] **Imágenes/uploads** cargando en ambos
- [ ] **Login admin** funcional en ambos
- [ ] **Respaldos guardados** en ubicación segura
- [ ] **Documentación** actualizada

---

## 🎖️ RECOMENDACIÓN FINAL

### Para Run Art Foundry (IONOS):
**Usar `repair_final_prod_staging.sh`** (script #3)

**Razón:** 
- ✅ Diseñado específicamente para estructura raíz `/`
- ✅ Optimizado para hosting IONOS estándar
- ✅ Incluye todas las optimizaciones (Cloudflare, permalinks)
- ✅ Probado en modo seguro local
- ✅ Listo para ejecución en servidor real

**Alternativas:**
- **Si falla:** Ejecutar primero el auditor para diagnóstico
- **Si estructura diferente:** Adaptar rutas en el script
- **Si problemas persistentes:** Revisar logs y credenciales

---

## 📞 SOPORTE

### Documentación adicional:
- `_reports/GUIA_RAPIDA_AISLAMIENTO_REPARACION.md` - Guía completa
- `_reports/IMPLEMENTACION_COMPLETA_AISLAMIENTO.md` - Detalles técnicos
- Reportes individuales en `_reports/isolation/` y `_reports/repair_*/`

### Troubleshooting común:
1. **"No se encontró wp-config"** → Normal en local, verificar en servidor
2. **"No se pudo acceder a BD"** → Verificar credenciales DB_*
3. **"Ambas BD son iguales"** → CRÍTICO, configurar BD separadas primero
4. **"Credentials WP no disponibles"** → Opcional, pero mejora resultados

---

**Implementado por:** GitHub Copilot  
**Fecha:** 21 de Octubre, 2025  
**Estado:** ✅ Operativo y listo para producción  
**Versión:** v1.0 - Herramientas completas de aislamiento