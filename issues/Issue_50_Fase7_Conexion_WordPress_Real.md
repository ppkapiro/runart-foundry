# 🧾 Issue #50 — Checklist Fase 7 · Conexión WordPress Real

**Fecha de inicio:** 2025-10-20  
**Estado:** 🟡 En ejecución  
**Rama:** `feat/fase7-wp-connection`  
**Ubicación:** `issues/Issue_50_Fase7_Conexion_WordPress_Real.md`

---

## 🚀 Ejecución — Fase 7 (En progreso)

**Inicio de ejecución:** 2025-10-20 14:16 UTC  
**Responsable:** GitHub Copilot (preparación) → Owner (credenciales reales)

### Status de la ejecución
1. ✅ **Rama creada:** `feat/fase7-wp-connection`
2. ✅ **Preparación de variables/secrets:** Completada
3. ✅ **Ajuste de workflows:** Completada (mode=placeholder|real añadido)
4. ✅ **Documentación:** Completada (README.md sección Fase 7)
5. ⏳ **PR abierto:** Pendiente (crear via GitHub UI o gh CLI)
6. ⏳ **Carga de credenciales (Owner):** **PENDIENTE**
7. ⏳ **Ejecución de verify-*:** **PENDIENTE CREDENCIALES**
8. ⏳ **Cierre y merge:** Pendiente

---

## 🔐 Carga de credenciales por el Owner

**Estado actual:** ⏳ **PENDIENTE**

El siguiente paso requiere que el **owner del repositorio** cargue las credenciales reales en GitHub Actions.

### Instrucciones para el owner
1. **`WP_BASE_URL`** → Crear como **Variable** en `repo → Settings → Secrets and variables → Actions → Variables`
   - Valor: URL real del sitio WordPress (ej: `https://tu-wp.com`)
   - Estado: [ ] Cargada por el owner
   
2. **`WP_USER`** → Crear como **Secret** en `repo → Settings → Secrets and variables → Actions → Secrets`
   - Valor: Usuario de GitHub Actions (ej: `github-actions`)
   - Estado: [ ] Cargada por el owner
   
3. **`WP_APP_PASSWORD`** → Crear como **Secret** en `repo → Settings → Secrets and variables → Actions → Secrets`
   - Valor: Application Password generada en WordPress
   - ⚠️ **CRÍTICO:** No exponer este valor en commits, logs ni comentarios. GitHub lo enmascara automáticamente.
   - Estado: [ ] Cargada por el owner

---

## 📍 Contexto y objetivo

La Fase 7 marca la transición del modo placeholder a la conexión real con un sitio WordPress operativo.  
Su propósito es reemplazar las credenciales dummy por valores reales, validar la autenticación (Auth = OK) y activar la generación automática de Issues de monitorización y alertas.  
Esta fase continúa directamente desde la Fase 6 (documentada en `082_reestructuracion_local.md` y `CIERRE_AUTOMATIZACION_TOTAL.md`).

### Referencias cruzadas
- [CIERRE_AUTOMATIZACION_TOTAL.md](../docs/CIERRE_AUTOMATIZACION_TOTAL.md)
- [DEPLOY_RUNBOOK.md](../docs/DEPLOY_RUNBOOK.md)
- [PROBLEMA_pages_functions_preview.md](../_reports/PROBLEMA_pages_functions_preview.md)
- [Bitácora 082 — Reestructuración Local](../apps/briefing/docs/internal/briefing_system/ci/082_reestructuracion_local.md)
- [📋 Reporte de Ejecución Fase 7](../_reports/FASE7_EJECUCION_CONEXION_WP_REAL_20251020.md)

---

## ✅ Checklist Fase 7 — Conexión WordPress Real

### 1. Instancia WordPress
- [ ] Levantar sitio WP (vacío o demo)  
- [ ] Habilitar REST API  
- [ ] Crear usuario `github-actions` (con rol Editor o similar)  
- [ ] Generar Application Password para GitHub Actions  

### 2. Configuración de Secrets en GitHub
- [ ] Actualizar `WP_BASE_URL` con URL real  
- [ ] Actualizar `WP_USER` con usuario real  
- [ ] Actualizar `WP_APP_PASSWORD` con contraseña de aplicación  

### 3. Validación de Conectividad
- [ ] Ejecutar `verify-home` (Auth OK esperado)  
- [ ] Ejecutar `verify-settings` (Auth OK esperado)  
- [ ] Ejecutar `verify-menus` (Auth OK esperado)  
- [ ] Ejecutar `verify-media` (Auth OK esperado)  

### 4. Validación de Alertas
- [ ] Confirmar creación automática de Issues en caso de KO/Drift  
- [ ] Verificar cierre automático de Issues al volver a OK  

### 5. Documentación Final
- [ ] Registrar URL real del sitio WP en `README.md`  
- [ ] Actualizar `CHANGELOG.md` con la entrada de integración WordPress  
- [ ] Adjuntar artefactos *_summary.txt con Auth = OK  

---

## ⚙️ Notas operativas

- Mantener los workflows `verify-*` en cron según Fase 6 (6h/12h/24h).  
- Los artefactos reales con Auth = OK serán la evidencia oficial de conexión.  
- GitHub enmascara automáticamente los secrets.  
- Se deben usar tokens con permisos mínimos (lectura de API).  
- En caso de error Auth=KO, revertir a placeholders para mantener el CI estable.

---

## 🧩 Validación y QA

- [ ] Confirmar que los workflows detectan Auth=OK sin errores.  
- [ ] Verificar cierre automático de Issues.  
- [ ] Documentar resultado en `082_reestructuracion_local.md` (Fase 7).  

---

## 📄 Historial y seguimiento

- **Fase previa:** Fase 6 — Verificación Integral (Local/Placeholder)  
- **Fase actual:** Fase 7 — Conexión WordPress Real  
- **Fase siguiente:** Fase 8 — Automatización de contenidos y dashboard de métricas  

---

## ✍️ Observaciones de inicio

- CI totalmente operativo en modo placeholder (ver `CIERRE_AUTOMATIZACION_TOTAL.md`).  
- Workflows y alertas listos para transicionar a Auth real.  
- Esta fase implica exposición controlada de credenciales reales y primer test end-to-end con WordPress vivo.  

---

## 📋 Resumen de ítems del checklist

Total de tareas: **16 ítems**

| Sección | Ítems | Descripción |
|---------|-------|-------------|
| Instancia WordPress | 4 | Configuración inicial del sitio WP y credenciales |
| Configuración de Secrets | 3 | Integración de credenciales reales en GitHub |
| Validación de Conectividad | 4 | Ejecución de verificaciones de Auth = OK |
| Validación de Alertas | 2 | Confirmación de generación/cierre automático de Issues |
| Validación y QA | 3 | Validación integral y documentación final |

---

## 📌 Próximos pasos

1. **Implementación:** Proceder con los pasos 1-5 del checklist en orden secuencial.
2. **Validación:** Ejecutar todas las verificaciones y documentar resultados.
3. **Cierre:** Actualizar el estado a ✅ Completado cuando todos los ítems estén marcados.
4. **Transición:** Avanzar a Fase 8 — Automatización de contenidos y dashboard de métricas.

---

**Issue #50 creado e integrado, listo para iniciar la Fase 7 (Conexión WordPress Real).**
