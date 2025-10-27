# RunMedia (CLI)

RunMedia es una herramienta CLI modular para escanear, indexar, asociar, organizar y exportar imágenes del proyecto RUN Art Foundry.

Uso rápido:

- Escaneo inicial y generación del índice:
  - python -m runmedia scan --roots mirror content/media/library
- Verificar consistencia:
  - python -m runmedia verify
- Exportar a CSV:
  - python -m runmedia export csv

Ver comandos y opciones:

- python -m runmedia --help

Estructura de datos canónica: content/media/media-index.json
