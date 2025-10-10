# Scaffolding dashboards `/dash/*`
**Fecha:** 2025-10-08T15:45Z  
**Responsable:** Copilot  

## Alcance
- Creación de estructura `docs/internal/briefing_system/ui/` con índice central.
- Plantillas iniciales para `/dash/{role}` (owner, client_admin, team, client, visitor).
- Documento `contrato_datos.md` con el contrato preliminar de APIs y fuentes.

## Detalles relevantes
1. **Estructura de documentación**
   - `docs/internal/briefing_system/ui/index.md` presenta tabla de roles, entregables y protocolo de actualización.
   - Cada rol cuenta con checklist de widgets, fuentes y evidencias esperadas.
2. **Contrato de datos**
   - Se definieron payloads esperados para `/api/whoami`, `/api/logs/activity`, `/api/inbox`, métricas de observabilidad y configuración estática.
   - Se propuso almacenamiento central de enlaces/contactos en `config/ui_dashboards.yml` (pendiente de implementación).
3. **Navegación MkDocs**
   - `mkdocs.yml` expone sección “UI contextual por rol” con enlaces a todos los dashboards y contrato de datos.

## Pendientes derivados
- Diseñar wireframes definitivos por rol.
- Implementar mocks de datos y componentes JS.
- Capturar evidencias por rol con datos reales una vez desplegado.

## QA
- `make lint` (2025-10-08T15:58Z) → ✅ sin advertencias adicionales.
