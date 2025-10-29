# Responsive Diff — Cambios aplicados (2025-10-28)

## Archivos modificados
- `wp-content/themes/runart-base/functions.php`
  - Encolado final de `assets/css/responsive.overrides.css` (versión 0.3.1) dependiente de `runart-base-style`.

- `wp-content/themes/runart-base/assets/css/responsive.overrides.css`
  - Contención overflow-x con `clip`.
  - Tipografía fluida con `clamp()` en body y encabezados.
  - Contenedores fluidos `.container/.wrap` con `max-width` y `padding-inline` adaptativos.
  - Safe areas iOS (`env(safe-area-inset-*)`).
  - `scroll-margin-top` global para anclas bajo headers sticky.
  - Utilidad `.grid-auto` y ajustes para `.blog-grid`, `.services-grid`, `.projects-grid` con `auto-fit + minmax`.
  - `aspect-ratio: 16/9` y `object-fit: cover` para imágenes de cards.
  - Targets táctiles mínimos (44px) en botones/links claves, inputs a 16px.
  - Media query para desactivar efectos de hover en coarse pointers.
  - Tweaks de tipografía/spacing para ≤ 430px.

## Justificación
Cambios mínimos y encapsulados para cumplir criterios de aceptación responsive sin alterar paleta, contenidos ni i18n. Se prioriza estabilidad visual en móviles (320–430px) y grids fluidas.
