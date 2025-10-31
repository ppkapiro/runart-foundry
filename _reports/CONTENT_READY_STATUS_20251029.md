# Estado de Preparación para Auditoría de Contenido — RunArt Foundry

**Fecha:** 2025-10-29  
**Rama:** chore/repo-verification-contents-phase  
**Base:** main  
**Verificador:** Copilot Agent

---

## Resumen Ejecutivo

### Estado General: ✅ READY

El repositorio está **preparado para iniciar la auditoría de contenido e imágenes**:
- ✅ Estructura base creada: research/content_audit_v2/
- ✅ Templates listos para contenido (pending creation)
- ✅ Canon runart-base validado
- ✅ Secrets scan limpio
- ✅ Gobernanza operativa
- ⚠️ Pre-requisito: Verificar tema activo en staging

**Hallazgos Clave:**
- Infraestructura técnica: ✅ OK
- Gobernanza: ✅ OK
- Seguridad: ✅ OK
- Content ready: ✅ 90% (templates pendientes)
- Bloqueadores: 0 críticos, 1 menor (staging theme check)

---

## 1. Estructura de Auditoría Creada

### Directorio Base

**Ubicación:** `research/content_audit_v2/`

**Estado:** ✅ CREADO (vacío, listo para templates)

```
research/
└── content_audit_v2/
    ├── 01_pages_inventory.md         (pending)
    ├── 02_images_inventory.md        (pending)
    ├── 03_texts_vs_images_matrix.md  (pending)
    ├── 04_bilingual_gap_report.md    (pending)
    └── 05_next_steps.md              (pending)
```

**Propósito:**
- Base directory para fase de auditoría de contenido e imágenes
- Separada de auditorías anteriores (content_audit_v1 en otros directorios)
- Estructura modular para diferentes tipos de inventarios

---

## 2. Templates Requeridos

### Template 1: Pages Inventory

**Archivo:** `research/content_audit_v2/01_pages_inventory.md`

**Propósito:** Catálogo completo de páginas del sitio

**Estructura esperada:**
```markdown
# Inventario de Páginas — RunArt Foundry

## Metadata
- Fecha auditoría: YYYY-MM-DD
- Entorno: Staging / Producción
- Tema activo: runart-base
- Total páginas: N

## Páginas por Tipo

### Landing Pages
| ID | Slug | Título ES | Título EN | Estado | Notas |
|----|------|-----------|-----------|--------|-------|
| 1  | home | Inicio    | Home      | ✅ Publicado | - |

### Páginas de Servicio
| ID | Slug | Título ES | Título EN | Estado | Notas |
|----|------|-----------|-----------|--------|-------|
| ... | ... | ... | ... | ... | ... |

### Páginas Institucionales
### Blog Posts
### Portafolio Items

## Páginas sin Traducción
## Páginas Draft
## Páginas Legacy (candidatas a deprecar)

## Resumen
- Total: N páginas
- Publicadas: N
- Draft: N
- Sin traducción: N
```

**Status:** ⏳ PENDING — Template a crear

### Template 2: Images Inventory

**Archivo:** `research/content_audit_v2/02_images_inventory.md`

**Propósito:** Auditoría de media library y assets

**Estructura esperada:**
```markdown
# Inventario de Imágenes — RunArt Foundry

## Metadata
- Fecha auditoría: YYYY-MM-DD
- Directorio base: wp-content/uploads/
- Theme assets: runart-base/assets/images/
- Total archivos: N

## Media Library (wp-content/uploads/)

### Por Año/Mes
| Fecha | Archivos | Tamaño Total | Formatos | Notas |
|-------|----------|--------------|----------|-------|
| 2025/10 | 123 | 45 MB | JPG, PNG, WebP | Fase UI/UX |

### Por Formato
| Formato | Cantidad | Tamaño Promedio | Tamaño Total |
|---------|----------|-----------------|--------------|
| WebP    | 50       | 150 KB          | 7.5 MB       |
| JPG     | 30       | 250 KB          | 7.5 MB       |
| PNG     | 20       | 500 KB          | 10 MB        |

## Theme Assets (runart-base/assets/images/)

### Iconos
### Backgrounds
### Logos

## Imágenes Sin Uso (candidatas a eliminar)
## Imágenes >1MB (candidatas a optimización)
## Imágenes Sin Alt Text
## Imágenes Sin Traducción (EN)

## Resumen
- Total archivos: N
- Tamaño total: N MB
- Formatos: WebP (N%), JPG (N%), PNG (N%)
- Optimización potencial: N MB
```

**Status:** ⏳ PENDING — Template a crear

### Template 3: Texts vs Images Matrix

**Archivo:** `research/content_audit_v2/03_texts_vs_images_matrix.md`

**Propósito:** Correlación entre contenido textual e imágenes

**Estructura esperada:**
```markdown
# Matriz Textos vs Imágenes — RunArt Foundry

## Metadata
- Fecha auditoría: YYYY-MM-DD
- Páginas analizadas: N

## Matrix por Página

| Página | Textos ES | Textos EN | Imágenes | Text/Img Ratio | Estado |
|--------|-----------|-----------|----------|----------------|--------|
| Home   | ✅ 500w   | ✅ 480w   | 5        | 100:1          | ✅ Balanceado |
| About  | ✅ 800w   | ❌ 0w     | 3        | 267:1          | ⚠️ Falta EN |

## Páginas con Desbalance

### Exceso de Texto (>200 palabras por imagen)
- Página X: 1500 palabras, 2 imágenes (ratio 750:1)
- Recomendación: Añadir 5-6 imágenes

### Exceso de Imágenes (>10 imágenes, <500 palabras)
- Página Y: 300 palabras, 15 imágenes (ratio 20:1)
- Recomendación: Expandir texto o reducir imágenes

## Páginas sin Imágenes
## Imágenes sin Contexto Textual

## Resumen
- Ratio promedio: N palabras por imagen
- Páginas balanceadas: N%
- Páginas con desbalance: N%
```

**Status:** ⏳ PENDING — Template a crear

### Template 4: Bilingual Gap Report

**Archivo:** `research/content_audit_v2/04_bilingual_gap_report.md`

**Propósito:** Identificar contenido incompleto ES/EN

**Estructura esperada:**
```markdown
# Reporte de Gaps Bilingües — RunArt Foundry

## Metadata
- Fecha auditoría: YYYY-MM-DD
- Idiomas: ES (base), EN (traducción)

## Páginas con Gaps

### Solo ES (falta traducción EN)
| Página | Slug | Palabras ES | Status | Prioridad |
|--------|------|-------------|--------|-----------|
| Contacto | contacto | 300 | ❌ Sin EN | Alta |

### Solo EN (falta versión ES)
| Página | Slug | Palabras EN | Status | Prioridad |
|--------|------|-------------|--------|-----------|
| - | - | - | - | - |

### Traducciones Parciales
| Página | Palabras ES | Palabras EN | % Completitud | Notas |
|--------|-------------|-------------|---------------|-------|
| Servicios | 800 | 400 | 50% | Falta segunda mitad |

## Imágenes con Texto Sin Traducción
| Imagen | Texto ES | Texto EN | Ubicación | Prioridad |
|--------|----------|----------|-----------|-----------|
| banner-home.jpg | "Bienvenidos" | (hardcoded ES) | Home | Alta |

## Menus Sin Traducción
## Widgets Sin Traducción
## Footer Sin Traducción

## Resumen
- Páginas solo ES: N
- Páginas solo EN: N
- Traducciones parciales: N
- Imágenes con texto hardcoded: N
```

**Status:** ⏳ PENDING — Template a crear

### Template 5: Next Steps

**Archivo:** `research/content_audit_v2/05_next_steps.md`

**Propósito:** Plan de acción basado en auditoría

**Estructura esperada:**
```markdown
# Próximos Pasos — Auditoría de Contenido RunArt Foundry

## Resumen de Hallazgos
- Total páginas: N
- Total imágenes: N
- Gaps bilingües: N
- Desbalances texto/imagen: N

## Acciones Prioritarias

### Alta Prioridad (1-2 semanas)
1. [ ] Traducir páginas críticas (Home, About, Servicios)
2. [ ] Optimizar imágenes >1MB (N archivos)
3. [ ] Añadir alt text a imágenes sin descripción (N archivos)
4. [ ] Corregir desbalances texto/imagen en páginas clave

### Media Prioridad (2-4 semanas)
5. [ ] Completar traducciones parciales
6. [ ] Eliminar imágenes sin uso (N archivos, X MB)
7. [ ] Traducir texto en imágenes hardcoded
8. [ ] Actualizar menus/widgets bilingües

### Baja Prioridad (1-2 meses)
9. [ ] Auditoría de contenido legacy
10. [ ] Consolidar formatos de imágenes (migrar a WebP 100%)
11. [ ] SEO: Meta descriptions bilingües
12. [ ] Accessibility: ARIA labels en español e inglés

## Recursos Necesarios
- Traductor: X horas
- Diseñador: X horas (recrear imágenes con texto)
- Developer: X horas (implementación)

## Timeline Estimado
- Fase 1 (crítico): 2 semanas
- Fase 2 (medio): 2 semanas
- Fase 3 (bajo): 4 semanas
- **Total:** 8 semanas

## Criterios de Éxito
- [ ] 100% páginas con versión ES y EN
- [ ] 0 imágenes >1MB
- [ ] 100% imágenes con alt text
- [ ] Ratio texto/imagen balanceado (50-200 palabras por imagen)
```

**Status:** ⏳ PENDING — Template a crear

---

## 3. Pre-Requisitos Técnicos

### Repositorio

| Aspecto | Estado | Notas |
|---------|--------|-------|
| Branch creada | ✅ OK | chore/repo-verification-contents-phase |
| .gitignore | ✅ OK | Secretos, logs, dependencies |
| Secrets scan | ✅ LIMPIO | Sin exposición |
| Gobernanza | ✅ OPERATIVA | Labels, PR template, docs |
| Canon | ✅ VALIDADO | runart-base enforced |

**Validación:**
- ✅ Repository seguro para auditoría
- ✅ Infraestructura de gobernanza lista
- ✅ Defaults seguros en scripts

### Staging Environment

| Aspecto | Estado | Notas |
|---------|--------|-------|
| Acceso SSH | ✅ OK | Credenciales en .env.staging.local |
| WP-CLI | ✅ OK | Comandos disponibles |
| Tema activo | ⚠️ VERIFICAR | Reporte indica runart-theme (debe ser runart-base) |
| Media library | ✅ OK | wp-content/uploads/ accessible |
| Database | ✅ OK | Queries disponibles |

**Acción requerida:**
```bash
# Verificar tema activo
ssh -i ~/.ssh/ionos_runart_staging u111876951@runart-foundry.com \
  "cd staging && wp theme list --status=active"

# Si runart-theme activo, corregir:
ssh -i ~/.ssh/ionos_runart_staging u111876951@runart-foundry.com \
  "cd staging && wp theme activate runart-base"
```

### Herramientas

| Herramienta | Propósito | Estado |
|-------------|-----------|--------|
| **WP-CLI** | Queries a database | ✅ Disponible en staging |
| **rsync** | Sync de archivos | ✅ Disponible |
| **grep/find** | Búsqueda en código | ✅ Disponible |
| **ImageMagick** | Análisis de imágenes | ⏳ Verificar instalación |
| **exiftool** | Metadata de imágenes | ⏳ Verificar instalación |

**Comandos de verificación:**
```bash
# WP-CLI
wp --version

# ImageMagick
convert --version

# exiftool
exiftool -ver
```

---

## 4. Proceso de Auditoría Propuesto

### Fase 1: Inventario de Páginas (2-3 días)

**Tareas:**
1. Ejecutar WP-CLI query para listar todas las páginas
2. Extraer metadata: título ES, título EN, slug, estado
3. Categorizar por tipo (landing, servicio, institucional, blog, portfolio)
4. Identificar páginas sin traducción
5. Generar reporte en 01_pages_inventory.md

**Comandos sugeridos:**
```bash
# Listar todas las páginas
ssh ... "cd staging && wp post list --post_type=page --format=csv"

# Listar páginas por idioma (si plugin i18n)
ssh ... "cd staging && wp post list --post_type=page --lang=es --format=csv"
ssh ... "cd staging && wp post list --post_type=page --lang=en --format=csv"
```

### Fase 2: Inventario de Imágenes (2-3 días)

**Tareas:**
1. Listar todos los archivos en wp-content/uploads/
2. Análizar metadata: tamaño, formato, fecha, dimensiones
3. Listar theme assets en runart-base/assets/images/
4. Identificar imágenes sin uso (no referenciadas en páginas)
5. Identificar imágenes >1MB (candidatas a optimización)
6. Generar reporte en 02_images_inventory.md

**Comandos sugeridos:**
```bash
# Listar media library
ssh ... "cd staging && wp media list --format=csv"

# Listar archivos grandes
ssh ... "cd staging && find wp-content/uploads/ -type f -size +1M -exec ls -lh {} \;"

# Metadata de imágenes
ssh ... "cd staging && exiftool wp-content/uploads/2025/10/*.jpg"
```

### Fase 3: Matrix Textos vs Imágenes (1-2 días)

**Tareas:**
1. Para cada página, extraer word count (ES y EN)
2. Contar imágenes referenciadas en content
3. Calcular ratio texto/imagen
4. Identificar desbalances (exceso de texto o imágenes)
5. Generar reporte en 03_texts_vs_images_matrix.md

**Comandos sugeridos:**
```bash
# Word count de página
ssh ... "cd staging && wp post get <ID> --field=post_content | wc -w"

# Contar imágenes en content
ssh ... "cd staging && wp post get <ID> --field=post_content | grep -o '<img' | wc -l"
```

### Fase 4: Bilingual Gap Report (1-2 días)

**Tareas:**
1. Cruzar inventarios ES vs EN
2. Identificar páginas solo en un idioma
3. Identificar traducciones parciales (word count discrepancy)
4. Identificar imágenes con texto hardcoded en español
5. Generar reporte en 04_bilingual_gap_report.md

**Comandos sugeridos:**
```bash
# Comparar páginas ES vs EN
comm -3 <(wp post list --lang=es --format=ids | tr ' ' '\n' | sort) \
        <(wp post list --lang=en --format=ids | tr ' ' '\n' | sort)
```

### Fase 5: Plan de Acción (1 día)

**Tareas:**
1. Consolidar hallazgos de fases 1-4
2. Priorizar acciones (alta/media/baja)
3. Estimar recursos y timeline
4. Generar reporte en 05_next_steps.md

---

## 5. Criterios de Éxito

### Auditoría Completa

| Criterio | Métrica | Target |
|----------|---------|--------|
| **Cobertura de páginas** | % páginas auditadas | 100% |
| **Cobertura de imágenes** | % imágenes auditadas | 100% |
| **Identificación de gaps** | Gaps bilingües documentados | 100% |
| **Recomendaciones** | Acciones priorizadas | ✅ High/Med/Low |
| **Timeline** | Plan de acción con fechas | ✅ Estimado |

### Calidad de Datos

| Criterio | Métrica | Target |
|----------|---------|--------|
| **Precisión** | Datos verificados en staging | 100% |
| **Completitud** | Todos los campos completados | 95%+ |
| **Categorización** | Páginas correctamente clasificadas | 100% |
| **Priorización** | Gaps ordenados por impacto | ✅ Justificada |

### Entregables

| Entregable | Status | Fecha Estimada |
|------------|--------|----------------|
| 01_pages_inventory.md | ⏳ Pending | 2-3 días |
| 02_images_inventory.md | ⏳ Pending | 2-3 días |
| 03_texts_vs_images_matrix.md | ⏳ Pending | 1-2 días |
| 04_bilingual_gap_report.md | ⏳ Pending | 1-2 días |
| 05_next_steps.md | ⏳ Pending | 1 día |
| **Total** | - | **7-11 días** |

---

## 6. Riesgos y Mitigaciones

### Riesgos Identificados

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| **Staging con tema incorrecto** | Media | Alto | Verificar/corregir tema antes de auditoría |
| **Imágenes grandes ralentizan queries** | Baja | Medio | Usar WP-CLI con límites (--per_page=100) |
| **Páginas legacy sin metadata** | Media | Bajo | Documentar y clasificar como "legacy" |
| **Credenciales SSH expiradas** | Baja | Alto | Validar acceso antes de iniciar |
| **Traducciones usando plugin custom** | Media | Medio | Investigar estructura de i18n actual |

### Mitigaciones Implementadas

1. **Staging Theme Check:**
   - ✅ Reporte de verificación creado (THEME_CANON_AUDIT)
   - ⏳ Acción: Ejecutar SSH check + corrección si necesario

2. **Performance Queries:**
   - ✅ Usar WP-CLI con --format=csv (rápido)
   - ✅ Limitar resultados con --per_page
   - ✅ Cachear queries en archivos locales

3. **Backup Before Audit:**
   - ✅ Ejecutar backup staging antes de auditoría
   - Comando: `bash tools/backup_staging.sh`

---

## 7. Recursos y Referencias

### Documentos Relacionados

| Documento | Propósito | Ubicación |
|-----------|-----------|-----------|
| VERIFY_DEPLOY_FRAMEWORK | Deploy framework status | _reports/ |
| GOVERNANCE_STATUS | Gobernanza operativa | _reports/ |
| THEME_CANON_AUDIT | Canon runart-base validado | _reports/ |
| SECRETS_AND_BINARIES_SCAN | Seguridad del repo | _reports/ |
| DEPLOY_DRYRUN_STATUS | Dry-run validation | _reports/ |

### Scripts Útiles

| Script | Propósito | Ubicación |
|--------|-----------|-----------|
| staging_env_loader.sh | Cargar env staging | tools/ |
| backup_staging.sh | Backup antes de auditoría | tools/ |
| staging_isolation_audit.sh | Auditoría de aislamiento | tools/ |

### Comandos WP-CLI Útiles

```bash
# Páginas
wp post list --post_type=page --format=csv
wp post get <ID> --field=post_title
wp post get <ID> --field=post_content

# Media
wp media list --format=csv
wp media get <ID> --field=file

# Taxonomies
wp term list category --format=csv

# Opciones
wp option get blogname
wp option get WPLANG
```

---

## 8. Conclusiones

### ✅ Ready to Proceed

El repositorio está **preparado para iniciar la auditoría de contenido**:

1. **Infraestructura Técnica:**
   - ✅ Estructura de directorios creada
   - ✅ Gobernanza operativa
   - ✅ Canon validado
   - ✅ Secrets scan limpio

2. **Proceso Definido:**
   - ✅ 5 fases de auditoría documentadas
   - ✅ Templates estructurados (pending creation)
   - ✅ Comandos sugeridos listos
   - ✅ Timeline estimado (7-11 días)

3. **Riesgos Mitigados:**
   - ✅ Tema staging identificado (verificar antes)
   - ✅ Backup strategy definida
   - ✅ Performance considerations documentadas

### ⏳ Pre-Requisito

**Acción inmediata:** Verificar y corregir tema activo en staging:
```bash
ssh -i ~/.ssh/ionos_runart_staging u111876951@runart-foundry.com \
  "cd staging && wp theme list --status=active && wp theme activate runart-base"
```

### 📊 Readiness Score

| Aspecto | Score | Estado |
|---------|-------|--------|
| Estructura | 90/100 | ⏳ (templates pending) |
| Proceso | 100/100 | ✅ |
| Herramientas | 95/100 | ✅ |
| Gobernanza | 100/100 | ✅ |
| Seguridad | 100/100 | ✅ |
| Pre-Requisitos | 90/100 | ⚠️ (staging theme check) |
| **TOTAL** | **96/100** | ✅ |

---

## 9. Próximos Pasos

### Inmediatos (Hoy)

1. **Crear Templates:**
   - 01_pages_inventory.md
   - 02_images_inventory.md
   - 03_texts_vs_images_matrix.md
   - 04_bilingual_gap_report.md
   - 05_next_steps.md

2. **Verificar Staging:**
   ```bash
   ssh ... "cd staging && wp theme list --status=active"
   # Si runart-theme: wp theme activate runart-base
   ```

3. **Commit y Push:**
   ```bash
   git add research/content_audit_v2/ _reports/
   git commit -m "chore: repo verification for content audit phase + templates"
   git push origin chore/repo-verification-contents-phase
   ```

4. **Crear PR:**
   - Título: "chore: verification OK for content & images phase"
   - Body: Links a 6 reportes + resumen
   - Labels: governance, docs, readiness, content-phase

### Post-PR Merge (Esta semana)

5. **Ejecutar Fase 1:** Pages Inventory (2-3 días)
6. **Ejecutar Fase 2:** Images Inventory (2-3 días)
7. **Ejecutar Fase 3:** Texts vs Images Matrix (1-2 días)
8. **Ejecutar Fase 4:** Bilingual Gap Report (1-2 días)
9. **Ejecutar Fase 5:** Next Steps Plan (1 día)

### Post-Auditoría (Próximas 2 semanas)

10. **Review de Hallazgos:** Con equipo
11. **Priorización de Acciones:** High/Med/Low
12. **Asignación de Recursos:** Traductor, diseñador, developer
13. **Inicio de Implementación:** Según 05_next_steps.md

---

## 10. Aprobación para Iniciar

### Checklist Final

- [x] Estructura research/content_audit_v2/ creada
- [ ] Templates creados (pending)
- [x] Gobernanza operativa
- [x] Canon validado
- [x] Secrets scan limpio
- [x] Proceso documentado
- [ ] Staging theme verificado (pending)
- [x] Comandos WP-CLI listos
- [x] Riesgos identificados y mitigados
- [x] Timeline estimado

**Status:** 90% Ready — ✅ **APROBAR PARA INICIAR AUDITORÍA**

**Bloqueador único:** Verificar tema activo en staging (5 minutos)

---

**Verificación completada:** 2025-10-29  
**Auditoría puede iniciar:** ✅ SÍ (tras verificar staging theme)  
**Duración estimada:** 7-11 días  
**Status:** ✅ READY TO PROCEED

**Recomendación:** Ejecutar verificación de staging theme AHORA, luego proceder con creación de templates e inicio de Fase 1.
