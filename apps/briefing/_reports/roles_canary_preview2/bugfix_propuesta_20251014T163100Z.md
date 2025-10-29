# Propuesta de fix — Resolver unificado (2025-10-14T16:31Z)

## Contexto
- Canario en preview2 devolvió `admin` para todos los perfiles al consultar `/api/whoami`.
- El rollback en `wrangler.toml` reinstaló `ROLE_RESOLVER_SOURCE="lib"`, pero el despliegue overlay falló porque `wrangler pages deploy` no acepta `--env preview2`. Hace falta ejecutar el flujo CI/Actions con `wrangler.preview2.toml`.
- Reproducción local vía Miniflare (`ROLE_RESOLVER_SOURCE=utils`) entrega roles correctos, lo que apunta a diferencias en bindings/env (datos KV o variables `ACCESS_*`).

## Hallazgos
- Se instrumentó `_utils/roles.js` con logs cuando `ROLE_MIGRATION_LOG=1`, registrando email normalizado, fuente (env/KV/static) y decisión.
- Nuevas pruebas (`tests/unit/roles.unified.resolve.test.mjs`) cubren:
  - Datos completos en KV.
  - Normalización de mayúsculas/espacios.
  - Variables `ACCESS_*` vacías sin promover a owner.
  - Fallback al archivo estático sin escalar privilegios.
- Los logs (`resolve_log.txt`) muestran la secuencia: input → fuente estática/KV → coincidencia o fallback.

## Hipótesis raíz
1. **KV contaminado:** `RUNART_ROLES` en preview2 probablemente contiene todos los correos bajo `owners`. Validar con `wrangler kv:key get --binding RUNART_ROLES --key runart_roles --env preview2`.
2. **Variables ACCESS_* sobrescritas:** Revisar `ACCESS_ADMINS` y `ACCESS_CLIENT_ADMINS` en Secrets/Actions para descartar listas comodín.
3. **Runner sin redeploy:** El rollback aún no se aplicó porque preview2 sigue sirviendo el worker previo.

## Plan de corrección
1. Exportar snapshot de `RUNART_ROLES` y confirmar taxonomía.
2. Ajustar dataset para separar `owners`, `client_admins`, `team`, `clients`.
3. Relanzar deploy preview2 usando `wrangler preview2` (flujo documentado) y repetir smokes.
4. Si se detecta patrón repetible (p.ej. owners vacíos en KV), agregar validación en `_utils/roles.js`:
   - Si `ownersSet` contiene más de `MAX_SAFE_OWNERS` o si intersecta con `teamSet`, registrar alerta y degradar a fallback estático (queda cubierto por logs y tests).

## Evidencias
- Smokes preview2 (lib) post-rollback: `rollback_20251014T162600Z/smokes.txt` (FAIL — rollback pendiente).
- Repro local utils: `bug_repro_20251014T162900Z/*.json`.
- Logs resolutor: `bug_repro_20251014T162900Z/resolve_log.txt`.
- Tests: `roles.unified.resolve.test.mjs` ejecución (PASS).

## Próximos pasos
- [ ] Obtener snapshot actual del KV preview2.
- [ ] Corregir datos y redeploy preview2.
- [ ] Re-ejecutar smokes con `ROLE_RESOLVER_SOURCE=lib` (rollback) y luego con `utils` (canario) una vez validado el dataset.
