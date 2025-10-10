# Wireframe v1 — Dashboard Client Admin
**Fecha:** 2025-10-08T16:05Z  
**Responsable:** Copilot

## Layout
- Banner superior con resumen de pendientes críticos.
- Grid 2 columnas (solicitudes abiertas, accesos recientes).
- Bloque inferior con guías destacadas, CTA contacto y barra de progreso general.

## Consideraciones UX
- Filtros rápidos por estado de tarea (Urgente, Próximo, Completado).
- Integración de iconografía consistente con la guía de estilos.
- Tooltips explicativos en accesos para diferenciar inicio de sesión exitoso vs. fallido.

## Estados contemplados
- Sin tareas: mensaje positivo y enlace a crear solicitud.
- Sin accesos: indicador del último login registrado.
- Error: banner amarillo con botón reintentar.

## Próximos pasos
- Implementar consulta filtrada por dominio en `LOG_EVENTS`.
- Definir YAML de enlaces rápidos y contactos.
- Preparar mock data y capturas.
