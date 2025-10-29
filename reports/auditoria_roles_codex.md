# Auditoría técnica de accesos y roles — Codex

## Resumen de hallazgos
- El middleware clasifica identidades a partir de Cloudflare Access y KV (`RUNART_ROLES`), pero las guardas internas dependen de otra librería de roles que ignora ese KV y usa nombres distintos, lo que rompe la gobernanza entre “owner/client_admin/client/team” y “admin/equipo/cliente”.
- Las guardas (`requireTeam`/`requireAdmin`) asignan por defecto el rol `cliente` a cualquier correo autenticado que no esté en las listas de entorno, impidiendo que nuevas altas hechas desde `/api/admin/roles` obtengan permisos y abriendo la puerta a tratos privilegiados inesperados si se habilita acceso cliente.
- Existe un bypass de pruebas en `preview` basado en el header `X-RunArt-Test-Email`; no tiene restricciones adicionales y depende de que Cloudflare Access bloquee peticiones externas.
- Los indicadores de entorno son inconsistentes: `.dev.vars` anuncia `RUNART_ENV=preview` (local deja de verse como LOCAL) y el banner `env-flag` solo muestra etiquetas para `local/preview`, por lo que `preview2` queda sin distintivo visual.

## Lista de archivos relevantes
- `apps/briefing/functions/_middleware.js`
- `apps/briefing/functions/_utils/roles.js`
- `apps/briefing/functions/_utils/acl.js`
- `apps/briefing/functions/_lib/roles.js`
- `apps/briefing/functions/_lib/guard.js`
- `apps/briefing/functions/_lib/accessStore.js`
- `apps/briefing/functions/api/whoami.js`
- `apps/briefing/functions/api/admin/roles.js`
- `apps/briefing/functions/api/inbox.js`
- `apps/briefing/functions/api/log_event.js`
- `apps/briefing/access/roles.json`
- `apps/briefing/docs/assets/runart/userbar.js`
- `apps/briefing/overrides/main.html`
- `apps/briefing/docs/assets/env-flag.js`
- `apps/briefing/wrangler.toml`
- `apps/briefing/.dev.vars`
- `apps/briefing/functions/.dev.vars`

## Flujo actual de autenticación
1. Cloudflare Access autentica la sesión e inserta headers (`Cf-Access-Authenticated-User-Email`, JWT).
2. El middleware global (`apps/briefing/functions/_middleware.js`) evalúa si la ruta es pública (`isPublicPath`), aplica bypass de prueba cuando `RUNART_ENV=preview` y `ACCESS_TEST_MODE=1`, obtiene el correo (`getEmailFromRequest`) y resuelve el rol con `_utils/roles.resolveRole`.
3. Para rutas no públicas añade `X-RunArt-Email`, `X-RunArt-Role`, `X-RunArt-Role-Alias` y `X-RunArt-Rol`, registra visitas y aplica ACL sobre `/dash/*` con `_utils/acl`.
4. Los handlers (`/api/whoami`, dashboards, etc.) vuelven a llamar a `_utils/roles.resolveRole` para determinar la sesión efectiva; `/api/admin/roles` sincroniza el KV `RUNART_ROLES`.
5. La UI (`overrides/main.html`, `docs/assets/runart/userbar.js`, `docs/assets/env-flag.js`) consulta `/api/whoami` para mostrar correo, rol, menú contextual y bandera de entorno. El enlace “Salir” redirige a `cdn-cgi/access/logout`.

## Problemas detectados
- Taxonomía de roles divergente: `_utils/roles.resolveRole` entrega `owner/client_admin/client/team/visitor` desde KV (`apps/briefing/functions/_utils/roles.js:119`), mientras `guardRequest` delega en `_lib/roles.resolveRole` que solo conoce `admin/equipo/cliente/visitante` y no consulta `RUNART_ROLES` (`apps/briefing/functions/_lib/roles.js:94`). Por ello, altas y bajas gestionadas vía `/api/admin/roles` no habilitan accesos protegidos como `/api/log_event` que usa `requireTeam` (`apps/briefing/functions/api/log_event.js:18`) y requieren duplicar la información en variables de entorno.
- Fallback permisivo en las guardas: `_lib/roles.resolveRole` devuelve `ROLES.CLIENTE` para cualquier correo autenticado no listado en `ACCESS_*` (`apps/briefing/functions/_lib/roles.js:110-115`). Si en el futuro se habilitan endpoints para “clientes”, cualquier identidad aprobada por Access quedará promovida sin pasar por el mapeo de KV, rompiendo la separación visitor/client.
- Bypass de ensayo en preview: el middleware acepta `X-RunArt-Test-Email` cuando `RUNART_ENV === "preview"` y `ACCESS_TEST_MODE === "1"` (`apps/briefing/functions/_middleware.js:26-43`). Este flujo permite suplantar cualquier correo sin comprobaciones adicionales; depende totalmente de que la URL de preview permanezca protegida por Access.
- Variables locales engañosas: `.dev.vars` establece `RUNART_ENV="preview"` (`apps/briefing/.dev.vars:1`) y la bandera `env-flag` solo rotula `local/preview` (`apps/briefing/docs/assets/env-flag.js:22`). Al servir en local, la UI termina mostrando “PREVIEW”, lo que dificulta distinguir ambientes y contradice la documentación operativa que promete etiqueta LOCAL.
- Etiqueta ausente en preview2: `wrangler` declara `RUNART_ENV="preview2"` (`apps/briefing/wrangler.toml:42`), pero ni `env-flag` ni la lógica de la UI contemplan ese valor, dejando sin indicación visual el entorno usado para pruebas con bypass deshabilitado.
- Variables de laboratorio sin efecto: tanto `.dev.vars` global como de Functions declaran `ACCESS_ROLE` (`apps/briefing/.dev.vars:3`, `apps/briefing/functions/.dev.vars:3`), pero ninguna ruta la consume; los desarrolladores carecen de una vía oficial para forzar roles locales más allá del bypass o de modificar Cloudflare Access.

## Riesgos asociados
- **Seguridad:** endpoints protegidos por `requireTeam`/`requireAdmin` pueden negar servicio a roles válidos o, en el extremo opuesto, conceder privilegios a correos mal clasificados como `cliente`.
- **Gobernanza:** mantener dos fuentes de verdad (KV vs variables de entorno) incrementa el riesgo de desalineación entre políticas aprobadas y comportamiento real tras cada despliegue.
- **Usabilidad:** la falta de señales de entorno consistentes (preview vs preview2 vs local) y la inexistencia de una vía controlada para modo demo dificultan validaciones por parte de QA y stakeholders.
- **Mantenimiento:** los bypass de pruebas activados por configuración (`ACCESS_TEST_MODE`) requieren disciplina manual para desactivarse y no cuentan con guardas o alertas automáticas.

## Recomendaciones inmediatas
- Unificar la resolución de roles: reutilizar `_utils/roles` (o compartir una única librería) dentro de `requireTeam`/`requireAdmin` para que las decisiones dependan exclusivamente de `RUNART_ROLES` y de los overrides declarados (owners/client_admins/etc.).
- Ajustar el fallback de `_lib/roles.resolveRole` a `visitante` y agregar pruebas que cubran correos no registrados, evitando promociones implícitas a `cliente`.
- Endurecer y documentar el bypass de pruebas (`X-RunArt-Test-Email`): añadir whitelist o flag puntual (por ejemplo, cabecera secreta) y revisar si debe permanecer activo en `preview`.
- Normalizar banderas de entorno: definir `RUNART_ENV=local` para `.dev.vars`, extender `env-flag` y la UI para reconocer `preview2/prod/local`, y validar automáticamente que el banner corresponda al ambiente antes de cada release.
- Sustituir las variables experimentales (`ACCESS_ROLE`, `ACCESS_EMAIL`) por un mecanismo oficial de impersonación local (por ejemplo, script que simule Access emitiendo `X-RunArt-Email`) o eliminarlas para reducir confusión.
