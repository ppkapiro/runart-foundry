=== RunArt WP-CLI Bridge (REST) ===
Contributors: runart
Requires at least: 5.8
Tested up to: 6.x
Stable tag: 1.0.1
License: GPLv2 or later

Plugin mínimo con un endpoint REST de salud:
- Ruta: /wp-json/runart-bridge/v1/health
- Acceso: requiere credenciales con capacidad de "manage_options" (por ejemplo, admin con Application Password).
- Uso: verificar instalación/activación del plugin y servir de base para el bridge controlado por CI/CD.

Instalación:
1) Comprimir como ZIP manteniendo esta carpeta raíz "runart-wpcli-bridge/".
2) Subir en /wp-admin → Plugins → Añadir nuevo → Subir plugin → Instalar → Activar.
3) Probar con credenciales admin (App Password): GET /wp-json/runart-bridge/v1/health
