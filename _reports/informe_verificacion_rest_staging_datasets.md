# Informe — Verificación del “dataset real” vía WordPress REST (FASE 3.D)

Fecha: 2025-10-31
Autor: automation-runart
Ámbito: Validación remota (sin SFTP/SSH/WP‑CLI) de rutas de datos IA‑Visual en staging

## Endpoints creados (plugin unificado)

1) /wp-json/runart/v1/ping-staging
- Propósito: eco remoto para confirmar que el plugin está activo y el entorno es alcanzable.
- Respuesta: `{ ok, status:"ok", site_url, theme:{name,version}, runart_plugin:{version}, auth:{is_logged_in,hint}, timestamp }`
- Permisos: público (solo lectura, sin datos sensibles).

2) /wp-json/runart/v1/data-scan
- Propósito: diagnosticar la existencia del “dataset grande” y otras rutas candidatas, SIN leer archivos completos.
- Rutas probadas (en orden):
  1. `wp-content/runart-data/assistants/rewrite/index.json`
  2. `wp-content/uploads/runart-data/assistants/rewrite/index.json`
  3. `[plugin]/data/assistants/rewrite/index.json`
  4. `wp-content/uploads/runart-jobs/enriched/index.json` ← dataset “grande” a confirmar
  5. `content/enriched/index.json`
  6. `mirror/raw/<más reciente>/wp-content/uploads/runart-jobs/enriched/index.json` (si existe `mirror/` en el host)
- Respuesta por cada ruta: `{ label, path, exists, size_bytes, json_ok, item_count, error }`
- Resumen con decisión automática: `summary.dataset_real_status ∈ { FOUND_IN_STAGING, NOT_FOUND_IN_STAGING, UNKNOWN }`
  - FOUND_IN_STAGING ⇒ la ruta 4 existe y `item_count > 3`
  - NOT_FOUND_IN_STAGING ⇒ las 1–3 existen con total 3 ítems y la 4 no existe
- Permisos: público (solo lectura).

Notas de seguridad: ambas respuestas evitan exponer contenido de archivos; solo devuelven existencia, tamaño, y conteos si el JSON es parseable.

## Cómo verificar desde navegador o curl

- Ping (alcance):
  - Navegador: `https://<staging>/wp-json/runart/v1/ping-staging`
  - curl:
    ```bash
    curl -sS https://<staging>/wp-json/runart/v1/ping-staging | jq
    ```

- Data scan (dataset real):
  - Navegador: `https://<staging>/wp-json/runart/v1/data-scan`
  - curl:
    ```bash
    curl -sS https://<staging>/wp-json/runart/v1/data-scan | jq
    ```

Autenticación (si aplica):
- Si el staging exige autenticación (nonce o token), enviar:
  - WordPress nonce (sesión de usuario): `X-WP-Nonce: <nonce>`
  - Bearer token (config específico): `Authorization: Bearer <token>`

## Qué esperar en la respuesta

- `scan[]`: una entrada por ruta candidata, con `exists` y `item_count` si el JSON se leyó.
- `summary.dataset_real_status`:
  - `FOUND_IN_STAGING` si `uploads/runart-jobs/enriched/index.json` existe y tiene más de 3 ítems.
  - `NOT_FOUND_IN_STAGING` si las rutas pequeñas suman 3 y la ruta grande no existe.
  - `UNKNOWN` en cualquier otro caso (permisos, formatos no detectados, etc.).

## Recomendación a partir del resultado

- Si `FOUND_IN_STAGING`:
  - Opción B (preferida a medio plazo): ampliar la cascada del endpoint de lectura para incluir `uploads/runart-jobs/enriched/index.json` con lectura de solo‑lectura y normalización si hiciera falta.
  - Opción A (contingencia): sincronizar el índice grande hacia `wp-content/uploads/runart-data/assistants/rewrite/` para que el panel lo consuma sin cambios de código.

- Si `NOT_FOUND_IN_STAGING`:
  - Mantener dataset pequeño (3 ítems) como red de seguridad.
  - Revalorar si el dataset grande está en otro entorno o si se deshabilitó históricamente.

## Notas de implementación (para el equipo)

- Los endpoints están en `tools/runart-ia-visual-unified/includes/class-rest-api.php`.
- Se dejaron TODOs comentados para ampliar la cascada en cuanto confirmemos la presencia del dataset grande.
- No se modificó la estructura JSON del panel existente ni se movieron datasets.

## Siguientes pasos

1) Ejecutar `ping-staging` y `data-scan` en el staging objetivo.
2) Archivar la respuesta JSON como evidencia en `_reports/` si es posible (con hashes o timestamps).
3) Tomar la decisión A/B y, si procede, implementar la ampliación de cascada (FASE 3.E) con QA breve.
