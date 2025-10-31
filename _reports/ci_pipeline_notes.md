# CI Pipeline Notes — FASE 3.E Verificación REST

- Fecha: 2025-10-31T17:18:25Z
- Staging: https://staging.runartfoundry.com/
- Comando ejecutado: `python tools/fase3e_verify_rest.py --staging-url https://staging.runartfoundry.com/`
- Código de salida: 20 (UNKNOWN)
- Interpretación:
  - 0 → FOUND_IN_STAGING → aplicar RAMA B (ampliar cascada)
  - 10 → NOT_FOUND_IN_STAGING → aplicar RAMA A (mantener dataset demo)
  - 20 → UNKNOWN → no tocar código; documentar e investigar auth/permisos
- Artifacts:
  - _reports/ping_staging_20251031T171825Z.json
  - _reports/data_scan_20251031T171825Z.json
  - _reports/informe_resultados_verificacion_rest_staging.md
  - _reports/informe_verificacion_rest_staging_error.md
