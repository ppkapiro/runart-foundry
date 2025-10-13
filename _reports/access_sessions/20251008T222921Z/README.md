# Evidencia — Sesiones "Ver como" Fase 5

**Timestamp carpeta:** 2025-10-08T22:29:21Z (UTC)

## Alcance
Preparar y documentar las sesiones "Ver como" para los roles principales del micrositio Briefing:

- Owner (dirección RunArt)
- Client Admin (coordinadores del cliente)
- Team (producción interna RunArt)
- Client (usuarios invitados con acceso restringido)
- Visitor (visitante sin autenticación Access)

## Estado actual
> ⚠️ Sesiones reales aún pendientes de ejecutar a la espera de credenciales autorizadas y ventana operativa con stakeholders. Esta carpeta contiene plantillas y guías previas al registro audiovisual definitivo.

## Plan de cada sesión
| Rol | Objetivo de la sesión | Evidencia a capturar | Responsable | Estado |
| --- | --- | --- | --- | --- |
| Owner | Validar userbar, bandejas globales y dashboards `/dash/owner`. | Video corto + 3 capturas clave (userbar, dashboard, acciones críticas). | Copilot + Dirección RunArt | 🟡 Programada |
| Client Admin | Verificar tareas pendientes del cliente y dashboard `/dash/client_admin`. | 3 capturas (inbox, métricas de dominio, alertas) + notas de audio opcional. | Copilot + Coordinación cliente | 🟡 Programada |
| Team | Revisar bandeja operativa y widgets de producción. | 2 capturas (pipeline tareas, reportes recientes) + checklist completado. | Equipo Briefing | 🟡 Programada |
| Client | Asegurar experiencia simplificada con acceso a fichas/galería. | 2 capturas (home, ficha) + confirmación de restricciones (403 en acciones avanzadas). | Operaciones | 🟡 Programada |
| Visitor | Comprobar mensajes de acceso restringido y redirecciones. | 1 captura (pantalla de acceso) + resultado curl `/api/inbox` → 403. | QA | 🟡 Programada |

Plantillas por rol:
- Owner → `owner_session_template.md`
- Client Admin → `client_admin_session_template.md`
- Team → `team_session_template.md`
- Client → `client_session_template.md`
- Visitor → `visitor_session_template.md`

## Checklist previo a cada grabación
1. Confirmar vigencia de credenciales en `_reports/kv_roles/20251009T2106Z/`.
2. Revisar el valor de `RUNART_ENV` mediante `tools/check_env.py --mode http` (preview o prod según entorno a usar).
3. Definir hosting seguro para videos (carpeta interna o enlace restringido). Los archivos deberán compartirse aparte; aquí sólo se registran rutas/links.
4. Activar `wrangler tail` para detectar errores en tiempo real y anotar incidentes.
5. Completar la hoja de ruta correspondiente en Bitácora 082 (sección Ver como).

## Plantillas de notas
- **Ficha rápida (por sesión):**
  - Fecha/hora (UTC y local)
  - Rol participante
  - Entorno (`preview` / `prod`)
  - URL principal visitada
  - Check de userbar (`OK/FAIL`)
  - Check de dashboard (`OK/FAIL`)
  - Incidencias detectadas (enlazar a issue si aplica)
  - Capturas guardadas en: `captures/<rol>/` (crear carpeta por rol)
- **Resumen diario:** consolidar observaciones y próxima sesión.

## Próximos pasos
- [ ] Confirmar ventana con stakeholders y autorizar grabaciones.
- [ ] Ejecutar sesión Owner (prioridad alta) y guardar material en `captures/owner/`.
- [ ] Iterar resto de roles, completando la tabla de estado.
- [ ] Actualizar `docs/internal/briefing_system/guides/Guia_QA_y_Validaciones.md` con resultados y enlaces definitivos.

---
_Revisión pendiente tras capturar las sesiones reales: completar esta carpeta con subdirectorios `captures/<rol>/`, notas estructuradas y resúmenes firmados._
