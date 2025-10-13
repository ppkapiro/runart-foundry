# Wireframe v1 — Dashboard Team
**Fecha:** 2025-10-08T16:06Z  
**Responsable:** Copilot

## Layout
- Encabezado con filtros por módulo y botones rápidos (Daily, Retrospectiva, QA).
- Kanban central con cuatro columnas y contador de tarjetas.
- Panel lateral con incidencias, deploys recientes y métricas SLA.

## Interacción
- Cards Kanban muestran responsable, due date y etiquetas.
- Incidencias enlazan directamente al archivo en `INCIDENTS.md` o al ticket.
- Deploys incluyen enlaces a Cloudflare Pages y GitHub Actions.

## Estados
- Sin tareas: CTA para abrir plantilla `Plantilla_Tarea_Fase`.
- Sin incidents: mensaje “Todo estable” con emoji.
- Métricas fuera de rango: semáforo cambia a rojo y aparece tooltip con recomendación.

## Próximos pasos
- Implementar parser de `NEXT_PHASE.md`.
- Conectar pipeline con issues GitHub.
- Generar mock JSON para SLA y deploys.
