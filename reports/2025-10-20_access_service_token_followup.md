# Follow-up — Access Service Token Integration

**Fecha de creación:** 2025-10-20  
**Estado:** Abierto  
**Contexto:** Tras el hardening de Pages Functions y el despliegue exitoso a producción (run `18657958933`), falta habilitar el Access Service Token para poder ejecutar smokes autenticados, revertir códigos temporales 404/405 en Functions y validar el flujo completo con credenciales de servicio.

## Objetivos
- Configurar las credenciales `ACCESS_CLIENT_ID` y `ACCESS_CLIENT_SECRET` en GitHub Actions con valores reales de Cloudflare Access.
- Replicar los secretos en `.dev.vars` y `wrangler.toml` (entornos preview/production) asegurando que no se suban claves en claro.
- Rehabilitar los smokes autenticados (`make test-smoke-auth`) en CI y documentar resultados para preview y producción.
- Revertir los códigos temporales: `/api/inbox` → `403 Forbidden` y `/api/decisiones` → `401 Unauthorized` cuando Access valide la sesión.
- Actualizar la documentación operativa (Bitácora 082, Runbook de smokes) con las nuevas rutas y procedimientos.

## Checklist
- [ ] Obtener Access Service Token en Cloudflare Zero Trust (Dashboard → Access → Service Tokens) y generar credenciales dedicadas para RunArt.
- [ ] Cargar `ACCESS_CLIENT_ID` y `ACCESS_CLIENT_SECRET` en GitHub (`Settings → Secrets and variables → Actions`).
- [ ] Configurar variables seguras equivalentes en Cloudflare Pages (`PROJECT → Settings → Environment variables`) para preview y producción.
- [ ] Actualizar `scripts/smoke_production.sh` y `Makefile` para consumir el token de servicio durante los smokes autenticados.
- [ ] Ejecutar smokes autenticados en preview y producción; guardar evidencias en `_reports/consolidacion_prod/<timestamp>_auth/`.
- [ ] Documentar el cierre en `_reports/PROBLEMA_pages_functions_preview.md`, Bitácora 082 y CHANGELOG.

## Artefactos de referencia
- `_reports/PROBLEMA_pages_functions_preview.md`
- `apps/briefing/_reports/smokes_prod_20251020T160949Z/`
- `apps/briefing/tests/scripts/run-smokes.mjs`
- `apps/briefing/functions/api/inbox.js`
- `apps/briefing/functions/api/decisiones.js`

## Riesgos
- Exposición accidental de credenciales si se manejan fuera de secretos.
- Inconsistencias entre entornos (preview vs production) si los tokens no se replican correctamente.
- Smokes autenticados podrían bloquearse sin ajustes en las políticas de Access; coordinar con Operaciones antes de correrlos en producción.

## Próximos hitos sugeridos
1. Confirmar presencia de tokens en Panel Access y GitHub (deadline: 2025-10-22).
2. Rehabilitar smokes autenticados en CI (deadline: 2025-10-24).
3. Revertir códigos temporales y documentar cambios (deadline: 2025-10-25).

## Contactos
- Responsable técnico sugerido: Equipo Access / Seguridad RunArt.
- Soporte operativo: Equipo de Operaciones Briefing.
