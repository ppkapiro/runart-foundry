# Dashboard Owner — Draft
**Última actualización:** 2025-10-08  
**Responsable:** Equipo técnico UI  

## Objetivo
Proveer a la dirección (owner) visibilidad inmediata de actividad reciente, decisiones pendientes y métricas críticas del micrositio.

## Mock interactivo
<div class="ra-dash-preview" data-runart-dashboard="owner" aria-label="Vista previa dashboard owner"></div>

## Wireframe propuesto
```
┌──────────────────────────────────────────────────────────────┐
│ Barra superior (userbar)                                     │
├───────────────┬───────────────────────────────┬──────────────┤
│ Actividad      │ Bandeja prioritaria           │ Automatización│
│ reciente (A)   │ (B)                            │ status (C)    │
├───────────────┴───────────────────────────────┴──────────────┤
│ Alertas Access (D) + métricas p95              │               │
├──────────────────────────────────────────────────────────────┤
│ Registro de decisiones destacadas (E)                         │
└──────────────────────────────────────────────────────────────┘
```
- **A**: tabla cronológica (máx. 6 filas) con ícono por tipo de evento.
- **B**: carrusel de tarjetas con prioridad y CTA “Ir a inbox”.
- **C**: tres badges (`docs-lint`, `env-report`, `status-update`) con tooltips y enlace a run.
- **D**: mosaico de métricas (`role_unknown`, `error_5xx`, `latency_p95_ms`) con semáforos.
- **E**: timeline horizontal de decisiones estratégicas.

### Breakpoints
- `≥1024px`: layout 3 columnas; C colapsa a badges horizontales.
- `768–1023px`: A y B en bloque vertical, C y D comparten fila.
- `<768px`: pila lineal con collapsibles para C y D.

## Contenido dinámico por sección
| Sección | Fuente | Tratamiento |
| --- | --- | --- |
| Actividad reciente | `/api/logs/activity?role=owner&limit=6` | Agrupar por día; mostrar etiqueta `ago` calculada client-side. |
| Bandeja prioritaria | `/api/inbox?owner_view=true` | Ordenar por `priority`, destacar vencidos. |
| Automatizaciones | `tools/api/workflow-status` (mock → GitHub API) | Badge verde = `success`, ámbar = `in_progress/queued`, rojo = `failure`. |
| Alertas Access | Observabilidad (`alerts.role_unknown`, etc.) | Mostrar timestamp del último corte. |
| Decisiones destacadas | `/api/logs/activity?type=decision_created` | Convertir a timeline con chip de estado (pendiente/cerrada). |

## Estados vacíos y degradados
- **Sin actividad**: mostrar ilustración y CTA “Revisar decisiones históricas”.
- **API fallida**: mensaje contextual y log `ui.dashboard.error` con stack.
- **Workflow sin datos**: badge gris con mensaje “Aún sin corridas registradas”.

## Reglas de visibilidad
- Mostrar toggle “Ver como” cuando `role=owner` (sincronizado con `localStorage.runart:viewas`).
- Activar modo “presentación” (pendiente) ocultando números sensibles al presionar `P`.

## Checklist de implementación
- [x] Diseñar layout responsive con tarjetas a dos columnas en desktop / una en mobile.
- [ ] Definir componentes en `docs/assets/runart/dash-owner.js` (archivo pendiente).
- [ ] Conectar fetch real de `/api/logs/activity` con fallback a mock.
- [ ] Documentar fixtures en `_reports/ui_context/<timestamp>/owner/`.

## Evidencias
- `_reports/ui_context/20251011T153200Z/wireframe_owner.md` (wireframe v1).
