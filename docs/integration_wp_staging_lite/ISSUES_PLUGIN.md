# Incidencias — WP Staging Lite (MU-Plugin)

Usa este archivo para registrar problemas, errores o advertencias durante la integración y pruebas.

## Registro

- 2025-10-22 13:17 — Conectividad desde WSL a dominio Local
	- Síntoma: `curl` a `http://runart-staging-local.local` → HTTP 000 / conexión rechazada.
	- Causa probable: el dominio de Local no está resolviéndose dentro de WSL (hosts/Router Mode de Local).
	- Mitigación:
		- Opción A: usar `BASE_URL` con `http://127.0.0.1:<PUERTO>` o `http://localhost:<PUERTO>` si Local está en Router Mode (localhost routing).
		- Opción B: añadir el dominio al `/etc/hosts` de WSL apuntando a 127.0.0.1 (si corresponde) o a la IP que exponga Local.
		- Opción C: cambiar temporalmente `BASE_URL` a la URL que sea accesible desde WSL.
	- Estado: Pendiente de confirmar URL accesible desde WSL para reintentar validación.
