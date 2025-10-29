---
title: Guía Operativa — Administración de Roles
---
# Guía rápida para administrar roles en RunArt Briefing

**Versión:** v1.0 — 2025-10-09  
**Responsable:** Copilot + Project Manager

## Objetivo
Establecer un procedimiento fiable y documentado para altas, bajas y auditorías de roles (`owner`, `client_admin`, `client`, `team`, `visitor`) usando el endpoint `/api/admin/roles`, el KV `RUNART_ROLES` y los estáticos `access/roles.json`.

## Requisitos previos
- Credenciales Cloudflare Access con rol `owner` o `client_admin`.
- Token y permisos de lectura/escritura sobre el namespace `RUNART_ROLES`.
- Repositorio sincronizado para editar `access/roles.json` y ejecutar QA (`make lint`).

## Flujo resumido
1. **Revisión:** Ejecutar smokes con `node` (ver sección QA) para validar situación actual.  
2. **Edición estática:** Actualizar `access/roles.json` con los cambios aprobados.  
3. **Sincronización KV:** Consumir `PUT /api/admin/roles` con el payload actualizado.  
4. **Verificación:** Ejecutar `GET /api/admin/roles` y `/api/whoami` para cada actor relevante.  
5. **Registro:** Documentar en `_reports/kv_roles/<timestamp>/` los outputs JSON y capturas.  
6. **Bitácora:** Anotar el resultado en `ci/082_reestructuracion_local.md` dentro de la sección correspondiente a la fase activa.

## Paso a paso detallado
### 1. Preparar payload
```json
{
  "owners": ["ppcapiro@gmail.com"],
  "client_admins": ["runartfoundry@gmail.com"],
  "clients": ["musicmanagercuba@gmail.com"],
  "team": ["infonetwokmedia@gmail.com"],
  "team_domains": ["runartfoundry.com"]
}
```
- El payload debe incluir siempre los cinco campos.  
- Los correos se normalizan en minúsculas; no se permiten duplicados.  
- `team_domains` acepta dominios (sin `@`).

### 2. Ejecutar PUT seguro
```bash
curl -X PUT "$PAGES_URL/api/admin/roles" \
  -H "Cf-Access-Authenticated-User-Email: runartfoundry@gmail.com" \
  -H "Content-Type: application/json" \
  --data @payload.json
```
- Sustituir `$PAGES_URL` por la URL de Preview o Producción.  
- Para sesión real usar cookies de Cloudflare Access; en smokes se puede simular sólo la cabecera.  
- El endpoint valida el rol y registrará el evento en `LOG_EVENTS` con la clave `roles.update`.

### 3. Validar resultado
- `GET /api/admin/roles` debe devolver `role: "client_admin"` o `"owner"`, `source: "kv"` y la lista sincronizada.  
- `GET /api/whoami` desde cada correo debe reflejar el rol correspondiente y cabeceras `X-RunArt-Role`, `X-RunArt-Role-Alias`.  
- `GET /api/inbox` admite `owner`, `client_admin`, `team`; `client` recibe 403.

### 4. Auditorías periódicas
- Ejecutar script `node scripts/admin/roles-smoke.mjs` *(pendiente de empaquetar)* o el snippet documentado en reporte de fase.  
- Guardar outputs en `_reports/kv_roles/<timestamp>/`.  
- Resumir hallazgos en `reports/2025-10-09_fase3_administracion_roles_y_delegaciones.md`.

### 5. Documentación y cierres
- Actualizar la Bitácora 082 con el bloque “✅ Cierre Fase 3 — Administración de Roles” cuando proceda.  
- Enviar alerta al stakeholder si cambia la lista de `owners` o `client_admins`.

## Checklist rápido
- [ ] Payload preparado y validado.  
- [ ] `access/roles.json` actualizado.  
- [ ] `PUT /api/admin/roles` ejecutado.  
- [ ] `GET /api/admin/roles` y `/api/whoami` verificados.  
- [ ] Smokes archivados en `_reports/kv_roles/`.  
- [ ] QA (`make lint`, `mkdocs build --strict`) pasado.  
- [ ] Bitácora 082 actualizada.

## Troubleshooting
- **403 Forbidden:** el correo no tiene rol `owner`/`client_admin`; revisar Access.  
- **Payload inválido:** alguno de los campos no es array o contiene valores vacíos; validar JSON.  
- **KV desincronizado:** ejecutar `GET` con query `?force=1` (pendiente) o limpiar cache re-desplegando.  
- **Logs ausentes:** revisar `LOG_EVENTS` mediante `wrangler kv:key list --namespace-id <LOG_EVENTS>` y buscar eventos `roles.update`.

## Referencias
- [`ops/roles_admin.md`](../ops/roles_admin.md) — contrato del endpoint.  
- [`_reports/kv_roles/`](../../../../_reports/kv_roles/) — evidencias históricas.  
- [`ci/082_reestructuracion_local.md`](../ci/082_reestructuracion_local.md) — bitácora de fases.
