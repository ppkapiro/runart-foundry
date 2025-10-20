# 🧾 Issue #50 — Checklist Fase 7 · Conexión WordPress Real

**Fecha de inicio:** 2025-10-20  
**Estado:** 🟡 En ejecución  
**Rama:** `feat/fase7-wp-connection`  
**Ubicación:** `issues/Issue_50_Fase7_Conexion_WordPress_Real.md`

---

## 🚀 Ejecución — Fase 7 (En progreso)

**Inicio de ejecución:** 2025-10-20 14:16 UTC  
**Responsable:** GitHub Copilot (preparación) → Owner (credenciales reales)

### 📊 Estado de Documentación (2025-10-20)
- ✅ RUNBOOK_FASE7_PREVIEW_PRIMERO.md (1,400+ líneas, 7 fases, comandos exactos)
- ✅ CHECKLIST_EJECUTIVA_FASE7.md (500 líneas, 8 partes, cajas ☐)
- ✅ QUICK_REFERENCE_FASE7.md (tarjeta de referencia, imprimible)
- ✅ FLOWCHART_FASE7.md (diagrama visual Mermaid + timeline)
- ✅ Automation scripts (fase7_collect_evidence.sh + fase7_process_evidence.py)
- ✅ Issue #50 referencias agregadas

### Status de la ejecución
1. ✅ **Rama creada:** `feat/fase7-wp-connection` → `feat/fase7-evidencias-auto` (rebase)
2. ✅ **Preparación de variables/secrets:** Completada
3. ✅ **Ajuste de workflows:** Completada (mode=placeholder|real añadido)
4. ✅ **Documentación operacional:** Completada (4 documentos + 1 flowchart)
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

### 📚 GUÍAS OPERACIONALES NUEVA (2025-10-20)
**¡Lee esto ANTES de ejecutar Fase 7!**
- **[🎯 QUICK REFERENCE — FASE 7 PREVIEW PRIMERO](../docs/QUICK_REFERENCE_FASE7.md)** ← **IMPRIME ESTO**
  * Comandos esenciales (SSH, DNS, BD, secrets, workflows)
  * Quick troubleshooting (tabla de errores/fix)
  * Timeline: 3.5-4.5 horas
  * Definition of Done (20+ items)
  
- **[📖 RUNBOOK OPERACIONAL COMPLETO — FASE 7 PREVIEW PRIMERO](../docs/RUNBOOK_FASE7_PREVIEW_PRIMERO.md)**
  * 7 Fases detalladas (Crear Staging → Validar → Promover → Cierre)
  * Fase 1: Crear Staging (45 min: DNS, HTTPS, Archivos, BD, Config, Usuario)
  * Fase 2: Cargar Secrets GitHub (5 min)
  * Fase 3: Ejecutar verify-* STAGING (20 min)
  * Fase 4: Documentar Staging (10 min)
  * Fase 5: Promover a PRODUCCIÓN (10 min) ⚠️
  * Fase 6: Validar PROD (20 min)
  * Fase 7: Cierre + Merge (20 min)
  * Rollback Plan (si falla staging o prod)
  * Troubleshooting tabla completa
  
- **[✅ CHECKLIST EJECUTIVA — FASE 7](../docs/CHECKLIST_EJECUTIVA_FASE7.md)**
  * 8 Partes con cajas ☐ verificables
  * Parte A: Preparación (10 min)
  * Parte B: Crear Staging (45 min, 7 subsecciones con comandos exactos)
  * Parte C: Cargar Secrets (5 min)
  * Parte D: Validar Staging (20 min)
  * Parte E: Documentar (10 min)
  * Parte F: Promover a PROD (10 min, triple checklist)
  * Parte G: Validar PROD (20 min)
  * Parte H: Cierre Documental (20 min)
  * Criterio de Éxito (20+ items verificables)
  * Troubleshooting rápido
  
- **[🔀 FLOWCHART VISUAL — FASE 7](../docs/FLOWCHART_FASE7.md)**
  * Diagrama Mermaid del flujo completo
  * Happy path vs error paths
  * Decision points (rollback triggers)
  * Timeline visual
  * Definition of Done

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

## � Verificación de Accesos — Fase 7 (Sin secretos)

**Ubicación:** `apps/briefing/docs/internal/briefing_system/integrations/wp_real/`

Esta sección documenta la **verificación integral** del estado actual antes de cargar credenciales reales. Todas las evidencias se recopilan **sin exponer secretos**.

### Estado de Verificación

#### Evidencias a recopilar por el Owner

- [ ] **Repo Access:** `git remote -v` output → `_templates/evidencia_repo_remotes.txt`
  - Remotes configurados (origin, upstream)
  - Branch actual
  - Workflows activos detectados

- [ ] **Local Mirror:** Árbol de `mirror/` directory → `_templates/` (referencia)
  - Qué activos se descargaron (DB dump, wp-content, etc.)
  - Checksums (si aplica)
  - Tamaño aproximado

- [ ] **SSH Connectivity:** Salidas sanitizadas del servidor → `_templates/evidencia_server_versions.txt`
  - `uname -a` (SO, kernel)
  - `php -v` (versión PHP, mínimo 7.4)
  - `nginx -v` o `apachectl -v` (servidor web)
  - `mysql --version` o `mariadb --version` (base de datos)

- [ ] **WP REST Readiness:** Información pública de WordPress → `_templates/evidencia_wp_cli_info.txt`
  - WordPress version (confirmar 5.6+ para Application Passwords)
  - Plugins instalados (nombre/versión)
  - Tema activo
  - Estado de Application Passwords

- [ ] **REST API Accesibilidad:** Validación de endpoints públicos → `_templates/evidencia_rest_sample.txt`
  - `/wp-json/` → HTTP 200 OK (REST API habilitado)
  - `/wp-json/wp/v2/users/me` → HTTP 401 sin auth (correcto)
  - `/wp-json/wp/v2/pages`, `/wp/v2/posts` → accesibles (públicos)
  - SSL certificate válido (HTTPS)

#### Documentos de referencia para el Owner

1. **`README.md`** (en carpeta wp_real)
   - Índice de documentos y flujo de uso
   - Checklist de completitud

2. **`000_state_snapshot_checklist.md`** (Central)
   - Qué evidencias se necesitan (resumen)
   - Matriz de accesos
   - Hallazgos consolidados (se rellena tras recibir evidencias)

3. **`010_repo_access_inventory.md`**
   - Qué datos esperar de `git remote -v`
   - Estructura de workflows
   - Variables/Secrets en GitHub

4. **`020_local_mirror_inventory.md`**
   - Qué se descargó del servidor
   - Tipos de activos (DB, uploads, temas, plugins)

5. **`030_ssh_connectivity_and_server_facts.md`**
   - Cómo capturar información del servidor (sanitizada)
   - Versiones mínimas recomendadas
   - Hardening checklist

6. **`040_wp_rest_and_authn_readiness.md`**
   - Endpoints a validar (sin credenciales)
   - Compatibilidad con Application Passwords
   - Notas de seguridad

7. **`050_decision_record_styling_vs_preview.md`** (ADR)
   - **3 opciones evaluadas:**
     - Opción 1: Styling Primero (~1 semana, riesgo 🟡 Medio-Alto)
     - Opción 2: Preview Primero (~2 semanas, riesgo 🟢 **BAJO — RECOMENDADA**)
     - Opción 3: Mixto Coordinado (~1.5 semanas, riesgo 🟡 Medio)
   - Owner debe elegir una opción

8. **`060_risk_register_fase7.md`** (Riesgos)
   - 10 riesgos identificados con matriz
   - R1 (Credenciales expuestas) — **YA MITIGADO**
   - R2-R10 (Otros riesgos y mitigaciones)
   - Checklist pre/durante/post ejecución

### Guía de Seguridad para Aportar Evidencias

**⚠️ NUNCA pegar en evidencias:**
- ❌ Contraseñas, tokens, Application Passwords
- ❌ Claves privadas (SSH, SSL)
- ❌ Datos de wp-config.php
- ❌ Authorization headers con credenciales

**✅ PUEDES pegar:**
- ✅ Output de `git remote -v` (sin credenciales)
- ✅ Output de `wp --version` (solo versión)
- ✅ Output de `uname -a`, `php -v` (solo versiones)
- ✅ Status HTTP y headers de `/wp-json/` (sin tokens)

Cada template en `_templates/evidencia_*.txt` incluye ejemplos de ✅ CORRECTO vs ❌ NO HAGAS.

### Acciones Copilot (después de recibir evidencias)

1. Revisar evidencias en `_templates/`
2. Consolidar hallazgos en `000_state_snapshot_checklist.md`
3. Validar estado de riesgos (actualizar `060_risk_register_fase7.md`)
4. Proponer decisión final en `050_decision_record_styling_vs_preview.md` con semáforo 🔴/🟡/🟢
5. Generar Plan de Siguiente Fase

---



Total de tareas: **16 ítems**

| Sección | Ítems | Descripción |
|---------|-------|-------------|
| Instancia WordPress | 4 | Configuración inicial del sitio WP y credenciales |
| Configuración de Secrets | 3 | Integración de credenciales reales en GitHub |
| Validación de Conectividad | 4 | Ejecución de verificaciones de Auth = OK |
| Validación de Alertas | 2 | Confirmación de generación/cierre automático de Issues |
| Validación y QA | 3 | Validación integral y documentación final |

---

## � Resultado Verificación de Accesos (Consolidado 2025-10-20)

**Status:** 🟡 **PENDIENTE EVIDENCIAS** (owner aún no ha aportado datos)

### Matriz de Estado

| Punto | Status | Evidencia | Siguiente Paso |
|------|--------|-----------|-----------------|
| **Repo (GitHub)** | ⏳ PENDIENTE | `evidencia_repo_remotes.txt` (vacío) | Owner pega `git remote -v` |
| **Local (Mirror)** | ⏳ PENDIENTE | Árbol de directorio | Owner describe descarga local |
| **SSH (Servidor)** | ⏳ PENDIENTE | `evidencia_server_versions.txt` (vacío) | Owner pega `uname -a`, `php -v`, `nginx -v` |
| **REST API** | 🔴 **CRÍTICO** | `evidencia_rest_sample.txt` (vacío) | Owner valida `/wp-json/` accesible |

### Interpretación Provisional

**Basado en contexto del proyecto (sin evidencias aún):**

- ✅ **Repo:** Enriquecido con modo detection, workflows listos
- ✅ **Local:** Mirror descargado (según arquitectura)
- ✅ **SSH:** Presumiblemente operativo
- ⏳ **REST API:** **BLOQUEADOR CRÍTICO** — Requiere validación real

### Decisión Recomendada

**🟢 ADR: OPCIÓN 2 — Preview Primero**

Razones:
1. Valida workflows contra WordPress real SIN exposición de prod
2. Riesgo BAJO: Staging es entorno "seguro"
3. Precedente: Buenas prácticas (Staging → Prod)
4. Reversible: Si falla, prod no se ve afectado

**Plan operativo:** Ver `070_preview_staging_plan.md`

### Inputs del Owner para Avanzar

**Acción 1: Validar REST API (INMEDIATO)**
```bash
# Desde navegador o terminal:
curl -i https://runalfondry.com/wp-json/
# Esperar: HTTP 200 OK o 401 (no 404 o 403)
```
- ✅ Si 200/401 → OK, continuar
- ❌ Si 404 → BLOQUEADOR, habilitар REST en WP-Admin
- ⚠️ Si 403 → Contactar admin, revisar WAF

**Acción 2: Preparar Staging (SI ELIGE OPCIÓN 2)**
- [ ] Hostname de staging: `https://<staging-hostname>` (ej: `staging.runalfondry.com`)
- [ ] Usuario WP técnico: `github-actions` (o similar)
- [ ] BD fresca importada
- [ ] `wp-content/` replicado (uploads, temas, plugins)
- [ ] REST API accesible en staging también

**Acción 3: Confirmar Decisión**
- [ ] ADR Opción elegida: **Preview primero** / Styling primero / Mixto
- [ ] Comentar en este Issue o en el PR

### Checklists Próximos

#### Owner — Hoy/Mañana
- [ ] Validar REST API (`curl /wp-json/`)
- [ ] Pegar evidencias en `_templates/evidencia_*.txt`
- [ ] Marcar checkboxes en sección "Evidencias" (arriba)
- [ ] Revisar ADR (`050_decision_record_styling_vs_preview.md`)
- [ ] Confirmar decisión (Preview / Styling / Mixto)

#### Si Opción 2 (Preview Primero) — Owner
- [ ] Preparar subdominio staging
- [ ] Copiar BD fresca
- [ ] Replicar archivos (wp-content)
- [ ] Crear usuario + Application Password en staging

#### Copilot — Post-Evidencias y Staging
- [ ] Ejecutar `verify-home` en staging (manual)
- [ ] Ejecutar `verify-settings` en staging
- [ ] Ejecutar `verify-menus` en staging
- [ ] Ejecutar `verify-media` en staging
- [ ] Adjuntar artifacts *_summary.txt en Issue
- [ ] Cambiar variables a producción
- [ ] Ejecutar workflows en producción
- [ ] Adjuntar artifacts finales
- [ ] ✅ Fase 7 COMPLETADA

---

## �📌 Próximos pasos



1. **Implementación:** Proceder con los pasos 1-5 del checklist en orden secuencial.
2. **Validación:** Ejecutar todas las verificaciones y documentar resultados.
3. **Cierre:** Actualizar el estado a ✅ Completado cuando todos los ítems estén marcados.
4. **Transición:** Avanzar a Fase 8 — Automatización de contenidos y dashboard de métricas.

---

**Issue #50 creado e integrado, listo para iniciar la Fase 7 (Conexión WordPress Real).**


## 📊 Resultado Verificación de Accesos (Consolidado 2025-10-20)

### Matriz de Estado

| Pilar | Estado | Semáforo | Evidencia | Próximo Paso |
|-------|--------|----------|-----------|-------------|
| Repo (GitHub) | OK | ✅ | git remote -v, remotes OK | ✅ Ready |
| Local (Mirror) | OK | ✅ | 760M disponible | ✅ Ready |
| SSH (Servidor) | PENDIENTE | ⏳ | No configurado | ⏳ Owner: exportar WP_SSH_HOST |
| REST API | PENDIENTE | ⏳ | DNS fallo (prod) | 🔴 Validar en staging |

### Interpretación

- **Repo:** ✅ LISTO — Remotes configurados, workflows enriquecidos
- **Local:** ✅ LISTO — Mirror de 760M presente
- **SSH:** ⏳ PENDIENTE — Owner proporciona credenciales
- **REST:** 🔴 CRÍTICO — Validar en staging/producción real

### Decisión Recomendada

**🟢 OPCIÓN 2 — Preview Primero (RECOMENDADA)**

Razones:
1. Valida workflows en staging antes de producción
2. Riesgo BAJO — entorno seguro
3. Permite identificar bloqueadores (como DNS)
4. Precedente: Buenas prácticas

### Inputs del Owner para Avanzar

- [ ] **Hoy:** Validar REST API en staging → `curl -i https://staging.example.com/wp-json/`
- [ ] **Hoy:** Exportar `WP_SSH_HOST="user@host"` → Copilot recolecta server info
- [ ] **Mañana:** Confirmar decisión en este Issue (Preview / Styling / Mixto)

### Checklists Próximos

**Owner — Inmediato:**
- [ ] Revisar matriz de estado arriba
- [ ] Proporcionar hostname de staging
- [ ] Exportar WP_SSH_HOST si aplica
- [ ] Confirmar decisión (Preview/Styling/Mixto)

**Copilot — Post-Owner:**
- [ ] Si Preview elegido → Ejecutar 070_preview_staging_plan.md
- [ ] Si Styling elegido → Aplicar cambios de tema
- [ ] Si Mixto elegido → Coordinar ambas fases
