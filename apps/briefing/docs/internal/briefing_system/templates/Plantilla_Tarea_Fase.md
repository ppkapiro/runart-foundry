---
title: Plantilla — Tarea por Fase RunArt Briefing
---
# Plantilla · Tarea por Fase — RunArt Briefing

> **Uso:** duplica este archivo en `templates/instancias/` (crear carpeta si no existe) y renómbralo `F#_<nombre_tarea>.md`. Cada fase puede tener múltiples tareas activas, pero todas deben seguir el formato para asegurar trazabilidad.

## Identificación
- **Fase:** <!-- F1 / F2 / F3 / F4 -->
- **Nombre de la tarea:** <!-- Ej: F1_Normalizar_Menu_Interno -->
- **Responsable principal:** <!-- Nombre -->
- **Colaboradores:** <!-- Nombres -->
- **Fecha de inicio:** <!-- YYYY-MM-DD -->
- **Fecha objetivo de cierre:** <!-- YYYY-MM-DD -->
- **Reporte de avance asociado:** <!-- enlace relativo a reports/ -->
- **Bitácora 082 referencia:** [082 — Reestructuración local Briefing](../ci/082_reestructuracion_local.md)

## Objetivo y alcance
- **Objetivo breve:** <!-- ¿Qué se busca lograr? -->
- **Deliverables esperados:**
  - [ ] <!-- Deliverable 1 -->
  - [ ] <!-- Deliverable 2 -->

## Plan de ejecución
| Paso | Descripción | Responsable | Estado | Evidencia |
| --- | --- | --- | --- | --- |
| 1 | <!-- Ej: Auditar navegaciones MkDocs --> | <!-- --> | <!-- Pendiente --> | <!-- enlace --> |
| 2 | <!-- --> | <!-- --> | <!-- --> | <!-- --> |
| 3 | <!-- --> | <!-- --> | <!-- --> | <!-- --> |

## Checklist QA mínima
- [ ] Validaciones ejecutadas según fase (ver [Guía QA](../guides/Guia_QA_y_Validaciones.md)).
- [ ] Logs adjuntos en reporte de avance.
- [ ] QA responsable firmó en el reporte.

## Checklist por fase (marcar solo la que aplique)
### F1 — Documentación
- [ ] Placeholders completados.
- [ ] Navegación MkDocs validada.
- [ ] Inventario actualizado en `reports/`.

### F2 — Corrección técnica
- [ ] Nomenclatura `role/rol` alineada.
- [ ] Pipelines y smokes en verde.
- [ ] Changelog actualizado.

### F3 — Roles y delegaciones
- [ ] `roles.json` y KV sincronizados.
- [ ] Políticas de acceso documentadas.
- [ ] Dashboards revisados con owner/team/client.

### F4 — Cierre operativo
- [ ] Release note generado.
- [ ] Reporte final consolidado.
- [ ] Archivos y lecciones archivadas en `archives/`.

## Riesgos y bloqueos
| Riesgo/Bloqueo | Impacto | Mitigación | Estado |
| --- | --- | --- | --- |
| <!-- --> | <!-- Alto/Medio/Bajo --> | <!-- --> | <!-- Abierto/Cerrado --> |

## Bitácora específica de la tarea
> Registrar notas breves, decisiones y acuerdos. Añadir marcas de tiempo ISO (`2025-10-08T15:45Z`).

- <!-- 2025-10-08T15:45Z · Nota o acuerdo -->
- <!-- -->

## Cierre de tarea
- **Fecha de cierre:** <!-- YYYY-MM-DD -->
- **Reporte final referenciado:** <!-- enlace -->
- **Comentario publicado en bitácora 082:** <!-- URL/anchor -->
- **Lecciones aprendidas / follow-ups:**
  - <!-- -->

---
**Historial del documento**
- 2025-10-08 · Plantilla base creada por Copilot.
