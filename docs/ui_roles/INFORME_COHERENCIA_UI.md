# Informe de Coherencia UI — 2025-10-21 17:24:17
Relación con estilos.md y tokens detectados.

## Tabla de consistencia (tokens vs uso)
Token | Conteo/Estado
--- | ---
Colores | 7
Tamaños | 3
Variables declaradas | 0
Variables usadas | 4
Fuentes declaradas | 0

## Incongruencias detectadas
- Mezcla de formatos de color (hex/rgb/hsl).
- No se detectaron fuentes declaradas explícitamente.

## Ajustes recomendados
- Normalizar unidades a rem/em, limitar px a casos puntuales.
- Unificar formato de color (preferible variables CSS).
- Asegurar correspondencia 1:1 entre variables declaradas y usadas.
- Declarar tipografías base y jerarquías (H1/H2/H3, body, caption).

## Criterios de validación visual
- Contraste AA mínimo, tamaño de fuente >= 14px (o equivalente rem), jerarquía clara.
- Espaciado consistente (escala 4/8px o rem equivalente).

## Impacto estimado en experiencia Cliente
- Reducción del tiempo de comprensión en 3–7 s por vista al estandarizar copy y jerarquía.

## Conclusión — Nivel de madurez
Medio
