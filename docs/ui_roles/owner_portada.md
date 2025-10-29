# Vista Owner — Portada

Propósito: Resumen ejecutivo de avance, decisiones y evidencias clave para el Owner.

## Métricas clave
- CCE: kpi_chip
```json
{{ ./docs/ui_roles/owner_vista.json:kpis }}
```

## Hitos relevantes
- CCE: hito_card
```json
{{ ./docs/ui_roles/owner_vista.json:hitos }}
```

## Evidencias destacadas
- CCE: evidencia_clip
```json
{{ ./docs/ui_roles/owner_vista.json:evidencias }}
```

## FAQ
- CCE: faq_item
```json
{{ ./docs/ui_roles/owner_vista.json:faq }}
```

---

## i18n
ES:
- owner.title: "Resumen ejecutivo"
- owner.cta: "Validar próximos pasos"

EN:
- owner.title: "Executive summary"
- owner.cta: "Validate next steps"

---

## Mapa CCE↔Campos
- kpi_chip ← owner_vista.json.kpis[] { label, value }
- hito_card ← owner_vista.json.hitos[] { fecha, titulo }
- evidencia_clip ← owner_vista.json.evidencias[] { id, tipo, url }
- faq_item ← owner_vista.json.faq[] { q, a }

Notas de estilo: var(--token) según TOKENS_UI.md; H1/H2/Body/Caption según estilos.md; accesibilidad AA.
