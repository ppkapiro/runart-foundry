# ADR-0001 — Briefing como panel interno permanente

## Contexto
RUN Art Foundry necesita un panel permanente para coordinar decisiones con el cliente, almacenar documentación operativa y publicar entregables (press-kit, fichas técnicas, dashboards). El repositorio `runart-foundry` ya contiene auditorías, scripts y el historial del sitio WordPress del cliente.

## Decisión
Implementar un micrositio **privado** (no indexado), construido con MkDocs Material y desplegado en Cloudflare Pages, que funcione como panel interno. El panel permanecerá en producción como hub de documentación y automatización, aún después de terminar migraciones o entregables puntuales.

## Detalles clave
- El briefing agrupa: roadmap, decisiones, auditorías, reportes y fichas técnicas.
- El acceso está protegido por Cloudflare Access (pendiente de activación definitiva, plan documentado).
- Se integra con Workers KV para almacenar decisiones y formularios de intake.
- Automatizaciones: generación de press-kit en PDF, promoción de fichas desde un inbox, cortes de control.
- El repositorio conserva audit logs (`audits/_logs/`), reportes (`audits/reports/`) y snapshots (`mirror/`).

## Consecuencias
- **Positivas**: Gobernanza centralizada, trazabilidad, despliegues reproducibles, documentación viva.
- **Negativas**: Requiere mantener pipelines de CI/CD y revisar Access periódicamente.
- **Riesgos mitigados**: Se documentan workflows y configuraciones (wrangler, KV, scripts) para rotación de equipo.

## Estado
- ADR aprobado el 1 de octubre de 2025.
- Implementación en curso, desplegada en `https://runart-briefing.pages.dev` (pendiente Access final).
