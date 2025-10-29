# RFC · Tokens UI Minimalista (POC local)

## Resumen
- **Objetivo:** definir un set reducido de tokens (color, tipografía, espaciado, radios, sombras, z-index) para unificar el look & feel del micrositio Briefing sin intervenir producción.  
- **Alcance:** documentación y prototipos locales; ningún build remoto ni merge en main.  
- **Supuestos:** se reutilizan hallazgos previos (`REPORT_UI_MINIMALISTA.md`, `tokens_detectados.json`) y se respeta el principio “experimentar en laboratorio, no en prod”.

## Tokens propuestos

| Categoría | Token | Valor propuesto | Nota |
|-----------|-------|-----------------|------|
| **Color neutro** | `--poc-color-bg` | `#f8f9fb` | Fondo base claro |
|  | `--poc-color-surface` | `#ffffff` | Tarjetas / bloques |
|  | `--poc-color-border` | `#d7dbe3` | Bordes sutiles (1px) |
|  | `--poc-color-text` | `#111827` | Texto principal |
|  | `--poc-color-muted` | `#4b5563` | Texto secundario |
| **Color acento** | `--poc-color-accent` | `#3366ff` | CTA / enlaces |
| **Semánticos** | `--poc-color-success` | `#1f8a5a` | Estados OK |
|  | `--poc-color-warning` | `#c47f17` | Advertencias |
|  | `--poc-color-error` | `#d0364c` | Errores críticos |
| **Tipografía** | `--poc-font-base` | `"Inter", system-ui, -apple-system, sans-serif` | Texto general |
|  | `--poc-font-mono` | `"JetBrains Mono", Menlo, monospace` | Código / datos |
| **Espaciado (8px scale)** | `--poc-space-1` | `0.25rem` (4px) | Tight |
|  | `--poc-space-2` | `0.5rem` (8px) | Base |
|  | `--poc-space-3` | `0.75rem` (12px) | Stack |
|  | `--poc-space-4` | `1rem` (16px) | Bloques |
|  | `--poc-space-6` | `1.5rem` (24px) | Secciones |
|  | `--poc-space-8` | `2rem` (32px) | Páginas |
| **Radios** | `--poc-radius-1` | `4px` | Chips / inputs |
|  | `--poc-radius-2` | `8px` | Tarjetas |
|  | `--poc-radius-3` | `16px` | Contenedores especiales |
| **Sombras** | `--poc-shadow-none` | `none` | Default |
|  | `--poc-shadow-01` | `0 8px 16px rgba(17, 24, 39, 0.08)` | Única sombra permitida |
| **z-index** | `--poc-z-base` | `1` | Contenido |
|  | `--poc-z-overlay` | `10` | Modales / banners |
|  | `--poc-z-toast` | `20` | Notificaciones |

## Mapeo actual → propuesto (solo referencias)

| Área | Valor actual | Fuente | Token propuesto |
|------|--------------|--------|-----------------|
| Userbar chip | `rgba(63, 81, 181, 0.13)` | `apps/briefing/docs/assets/runart/userbar.css:3-22` | `--poc-color-accent` + `--poc-color-muted` |
| Avatar userbar | `rgba(63, 81, 181, 0.92)` | `apps/briefing/docs/assets/runart/userbar.css:3-22` | `--poc-color-accent` sólido |
| Sombra menús | `0 12px 32px rgba(15, 23, 42, 0.18)` | `apps/briefing/docs/assets/runart/userbar.css:9-20` | `--poc-shadow-01` |
| Banner env | `applyEnv('local')` + inline `ensureBanner` | `apps/briefing/docs/assets/env-flag.js:12-28` | Fondo `--poc-color-surface`, texto `--poc-color-text` |
| View-as toggle | inline style con `select` flotante | `apps/briefing/overrides/main.html:120-162` | Uso de `--poc-space-2`, `--poc-radius-2` |
| Botones primarios | `background: var(--md-primary-fg-color)` + sombras | `overrides/main.html` + `mkdocs` defaults | Botón `.poc-btn-primary` (`--poc-color-accent`, sombra mínima) |
| Tarjetas dashboards | Varias clases `.kpi`, `.ra-dash__card` con sombras intensas | `apps/briefing/functions/_utils/ui.js`, doc styles | `--poc-color-surface` + borde `--poc-color-border` |
| Fuentes | Inter + Playfair + JetBrains + Roboto | `mkdocs.yml` + `overrides/main.html` | Reducir a `--poc-font-base` / `--poc-font-mono` |

*(Los archivos citados se mantienen sin cambios en esta etapa; las rutas sirven como referencia para futuras PRs.)*

## Reglas de uso
- **Jerarquía tipográfica:**  
  - H1 32px/1.2 (`--poc-font-base`, peso 600)  
  - H2 24px/1.3 (peso 600)  
  - H3 20px/1.3 (peso 500)  
  - Body 16px/1.5 (peso 400)  
  - Small 14px/1.5 (color `--poc-color-muted`)  
  - Code 14px/1.4 (`--poc-font-mono`, fondo `--poc-color-surface`, borde `--poc-color-border`)
- **Ritmo vertical:**  
  - Espaciado base `--poc-space-2` entre elementos, `--poc-space-4` para bloques, `--poc-space-6` para secciones.  
  - Listas y párrafos: margen inferior `--poc-space-2`.
- **Densidad:**  
  - Padding estándar `--poc-space-3` en tarjetas y `--poc-space-2` en botones.  
  - Formularios compactos: `--poc-space-1` vertical.
- **Bordes vs sombras:**  
  - Usar bordes (`--poc-color-border`) como separación principal.  
  - Sombra `--poc-shadow-01` reservada para overlays y menús flotantes.  
  - `--poc-shadow-none` para estados reposo.
- **Modo oscuro derivado:**  
  - Invertir superficies (`#0f172a` fondo, `#1e293b` surface), conservar tokens semánticos y acento con ajustes de luminosidad ±10%. (Se documentará cuando se extienda el POC.)

## Plan de adopción por fases
- **Quick wins (0–2 h):**  
  - Documentar tokens en `tokens.poc.css` y validar en laboratorio `minimal_poc.md`.  
  - Ajustar env-banner y botones en POC para medir contraste.  
  - Recoger feedback de stakeholders.
- **Corto plazo (1–2 días):**  
  - Centralizar tokens en `apps/briefing/docs/assets/theme/tokens.css` (archivo real futuro).  
  - Sustituir paleta dispersa en userbar, env-banner y dashboards.  
  - Reducir a Inter + JetBrains en plantilla MkDocs.
- **Sprint base:**  
  - Refactor UI dashboards/editor con componentes basados en tokens.  
  - Implementar modo oscuro token-driven y eliminar overlays redundantes.  
  - Automatizar lint de tokens (script que detecte hex ajenos).

> **Recordatorio:** este RFC no modifica código existente; habilita la conversación para próximas iteraciones en la rama local `feat/ui-minimal-poc`.
