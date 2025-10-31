# Checklist — Release Roles Unificados

## Pre-release
- [ ] Smokes preview (público + autenticado) PASS con evidencias archivadas.  
- [ ] Canary desplegado en `preview2` (`RUNART_ROLES_MODE=unified`) con reporte `_reports/roles_canary_<timestamp>/`.  
- [ ] Comparativa legacy vs unified (`/api/whoami`, `/api/inbox`, `/api/log_event`, `/api/admin/roles`) documentada.  
- [ ] Cloudflare Access Policies actualizadas (`runart:admin`, `runart:admin_delegate`, `runart:team`, `runart:client`, `runart:visitor`).  
- [ ] KV `RUNART_ROLES` revisado (owners, admin_delegate, team, client, domains).  
- [ ] Aprobar ADR-0005 y Runbook actualizado.
- [ ] Prueba unitaria `resolveRoleUnified` confirma: correo no mapeado → `visitor`.  
- [ ] Validación de normalización (case/espacios): entradas con mayúsculas/espacios producen el rol correcto.  
- [ ] Escenario KV vacío / no disponible probado: el resolver NO promueve a `owner` por defecto.
- [ ] Auditoría `RUNART_ROLES` documentada (conteo por rol, timestamp y origen).  
- [ ] Variables `ACCESS_*` saneadas (sin wildcard, strings vacíos ni valores truthy ambiguos).  
- [ ] Canario activo únicamente para correos listados en la allowlist (KV).

## Release
- [ ] Merge `feature/roles-unificados` → `main` con tag de evidencia.  
- [ ] Deploy a producción completado (workflow `pages-prod`).  
- [ ] Smokes producción (público + autenticado) PASS y artefactos almacenados.  
- [ ] Confirmar ausencia de regresiones en dashboards `/dash/*`.

## Post-release (24–48 h)
- [ ] Revisar logs `LOG_EVENTS` (roles, acciones, tasa de errores).  
- [ ] Ejecutar `curl /api/whoami` con tokens admin/admin_delegate/team/client/visitor y documentar salida.  
- [ ] Validar `/api/inbox` y `/api/log_event` (status 200 solo para roles autorizados).  
- [ ] Navegar `/dash/admin`, `/dash/admin_delegate`, `/dash/team`, `/dash/client`, `/dash/visitor` y capturar evidencia.  
- [ ] Actualizar `STATUS.md` e `INCIDENTS.md` con resultados.  
- [ ] Cerrar checklist en Bitácora 082 con resumen PASS/FAIL por entorno.
