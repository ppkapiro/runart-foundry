# ADR-0005 — Unificación de la resolución de roles

- **Estado:** aprobada  
- **Fecha:** 2025-10-14  
- **Responsables:** Equipo Copilot RunArt · Dirección Técnica

## Contexto
- Auditorías consecutivas (`reports/auditoria_roles_codex.md`, `reports/INVESTIGACION_PIPELINE_Y_ROLES.md`) identificaron dos librerías paralelas para determinar roles (`_utils/roles` con KV `RUNART_ROLES` y `_lib/roles` con overrides `ACCESS_*`).  
- Esta duplicidad provoca fallos en endpoints protegidos (`/api/inbox`, `/api/log_event`, `/api/admin/roles`) y dificulta la trazabilidad operativa documentada en Bitácora 082.  
- El pipeline CI/CD diferencia preview/producción, pero la doble fuente de verdad mantiene riesgos de escalamiento accidental y resultados inconsistentes en smokes T3.

## Decisión
- Adoptar `RUNART_ROLES` como fuente única de roles, combinando overrides `ACCESS_*` en un resolver compartido.  
- Refactorizar guardas (`requireTeam`, `requireAdmin`, ACL `/dash/*`) y middleware para consumir el mismo resolver, con fallback único `visitor`.  
- Normalizar alias y claims (`owner→admin`, `client_admin→admin_delegate`, etc.) para alinear UI, Access Policies y documentación.

## Consecuencias
- Simplificación del mantenimiento: eliminación de la librería legacy en `_lib/roles`.  
- Reducción de riesgo: ningún correo no reconocido se promoverá a `client`.  
- Necesidad de plan de canario (preview2) y controles post-release para validar el cambio.  
- Actualización obligatoria de documentación operativa, smokes y policies de Access.  
- Bypass de pruebas (`ACCESS_TEST_MODE` + `X-RunArt-Test-Email`) restringido mediante whitelist o desactivado tras validación.

## Nota de incidente (canario preview2)
- Riesgo descubierto: resolver unificado (`ROLE_RESOLVER_SOURCE=utils`) devolvió `admin` para todos los correos en preview2 (`/api/whoami`), generando escalamiento completo de privilegios.  
- Mitigación: rollback inmediato a resolver legacy (`ROLE_RESOLVER_SOURCE=lib`), canario detenido y evidencias archivadas en `apps/briefing/_reports/roles_canary_preview2/BUG_OWNER_FOR_ALL_20251014_1624/`.  
- Cambio requerido: asegurar fallback `visitor`, normalización (trim + lowercase) y orden de fuentes (overrides → KV → dominios → default).  
- Decisión: no promover a preview ni producción hasta que el bug esté corregido y validado mediante pruebas unitarias y smokes canario.

## Nota adicional (canario por lista blanca)
- Pages mantendrá únicamente entornos `preview` y `production`; se descarta el uso de `preview2` para pruebas automatizadas.  
- Se adopta canario por lista blanca de correos (KV) ejecutado en `preview`, con headers de depuración y endpoints diagnósticos temporales.  
- El resolver legacy (`SRC=lib`) permanece activo hasta que el enfoque unificado supere todas las validaciones.

## Referencias
- Plan de integración `reports/INTEGRACION_ROLES_FINAL.md`.  
- Bitácora 082 `apps/briefing/docs/internal/briefing_system/ci/082_reestructuracion_local.md`.  
- Checklist de release `apps/briefing/docs/internal/briefing_system/checklists/roles_unificados_release.md`.
