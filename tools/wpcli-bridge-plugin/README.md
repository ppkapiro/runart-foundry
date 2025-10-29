# RunArt WP-CLI Bridge (REST)

Endpoints REST seguros que exponen un subconjunto de operaciones típicas de WP-CLI, sin requerir acceso SSH.

## Características

- Autenticación mediante Application Passwords (Basic Auth)
- Permisos: requiere `manage_options` (rol Administrator)
- Endpoints:
  - `GET  /wp-json/runart/v1/bridge/health`
  - `POST /wp-json/runart/v1/bridge/cache/flush`
  - `POST /wp-json/runart/v1/bridge/rewrite/flush`
  - `GET  /wp-json/runart/v1/bridge/users`
  - `GET  /wp-json/runart/v1/bridge/plugins`

## Instalación

1. Descarga el ZIP del plugin desde el artefacto del workflow de build (ver sección Workflows)
2. En WordPress Admin: Plugins → Añadir nuevo → Subir plugin → Selecciona el ZIP → Instalar → Activar
3. Verifica el endpoint de health:
   ```bash
   curl -u "<USER>:<APP_PASSWORD>" \
     "https://<tu-sitio>/wp-json/runart/v1/bridge/health"
   ```

## Seguridad

- Requiere usuarios con rol Administrator (cap `manage_options`)
- Usa HTTPS + Basic Auth con Application Passwords
- Limita el alcance a operaciones sin efectos destructivos (excepto flush)

## Ejemplos de uso (curl)

```bash
# Health
curl -s -u "$WP_USER:$WP_APP_PASSWORD" \
  "$WP_BASE_URL/wp-json/runart/v1/bridge/health" | jq .

# Flush cache
curl -s -X POST -u "$WP_USER:$WP_APP_PASSWORD" \
  "$WP_BASE_URL/wp-json/runart/v1/bridge/cache/flush" | jq .

# Flush rewrite rules
curl -s -X POST -u "$WP_USER:$WP_APP_PASSWORD" \
  "$WP_BASE_URL/wp-json/runart/v1/bridge/rewrite/flush" | jq .

# Listar usuarios
curl -s -u "$WP_USER:$WP_APP_PASSWORD" \
  "$WP_BASE_URL/wp-json/runart/v1/bridge/users" | jq '.data.users | length'

# Listar plugins
curl -s -u "$WP_USER:$WP_APP_PASSWORD" \
  "$WP_BASE_URL/wp-json/runart/v1/bridge/plugins" | jq '.data.plugins[0]'
```

## Workflows de soporte

- `build-wpcli-bridge.yml`: empaqueta y publica el ZIP del plugin como artifact
- `wpcli-bridge.yml`: invoca endpoints del bridge y genera reporte en `_reports/bridge/`

## Notas

- `wp_cache_flush()` depende de la implementación de object cache; si no está disponible, responde `object_cache_supported=false`
- Para integrar con plugins de page cache, engancha al hook `runart_bridge_cache_flush`
