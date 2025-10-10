# Dashboard Client — Draft
**Última actualización:** 2025-10-08  
**Responsable:** Equipo técnico UI  

## Objetivo
Ofrecer a los clientes una vista simplificada con acceso a fichas, entregables recientes y formularios disponibles.

## Mock interactivo
<div class="ra-dash-preview" data-runart-dashboard="client" aria-label="Vista previa dashboard client"></div>

## Wireframe propuesto
```
┌──────────────────────────────────────────────────────────────┐
│ Bienvenida + resumen proyecto (banner hero)                  │
├───────────────────────┬──────────────────────────────────────┤
│ Contenido actualizado (A) | Próximos hitos (B)               │
├───────────────────────┴──────────────────────────────────────┤
│ Formularios activos (C)                                     │
├──────────────────────────────────────────────────────────────┤
│ Soporte y contactos (D)                                     │
└──────────────────────────────────────────────────────────────┘
```
- **A**: cards horizontales con título, fecha y etiqueta (Nueva/Actualizada).
- **B**: minicalendario semana vista + listado resumido.
- **C**: tiles con CTA “Completar” + estimación tiempo.
- **D**: bloque de contacto con foto/avatar opcional y botones (email, Slack, teléfono).

### Breakpoints
- Desktop: banner ancho completo, A y B en 2 columnas.
- Tablet: A y B se apilan; C y D ocupan 100%.
- Mobile: cada sección convertida en acordeón con CTA siempre visible.

## Contenido dinámico
| Sección | Fuente | Tratamiento |
| --- | --- | --- |
| Banner bienvenida | Config YAML `ui_dashboards.yml` (`hero_message`) | Soporta markdown para resaltar mensajes clave. |
| Contenido actualizado | `/api/content/recent?audience=client` | Limitar a 4; iconos según tipo de ficha. |
| Próximos hitos | `NEXT_PHASE.md` (`Calendario tentativo`) filtrado para cliente | Mostrar fecha, responsable y enlace a detalle. |
| Formularios activos | Config `forms.active` en YAML | Ordenar por prioridad; indicador de fecha límite. |
| Soporte y contactos | Config `contacts.default` o específico | Mostrar disponibilidad “L–V 09:00–18:00 ET”. |

## Estados y mensajes
- Sin contenido reciente: mensaje “Último update el dd/mm” + enlace a historial.
- Sin hitos próximos: mostrar CTA “Coordinar revisión de roadmap”.
- Formularios vacíos: banner recordando que no hay acciones pendientes.

## Reglas de visibilidad
- Ocultar secciones internas automáticamente (no mostrar workflow ni incidentes).
- CTA “Ver todo” redirige a `/client_projects/runart_foundry/index.md`.

## Checklist de implementación
- [x] Diseñar layout amigable con íconos y CTA claros.
- [ ] Configurar dataset de contactos per-client.
- [ ] Implementar feed de contenidos en orden cronológico inverso.
- [ ] Documentar capturas en `_reports/ui_context/<timestamp>/client/`.

## Evidencias
- `_reports/ui_context/20251011T153200Z/wireframe_client.md` (wireframe v1).
