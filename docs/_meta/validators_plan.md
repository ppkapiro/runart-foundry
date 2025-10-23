---
generated_by: copilot
phase: post_revision_v2
date: 2025-10-23T14:31:24-04:00
repo: runart-foundry
branch: main
---

# Borrador — Plan de validadores (no activar aún)

Este plan define validadores a integrar en CI en fases posteriores.

## 1) Frontmatter requerido
- Plantilla estándar: `docs/_meta/frontmatter_template.md`
- Campos mínimos: `status`, `owner`, `updated`, `audience`, `tags`
- Alcance: todos los `.md` en `docs/**` y `apps/**/docs/**`

## 2) Verificador de enlaces internos
- Targets: `docs/**` y `apps/**/docs/**`
- Reglas: detectar enlaces rotos, orfandad y referencias a rutas legacy
- Salida: reporte con archivo/anchor de destino y sugerencia de corrección

## 3) Exclusiones de histórico
- Excluir de validación: `_archive/`, `_reports/`, `mirror/`, `ci_artifacts/`
- Regla: permitir solo chequeos básicos (existencia de archivo), no frontmatter ni enlaces

## 4) Integración con CI (posterior)
- No activar todavía. Una vez aprobado:
  - Añadir a `.github/workflows/docs-lint.yml` o crear job dedicado
  - Publicar artifact con log de validación y anotaciones

## 5) Métricas básicas
- % de documentos con frontmatter válido
- % de enlaces válidos por carpeta
- Tiempo medio de validación por 100 documentos
