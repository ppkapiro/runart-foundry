# Vista Admin — Portada

Propósito: Panel operativo para Admin con acceso a KPIs de operación, publicaciones, decisiones y evidencias del sistema.

## KPIs de operación
- CCE: kpi_chip
```json
{{ ./docs/ui_roles/admin_vista.json:kpis }}
```

## Hitos de publicación
- CCE: hito_card
```json
{{ ./docs/ui_roles/admin_vista.json:hitos }}
```

## Decisiones administrativas
- CCE: decision_chip
```json
{{ ./docs/ui_roles/admin_vista.json:decisiones }}
```

## Últimas evidencias
- CCE: evidencia_clip
```json
{{ ./docs/ui_roles/admin_vista.json:evidencias }}
```

## FAQ operativa
- CCE: faq_item
```json
{{ ./docs/ui_roles/admin_vista.json:faq }}
```

---

## i18n
ES:
- admin.title: "Panel de administración"
- admin.cta: "Publicar cambios"

EN:
- admin.title: "Admin dashboard"
- admin.cta: "Publish changes"

---

## Mapa CCE↔Campos (Admin)
- kpi_chip ← admin_vista.json.kpis[] { label, value }
- hito_card ← admin_vista.json.hitos[] { fecha, titulo }
- decision_chip ← admin_vista.json.decisiones[] { fecha, asunto }
- evidencia_clip ← admin_vista.json.evidencias[] { id, tipo, url }
- faq_item ← admin_vista.json.faq[] { q, a }

Notas de estilo: var(--token) según TOKENS_UI.md; H1/H2/Body/Caption según estilos.md; accesibilidad AA; cero contenido técnico ajeno al rol Admin.
