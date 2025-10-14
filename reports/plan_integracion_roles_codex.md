# Plan de integración de roles y accesos — Codex

## Resumen ejecutivo
- La auditoría técnica identificó dos fuentes de verdad para la clasificación de usuarios: `_utils/roles` alimentado por `RUNART_ROLES` (owner/client_admin/client/team/visitor) y `_lib/roles` usado por las guardas (`admin/equipo/cliente/visitante`). Esta divergencia explica los bloqueos y privilegios inesperados descritos en `reports/auditoria_roles_codex.md:4-45`.
- El Runbook operativo (documentado como `runart_runbook_operacion.md` y reflejado en la taxonomía `admin/equipo/cliente/visitante` usada por las guías de operación `apps/briefing/docs/client_projects/runart_foundry/auditoria/index.md:36-83`) asume que Cloudflare Access ofrece esos cuatro niveles. El código actual añade `owner` y `client_admin` sin homólogos directos, rompiendo los flujos descritos en el Runbook.
- Para alinear el sistema se requiere centralizar la resolución de roles en una única librería, normalizar nomenclaturas y claims entre Access, KV y UI, endurecer el middleware frente a bypasses (`apps/briefing/functions/_middleware.js:26-88`) y actualizar la documentación operativa antes de habilitar clientes reales.

## Mapa de roles actual
| Dominio funcional | KV / `_utils/roles` | Guardas `_lib/roles` / Access | Runbook / documentación operativa | Observaciones |
|-------------------|----------------------|-------------------------------|-----------------------------------|---------------|
| Dirección / owners | `owner` (`apps/briefing/functions/_utils/roles.js:119-141`) | `admin` (`apps/briefing/functions/_lib/roles.js:99-102`) | `admin` (`apps/briefing/docs/client_projects/runart_foundry/auditoria/index.md:36-83`) | Guardas nunca ven `owner`; requieren traducirlo a `admin`. |
| Delegados cliente | `client_admin` (`apps/briefing/functions/_utils/roles.js:128-135`) | *Sin mapeo específico* → cae como `cliente` (`apps/briefing/functions/_lib/roles.js:110-115`) | No documentado explícitamente; runbook agrupa delegados bajo `admin` | Usuarios promovidos vía `/api/admin/roles` no obtienen privilegios extra. |
| Equipo interno | `team` | `equipo` | `equipo` | Coincidencia semántica, pero la guardia depende de variables `ACCESS_*` en lugar de KV (`apps/briefing/functions/_lib/roles.js:103-109`). |
| Clientes finales | `client` | `cliente` | `cliente` | Mapeo directo, aunque `_lib/roles` los concede por defecto a cualquier correo no listado (`apps/briefing/functions/_lib/roles.js:110-115`). |
| Visitantes | `visitor` | `visitante` | `visitante` | Coincidencia esperada; UI y env-flag usan este alias (`apps/briefing/docs/assets/env-flag.js:12-29`). |

## Puntos de desalineación
- **Doble resolución de roles:** `_utils/roles` carga datos desde KV y CSV (`ACCESS_*`), mientras `guardRequest` usa `_lib/roles` con una jerarquía fija y fallback permisivo (`apps/briefing/functions/_lib/roles.js:94-115`, `apps/briefing/functions/_lib/guard.js:23-46`). Resultado: roles agregados vía `/api/admin/roles` no afectan a las guardas (`reports/auditoria_roles_codex.md:36-38`).
- **Bypass de ensayo activo en preview:** El middleware acepta `X-RunArt-Test-Email` cuando `RUNART_ENV=preview` y `ACCESS_TEST_MODE=1` (`apps/briefing/functions/_middleware.js:26-45`), contradiciendo el flujo seguro descrito por el Runbook al permitir suplantaciones sin política Access (`reports/auditoria_roles_codex.md:38-46`).
- **Inconsistencia de entornos:** `.dev.vars` fija `RUNART_ENV=preview` y banderas de impersonación sin efecto (`apps/briefing/.dev.vars:1-5`, `apps/briefing/functions/.dev.vars:1-3`), mientras el truco visual `env-flag` solo distingue `local/preview` (`apps/briefing/docs/assets/env-flag.js:12-29`), a diferencia del Runbook que exige visibilidad clara por entorno.
- **Documentación desactualizada:** El Runbook sigue operando con la matriz `admin/equipo/cliente/visitante`; no registra la existencia de `client_admin` ni del alias `owner`, lo que impide a operaciones entender por qué `/api/log_event` o `/api/logs_list` fallan ante usuarios con nuevos roles.

## Plan de integración
### Fase 1 — Consolidar librerías (`_utils/roles` y `_lib/roles`)
**Objetivo:** Tener un único origen de verdad que sirva a middleware, guardas y endpoints.
- Extraer la lógica de `_utils/roles` a un módulo compartido que exponga `resolveRole`, `roleToAlias`, `normalizeRoleForAcl` y sets derivados del KV (`apps/briefing/functions/_utils/roles.js:38-166`).
- Reescribir `_lib/roles` y `guardRequest` para importar ese módulo en lugar de replicar listas (`apps/briefing/functions/_lib/guard.js:23-46`).
- Mantener compatibilidad con CSV (`ACCESS_ADMINS`, etc.) como overrides, pero aplicarlos dentro del mismo flujo antes de consultar KV.
- Criterio de éxito: `requireTeam` y `requireAdmin` determinan roles usando la misma fuente que `/api/whoami` y los dashboards; pruebas unitarias cubren owner y client_admin.

### Fase 2 — Normalizar nomenclatura y claims
**Objetivo:** Alinear nombres Runbook ↔ código ↔ Access.
- Definir una tabla de equivalencias (`owner`→`admin`, `client_admin`→`admin_delegate`, etc.) y aplicarla al construir cabeceras (`X-RunArt-Role`, `X-RunArt-Role-Alias`) y UI (`apps/briefing/functions/_middleware.js:75-85`, `apps/briefing/docs/assets/runart/userbar.js:17-162`).
- Actualizar `RUNART_ROLES` y `access/roles.json` para incorporar los alias oficiales, validando que Cloudflare Access policies usen las mismas etiquetas.
- Ajustar la documentación operativa para incluir `client_admin` como extensión del grupo administrativo.
- Criterio de éxito: `/api/whoami` refleja rol + alias coherentes y la UI muestra etiquetas iguales a las del Runbook.

### Fase 3 — Reforzar validaciones en middleware y handlers
**Objetivo:** Reducir bypasses y garantizar controles uniformes.
- Delimitar el bypass `ACCESS_TEST_MODE` con whitelists o cabeceras firmadas y desactivarlo por defecto en `wrangler` (`apps/briefing/wrangler.toml:29-48`).
- Ajustar `.dev.vars` y `env-flag` para mostrar `LOCAL/preview/preview2/prod` según entorno real (`apps/briefing/.dev.vars:1-5`, `apps/briefing/docs/assets/env-flag.js:12-29`).
- Revisar endpoints críticos (`/api/decisiones`, `/api/inbox`, `/api/log_event`, `/api/admin/roles`) para validar `X-RunArt-Role` y rechazar combinaciones inconsistentes (por ejemplo, client intentando escribir en roles).
- Criterio de éxito: smokes autenticados confirman 403/200 alineados con la matriz de roles y no depende de defaults permisivos.

### Fase 4 — Actualizar documentación operativa y Runbook
**Objetivo:** Reflejar el modelo unificado en los manuales.
- Versionar `runart_runbook_operacion.md` en el repositorio (actualmente ausente) con la nueva taxonomía y flujo de actualización de roles.
- Sincronizar guías (`apps/briefing/docs/client_projects/runart_foundry/auditoria/index.md:36-83`, `apps/briefing/docs/internal/briefing_system/ops/runbook_smokes_ci.md:1-80`) para que referencien el mismo set de roles y nuevas herramientas de impersonación segura.
- Añadir checklist de revisión rápida al final del Runbook para validar que KV y Access policies estén sincronizados tras cada cambio en `/api/admin/roles`.
- Criterio de éxito: operaciones pueden seguir el Runbook sin reconciliar manualmente alias distintos.

## Pruebas recomendadas
- **Unitarias:** cobertura de `resolveRole` para combinaciones owner/client_admin/team y correos desconocidos; validación de alias y headers generados (`apps/briefing/functions/_utils/roles.js:109-155`).
- **Integración (Pages Functions):** miniflare o workers test comprobando que `requireTeam` respeta los roles del KV y rechaza usuarios sin mapeo (`apps/briefing/functions/_lib/guard.js:23-46`).
- **End-to-end:** smokes autenticados (`apps/briefing/docs/internal/briefing_system/ops/runbook_smokes_ci.md:1-80`) con tokens de servicio para cada rol; validar `/api/whoami`, `/api/inbox`, `/api/admin/roles` y dashboards `/dash/*`.
- **UI / entorno:** pruebas que verifiquen la etiqueta de entorno en banner y userbar bajo `local`, `preview`, `preview2`, `prod` tras los ajustes (`apps/briefing/docs/assets/env-flag.js:12-29`, `apps/briefing/docs/assets/runart/userbar.js:136-161`).
- **Regresión de bypass:** test específico que asegure que `ACCESS_TEST_MODE` no permite escalamiento si la cabecera no está autorizada.

## Checklist de despliegue seguro
- KV `RUNART_ROLES` sincronizado con el mapeo final (verificar con `/api/admin/roles` GET).
- Cloudflare Access policies revisadas para reflejar la nueva equivalencia de roles (`admin` ↔ owners/client_admins).
- `.dev.vars` y plantillas `wrangler` actualizadas y revisadas en PR.
- Smokes públicos y autenticados PASS en preview y producción.
- Documentación (`runart_runbook_operacion.md`, guías internas) aprobada por operaciones.
- Registro en `LOG_EVENTS` de un cambio de roles (`roles.update`) y validación cruzada en dashboards.

## Apéndice técnico
| Tema | Auditoría | Runbook / documentación operativa |
|------|-----------|-----------------------------------|
| Doble librería de roles | `reports/auditoria_roles_codex.md:4-38` | Taxonomía en `apps/briefing/docs/client_projects/runart_foundry/auditoria/index.md:36-83` |
| Bypass Access preview | `reports/auditoria_roles_codex.md:38-46`, `apps/briefing/functions/_middleware.js:26-45` | Runbook smokes exige policies consistentes `apps/briefing/docs/internal/briefing_system/ops/runbook_smokes_ci.md:1-80` |
| Señalización de entorno | `reports/auditoria_roles_codex.md:39-41`, `apps/briefing/docs/assets/env-flag.js:12-29` | Runbook espera visibilidad de entorno antes de correr smokes |
| Gestión de roles vía `/api/admin/roles` | `reports/auditoria_roles_codex.md:10-18`, `apps/briefing/functions/api/admin/roles.js:1-124` | Runbook requiere inventario y delegaciones centralizadas |

## Conclusión
Este plan alinea la gobernanza técnica con la operativa unificando la lógica de roles, corrigiendo nomenclaturas y reforzando controles en middleware, endpoints y documentación. La ejecución requiere coordinación entre desarrollo (implementación y pruebas), operaciones (actualización de Runbook y validación manual), y administración de Cloudflare (ajustes de Access policies, tokens y KV). Dependencias clave: soporte de Copilot para automatizar refactors, revisión manual de QA/Operaciones, y cambios coordinados en Zero Trust antes de liberar accesos a clientes reales.
