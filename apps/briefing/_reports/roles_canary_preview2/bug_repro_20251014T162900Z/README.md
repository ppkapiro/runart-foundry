# Reproducción local del bug — 2025-10-14T16:29Z

Archivos generados:
- `whoami_owner.json`, `whoami_team.json`, `whoami_client_admin.json`, `whoami_client.json`: respuestas de `/api/whoami` usando Miniflare con `ROLE_RESOLVER_SOURCE=utils`.
- `resolve_log.txt`: logs del resolver con `ROLE_MIGRATION_LOG=1`.
- `unit_test_output.txt`: ejecución de `roles.unified.resolve.test.mjs`.

Observación: en entorno local con datos curados, los roles se resuelven correctamente (`owner`, `team`, `client_admin`, `client`). Esto confirma que el fallo observado en preview2 proviene de datos/KV o bindings específicos de ese entorno.
