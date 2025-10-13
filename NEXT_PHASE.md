<<<<<<< HEAD
# Próxima etapa — Alcance propuesto

1) Accesos por rol (admin/equipo/cliente):
   - Resolución de rol vía Access (/api/whoami).
   - “Ver como” en admin (solo vista).
   - Pruebas de acceso (admin/equipo/cliente).

2) CSS/UI:
   - Base de tema, tokens y componentes mínimos.
   - A11Y foco y estados (loading/error/success) unificados.

3) (Opcional) Hardening:
   - Rate-limit, Origin/Referer estricto, validación server vs. schema.

4) Recursos internos:
   - Publicación real de audits/scripts/assets o mantener neutralización con toggle.
=======
# Próxima etapa — Fase 6 (preparación)

## Objetivo general
Activar datos reales y sesiones "Ver como" sobre la base consolidada de Fase 5, automatizar guardias QA/observabilidad y lanzar el ecosistema de paquetes compartidos pendiente.

## Tablero de streams
| Stream | Objetivos clave | Artefactos esperados | Responsable sugerido | Estado |
| --- | --- | --- | --- | --- |
| Sesiones "Ver como" y datos reales | Ejecutar walkthroughs owner/client_admin/team con capturas y poblar dashboards con datos Access reales. | `_reports/access_sessions/<timestamp>/`, `_reports/ui_context/<timestamp>/capturas`, dashboards `/dash/*` con data real | Operaciones + Equipo técnico | � Planificación |
| QA y reporting continuo | Calendarizar `docs-lint`, `env-report`, `status-update`, documentar owners y publicar sumarios. | `_reports/qa_runs/<timestamp>/`, actualización `ops/qa_guardias.md`, agenda en `STATUS.md` | DevOps | 🟡 Preparación |
| Observabilidad automatizada | Implementar notificaciones/alertas y validar disparos con `tools/log_events_summary.py`. | `docs/internal/.../ops/observabilidad.md` §Alertas, logs de prueba, checklist | Observabilidad | 🟡 Preparación |
| Ecosistema de paquetes | Inicializar `packages/env-banner`, migrar scripts prioritarios a `tools/` y publicar roadmap releases. | `packages/env-banner/` v0.1.0, `docs/internal/.../plans/releases.md`, scripts portados | Plataforma | ⏳ Pendiente |

### Calendario tentativo de hitos (T+)
| Semana | Hito | Responsable | Evidencia requerida |
| --- | --- | --- | --- |
| T+1 | Auditoría de UI y wireframes por rol completados | Equipo técnico | Checklist en reporte F5 + mockups almacenados |
| T+2 | Primera sesión "Ver como" documentada (owner) | Operaciones | `_reports/access_sessions/<timestamp>/owner` + actualización guía |
| T+3 | Workflows `docs-lint` y `status-update` activados en `main` | DevOps | Logs en `_reports/qa_runs/` + playbook publicado |
| T+4 | Alertas `LOG_EVENTS` con notificación piloto | Observabilidad | Log de disparo + anexo en `ops/observabilidad.md` |
| T+5 | `packages/env-banner` 0.1.0 liberado y scripts migrados | Plataforma | README del paquete + registro en `plans/releases.md` |

## Próximos entregables inmediatos (T+7 días)
- [ ] Ejecutar sesión "Ver como" (owner) y completar plantilla correspondiente.
- [ ] Registrar primera corrida programada de `docs-lint` + `status-update` en `_reports/qa_runs/`.
- [ ] Anexar log de prueba de alertas `LOG_EVENTS` en `ops/observabilidad.md`.
- [ ] Bootstrapping de `packages/env-banner` con README y build inicial.

## Dependencias
- Accesos reales activos (`_reports/kv_roles/20251009T2106Z/`).
- Coordinación con stakeholders para autorizar capturas y sesiones.
- Tokens/secretos listos para workflows de GitHub Actions.

## Mirando más allá (pre-backlog complementario)
- Extender dashboards a reportes operativos (CAL/CRM) tras completar sesiones reales.
- Automatizar publicación de métricas `LOG_EVENTS` hacia stakeholders.
- Evaluar nuevos paquetes compartidos (`packages/access-auditor`, `packages/mkdocs-widgets`).
>>>>>>> chore/bootstrap-git
