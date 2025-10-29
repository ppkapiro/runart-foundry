# RunMedia (CLI)

RunMedia es una herramienta CLI modular para escanear, indexar, asociar, organizar y exportar imágenes del proyecto RUN Art Foundry.

Uso rápido:

- Escaneo inicial y generación del índice:
  - python -m runmedia scan --roots mirror content/media/library
- Verificar consistencia:
  - python -m runmedia verify
- Exportar a CSV:
  - python -m runmedia export csv
 - Generar variantes optimizadas (WebP/AVIF):
   - python -m runmedia optimize --formats webp avif --widths 2560,1600,1200,800,400
   - Sugerencia: probar primero con --limit 10

Ver comandos y opciones:

- python -m runmedia --help

Estructura de datos canónica: content/media/media-index.json

Notas sobre optimización
- Salidas de variantes se guardan en: content/media/variants/<id>/{webp,avif}/w{ancho}.{fmt}
- El índice se actualiza en `items[].variants.{webp,avif}` y `items[].sizes[fmt].w{ancho]` con path, width, height, bytes, generated_at.
- Si `pillow-avif-plugin` no está instalado, el comando omitirá AVIF y continuará con WebP.
- Usa `--force` para regenerar aunque existan; por defecto no se sobrescribe si el origen no cambió.
