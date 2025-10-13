# Smokes automáticos roles — 2025-10-09T21:06Z

- Contexto: ejecución local simulada con cabeceras `Cf-Access-Authenticated-User-Email` para validar `/api/whoami`, `/api/inbox` y `/api/admin/roles` tras promover `runartfoundry@gmail.com` a `client_admin`.
- Resultados clave:
  - `whoami` entrega rol y alias esperado para owner, client_admin, team, client y visitante.
  - `inbox` responde 200 para owner/client_admin/team; 403 para client/visitor.
  - `admin/roles`:
    - `PUT` aceptado para client_admin (200) y registra evento `roles.update`.
    - `GET` expone snapshot `source: "kv"` con payload actualizado.
    - `GET` desde team devuelve 200 en modo solo lectura (`read_only: true`).
    - `GET` desde client devuelve 403.
  - `kv_snapshot.json` confirma almacenamiento en KV (`runart_roles`).
  - `log_events.json` contiene entrada `roles.update` con métricas agregadas.

Los artefactos permanecen en esta carpeta para referencia del cierre de la Fase 3.
