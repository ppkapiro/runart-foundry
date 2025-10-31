# 🧭 Fase 5 — UI Contextual y Experiencias por Rol
**Versión:** v1.0 — 2025-10-11  
**Ubicación:** apps/briefing/docs/internal/briefing_system/reports/  
**Propósito:** Orquestar la consolidación de la experiencia de usuario segmentada por roles en el micrositio Briefing, activar los workflows de QA/reporting automáticos y establecer la base de observabilidad que respalde las operaciones continuas.  
**Relacionado con:**  
- `plans/Plan_Estrategico_Consolidacion_Runart_Briefing.md`  
- `plans/00_orquestador_fases_runart_briefing.md`  
- `ci/082_reestructuracion_local.md`  
- `reports/2025-10-10_fase4_consolidacion_y_cierre.md`  
- `_reports/kv_roles/20251009T2106Z/`

## 1. Objetivos de la fase

## 2. Alcance técnico y documental

## 3. Resultados esperados y entregables
1. **Experiencia UI por rol**  
   - Userbar con datos reales y chips de estado.  
   - Dashboards `/dash/{role}` con widgets mínimos (actividad reciente, accesos, tareas).  
    - Capturas autorizadas alojadas en `_reports/consolidacion_prod/` con referencias en este documento.  
    - _Estado cierre_: Scaffolding documental consolidado y mocks disponibles; datos reales y capturas se trasladan explícitamente a backlog Fase 6.
2. **Flujos "Ver como" operativos**  
   - Guía documentada (`guides/`) con pasos y enlaces a smokes autenticados.  
   - Evidencias en `_reports/access_sessions/2025-10-1x/` con timestamp ISO.  
     - Registro en Bitácora 082 del resultado de cada sesión.  
     - _Estado cierre_: Agenda, plantillas y flujos documentados; ejecución de sesiones y evidencias se difieren por decisión de negocio.
3. **Automatización QA + reporting**  
   - Workflows `docs-lint`, `env-report`, `status-update` activos en `main` y documentados.  
   - Logs iniciales almacenados en `_reports/qa_runs/2025-10-1x/`.  
   - Playbook de respuesta ante fallos en `docs/internal/briefing_system/ops/qa_guardias.md` (nuevo).
4. **Observabilidad y métricas**  
   - Pipeline de ingesta `LOG_EVENTS` normalizada (esquema documentado).  
   - Dashboard MkDocs con gráficas simples (`docs/internal/briefing_system/ops/observabilidad.md`).  
    - Alertas configuradas para roles desconocidos o errores 5xx persistentes.  
    - _Estado cierre_: Documentación, CLI y umbrales listos; automatización de alertas queda como seguimiento Fase 6.
5. **Ecosistema técnico y paquetes**  
   - Repositorio `packages/env-banner` inicializado con README, build y versión `0.1.0`.  
   - Scripts críticos migrados a `tools/` con documentación (`scripts/validate_structure.sh` → `tools/` planificado).  
    - Cronograma de releases trimestrales publicado en `docs/internal/briefing_system/plans/releases.md`.  
    - _Estado cierre_: Se mantiene como pendiente estratégico; se agenda para próxima iteración de plataforma compartida.

## 4. Plan de ejecución
| Hito | Descripción | Responsable | Evidencia | Estado |
| --- | --- | --- | --- | --- |
| Kickoff F5 | Publicar este documento, actualizar orquestador, bitácora y `STATUS.md` | Copilot | Este reporte, Bitácora 082, commit | 🟢 Completo |
| UI contextual v1 | Unificar userbar + dashboards con datos Access reales | Equipo técnico | `_reports/ui_context/20251011T153200Z/` | 🟡 Parcial (datos reales y capturas a backlog) |
| Flujos "Ver como" | Sessions owner/client/team registradas con capturas | Operaciones | `_reports/access_sessions/` | 🚫 No ejecutado (se reprograma Fase 6) |
| QA automation | Workflows activados + primer run documentado | DevOps | `_reports/qa_runs/20251008T221533Z/` | 🟢 Completo |
        - [x] Implementar prototipo interactivo con mocks (`docs/assets/runart/dashboards.{js,css}`) cargado en `/dash/{role}`.  
| Observabilidad | Dashboard métricas + alertas definidas | Observabilidad | `docs/internal/.../observabilidad.md` | 🟡 Parcial (alertas automáticas diferidas) |
| Paquetes compartidos | `packages/env-banner` + plan releases publicado | Plataforma | `packages/env-banner/`, `docs/.../releases.md` | ⏭️ Reprogramado |
| Cierre F5 | Reporte actualizado con QA y sello DONE | PM | Este documento (v1.x) | 🟢 Completo |

### Roadmap detallado por stream

1. **Experiencia por rol**  
    - [x] Auditar overrides actuales (`overrides/main.html`, `docs/assets/runart/userbar.js`) y definir brechas por rol. → Evidencia `_reports/ui_context/20251011T153200Z/auditoria_overrides.md`.  
    - [x] Generar scaffolding documental (`docs/internal/briefing_system/ui/**`) para `/dash/{role}` con placeholders iniciales.  
    - [x] Documentar contrato de datos compartido (`docs/internal/briefing_system/ui/contrato_datos.md`).  
    - [x] Diseñar wireframe mínimo de cada dashboard (`/dash/owner`, `/dash/client_admin`, `/dash/team`, `/dash/client`, `/dash/visitor`) → Evidencias `_reports/ui_context/20251011T153200Z/wireframe_*.md`.  
    - [ ] Implementar componentes y poblarlos con datos reales provenientes de Access/KV.  
    - [ ] Guardar capturas autorizadas en `_reports/ui_context/<timestamp>/` con metadatos de sesión.  
    - ↪️ Ambos pendientes se documentan en backlog Fase 6 (ver §10 NEXT).

2. **Flujos "Ver como"**  
    - [x] Preparar credenciales y agenda de sesiones para owner, client_admin y team (ver `_reports/kv_roles/20251009T2106Z/` + plan en `_reports/access_sessions/20251008T222921Z/README.md`).  
    - [ ] Ejecutar walkthrough grabado de userbar, dashboards y bandejas por rol.  
    - [ ] Registrar cada sesión en `_reports/access_sessions/<timestamp>/` (video, capturas, notas) → plantillas por rol en `_reports/access_sessions/20251008T222921Z/*.md`.  
    - ↪️ Ejecución real pausada; se mantiene agenda/listado para iniciar en Fase 6.
    - [x] Actualizar guía operativa con instrucciones de “cambio de rol” y checklists por actor (`guides/Guia_QA_y_Validaciones.md`, sección "Sesiones Ver como").  

3. **Automatización QA + reporting**  
    - [x] Revisar `docs-lint`, `status-update`, `env-report` y preparar PR de activación (ver `apps/briefing/mkdocs.yml` actualizado).  
    - [x] Ejecutar primera corrida en rama controlada y recopilar logs de GitHub Actions/CLI → `_reports/qa_runs/20251008T221533Z/`.  
    - [x] Publicar `ops/qa_guardias.md` con protocolo de respuesta ante fallos.  
    - [x] Archivar los resultados en `_reports/qa_runs/20251008T221533Z/` con resumen.  

4. **Observabilidad y métricas**  
    - [x] Documentar esquema actual de `LOG_EVENTS` y `DECISIONES` → `ops/observabilidad.md`.  
    - [x] Crear script de normalización y tablero básico (`tools/log_events_summary.py`).  
    - [x] Definir umbrales/alertas (roles desconocidos, 5xx consecutivos) y registrar responsables (`ops/observabilidad.md` §7).  
    - [ ] Configurar notificaciones y documentar pruebas de disparo.  
    - ↪️ Se pospone a automatizaciones de Fase 6.

5. **Ecosistema técnico y paquetes**  
    - [ ] Crear `packages/env-banner` con estructura reproducible (build, lint, README).  
    - [ ] Migrar los scripts críticos priorizados (`validate_structure` y asociados) hacia `tools/` manteniendo documentación.  
    - [ ] Publicar plan de releases en `docs/internal/briefing_system/plans/releases.md`.  
    - [ ] Registrar métricas de uso e integración en workflows.  
    - ↪️ Roadmap completo se reubica en plan de releases 2025Q4.

## 5. Validaciones y QA
### Suite target
- `make lint` + `mkdocs build --strict` (post-cambios de contenido/UI).  
- Smokes autenticados reales (`/api/whoami`, `/api/inbox`, `/dash/*`) ejecutados desde navegadores autorizados.  
- Workflows `docs-lint`, `env-report`, `status-update` reportando verde en GitHub Actions.  
- Pruebas de observabilidad: ingestión `LOG_EVENTS` y detección de roles desconocidos.  
- Tests de paquetes (`pnpm lint`/`test`) para `packages/env-banner`.

### Plan de QA inicial
- [x] Definir matriz de pruebas por rol y publicarla en `guides/Guia_QA_y_Validaciones.md`.  
    - [x] Ejecutar QA básico tras el kickoff (`make lint` 2025-10-11T15:40Z).  
    - [ ] Programar corridas periódicas (`docs-lint`, `env-report`, `status-update`) y archivar logs.  
    - [ ] Crear script smoke Access automatizado (CLI) y archivarlo en `tools/`.  
    - [ ] Documentar métricas y umbrales de alerta en anexo de este reporte.  
    - ↪️ Actividades reprogramadas para el siguiente ciclo operativo.

## 6. Dependencias y preparación
- Accesos reales para roles owner/client_admin/team (ver `_reports/kv_roles/20251009T2106Z/`).  
- Configuración Cloudflare Access vigente y credenciales compartidas.  
- Infraestructura CI activa y permisos para crear workflows en el repo.  
- Coordinación con stakeholders para sesiones guiadas y aprobación de capturas.

## 7. Riesgos y mitigaciones
| Riesgo | Impacto | Mitigación |
| --- | --- | --- |
| Rroles-01: roles sin sesión real | UI sin datos reales | Calendarizar sesiones semanales con responsables y fallback de capturas en staging. |
| Rqa-02: workflows fallan por permisos | Bloqueo en automatizaciones | Revisar tokens/secretos antes de activar y ejecutar corrida en rama de prueba. |
| Robs-03: eventos incompletos | Alertas ineficaces | Documentar esquema `LOG_EVENTS` y agregar validación diaria (cron) |
| Rpkg-04: deuda en scripts legacy | Inconsistencias en herramientas | Migrar en orden crítico → priorizar `validate_structure` y asegurar paridad con doc. |

## 8. Métricas iniciales
- **Cobertura dashboards:** porcentaje de rutas `/dash/*` con datos reales (meta ≥80%).  
- **Tiempo de activación workflows:** días desde kickoff hasta primer run exitoso (meta ≤5).  
- **Alertas Access:** recuento semanal de roles desconocidos (meta = 0).  
- **Paquetes compartidos:** número de scripts migrados y versiones publicadas (meta inicial: 1 paquete).  
- **QA sessions:** cantidad de sesiones "Ver como" documentadas (meta ≥3, una por rol principal).

## 9. Estado final
- Kickoff y documentación de UI/QA/Observabilidad completados; entregables parciales señalados en §3.  
- Plantillas "Ver como" listas; ejecución real diferida por decisión de negocio y registrada en backlog.  
- Workflows `docs-lint`, `env-report`, `status-update` corren bajo demanda (última corrida 2025-10-08T22:55Z) y quedan listos para scheduling.  
- Observabilidad documentada con CLI (`tools/log_events_summary.py`) y umbrales definidos; automatización de alertas pasará a Fase 6.  
- Ecosistema de paquetes compartidos se mueve al plan de releases 2025Q4.

## 10. Sello de fase
- DONE: true  
- CLOSED_AT: 2025-10-08T23:00:00Z  
- SUMMARY: Se cierra Fase 5 tras consolidar dashboards por rol (con mocks), guías operativas y base de QA/observabilidad. Las sesiones "Ver como" y capturas reales quedan aplazadas deliberadamente hacia Fase 6.  
- ARTIFACTS: `_reports/ui_context/20251011T153200Z/`, `_reports/qa_runs/20251008T221533Z/`, `_reports/access_sessions/20251008T222921Z/README.md`, `docs/internal/briefing_system/ops/observabilidad.md`, `guides/Guia_QA_y_Validaciones.md`.  
- QA: `tools/lint_docs.py` ejecución local 2025-10-08T22:55Z (verde); workflows configurados para activación futura.  
- NEXT: Activar corridas recurrentes QA/observabilidad, ejecutar sesiones "Ver como" con evidencia real y lanzar `packages/env-banner`.
