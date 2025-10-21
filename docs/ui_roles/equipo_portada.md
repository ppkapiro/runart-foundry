# Vista Equipo — Portada

Propósito: Seguimiento operativo para el equipo (tareas, hitos próximos, evidencias de trabajo).

## Métricas del Sprint
- CCE: kpi_chip
```json
{{ ./docs/ui_roles/equipo_vista.json:kpis }}
```

## Hitos próximos
- CCE: hito_card
```json
{{ ./docs/ui_roles/equipo_vista.json:hitos }}
```

## Decisiones operativas
- CCE: decision_chip
```json
{{ ./docs/ui_roles/equipo_vista.json:decisiones }}
```

## Entregables del Sprint
- CCE: entrega_card
```json
{{ ./docs/ui_roles/equipo_vista.json:entregables }}
```

## Evidencias
- CCE: evidencia_clip
```json
{{ ./docs/ui_roles/equipo_vista.json:evidencias }}
```

---

## i18n
ES:
- equipo.title: "Seguimiento del Sprint"
- equipo.cta: "Subir evidencia"

EN:
- equipo.title: "Sprint tracking"
- equipo.cta: "Upload evidence"

---

## Mapa CCE↔Campos
- kpi_chip ← equipo_vista.json.kpis[] { label, value }
- hito_card ← equipo_vista.json.hitos[] { fecha, titulo }
- decision_chip ← equipo_vista.json.decisiones[] { fecha, asunto }
- entrega_card ← equipo_vista.json.entregables[] { id, titulo }
- evidencia_clip ← equipo_vista.json.evidencias[] { id, tipo, url }

Notas de estilo: var(--token) según TOKENS_UI.md; H1/H2/Body/Caption según estilos.md; accesibilidad AA.
