# Próximos Pasos — Auditoría de Contenido e Imágenes (Fase 1)

**Fecha:** 2025-10-29  
**Estado:** ✅ PLANTILLAS CREADAS — Listo para iniciar auditoría  
**Modo:** READ_ONLY=1

---

## Resumen de Preparación

### ✅ Completado

1. **Estructura de auditoría creada:**
   - ✅ `01_pages_inventory.md` — Template para inventario de páginas
   - ✅ `02_images_inventory.md` — Template para inventario de imágenes
   - ✅ `03_texts_vs_images_matrix.md` — Template para análisis de balance
   - ✅ `04_bilingual_gap_report.md` — Template para gaps ES/EN
   - ✅ `05_next_steps.md` — Este archivo (plan de acción)

2. **Repositorio preparado:**
   - ✅ Canon confirmado: runart-base
   - ✅ Gobernanza operativa (PR template, labels, docs)
   - ✅ Secrets scan limpio
   - ✅ Rama feat/content-audit-v2-phase1 creada

3. **Herramientas validadas:**
   - ✅ WP-CLI disponible (staging)
   - ✅ SSH access configurado
   - ✅ Scripts de backup y auditoría operativos

### ⏳ Pendiente

1. **Pre-requisito crítico:**
   - ⏳ Verificar tema activo en staging (debe ser runart-base)
   - Comando: `ssh ... "wp theme list --status=active"`

2. **Inicio de auditoría:**
   - ⏳ Ejecutar inventario de páginas (01)
   - ⏳ Ejecutar inventario de imágenes (02)
   - ⏳ Análisis de balance texto/imagen (03)
   - ⏳ Análisis de gaps bilingües (04)

---

## Plan de Ejecución

### Fase 1.1: Pre-Flight Checks (Hoy)

**Tiempo estimado:** 30 minutos

#### Tareas:
1. ✅ Crear rama feat/content-audit-v2-phase1
2. ✅ Crear 5 plantillas en research/content_audit_v2/
3. ⏳ Verificar tema staging:
   ```bash
   ssh -i ~/.ssh/ionos_runart_staging u111876951@runart-foundry.com \
     "cd staging && wp theme list --status=active"
   
   # Si no es runart-base:
   ssh -i ~/.ssh/ionos_runart_staging u111876951@runart-foundry.com \
     "cd staging && wp theme activate runart-base"
   ```
4. ⏳ Ejecutar backup staging:
   ```bash
   bash tools/backup_staging.sh
   ```
5. ⏳ Commit y push inicial:
   ```bash
   git add research/content_audit_v2/ _reports/CONTENT_AUDIT_INIT_*.md
   git commit -m "feat: initialize content audit phase 1 (templates)"
   git push origin feat/content-audit-v2-phase1
   ```

---

### Fase 1.2: Inventario de Páginas (Días 1-3)

**Tiempo estimado:** 2-3 días

#### Tareas:
1. **Listar todas las páginas (WP-CLI):**
   ```bash
   ssh ... "cd staging && wp post list --post_type=page --format=csv" > _tmp/pages_raw.csv
   ```

2. **Extraer metadata:**
   - ID, título ES, título EN, slug, estado, plantilla, URL

3. **Categorizar páginas:**
   - Landing pages
   - Páginas de servicio
   - Institucionales (About, Contact)
   - Blog posts
   - Portfolio items

4. **Identificar gaps:**
   - Páginas solo ES (sin EN)
   - Páginas draft
   - Páginas legacy

5. **Actualizar `01_pages_inventory.md`:**
   - Completar tabla principal
   - Actualizar resumen estadístico

#### Entregable:
- ✅ `01_pages_inventory.md` completo
- ✅ Archivo CSV raw: `_tmp/pages_raw.csv`

---

### Fase 1.3: Inventario de Imágenes (Días 4-6)

**Tiempo estimado:** 2-3 días

#### Tareas:
1. **Listar media library (WP-CLI):**
   ```bash
   ssh ... "cd staging && wp media list --format=csv" > _tmp/media_raw.csv
   ```

2. **Analizar theme assets:**
   ```bash
   find runart-base/assets/images/ -type f -exec ls -lh {} \; > _tmp/theme_assets.txt
   ```

3. **Identificar imágenes grandes (>1MB):**
   ```bash
   ssh ... "cd staging && find wp-content/uploads/ -size +1M -exec ls -lh {} \;" > _tmp/large_images.txt
   ```

4. **Extraer metadata:**
   - Formato, tamaño, dimensiones, alt text, fecha, uso

5. **Clasificar:**
   - Por formato (WebP, JPG, PNG, GIF, SVG)
   - Por tamaño (>1MB, >500KB, <500KB)
   - Por uso (en páginas vs sin uso)

6. **Actualizar `02_images_inventory.md`:**
   - Completar tablas de media library y theme assets
   - Actualizar análisis por formato y tamaño
   - Documentar imágenes sin uso y sin alt text

#### Entregable:
- ✅ `02_images_inventory.md` completo
- ✅ Archivos CSV/TXT raw: `_tmp/media_raw.csv`, `_tmp/large_images.txt`

---

### Fase 1.4: Análisis Texto vs Imagen (Días 7-8)

**Tiempo estimado:** 1-2 días

#### Tareas:
1. **Para cada página, extraer word count:**
   ```bash
   wp post get <ID> --lang=es --field=post_content | wc -w
   wp post get <ID> --lang=en --field=post_content | wc -w
   ```

2. **Contar imágenes por página:**
   ```bash
   wp post get <ID> --field=post_content | grep -o '<img' | wc -l
   ```

3. **Calcular ratio texto/imagen:**
   - Ejemplo: 800 palabras / 4 imágenes = 200:1

4. **Identificar desbalances:**
   - Exceso de texto (>200:1)
   - Exceso de imágenes (<50:1)
   - Páginas sin imágenes

5. **Actualizar `03_texts_vs_images_matrix.md`:**
   - Completar matriz por página
   - Documentar desbalances
   - Sugerir correcciones

#### Entregable:
- ✅ `03_texts_vs_images_matrix.md` completo

---

### Fase 1.5: Análisis de Gaps Bilingües (Días 9-10)

**Tiempo estimado:** 1-2 días

#### Tareas:
1. **Cruzar inventarios ES vs EN:**
   ```bash
   comm -3 <(wp post list --lang=es --format=ids | tr ' ' '\n' | sort) \
           <(wp post list --lang=en --format=ids | tr ' ' '\n' | sort)
   ```

2. **Identificar páginas sin traducción:**
   - Solo ES (sin EN)
   - Solo EN (sin ES)

3. **Comparar word count ES vs EN:**
   - Calcular % completitud traducción
   - Identificar traducciones parciales (<90%)

4. **Identificar imágenes con texto hardcoded:**
   - Revisar banners, CTAs, infográficos
   - Documentar necesidad de versiones bilingües

5. **Validar elementos UI:**
   - Menús
   - Widgets
   - Formularios
   - Meta tags

6. **Actualizar `04_bilingual_gap_report.md`:**
   - Documentar todos los gaps
   - Priorizar por importancia
   - Estimar recursos necesarios

#### Entregable:
- ✅ `04_bilingual_gap_report.md` completo

---

### Fase 1.6: Consolidación y Plan de Acción (Día 11)

**Tiempo estimado:** 1 día

#### Tareas:
1. **Consolidar hallazgos:**
   - Total páginas, imágenes, gaps
   - Métricas clave (ratios, completitud, etc.)

2. **Priorizar acciones:**
   - **Alta:** Páginas críticas sin traducción, imágenes >1MB
   - **Media:** Traducciones parciales, desbalances texto/imagen
   - **Baja:** Contenido legacy, optimizaciones menores

3. **Estimar recursos:**
   - Horas de traducción
   - Horas de diseño (recrear imágenes)
   - Horas de desarrollo (implementación)
   - Costos estimados

4. **Definir timeline:**
   - Fase 2: Crítico (1-2 semanas)
   - Fase 3: Importante (2-3 semanas)
   - Fase 4: Complementario (1 mes)

5. **Actualizar `05_next_steps.md`:**
   - Resumen ejecutivo de hallazgos
   - Plan de acción detallado
   - Criterios de éxito

#### Entregable:
- ✅ `05_next_steps.md` actualizado con plan completo

---

## Timeline Completo

| Fase | Tareas | Duración | Fechas Estimadas |
|------|--------|----------|------------------|
| **1.1** | Pre-flight checks | 0.5 días | 2025-10-29 |
| **1.2** | Inventario páginas | 2-3 días | 2025-10-30 a 2025-11-01 |
| **1.3** | Inventario imágenes | 2-3 días | 2025-11-02 a 2025-11-04 |
| **1.4** | Análisis texto vs imagen | 1-2 días | 2025-11-05 a 2025-11-06 |
| **1.5** | Análisis gaps bilingües | 1-2 días | 2025-11-07 a 2025-11-08 |
| **1.6** | Consolidación y plan | 1 día | 2025-11-09 |
| **TOTAL** | - | **7-11 días** | **2025-10-29 a 2025-11-09** |

---

## Acciones Sugeridas Post-Auditoría

### Inmediato (Post-Fase 1)

1. **Review de hallazgos con equipo:**
   - Presentar inventarios completos
   - Validar priorización de gaps
   - Aprobar presupuesto para traducción/diseño

2. **Crear issues en GitHub:**
   - Issue por cada gap crítico (traducción faltante)
   - Issue por cada imagen >1MB (optimización)
   - Labels: content-audit, translation, optimization

3. **Planificar Fase 2 (Implementación):**
   - Asignar traductor para páginas críticas
   - Asignar diseñador para recrear imágenes con texto
   - Asignar developer para implementación técnica

### Mediano Plazo (2-4 semanas)

4. **Ejecutar traducciones críticas:**
   - Home, About, Services, Contact (100% bilingües)
   - Blog posts recientes (últimos 10)

5. **Optimizar imágenes:**
   - Reducir >1MB a <500KB
   - Migrar JPG/PNG a WebP
   - Añadir alt text faltantes

6. **Corregir desbalances:**
   - Añadir imágenes a páginas con exceso de texto
   - Añadir contexto a páginas con exceso de imágenes

### Largo Plazo (1-2 meses)

7. **Contenido legacy:**
   - Evaluar deprecar o actualizar
   - Consolidar páginas duplicadas

8. **SEO y metadata:**
   - Meta descriptions bilingües
   - Alt text descriptivos (accesibilidad)

9. **Automatización:**
   - CI checks para alt text obligatorio
   - CI checks para tamaño máximo imagen
   - CI checks para completitud bilingüe

---

## Criterios de Éxito

### Auditoría (Fase 1)
- [ ] 100% páginas inventariadas
- [ ] 100% imágenes inventariadas
- [ ] Análisis de balance texto/imagen completo
- [ ] Gaps bilingües documentados
- [ ] Plan de acción priorizado y estimado

### Implementación (Fase 2-4)
- [ ] 100% páginas críticas con versión ES y EN
- [ ] 0 imágenes >1MB
- [ ] 100% imágenes con alt text
- [ ] Ratio texto/imagen balanceado (50-200:1)
- [ ] Meta tags y SEO bilingües completos

---

## Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Staging con tema incorrecto | Media | Alto | ✅ Verificar antes de auditoría |
| WP-CLI queries lentos | Baja | Medio | Usar --per_page=100, cachear resultados |
| Páginas sin metadata estructurada | Media | Bajo | Documentar como legacy |
| Presupuesto insuficiente | Media | Alto | Priorizar crítico, diferir complementario |

---

## Recursos de Apoyo

### Documentación
- `_reports/VERIFY_DEPLOY_FRAMEWORK_20251029.md`
- `_reports/GOVERNANCE_STATUS_20251029.md`
- `_reports/THEME_CANON_AUDIT_20251029.md`
- `_reports/CONTENT_READY_STATUS_20251029.md`

### Scripts
- `tools/staging_env_loader.sh` — Cargar env staging
- `tools/backup_staging.sh` — Backup antes de auditoría
- `tools/staging_isolation_audit.sh` — Auditoría de aislamiento

### Comandos WP-CLI
Ver secciones específicas en cada plantilla (01-04) para comandos detallados.

---

## Notas Finales

- ✅ **Modo READ_ONLY:** Toda la auditoría es de solo lectura, sin modificaciones en staging
- ✅ **Canon confirmado:** runart-base (sin cambios durante auditoría)
- ✅ **Backup requerido:** Ejecutar backup staging antes de iniciar
- ✅ **Freeze policy activo:** Respeta políticas de code freeze durante auditoría

---

**Última actualización:** 2025-10-29  
**Estado:** ✅ READY TO START — Iniciar Fase 1.1 (Pre-flight checks)  
**Duración total estimada:** 7-11 días  
**Próxima acción:** Verificar tema staging + commit inicial
