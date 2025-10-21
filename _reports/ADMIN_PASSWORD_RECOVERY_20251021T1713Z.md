# Recuperación/Rotación de credencial de administrador (STAGING)

Fecha: 2025-10-21T17:13:00Z
Entorno: STAGING
Sitio: https://staging.runartfoundry.com
Usuario afectado: runart-admin
Ephemeral: true

Acción realizada:
- Se ejecutó el workflow Grant Admin Access (Ephemeral) para establecer/rotar la contraseña del usuario administrador.
- Se generó un password aleatorio y se aplicó vía REST API.
- Se subió un artifact con las credenciales (sin exponerlas en logs).

Evidencias:
- Run OK: https://github.com/RunArtFoundry/runart-foundry/actions/runs/18691911856
- Artifact: admin-credentials (ID: 4331108744)
- Archivo local (no versionado): ci_artifacts/creds_18691911856/admin_credentials.txt
- URL de acceso: https://staging.runartfoundry.com/wp-admin

Notas de seguridad:
- El primer intento (Run 18691747318) expuso temporalmente el valor de PASS en logs. Se procedió a:
  - Enmascarar adecuadamente PASS/AUTH en el workflow.
  - Rotar inmediatamente la contraseña con una nueva ejecución ya enmascarada (Run 18691911856).
- El artifact contiene la contraseña; no se adjunta a repositorio. Acceso limitado a colaboradores con permisos sobre los runs.

Siguientes pasos recomendados:
- Usar el artifact para el primer login de runart-admin y cambiar la contraseña en el primer acceso.
- Confirmar acceso y, si procede, deshabilitar/rotar el usuario o ajustar políticas según el uso.
