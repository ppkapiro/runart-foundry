# SECRETS_REFERENCE — WP Staging Lite

Fecha: 2025-10-22

## Descripción
Listado de secretos sugeridos (nombres) para CI y pruebas en staging. No incluir valores aquí: configúrelos en GitHub Secrets.

## Secrets sugeridos
- `WP_BASE_URL`: URL pública del sitio WP de staging.
- `WP_USER`: usuario con permisos para pruebas (si se requieren llamadas autenticadas fuera de WP).
- `WP_APP_PASSWORD`: App Password de WP asociada a `WP_USER` (si aplica).
- `API_GATEWAY_TOKEN`: solo si se habilita `POST /trigger` con verificación por token.
- `GITHUB_TOKEN`: token automático inyectado por GitHub Actions (no definir manualmente).

## Notas
- Mantener los secretos restringidos por entorno (staging vs prod) y por entorno de repositorio.
- Evitar imprimir valores en logs; use redacción o no loguee cabeceras sensibles.
