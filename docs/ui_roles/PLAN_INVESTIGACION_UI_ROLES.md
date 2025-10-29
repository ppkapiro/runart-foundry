# Plan de Investigación UI/Roles (Briefing v2)

Fecha: 2025-10-21

## Propósito
Alinear la interfaz de usuario (UI) con la matriz de roles del Briefing v2, garantizando que cada rol vea sólo lo necesario, con lenguaje adecuado para Cliente y sin mezclar contenidos técnicos.

## Alcance
- Auditoría y normalización de páginas, secciones y módulos UI orientados a Cliente, Owner Interno, Equipo, Técnico y Admin.
- Definición de “view-as” para simulación de roles sin alterar permisos backend.
- Matriz de visibilidad de componentes (CCEs) por rol.
- Identificación de contenido técnico a mover a vista técnica/aislada.

## Metodología
1. Inventario real de UI a partir del proyecto actual (docs/ui, apps/briefing, etc.).
2. Detección de duplicados/legados y propuesta de destino o descarte.
3. Análisis de lenguaje (micro-copy) y i18n base.
4. Diseño de “view-as” para Admin, con trazabilidad mínima.
5. Revisión con Admin General y priorización de iteraciones.

## Entregables
- roles_matrix_base.yaml (visibilidad inicial por CCE y rol).
- content_matrix_template.md (plantilla de seguimiento por página/rol/acción).
- view_as_spec.md (especificación de simulación de rol).
- ui_inventory.md (inventario real + duplicados/legados + observaciones).
- glosario_tecnico_cliente.md (terminología en lenguaje negocio).

## Criterios de aceptación
- El Admin puede revisar el paquete en docs/ui_roles/ sin contenido técnico mezclado.
- “View-as” diseñado sin romper permisos backend.
- Tabla de visibilidad por rol completada al menos para las principales vistas.

## Riesgos
- Contenido legado mezclado con el actual.
- Falta de i18n puede requerir reestructuración.
- Dependencias CI/CD que afectan la previsualización (p. ej., mkdocs, build de site/).

## Cronograma
- Sprint 1: Cliente + View-as (selector y banner, identificación de páginas clave para Cliente, ajuste de micro-copy).
- Sprint 2: Owner/Equipo (matriz de visibilidad, priorización de evidencias y entregas, revisión de permisos de presentación).
- Sprint 3: Técnico aislado (migración de contenido técnico a vistas aisladas, limpieza de legados y normalización de docs).
