---
generated_by: copilot
phase: revision_profunda_v2
date: 2025-10-23T14:18:42-04:00
repo: runart-foundry
branch: main
---

# Revisión Profunda V2 — Diagnóstico integral de documentación

Commit: 23cea283d1f6c1e7819a10d38bb234a2f2d0d373

Este informe radiografía TODO el contenido documental del monorepo (raíz, docs/, reports/_reports/, apps/, scripts/, .github/, etc.). No se movió ni renombró nada; solo se leyó, clasificó heurísticamente y se documentó el estado actual.

## Resumen general
- Archivos totales indexados (todas las extensiones): 73,197
- Por tipo (clasificación heurística):
  - readme: 648
  - adr: 5
  - report: 1,137
  - workflow: 44
  - bitácora: 1,123
  - binary_doc: 0
  - otro: 70,240
- Por estado preliminar:
  - 🟢 activo: 471
  - 🟡 incierto: 72,361
  - 🔴 histórico: 365
- Por extensión (archivo):
  - .md: 1,582
  - .txt: 491
  - binarios doc (pdf/docx/pptx/xlsx): 0
  - otros: 71,124

## a) Distribución por carpeta (top-level)
- docs/: 218 archivos (activos: 218)
- apps/: 25,576 archivos (activos: 209)
- .github/: 53 archivos (activos: 44)
- _archive/: 220 archivos (activos: 0)
- mirror/: 12,537 archivos (activos: 0)
- _reports/: 142 archivos (activos: 0)
- reports/: 7 archivos (activos: 0)
- audits/: 55 archivos (activos: 0)
- ci_artifacts/: 252 archivos (activos: 0)
- tools/: 114 archivos (activos: 0)
- scripts/: 20 archivos (activos: 0)
- wp-content/: 18 archivos (activos: 0)
- plugins/: 2 archivos (activos: 0)
- _dist/: 7 archivos (activos: 0)
- _artifacts/: 1 archivos (activos: 0)
- _tmp/: 8 archivos (activos: 0)
- content/: 2 archivos (activos: 0)
- raíz (README.md, STATUS.md, etc.): 6 archivos sueltos

Nota: “activos” aquí refleja la heurística aplicada (p. ej., docs/ y .github/workflows/ se consideran activos por uso operativo).

## b) Conteo total de documentos por formato
- Markdown (.md): 1,582
- Texto plano (.txt): 491
- Binarios documentales (pdf/docx/pptx/xlsx): 0
- Otros: 71,124

## c) Documentos principales y estado preliminar
- README.md (raíz): incierto
- STATUS.md (raíz): incierto
- NEXT_PHASE.md (raíz): incierto
- CHANGELOG.md (raíz): incierto
- ROADMAP.md (raíz): no encontrado

## d) Hallazgos clave
- Alto volumen de archivos fuera de docs/ (especialmente en apps/ y mirror/); muchos son código u otros recursos no documentales.
- Documentación operativa viva se concentra en:
  - docs/ (activa por definición de capa)
  - .github/workflows/ (definen pipelines, considerados activos)
  - apps/briefing/docs/** (documentación embebida; activa en menor proporción)
- Presencia de histórico/legado:
  - _archive/, _reports/, mirror/, ci_artifacts/ y artefactos temporales.
- Duplicaciones y variantes por fase/fecha: múltiples “CHECKLIST/RESUMEN/FASE*” y bitácoras distribuidas; a consolidar en fases siguientes.
- Archivos activos fuera de docs/: sí, principalmente en .github/workflows/ y apps/briefing/docs/.

## e) Conclusiones iniciales
- La capa docs/ está lista para operar como “live” tras la Fase 1; el resto requiere clasificación y traslado progresivo.
- Las bitácoras y reportes por fase deben consolidarse en docs/archive/ con convenciones de fecha (YYYY-MM-DD) y fase.
- La documentación embebida en apps/briefing/ debe enlazarse o moverse a docs/live/ si aplica a operación cross-proyecto.

## f) Recomendaciones preliminares
- Establecer validadores de frontmatter y enlaces en CI (docs-lint) para .md de docs/ y apps/**/docs/.
- Catalogar bitácoras en docs/archive/ con prefijos de fecha; mantener un índice cronológico global.
- Unificar “checklists” y “runbooks” activos en docs/live/ con enlaces canónicos desde README.md.
- Señalar directorios exclusivamente históricos (_archive/, mirror/, _reports/) para exclusión de lint/links (o lower priority).
- Mantener .github/workflows/ referenciado en governance como “documentación operativa” con pauta de naming y comentarios estructurados.
