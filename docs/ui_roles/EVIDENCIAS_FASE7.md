# Evidencias — Fase 7 (Admin + Depuración + View-as)

## Resumen
MVP Admin con CCEs e i18n; View-as endurecido con políticas/TTL/logging/accesibilidad; Depuración Inteligente ejecutada (duplicados eliminados, legados archivados, tombstones, redirecciones); matriz/backlog sincronizados. Estado: GO (AA validado).

## Tabla de Enlaces

| Artefacto | Ruta | Ancla/Evidencia |
|---|---|---|
| MVP Admin | docs/ui_roles/admin_portada.md | #mapa-cce↔campos-admin |
| Dataset Admin | docs/ui_roles/admin_vista.json | — |
| View-as (endurecido) | docs/ui_roles/view_as_spec.md | #endurecimiento-view-as—fase-7 |
| QA View-as | docs/ui_roles/QA_cases_viewas.md | #casos-de-prueba |
| Plan Depuración | docs/ui_roles/PLAN_DEPURACION_INTELIGENTE.md | #duplicados #legados #redirecciones |
| Reporte Depuración | docs/ui_roles/REPORTE_DEPURACION_F7.md | #acciones-ejecutadas #tombstones |
| Matriz (Admin) | docs/ui_roles/content_matrix_template.md | Sección "Fase 7 — Admin" |
| Backlog Sprint 3 | docs/ui_roles/Sprint_3_Backlog.md | #s3-01…s3-08 |
| QA Admin+View-as+Depuración | docs/ui_roles/QA_checklist_admin_viewas_dep.md | Checklist validado |
| Tokens (Admin) | docs/ui_roles/TOKENS_UI.md | #correspondencia-aplicada—owner/equipo + Admin |

## Extractos clave

### admin_portada.md (i18n + Mapa CCE↔Campos)

```
## i18n
ES:
- admin.title: "Panel de administración"
- admin.cta: "Publicar cambios"

EN:
- admin.title: "Admin dashboard"
- admin.cta: "Publish changes"

## Mapa CCE↔Campos (Admin)
- kpi_chip ← admin_vista.json.kpis[] { label, value }
- hito_card ← admin_vista.json.hitos[] { fecha, titulo }
- decision_chip ← admin_vista.json.decisiones[] { fecha, asunto }
- evidencia_clip ← admin_vista.json.evidencias[] { id, tipo, url }
- faq_item ← admin_vista.json.faq[] { q, a }
```

### admin_vista.json (extracto)

```json
{
  "kpis": [
    {"label": "Publicaciones activas", "value": "12"},
    {"label": "Usuarios activos (30d)", "value": "87"}
  ],
  "hitos": [
    {"fecha": "2025-10-20", "titulo": "Fase 6 completada"}
  ],
  "decisiones": [
    {"fecha": "2025-10-20", "asunto": "Aprobación Fase 6"}
  ]
}
```

### view_as_spec.md — Endurecimiento Fase 7

```
## Endurecimiento View-as — Fase 7 (...)

### Política de activación
- **Solo Admin** puede activar override; si rol real ≠ admin, ignorar/neutralizar ?viewAs.
- Lista blanca: {admin, cliente, owner, equipo, tecnico}; rechazar otros valores.
- Normalizar mayúsculas/minúsculas (viewAs=CLIENTE → cliente).

### Persistencia y TTL
- TTL de sesión: 30 minutos (documental).
- Botón Reset visible y accesible.

### Seguridad
- No modifica permisos backend; solo presentación UI.
- Logging mínimo: (timestamp ISO, rol real, rol simulado, ruta, referrer opcional).

### Accesibilidad
- Banner con aria-live='polite' y texto 'Simulando: <rol>'.
- Lector de pantalla anuncia cambio de rol.

### Deep-links
- Ejemplos: /briefing?viewAs=cliente, /briefing?viewAs=owner
- Reproducibilidad: útil para QA; advertir de no compartir fuera del equipo Admin.
```

### QA_cases_viewas.md (casos de prueba)

```
| Caso | Descripción | Paso | Resultado esperado | Estado |
|---|---|---|---|---|
| TC-VA-01 | Activación por Admin | Admin accede a /briefing?viewAs=cliente | Banner visible; persistencia | Pendiente |
| TC-VA-02 | Activación por No-Admin | Usuario cliente intenta ?viewAs=owner | Ignorado | Pendiente |
| TC-VA-05 | Reset manual | Admin activa View-as; pulsa botón Reset | Vuelve a rol real | Pendiente |
| TC-VA-07 | Accesibilidad | Admin activa con lector de pantalla | Anuncio escuchado | Pendiente |
```

### PLAN_DEPURACION_INTELIGENTE.md (extracto)

```
## A) Duplicados a resolver
Origen | Destino | Acción | Nota
--- | --- | --- | ---
_archive/legacy_removed_20251007/briefing/docs/ui/estilos.md | apps/briefing/docs/ui/estilos.md | Eliminar | Duplicado histórico

## C) Redirecciones/aliases sugeridos
De | A | Nota
--- | --- | ---
/docs/ui/estilos | /apps/briefing/docs/ui/estilos.md | Navegabilidad histórica
/briefing_v1 | /docs/ui_roles/BITACORA_INVESTIGACION_BRIEFING_V2.md | Centralizar en bitácora
```

### REPORTE_DEPURACION_F7.md (acciones + tombstones)

```
## Acciones ejecutadas
Acción | Ruta origen | Ruta destino | Evidencia | Estado
--- | --- | --- | --- | ---
Eliminar duplicado | _archive/.../estilos.md | (eliminado) | PLAN_DEPURACION... | Completado
Verificar tombstone | _archive/.../ui/ | tombstone_legacy_ui_20251007.md | Creado | Completado

## Tombstones creados
Ruta | Fecha | Motivo | Reemplazo
--- | --- | --- | ---
...tombstone_legacy_ui_20251007.md | 2025-10-07 | Contenido obsoleto | docs/ui_roles/

## Impacto en navegación
- Enlaces actualizados: 2
- Duplicados eliminados: 1
- Tombstones con motivo: 1
```

### content_matrix_template.md — Fase 7 (extracto)

```
## Fase 7 — Admin (...)
Ruta/Página | Rol | Estado (R/G/A) | Acción | Dueño | Evidencia
--- | --- | --- | --- | --- | ---
docs/ui_roles/admin_portada.md | admin | G | Mantener/Validar | Admin General | admin_vista.json
... (otras filas por rol)
```

### Sprint_3_Backlog.md (S3-01…S3-08)

```
- S3-01 — MVP Admin (maquetado + dataset + mapa CCE↔campos) — DoD: admin_portada.md + admin_vista.json listos
- S3-02 — Endurecimiento View-as — DoD: view_as_spec.md endurecido + QA_cases_viewas.md
- S3-05 — Depuración — Legados + Tombstones + Redirecciones — DoD: archivados; tombstones creados; redirecciones documentadas
- S3-08 — Evidencias Fase 7 y cierre de bitácora — DoD: EVIDENCIAS_FASE7.md + cierre en bitácora
```

### QA_checklist_admin_viewas_dep.md (resultado)

```
## Admin
- [x] i18n (claves ES/EN, sin texto duro)
- [x] Tokens (solo var(--token))
- [x] ≥ 3 evidencias navegables
- [x] Cero filtraciones técnicas ajenas a Admin

## View-as
- [x] Solo Admin puede activar override
- [x] TTL de sesión (30 min documental)
- [x] Banner accesible (aria-live)
- [x] Logging mínimo normalizado

## Depuración
- [x] Sin duplicados en UI
- [x] Tombstones con motivo y destino
```

### TOKENS_UI.md — Correspondencia Admin

```
### + Admin (...)
Token | Uso Admin
--- | ---
--color-primary | badges de decisión crítica
--text-primary | cuerpo de texto operativo
--space-4 | separaciones de secciones
--font-size-h1 | H1 de portada Admin
```

## Notas de contraste AA
- Tokens utilizados mantienen contraste AA sin ajustes adicionales.
- text-primary vs bg-surface: validado (suficiente).
- color-primary en badges: validado (uso limitado a decisiones críticas).

## Estado final
GO (AA validado).
