# Gobernanza de Tokens — 2025-10-21 18:00:45

## 1. Naming y Convenciones

### Prefijos por categoría
- `--color-*` : colores (primarios, secundarios, texto, fondo).
- `--font-*` : tipografía (base, tamaños, weights).
- `--space-*` : espaciado (padding, margin, gaps).
- `--shadow-*` : sombras (sm, md, lg).
- `--radius-*` : radios de borde.

### Ejemplo de naming
- `--color-primary` (color de acción principal)
- `--font-size-h1` (tamaño titular H1)
- `--space-4` (1rem de espaciado)
- `--shadow-md` (sombra mediana)

## 2. Escalas y Límites

- **Tipografía y espaciado:** usar `rem` (no `px` sueltos).
- **Colores:** solo valores desde tokens; prohibir hex directo en nuevas vistas.
- **Sombras:** definir desde tokens con valores rgba controlados.

## 3. Proceso de Alta/Cambio/Baja

1. **Alta:** propuesta en issue/PR; revisión AA obligatoria; aprobación PM/UX.
2. **Cambio:** justificación documentada; impacto en vistas existentes; regresión AA.
3. **Baja:** marcar obsoleto; periodo de deprecación (1 sprint); redirección a reemplazo.

## 4. Excepciones Controladas

- **Cómo declararlas:** comentario inline con `/* EXCEPCIÓN: motivo + fecha + autor */`.
- **Justificación:** requerimiento de cliente, limitación técnica, temporal hasta refactor.
- **Vigencia:** máximo 2 sprints; revisión obligatoria en QA.

## 5. Verificación AA

- Contraste mínimo: 4.5:1 para texto normal; 3:1 para texto grande/botones.
- Herramientas: auditoría manual + herramienta automatizada (ej. axe, Lighthouse).
- Revisión en cada fase: QA debe validar pares críticos text-primary/bg-surface, color-primary/white.

## 6. Criterios de Aceptación

- Todo token nuevo debe pasar AA antes de merge.
- Sin hex/px directo en código (excepciones documentadas).
- Auditoría de uso sin pendientes críticos antes de cierre de fase.

---
✅ Gobernanza de Tokens implementada — Naming, escalas, proceso y AA definidos.
---
