# Informe — Verificación REST en staging (ERROR / UNKNOWN)

Fecha: 2025-10-31T17:18:25Z
Entorno: https://staging.runartfoundry.com/
Alcance: FASE 3.E — Verificación por REST exclusivamente (sin SFTP/SSH)

## Endpoints consultados

1) GET /wp-json/runart/v1/ping-staging
- Código HTTP: 404
- Cuerpo: {"code":"rest_no_route","message":"No se ha encontrado ninguna ruta que coincida con la URL y el método de la solicitud.","data":{"status":404}}
- Cabeceras usadas: Accept: application/json

2) GET /wp-json/runart/v1/data-scan
- Código HTTP: 404
- Cuerpo: {"code":"rest_no_route","message":"No se ha encontrado ninguna ruta que coincida con la URL y el método de la solicitud.","data":{"status":404}}
- Cabeceras usadas: Accept: application/json

Notas:
- Los JSON originales generados por el script se encuentran en:
  - _reports/ping_staging_20251031T171825Z.json
  - _reports/data_scan_20251031T171825Z.json

## Interpretación

- summary.dataset_real_status = UNKNOWN (código de salida del verificador: 20)
- La API REST de WordPress respondió "rest_no_route" (404) para ambos endpoints específicos del plugin unificado.

## Hipótesis

- El plugin unificado no está instalado/activado en el staging indicado.
- El staging podría estar detrás de un WAF (Cloudflare Access) que interfiere en las rutas específicas del plugin.
- Diferencia de namespace o base path en el staging actual.

## Recomendación

- Confirmar que el plugin "RunArt IA-Visual Unified" está instalado y activo en staging.
- Si hay protección (Access/Token), reintentar con las cabeceras adecuadas:
  - X-WP-Nonce: <nonce>
  - Authorization: Bearer <token>
- Verificar que el namespace "runart" esté habilitado y visible vía `/wp-json` (índice de namespace). 
- Una vez resuelto el acceso, reejecutar la FASE 3.E para decidir A/B automáticamente.

## Estado de la fase

- FASE 3.E: pendiente por auth (UNKNOWN).
