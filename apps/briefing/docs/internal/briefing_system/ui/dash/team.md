# Dashboard Team — Draft
**Última actualización:** 2025-10-08  
**Responsable:** Equipo técnico UI  

## Objetivo
Brindar al equipo interno un panel de control operativo con tareas activas, incidencias y métricas de automatización.

## Mock interactivo
<div class="ra-dash-preview" data-runart-dashboard="team" aria-label="Vista previa dashboard team"></div>

## Wireframe propuesto
```
┌──────────────────────────────────────────────────────────────┐
│ Filtro por módulo + botones rápidos (apps/services/tools)    │
├──────────────────────────────────────────────────────────────┤
│ Kanban tareas (A)                                            │
├───────────────────────┬──────────────────────────────────────┤
│ Incidencias (B)        │ Deploys recientes (C)               │
├───────────────────────┴──────────────────────────────────────┤
│ Alertas técnicas (D) + métricas SLA                          │
└──────────────────────────────────────────────────────────────┘
```
- **A**: columnas `Por hacer / En progreso / En revisión / Bloqueadas`.
- **B**: tabla con severidad (Critical, Major, Minor) y enlace a detalle.
- **C**: lista cronológica con estado, commit y enlace a Cloudflare.
- **D**: tarjetas de métricas (errores 5xx, latencia p95, uptime) con sparkline.

### Breakpoints
- Desktop: A ocupa 60% arriba; B y C comparten fila debajo.
- Tablet: Kanban se vuelve carrusel horizontal; B, C y D se apilan.
- Móvil: todas las secciones en acordeón con badges.

## Contenido dinámico
| Sección | Fuente | Tratamiento |
| --- | --- | --- |
| Kanban tareas | Parser `NEXT_PHASE.md` + issues GitHub etiquetadas `team` | Unión por ID, arrastrable (pendiente). |
| Incidencias | `INCIDENTS.md` + repositorio `incidents/` | Mostrar solo incidentes `status!=closed`. |
| Deploys recientes | GitHub Actions (`pages-build-deploy`) + Cloudflare API | Mostrar último 5 con resultado y duración. |
| Alertas técnicas | `ops/observabilidad.md` (API futura) | Comparar con umbrales SLA y colorear. |

## Estados y mensajes
- Sin tareas: mostrar CTA “Crear tarea” con enlace a plantilla.
- Incident feed vacío: mensaje “Sin incidentes abiertos”.
- Deploy sin datos: mostrar nota “Esperando próxima corrida”.

## Reglas de visibilidad
- Mostrar botón “Registrar retrospectiva” cuando existan tareas en `review` > 3 días.
- Highlight rojo en D cuando `error_5xx` > 3 o `latency_p95` > 400ms.

## Checklist de implementación
- [x] Diseñar layout Kanban + métricas.
- [ ] Construir pipeline Kanban basado en `NEXT_PHASE.md`.
- [ ] Integrar feed de incidentes con badges de severidad.
- [ ] Renderizar tabla de deploys con link directo a Cloudflare.
- [ ] Publicar capturas en `_reports/ui_context/<timestamp>/team/`.

## Evidencias
- `_reports/ui_context/20251011T153200Z/wireframe_team.md` (wireframe v1).
