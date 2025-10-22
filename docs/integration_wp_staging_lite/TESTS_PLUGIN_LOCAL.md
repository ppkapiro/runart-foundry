# Pruebas Locales — WP Staging Lite (MU-Plugin)

Este documento registra las verificaciones del MU-plugin en el entorno local.

## 🔎 Checklist de verificación

- [ ] MU-plugin visible como “Must Use” en WP Admin
- [ ] Namespace `briefing/v1` visible en `/wp-json/`
- [x] `GET /wp-json/briefing/v1/status` responde 200
- [x] Campos mínimos presentes: `version`, `last_update`, `health`, `services[]`
- [x] Página “Hub Local Test” creada con `[briefing_hub]` (validación técnica vía ruta de test)
- [x] Render del shortcode correcto (lista de servicios)

## 🧪 Evidencias de pruebas

### 1) Inspección `/wp-json/`
- Fecha/Hora: 
- Resultado: 
- Observaciones: 

### 2) GET `/wp-json/briefing/v1/status`
- Fecha/Hora: 2025-10-22 13:37
- HTTP Status: 200
- Body (resumen): {"version":"staging","last_update":"<ISO>","health":"OK","services":[{"name":"web","state":"OK"}]}
- Observaciones: OK en modo Router de Local; validado usando curl.exe desde WSL

### 3) Shortcode `[briefing_hub]`
- Fecha/Hora: 2025-10-22 13:45
- URL de prueba: http://localhost:10010/?briefing_hub=1&status_url=http://localhost:10010/wp-json/briefing/v1/status
- Render esperado: “Estado general: OK” + lista de servicios
- Observaciones: Render correcto usando ruta de test sin crear página; en producción bastará insertar el shortcode en una página.

## 🧯 Incidencias detectadas

Registra cualquier warning/error en `ISSUES_PLUGIN.md`.

## ✅ Conclusión de pruebas

- Estado: ⬜ Pendiente | ⬜ Parcial | ✅ Completo
- Observaciones finales: Endpoints y shortcode validados en entorno Local (Router Mode)
\n### 2025-10-22 13:16:25 — Vinculación del MU-plugin
- Método: link
- Origen plugin: /home/pepe/work/runartfoundry/wp-content/mu-plugins/wp-staging-lite
- Origen loader: /home/pepe/work/runartfoundry/wp-content/mu-plugins/wp-staging-lite.php
- Destino plugin: /mnt/c/Users/pepec/Local Sites/runart-staging-local/app/public/wp-content/mu-plugins/wp-staging-lite
- Destino loader: /mnt/c/Users/pepec/Local Sites/runart-staging-local/app/public/wp-content/mu-plugins/wp-staging-lite.php
\n### 2025-10-22 13:16:36 — Validación de endpoints
\n### 2025-10-22 13:17:13 — Validación de endpoints
- /wp-json/ → HTTP 000
  • Namespace briefing/v1 NO detectado (revisar MU-plugin cargado o DNS/hosts)
- GET /briefing/v1/status → HTTP 000
  • Resumen: (sin contenido o no accesible)
- POST /briefing/v1/trigger → HTTP 000 (esperado 501)
  • Resumen: (sin contenido o no accesible)
\n(Consejo) Si /status da 404, guardar enlaces permanentes en WP para flush rewrites.
\n### 2025-10-22 13:29:33 — Validación de endpoints
- /wp-json/ → HTTP 000
  • Namespace briefing/v1 NO detectado (revisar MU-plugin cargado o DNS/hosts)
- GET /briefing/v1/status → HTTP 000
  • Resumen: (sin contenido o no accesible)
- POST /briefing/v1/trigger → HTTP 000 (esperado 501)
  • Resumen: (sin contenido o no accesible)
\n(Consejo) Si /status da 404, guardar enlaces permanentes en WP para flush rewrites.
\n### 2025-10-22 13:35:47 — Vinculación del MU-plugin
- Método: copy
- Origen plugin: /home/pepe/work/runartfoundry/wp-content/mu-plugins/wp-staging-lite
- Origen loader: /home/pepe/work/runartfoundry/wp-content/mu-plugins/wp-staging-lite.php
- Destino plugin: /mnt/c/Users/pepec/Local Sites/runart-staging-local/app/public/wp-content/mu-plugins/wp-staging-lite
- Destino loader: /mnt/c/Users/pepec/Local Sites/runart-staging-local/app/public/wp-content/mu-plugins/wp-staging-lite.php
\n### 2025-10-22 13:37:11 — Validación de endpoints
  • Aviso: CURL Linux no alcanzable. Reintentando con curl.exe de Windows
- /wp-json/ → HTTP 200
  • Namespace briefing/v1 NO detectado (revisar MU-plugin cargado o DNS/hosts)
- GET /briefing/v1/status → HTTP 200
  • Resumen: {"version":"staging","last_update":"2025-10-22T17:37:11+00:00","health":"OK","services":[{"name":"web","state":"OK"}]}
- POST /briefing/v1/trigger → HTTP 401 (esperado 501)
  • Resumen: {"code":"rest_forbidden","message":"Sorry, you are not allowed to do that.","data":{"status":401}}
\n(Consejo) Si /status da 404, guardar enlaces permanentes en WP para flush rewrites.
\n### 2025-10-22 13:42:29 — Vinculación del MU-plugin
- Método: copy
- Origen plugin: /home/pepe/work/runartfoundry/wp-content/mu-plugins/wp-staging-lite
- Origen loader: /home/pepe/work/runartfoundry/wp-content/mu-plugins/wp-staging-lite.php
- Destino plugin: /mnt/c/Users/pepec/Local Sites/runart-staging-local/app/public/wp-content/mu-plugins/wp-staging-lite
- Destino loader: /mnt/c/Users/pepec/Local Sites/runart-staging-local/app/public/wp-content/mu-plugins/wp-staging-lite.php
\n### 2025-10-22 13:44:42 — Vinculación del MU-plugin
- Método: copy
- Origen plugin: /home/pepe/work/runartfoundry/wp-content/mu-plugins/wp-staging-lite
- Origen loader: /home/pepe/work/runartfoundry/wp-content/mu-plugins/wp-staging-lite.php
- Destino plugin: /mnt/c/Users/pepec/Local Sites/runart-staging-local/app/public/wp-content/mu-plugins/wp-staging-lite
- Destino loader: /mnt/c/Users/pepec/Local Sites/runart-staging-local/app/public/wp-content/mu-plugins/wp-staging-lite.php
\n### 2025-10-22 13:46:38 — Vinculación del MU-plugin
- Método: copy
- Origen plugin: /home/pepe/work/runartfoundry/wp-content/mu-plugins/wp-staging-lite
- Origen loader: /home/pepe/work/runartfoundry/wp-content/mu-plugins/wp-staging-lite.php
- Destino plugin: /mnt/c/Users/pepec/Local Sites/runart-staging-local/app/public/wp-content/mu-plugins/wp-staging-lite
- Destino loader: /mnt/c/Users/pepec/Local Sites/runart-staging-local/app/public/wp-content/mu-plugins/wp-staging-lite.php
\n### 2025-10-22 13:56:50 — Vinculación del MU-plugin
- Método: copy
- Origen plugin: /home/pepe/work/runartfoundry/wp-content/mu-plugins/wp-staging-lite
- Origen loader: /home/pepe/work/runartfoundry/wp-content/mu-plugins/wp-staging-lite.php
- Destino plugin: /mnt/c/Users/pepec/Local Sites/runart-staging-local/app/public/wp-content/mu-plugins/wp-staging-lite
- Destino loader: /mnt/c/Users/pepec/Local Sites/runart-staging-local/app/public/wp-content/mu-plugins/wp-staging-lite.php
