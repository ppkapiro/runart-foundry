# Vista Técnico — Portada

Propósito: Panel operacional para soporte técnico (incidencias, logs, parámetros críticos, cambios).

## Incidencias y resoluciones
- CCE: hito_card
```json
{{ ./docs/ui_roles/tecnico_vista.json:incidencias }}
```

## Logs y capturas
- CCE: evidencia_clip
```json
{{ ./docs/ui_roles/tecnico_vista.json:logs }}
```

## Parámetros críticos
- CCE: ficha_tecnica_mini
```json
{{ ./docs/ui_roles/tecnico_vista.json:parametros }}
```

## Cambios aprobados
- CCE: decision_chip
```json
{{ ./docs/ui_roles/tecnico_vista.json:cambios }}
```

---

## i18n
ES:
- tecnico.title: "Panel operacional"
- tecnico.cta: "Ver logs completos"

EN:
- tecnico.title: "Operations dashboard"
- tecnico.cta: "View full logs"

---

## Mapa CCE↔Campos (Técnico)
- hito_card ← tecnico_vista.json.incidencias[] { fecha, titulo, estado }
- evidencia_clip ← tecnico_vista.json.logs[] { id, tipo, url }
- ficha_tecnica_mini ← tecnico_vista.json.parametros[] { clave, valor }
- decision_chip ← tecnico_vista.json.cambios[] { fecha, asunto }

Notas de estilo: var(--token) según TOKENS_UI.md; H1/H2/Body/Caption según estilos.md; accesibilidad AA; cero contenido de negocio/cliente; enfoque operacional puro.
