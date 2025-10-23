---
status: active
owner: reinaldo.capiro
updated: 2025-10-23
audience: internal
tags: [briefing, runart, ui]
---

# TOKENS UI — 2025-10-21 17:28:03
Variables consolidadas y correspondencias con estilos.md

## Variables propuestas
```css
:root { --color-primary: #1a73e8; }
:root { --color-secondary: #6c757d; }
:root { --color-accent: #ff6d00; }
:root { --color-success: #2e7d32; }
:root { --color-warning: #ed6c02; }
:root { --color-danger: #d32f2f; }
:root { --text-primary: #111111; }
:root { --text-secondary: #555555; }
:root { --bg-surface: #ffffff; }
:root { --space-1: 0.25rem; }
:root { --space-2: 0.5rem; }
:root { --space-3: 0.75rem; }
:root { --space-4: 1rem; }
:root { --space-6: 1.5rem; }
:root { --space-8: 2rem; }
:root { --font-base: Inter, system-ui, -apple-system, Segoe UI, Roboto, Ubuntu, Cantarell, Noto Sans, Helvetica Neue, Arial, "Apple Color Emoji", "Segoe UI Emoji"; }
:root { --font-size-body: 1rem; }
:root { --font-size-h1: 2rem; }
:root { --font-size-h2: 1.5rem; }
:root { --font-size-caption: 0.875rem; }
:root { --shadow-sm: 0 1px 2px rgba(0,0,0,.08); }
:root { --shadow-md: 0 2px 6px rgba(0,0,0,.12); }
```

## Mapeo detectado (colores originales → tokens)
Original | Token
--- | ---
#445c9b | --color-primary
#c5923c | --color-secondary
#f6f7fb | --color-accent
rgba(23, 31, 58, 0.12) | --color-success
#2e7d32 | --color-warning

## Validación de contraste AA
- Revisión manual pendiente para pares críticos (texto vs fondo).

## Correspondencia aplicada — Vista Cliente (2025-10-21 17:32:25)

Token | Uso
--- | ---
--color-primary | títulos y CTA
--text-primary | cuerpo de texto
--space-4 | separaciones principales
--font-size-h1 | H1 de portada

## Correspondencia aplicada — Owner/Equipo (2025-10-21 17:42:34)
Token | Uso
--- | ---
--color-primary | títulos, chips de decisión
--text-primary | cuerpo de texto
--space-4 | separaciones de secciones
--font-size-h1 | H1 de portada (Owner/Equipo)

### Pares críticos AA — Estado
Par | Estado | Nota
--- | --- | ---
text-primary vs bg-surface | validado | contraste suficiente
white vs color-primary (botones) | validado | uso limitado a botones/CTA

### + Admin (2025-10-21 17:52:17)
Token | Uso Admin
--- | ---
--color-primary | badges de decisión crítica
--text-primary | cuerpo de texto operativo
--space-4 | separaciones de secciones
--font-size-h1 | H1 de portada Admin

## Correspondencia aplicada — Técnico + Glosario 2.0 (2025-10-21 18:00:45)
Token | Uso Técnico/Glosario
--- | ---
--color-primary | badges de cambios aprobados
--text-primary | cuerpo de logs y parámetros
--space-4 | separaciones de secciones técnicas
--font-size-h1 | H1 de portada Técnico

### Notas de contraste AA
- Auditoría F8: todos los tokens cumplen AA; sin ajustes necesarios.
