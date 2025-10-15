# Integración de roles — Fases 1 y 2

## 1. Resumen ejecutivo
La auditoría vigente evidenció la coexistencia de dos librerías para clasificar usuarios (`_utils/roles` vs `_lib/roles`), provocando decisiones inconsistentes entre middleware y guardas. El impacto operativo incluye permisos divergentes en `/api/inbox`, `/api/log_event` y el flujo de dashboards, además de confusión documental. El comité decidió consolidar la resolución de identidades usando `RUNART_ROLES` (KV) como única fuente y normalizar nomenclaturas frente a Cloudflare Access. Este documento describe cómo ejecutar las Fases 1–2 sin interrumpir el pipeline, manteniendo preview operativo y endureciendo producción.

## 2. Taxonomía unificada de roles
| nombre_canónico | alias_UI | claim_access (Zero Trust) | descripción | hereda_de |
|-----------------|----------|---------------------------|-------------|-----------|
| owner | admin | `runart:admin` | Dirección; controla delegaciones, configuración y auditorías. | admin_delegate, team, client |
| client_admin | admin_delegate | `runart:admin_delegate` | Delegados del cliente con facultad para consultar métricas y administrar roles secundarios. | team, client |
| team | team | `runart:team` | Operaciones internas (producción, soporte, moderación). | client |
| client | client | `runart:client` | Clientes finales con acceso a dashboards y documentación de proyecto. | visitor |
| visitor | visitor | `runart:visitor` | Sesiones sin privilegios autenticados (incluye no autenticados). | — |

## 3. Fuente de verdad y reglas de resolución
- **Flujo objetivo (diagrama textual):**  
  1. Cloudflare Access autentica la solicitud y añade `Cf-Access-Authenticated-User-Email` (y claims asociados).  
  2. Middleware invoca `resolveRole` único → lee overrides (`ACCESS_*`) y `RUNART_ROLES` (KV).  
  3. Middleware propaga `X-RunArt-Email`, `X-RunArt-Role`, `X-RunArt-Role-Alias` al resto de la cadena.  
  4. Guardas (`requireTeam`, `requireAdmin`, ACL `/dash/*`) consumen la misma función para autorizar.  
  5. Handlers aplican lógica de negocio suponiendo rol normalizado.
- **Reglas clave:**  
  - Prioridad de clasificación: owner (override/env) → client_admin → team (email/domains) → client → visitor.  
  - Fallback único: `visitor` (nunca promover a `client` por defecto).  
  - Claims de Access deben reflejar `claim_access` de la tabla para que la equivalencia sea determinista.

## 4. Alcance Fase 1 – Unificación técnica mínima
- **Objetivo:** reemplazar la doble librería por un único módulo de resolución y sets derivados de KV.
- **Archivos a intervenir (solo enumeración):**  
  `apps/briefing/functions/_utils/roles.js` · `apps/briefing/functions/_lib/roles.js` · `apps/briefing/functions/_lib/guard.js` · `apps/briefing/functions/_middleware.js` · `apps/briefing/functions/api/{whoami,inbox,decisiones,log_event,admin/roles}.js` · pruebas en `apps/briefing/tests/`.
- **Orden sugerido:**  
  1. **Diseño del módulo compartido:** extraer helpers (`normalizeValue`, estado de KV) a `roles.shared.js`. *Éxito:* exporta `resolveRole`, `roleToAlias`, `roleMatrix`.  
  2. **Migración de `_lib/roles` y guardas:** importar el módulo compartido, eliminar fallback cliente y documentar el nuevo contrato. *Éxito:* `requireTeam` hace referencia directa al nuevo resolver.  
  3. **Actualización del middleware:** consumir el módulo único y retirar lógica duplicada. *Éxito:* logs y headers usan los mismos alias.  
  4. **Revisión de handlers:** asegurar que ningún endpoint llame a la librería antigua. *Éxito:* grep sin coincidencias de funciones deprecadas.  
  5. **Pruebas automatizadas iniciales:** unitarias y miniflare validan owner/client_admin/team/visitor. *Éxito:* suite verde y evidencia en `_reports/kv_roles`.

## 5. Alcance Fase 2 – Normalización de nomenclatura y claims
- **Mapeo de equivalencias:** owner→admin; client_admin→admin_delegate; team→team; client→client; visitor→visitor.  
  - Actualizar payloads de `/api/whoami`, userbar (`apps/briefing/docs/assets/runart/userbar.js`), y menús en `overrides/main.html` para reflejar alias UI.  
  - Ajustar `apps/briefing/docs/assets/env-flag.js` y componentes UI para mostrar `preview2` y `prod`.
- **Cloudflare Access:** revisar Zero Trust → Access → Policies para garantizar que los grupos/claims (`runart:*`) replican la tabla.  
- **Documentación UI:** actualizar navegación contextual (`apps/briefing/functions/_utils/ui.js`) y rutas `/dash/*` para usar el alias canónico.

## 6. Matriz de impacto por endpoint
| endpoint | rol mínimo actual | rol mínimo objetivo | cambios esperados | nota |
|----------|-------------------|---------------------|------------------|------|
| `/api/whoami` | visitor (con alias inconsistente) | visitor (alias coherente) | Respuesta mantiene acceso universal pero muestra alias normalizado. | Ajustar pruebas snapshot. |
| `/api/inbox` | owner/team/client_admin (dependiente de guardas legacy) | team (incluye owner/admin_delegate vía herencia) | Guardas ya no aceptan client por fallback; responses 403 coherentes. | Verificar con smokes T3 preview/prod. |
| `/api/log_event` | team/admin (pero fallback puede incluir cliente) | team (hereda admin, admin_delegate) | Rechazar client/visitor explícitamente y registrar motivo. | Requiere actualización de `requireTeam`. |
| `/api/admin/roles` | GET: team/admin; PUT: owner/client_admin (parcial) | GET: team/admin_delegate; PUT: admin (owner) | Validar `read_only` para admin_delegate, reforzar PUT solo admin. | Coordinar con Access policies. |
| `/dash/*` | ACL mixta (visitor/client/team/owner) | ACL basada en tabla canónica | Redirecciones `/dash/{segment}` usando alias normalizado (`admin`, `admin_delegate`, `team`, `client`, `visitor`). | Actualizar `_utils/ui.js` y ACL consolidado. |

## 7. Pruebas y validación
- **Unitarias:** nuevas suites para `resolveRole`, `roleToAlias`, herencia (`apps/briefing/tests/unit/roles.*`).  
- **Integración (Pages Functions):** miniflare con fixtures Access que cubran GET/POST en `/api/inbox`, `/api/log_event`, `/api/admin/roles`.  
- **Smokes T3 (preview y prod):** actualizar `apps/briefing/tests/scripts/run-smokes.mjs` para reflejar la nueva matriz y verificar alias.  
- **Criterios de aceptación:**  
  - Preview: tolerancias existentes se mantienen (404/405) pero roles resueltos vía fuente única.  
  - Producción: `/api/inbox` y `/api/log_event` rechazan client/visitor; `/api/admin/roles` PUT solo owner.  
  - UI: userbar y `env-flag` muestran etiqueta correcta en `local`, `preview`, `preview2`, `prod`.

## 8. Riesgos, mitigaciones y plan de reversa
- **Riesgos:** corte involuntario a clientes por cambios en guardas; bypass preview deshabilitado rompiendo QA; smokes fallando por alias inesperados.  
- **Mitigaciones:** introducir bandera `RUNART_ROLES_MODE=legacy|unified` para canary; ejecutar smokes comparativos (antes/después) en preview2; mantener `ACCESS_TEST_MODE` temporalmente con whitelist firmada.  
- **Plan de reversa:** conservar rama `feature/roles-unificados`; si se detecta impacto, redeploy con versión anterior de `_lib/roles` y `run-smokes` (tagged en `overlay`), manteniendo `RUNART_ROLES` intacto. Documentar revert en `INCIDENTS.md`.

## 9. Actualizaciones de Runbook Operativo
- **Nueva sección “Control de Accesos y Roles”:** incluir taxonomía unificada, flujo de resolución, checklist para sincronizar KV + Access + UI.  
- **Checklist post-release (24–48 h):**  
  - Revisar smokes T3 preview/prod (public + auth).  
  - Consultar `LOG_EVENTS` para confirmar registros `roles.update` y accesos por alias.  
  - Verificar `/api/whoami` desde owner, admin_delegate, team, client (capturas).  
  - Confirmar dashboards `/dash/admin`, `/dash/admin_delegate`, `/dash/team`, `/dash/client`, `/dash/visitor` según usuario impersonado.  
  - Reportar en `STATUS.md` y `INCIDENTS.md` cualquier discrepancia.

## 10. Anexos
- **Glosario rápido:**  
  - *admin:* alias UI de owner.  
  - *admin_delegate:* alias UI de client_admin.  
  - *RUNART_ROLES:* KV namespace que almacena la matriz de roles dinámica.  
  - *ACCESS_TEST_MODE:* bandera usada en preview para bypass controlado.  
  - *Smokes T3:* pruebas autenticadas que validan roles en preview/prod.  
- **Referencias:**  
  - Auditoría técnica `reports/auditoria_roles_codex.md`.  
  - Plan de integración `reports/plan_integracion_roles_codex.md`.  
  - Investigación pipeline `reports/INVESTIGACION_PIPELINE_Y_ROLES.md`.  
  - Runbook operativo (pendiente versión `runart_runbook_operacion.md` con nueva sección de control de accesos).

## 11. Plan de Canario y Rollback
- **Canario:** desplegar la rama `feature/roles-unificados` en `preview2` con `RUNART_ROLES_MODE=unified`, mantener `preview`/`prod` en modo legacy, ejecutar smokes T3 completos y recopilar evidencias en `_reports/roles_canary_<timestamp>/`.
- **Monitoreo:** comparar respuestas de `/api/{whoami,inbox,log_event,admin/roles}` entre `preview` (legacy) y `preview2` (unified), revisar dashboards `/dash/*` y logs `LOG_EVENTS` para verificar alias. Registrar hallazgos en Bitácora 082.
- **Rollback:** si se detecta regresión, reconfigurar `RUNART_ROLES_MODE=legacy`, redeploy último build estable (hash anotado en Bitácora) y revertir la rama canario. Documentar el evento en `INCIDENTS.md` y mantener la KV intacta.

## 12. Matriz de Verificación Post-Release (24–48 h)
| Verificación | Roles esperados | Resultado esperado | Evidencia |
|--------------|-----------------|--------------------|-----------|
| `/api/whoami` (owner, admin_delegate, team, client, visitor) | Respuesta con alias normalizado según taxonomía | `role` y `rol` coherentes; `env` acorde al entorno | Capturas e IDs de smokes |
| `/api/inbox` | team, admin_delegate, admin | 200 para team/admin_delegate/admin; 403 para client/visitor | Logs de smokes T3 |
| `/api/log_event` | team, admin_delegate, admin | 200 y registro en `LOG_EVENTS`; 403 para client/visitor | KV `LOG_EVENTS` keys recientes |
| `/api/admin/roles` | admin (PUT), admin_delegate/team (GET) | PUT solo admin; GET read-only para admin_delegate/team | JSON de canary + producción |
| `/dash/*` | Según alias (`/dash/admin`, `/dash/admin_delegate`, etc.) | Redirecciones y contenido según rol impersonado | Grabación corta / checklist QA |
| `LOG_EVENTS` | Todas las sesiones autenticadas | Eventos con alias correcto y sin fallback inseguro | Export de auditoría diaria |

## 13. Registro de Cambios de Taxonomía
| Rol anterior | Estado previo | Rol nuevo (canónico) | Alias UI | Nota |
|--------------|---------------|----------------------|----------|------|
| admin | Consumido solo en `_lib/roles` | owner | admin | Administra sistema y delegaciones |
| client_admin (parcial) | Sin reconocimiento en guardas | client_admin | admin_delegate | Delegado con permisos extendidos |
| equipo | Mezcla `team`/`equipo` | team | team | Operaciones internas |
| cliente | Igual | client | client | Clientes del proyecto |
| visitante | Igual | visitor | visitor | Sesiones sin privilegios |

## 14. Estrategia de canario final
- **Modo de activación:** lista blanca de correos en `RUNART_ROLES` (`canary_allowlist`) que habilita el resolver unificado solo para esos usuarios en `preview`; el resto continúa con resolver legacy (`SRC=lib`).  
- **Headers de depuración:** en `preview` se mantienen `X-RunArt-Role-Source`, `X-RunArt-Role-Original`, `X-RunArt-Role-Translated` para diagnosticar cada request; se eliminarán tras validar el canario.  
- **Endpoints temporales:** `/api/debug/roles_unified` y `/api/debug/roles_headers` expuestos únicamente en `preview` para auditar resultados durante el canario; deben retirarse una vez se confirme la estabilidad antes de desplegar a producción.
