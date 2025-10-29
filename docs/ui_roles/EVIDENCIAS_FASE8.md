# Evidencias — Fase 8 (Técnico + Glosario 2.0 + Gobernanza de Tokens)

## Resumen
MVP Técnico con CCEs e i18n; Glosario Cliente 2.0 con lenguaje claro, ejemplos y enlaces; Gobernanza de Tokens con normativa, auditoría y AA validado; matriz/backlog sincronizados. Estado: GO (AA validado al 100%).

## Tabla de Enlaces

| Artefacto | Ruta | Ancla/Evidencia |
|---|---|---|
| MVP Técnico | docs/ui_roles/tecnico_portada.md | #mapa-cce↔campos-tecnico |
| Dataset Técnico | docs/ui_roles/tecnico_vista.json | — |
| Glosario Cliente 2.0 | docs/ui_roles/glosario_cliente_2_0.md | #terminos #no-confundir-con #donde-lo-veras |
| Gobernanza de Tokens | docs/ui_roles/GOBERNANZA_TOKENS.md | #naming #escalas #excepciones #aa |
| Auditoría de Tokens | docs/ui_roles/REPORTE_AUDITORIA_TOKENS_F8.md | #hallazgos-criticos |
| Tokens (Correspondencia) | docs/ui_roles/TOKENS_UI.md | #correspondencia-aplicada—tecnico-+-glosario-2-0 |
| View-as Técnico | docs/ui_roles/view_as_spec.md | #escenarios-tecnico #ttl #logging #deep-links |
| Matriz (Técnico/Glosario) | docs/ui_roles/content_matrix_template.md | Sección "Fase 8 — Técnico + Glosario" |
| Backlog Sprint 4 | docs/ui_roles/Sprint_4_Backlog.md | #s4-01…s4-10 |
| QA Técnico+Glosario+Tokens | docs/ui_roles/QA_checklist_tecnico_glosario_tokens.md | Checklist validado |

## Extractos clave

### tecnico_portada.md (i18n + Mapa CCE↔Campos)

```
## i18n
ES:
- tecnico.title: "Panel operacional"
- tecnico.cta: "Ver logs completos"

EN:
- tecnico.title: "Operations dashboard"
- tecnico.cta: "View full logs"

## Mapa CCE↔Campos (Técnico)
- hito_card ← tecnico_vista.json.incidencias[] { fecha, titulo, estado }
- evidencia_clip ← tecnico_vista.json.logs[] { id, tipo, url }
- ficha_tecnica_mini ← tecnico_vista.json.parametros[] { clave, valor }
- decision_chip ← tecnico_vista.json.cambios[] { fecha, asunto }

Notas de estilo: var(--token) según TOKENS_UI.md; H1/H2/Body/Caption; accesibilidad AA; cero contenido de negocio/cliente; enfoque operacional puro.
```

### tecnico_vista.json (extracto)

```json
{
  "incidencias": [
    {"fecha": "2025-10-20", "titulo": "Timeout en API /briefing", "estado": "Resuelta"}
  ],
  "logs": [
    {"id": "LOG-T-1", "tipo": "txt", "url": "./logs/staging_20251021.log"}
  ],
  "parametros": [
    {"clave": "DB_MAX_CONNECTIONS", "valor": "100"}
  ]
}
```

### glosario_cliente_2_0.md (estructura por término)

```
## Término: Cáscara cerámica

**Definición:** Revestimiento refractario que forma el molde alrededor de la cera (lenguaje cliente: "la capa dura que rodea el modelo").

**No confundir con:** El molde de arena (proceso diferente; cáscara es para cera perdida).

**Ejemplo:** En la ficha de tu proyecto verás "cáscara aplicada" cuando empiece el moldeo.

**i18n:**
- ES: cascara_ceramica
- EN: ceramic_shell

**Dónde lo verás:** cliente_portada.md (ficha de hito), owner_portada.md (métricas).
```

### GOBERNANZA_TOKENS.md (políticas)

```
## 1. Naming y Convenciones
### Prefijos por categoría
- `--color-*` : colores (primarios, secundarios, texto, fondo).
- `--font-*` : tipografía (base, tamaños, weights).
- `--space-*` : espaciado (padding, margin, gaps).
- `--shadow-*` : sombras (sm, md, lg).

## 2. Escalas y Límites
- **Tipografía y espaciado:** usar `rem` (no `px` sueltos).
- **Colores:** solo valores desde tokens; prohibir hex directo en nuevas vistas.

## 4. Excepciones Controladas
- **Cómo declararlas:** comentario inline con `/* EXCEPCIÓN: motivo + fecha + autor */`.
- **Vigencia:** máximo 2 sprints; revisión obligatoria en QA.

## 5. Verificación AA
- Contraste mínimo: 4.5:1 para texto normal; 3:1 para texto grande/botones.
- Revisión en cada fase: QA debe validar pares críticos text-primary/bg-surface, color-primary/white.
```

### REPORTE_AUDITORIA_TOKENS_F8.md (hallazgos)

```
## Archivos auditados
Archivo | Token detectado | Categoría | Conformidad AA | Observación
--- | --- | --- | --- | ---
cliente_portada.md | var(--color-primary) | color | ✓ | Contraste validado
tecnico_portada.md | var(--text-primary) | color | ✓ | Contraste suficiente

## Hallazgos críticos
- **Ninguno:** todos los archivos usan var(--token); sin hex sueltos detectados.
- **Excepciones:** 0 excepciones declaradas en esta fase.

## Pares críticos AA (verificados)
Par | Contraste | Estado | Nota
--- | --- | --- | ---
text-primary vs bg-surface | 7.2:1 | ✓ | Muy por encima de 4.5:1
color-primary vs white (botones) | 4.8:1 | ✓ | Uso limitado a CTA

## Estado
✅ Auditoría completada — 0 pendientes críticos; conformidad AA al 100%.
```

### TOKENS_UI.md — Correspondencia Técnico + Glosario 2.0

```
## Correspondencia aplicada — Técnico + Glosario 2.0 (...)
Token | Uso Técnico/Glosario
--- | ---
--color-primary | badges de cambios aprobados
--text-primary | cuerpo de logs y parámetros
--space-4 | separaciones de secciones técnicas
--font-size-h1 | H1 de portada Técnico

### Notas de contraste AA
- Auditoría F8: todos los tokens cumplen AA; sin ajustes necesarios.
```

### view_as_spec.md — Escenarios Técnico

```
## Escenarios View-as Técnico (...)
- ?viewAs=tecnico — Banner 'Simulando: Técnico', persistencia por sesión, botón Reset, lector de pantalla.
- Deep-links ejemplo: /briefing?viewAs=tecnico
- Seguridad: solo Admin puede activar override; no altera permisos backend.
```

### content_matrix_template.md — Fase 8 (extracto)

```
## Fase 8 — Técnico + Glosario (...)
Ruta/Página | Rol | Estado (R/G/A) | Acción | Dueño | Evidencia
--- | --- | --- | --- | --- | ---
docs/ui_roles/tecnico_portada.md | tecnico | G | Mantener/Validar | Tech Lead | tecnico_vista.json
... (otras filas por rol)

### Glosario 2.0 — Aplicabilidad por Rol
Término | Cliente | Owner | Equipo | Admin | Técnico | Vista donde aparece
--- | --- | --- | --- | --- | --- | ---
Cáscara cerámica | G | G | A | G | R | cliente_portada, owner_portada
Pátina | G | G | A | G | R | cliente_portada, equipo_portada
```

### Sprint_4_Backlog.md (S4-01…S4-10)

```
- S4-01 — MVP Técnico (maquetado + dataset + mapa CCE↔campos) — DoD: tecnico_portada.md + tecnico_vista.json listos
- S4-02 — Glosario Cliente 2.0 (estructura, i18n, enlaces cruzados) — DoD: glosario_cliente_2_0.md completo
- S4-03 — Gobernanza de Tokens (normativa completa) — DoD: GOBERNANZA_TOKENS.md aprobado
- S4-04 — Auditoría de Tokens y reporte F8 — DoD: REPORTE_AUDITORIA_TOKENS_F8.md sin críticos
- S4-08 — QA Técnico + Glosario + Tokens — DoD: QA_checklist_tecnico_glosario_tokens.md completo
```

### QA_checklist_tecnico_glosario_tokens.md (resultado)

```
## Técnico
- [x] i18n (claves ES/EN, sin texto duro)
- [x] Tokens (solo var(--token))
- [x] ≥ 3 evidencias navegables
- [x] Cero fuga hacia negocio/cliente

## Glosario 2.0
- [x] "No confundir con…" en cada término
- [x] i18n ES/EN por término
- [x] Enlaces a vistas donde aparece

## Gobernanza de Tokens
- [x] Naming y escala definidos
- [x] Auditoría sin pendientes críticos
- [x] AA validado (contraste ≥ 4.5:1 texto, ≥ 3:1 botones)
```

## Notas de contraste AA
- Auditoría F8 validó todos los pares críticos sin necesidad de ajustes.
- text-primary vs bg-surface: 7.2:1 (muy por encima del mínimo 4.5:1).
- color-primary vs white (botones): 4.8:1 (cumple estándar 4.5:1).
- Sin uso de colores hex sueltos; 100% conformidad con var(--token).

## Estado final
GO (AA validado al 100%).
