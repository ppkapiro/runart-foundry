# Registro de Incidentes — RUNArt Foundry

Este documento centraliza la gestión de incidentes operativos relacionados con el monorepo y su plataforma de despliegue.

## Procedimiento

1. **Detonar incidente** cuando exista impacto en clientes, disponibilidad, integridad de datos o incumplimiento de SLA interno.
2. **Abrir issue** usando la plantilla `incident.md` en GitHub, etiquetar con `type:incident` y asignar responsable inicial.
3. **Recolección de datos** en la primera hora: logs relevantes, tiempo de detección, servicios afectados.
4. **Mitigación inmediata** documentada en la sección “Mitigación” de la ficha.
5. **Postmortem obligatorio** si el impacto es "Alto" o hubo reincidencia dentro de 30 días. Adjuntar enlace en “Acciones correctivas”.
6. **Cierre** cuando las acciones correctivas tengan due date validado y el riesgo residual sea aceptable. Registrar fecha de cierre en el issue.

## Plantilla por incidente

```
## Identificación
- **Fecha/Hora (UTC)**:
- **Reportado por**:
- **Estado actual**: _[Abierto | Mitigado | Cerrado]_

## Impacto
- **Severidad**: _Baja / Media / Alta / Crítica_
- **Clientes / usuarios afectados**:
- **Sistemas involucrados**: _apps/briefing, services/..., packages/..., tools/..._

## Línea de tiempo
- **Detección**:
- **Mitigación aplicada**:
- **Restauración completa**:

## Causa raíz
- Descripción corta.
- Factores contribuyentes.

## Mitigación inmediata
- Acciones ejecutadas para contener el incidente.

## Acciones correctivas
- [ ] Acción 1 — Responsable — Due date
- [ ] Acción 2 — Responsable — Due date

## Evidencias y logs
- Logs relevantes (adjuntar rutas o enlaces a `audits/`).
- Artefactos (screenshots, exportaciones, etc.).

## Seguimiento
- Próxima revisión en (fecha).
- Enlace al issue/postmortem.
```

## Historial

> Registra aquí un índice cronológico de incidentes, ordenando por fecha más reciente.
> Ejemplo de entrada:
>
> - **2025-11-02 — INC-0003** · Severidad Alta · apps/briefing · Causa: fallo en deploy planchado. [Issue #123](https://github.com/ppkapiro/runart-foundry/issues/123)
