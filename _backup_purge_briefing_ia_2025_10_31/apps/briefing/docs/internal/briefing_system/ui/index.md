# UI Contextual por Rol
**Versión:** v0.1 — 2025-10-08  
**Ubicación:** `docs/internal/briefing_system/ui/`  
**Propósito:** Centralizar el diseño y la implementación de las vistas `/dash/*` y componentes asociados a la userbar contextual del micrositio Briefing.

## Roles cubiertos
| Rol | Ruta target | Responsable | Estado |
| --- | --- | --- | --- |
| owner | `/dash/owner/` | UI · Equipo técnico | ✅ Wireframe v1 aprobado |
| client_admin | `/dash/client-admin/` | UI · Equipo técnico | ✅ Wireframe v1 aprobado |
| team | `/dash/team/` | UI · Equipo técnico | ✅ Wireframe v1 aprobado |
| client | `/dash/client/` | UI · Equipo técnico | ✅ Wireframe v1 aprobado |
| visitor | `/dash/visitor/` | UI · Equipo técnico | ✅ Wireframe v1 aprobado |

## Entregables inmediatos
1. Definir widgets mínimos por rol (actividad reciente, accesos, tareas asignadas).
2. Alinear la userbar con estados de sesión (`/api/whoami`) y exponer chips de rol.
3. Documentar contratos de datos y fuentes (Access, KV, LOG_EVENTS).
4. Publicar capturas autorizadas en `_reports/ui_context/<timestamp>/` y registrar sesiones "Ver como" en `_reports/access_sessions/20251008T222921Z/` (o timestamp vigente).

## Vínculos relevantes
- [Reporte Fase 5](../reports/2025-10-11_fase5_ui_contextual_y_experiencias_por_rol.md)
- [Bitácora 082](../ci/082_reestructuracion_local.md)
- [Contrato de datos](contrato_datos.md)
- [Guía de estilos UI](../../../ui/estilos.md)
- Evidencias wireframes: `_reports/ui_context/20251011T153200Z/`

## Protocolo de actualización
- Mantener esta tabla sincronizada con el roadmap del reporte de fase.
- Adjuntar enlace a evidencias en `_reports/ui_context/` por cada rol una vez publicado.
- Registrar cambios significativos en la Bitácora 082 y estado general en `STATUS.md`.
