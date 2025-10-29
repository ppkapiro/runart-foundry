# Auditoría overrides UI contextual
**Fecha:** 2025-10-11T15:32Z  
**Responsable:** Copilot  
**Contexto:** Primer barrido del roadmap F5 para la experiencia por rol.

## Archivos revisados
- `apps/briefing/overrides/main.html`
  - Inyecta `data-viewas` y controla visibilidad de navegación interna.
  - Depende de `/api/whoami` y `window.runartSetEnv` para ajustar `data-role`/`data-env` en `<html>`.
  - Define listado fijo de rutas internas y clases `interno`/`owner-only`.
  - Incluye autolog hacia `/api/log_event` exclusivo para roles `admin` y `equipo`.
- `apps/briefing/overrides/roles.js`
  - Exporta `window.BriefingRoleConfig = { role: "equipo" }` como valor por defecto.

## Hallazgos clave
1. **Userbar/dashboard inexistentes en docs**
   - No existe `docs/internal/briefing_system/ui/` ni rutas `/dash/<role>` en el snapshot actual → se requiere scaffolding completo.
2. **Consistencia de roles**
   - El normalizador acepta `owner`, `team`, `client`, `client_admin`, `visitor`; el autolog filtra `admin`/`equipo` → revisar naming para evitar incoherencias.
3. **Dependencias externas**
   - Requiere endpoints `/api/whoami` y `/api/log_event`; no hay mocks documentados para desarrollo local.
4. **Control "Ver como" restringido**
   - Solo `owner` puede alternar roles vía `<select>` y se persiste en `localStorage`. No hay UI visible para otros roles.
5. **Nav interna hardcodeada**
   - Listas `internalLabels` y `internalHrefPatterns` podrían quedar desactualizadas cuando sumemos dashboards dedicados.

## Riesgos / Bloqueos inmediatos
- Sin estructura `docs/internal/briefing_system/ui/` no podemos alojar dashboards segmentados.
- Falta de dataset Access/KV real visible en repo; se necesitará integración o mocks para popular widgets.
- Autolog se ejecuta en DOMContentLoaded sin validar entorno → riesgo en ambientes sin `/api/log_event`.

## Próximos pasos sugeridos
1. Crear scaffolding base `docs/internal/briefing_system/ui/` con landing `/dash/index.md` y plantillas por rol.
2. Definir contrato de datos (keys esperadas de `/api/whoami` y fuentes Access/KV) y documentarlo.
3. Ajustar script de navegación para detectar nuevas rutas `/dash/*` automáticamente.
4. Preparar fixtures/mocks para QA de la userbar y dashboards (facilitar capturas en `_reports/ui_context`).

## Evidencias
- Este archivo.
- Captura de contexto del script principal: pendiente (se documentará al generar wireframes).
