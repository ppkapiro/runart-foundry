# Plan de Correcciones UI — 2025-10-21 17:24:17
Objetivo: corregir incoherencias de estilo, uniformizar lenguaje y preparar vista Cliente.

## Hallazgos de coherencia (resumen)
- Mezcla de formatos de color.

## Acciones de corrección
| Área | Acción | Prioridad (P0/P1/P2) | Responsable | Evidencia |
| --- | --- | --- | --- | --- |
| Unidades | Migrar px→rem/em en estilos.md | P1 | UX | diff estilos.md |
| Colores | Unificar a variables CSS globales | P1 | UX | tokens en estilos.md |
| Variables | Alinear declaración/uso de variables | P2 | UI Dev | grep var() |
| Tipografías | Definir jerarquía base (H1/H2/Body) | P2 | UX | estilos tipográficos |
| i18n | Introducir claves ES/EN en copy | P0 | PM/UX | secciones i18n |

## Dependencias
- content_matrix_template.md: columnas Acción y Prioridad deberán actualizarse para páginas P1/P0.
- PLAN_BACKLOG_SPRINTS.md: crear historias de corrección UI (Sprint 1).

## Plan de validación post-corrección
- Revisión visual por checklist AA y pruebas con 3 usuarios internos.
- Validación semántica con Admin General.

## Bloqueadores visuales (si aplica)
- Tokens globales no definidos/consistentes (bloqueador hasta acordar paleta/escala).
