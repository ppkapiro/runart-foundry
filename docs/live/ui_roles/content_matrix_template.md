---
status: active
owner: reinaldo.capiro
updated: 2025-10-23
audience: internal
tags: [briefing, runart, ui]
---

# Content Matrix Template

Tabla de seguimiento por página/rol.

Ruta/Página | Rol | Estado (R/G/A) | Acción | Dueño | Evidencia
--- | --- | --- | --- | --- | ---
/path/ejemplo | Cliente | G | Mantener | PM | enlace
/path/ejemplo | Owner | A | Re-escribir micro-copy | UX | enlace
/path/ejemplo | Técnico | R | Mover a vista técnica | Tech Lead | enlace

Leyenda:
- Verde (G): mostrar tal cual
- Ámbar (A): re-escribir/micro-copy
- Rojo (R): mover a vista técnica

## Auto-populación — 2025-10-21 17:15:12

Ruta/Página | Rol | Estado (R/G/A) | Acción | Dueño | Evidencia
--- | --- | --- | --- | --- | ---
apps/briefing/docs/ui/estilos.md | cliente | A | Re-escribir micro-copy | PM | 
apps/briefing/docs/ui/estilos.md | owner_interno | A | Re-escribir micro-copy | Owner | 
apps/briefing/docs/ui/estilos.md | equipo | A | Re-escribir micro-copy | UX | 
apps/briefing/docs/ui/estilos.md | tecnico | G | Mantener | Tech Lead | 
apps/briefing/docs/ui/estilos.md | admin | G | Mantener | Admin General | 

## Auto-enriquecimiento — 2025-10-21 17:16:36

Ruta/Página | Rol | CCE(s) | Prioridad | Nota
--- | --- | --- | --- | ---
apps/briefing/docs/ui/estilos.md | cliente | - | P2 | heurística

## Actualización Fase 4 — Acciones y Prioridades (2025-10-21 17:28:03)

Ruta/Página | Rol | Acción | Prioridad | Observación
--- | --- | --- | --- | ---
apps/briefing/docs/ui/estilos.md | cliente | Aplicar correcciones UI | P1 | Correcciones UI aplicadas – Fase 4
apps/briefing/docs/ui/estilos.md | admin | Introducir i18n/jerarquía tipográfica | P0 | Correcciones UI aplicadas – Fase 4

## Fase 5 — Vista Cliente (2025-10-21 17:32:25)

Ruta/Página | Rol | Estado (R/G/A) | Acción | Dueño | Evidencia
--- | --- | --- | --- | --- | ---
apps/briefing/docs/ui/cliente_portada.md | cliente | G | Mantener/Validar | PM | docs/ui_roles/datos_demo/cliente_vista.json
apps/briefing/docs/ui/cliente_portada.md | admin | G | Documentar/Operar | Admin General | docs/ui_roles/wireframes/cliente_portada.md
apps/briefing/docs/ui/cliente_portada.md | owner_interno | R | No aplicar en Vista Cliente | Owner | -
apps/briefing/docs/ui/cliente_portada.md | equipo | R | No aplicar en Vista Cliente | UX | -
apps/briefing/docs/ui/cliente_portada.md | tecnico | R | No aplicar en Vista Cliente | Tech Lead | -

## Fase 6 — Owner/Equipo (2025-10-21 17:42:34)

Ruta/Página | Rol | Estado (R/G/A) | Acción | Dueño | Evidencia
--- | --- | --- | --- | --- | ---
docs/ui_roles/owner_portada.md | owner_interno | G | Mantener/Validar | Owner | docs/ui_roles/owner_vista.json
docs/ui_roles/owner_portada.md | equipo | A | Revisar/operar | UX | docs/ui_roles/owner_vista.json
docs/ui_roles/owner_portada.md | cliente | R | No aplicar | PM | -
docs/ui_roles/owner_portada.md | admin | G | Documentar/Operar | Admin General | docs/ui_roles/owner_portada.md
docs/ui_roles/owner_portada.md | tecnico | R | No aplicar | Tech Lead | -
docs/ui_roles/equipo_portada.md | equipo | G | Mantener/Validar | UX | docs/ui_roles/equipo_vista.json
docs/ui_roles/equipo_portada.md | owner_interno | A | Revisar/operar | Owner | docs/ui_roles/equipo_vista.json
docs/ui_roles/equipo_portada.md | cliente | R | No aplicar | PM | -
docs/ui_roles/equipo_portada.md | admin | G | Documentar/Operar | Admin General | docs/ui_roles/equipo_portada.md
docs/ui_roles/equipo_portada.md | tecnico | R | No aplicar | Tech Lead | -

## Fase 7 — Admin (2025-10-21 17:52:17)

Ruta/Página | Rol | Estado (R/G/A) | Acción | Dueño | Evidencia
--- | --- | --- | --- | --- | ---
docs/ui_roles/admin_portada.md | admin | G | Mantener/Validar | Admin General | docs/ui_roles/admin_vista.json
docs/ui_roles/admin_portada.md | cliente | R | No aplicar | PM | -
docs/ui_roles/admin_portada.md | owner_interno | R | No aplicar | Owner | -
docs/ui_roles/admin_portada.md | equipo | R | No aplicar | UX | -
docs/ui_roles/admin_portada.md | tecnico | R | No aplicar | Tech Lead | -

## Fase 8 — Técnico + Glosario (2025-10-21 18:00:45)

Ruta/Página | Rol | Estado (R/G/A) | Acción | Dueño | Evidencia
--- | --- | --- | --- | --- | ---
docs/ui_roles/tecnico_portada.md | tecnico | G | Mantener/Validar | Tech Lead | docs/ui_roles/tecnico_vista.json
docs/ui_roles/tecnico_portada.md | admin | A | Revisar/operar | Admin General | docs/ui_roles/tecnico_vista.json
docs/ui_roles/tecnico_portada.md | cliente | R | No aplicar | PM | -
docs/ui_roles/tecnico_portada.md | owner_interno | R | No aplicar | Owner | -
docs/ui_roles/tecnico_portada.md | equipo | R | No aplicar | UX | -

### Glosario 2.0 — Aplicabilidad por Rol
Término | Cliente | Owner | Equipo | Admin | Técnico | Vista donde aparece
--- | --- | --- | --- | --- | --- | ---
Cáscara cerámica | G | G | A | G | R | cliente_portada, owner_portada
Pátina | G | G | A | G | R | cliente_portada, equipo_portada
Colada | G | G | G | G | A | owner_portada, admin_portada
Desmoldeo | G | G | G | G | A | cliente_portada, equipo_portada
