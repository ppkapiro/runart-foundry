# Administrar roles (placeholder)

> **Estado:** En preparación inicial (Fase 3).

Este módulo alojará la interfaz interna para revisar y delegar roles del sistema Briefing.

## Endpoint `/api/admin/roles`
- **Métodos soportados:** `GET`, `PUT`.
- **Autorización:** requiere sesión Cloudflare Access y rol `owner` o `client_admin`; el middleware valida encabezado `Cf-Access-Authenticated-User-Email` y propaga `X-RunArt-Role`.
- **Cabeceras de respuesta:**
	- `Cache-Control: no-store`
	- `X-RunArt-Role` (inglés) / `X-RunArt-Role-Alias` (alias español)
- **Payload `GET` (200):**
	```json
	{
		"ok": true,
		"roles": {
			"owners": ["ppcapiro@gmail.com"],
			"client_admins": ["owner@client-admin.test"],
			"clients": [...],
			"team": [...],
			"team_domains": [...]
		},
		"ts": "2025-10-08T21:06:00Z"
	}
	```
- **Payload `PUT` (body esperado):**
	```json
	{
		"owners": ["ppcapiro@gmail.com"],
		"client_admins": ["delegado@runartfoundry.com"],
		"clients": ["runartfoundry@gmail.com"],
		"team": ["infonetwokmedia@gmail.com"],
		"team_domains": ["runartfoundry.com"]
	}
	```
	- Valida formato de arrays de correos/dominios y registra el cambio en `LOG_EVENTS`.
	- Actualiza `RUNART_ROLES` (KV) y sincroniza `access/roles.json` mediante automatización pendiente.

### Flujo temporal de uso
1. Ejecutar smokes (`node --input-type=module functions/api/admin/roles.js`) con cabeceras simuladas para validar ACL.
2. Realizar cambio real una vez autenticado vía Access (se registrará en `_reports/kv_roles/`).
3. Confirmar salida de `/api/whoami` y `/api/inbox` para el correo afectado.
4. Registrar en Bitácora 082 + reporte Fase 3.

## Próximos pasos

- Conectar con `/api/admin/roles` para mostrar el inventario vigente (owners, client_admins, clients, team, team_domains).
- Incluir acciones de alta/baja y sincronización con `RUNART_ROLES`.
- Registrar cada cambio en `LOG_EVENTS` con el detalle del actor y el payload enviado.

Mientras la UI final se implementa, las actualizaciones de roles deben realizarse mediante el endpoint de administración o directamente en Cloudflare.
