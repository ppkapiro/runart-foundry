# Análisis de Micro-copy y Tono Visual — 2025-10-21 17:24:17
status: review-needed

## Propósito del archivo analizado
Revisar 'estilos.md' para asegurar claridad, lenguaje orientado a Cliente y coherencia con tokens/UI.

## Extracto literal del contenido
```
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
```

## Diagnóstico de tono y coherencia
- Tono detectado: cliente
- i18n presente: no
- Mezcla de unidades: no
- Mezcla de formatos de color: sí
- Variables CSS no utilizadas: no

### Ejemplos
- Ejemplo medidas: 18px, 36px, 3px
- Ejemplo colores: #445c9b, #c5923c, #f6f7fb, rgba(23, 31, 58, 0.12), #445c9b

## Propuesta de normalización del micro-copy
- Sustituir términos altamente técnicos por definiciones simples o notas al pie.
- Unificar la voz a tono "cliente" (instrucciones claras y concisas).
- Evitar jerga interna; usar palabras del glosario con definiciones cortas.

## Recomendaciones de i18n
- Introducir claves i18n: ui.estilos.titulo, ui.estilos.descripcion.
- Proveer traducciones ES/EN para encabezados y mensajes claves.

## Acciones inmediatas (checklist)
- [ ] Revisar mezcla px/rem y definir estándar (recomendado rem).
- [ ] Adoptar paleta de color unificada (un solo formato, preferible variables CSS).
- [ ] Añadir sección i18n o marcadores ES/EN.
- [ ] Revisar uso/definición de variables CSS (declaración vs uso).
