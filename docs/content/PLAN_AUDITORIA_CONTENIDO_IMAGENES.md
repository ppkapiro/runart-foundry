# Plan Maestro — Auditoría de Contenido e Imágenes (v2)

**Fecha de creación:** 2025-10-29  
**Versión:** 2.0  
**Estado:** ACTIVO  
**Canon del tema:** RunArt Base (runart-base)

---

## Alcance

Esta auditoría cubre **5 fases secuenciales** para evaluar y optimizar el contenido textual e imágenes del sitio RunArt Foundry:

### Fase 1: Inventario de Páginas (ES/EN)
- Catalogar todas las páginas del sitio
- Identificar páginas por idioma (español/inglés)
- Detectar gaps de traducción
- Clasificar por tipo (landing, servicios, institucional, blog, portfolio)

### Fase 2: Inventario de Imágenes (Media Library)
- Listar todos los archivos en `wp-content/uploads/`
- Analizar theme assets en `runart-base/assets/images/`
- Clasificar por formato (WebP, JPG, PNG, GIF, SVG)
- Identificar imágenes >1MB (optimización)
- Detectar imágenes sin uso (eliminar)
- Validar alt text (accesibilidad)

### Fase 3: Matriz Texto ↔ Imagen
- Analizar balance texto/imagen por página
- Calcular ratios palabras/imagen (target: 50-200:1)
- Identificar páginas con exceso de texto (>200:1)
- Identificar páginas con exceso de imágenes (<50:1)
- Validar coherencia mensaje textual vs visual

### Fase 4: Reporte de Brechas Bilingües
- Detectar páginas sin traducción (solo ES o solo EN)
- Identificar traducciones parciales (<90% completitud)
- Localizar imágenes con texto hardcoded sin traducir
- Validar elementos UI bilingües (menús, widgets, formularios)
- Priorizar gaps por impacto (alta/media/baja)

### Fase 5: Plan de Acción y Cierre
- Consolidar hallazgos de F1-F4
- Priorizar acciones correctivas
- Estimar recursos (horas, costos)
- Definir timeline de implementación
- Generar KPIs de calidad

---

## Entregables por Fase

| Fase | Entregable | Ubicación | Criterio de Aceptación |
|------|-----------|-----------|------------------------|
| **F1** | Inventario de Páginas | `research/content_audit_v2/01_pages_inventory.md` | 100% páginas catalogadas, sin "TBD" |
| **F2** | Inventario de Imágenes | `research/content_audit_v2/02_images_inventory.md` | 100% imágenes catalogadas, metadata completo |
| **F3** | Matriz Texto↔Imagen | `research/content_audit_v2/03_texts_vs_images_matrix.md` | Ratios calculados para todas las páginas |
| **F4** | Brechas Bilingües | `research/content_audit_v2/04_bilingual_gap_report.md` | Gaps priorizados, estimaciones completas |
| **F5** | Plan de Acción | `research/content_audit_v2/05_next_steps.md` | Acciones priorizadas, recursos estimados |

**Evidencias adicionales:**
- Cada fase debe generar un reporte complementario en `_reports/FASE_X_EVIDENCIA_YYYYMMDD.md`
- Capturas/logs de WP-CLI queries en `_tmp/` (no commitear, solo referencia)

---

## Criterios de Aceptación Global

### Por Entregable
- ✅ Tablas completas, sin celdas "TBD" o "Por identificar" pendientes
- ✅ Metadata completo (fechas, URLs, tamaños, etc.)
- ✅ Resumen estadístico actualizado
- ✅ Evidencias adjuntas en `_reports/`

### Por Fase
- ✅ CI checks en verde (linting, structure validation)
- ✅ Revisado por 1 revisor (runart-admin) o label `ready-for-review` + CI OK
- ✅ Entrada en Bitácora con estado "COMPLETADA"
- ✅ PR mergeado a `develop` (según política de merge)

### Cierre de Auditoría (F5)
- ✅ 100% páginas inventariadas (ES/EN)
- ✅ 100% imágenes inventariadas con clasificación
- ✅ 100% matriz texto↔imagen cubierta
- ✅ 100% brechas bilingües detectadas + plan de corrección
- ✅ Plan de acción con timeline y recursos estimados
- ✅ Todos los PRs F1-F5 mergeados a `develop`
- ✅ PR de release `release/content-audit-v2` abierto hacia `main`

---

## Flujo de Ramas (Strategy)

### Estructura de Ramas
```
main (producción estable)
  ↑
  └── release/content-audit-v2 (release candidate)
        ↑
        └── develop (integración continua)
              ↑
              ├── feat/content-audit-v2-phase1 (F1) → PR #77
              ├── feat/content-audit-v2-phase2 (F2)
              ├── feat/content-audit-v2-phase3 (F3)
              ├── feat/content-audit-v2-phase4 (F4)
              └── feat/content-audit-v2-phase5 (F5)
```

### Política de Merge por Fase

**De fase → develop:**
- Merge commit (preservar historial de cada fase)
- Autorizado cuando:
  1. Bitácora marca fase como "COMPLETADA"
  2. CI en verde
  3. Sin conflictos con develop
  4. Al menos 1 review aprobado O label `ready-for-merge`

**De develop → release → main:**
- Después de F5 completada
- Release PR con changelog completo
- Review obligatorio de 2+ maintainers
- Squash merge a main (consolidar auditoría en 1 commit)

---

## Gobernanza

### Políticas de Seguridad
- **READ_ONLY=1** / **DRY_RUN=1** activo por defecto
- **Sin staging writes** salvo autorización expresa
- **Sin SSH deployment** durante auditoría
- **Cambios en media** requieren label `media-review`
- **Deploy real** (no aplica aquí) requeriría label `deployment-approved`

### Freeze Policy
- Code freeze activo durante auditoría
- Solo permitidos:
  - Cambios en documentación (`docs/`, `_reports/`, `research/`)
  - Bugfixes críticos (con label `maintenance-window`)
  - Updates de gobernanza

### Labels Requeridas
- **documentation** — Cambios en docs
- **content-phase** — Relacionado con auditoría de contenido
- **ready-for-review** — Listo para revisión
- **ready-for-merge** — Autorizado para merge automático
- **area/docs** — Documentación y estructura
- **type/chore** — Mantenimiento

---

## Timeline Sugerido

| Fase | Días | Fechas Estimadas | Responsable |
|------|------|------------------|-------------|
| **F1** | 1-3 | 2025-10-29 a 2025-10-31 | Copilot Agent + runart-admin |
| **F2** | 4-6 | 2025-11-01 a 2025-11-03 | Copilot Agent + runart-admin |
| **F3** | 7-8 | 2025-11-04 a 2025-11-05 | Copilot Agent |
| **F4** | 9-10 | 2025-11-06 a 2025-11-07 | Copilot Agent |
| **F5** | 11 | 2025-11-08 | Copilot Agent + runart-admin |
| **Review & Release** | 12-13 | 2025-11-09 a 2025-11-10 | runart-admin |

**Total:** 13 días (2025-10-29 a 2025-11-10)

### Hitos Clave
- **Día 3:** F1 completada, PR #77 mergeado
- **Día 6:** F2 completada, 50% de auditoría
- **Día 8:** F3 completada, 75% de auditoría
- **Día 10:** F4 completada, 90% de auditoría
- **Día 11:** F5 completada, auditoría cerrada
- **Día 13:** Release a main

---

## KPIs de Cierre

### Cobertura
- [ ] 100% páginas inventariadas (target: 50+ páginas)
- [ ] 100% imágenes inventariadas (target: 200+ archivos)
- [ ] 100% análisis texto↔imagen completo
- [ ] 100% gaps bilingües documentados

### Calidad
- [ ] 0 páginas sin categorizar
- [ ] 0 imágenes sin clasificación de uso
- [ ] <5% páginas con ratio texto/imagen fuera de rango (50-200:1)
- [ ] <10% contenido sin traducción (target: 100% bilingüe)

### Optimización
- [ ] Identificar 20+ imágenes >1MB (candidatas a optimización)
- [ ] Identificar 10+ imágenes sin uso (candidatas a eliminar)
- [ ] Identificar 5+ páginas con desbalance texto/imagen
- [ ] Identificar 10+ gaps de traducción críticos

### Proceso
- [ ] 5/5 PRs de fases mergeados a develop
- [ ] 0 conflictos de merge
- [ ] 100% CI checks en verde
- [ ] 1 release PR abierto a main

---

## Reglas de Autorización de Merge

### Condiciones para Merge Automático (fase → develop)

**Copilot Agent está autorizado a mergear un PR de fase cuando:**

1. **Estado en Bitácora:** Fase marcada como "COMPLETADA" en `_reports/BITACORA_AUDITORIA_V2.md`
2. **CI Status:** Todos los checks en verde (linting, structure validation, tests)
3. **Conflictos:** Sin conflictos con `develop` (merge limpio)
4. **Review:** Al menos 1 de:
   - 1+ review aprobado por runart-admin u otro maintainer
   - Label `ready-for-merge` aplicado manualmente
   - Label `ready-for-review` + CI verde + 24h sin objeciones

**Proceso de Merge:**
1. Validar condiciones arriba
2. Ejecutar merge commit: `gh pr merge <PR> --merge`
3. Actualizar Bitácora: Añadir entrada "Fase X: Merge a develop — OK"
4. Cerrar labels asociados (`ready-for-review` → `merged`)
5. Notificar en comentario del PR: "✅ Merged to develop — See BITACORA for details"

**Excepciones (NO mergear si):**
- Comentarios de revisión solicitando cambios (request changes)
- Label `do-not-merge` o `hold` presente
- CI fallando en checks críticos
- Conflictos no resueltos

### Condiciones para Release PR (develop → main)

**Después de F5 completada:**
1. Crear `release/content-audit-v2` desde `develop`
2. Generar CHANGELOG con resumen de F1-F5
3. Abrir PR a `main` con:
   - Título: "release: Content Audit v2 Complete (5 phases)"
   - Labels: `release`, `documentation-complete`, `ready-for-review`
   - Review obligatorio: 2+ maintainers
4. **NO mergear automáticamente** — Esperar aprobación explícita de runart-admin

---

## Herramientas y Scripts

### Scripts Auxiliares

**Bitácora:**
- `tools/log/append_bitacora.sh` — Añadir entrada automática a bitácora
  ```bash
  bash tools/log/append_bitacora.sh "F1: Inventario completado" "PR #77 mergeado"
  ```

**WP-CLI Queries:**
- `tools/audit/query_pages.sh` — Listar páginas (F1)
- `tools/audit/query_media.sh` — Listar media library (F2)

**Validación:**
- `.github/workflows/content-audit-checks.yml` — CI checks para auditoría
  - Validar markdown syntax
  - Verificar tablas completas (no "TBD")
  - Validar referencias cruzadas

### Comandos Clave

**WP-CLI (Staging):**
```bash
# Páginas
ssh ... "cd staging && wp post list --post_type=page --format=csv"

# Media
ssh ... "cd staging && wp media list --format=csv"

# Word count
wp post get <ID> --field=post_content | wc -w
```

**Git:**
```bash
# Merge automático (cuando autorizado)
gh pr merge <PR> --merge --body "✅ Auto-merged by Copilot Agent (conditions met)"

# Actualizar bitácora
git add _reports/BITACORA_AUDITORIA_V2.md
git commit -m "docs: update bitácora (Fase X: COMPLETADA)"
```

---

## Referencias

### Documentos Relacionados
- `_reports/BITACORA_AUDITORIA_V2.md` — Bitácora iterativa (documento vivo)
- `_reports/CONTENT_AUDIT_INIT_20251029.md` — Inicialización de auditoría
- `_reports/CONTENT_READY_STATUS_20251029.md` — Verificación pre-auditoría
- `docs/_meta/governance.md` — Políticas de gobernanza
- `docs/Deployment_Master.md` — Deployment docs (referencia)

### PRs y Issues
- PR #77: `feat/content-audit-v2-phase1` (F1 en progreso)
- Issue #XX: Content Audit Master Tracking (crear si no existe)

### Plantillas
- `research/content_audit_v2/01_pages_inventory.md`
- `research/content_audit_v2/02_images_inventory.md`
- `research/content_audit_v2/03_texts_vs_images_matrix.md`
- `research/content_audit_v2/04_bilingual_gap_report.md`
- `research/content_audit_v2/05_next_steps.md`

---

## Control de Cambios

| Versión | Fecha | Cambios | Autor |
|---------|-------|---------|-------|
| 1.0 | 2025-10-29 | Versión inicial (plantillas) | Copilot Agent |
| 2.0 | 2025-10-29 | Plan Maestro + Bitácora + Política de Merge | Copilot Agent |

---

**Aprobado por:** runart-admin (pending)  
**Fecha de aprobación:** 2025-10-29 (pending)  
**Próxima revisión:** Post F5 (2025-11-08)

---

**Estado del Plan:** ✅ ACTIVO — Listo para ejecución de F1-F5
