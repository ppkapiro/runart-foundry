# 🧾 Reparación auto-detect (MODO SEGURO) — 20251021_161858

## ⚠️ Diagnóstico
No se localizaron wp-config.php en las siguientes rutas:
- /
- /htdocs
- /homepages/*/*/htdocs (IONOS típico)

## Próximos pasos
1. Ejecutar este script en el servidor real (vía SSH o runner remoto)
2. O proporcionar BASE_PATH manualmente:
   ```bash
   BASE_PATH=/ruta/real ./tools/repair_autodetect_prod_staging.sh
   ```

## Variables de entorno opcionales
- DB_USER, DB_PASSWORD, DB_HOST: Para forzar credenciales de BD
- WP_USER, WP_APP_PASSWORD: Para regenerar permalinks vía REST
- CLOUDFLARE_API_TOKEN, CF_ZONE_ID: Para purgar caché
- REPORT_DIR: Sobrescribir directorio de reportes (default: _reports/repair_autodetect)
