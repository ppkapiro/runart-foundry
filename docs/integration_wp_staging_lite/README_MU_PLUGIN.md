# WP Staging Lite — MU-Plugin (RunArt Foundry)

Este MU-plugin habilita endpoints REST y un shortcode mínimo para exponer y visualizar el estado del sitio en WordPress Staging.

## 📦 Estructura

```
wp-content/mu-plugins/wp-staging-lite/
├── wp-staging-lite.php              # Bootstrap del MU-plugin
└── inc/
    ├── rest-status.php              # GET /wp-json/briefing/v1/status
    ├── rest-trigger.php             # POST /wp-json/briefing/v1/trigger (opcional; deshabilitado por defecto)
    └── shortcodes/
        └── briefing-hub.php         # [briefing_hub]
```

## 🔌 Endpoints REST

- GET `/wp-json/briefing/v1/status`
  - Respuesta esperada (mínima):
    ```json
    {
      "version": "staging",
      "last_update": "<ISO8601>",
      "health": "OK",
      "services": [{"name": "web", "state": "OK"}]
    }
    ```
  - Notas: en producción, puede leer `docs/status.json` generado por CI.

- POST `/wp-json/briefing/v1/trigger` (opcional)
  - Deshabilitado por defecto. Devuelve 501 con mensaje instructivo.
  - Para habilitarlo: filtrar `wp_staging_lite_allow_trigger` y devolver `true`. Luego implementar la lógica requerida (p.ej. `repository_dispatch`).

## 🧩 Shortcodes

- `[briefing_hub]`
  - Obtiene `GET /wp-json/briefing/v1/status` y renderiza un listado simple de servicios.
  - Errores de red devuelven mensajes no intrusivos al usuario.

## 🔐 Seguridad

- Sin llamadas externas activas por defecto (trigger deshabilitado con 501).
- Endpoints de lectura abiertos (status) y de acción protegidos por filtro/rol.
- Evitar exponer valores sensibles; usar secrets por nombre.

## 🧪 Pruebas locales

1. Verificar que el MU-plugin aparezca en “Plugins Must Use”.
2. Revisar `/wp-json/` y confirmar `briefing/v1`.
3. Probar `GET /wp-json/briefing/v1/status`.
4. Crear página “Hub Local Test” con `[briefing_hub]`.
5. Registrar resultados en `TESTS_PLUGIN_LOCAL.md`.

### Automatización de validación

- Configurar `docs/integration_wp_staging_lite/local_site.env` con `BASE_URL` y rutas locales.
- Enlazar/copiar el plugin al sitio Local:
  - `scripts/wp_staging_local_link.sh`
- Ejecutar validaciones automáticas de endpoints:
  - `scripts/wp_staging_local_validate.sh` (anexa resultados a `TESTS_PLUGIN_LOCAL.md`)
  - Si `/wp-json/` responde 404, guardar Enlaces Permanentes en WP para forzar flush de rewrites.

## 📎 Referencias

- Dossier externo: `/home/pepe/work/_inspector_extint`
- Especificaciones: `_inspector_extint/specs/wp_staging_lite/`
- Plantillas: `_inspector_extint/kit_entrega/TEMPLATES/`
