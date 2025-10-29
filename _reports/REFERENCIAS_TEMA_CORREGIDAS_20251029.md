# Normalización de Referencias de Tema — 2025-10-29

**Objetivo:** Alinear documentación y scripts al canon "RunArt Base" (`runart-base`) en modo solo lectura, sin tocar el servidor.

---

## 📋 Alcance de la Normalización

### Documentación y Reportes
- Actualizar referencias de `runart-theme` a **RunArt Base** (`runart-base`) donde corresponda
- Fijar canon oficial en toda la documentación técnica
- Mantener evidencia histórica del child theme para trazabilidad

### Scripts Locales
- Forzar `THEME_SLUG=runart-base` en loader y deploy scripts
- Congelar despliegues: `READ_ONLY=1` y `DRY_RUN=1` por defecto
- Añadir soporte `SKIP_SSH=1` para CI y documentación

### CI Guardrails
- Añadir guardas para evitar deployments accidentales
- Exigir etiqueta `media-review` para cambios en biblioteca de medios
- Validar flags de seguridad en deploy scripts

---

## 🔧 Cambios Realizados

### 1. tools/staging_env_loader.sh

**Modificaciones:**
- Forzado `THEME_SLUG="runart-base"` (ignora valores previos)
- Export de `THEME_PATH` calculado automáticamente
- Defaults: `READ_ONLY=1`
- Soporte `SKIP_SSH=1` para CI/documentación sin conexión real
- Guía actualizada con ruta canónica de WP y tema

**Justificación:**
- Garantizar consistencia de canon en todas las cargas de entorno
- Prevenir deployments accidentales con flags de seguridad
- Permitir validación de scripts en CI sin conectar a servidor

### 2. tools/deploy_wp_ssh.sh

**Modificaciones:**
- Marcador `CI-GUARD: DRY-RUN-CAPABLE` en header
- Defaults: `READ_ONLY=1` y `DRY_RUN=1`
- rsync añade `--dry-run` automáticamente cuando flags activos
- Operaciones mutadoras omitidas con `READ_ONLY=1`:
  - Backup remoto
  - `wp rewrite flush`
  - `wp cache flush`
  - Publicación de páginas
- Resumen incluye flags `READ_ONLY` y `DRY_RUN`

**Justificación:**
- Congelar operaciones por defecto hasta aprobación explícita
- Mantener trazabilidad de qué acciones se omiten
- Permitir CI verificar capacidad de dry-run

### 3. _reports/IONOS_STAGING_THEME_CHECK_20251029.md

**Modificaciones:**
- Reorientado a canon **RunArt Base**
- Conserva evidencia actual del child `runart-theme`
- Añadidas rutas canónicas para verificación
- Comandos actualizados para apuntar a `runart-base`

**Justificación:**
- Establecer canon documental claro
- Mantener evidencia del estado actual sin modificarlo
- Facilitar futura alineación con procedimientos correctos

### 4. docs/Deployment_Master.md

**Modificaciones:**
- Sección nueva: **"🧱 Canon Actual y Operación Congelada"**
- Detalles del tema oficial (nombre, slug, ruta)
- Flags de operación (READ_ONLY, DRY_RUN, SKIP_SSH)
- Políticas de staging y deployment
- Enlaces a reportes de evidencia

**Justificación:**
- Centralizar información canónica en documento maestro
- Hacer explícitas las políticas de congelación
- Proporcionar enlaces a evidencia y procedimientos

### 5. docs/_meta/governance.md

**Modificaciones:**
- Sección nueva: **"Políticas de Staging y Deployment"**
- Canon del tema documentado
- Operación congelada (freeze policy)
- CI guardrails explicados
- Deployment policy formalizado

**Justificación:**
- Integrar políticas técnicas en documento de gobernanza
- Establecer reglas claras para equipo
- Documentar CI guardrails para futuras modificaciones

### 6. .github/workflows/guard-deploy-readonly.yml (NUEVO)

**Jobs:**

**a) dryrun-guard:**
- Verifica existencia de `tools/deploy_wp_ssh.sh`
- Valida marcador `CI-GUARD: DRY-RUN-CAPABLE`
- Verifica defaults `READ_ONLY=${READ_ONLY:-1}` y `DRY_RUN=${DRY_RUN:-1}`

**b) media-guard:**
- Detecta cambios en `wp-content/uploads/`, `runmedia/`, `content/media/`
- Falla PR si toca media sin etiqueta `media-review`
- Usa `actions/github-script@v7` para verificación

**Justificación:**
- Prevenir deployments accidentales en PRs
- Proteger biblioteca de medios de cambios no revisados
- Automatizar validación de políticas de seguridad

### 7. _reports/TEMA_ACTIVO_STAGING_20251029.md (NUEVO)

**Contenido:**
- Canon documental: RunArt Base
- Evidencia actual: child theme referenciado
- Estructura de temas en staging
- Archivos clave del canon
- Operación congelada (flags activos)
- Verificación HTTP completa
- Procedimiento de alineación futura (no ejecutado)

**Justificación:**
- Documento formal de estado del tema
- Evidencia de verificación sin modificaciones
- Guía para futura alineación aprobada

### 8. _reports/REFERENCIAS_TEMA_CORREGIDAS_20251029.md (ESTE ARCHIVO)

Inventario completo de cambios de normalización.

---

## 📊 Archivos con Referencias Históricas (No Modificados)

Los siguientes archivos mantienen referencias a `runart-theme` como evidencia histórica:

### Reportes de Exploración y Evidencia
- `_reports/IONOS_STAGING_EXPLORATION_20251029.md` (evidencia del child activo)
- `_reports/RESUMEN_EJECUTIVO_TAREA2_20251029.md` (status histórico)
- `_reports/ACTUALIZACION_MAIN_20251029.md` (log de actividades)
- `_reports/inventario_base_imagenes_runmedia.md` (referencias de assets)
- `_reports/STATUS_DEPLOYMENT_SSH_20251028.md` (deploy anterior)

### Documentación Legacy y Live
- `docs/RESUMEN_FASE_VISUAL_UIUX_COMPLETA.md` (fase UI/UX histórica)
- `docs/live/FLUJO_CONSTRUCCION_WEB_RUNART.md` (flujo de construcción original)

**Razón para mantener:**
- Trazabilidad histórica de decisiones
- Evidencia de estado real del servidor
- Documentación de fases previas

**Acción futura:**
- Marcar como `status: archived` cuando se complete alineación
- Mover a `docs/archive/` tras cierre de fase

---

## 🎯 Estado Final

### Canon Establecido
- ✅ Tema oficial: **RunArt Base** (`runart-base`)
- ✅ Ruta canónica: `/homepages/7/d958591985/htdocs/staging/wp-content/themes/runart-base/`
- ✅ Documentación alineada en docs/ y _reports/

### Operación Congelada
- ✅ `READ_ONLY=1` por defecto en scripts
- ✅ `DRY_RUN=1` por defecto en deploy
- ✅ `SKIP_SSH=1` soportado para CI
- ✅ Operaciones mutadoras deshabilitadas

### CI Actualizado
- ✅ Dry-run guard activo
- ✅ Media review guard activo
- ✅ Validación automática en PRs (main/develop)

### Servidor Staging
- ✅ Sin modificaciones (congelado)
- ✅ Evidencia actual documentada
- ✅ Procedimiento de alineación preparado (pendiente aprobación)

---

## 📝 Archivos de Evidencia Generados

1. `_reports/TEMA_ACTIVO_STAGING_20251029.md` — Estado y canon del tema
2. `_reports/REFERENCIAS_TEMA_CORREGIDAS_20251029.md` — Este inventario
3. `_reports/CI_FREEZE_POLICY_20251029.md` — Políticas CI (próximo)

---

## 🚀 Próximos Pasos (No Ejecutados)

### Validación CI
- [ ] Push a branch `chore/canon-runart-base-freeze-ops`
- [ ] Esperar ejecución de workflows
- [ ] Confirmar PASS en:
  - `guard-deploy-readonly.yml` (dry-run + media)
  - `structure-guard.yml` (estructura)
  - `docs-lint.yml` (lint de docs)

### Alineación Futura (Bajo Aprobación)
- [ ] Issue aprobado con ventana de mantenimiento
- [ ] SSH key configurado (bloqueador actual)
- [ ] Backup previo del child theme
- [ ] Ejecutar `wp theme activate runart-base`
- [ ] Smoke tests post-cambio (12 rutas ES/EN)
- [ ] Documentar cambio en `_reports/`

### Documentación Post-Alineación
- [ ] Actualizar evidencia en reportes históricos
- [ ] Marcar docs legacy como `status: archived`
- [ ] Mover a `docs/archive/YYYY-MM/`

---

## ✅ Criterio de Éxito

- [x] Ningún archivo del servidor modificado
- [x] Documentación alineada al canon RunArt Base
- [x] CI y governance activos para impedir cambios accidentales
- [x] Scripts en modo seguro por defecto (READ_ONLY + DRY_RUN)
- [x] Evidencia del estado actual preservada
- [x] Procedimiento de alineación documentado

---

**Timestamp:** 2025-10-29T19:30:00Z  
**Autor:** GitHub Copilot + Equipo Técnico  
**Contexto:** Normalización documental canon RunArt Base  
**Servidor:** Sin modificaciones (operación congelada)
