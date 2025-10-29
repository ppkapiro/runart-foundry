# Dashboard Client Admin — Draft
**Última actualización:** 2025-10-08  
**Responsable:** Equipo técnico UI  

## Objetivo
Facilitar a los responsables de cliente la gestión diaria de contenidos, aprobaciones y coordinación con el equipo RunArt.

## Mock interactivo
<div class="ra-dash-preview" data-runart-dashboard="client_admin" aria-label="Vista previa dashboard client admin"></div>

## Wireframe propuesto
```
┌──────────────────────────────────────────────────────────────┐
│ Banner de estado (pendientes críticos)                       │
├───────────────────────────┬──────────────────────────────────┤
│ Solicitudes abiertas (A)  │ Accesos recientes (B)            │
├───────────────────────────┴──────────────────────────────────┤
│ Guías destacadas (C) + CTA contacto                          │
├──────────────────────────────────────────────────────────────┤
│ Progreso de entregables (D)                                  │
└──────────────────────────────────────────────────────────────┘
```
- **A**: tabla con filtros rápidos (Urgente / Próximos 7 días / Completadas).
- **B**: feed de sesiones con avatar, correo y dispositivo.
- **C**: tarjetas con iconografía y descripción breve; CTA lateral “Contactar equipo”.
- **D**: barra stacked con porcentaje por fase + chips de próxima reunión.

### Breakpoints
- `≥1024px`: A y B en dos columnas 60/40.
- `768–1023px`: banner y A ocupan ancho completo; B y C se apilan.
- `<768px`: componente acordeón por sección.

## Contenido dinámico
| Sección | Fuente | Tratamiento |
| --- | --- | --- |
| Banner estado | `/api/inbox?summary=1` | Mostrar número de tareas críticas y fecha más próxima. |
| Solicitudes abiertas | `/api/inbox?assigned_to=client_admin` | Ordenar por `due_date`; chips de prioridad. |
| Accesos recientes | `/api/logs/activity?event=login_success&domain=runartfoundry.com` | Limitar a 10; resaltar intentos fallidos. |
| Guías destacadas | `config/ui_dashboards.yml` | Renderizar tiles con icono + descripción. |
| Progreso entregables | `STATUS.md` parseado (`Prioridades inmediatas`) | Mapear estado a porcentaje (meta 100% = completado). |

## Estados y mensajes
- Sin solicitudes: tarjeta con mensaje “¡Todo al día!” y enlace para crear nueva decisión.
- Sin accesos recientes: mostrar nota “Último acceso registrado hace X días”.
- Error API: fallback con botón “Reintentar” y logging.

## Reglas de visibilidad
- Banner solo aparece si existen tareas `priority=high` o `due_date <= hoy+2`.
- CTA de contacto configurable por cliente en YAML (`contacts`).

## Checklist de implementación
- [x] Definir estructura de tarjetas enfocada en fechas límite.
- [ ] Integrar filtro `domain` en consulta de `LOG_EVENTS`.
- [ ] Añadir mensajes vacíos amigables cuando no haya tareas.
- [ ] Capturar evidencia en `_reports/ui_context/<timestamp>/client_admin/`.

## Evidencias
- `_reports/ui_context/20251011T153200Z/wireframe_client_admin.md` (wireframe v1).
