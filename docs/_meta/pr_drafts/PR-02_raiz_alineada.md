---
generated_by: copilot
phase: phase2_planning
date: 2025-10-23T15:05:37-04:00
repo: runart-foundry
branch: main
---

# PR-02 — Raíz alineada con fuente canónica (sin mover contenidos)

Título sugerido: chore(docs): PR-02 raíz alineada — portada y roles canónicos (README/STATUS/NEXT_PHASE/CHANGELOG)

## Objetivo
Alinear los documentos raíz con la fuente canónica `docs/live/`, clarificando roles y añadiendo enlaces canónicos, sin mover ni renombrar por ahora.

## Alcance
- `README.md` (raíz): añadir enlace destacado a `docs/live/index.md` como índice canónico.
- `STATUS.md`: decidir mantener en raíz con enlace canónico o duplicar en `docs/live/operations/status_overview.md` (registrar decisión en gobernanza).
- `NEXT_PHASE.md`: enlazar desde `docs/live/` o migrar a issues/roadmap (decisión documentada, sin ejecutar en este PR).
- `CHANGELOG.md`: mantener y enlazar desde `docs/live/`.

## Pasos propuestos
1) Editar `README.md` para incluir una sección “Documentación canónica” → link a `docs/live/index.md`.
2) En `STATUS.md`, añadir banner con rol y enlace canónico. Evaluar necesidad de duplicado en `docs/live/operations/` (sin mover todavía).
3) En `NEXT_PHASE.md`, añadir enlace a hub de planificación (o nota de posible conversión a issues/roadmap).
4) En `CHANGELOG.md`, añadir enlace inverso desde `docs/live/`.
5) Ejecutar lint de documentación y verificador de enlaces.

## Checklist
- [ ] No se mueven ni renombran archivos.
- [ ] README.md enlaza claramente a `docs/live/index.md`.
- [ ] STATUS.md con rol aclarado y enlace canónico.
- [ ] NEXT_PHASE.md y CHANGELOG.md con enlaces/rol aclarados.
- [ ] Frontmatter presente donde aplique.
- [ ] Enlaces verificados (0 rotos).
- [ ] CI verde.

## Riesgos y mitigación
- Confusión por duplicidad temporal: añadir notas claras de canonicidad.
- Enlaces relativos: validar rutas y anchors.

## Fuentes
- `docs/_meta/lote_A_root_docs.md`
- `docs/live/briefing_canonical_source.md`
