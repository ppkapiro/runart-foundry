---
generated_by: copilot
phase: revision_profunda_v2
date: 2025-10-23T14:18:42-04:00
repo: runart-foundry
branch: main
---

# Revisión Profunda V2 — Próximos pasos sugeridos

## 1) Carpetas con documentación viva
- docs/ (base “live” creada en Fase 1): consolidar guías, runbooks, ADRs vigentes.
- .github/workflows/: mantener comentarios y convenciones como documentación operativa.
- apps/briefing/docs/**: decidir qué materiales deben tener réplica/enlace en docs/live/.

## 2) Material a archivar o unificar
- _archive/, _reports/, mirror/, ci_artifacts/: mover o referenciar en docs/archive/ con índice cronológico.
- Bitácoras por fase/fecha (FASE*, *bitacora*, reports de auditorías): estandarizar prefijos YYYY-MM-DD y registrar en docs/archive/index.md.
- Checklists y runbooks duplicados: unificar versiones canónicas en docs/live/ y vincular desde README.md.

## 3) Fuente principal de Briefing
- Establecer docs/live/ como fuente canónica transversal.
- Mantener documentación específica de apps en apps/briefing/docs/** con enlaces de ida y vuelta a docs/live/.

## 4) Validadores y workflows dependientes
- docs-lint (MkDocs/linters): agregar verificación de frontmatter (campos de `_meta/frontmatter_template.md`).
- Enlaces internos: añadir verificador de links (rotos/huérfanos) en CI.
- structure-guard: actualizar reglas para permitir capas live/archive/_meta y marcar exclusiones para mirror/_archive/_reports/.

## 5) Áreas que requieren validación humana
- Clasificación “incierto”: alto volumen (72k+); priorizar por impacto (docs/ui_roles, architecture, ops, i18n, integration_wp_staging_lite).
- Documentos en raíz (README.md, STATUS.md, NEXT_PHASE.md, CHANGELOG.md): decidir su rol canónico y enlazarlos desde docs/live/.
- Documentación embebida en apps/: decidir traslado o enlaces.

## 6) Roadmap de organización (borrador)
- Semana 1: activar lint de frontmatter y verificador de enlaces; crear índices canónicos.
- Semana 2: migración controlada a live/archive (por dominios: ops → i18n → seo → ui_roles ...).
- Semana 3: consolidación de checklists/runbooks; cierre de duplicados.
- Semana 4: limpieza de histórico y actualización de governance.

## 7) Notas
- Esta lista no mueve archivos; es una guía operativa para las siguientes fases.
- Mantener PRs atómicos por lote de documentos con validación de CI.
