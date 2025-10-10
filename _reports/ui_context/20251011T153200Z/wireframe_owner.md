# Wireframe v1 — Dashboard Owner
**Fecha:** 2025-10-08T16:05Z  
**Responsable:** Copilot  

## Layout
- Cabecera: userbar existente + botón “Ver como”.
- Sección principal con grid 3 columnas (actividad, bandeja, automatizaciones).
- Fila inferior con mosaico de alertas y timeline de decisiones.

## Estados contemplados
- Éxito: widgets con datos en vivo y badges de color.
- Vacío: placeholder ilustrado con CTA de navegación.
- Error: mensaje contextual y registro `ui.dashboard.error`.

## Notas de interacción
- Tooltips con detalles de cada workflow.
- Scroll independiente para actividad cuando supera 6 filas.
- Toggle “modo presentación” planificado para ocultar datos sensibles durante demos.

## Próximos pasos
- Construir componentes JS.
- Preparar mock de `workflow-status`.
- Capturar evidencia una vez desplegado.
