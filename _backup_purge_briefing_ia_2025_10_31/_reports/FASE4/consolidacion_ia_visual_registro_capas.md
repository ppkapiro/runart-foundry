# Registro de Capas IA-Visual para Consolidación
## FASE 4.D - Inventario y Clasificación

**Fecha de análisis:** 2025-10-31  
**Fuente:** `informe_reconstruccion_base_editable_ia_visual.md` (FASE 4.C)  
**Objetivo:** Identificar todas las capas de datos IA-Visual existentes, clasificarlas por función y determinar la fuente de verdad única.

---

## 1. Resumen Ejecutivo

### 1.1 Contexto
Durante FASE 4.C se detectó **replicación 5×** del dataset IA-Visual (index.json + 3 páginas enriquecidas) en diferentes ubicaciones del proyecto. Esta fase (4.D) establece la estrategia de consolidación para:
- Eliminar redundancia (217.5 KB → 43.5 KB)
- Definir fuente de verdad única
- Prevenir desincronización
- Facilitar edición y gestión

### 1.2 Hallazgos Clave
- **5 capas** detectadas con contenido idéntico (4 archivos JSON cada una)
- **Tamaño total:** 217.5 KB (43.5 KB × 5)
- **Redundancia:** 400% (4 capas duplicadas innecesarias)
- **Última modificación más reciente:** 2025-10-31 11:56:24 (capa 5 - tools/)
- **Riesgo:** Desincronización sin mecanismo de validación

---

## 2. Inventario Detallado de Capas

### 🔵 CAPA 1: Repositorio (data/)

**Ruta absoluta:**
```
/home/pepe/work/runartfoundry/data/assistants/rewrite/
```

**Contenido:**
```
├── index.json                (1.1 KB)
├── page_42.json              (2.3 KB)
├── page_43.json              (2.3 KB)
└── page_44.json              (3.0 KB)

Total: 4 archivos | 8.7 KB
```

**Última modificación:** `2025-10-30 14:32:38`

**Estado:** ✅ **PRESENTE**

**Propósito original:**
- Capa primaria de desarrollo
- Fuente de verdad en repositorio Git
- Versionamiento con control de cambios

**Características:**
- ✅ Versionada en Git
- ✅ Accesible sin WordPress
- ✅ Facilita desarrollo/testing
- ⚠️ NO editable desde panel WP
- ⚠️ Requiere redeploy para actualizar WordPress

**Clasificación:** **DESARROLLO / GIT**

---

### 🟢 CAPA 2: WordPress Core (wp-content/runart-data/)

**Ruta absoluta:**
```
/home/pepe/work/runartfoundry/wp-content/runart-data/assistants/rewrite/
```

**Contenido:**
```
├── index.json                (1.1 KB)
├── page_42.json              (2.3 KB)
├── page_43.json              (2.3 KB)
└── page_44.json              (3.0 KB)

Total: 4 archivos | 8.7 KB
```

**Última modificación:** `2025-10-30 18:45:19`

**Estado:** ✅ **PRESENTE**

**Propósito original:**
- Capa de lectura para plugins WordPress
- Ubicación estándar en wp-content/

**Características:**
- ✅ Editable sin reinstalar plugin
- ✅ Sobrevive a actualizaciones de plugin
- ✅ Accesible desde panel WP
- ✅ NO depende de Git
- ✅ Protegida por htaccess WordPress (no web-public)
- ✅ Respaldable con backups de WP

**Clasificación:** **WORDPRESS PRIMARIA** → **🎯 FUENTE DE VERDAD ELEGIDA**

**Justificación:**
1. **Persistencia:** No se borra con actualizaciones de plugin
2. **Editabilidad:** Modificable desde panel WP sin redeploy
3. **Seguridad:** Protegida por configuración WordPress estándar
4. **Backups:** Incluida en procedimientos de backup WP
5. **Independencia:** No requiere sincronización con Git para operar

---

### 🟡 CAPA 3: WordPress Uploads (wp-content/uploads/runart-data/)

**Ruta absoluta:**
```
/home/pepe/work/runartfoundry/wp-content/uploads/runart-data/assistants/rewrite/
```

**Contenido:**
```
├── index.json                (1.1 KB)
├── page_42.json              (2.3 KB)
├── page_43.json              (2.3 KB)
└── page_44.json              (3.0 KB)

Total: 4 archivos | 8.7 KB
```

**Última modificación:** `2025-10-30 18:45:19`

**Estado:** ✅ **PRESENTE**

**Propósito original:**
- Capa compatible con gestión uploads WP
- Posible acceso desde URL pública

**Características:**
- ⚠️ Potencialmente accesible vía web (`/wp-content/uploads/`)
- ⚠️ Puede ser modificada por usuarios con permisos upload
- ⚠️ No es ubicación estándar para datos de configuración
- ✅ Respaldable con backups de uploads

**Clasificación:** **WORDPRESS SECUNDARIA** → **⚠️ DEPRECAR**

**Riesgos:**
- **Exposición web:** JSON podrían ser accesibles públicamente
- **Permisos:** Editables por usuarios con rol Editor/Contributor
- **Confusión:** Duplicación innecesaria con capa 2

**Recomendación:** Eliminar tras consolidación. Si plugin lee desde aquí, cambiar a capa 2.

---

### 🟠 CAPA 4: Plugin Bridge (wp-content/plugins/runart-wpcli-bridge/data/)

**Ruta absoluta:**
```
/home/pepe/work/runartfoundry/wp-content/plugins/runart-wpcli-bridge/data/assistants/rewrite/
```

**Contenido:**
```
├── index.json                (1.1 KB)
├── page_42.json              (2.3 KB)
├── page_43.json              (2.3 KB)
└── page_44.json              (3.0 KB)

Total: 4 archivos | 8.7 KB
```

**Última modificación:** `2025-10-30 18:45:19`

**Estado:** ✅ **PRESENTE**

**Propósito original:**
- Datos embebidos en plugin WP-CLI Bridge
- Auto-provisioning de datos en instalación

**Características:**
- ✅ Distribuida con plugin ZIP
- ✅ Auto-provisioning en instalación limpia
- ⚠️ Se borra con desinstalación del plugin
- ⚠️ NO sobrevive a actualizaciones del plugin
- ⚠️ NO editable sin modificar plugin

**Clasificación:** **PLUGIN EMBEBIDO** → **📦 MANTENER COMO FALLBACK**

**Uso futuro:**
- **Inicialización:** Copiar a capa 2 en primera instalación si no existe
- **Fallback:** Leer solo si capa 2 no disponible
- **Distribución:** Incluir en plugin ZIP como datos de ejemplo

**Recomendación:** Mantener solo como fuente de datos de ejemplo para instalaciones nuevas.

---

### 🔴 CAPA 5: Plugin IA-Visual Unified (tools/runart-ia-visual-unified/data/)

**Ruta absoluta:**
```
/home/pepe/work/runartfoundry/tools/runart-ia-visual-unified/data/assistants/rewrite/
```

**Contenido:**
```
├── index.json                (1.1 KB)
├── page_42.json              (2.3 KB)
├── page_43.json              (2.3 KB)
└── page_44.json              (3.0 KB)

Total: 4 archivos | 8.7 KB
```

**Última modificación:** `2025-10-31 11:56:24` ← **MÁS RECIENTE**

**Estado:** ✅ **PRESENTE**

**Propósito original:**
- Datos embebidos en plugin principal
- Distribución empaquetada en ZIP

**Características:**
- ✅ Incluida en distribución ZIP del plugin
- ✅ Versión más reciente detectada (Oct 31 11:56)
- ⚠️ Se borra con desinstalación del plugin
- ⚠️ NO sobrevive a actualizaciones del plugin
- ⚠️ NO editable sin modificar código fuente plugin

**Clasificación:** **PLUGIN EMBEBIDO** → **📦 MANTENER COMO FALLBACK**

**Uso futuro:**
- **Inicialización:** Copiar a capa 2 en primera instalación si no existe
- **Fallback:** Leer solo si capa 2 y capa 4 no disponibles
- **Distribución:** Incluir en plugin ZIP empaquetado

**Recomendación:** Mantener solo como fuente de datos de ejemplo para distribución.

---

## 3. Análisis Temporal de Sincronización

### 3.1 Timeline de Modificaciones

```
2025-10-30 14:32:38  →  Capa 1 (data/) actualizada
          ↓ +4h 13m
2025-10-30 18:45:19  →  Capas 2, 3, 4 sincronizadas (wp-content/*)
          ↓ +17h 11m
2025-10-31 11:56:24  →  Capa 5 (tools/plugin) actualizada
```

### 3.2 Interpretación

**Evento 1 (Oct 30 14:32):** Actualización en capa desarrollo (data/)
- Posible edición manual de JSON en repo
- Commit Git con dataset actualizado

**Evento 2 (Oct 30 18:45):** Sincronización masiva a WordPress
- Script de deployment o copia manual
- 3 capas actualizadas simultáneamente (wp-content/*)
- Delta: +4h 13m desde capa 1

**Evento 3 (Oct 31 11:56):** Actualización plugin principal
- Packaging de plugin v2.1.0 con datos frescos
- Delta: +17h 11m desde capas WordPress
- **Esta es la versión más reciente del dataset**

### 3.3 Desincronización Detectada

**Problema:** Capa 5 tiene versión 17 horas más reciente que capas WordPress

**Posibles causas:**
1. Packaging del plugin actualizado pero no sincronizado a WordPress
2. Edición de datos en tools/ sin copiar a wp-content/
3. Proceso de consolidación incompleto

**Riesgo:**
- Si WordPress lee de capa 2/3/4 → datos desactualizados (-17h)
- Si WordPress lee de capa 5 → datos actualizados pero volátiles (se pierden con actualización)

**Solución FASE 4.D:**
- Consolidar TODAS las capas a capa 2 (wp-content/runart-data/)
- Usar capa 2 como fuente única
- Capas 4 y 5 solo como fallback inicial

---

## 4. Matriz de Decisión de Capas

| Capa | Ruta | Estado | Rol Futuro | Acción |
|------|------|--------|------------|--------|
| **1** | `data/assistants/rewrite/` | ✅ Presente | **Desarrollo/Git** | 🔄 Mantener, sync manual |
| **2** | `wp-content/runart-data/` | ✅ Presente | **🎯 FUENTE DE VERDAD** | ✅ **PROMOVER A PRIMARIA** |
| **3** | `wp-content/uploads/runart-data/` | ✅ Presente | ~~Uploads~~ | ❌ **ELIMINAR** |
| **4** | `wp-content/plugins/.../data/` | ✅ Presente | Fallback inicial | 📦 Mantener solo lectura |
| **5** | `tools/.../data/` | ✅ Presente | Fallback distribución | 📦 Mantener solo lectura |

**Leyenda:**
- 🎯 = Fuente de verdad única (lectura/escritura)
- 🔄 = Sincronización manual (solo desarrollo)
- 📦 = Fallback inicial (solo lectura, provisioning)
- ❌ = Eliminar (redundante y riesgosa)
- ✅ = Mantener con modificaciones

---

## 5. Estrategia de Consolidación

### 5.1 Fuente de Verdad Elegida

**Capa 2: `wp-content/runart-data/assistants/rewrite/`**

**Justificación técnica:**
1. **Persistencia:** Sobrevive a actualizaciones de plugins
2. **Editabilidad:** Modificable desde panel WP sin código
3. **Seguridad:** Protegida por .htaccess estándar de WordPress
4. **Backups:** Incluida en procedimientos backup WP
5. **Independencia:** Opera sin dependencia de Git o plugins
6. **Estabilidad:** No se modifica con desinstalación de plugins
7. **Accesibilidad:** Legible por todos los plugins instalados

**Ubicación estándar WordPress:**
- `wp-content/` es el directorio estándar para datos personalizados
- Nombre `runart-data/` evita conflictos con plugins third-party
- Estructura `assistants/rewrite/` mantiene organización semántica

### 5.2 Roles de Capas Post-Consolidación

#### Capa 1 (data/) - Desarrollo
**Rol:** Fuente para desarrollo y versionamiento Git

**Flujo:**
1. Desarrollador edita JSON en `data/assistants/rewrite/`
2. Commit Git con cambios
3. **NO** se sincroniza automáticamente a WordPress
4. Sincronización manual con script cuando sea necesario

**Uso:**
- Testing local sin WordPress
- Versionamiento de cambios estructurales
- Desarrollo de nuevas características

#### Capa 2 (wp-content/runart-data/) - PRODUCCIÓN ✅
**Rol:** Fuente de verdad única operacional

**Flujo:**
1. Plugin lee/escribe SIEMPRE de/a esta ubicación
2. Panel WP edita directamente aquí
3. Backups incluyen esta carpeta
4. Consolidación copia todo a aquí

**Uso:**
- Operación normal del plugin
- Edición desde panel WP
- Exportación de datos
- Importación de dataset real

#### Capa 3 (wp-content/uploads/runart-data/) - ELIMINAR ❌
**Rol:** Ninguno (redundante y riesgosa)

**Acción:**
1. Verificar que plugin NO lee de aquí
2. Eliminar directorio completo tras consolidación
3. Actualizar documentación indicando deprecación

#### Capa 4 (plugins/runart-wpcli-bridge/data/) - Fallback
**Rol:** Provisioning inicial (solo lectura)

**Flujo:**
1. En primera instalación: si capa 2 NO existe → copiar capa 4 a capa 2
2. Nunca escribir aquí
3. Nunca leer si capa 2 existe

**Uso:**
- Auto-provisioning en instalación limpia
- Datos de ejemplo para testing

#### Capa 5 (tools/runart-ia-visual-unified/data/) - Fallback
**Rol:** Provisioning distribución (solo lectura)

**Flujo:**
1. Incluir en ZIP de distribución del plugin
2. En activación del plugin: si capa 2 NO existe → copiar capa 5 a capa 2
3. Nunca escribir aquí
4. Nunca leer si capa 2 o capa 4 existen

**Uso:**
- Distribución de plugin empaquetado
- Auto-provisioning en instalación vía ZIP

### 5.3 Cascada de Lectura (Fallback Chain)

```
SOLICITUD DE DATOS
       ↓
┌──────────────────────────────────┐
│ 1. Leer de capa 2 (runart-data/) │ ← PRIMARIA (99% casos)
└──────────────┬───────────────────┘
               │ ¿Existe?
               ├─ SÍ → Devolver datos ✅
               │
               └─ NO ↓
┌──────────────────────────────────┐
│ 2. Leer de capa 4 (wpcli-bridge) │ ← FALLBACK 1 (instalación)
└──────────────┬───────────────────┘
               │ ¿Existe?
               ├─ SÍ → Copiar a capa 2 → Devolver ✅
               │
               └─ NO ↓
┌──────────────────────────────────┐
│ 3. Leer de capa 5 (ia-visual)    │ ← FALLBACK 2 (distribución)
└──────────────┬───────────────────┘
               │ ¿Existe?
               ├─ SÍ → Copiar a capa 2 → Devolver ✅
               │
               └─ NO ↓
┌──────────────────────────────────┐
│ 4. ERROR: Dataset no encontrado  │ ← FALLO TOTAL
└──────────────────────────────────┘
```

**Regla crítica:** SIEMPRE escribir a capa 2. NUNCA escribir a capas 4 o 5.

---

## 6. Estado Actual de Capas (Verificación)

**Fecha de verificación:** 2025-10-31

### Capa 1 - Repositorio
- **Estado:** ✅ PRESENTE
- **Archivos:** 4
- **Última modificación:** 2025-10-30 14:32:38
- **Tamaño:** 8.7 KB

### Capa 2 - WordPress Core
- **Estado:** ✅ PRESENTE
- **Archivos:** 4
- **Última modificación:** 2025-10-30 18:45:19
- **Tamaño:** 8.7 KB

### Capa 3 - WordPress Uploads
- **Estado:** ✅ PRESENTE (deprecar)
- **Archivos:** 4
- **Última modificación:** 2025-10-30 18:45:19
- **Tamaño:** 8.7 KB

### Capa 4 - Plugin Bridge
- **Estado:** ✅ PRESENTE
- **Archivos:** 4
- **Última modificación:** 2025-10-30 18:45:19
- **Tamaño:** 8.7 KB

### Capa 5 - Plugin IA-Visual
- **Estado:** ✅ PRESENTE
- **Archivos:** 4
- **Última modificación:** 2025-10-31 11:56:24 ← **MÁS RECIENTE**
- **Tamaño:** 8.7 KB

**Total archivos:** 20 (5 capas × 4 archivos)  
**Tamaño total:** 43.5 KB (lógico) | 217.5 KB (real)  
**Redundancia:** 400%

---

## 7. Acciones Pendientes FASE 4.D

### 7.1 Inmediatas (Críticas)

1. **✅ Promover capa 2 a fuente de verdad**
   - Actualizar código plugin para leer/escribir exclusivamente de `wp-content/runart-data/`
   - Implementar cascada de fallback (capa 2 → capa 4 → capa 5)
   - Documentar en código PHP con comentarios claros

2. **🔄 Consolidar datos a capa 2**
   - Ejecutar script `consolidate_ia_visual_data.py --write`
   - Copiar versión más reciente (capa 5, Oct 31 11:56) a capa 2
   - Verificar integridad con checksums

3. **❌ Eliminar capa 3**
   - Backup de `wp-content/uploads/runart-data/` a `/_tmp/backup_capa3_20251031/`
   - Eliminar directorio `wp-content/uploads/runart-data/`
   - Actualizar documentación indicando deprecación

### 7.2 Mediano Plazo (Validación)

4. **🧪 Testing de cascada**
   - Simular ausencia de capa 2 → verificar fallback a capa 4
   - Simular ausencia de capas 2 y 4 → verificar fallback a capa 5
   - Verificar que escrituras van solo a capa 2

5. **📊 Endpoint de health extendido**
   - Implementar `/v1/ia-visual/health-extended`
   - Mostrar estado de cada capa (presente/ausente)
   - Indicar cuál es la fuente activa
   - Detectar desincronizaciones

6. **📝 Actualizar documentación**
   - Plugin README con nueva arquitectura
   - Diagrama de flujo de lectura/escritura
   - Guía para importar dataset real

### 7.3 Largo Plazo (Mantenimiento)

7. **🔄 Script de sincronización**
   - Desarrollar `sync_git_to_wordpress.py`
   - Sincronizar capa 1 → capa 2 bajo demanda
   - Logging de operaciones

8. **🛡️ Sistema de backups**
   - Backup automático antes de escrituras en capa 2
   - Directorio `wp-content/uploads/runart-backups/ia-visual/`
   - Retención 7 días

9. **📈 Monitoreo de integridad**
   - Checksums periódicos de capa 2
   - Alertas de desincronización
   - Logs de accesos

---

## 8. Criterios de Éxito FASE 4.D

### 8.1 Consolidación Completada ✅

- [ ] Capa 2 contiene dataset más reciente (version Oct 31 11:56)
- [ ] Plugin lee exclusivamente de capa 2 en operación normal
- [ ] Cascada de fallback implementada y testeada
- [ ] Capa 3 eliminada y documentada como deprecada
- [ ] Endpoint `/v1/ia-visual/health-extended` reporta estado correcto

### 8.2 Editabilidad Activa ✅

- [ ] Panel WP puede editar datos en capa 2
- [ ] Cambios persisten tras reinicio de WordPress
- [ ] Sistema de colas `runart-jobs/` operativo
- [ ] Backups automáticos antes de cada escritura

### 8.3 Preparación para Dataset Real ✅

- [ ] Script `consolidate_ia_visual_data.py --from-remote` documentado
- [ ] Endpoint de importación disponible
- [ ] Proceso de validación de dataset importado
- [ ] Documentación para admin/staging completa

---

## 9. Referencias

**Documentos relacionados:**
- `informe_reconstruccion_base_editable_ia_visual.md` (FASE 4.C)
- `informe_global_ia_visual_runart_foundry.md` (FASE 4.A)
- `PLAN_MAESTRO_FINAL_FASE4B.md` (FASE 4.B)
- `lista_acciones_admin_staging.md` (FASE 4.A)

**Archivos a crear en FASE 4.D:**
- `docs/IA_VISUAL_EDITORIAL_QUEUE.md`
- `docs/IA_VISUAL_BACKUPS.md`
- `docs/IA_VISUAL_REST_REFERENCE.md`
- `CIERRE_FASE4D_CONSOLIDACION.md`
- `tools/consolidate_ia_visual_data.py`

---

**Generado:** 2025-10-31  
**Fase:** 4.D - Consolidación y Activación  
**Estado:** ✅ Inventario completado, estrategia definida  
**Próximo paso:** Diseño de flujo de consolidación
