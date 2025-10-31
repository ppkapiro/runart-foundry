# Plan Maestro Final — FASE 4.B
## Backend Editable con Dataset Completo

**Fecha:** 2025-10-31  
**Rama:** `feat/ai-visual-implementation`  
**Autor:** automation-runart  
**Fase anterior:** FASE 4.A (Informe Global + Endpoints Export)

---

## 1. Estado actual consolidado

### ✅ Completado en FASE 4.A

1. **Informe Global Unificado**
   - `informe_global_ia_visual_runart_foundry.md` (raíz)
   - Copia en `_reports/FASE4/INFORME_GLOBAL_IA_VISUAL_RUNART_FOUNDRY.md`
   - Consolidación de: endpoints, datasets, arquitectura, brechas y recomendaciones

2. **Endpoints REST de Export Seguro (admin-only)**
   - `GET /wp-json/runart/v1/export-enriched?format={full|index-only}`
   - `GET /wp-json/runart/v1/media-index?include_meta={true|false}`
   - Implementados en `class-rest-api.php`
   - Cascada de búsqueda: uploads-enriched → wp-content → uploads → plugin

3. **Script de Sincronización Python**
   - `tools/sync_enriched_dataset.py`
   - Funciones: backup automático, validación JSON, guardado en `data/assistants/rewrite/`, generación de reporte
   - Uso: `python tools/sync_enriched_dataset.py --staging-url URL [--auth-token TOKEN] [--format full]`

4. **UI Backend Editable Básica**
   - Nueva clase: `class-admin-editor.php`
   - Assets: `admin-editor.css`, `admin-editor.js`
   - Funcionalidades implementadas:
     - Listado de contenido con búsqueda y filtros por estado
     - Editor inline con preview lado a lado (ES/EN)
     - Página de export/import con sincronización AJAX
     - Estadísticas y metadatos de cada entrada
   - Menú: "IA-Visual" en admin WordPress (capability: `edit_posts`)

5. **Verificación REST Staging**
   - Dataset real `uploads/runart-jobs/enriched/index.json`: NOT_FOUND_IN_STAGING
   - Sistema operando con dataset de ejemplo (3 ítems)

### 🔄 Pendiente (próximos pasos)

- **Recuperación del dataset real:** Coordinar con admin para acceso vía export REST o SFTP
- **Normalización:** Aplicar plan de migración (`_reports/plan_migracion_normalizacion.md`)
- **Activación de cascada ampliada:** Habilitar Opción B (wp-content/uploads/runart-jobs/enriched como 4ª fuente)
- **Persistencia de ediciones:** Implementar guardado real (actualmente mock) con backups y locks
- **Audit log:** Registrar quién editó qué y cuándo
- **Tests de integración:** Validar flujo completo con dataset real

---

## 2. Roadmap hacia Backend Completo

### Milestone 1: Recuperación del Dataset Real (Prioridad Alta)
**Objetivo:** Obtener el dataset completo enriched desde prod/staging.

**Acciones:**
1. Ejecutar solicitud al admin según `_reports/lista_acciones_admin_staging.md`:
   - Confirmar ruta exacta de `uploads/runart-jobs/enriched/index.json` en prod
   - Verificar permisos de lectura en staging
   - Habilitar endpoint de export temporal (admin-only) o proporcionar export manual
2. Una vez disponible el endpoint:
   ```bash
   python tools/sync_enriched_dataset.py \
     --staging-url https://staging.runartfoundry.com/ \
     --auth-token <ADMIN_TOKEN> \
     --format full
   ```
3. Validar integridad del dataset sincronizado:
   - Verificar `data/assistants/rewrite/index.json`
   - Contar páginas individuales (esperado: >3)
   - Ejecutar `tools/fase3e_verify_rest.py` localmente si el plugin está activo

**Responsables:** Admin staging + equipo dev  
**Duración estimada:** 1-3 días (depende de coordinación)

---

### Milestone 2: Normalización y Activación de Cascada Ampliada
**Objetivo:** Integrar dataset real en la cascada de lectura con feature flag.

**Acciones:**
1. Implementar normalización según `_reports/plan_migracion_normalizacion.md`:
   - Script Python para validar y convertir formato si necesario
   - Backup obligatorio pre-normalización
   - Verificación post-normalización (schema, counts, idiomas)
2. Activar Opción B en `class-data-layer.php`:
   - Añadir `uploads-enriched` como 4ª ruta en `get_data_bases()`
   - Feature flag: `define('RUNART_USE_UPLOADS_ENRICHED', true);` en `wp-config.php`
   - Logs de cascada para debugging
3. Tests:
   - Endpoint `/content/enriched-list` debe devolver dataset real (>3 ítems)
   - Endpoint `/v1/data-scan` debe reportar `dataset_real_status: FOUND_IN_STAGING`
   - Shortcode `[runart_ai_visual_list]` debe renderizar dataset real

**Responsables:** Dev team  
**Duración estimada:** 2-5 días

---

### Milestone 3: Persistencia de Ediciones y Backups
**Objetivo:** Habilitar guardado real de ediciones con backups automáticos.

**Acciones:**
1. Implementar lógica en `ajax_save_enriched()` (actualmente mock):
   - Validar permisos (`edit_posts` + ownership si aplica)
   - Crear backup timestamped antes de escribir
   - Guardar cambios en archivo JSON correspondiente
   - Actualizar `index.json` si cambia metadata (título, estado, etc.)
   - Devolver confirmación con diff de cambios
2. Implementar sistema de locks/concurrencia:
   - Archivo `.lock` temporal al abrir editor
   - Timeout de 15 minutos o liberación manual
   - Advertencia si otro usuario está editando
3. Implementar audit log:
   - Tabla custom `wp_runart_audit_log` o archivo JSON `_logs/audit_ia_visual.json`
   - Campos: timestamp, user_id, action (edit/delete/export), page_id, diff_summary
   - Vista de audit log en admin (filtros por usuario/fecha)
4. Tests:
   - Editar contenido ES/EN, guardar, recargar y verificar cambios persistidos
   - Probar lock: abrir mismo contenido en dos sesiones
   - Verificar entrada en audit log

**Responsables:** Dev team  
**Duración estimada:** 3-7 días

---

### Milestone 4: Enriquecimiento de UI y UX
**Objetivo:** Mejorar experiencia de editor con funciones avanzadas.

**Acciones:**
1. **Preview en tiempo real:**
   - Renderizar Markdown/HTML enriquecido en panel derecho
   - Sincronización automática cada 2 segundos (debounced)
2. **Editor Markdown con toolbar:**
   - Botones: negrita, cursiva, listas, enlaces, imágenes
   - Inserción de visual_references existentes vía dropdown
3. **Gestión de imágenes inline:**
   - Modal para seleccionar medias de biblioteca WP
   - Arrastrar y soltar para reordenar visual_references
   - Actualizar confianza/alt de cada referencia
4. **Exportar página individual:**
   - Botón "Exportar como JSON" en modal de edición
   - Descargar archivo `page_XX.json` del contenido actual
5. **Bulk actions:**
   - Selección múltiple en listado principal
   - Acciones: cambiar estado (aprobar/rechazar en lote), exportar selección
6. **Búsqueda avanzada:**
   - Filtro por idioma, rango de fechas de edición, autor
   - Full-text search en contenido enriquecido (si dataset es <1000 páginas)

**Responsables:** Dev team + UX/UI feedback  
**Duración estimada:** 5-10 días

---

### Milestone 5: Tests de Integración y QA Final
**Objetivo:** Validar flujo completo y preparar para producción.

**Acciones:**
1. **Test de sincronización:**
   - Ejecutar sync desde staging con token admin
   - Verificar dataset descargado, validar schema, contar páginas
   - Probar rollback a backup en caso de error
2. **Test de edición:**
   - Crear, editar, eliminar contenido enriquecido
   - Verificar persistencia y backups
   - Validar audit log
3. **Test de permisos:**
   - Probar acceso con roles: admin, editor, author, subscriber
   - Verificar capability checks en endpoints REST y admin UI
4. **Test de carga:**
   - Simular dataset grande (100+ páginas)
   - Medir tiempos de respuesta de listado y búsqueda
   - Optimizar queries si es necesario (paginación, caché)
5. **Test de compatibilidad:**
   - WordPress 6.0+, PHP 7.4+, 8.0+
   - Temas: RunArt Base y otros genéricos
   - Plugins comunes: Yoast SEO, ACF, etc.
6. **Documentación de usuario:**
   - Guía rápida para editores (captura de pantalla, instrucciones paso a paso)
   - FAQ: cómo sincronizar, cómo editar, cómo exportar
   - Troubleshooting: errores comunes y soluciones

**Responsables:** QA + Dev team  
**Duración estimada:** 3-5 días

---

## 3. Activación en Producción

### Pre-requisitos
- [ ] Dataset real sincronizado y validado
- [ ] Backend editable testeado en staging con dataset real
- [ ] Audit log funcional
- [ ] Backups automáticos confirmados
- [ ] Permisos y seguridad revisados
- [ ] Documentación de usuario publicada

### Procedimiento de Deploy

1. **Backup completo de prod:**
   - Base de datos: `wp db export`
   - Archivos wp-content: `tar czf wp-content-backup-$(date +%Y%m%d).tar.gz wp-content/`
   - Dataset actual: `cp -r wp-content/runart-data wp-content/runart-data.bak`

2. **Deploy del plugin:**
   - Subir nuevo ZIP de `runart-ia-visual-unified` (versión 2.1.0+)
   - Activar plugin en prod
   - Verificar `/wp-admin/admin.php?page=runart-ia-visual-editor` accesible

3. **Sincronización inicial:**
   - Ejecutar sync script desde entorno seguro con token admin:
     ```bash
     python tools/sync_enriched_dataset.py \
       --staging-url https://runartfoundry.com/ \
       --auth-token <PROD_ADMIN_TOKEN> \
       --format full
     ```
   - Validar count de páginas y contenido

4. **Activación de cascada ampliada:**
   - Añadir en `wp-config.php` (si procede):
     ```php
     define('RUNART_USE_UPLOADS_ENRICHED', true);
     ```
   - Verificar endpoint `/wp-json/runart/v1/data-scan` reporta dataset real encontrado

5. **Verificación post-deploy:**
   - Probar edición de contenido desde admin
   - Verificar shortcode en frontend
   - Revisar logs de errores PHP/WP
   - Probar export/import
   - Verificar audit log funcional

6. **Rollback plan (si falla):**
   - Desactivar plugin
   - Restaurar backup de dataset: `mv wp-content/runart-data.bak wp-content/runart-data`
   - Restaurar DB si hubo cambios: `wp db import backup.sql`
   - Revisar logs y reportar issues

---

## 4. Mantenimiento Post-Activación

### Tareas periódicas
- **Semanal:**
  - Revisar audit log para detectar anomalías
  - Verificar tamaño de backups (rotar si >1GB acumulado)
- **Mensual:**
  - Sincronizar dataset desde prod para repo local (desarrollo)
  - Revisar performance de endpoints (tiempos de respuesta)
  - Actualizar documentación si hay cambios

### Monitorización
- **Métricas clave:**
  - Número de ediciones/semana
  - Tamaño del dataset (número de páginas)
  - Tiempo promedio de carga del listado
  - Errores en logs de audit
- **Alertas:**
  - Si dataset no sincroniza por >7 días
  - Si backups superan 5GB sin rotación
  - Si tiempo de respuesta de listado >3s

### Evolución futura (FASE 5+)
- **Integración con pipelines IA:**
  - Botón "Regenerar con IA" para solicitar reescritura automática
  - Preview de cambios IA antes de aplicar
- **Versionado de contenido:**
  - Sistema de versiones con diff visual (similar a Git)
  - Restaurar versión anterior de contenido
- **API pública (opcional):**
  - Endpoint público `GET /wp-json/runart/v1/public/enriched` (read-only)
  - Webhook para notificar cambios a sistemas externos
- **Multi-idioma ampliado:**
  - Soporte para más idiomas (FR, DE, IT)
  - Traducción asistida con IA

---

## 5. Documentos de referencia

- `informe_global_ia_visual_runart_foundry.md` — Estado actual del sistema
- `_reports/informe_origen_completo_datos_ia_visual.md` — Consolidado de orígenes
- `_reports/propuesta_backend_editable.md` — Diseño del backend
- `_reports/plan_migracion_normalizacion.md` — Plan de normalización
- `_reports/lista_acciones_admin_staging.md` — Solicitudes al admin
- `tools/sync_enriched_dataset.py` — Script de sincronización
- `tools/runart-ia-visual-unified/includes/class-admin-editor.php` — Implementación UI
- `PLAN_MAESTRO_IA_VISUAL_RUNART.md` — Plan maestro original (F7-F10)

---

## 6. Resumen ejecutivo

**Objetivo final:** Backend editable completamente funcional con dataset real integrado, permitiendo a editores y admins gestionar contenido enriquecido bilingüe con respaldos automáticos, audit log y sincronización desde staging/prod.

**Tiempo total estimado:** 14-30 días (según disponibilidad de dataset real y recursos de desarrollo).

**Prioridad inmediata:** Milestone 1 (Recuperación del Dataset Real) — sin dataset real, los siguientes milestones quedan bloqueados o limitados a testing con mock data.

**Estado actual:** FASE 4.A completada; sistema listo para recibir dataset real y avanzar a Milestone 2 (normalización e integración).

---

**Fin del Plan Maestro Final — FASE 4.B**

Este documento será actualizado conforme avancen los milestones y se identifiquen ajustes necesarios.
