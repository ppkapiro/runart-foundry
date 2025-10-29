# Plan de Cierre de Ramas — Q4 2025

Fecha: 2025-10-29
Origen: _reports/INVENTARIO_RAMAS_20251028.json (generated: 2025-10-28)
Repositorio: RunArtFoundry/runart-foundry

---

## Criterios de decisión

Se aplican reglas mínimas y no destructivas por defecto:

- Cerrar (close): behindMain > 150 y aheadOfMain == 0.
- Conservar (keep): aheadOfMain > 0 (tienen commits propios por rescatar o ya en proceso).
- Revisar/Rebase: behindMain > 150 y aheadOfMain > 0 (proponer rebase/cherry-pick a rama activa).
- Stale tolerado: behindMain ≤ 150 y aheadOfMain == 0 (marcar para seguimiento; no cerrar aún).

Notas:
- No se toca develop ni main.
- Duplicados “origin/…” y “upstream/…” se evalúan por separado.
- Toda eliminación remota deberá confirmarse y registrarse en CIERRE_RAMAS_LOG_20251029.md.

---

## Propuesta de Cierre (close)

Cumplen estricto: behindMain > 150 y aheadOfMain == 0.

- origin/preview (behindMain: 311, ahead: 0, status: stale)
- upstream/preview (behindMain: 311, ahead: 0, status: stale)

Acción propuesta:
- Eliminar local y remoto (origin y upstream) conservando referencia por 30 días en backups del proveedor (GitHub) y en `_reports/CIERRE_RAMAS_LOG_20251029.md`.

---

## Conservar (keep)

Ramas con aheadOfMain > 0. Recomendación: mantener, y, si behindMain > 150, preparar rebase/cherry-pick hacia rama activa.

Ejemplos (muestra, ver inventario para lista completa):
- develop (origin/upstream) — behind: 311, ahead: 2–18
- ci/… (varias) — ahead: 15–27
- feature/pr-* — ahead: 1–11
- fix/* — ahead: 1–42
- ops/* — ahead: 1–43
- feature/wp-staging-lite-integration — ahead: 12

---

## Stale tolerado (seguimiento, no cerrar aún)

Ramas con behindMain ≤ 150 y aheadOfMain == 0: seguir 7 días; si no hay actividad, escalar a cierre.

- origin/feat-local-no-auth-briefing (behind: 27, ahead: 0, status: stale)
- upstream/feat-local-no-auth-briefing (behind: 27, ahead: 0, status: stale)
- origin/feat/briefing-status-integration-research (behind: 142, ahead: 0, status: stale)
- upstream/feat/briefing-status-integration-research (behind: 142, ahead: 0, status: stale)

---

## Rebase/Cherry-pick recomendado (no cierre)

Ramas con behindMain > 150 y aheadOfMain > 0. Propuesta: abrir PR técnico de rebase/cherry-pick hacia `develop` una vez que se alinee con `main`.

Muestras:
- origin/feature/preview2-workflow — behind: 311, ahead: 2
- origin/ci/fix-preview-extractor — behind: 311, ahead: 37
- origin/fix/preview-role-resolution — behind: 311, ahead: 42
- origin/ops/overlay-deploy-ci — behind: 311, ahead: 43
- upstream/… (análogo a los anteriores)

---

## Procedimiento de ejecución (resumen)

1) Validar este plan con el owner (ventana de 24 h). 
2) Ejecutar eliminación solo para la sección “Propuesta de Cierre”.
3) Registrar resultado en `_reports/CIERRE_RAMAS_LOG_20251029.md` (OK/ERROR por rama y remoto).
4) Crear issues para “Stale tolerado” (seguimiento) y “Rebase recomendado”.

KPIs:
- Ramas cerradas: 2 (preview en origin, upstream)
- Ramas a seguimiento: 4
- Ramas a rebase: 8–15 (estimado, ver inventario)

---

## Riesgos y mitigación

- Riesgo: pérdida de contexto en `preview`. Mitigación: no tiene commits propios (ahead 0) y está 311 commits atrás; historia cubierta en `main`/tags.
- Riesgo: cierre prematuro de “stale tolerado”. Mitigación: periodo de gracia 7 días + comunicación previa.

---

Documento generado en base al inventario del 2025-10-28. Si cambian las métricas de behind/ahead, regenerar este plan.
