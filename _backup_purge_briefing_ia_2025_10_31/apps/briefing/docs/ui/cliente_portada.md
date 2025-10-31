# Vista Cliente — Portada

Propósito: Presentar el estado y próximos pasos en lenguaje de negocio, sin tecnicismos.

## Hero — KPIs
- CCE: kpi_chip
```json
<!-- datos_demo -->
{{ ./docs/ui_roles/datos_demo/cliente_vista.json:kpis }}
```

## Timeline (−7 / +14)
- CCE: hito_card
```json
{{ ./docs/ui_roles/datos_demo/cliente_vista.json:hitos }}
```

## Decisiones
- CCE: decision_chip
```json
{{ ./docs/ui_roles/datos_demo/cliente_vista.json:decisiones }}
```

## Entregables
- CCE: entrega_card
```json
{{ ./docs/ui_roles/datos_demo/cliente_vista.json:entregables }}
```

## Evidencias
- CCE: evidencia_clip
```json
{{ ./docs/ui_roles/datos_demo/cliente_vista.json:evidencias }}
```

## FAQ
- CCE: faq_item
```json
{{ ./docs/ui_roles/datos_demo/cliente_vista.json:faq }}
```

---

## i18n
ES:
- hero.title: "Resumen del estado"
- cta.next: "Tu próximo paso"

EN:
- hero.title: "Status summary"
- cta.next: "Your next step"

---

Notas de estilo:
- Colores via var(--token) definidos en docs/ui_roles/TOKENS_UI.md
- Tipografía H1/H2/Body/Caption según apps/briefing/docs/ui/estilos.md
- Accesibilidad AA y tamaño base >= 14px (equivalente rem)
