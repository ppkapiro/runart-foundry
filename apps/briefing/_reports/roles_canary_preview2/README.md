# Evidencias Canario Roles Unificados — preview2

Este directorio contiene logs, tablas de endpoints y resultados de smokes para la activación canario de roles unificados (fuente: KV RUNART_ROLES vía _utils/roles) en preview2.

## Pasos realizados
- Activación de ROLE_RESOLVER_SOURCE=utils y ROLE_MIGRATION_LOG=1 en wrangler.toml
- Despliegue overlay a preview2
- Ejecución de smokes y verificación de endpoints críticos:
  - /api/log_event (team/owner)
  - /api/logs_list (owner)
  - /api/admin/roles (GET/PUT)
- Exportación de logs y tabla de endpoints PASS/FAIL

## Resultados
- `smokes_stdout.txt`: primera corrida (canario utils) con FAIL.
- `rollback_20251014T162600Z/`: rollback parcial (hace falta redeploy) + smokes fallidos.
- `bug_repro_20251014T162900Z/`: reproducción local, logs y tests.
- `bugfix_propuesta_20251014T163100Z.md`: plan de corrección y próximos pasos.

---
Fecha: 2025-10-14
