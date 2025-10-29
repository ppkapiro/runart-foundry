# Evidencias — Fase 6 (Owner/Equipo)

Resumen: MVP Owner/Equipo con CCEs e i18n/tokens; View-as documentado; AA validado; matriz y backlog sincronizados.

## Tabla de Enlaces

| Artefacto | Ruta | Evidencia/Ancla |
|---|---|---|
| MVP Owner | docs/ui_roles/owner_portada.md | #mapa-cce↔campos |
| MVP Equipo | docs/ui_roles/equipo_portada.md | #mapa-cce↔campos |
| Dataset Owner | docs/ui_roles/owner_vista.json | — |
| Dataset Equipo | docs/ui_roles/equipo_vista.json | — |
| Tokens (Correspondencia Owner/Equipo) | docs/ui_roles/TOKENS_UI.md | #correspondencia-aplicada—owner/equipo |
| Matriz (Owner/Equipo) | docs/ui_roles/content_matrix_template.md | Sección “Fase 6 — Owner/Equipo” |
| View-as (Owner/Equipo) | docs/ui_roles/view_as_spec.md | #escenarios-owner · #escenarios-equipo |
| Backlog Sprint 2 | docs/ui_roles/Sprint_2_Backlog.md | #historias-s2-01-a-s2-06 |
| QA | docs/ui_roles/QA_checklist_owner_equipo.md | Checklist marcado |

## Extractos clave

### owner_portada.md (i18n + Mapa CCE↔Campos)

```
## i18n
ES:
- owner.title: "Resumen ejecutivo"
- owner.cta: "Validar próximos pasos"

EN:
- owner.title: "Executive summary"
- owner.cta: "Validate next steps"

## Mapa CCE↔Campos
- kpi_chip ← owner_vista.json.kpis[] { label, value }
- hito_card ← owner_vista.json.hitos[] { fecha, titulo }
- evidencia_clip ← owner_vista.json.evidencias[] { id, tipo, url }
- faq_item ← owner_vista.json.faq[] { q, a }
```

### equipo_portada.md (i18n + Mapa CCE↔Campos)

```
## i18n
ES:
- equipo.title: "Seguimiento del Sprint"
- equipo.cta: "Subir evidencia"

EN:
- equipo.title: "Sprint tracking"
- equipo.cta: "Upload evidence"

## Mapa CCE↔Campos
- kpi_chip ← equipo_vista.json.kpis[] { label, value }
- hito_card ← equipo_vista.json.hitos[] { fecha, titulo }
- decision_chip ← equipo_vista.json.decisiones[] { fecha, asunto }
- entrega_card ← equipo_vista.json.entregables[] { id, titulo }
- evidencia_clip ← equipo_vista.json.evidencias[] { id, tipo, url }
```

### owner_vista.json (extracto)

```json
{
  "kpis": [
    {"label": "ROI", "value": "18%"},
    {"label": "Presupuesto", "value": "82%"}
  ],
  "hitos": [
    {"fecha": "2025-10-10", "titulo": "Aprobación de diseño final"}
  ],
  "evidencias": [
    {"id": "EV-O-1", "tipo": "pdf", "url": "./evidencias/contrato.pdf"}
  ]
}
```

### equipo_vista.json (extracto)

```json
{
  "kpis": [
    {"label": "Tareas completadas", "value": "30"},
    {"label": "Bloqueos", "value": "1"}
  ],
  "hitos": [
    {"fecha": "2025-10-19", "titulo": "Integración de componentes"}
  ]
}
```

### TOKENS_UI.md — Correspondencia aplicada — Owner/Equipo + AA

```
## Correspondencia aplicada — Owner/Equipo (...)
Token | Uso
--- | ---
--color-primary | títulos, chips de decisión
--text-primary | cuerpo de texto
--space-4 | separaciones de secciones
--font-size-h1 | H1 de portada (Owner/Equipo)

### Pares críticos AA — Estado
Par | Estado | Nota
--- | --- | ---
text-primary vs bg-surface | validado | contraste suficiente
white vs color-primary (botones) | validado | uso limitado a botones/CTA
```

### content_matrix_template.md — Fase 6 (extracto)

```
## Fase 6 — Owner/Equipo (...)
Ruta/Página | Rol | Estado (R/G/A) | Acción | Dueño | Evidencia
--- | --- | --- | --- | --- | ---
docs/ui_roles/owner_portada.md | owner_interno | G | Mantener/Validar | Owner | docs/ui_roles/owner_vista.json
... (filas owner/equipo)
```

### view_as_spec.md — Escenarios Owner/Equipo

```
## Escenarios View-as Owner/Equipo (...)
- ?viewAs=owner — Banner “Simulando: Owner”, persistencia por sesión, botón Reset, lector de pantalla.
- ?viewAs=equipo — Banner “Simulando: Equipo”, persistencia por sesión, botón Reset, lector de pantalla.
- Deep-links: /briefing?viewAs=owner, /briefing?viewAs=equipo
- Seguridad: no altera permisos backend.
```

### Sprint_2_Backlog.md (S2-01…S2-06)

```
- S2-01 — MVP Owner (maquetado + dataset) — DoD: Owner_portada.md + owner_vista.json listos
- S2-02 — MVP Equipo (maquetado + dataset) — DoD: equipo_portada.md + equipo_vista.json listos
- S2-03 — Contraste AA Owner/Equipo (crítico) — DoD: Tabla AA en TOKENS_UI.md
- S2-04 — View-as Owner/Equipo — DoD: escenarios en view_as_spec.md
- S2-05 — Tokens/i18n aplicados — DoD: Correspondencia aplicada en TOKENS_UI.md
- S2-06 — QA unificado Owner/Equipo — DoD: QA_checklist_owner_equipo.md completo
```

### QA_checklist_owner_equipo.md (resultado)

```
- [x] i18n (claves traducidas, sin texto duro)
- [x] Tokens (solo var(--token))
- [x] Contraste AA (headers, chips, botones)
- [x] Legibilidad < 10 s
- [x] Navegación a ≥ 3 evidencias
```

## Notas de contraste AA
- text-primary vs bg-surface: validado — contraste suficiente.
- white vs color-primary (botones): validado — uso limitado a CTA.

## Estado final
GO (AA validado).
