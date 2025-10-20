# Checklist de accesibilidad — POC UI Minimalista

## Criterios WCAG AA
- [ ] Contraste mínimo 4.5:1 en texto normal (tokens principales vs. fondo).
- [ ] Contraste 3:1 en texto grande (H1–H3).
- [ ] Estados de foco visibles en botones y enlaces (`.poc-btn-*`).
- [ ] Orden de tabulación lógico en `minimal_poc.md`.
- [ ] Tamaño mínimo interactivo 44x44px (botones, badges).
- [ ] Compatibilidad dark mode (tokens previstos, validar contraste manual).
- [ ] Soporte `prefers-reduced-motion` (no animaciones agresivas).
- [ ] Lectura fluida en **1024 px**, **768 px**, **375 px**.

## Resultados de prueba (mkdocs serve)
- Contraste textos principales: _pendiente_ — `mkdocs serve` no disponible en este entorno (`PermissionError` al abrir puerto).
- Contraste estados (warn/error): _pendiente_.
- Foco visible: _pendiente_.
- Orden tab: _pendiente_.
- Prueba táctil 375 px: _pendiente_.
- Dark mode preliminar: _pendiente_.
- Reduced motion: _pendiente_.
- Observaciones adicionales: Reintentar en estación local con permisos de red habilitados.

> Actualizar este checklist tras revisar la página `internal/briefing_system/ui/lab/minimal_poc/` con `mkdocs serve`.
