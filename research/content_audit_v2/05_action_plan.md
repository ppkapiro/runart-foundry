# F5 — Plan de Acción Ejecutable (Consolidado F1–F4)

**Fecha de generación:** 2025-10-30T15:49:58Z  
**Alcance:** Auditoría completa de contenido, imágenes y traducciones  
**Fuentes:** F1 (páginas), F2 (imágenes), F3 (texto↔imagen), F4 (brechas bilingües)

---

## 📊 Resumen Ejecutivo

### Métricas Globales

| Métrica | Valor | % Completitud |
|---------|-------|---------------|
| **Total de páginas** | 25 | 100% |
| **Páginas ES** | 15 | 60% |
| **Páginas EN** | 10 | 40% |
| **Imágenes en biblioteca** | 0 | 0% |
| **Páginas con imágenes** | 0 | 0% |
| **Emparejamientos ES↔EN** | 2 | 8.0% |
| **Brechas de traducción** | 21 | 84% sin traducción |
| **Desbalance texto/imagen** | 21 páginas | 84.0% |

### Estado General
- ✅ **Inventario completo:** F1/F2 ejecutados vía REST
- ⚠️ **Cobertura visual crítica:** 0 imágenes, 100% de páginas sin soporte visual
- ⚠️ **Cobertura bilingüe crítica:** Solo 8% de páginas tienen traducción completa
- 🔴 **Polylang no configurado:** Metadatos de idioma ausentes

---

## 🎯 Plan de Acción Priorizado

### Tabla de Acciones

| # | Fase | Hallazgo | Severidad | Acción Recomendada | Responsable | Estimado (días) | Estado |
|---|------|----------|-----------|-------------------|-------------|-----------------|--------|
| 1 | F2 | Biblioteca de medios vacía | **Alta** | Cargar imágenes de productos/proyectos históricos | Diseñador | 5 | Pendiente |
| 2 | F3 | 100% páginas sin imágenes | **Alta** | Asignar imágenes representativas a cada página principal | Diseñador | 7 | Pendiente |
| 3 | F4 | 13 páginas ES sin traducción EN | **Alta** | Traducir páginas clave (inicio, servicios, sobre-nosotros) | Traductor | 10 | Pendiente |
| 4 | F4 | 8 páginas EN sin traducción ES | **Alta** | Traducir contenido técnico (blog posts, landing) | Traductor | 8 | Pendiente |
| 5 | F1/F4 | Polylang sin configurar | **Media** | Asignar idiomas correctos en Polylang y vincular traducciones | Desarrollador | 2 | Pendiente |
| 6 | F4 | 3 páginas de contacto duplicadas | **Media** | Consolidar formularios de contacto en una sola versión | Desarrollador | 1 | Pendiente |
| 7 | F1 | 6 posts de blog duplicados (-2 suffix) | **Media** | Eliminar duplicados y redirigir URLs | Desarrollador | 1 | Pendiente |
| 8 | F3 | Posts técnicos con 370+ palabras sin imagen | **Media** | Añadir diagramas/fotos técnicas a posts de fundición | Diseñador | 3 | Pendiente |
| 9 | F1 | Ausencia de alt text en imágenes futuras | **Baja** | Establecer política de alt text obligatorio | SEO | 1 | Pendiente |
| 10 | F2 | Optimización de imágenes (futura) | **Baja** | Implementar pipeline WebP + lazy loading | Desarrollador | 2 | Pendiente |

---

## 📅 Cronograma de Ejecución (30 días)

### Fase 1: Crítica (Días 1-7)
**Objetivo:** Restaurar presencia visual y cobertura bilingüe mínima

- **Día 1-2:** Configurar Polylang con metadatos de idioma (Acción #5)
- **Día 3-5:** Cargar primeras 20 imágenes de productos/portfolio (Acción #1)
- **Día 6-7:** Asignar imágenes a páginas principales (Home, About, Services) (Acción #2 parcial)

**Entregables:** Polylang operativo, 8 páginas con imágenes, metadatos de idioma asignados.

### Fase 2: Alta Prioridad (Días 8-20)
**Objetivo:** Completar cobertura bilingüe y visual

- **Día 8-12:** Traducir 5 páginas ES prioritarias (inicio, servicios, sobre-nosotros, cotización, contacto) (Acción #3)
- **Día 13-17:** Traducir 3 páginas EN prioritarias (home, about, services) (Acción #4 parcial)
- **Día 18-20:** Completar asignación de imágenes a las 25 páginas (Acción #2)

**Entregables:** 8 nuevas traducciones, 25 páginas con imágenes, 50% cobertura bilingüe.

### Fase 3: Limpieza y Optimización (Días 21-30)
**Objetivo:** Consolidar estructura y optimizar metadatos

- **Día 21-22:** Eliminar páginas duplicadas y configurar redirecciones 301 (Acciones #6, #7)
- **Día 23-28:** Traducir posts de blog técnicos restantes (Acción #4 completa)
- **Día 29-30:** Añadir diagramas técnicos a posts especializados (Acción #8)

**Entregables:** Estructura limpia, 100% traducción EN→ES, contenido técnico ilustrado.

---

## 👥 Recursos Necesarios

| Rol | Tareas Asignadas | Horas Estimadas |
|-----|------------------|-----------------|
| **Diseñador** | Cargar imágenes, asignar a páginas, crear diagramas técnicos | 80 horas (10 días) |
| **Traductor** | Traducir páginas ES→EN y EN→ES, revisar coherencia terminológica | 120 horas (15 días) |
| **Desarrollador** | Configurar Polylang, eliminar duplicados, redirecciones, alt text | 32 horas (4 días) |
| **SEO** | Definir política alt text, auditar metadatos | 8 horas (1 día) |

**Total:** 240 horas / 30 días laborables (estimado 1 FTE durante 1.5 meses)

---

## 🔗 Dependencias entre Tareas

```
Acción #5 (Polylang)
    ↓
Acción #3 & #4 (Traducciones) → Acción #6 (Consolidar duplicados)
    ↓
Acción #1 (Cargar imágenes)
    ↓
Acción #2 (Asignar imágenes) → Acción #8 (Diagramas técnicos)
    ↓
Acción #9 & #10 (Alt text + WebP)
```

**Crítico:** La configuración de Polylang (#5) desbloquea las traducciones (#3, #4). La carga de imágenes (#1) desbloquea la asignación visual (#2, #8).

---

## 🎯 KPIs de Calidad

Al completar este plan, se espera alcanzar:

| KPI | Meta | Medición |
|-----|------|----------|
| **Cobertura bilingüe** | ≥90% | (Páginas con traducción / Total páginas) × 100 |
| **Cobertura visual** | ≥80% | (Páginas con ≥1 imagen / Total páginas) × 100 |
| **Ratio texto/imagen** | ≤200:1 | Palabras promedio / Imágenes promedio por página |
| **Alt text presente** | 100% | (Imágenes con alt / Total imágenes) × 100 |
| **Páginas duplicadas** | 0 | Páginas con slug `-2` o `-3` activas |

---

## 📋 Próximos Pasos

1. **Validación del plan:**
   - Revisar estimaciones con equipo técnico
   - Confirmar disponibilidad de recursos (diseñador + traductor)
   - Aprobar presupuesto (~30 días FTE)

2. **Integración en gobernanza:**
   - Incorporar este plan en `docs/content/CONTENT_AUDIT_PLAN.md`
   - Vincular con roadmap de desarrollo Q4 2025
   - Establecer checkpoints semanales de progreso

3. **Ejecución:**
   - **Inicio:** Semana 1 de noviembre 2025
   - **Checkpoints:** Viernes de cada semana
   - **Cierre:** 30 de noviembre 2025

4. **Post-implementación:**
   - Re-ejecutar auditoría F1–F4 para validar cumplimiento de KPIs
   - Actualizar bitácora con métricas finales
   - Archivar documentación de auditoría en `_reports/archive/`

---

## ✅ Criterios de Completitud

Este plan se considerará **COMPLETADO** cuando:

- ✅ Todas las acciones de severidad **Alta** estén ejecutadas (100%)
- ✅ Al menos 80% de acciones de severidad **Media** estén ejecutadas
- ✅ KPIs de cobertura bilingüe ≥90% y visual ≥80%
- ✅ Auditoría F1–F4 re-ejecutada con validación positiva
- ✅ PR #77 mergeado a `develop` con aprobación de 2+ maintainers

---

## 📚 Referencias

- **Plan Maestro:** `docs/content/PLAN_AUDITORIA_CONTENIDO_IMAGENES.md`
- **Bitácora:** `_reports/BITACORA_AUDITORIA_V2.md`
- **PR de seguimiento:** #77 (`feat/content-audit-v2-phase1`)
- **Inventarios base:**
  - F1: `research/content_audit_v2/01_pages_inventory.md`
  - F2: `research/content_audit_v2/02_images_inventory.md`
  - F3: `research/content_audit_v2/03_text_image_matrix.md`
  - F4: `research/content_audit_v2/04_bilingual_gap_report.md`

---

**Documento generado automáticamente por automation-runart**  
**Última actualización:** 2025-10-30T15:49:58Z
