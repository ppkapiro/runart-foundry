# Guía Responsive — RuneUpFont v0.3.1

Principios:
- Mantener paleta clara y tipografías existentes.
- Cambios quirúrgicos que mejoran layout sin reescrituras grandes.
- Compatibilidad móvil 320–430px y escalado fluido hasta 1440+.

## Tipografía
- `clamp()` en body y h1–h3 para evitar saltos.
- `line-height` consistente (>1.2) para legibilidad.

## Contenedores y layout
- `.container/.wrap` con `max-width: 1200px` y `padding-inline` fluido.
- Grids con `repeat(auto-fit, minmax(280px, 1fr))` para cards (blog/services/projects).
- Evitar `width: 100vw` en hijos; usar 100%.

## Imágenes/medios
- `max-width:100%; height:auto` genérico.
- Cards con `aspect-ratio:16/9` + `object-fit:cover` para mitigar CLS.
- Opcional a futuro: `<picture>` con `srcset/sizes` (sin build adicional ahora).

## Header/anchors
- `scroll-margin-top: var(--header-h)` en headings/ids para que anclas no queden ocultas por sticky.

## Formularios y accesibilidad táctil
- Inputs `font-size:16px` (evita zoom iOS) y `min-height:44px`.
- Botones/links clave con targets ≥ 44px y focus visible.
- Desactivar hovers en `@media (hover:none) and (pointer:coarse)`.

## Safe Areas iOS
- `padding-bottom: env(safe-area-inset-bottom)` en body.
- `padding-top` en header con `env(safe-area-inset-top)`.

## Compatibilidad Chromium
- Evitar fracciones complejas en cálculos; se usan `clamp()` y minmax.
- Limitar `will-change` (no aplicado ahora). Evitar transforms de hover en mobile.

## Archivos
- `assets/css/responsive.overrides.css` — hoja final cargada después de los estilos.
- `functions.php` — enqueue de la hoja responsive.

## Verificación
- Capturas multi-breakpoint en `_artifacts/screenshots_uiux_20251028`.
- Lighthouse móvil: objetivo A11y ≥ 90, BP ≥ 90, Perf ≥ 80 (pendiente automatizar).