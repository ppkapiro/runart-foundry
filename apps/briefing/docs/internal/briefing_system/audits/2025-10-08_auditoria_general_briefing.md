# 🧭 Auditoría Técnica General — RUNART · Briefing (2025-10-08)
Este documento fue generado a partir de la instrucción de revisión completa del módulo `apps/briefing/`.
Resume la estructura actual, los endpoints activos, los estados CI/CD, la coherencia documental y los próximos pasos.
Se conserva íntegramente el contenido del informe original de Copilot sin modificaciones.

# Informe de Auditoría — RunArt Briefing (Copilot)

## 1. Estructura actual del módulo
**Estado:** ✅

**Descripción detallada**
- `apps/briefing/` aloja el módulo completo; conserva archivos operativos (`Makefile`, `requirements.txt`, `wrangler.toml`) y bitácoras (`README_briefing.md`, `CHANGELOG.md`) que trazan fases y entregables.
- `docs/` contiene el contenido Markdown separado en dominios: `client_projects/runart_foundry/` (material cliente) vs `internal/briefing_system/` (ops, arquitectura, CI), además de áreas temáticas (`decisiones/`, `editor/`, `exports/`, `dashboards/`, `ui/`). `assets/` añade JS/CSS (p. ej. `runart/userbar.*`, `env-flag.js`) y JSON de soporte.
- `functions/` organiza las Pages Functions: `_middleware.js` para control de acceso global, `_utils/` con roles/ACL/UI helpers, `_lib/` para interacciones con KV/logs, `api/` con endpoints (quedando activos `whoami.js`, `inbox.js`, `decisiones.js` entre otros) y `dash/` con renderizado server-side por rol.
- `access/roles.json` define el mapeo base de correos (owners, clients, team_domains) que se replica en KV `RUNART_ROLES`.
- `overrides/` personaliza Material: `main.html` injerta scripts de rol/env y controles de accesibilidad; `roles.js` expone configuración legacy; `extra.css` actúa como compatibilidad histórica.
- `scripts/`, `_reports/`, `_logs/` y `reports/` almacenan tooling y evidencia (smokes, inventarios, cortes, QA) esenciales para auditoría y despliegue.
- Carpetas auxiliares (`_tmp/`, `site/`, `.dev.vars`, `.wrangler/`) soportan desarrollo/local preview y builds.

**Notas de coherencia**
- La separación cliente/equipo descrita en la bitácora 082 ya se refleja en la estructura (docs reorganizados, snapshots en `_reports/`).
- Archivos legacy se resguardaron en `_archive/legacy_removed_20251007/`, cumpliendo con la limpieza documentada.

**Observaciones de integración**
- Los directorios se relacionan vía configuración MkDocs (nav dual) y middleware (que dirige a `/dash/<rol>`). Scripts CI (`tools/`, `scripts/validate_structure.sh`) validan que la estructura se mantenga alineada con gobernanza.
- Persisten rastros de compatibilidad (p. ej. workflow `briefing_deploy.yml` aún apunta a `briefing/` en lugar de `apps/briefing/`), pero no afectan el layout físico.

## 2. APIs y Middleware
**Estado:** ⚠️

**Descripción detallada**
- `_middleware.js` intercepta toda petición estática/SSR, omite rutas públicas (`/api`, `/assets`…), clasifica roles (`getEmailFromRequest`, `resolveRole`) y redirige `/` → `/dash/<rol>`. Inyecta headers `X-RunArt-Email` y `X-RunArt-Role` que consumen las Functions y aplica ACL sobre `/dash/*` mediante `_utils/acl.js`.
- `whoami.js` expone diagnóstico (env vars `RUNART_ENV`, `MOD_REQUIRED`, `ORIGIN_ALLOWED`) y retorna rol/email. `inbox.js` restringe acceso a owner/team; `decisiones.js` exige autenticación básica (email presente) antes de aceptar POST.
- `_utils/roles.js` centraliza lookup en KV `RUNART_ROLES`, lista blanca de admins (`ACCESS_ADMINS`) y dominios de equipo (`ACCESS_EQUIPO_DOMAINS`), además de logging asíncrono en `LOG_EVENTS`.

**Notas de coherencia**
- La bitácora 082 reporta smokes 200/403/401 que coinciden con la lógica actual (whoami abierto, inbox restringido, decisiones autenticado).
- El uso de KV/logging alinea con los mecanismos descritos en `_reports/kv_roles` y `_reports/consolidacion_prod`.

**Observaciones de integración**
- Inconsistencias de nomenclatura: `whoami` responde la propiedad `rol`, mientras los consumidores frontend esperan `role`. Además `resolveRole` devuelve valores en español (`equipo`, `cliente`, `visitante`), pero `inbox.js` espera `'team'` para conceder acceso ⇒ el equipo queda bloqueado. Se requiere normalizar claves y condicionales.
- `wrangler.toml` reutiliza el mismo ID para `DECISIONES` y `LOG_EVENTS`, lo que sugiere un binding duplicado poco fiable (debería apuntar a namespaces distintos).
- Dependencias externas: Cloudflare Pages Functions + Access (cabeceras `cf-access-*`) y KV namespaces (`DECISIONES`, `LOG_EVENTS`, `RUNART_ROLES`).

## 3. UI y experiencia de usuario
**Estado:** ❌

**Descripción detallada**
- `docs/assets/runart/userbar.js/css` implementan una userbar accesible (teclado, menú contextual, logout Access) que debería montar en `.md-header__inner`, consumir `/api/whoami` y derivar rutas según rol (owner→interno, client→cliente, visitor→home). `normalizeRole` intenta traducir valores en español ↔ inglés.
- `overrides/main.html` añade meta `noindex`, skip-link y un controlador que esconde navegación interna según rol, además de toggles “Ver como” para administradores (persistencia en `localStorage`).
- `env-flag.js` pinta banner de entorno; `roles.js` mantiene fallback legacy.

**Notas de coherencia**
- La bitácora Fase B “UI/Userbar” documenta la lógica prevista (avatar, chip, logout, `window.__RA_DEBUG_USERBAR`) y los smokes manuales por rol.

**Observaciones de integración**
- Bug crítico: tanto la userbar como el script de overrides consumen `data.role`, pero `whoami` publica `rol` ⇒ siempre caen en “visitor”. Esto oculta menús internos, impide detectar owners y deja al HTML con `data-role=visitante`. Debe alinearse la API (exponer `role`) o el frontend (leer `rol`).
- `ROLE_ROUTES` usa llaves en inglés (team/client) y depende de `normalizeRole`; sin la corrección anterior, nunca se alcanza la ruta correcta.
- Ausencia de pruebas automatizadas de UI; los smokes dependen del helper debug.

## 4. CI/CD y entorno
**Estado:** ⚠️

**Descripción detallada**
- Workflows activos: `ci.yml` (build MkDocs + tests de logs + deploy Wrangler), `docs-lint.yml` (lint estricto), `structure-guard.yml` (gobernanza), `pages-preview-guard.yml` (exige check de Cloudflare Pages), `auto-open-pr-on-deploy-branches.yml` (PR automático para ramas `deploy/*`), `env-report.yml` (smokes RUNART_ENV) y `pages-deploy.yml` (fallback de deploy manual con `npm run build`).
- Variables de entorno: `RUNART_ENV`, `MOD_REQUIRED`, `ORIGIN_ALLOWED`, `ACCESS_*`, bindings KV inyectados vía `wrangler.toml`. `env-report` confirma preview `RUNART_ENV=preview`; bitácora deja constancia del fix producción `RUNART_ENV=production`.
- Deploy principal depende del workflow nativo de Pages (gatillado por push a `main`) complementado con fallback GitHub Action.

**Notas de coherencia**
- La bitácora 082 y los reportes `_reports/deploy_fix/` describen el refuerzo de guardias, auto-PRs y fallback, coincidiendo con la configuración actual.
- Se documenta la necesidad de evidencias owner/client en `_reports/consolidacion_prod`.

**Observaciones de integración**
- `briefing_deploy.yml` sigue apuntando a `briefing/` (ruta legacy) y no refleja la migración a `apps/briefing/`. Riesgo de confusión si se reactiva.
- El flujo `ci.yml` requiere secretos (`CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`, `CF_LOG_EVENTS_ID/PREVIEW_ID`). Su ausencia degrada a deploy noop.
- Aún se depende de validaciones manuales (smokes Access reales) para cerrar releases, tal como advierte la bitácora.

## 5. Bitácora 082 — Estado documental
**Estado:** ⚠️

**Descripción detallada**
- Cobertura: Contexto de reestructuración local (dual Cliente/Equipo), cambios estructurales (nav dual, relocación docs, redirects, role-sim), validaciones (mkdocs, lint, scripts, wrangler dev), despliegues APU, guardias CI, roles Access, UI Userbar, y refuerzos de deploy Pages.
- Pendientes: evidencias Access reales (smokes owner/client), purga total de warnings, verificación RUNART_ENV producción (ya corregida a posteriori, pero el documento lo marca como pendiente hasta nuevas capturas), próximos ciclos APU y Fase B UI.

**Notas de coherencia**
- El repositorio refleja la mayoría de los checklist completados (estructuras movidas, scripts creados, guardias en Actions). Los archivos `_reports/` guardan los logs que la bitácora cita.
- Persisten elementos “auto-fill” (p. ej. consolidación roles KV) sin evidencias manuales almacenadas todavía.

**Observaciones de integración**
- Recomienda alinear documentación futura (p. ej. README_briefing) para mencionar los bugs detectados y su estatus.
- Conviene actualizar la bitácora tras capturar smokes con Access real y cerrar los “⚠️” heredados.

## 6. Diagnóstico global
**Estado general:** ⚠️

| Área | Estado | Comentarios clave |
| --- | --- | --- |
| Access & Roles | ⚠️ | Clasificador en middleware/ACL correcto, pero `inbox.js` no reconoce `equipo` ⇒ bloquea al equipo. `LOG_EVENTS` comparte ID con `DECISIONES`. |
| Userbar & UI | ❌ | Scripts esperan `data.role` y `role` en JSON; la API entrega `rol` ⇒ la UI no eleva privilegios ni revela navegación interna. |
| APIs y Middleware | ⚠️ | Flujo 200/403/401 se cumple; pendiente normalizar nomenclatura `rol/role` y revisar bindings duplicados. |
| CI/CD y despliegue | ⚠️ | Guardias y fallback operativos; requiere limpiar workflows legacy y automatizar smokes Access. |
| Documentación (082 + internos) | ✅ | Bitácora exhaustiva y alineada con estructura; faltan anexos de evidencias finales pero están señalados como pendientes. |

**Dependencias externas**
- Cloudflare Pages (build & deploy, env vars `RUNART_ENV`).
- Cloudflare Access (cabeceras `cf-access-*`, logout `/cdn-cgi/access/logout`).
- Cloudflare KV (`DECISIONES`, `RUNART_ROLES`, `LOG_EVENTS`).
- GitHub Actions + Cloudflare Pages Preview integration (guardias, auto PR).

**Coherencia roles**
- Definiciones: owners (`ACCESS_ADMINS`, roles.json), equipo (dominios + KV), clientes (lista en KV/JSON), visitante (fallback).
- Implementación: middleware/ACL usan español; UI espera inglés; APIs mezclan ambos ⇒ inconsistencias deben resolverse para evitar accesos erróneos.

## 7. Recomendaciones y próximos pasos
1. **Unificar nomenclatura de rol (urgente)**  
   - Actualizar `whoami` para retornar `role` (mantener alias `rol` por compatibilidad).  
   - Ajustar `inbox.js` para admitir `equipo` y normalizar a `'team'` si se requiere.  
   - Revisar front (`userbar.js`, `main.html`) para aceptar ambos campos y confirmar estados owner/team.
2. **Corregir bindings y configuración Cloudflare**  
   - Separar IDs de `LOG_EVENTS` y `DECISIONES` en `wrangler.toml`.  
   - Documentar en README el namespace correcto y refrescar secretos en CI.
3. **Limpiar pipelines legacy y automatizar smokes**  
   - Archivar o actualizar `briefing_deploy.yml` (ruta incorrecta).  
   - Añadir job en `ci.yml`/`env-report.yml` que simule respuestas Access (via headers) para detectar regresiones en roles.
4. **Capturar y versionar evidencias Access reales**  
   - Completar la tarea pendiente de la bitácora 082 (smokes owner/client en producción y preview) y anexar resultados a `_reports/consolidacion_prod/`.
5. **Fortalecer documentación operativa**  
   - Actualizar `README_briefing.md` y la bitácora 082 con los bugs detectados y su estatus.  
   - Registrar en `CHANGELOG.md` los fixes una vez desplegados.
6. **QA UI continuo**  
   - Incorporar pruebas end-to-end ligeras (Playwright o Cypress en modo headless) para validar el menú userbar y las rutas `/dash/<rol>`.  
   - Revisar estilos en dark mode tras corregir roles.
