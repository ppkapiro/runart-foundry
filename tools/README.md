# Tools

Utilidades compartidas para DX y automatización que pueden ejecutarse desde cualquier módulo. Todos los scripts aquí deben ser auto descriptivos, idempotentes y libres de dependencias propietarias.

## Convenciones

- Ejecutables en Python deben ser invocables vía `python tools/<script>.py` o mediante targets de `make`.
- Mantener el log en `audits/` cuando proceda (p.ej. `docs_lint.log`).
- Documentar opciones y modos de uso en el encabezado del script.

Scripts actuales:

- `lint_docs.py`: Linter de documentación que ejecuta `mkdocs build --strict`, valida snippets y espacios.
- `check_env.py`: Validador de banderas de entorno y conectividad (migrado desde `briefing/scripts`).
