# Plan Estratégico de Consolidación — RunArt Briefing
**Versión:** v0.1 — 2025-10-08  
**Ubicación:** apps/briefing/docs/internal/briefing_system/plans  
**Propósito:** Documento de referencia para la ejecución guiada del proyecto RunArt Briefing.  
**Relacionado con:** [Plan_Estrategico_Consolidacion_Runart_Briefing.md](./Plan_Estrategico_Consolidacion_Runart_Briefing.md) / [082_reestructuracion_local.md](../ci/082_reestructuracion_local.md) / [Ecosistema_Operativo_Runart.md](../archives/Ecosistema_Operativo_Runart.md)

---

## Propósito del plan
Este plan articula la hoja de ruta integral para consolidar el módulo `apps/briefing/` como el centro operativo de RunArt Foundry. Define fases secuenciales, responsables y criterios de éxito que deberán guiar cualquier intervención futura. Copilot debe consultarlo al inicio de cada ciclo para determinar la fase activa y el alcance correspondiente.

## Visión general
- **Objetivo general:** unificar documentación, automatizaciones y despliegues de Briefing bajo un marco gobernado por fases y evidencias.
- **Alcance:** código (`functions/`, `workers/`), documentación (`docs/`), procesos (CI/CD, QA) y relaciones con Cloudflare Access/Roles.
- **Piezas clave de referencia:**
  - Bitácora [_082 — Reestructuración local_](../ci/082_reestructuracion_local.md)
  - Ecosistema operativo (ver [Ecosistema_Operativo_Runart.md](../archives/Ecosistema_Operativo_Runart.md))
  - Auditoría general 2025-10-08 ([audits/2025-10-08_auditoria_general_briefing.md](../audits/2025-10-08_auditoria_general_briefing.md))

## Estructura por fases
| Fase | Nombre | Objetivo | Entregables clave | Responsable primario | Criterios de éxito |
| --- | --- | --- | --- | --- | --- |
| F1 | Consolidación documental y alineación operativa | Indexar y limpiar documentación, normalizar menús y asegurar referencias cruzadas | Inventario actualizado, plantillas pobladas, menú cliente/interno coherente | Project Manager (Reinaldo) + Copilot | Reducción de placeholders, navegación consistente y reporte de avance registrado |
| F2 | Corrección técnica y normalización | Resolver bugs de APIs/UI, alinear nomenclatura (`role/rol`), estabilizar pipelines | Fixes desplegados, validaciones verdes, QA documentado | Equipo técnico (Copilot + dev asignado) | Smokes en verde, informes de QA archivados y changelog actualizado |
| F3 | Administración de roles y delegaciones | Ajustar Access, KV y dashboards según roles; documentar políticas | Roles actualizados, dashboards por rol operativos, guía de acceso publicada | Responsable de seguridad (Reinaldo) + Copilot | `/api/whoami` y UI reflejan roles correctos; evidencias en reports/ |
| F4 | Consolidación y cierre operativo | Formalizar release, archivar lecciones, transferir ownership y preparar ciclo siguiente | Reporte final, checklist de cierre, handover documentado | Project Manager | Reporte final firmado, bitácora 082 actualizada, tasks cerradas |

## Detalle de fases
### Fase 1 — Consolidación documental y alineación operativa
- **Acciones prioritarias:**
  - Completar placeholders críticos (`Plan`, `Proceso`, `Galería`, `Dashboards`).
  - Alinear `mkdocs.yml` con archivos reales y etiquetar menús por audiencia.
  - Registrar inventario inicial en `reports/` usando la plantilla de avance.
- **Resultados esperados:** navegación limpia, estructura de carpetas creada y plantillas listas.
- **Dependencias:** auditoría de contenido 2025-10-08, plan estratégico (este doc), bitácora 082.

### Fase 2 — Corrección técnica y normalización
- **Acciones prioritarias:**
  - Normalizar nomenclatura `role/rol` en APIs, middleware y UI.
  - Separar bindings KV y revisar workflows legacy.
  - Ejecutar QA (lint/build/smokes) documentando resultados en `reports/`.
- **Resultados esperados:** código consistente, pipelines en verde, guías actualizadas.
- **Dependencias:** guía QA/Validaciones, reports de F1.

### Fase 3 — Administración de roles y delegaciones
- **Acciones prioritarias:**
  - Ajustar Cloudflare Access (owners, equipo, clientes) y sincronizar `roles.json` + KV.
  - Validar dashboards y userbar con roles reales.
  - Documentar políticas en `guides/` y actualizar bitácora 082.
- **Resultados esperados:** Acceso segmentado, dashboards activos, reporte de roles.
- **Dependencias:** informes técnicos de F2, ecosistema operativo.

### Fase 4 — Consolidación y cierre operativo
- **Acciones prioritarias:**
  - Compilar reporte de cierre (usando plantilla en `reports/`).
  - Actualizar changelog, status y archivos históricos en `archives/`.
  - Preparar plan siguiente (nueva versión o mantenimiento) y comunicar a stakeholders.
- **Resultados esperados:** cierre documentado, handover y backlog próximo definidos.
- **Dependencias:** entregables completados de F3.

## Roles y responsabilidades
| Rol | Nombre / Actor | Responsabilidades |
| --- | --- | --- |
| Project Manager | Reinaldo | Priorizar fases, validar entregables, coordinar comunicación con cliente |
| Technical Lead | Copilot (asistente) + desarrollador asignado | Ejecutar tareas, actualizar documentación, garantizar QA |
| Quality Owner | Equipo QA (por definir) | Revisar validaciones, emitir aprobaciones en `reports/` |
| Stakeholder | Uldis López | Recibir demostraciones, validar narrativa cliente |

## Criterios generales de éxito
1. **Documental:** todos los documentos clave con enlaces activos y sin placeholders críticos.
2. **Técnico:** APIs/UI alineados con roles, pipelines sin fallos, evidencia de QA archivada.
3. **Operativo:** Access configurado, roles verificados, bitácora 082 y ecosistema actualizados.
4. **Governanza:** reportes de avance por fase completados y almacenados en `reports/`.

## Próximos pasos inmediatos
1. Crear guías y plantillas (ver instrucciones en `guides/`).
2. Instanciar plantillas para Fase 1 y registrar primer reporte de avance.
3. Validar con Reinaldo la priorización de tareas antes de intervenir el código.

> **Nota:** Toda fase debe cerrarse con un comentario en la bitácora 082, adjuntando links a la plantilla de tarea y al reporte de avance generado.
