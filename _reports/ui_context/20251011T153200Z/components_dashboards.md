# Componentes UI y mocks — Dashboards F5
**Fecha:** 2025-10-08T16:25Z  
**Responsable:** Copilot

## Cambios incluidos
- `docs/assets/runart/dashboards.js`: script que renderiza dashboards interactivamente desde un dataset mock (`DATA`) para roles owner, client_admin, team, client y visitor.
- `docs/assets/runart/dashboards.css`: estilos responsive con grid, tarjetas, kanban y métricas.
- Contenedores `<div data-runart-dashboard="…">` añadidos a cada documento `/dash/{rol}.md` para previsualizar la UI.
- Navegación MkDocs actualizada para cargar los nuevos assets (`extra_css` y `extra_javascript`).

## Dataset mock
- Actividad, tareas, workflows y alertas para owner.
- Resumen de pendientes, accesos y progreso para client_admin.
- Kanban + incidentes + deploys para team.
- Contenido actualizado, hitos, formularios y contactos para client.
- Documentos públicos y noticias para visitor.

## QA
- `make lint` (2025-10-08T16:27Z) → ✅ build estricto sin errores.

## Próximos pasos
- Sustituir mocks por integraciones reales (`/api/logs/activity`, `/api/inbox`, GitHub/Cloudflare APIs).
- Añadir modo presentación y soporte para datasets externos (`config/ui_dashboards.yml`).
- Documentar pruebas de accesibilidad una vez implementados los componentes finales.
