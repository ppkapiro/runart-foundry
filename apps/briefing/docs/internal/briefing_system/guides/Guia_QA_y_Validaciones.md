---
title: Guía de QA y Validaciones — RunArt Briefing
---
# Guía de QA y Validaciones — RunArt Briefing

**Última actualización:** 2025-10-11  
**Responsable:** Quality Owner (equipo QA) + Copilot

## Propósito
Centralizar los checks obligatorios por fase del [Plan Estratégico de Consolidación](../plans/Plan_Estrategico_Consolidacion_Runart_Briefing.md) y definir cómo registrar evidencias en `reports/`. Este documento complementa la [Guía Copilot — Ejecución por Fases](./Guia_Copilot_Ejecucion_Fases.md).

## Matriz de validaciones por fase
| Fase | Validaciones mínimas | Comandos/acciones | Evidencia requerida |
| --- | --- | --- | --- |
| **F1** Documentación | `mkdocs build --strict` · `make lint-docs` (raíz) · `scripts/validate_structure.sh` | Desde la raíz: `make lint-docs` · `./scripts/validate_structure.sh --staged-only` | Log de comandos + listado de páginas afectadas en el reporte F1 |
| **F2** Corrección técnica | Validaciones F1 + `make -C apps/briefing lint` · `make -C apps/briefing test` · Smokes locales (`wrangler pages dev` o `curl`) | `make lint` · `make test` en la raíz · Registro de smokes `/api/whoami`, `/api/inbox`, `/api/decisiones` | Tabla de resultados QA con estatus por endpoint/pipeline |
| **F3** Roles y delegaciones | Validaciones F2 + pruebas de Access (owner, team, client) · Verificación de KV | `./tools/check_env.py --mode http --base-url <URL>` para preview/prod · Capturas de Access Dashboard | Capturas/logs de Access, dumps `roles.json` versionado, resultados de `check_env.py` |
| **F4** Cierre operativo | Validaciones F3 + smoke final en producción · `make test-env-prod` · Verificación de changelog/status | `make -C apps/briefing test-env-prod` (con `PROD_URL`) · Revisión manual de `STATUS.md` | Reporte final con tabla de validaciones y enlace a bitácora 082 |
| **F5** UI contextual y QA automatizado | Validaciones F4 + activación de workflows (`docs-lint`, `status-update`, `env-report`) · Smokes "Ver como" con sesiones reales · Métricas `LOG_EVENTS` | `make lint` · `gh workflow run <id>` (ensayos) · Scripts smoke Access en `tools/` · Extracción diaria `LOG_EVENTS` | Logs de workflows en `_reports/qa_runs/` · Capturas `_reports/access_sessions/` · Dashboard observabilidad documentado |

> **Nota:** Si una validación no aplica, justificar en el reporte de avance con responsable y plan de mitigación.

## Flujo estándar de QA
1. **Preparar entorno virtual** (si aún no existe):
   - `make -C apps/briefing venv`
   - Instalar dependencias declaradas en `apps/briefing/requirements.txt`.
2. **Ejecutar validaciones locales** en este orden:
   1. `make lint-docs`
   2. `make -C apps/briefing lint`
   3. `make -C apps/briefing build`
      4. `npm --prefix apps/briefing run test:bootstrap`
      5. `npm --prefix apps/briefing run test:unit`
      6. `./scripts/validate_structure.sh --staged-only`
      7. `make -C apps/briefing test`
3. **Validar entornos remotos** (Fases 2–4):
   - Definir `PREVIEW_URL` y `PROD_URL` según los despliegues activos (consultar bitácora 082 o `README_briefing.md`).
   - Ejecutar `make -C apps/briefing test-env-preview` y `make -C apps/briefing test-env-prod`.
   - Registrar los resultados en el reporte, incluyendo valores `env`, `role` y códigos HTTP.
4. **Pruebas de Access y roles** (F3):
   - Autenticarse como owner/team/client y registrar capturas del dashboard de Cloudflare Access.
   - Validar `roles.json` y KV asociados. Si se actualiza, anexar diff en el reporte.
5. **Compilación de evidencias**:
   - Guardar logs y salidas importantes en `_tmp/` (si son transitorios) o `archives/` (si deben conservarse).
   - Adjuntar enlaces o rutas relativas en el `Plantilla_Reporte_Avance.md` instanciado.

### Sesiones "Ver como" (Fase 5)
> Objetivo: registrar recorridos autenticados por rol y documentar evidencia audiovisual en `_reports/access_sessions/<timestamp>/`.

1. **Preparación previa**
   - Validar credenciales en `_reports/kv_roles/20251009T2106Z/`.
   - Confirmar entorno (`preview` o `prod`) con `tools/check_env.py --mode http --base-url <URL> --expect-env <env>`.
   - Abrir `wrangler tail` para observar eventos y anotar errores.
   - Crear carpeta con timestamp UTC en `_reports/access_sessions/` (ver plantilla `20251008T222921Z`).
2. **Ejecución por rol**
   - Owner / Client Admin / Team / Client / Visitor.
   - Registrar video corto (opcional) y mínimo tres capturas relevantes (según tabla en README de la carpeta).
   - Completar ficha rápida: fecha, entorno, userbar, dashboard, incidencias.
3. **Post-sesión**
   - Guardar capturas en `captures/<rol>/` dentro de la carpeta de timestamp.
   - Documentar hallazgos y seguimiento en Bitácora 082 (sección "Ver como").
   - Actualizar checklist de `docs/internal/briefing_system/reports/2025-10-11_fase5_ui_contextual_y_experiencias_por_rol.md`.

> Si alguna sesión no puede ejecutarse (ej. credenciales pendientes), registrar el motivo en la bitácora y marcar el estado como 🟡 en la tabla de la carpeta.

## Registro en plantillas
- **Reporte de Avance:** Completar la sección "Validaciones ejecutadas" indicando fecha, comando y resultado. En caso de error, documentar bloqueo y responsable de follow-up.
- **Tarea por Fase:** Actualizar la columna "QA" con el estado (`Pendiente`, `En curso`, `Completado`) y referencia al reporte de avance.

## Criterios de aprobación
- Ningún check crítico (`lint`, `build`, `validate_structure`, `test-env-*`) puede fallar en la rama a desplegar.
- Las pruebas de Access deben demostrar códigos correctos por rol (200 owner/team, 403 client, 401 visitante en `/api/inbox`).
- Los cambios documentales no se consideran listos sin `mkdocs build --strict` en verde.
- Cualquier skip debe contar con issue o incidencia vinculada en `ci/` o `audits/`.

## Troubleshooting rápido
- **Fallo en `make lint-docs`:** revisar enlaces rotos o snippets; usar `mkdocs serve` para identificar rutas problemáticas.
- **`validate_structure.sh` reporta rutas prohibidas:** mover archivos a las carpetas permitidas o actualizar `.gitignore` según gobernanza.
- **Mismatch en `RUNART_ENV`:** ejecutar `tools/check_env.py --mode http` contra la URL afectada y coordinar ajuste de variables en Cloudflare Pages antes de cerrar la fase.
- **Errores de Access:** confirmar que el correo esté en la lista correcta (`owner`, `team_domains`, `clients`) y que el dashboard se haya sincronizado; registrar hallazgos en el reporte.

## Actualización y ownership
- La guía debe revisarse al inicio de cada fase o cuando cambie la tubería de QA.
- Mejoras o nuevas validaciones se documentan en un issue interno (`ci/`) y se integran en esta guía tras aprobación del Project Manager.
