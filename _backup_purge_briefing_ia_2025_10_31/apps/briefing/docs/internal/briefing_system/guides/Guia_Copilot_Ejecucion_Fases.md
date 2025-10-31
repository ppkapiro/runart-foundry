---
title: Guía Copilot — Ejecución por Fases
---
# Guía Operativa para Copilot — RunArt Briefing

**Última actualización:** 2025-10-08  
**Responsable de mantenimiento:** Copilot (asistente) junto a Project Manager (Reinaldo)

## Propósito
Establecer un flujo consistente para que Copilot ejecute las fases del [Plan Estratégico de Consolidación](../plans/Plan_Estrategico_Consolidacion_Runart_Briefing.md). La guía detalla cómo identificar la fase activa, qué artefactos instanciar, qué evidencias capturar y dónde registrar cada hito. Debe consultarse al inicio de cada intervención y actualizarse con aprendizajes relevantes.

## Principios del flujo
1. **Una sola fase activa a la vez.** Toda tarea se atribuye explícitamente a F1–F4.
2. **Artefactos obligatorios.** Cada fase genera tareas (`templates/`) y reportes (`reports/`). Nada se marca como "hecho" sin evidencia cargada.
3. **Bitácora viva.** La bitácora [082 — Reestructuración local Briefing](../ci/082_reestructuracion_local.md) recibe un comentario al cierre de cada fase con enlaces a las evidencias generadas.
4. **QA integrado.** Las validaciones descritas en la [Guía de QA y Validaciones](./Guia_QA_y_Validaciones.md) son parte del Definition of Done y se documentan en el reporte de avance.

## Preparación previa a cualquier fase
- Leer el estado de `STATUS.md` y confirmar prioridades con el Project Manager.
- Verificar si existe un reporte de avance previo en `reports/` y continuar la numeración.
- Revisar incidencias abiertas o pendientes en `audits/` y `ci/` para evitar solapamientos.
- Configurar variables de entorno necesarias (`PREVIEW_URL`, `PROD_URL`) antes de ejecutar comandos de QA.

## Ciclo de trabajo por fase
1. **Identificar fase y alcance.** Consultar la tabla "Estructura por fases" del plan estratégico. Confirmar con Reinaldo si hay ajustes de alcance o responsables.
2. **Instanciar artefactos obligatorios.**
   - Crear una tarea derivada usando la [Plantilla de Tarea por Fase](../templates/Plantilla_Tarea_Fase.md). Guardarla en `templates/instancias/` o la carpeta operativa definida para la fase.
   - Abrir o crear el reporte de avance correspondiente (`reports/`).
3. **Ejecutar acciones de la fase.**
   - Seguir las acciones prioritarias descritas en el plan.
   - Registrar decisiones relevantes en la bitácora 082.
   - Si se tocan roles o Access, coordinar con seguridad y documentar en `guides/`.
4. **Validar y documentar.**
   - Ejecutar el set de QA indicado para la fase (ver guía QA).
   - Completar la sección de evidencias en el reporte.
   - Actualizar la bitácora 082 con resumen + enlaces a reporte, tareas y commits.
5. **Cerrar y solicitar revisión.**
   - Notificar a Reinaldo/Uldis según la fase, adjuntando enlace al reporte.
   - Enviar resumen al canal interno que corresponda (Slack/Teams) con el estado general.

## Autoavance (orquestador)
1. **Leer el orquestador.** Abrir `plans/00_orquestador_fases_runart_briefing.md`, resolver `AUTO_CONTINUE` y detectar la primera fase con estado `running` o `pending`.  
2. **Evaluar el reporte de fase.** Abrir el documento enlazado en la tabla:  
   - Si contiene un bloque “Sello de cierre” con `DONE: true`, tomar sus valores (`CLOSED_AT`, `SUMMARY`, `ARTIFACTS`, `NEXT`) y volver al orquestador para marcar la fila como `done` con el timestamp indicado.  
   - Si el sello está en `DONE: false`, ejecutar sus acciones pendientes en orden, registrando avances y timestamps en el propio reporte (sección “Bitácora de avances”) y en la bitácora 082.  
3. **Ejecutar QA y sellar.** Tras completar las acciones:  
   - Ejecutar `make lint` / `mkdocs build --strict`.  
   - Registrar el resultado “QA: PASS” (y “Smokes simulados: PASS” si aplica) dentro del sello de cierre.  
   - Actualizar `DONE: true`, `CLOSED_AT` (UTC), `SUMMARY`, `ARTIFACTS` y `NEXT`.  
4. **Sincronizar artefactos.**  
   - En el orquestador, cambiar el estado de la fase a `done`, registrar el nuevo timestamp y, si existe una siguiente fase, moverla a `running`.  
   - Ejecutar el hook de la Bitácora 082: añadir el bloque de cierre si aún no existe (formato `#### ✅ Cierre [...]`).  
5. **Control de loop.**  
   - Si `AUTO_CONTINUE == true`, repetir desde el paso 1 inmediatamente.  
   - Si `AUTO_CONTINUE == false`, preguntar “¿Continuar con la siguiente fase?” y pausar hasta recibir confirmación humana.  
6. **Idempotencia garantizada.** Cada ciclo debe verificar si el sello y el bloque de bitácora ya existen antes de escribir; no duplicar registros ni revertir fases cerradas.  

## Checklist rápida por fase
| Fase | Antes de empezar | Durante | Cierre |
| --- | --- | --- | --- |
| **F1 — Documentación** | Confirmar inventario inicial · Instanciar plantilla de tarea `F1` | Completar placeholders críticos · Alinear navegación MkDocs · Registrar inventario inicial | Ejecutar QA documental · Completar reporte F1 · Comentario en bitácora 082 |
| **F2 — Correcciones técnicas** | Revisar bugs conocidos · Planificar normalización `role/rol` | Actualizar código/middleware · Correr QA extendido (lint, build, smokes) | Registrar resultados QA · Actualizar changelog · Comentario en bitácora 082 |
| **F3 — Roles y delegaciones** | Validar Access y roles vigentes · Coordinar con seguridad | Ajustar `roles.json`/KV · Documentar políticas · Verificar dashboards | Evidencias de Access (capturas/logs) · Actualizar guías · Comentario en bitácora 082 |
| **F4 — Cierre operativo** | Revisar backlog residual · Confirmar entregables finales | Preparar release note · Consolidar lecciones aprendidas | Reporte final firmado · Archivar documentos en `archives/` · Comentario en bitácora 082 |

## Gestión de artefactos
- **Plantillas de tareas:** cada fase tiene un bloque en `Plantilla_Tarea_Fase.md`. Completa los campos y guarda el archivo derivado con formato `F#_<tema>.md`.
- **Reportes de avance:** utiliza `Plantilla_Reporte_Avance.md` para documentar sesión, validaciones y próximos pasos. Mantén un archivo por fase o por semana (acordado con Project Manager).
- **Archivos complementarios:** capturas, logs y artefactos pesados van a `archives/` o `_tmp/` según corresponda, referenciados desde el reporte.

## Roles y comunicación
- **Project Manager (Reinaldo):** aprueba cierres de fase, prioriza backlog y valida entregables.
- **Copilot + Dev asignado:** ejecutan tareas, mantienen guías y plantillas, registran QA.
- **Quality Owner:** revisa reportes y valida que los checks estén verdes antes del cierre.
- **Stakeholder (Uldis López):** recibe demostraciones en los hitos acordados (F2 y F4 mínimo).

## Reglas de gobernanza
- No se abren PRs ni merges sin que el reporte de la fase tenga estado "QA completado".
- Los enlaces en documentación deben ser relativos y validados con `mkdocs build --strict`.
- Cada archivo nuevo debe respetar la estructura descrita en `docs/proyecto_estructura_y_gobernanza.md`.
- Las excepciones a la guía deben quedar justificadas en la bitácora correspondiente.

## Próxima revisión de la guía
- Programada para el inicio de F3 o antes si se detecta un gap operativo.
- Sugerencias o mejoras: abrir issue interno bajo `ci/` o anotar en el reporte de avance de la fase activa.
