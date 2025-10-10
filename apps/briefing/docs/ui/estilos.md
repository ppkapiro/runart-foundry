# Guía de estilos UI (Etapa 4)

La Etapa 4 amplía los tokens visuales del briefing y aporta componentes de referencia para reforzar consistencia entre dashboards, formularios y herramientas internas.

## Tokens base

| Token | Descripción | Valor |
| --- | --- | --- |
| `--font-sans` | Fuente principal para párrafos y formularios | `"Inter", "Segoe UI", "Helvetica Neue", Arial, sans-serif` |
| `--font-serif` | Titulares y métricas destacadas | `"Playfair Display", "Georgia", serif` |
| `--brand-indigo-500` | Color primario para acciones | `#445c9b` |
| `--brand-gold-500` | Énfasis secundario (chips, etiquetas) | `#c5923c` |
| `--surface-muted` | Fondo general de páginas | `#f6f7fb` |
| `--shadow-soft` | Sombra suave para tarjetas elevadas | `0 18px 36px rgba(23, 31, 58, 0.12)` |

Los tokens se declaran en `assets/extra.css`; cualquier vista puede reutilizarlos desde CSS o inline usando `style="color: var(--brand-indigo-500)"`.

## Swatches de color

<div class="token-grid interno" role="list">
  <div class="token-swatch" role="listitem">
    <div class="token-swatch__color" style="background: var(--brand-indigo-500);"></div>
    <strong>Indigo primario</strong>
    <code>#445c9b</code>
  </div>
  <div class="token-swatch" role="listitem">
    <div class="token-swatch__color" style="background: var(--brand-gold-500);"></div>
    <strong>Dorado acento</strong>
    <code>#c5923c</code>
  </div>
  <div class="token-swatch" role="listitem">
    <div class="token-swatch__color" style="background: var(--brand-emerald-500);"></div>
    <strong>Emerald éxito</strong>
    <code>#2e7d32</code>
  </div>
</div>

Las tarjetas mantienen contraste AA en modo claro y oscuro; el script `mark_internal.py` asegura que esta página se marque como interna cuando corresponda (ejemplo arriba con `.interno`).

## Componentes de referencia

<div class="ui-card" tabindex="0">
  <h3 class="ui-card__title">Ficha de proyecto — resumen</h3>
  <p>Información curada para clientes VIP, con enlaces directos a assets y notas de validación.</p>
  <div class="metric">
    <span class="metric__value">38</span>
    <span class="metric__label">fichas aceptadas</span>
  </div>
  <div class="ui-card__meta">
    <span class="ui-chip">Equipo</span>
    <span class="ui-chip ui-chip--accent">ARQ-4</span>
  </div>
  <div class="ui-stack">
    <button type="button">Abrir dashboard</button>
    <button type="button" class="btn-ghost">Ver documentación</button>
  </div>
</div>

La tarjeta responde al foco (`tabindex="0"`) con `box-shadow` de alto contraste y respeta `prefers-reduced-motion`.

## Accesibilidad

- Foco visible global mediante `outline-offset: 3px` y token `--acc-focus` (color aprobado por WCAG).
- Estados oscuros (`prefers-color-scheme: dark`) ajustan fondo y bordes para mantener ratios AA.
- Botones usan sombra y transición suave, desactivadas automáticamente al habilitar `prefers-reduced-motion: reduce`.

Para mantener la paridad visual:

1. Usa botones `btn-ghost` para acciones secundarias junto a un primario.
2. Prefiere `.metric` para cifras clave en dashboards.
3. Alinea colores con `var(--brand-*)`; evita hex hardcodeados.
