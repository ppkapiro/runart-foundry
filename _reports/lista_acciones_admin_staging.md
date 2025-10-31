# Lista priorizada — Acciones para admin de staging/prod

Fecha: 2025-10-31
Autor: automation-runart

## Prioridad ALTA

1) Confirmación de ubicación del dataset real
- ¿Existe `wp-content/uploads/runart-jobs/enriched/index.json` en prod o en algún staging alternativo?
- Si sí: proporcionar ruta exacta y tamaño aproximado (bytes, total_pages si está disponible).

2) Export REST temporal (si no hay SFTP)
- Autorizar endpoints protegidos para export (solo admin):
  - `GET /wp-json/runart/v1/export-enriched?format=zip`
  - `GET /wp-json/runart/v1/media-index`
- Entregar nonce o token Bearer de admin para una ventana acotada (p. ej. 24–48 h).

3) Permisos en uploads
- Asegurar que existe `wp-content/uploads/runart-jobs/` con permisos de lectura/escritura por el proceso PHP (www-data).
- En caso de sólo lectura, habilitar fallback de colas/logs (se documentará en el panel).

## Prioridad MEDIA

4) Alternativas de extracción
- Si el dataset existe fuera de `uploads/` (otro path o storage externo), indicar ubicación y método de acceso (S3/FTP/HTTPS) y proveer credenciales temporales.

5) Snapshot previo a cambios
- Antes de habilitar lectura desde una nueva ruta, generar snapshot ZIP (con checksum) y guardarlo en el storage corporativo.

## Prioridad BAJA

6) Acceso SFTP temporal
- Si se permite, facilitar acceso SFTP/SSH a una cuenta de sólo lectura para descargar `uploads/runart-jobs/enriched/`.

7) Documentación operativa
- Confirmar política de backups y retención para `uploads/` y base de datos.
