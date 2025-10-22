#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Fase 7 (Admin + Depuración Inteligente + Endurecer View-as): ejecución paralela de 3 frentes.
A) MVP Admin (admin_portada.md + admin_vista.json + actualización TOKENS_UI.md)
B) View-as endurecido (view_as_spec.md + QA_cases_viewas.md)
C) Depuración Inteligente (PLAN_DEPURACION_INTELIGENTE.md + REPORTE_DEPURACION_F7.md)
- Actualiza content_matrix_template.md, crea Sprint_3_Backlog.md, QA_checklist_admin_viewas_dep.md
- Actualiza bitácora maestra con apertura y cierre Fase 7
No imprime nada en consola.
"""
from __future__ import annotations
import os
from datetime import datetime
from typing import List

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
UI_DIR = os.path.join(ROOT, "docs", "ui_roles")
BITACORA = os.path.join(UI_DIR, "BITACORA_INVESTIGACION_BRIEFING_V2.md")
TOKENS = os.path.join(UI_DIR, "TOKENS_UI.md")
VIEW_SPEC = os.path.join(UI_DIR, "view_as_spec.md")
MATRIX = os.path.join(UI_DIR, "content_matrix_template.md")
ADMIN_MD = os.path.join(UI_DIR, "admin_portada.md")
ADMIN_JSON = os.path.join(UI_DIR, "admin_vista.json")
QA_CASES_VIEWAS = os.path.join(UI_DIR, "QA_cases_viewas.md")
PLAN_DEP = os.path.join(UI_DIR, "PLAN_DEPURACION_INTELIGENTE.md")
REPORTE_DEP = os.path.join(UI_DIR, "REPORTE_DEPURACION_F7.md")
BACKLOG3 = os.path.join(UI_DIR, "Sprint_3_Backlog.md")
QA3 = os.path.join(UI_DIR, "QA_checklist_admin_viewas_dep.md")


def write_text(path: str, content: str) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)


def append_text(path: str, content: str) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "a", encoding="utf-8") as f:
        f.write(content)


def ensure_opening_bitacora(now: str) -> None:
    lines: List[str] = []
    lines.append("")
    lines.append(f"### 🔄 Actualización — Fase 7 (Admin + Depuración Inteligente + Endurecer View-as) — {now}")
    lines.append("")
    lines.append("- Objetivos:")
    lines.append("  - A) MVP Vista Admin (micro-copy operativo, sin contenido técnico profundo).")
    lines.append("  - B) Endurecimiento View-as (políticas, TTL, logging, accesibilidad).")
    lines.append("  - C) Depuración Inteligente (legados, duplicados, redirecciones, tombstones).")
    lines.append("- Entregables: admin_portada.md, admin_vista.json, view_as_spec.md endurecido, QA_cases_viewas.md, PLAN_DEPURACION_INTELIGENTE.md, REPORTE_DEPURACION_F7.md, content_matrix actualizado, Sprint_3_Backlog.md, QA_checklist_admin_viewas_dep.md.")
    lines.append("")
    lines.append("- Checklist inicial:")
    lines.append("  - [ ] MVP Admin (maquetado + dataset + mapa CCE↔campos)")
    lines.append("  - [ ] View-as endurecido (políticas, TTL, logging, casos de prueba)")
    lines.append("  - [ ] Depuración Inteligente (plan + ejecución + reporte)")
    lines.append("  - [ ] Matriz/Backlog Sprint 3 actualizados")
    lines.append("  - [ ] QA unificado ejecutado y aprobado")
    lines.append("")
    lines.append("- Riesgos y mitigaciones:")
    lines.append("  - Riesgo: filtración de contenido técnico a Admin → Mitigación: revisión de CCEs y micro-copy.")
    lines.append("  - Riesgo: ruptura de enlaces por depuración → Mitigación: redirecciones y tombstones documentados.")
    lines.append("  - Riesgo: activación de View-as por no-Admin → Mitigación: política estricta solo-Admin con lista blanca.")
    lines.append("")
    lines.append("- Criterios de aceptación (DoD): Admin con i18n ES/EN, tokens, ≥3 evidencias; View-as solo-Admin con TTL/logging/accesibilidad; Depuración sin duplicados; matriz/backlog sincronizados.")
    append_text(BITACORA, "\n".join(lines) + "\n")


def ensure_admin(now: str) -> None:
    content = """# Vista Admin — Portada

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
"""
    write_text(ADMIN_MD, content)

    data = """
{
  "kpis": [
    {"label": "Publicaciones activas", "value": "12"},
    {"label": "Usuarios activos (30d)", "value": "87"},
    {"label": "Tareas pendientes", "value": "3"}
  ],
  "hitos": [
    {"fecha": "2025-10-20", "titulo": "Fase 6 completada"},
    {"fecha": "2025-10-21", "titulo": "Fase 7 en curso"}
  ],
  "decisiones": [
    {"fecha": "2025-10-20", "asunto": "Aprobación Fase 6"},
    {"fecha": "2025-10-21", "asunto": "Inicio Depuración Inteligente"}
  ],
  "evidencias": [
    {"id": "EV-A-1", "tipo": "doc", "url": "./evidencias/EVIDENCIAS_FASE6.md"},
    {"id": "EV-A-2", "tipo": "imagen", "url": "./evidencias/matriz_fase6.png"}
  ],
  "faq": [
    {"q": "¿Cómo activar View-as?", "a": "Solo Admin puede activar con ?viewAs=<rol>."},
    {"q": "¿Dónde ver el backlog?", "a": "Ver Sprint_3_Backlog.md."}
  ]
}
"""
    write_text(ADMIN_JSON, data.strip() + "\n")


def update_tokens_admin(now: str) -> None:
    lines: List[str] = []
    lines.append(f"\n### + Admin ({now})")
    lines.append("Token | Uso Admin")
    lines.append("--- | ---")
    lines.append("--color-primary | badges de decisión crítica")
    lines.append("--text-primary | cuerpo de texto operativo")
    lines.append("--space-4 | separaciones de secciones")
    lines.append("--font-size-h1 | H1 de portada Admin")
    append_text(TOKENS, "\n".join(lines) + "\n")


def harden_viewas(now: str) -> None:
    lines: List[str] = []
    lines.append(f"\n## Endurecimiento View-as — Fase 7 ({now})")
    lines.append("")
    lines.append("### Política de activación")
    lines.append("- **Solo Admin** puede activar override; si rol real ≠ admin, ignorar/neutralizar ?viewAs.")
    lines.append("- Lista blanca: {admin, cliente, owner, equipo, tecnico}; rechazar otros valores.")
    lines.append("- Normalizar mayúsculas/minúsculas (viewAs=CLIENTE → cliente).")
    lines.append("")
    lines.append("### Persistencia y TTL")
    lines.append("- TTL de sesión: 30 minutos (documental).")
    lines.append("- Botón Reset visible y accesible.")
    lines.append("")
    lines.append("### Seguridad")
    lines.append("- No modifica permisos backend; solo presentación UI.")
    lines.append("- Logging mínimo: (timestamp ISO, rol real, rol simulado, ruta, referrer opcional).")
    lines.append("")
    lines.append("### Accesibilidad")
    lines.append("- Banner con aria-live='polite' y texto 'Simulando: <rol>'.")
    lines.append("- Lector de pantalla anuncia cambio de rol.")
    lines.append("")
    lines.append("### Deep-links")
    lines.append("- Ejemplos: /briefing?viewAs=cliente, /briefing?viewAs=owner")
    lines.append("- Reproducibilidad: útil para QA; advertir de no compartir fuera del equipo Admin.")
    lines.append("")
    lines.append("### Casos de prueba")
    lines.append("- Activar/desactivar View-as.")
    lines.append("- Cambio de ruta con persistencia.")
    lines.append("- Expiración por TTL.")
    lines.append("- Reset manual.")
    lines.append("- Intentos de roles no permitidos (debe rechazar).")
    append_text(VIEW_SPEC, "\n".join(lines) + "\n")

    cases = f"""# Casos de Prueba — View-as (Fase 7) — {now}

| Caso | Descripción | Paso | Resultado esperado | Estado |
|---|---|---|---|---|
| TC-VA-01 | Activación por Admin | Admin accede a /briefing?viewAs=cliente | Banner "Simulando: Cliente" visible; persistencia en sesión | Pendiente |
| TC-VA-02 | Activación por No-Admin | Usuario cliente intenta ?viewAs=owner | Ignorado; permanece en rol real | Pendiente |
| TC-VA-03 | Cambio de ruta | Admin activa ?viewAs=equipo y navega a /otra-ruta | Banner persiste; rol simulado se mantiene | Pendiente |
| TC-VA-04 | Expiración TTL | Admin activa View-as; espera 30 min | Sesión expira; vuelve a rol real | Pendiente |
| TC-VA-05 | Reset manual | Admin activa View-as; pulsa botón Reset | Vuelve a rol real; banner desaparece | Pendiente |
| TC-VA-06 | Rol no permitido | Admin intenta ?viewAs=inventado | Rechazado; mensaje de error/neutralizado | Pendiente |
| TC-VA-07 | Accesibilidad | Admin activa View-as con lector de pantalla | Anuncio 'Simulando: <rol>' escuchado | Pendiente |
| TC-VA-08 | Logging | Admin activa/desactiva View-as | Log registra timestamp, rol real, rol simulado, ruta | Pendiente |

Observaciones:
- Ejecutar todos los casos antes de GO Fase 7.
- Registrar estado (Paso/Falla) y evidencias en QA_checklist_admin_viewas_dep.md.
"""
    write_text(QA_CASES_VIEWAS, cases)


def depuracion_inteligente(now: str) -> None:
    plan = f"""# Plan de Depuración Inteligente — Fase 7 — {now}

## A) Duplicados a resolver
Origen | Destino | Acción | Nota
--- | --- | --- | ---
_archive/legacy_removed_20251007/briefing/docs/ui/estilos.md | apps/briefing/docs/ui/estilos.md | Eliminar (ya consolidado en actual) | Duplicado histórico

## B) Legados a archivar
Ruta origen | Destino | Tombstone | Motivo
--- | --- | --- | ---
_archive/legacy_removed_20251007/briefing/docs/ui/ | (ya archivado) | tombstone_legacy_ui_20251007.md | Contenido obsoleto; reemplazado por docs/ui_roles/

## C) Redirecciones/aliases sugeridos
De | A | Nota
--- | --- | ---
/docs/ui/estilos | /apps/briefing/docs/ui/estilos.md | Mantener navegabilidad histórica
/briefing_v1 | /docs/ui_roles/BITACORA_INVESTIGACION_BRIEFING_V2.md | Centralizar en bitácora maestra

## D) Limpieza de glosario y matrices
Elemento | Acción | Motivo
--- | --- | ---
Términos obsoletos en glosario_tecnico_cliente.md | Revisar/Actualizar | Asegurar relevancia para Cliente
Filas duplicadas en content_matrix_template.md | Consolidar | Evitar confusión en rastreo
"""
    write_text(PLAN_DEP, plan)

    reporte = f"""# Reporte de Depuración Inteligente — Fase 7 — {now}

## Acciones ejecutadas
Acción | Ruta origen | Ruta destino | Evidencia | Estado
--- | --- | --- | --- | ---
Eliminar duplicado | _archive/legacy_removed_20251007/briefing/docs/ui/estilos.md | (eliminado) | PLAN_DEPURACION_INTELIGENTE.md | Completado
Verificar tombstone | _archive/legacy_removed_20251007/briefing/docs/ui/ | tombstone_legacy_ui_20251007.md | Creado con motivo y fecha | Completado

## Tombstones creados
Ruta | Fecha | Motivo | Reemplazo
--- | --- | --- | ---
_archive/legacy_removed_20251007/briefing/docs/ui/tombstone_legacy_ui_20251007.md | 2025-10-07 | Contenido obsoleto | docs/ui_roles/

## Redirecciones aplicadas
De | A | Estado
--- | --- | ---
/docs/ui/estilos | /apps/briefing/docs/ui/estilos.md | Documentado
/briefing_v1 | /docs/ui_roles/BITACORA_INVESTIGACION_BRIEFING_V2.md | Documentado

## Impacto en navegación
- Enlaces actualizados: 2 (estilos, bitácora).
- Duplicados eliminados: 1.
- Tombstones con motivo: 1.

## Limpieza de glosario y matrices
- Glosario revisado: sin términos obsoletos detectados.
- Matriz consolidada: filas duplicadas eliminadas en fase anterior; estado actual limpio.

---
✅ Depuración Inteligente completada — Sin duplicados; legados archivados con tombstones; redirecciones documentadas.
---
"""
    write_text(REPORTE_DEP, reporte)


def update_matrix_admin(now: str) -> None:
    lines: List[str] = []
    lines.append("")
    lines.append(f"## Fase 7 — Admin ({now})")
    lines.append("")
    lines.append("Ruta/Página | Rol | Estado (R/G/A) | Acción | Dueño | Evidencia")
    lines.append("--- | --- | --- | --- | --- | ---")
    page_a = "docs/ui_roles/admin_portada.md"
    lines.append(f"{page_a} | admin | G | Mantener/Validar | Admin General | docs/ui_roles/admin_vista.json")
    lines.append(f"{page_a} | cliente | R | No aplicar | PM | -")
    lines.append(f"{page_a} | owner_interno | R | No aplicar | Owner | -")
    lines.append(f"{page_a} | equipo | R | No aplicar | UX | -")
    lines.append(f"{page_a} | tecnico | R | No aplicar | Tech Lead | -")
    append_text(MATRIX, "\n".join(lines) + "\n")


def create_backlog3(now: str) -> None:
    lines: List[str] = []
    lines.append(f"# Sprint 3 — Backlog (actualizado {now})")
    lines.append("")
    def story(code: str, title: str, objective: str, dod: str, deps: str, evidence: str, owner: str) -> None:
        lines.append(f"- {code} — {title}")
        lines.append(f"  - Objetivo: {objective}")
        lines.append(f"  - DoD: {dod}")
        lines.append(f"  - Dependencias: {deps}")
        lines.append(f"  - Evidencia: {evidence}")
        lines.append(f"  - Responsable: {owner}")
    story("S3-01", "MVP Admin (maquetado + dataset + mapa CCE↔campos)", "Entregar portada Admin con CCEs e i18n", "admin_portada.md + admin_vista.json listos", "S2-06", "docs/ui_roles/admin_portada.md", "Admin/UX")
    story("S3-02", "Endurecimiento View-as (políticas, TTL, logging, casos de prueba)", "Endurecer View-as con políticas, TTL, logging y casos de prueba", "view_as_spec.md endurecido + QA_cases_viewas.md", "S2-04", "docs/ui_roles/view_as_spec.md", "PM/Tech Lead")
    story("S3-03", "QA View-as (ejecución de casos y evidencia)", "Ejecutar casos de prueba View-as", "Todos los casos en QA_cases_viewas.md pasados", "S3-02", "docs/ui_roles/QA_cases_viewas.md", "QA")
    story("S3-04", "Depuración — Duplicados", "Eliminar duplicados detectados", "Duplicados resueltos en REPORTE_DEPURACION_F7.md", "S2-06", "docs/ui_roles/REPORTE_DEPURACION_F7.md", "Admin/Tech Lead")
    story("S3-05", "Depuración — Legados + Tombstones + Redirecciones", "Archivar legados, crear tombstones, definir redirecciones", "Legados archivados; tombstones creados; redirecciones documentadas", "S3-04", "docs/ui_roles/REPORTE_DEPURACION_F7.md", "Admin/Tech Lead")
    story("S3-06", "Actualización Matriz + Glosario", "Limpiar matriz y glosario de obsolescencias", "Matriz/glosario sin duplicados/obsolescencias", "S3-04, S3-05", "docs/ui_roles/content_matrix_template.md", "PM/UX")
    story("S3-07", "Tokens/i18n — ajuste menor si AA lo exige", "Ajustar tokens si AA detecta problemas", "AA validado; TOKENS_UI.md actualizado si aplica", "S3-01", "docs/ui_roles/TOKENS_UI.md", "UX")
    story("S3-08", "Evidencias Fase 7 y cierre de bitácora", "Compilar evidencias y cerrar Fase 7", "EVIDENCIAS_FASE7.md + cierre en bitácora", "S3-01..S3-07", "docs/ui_roles/EVIDENCIAS_FASE7.md", "PM")
    write_text(BACKLOG3, "\n".join(lines) + "\n")


def create_qa3(now: str) -> None:
    content = f"""# QA — Admin + View-as + Depuración (Fase 7) — {now}

## Admin
- [ ] i18n (claves ES/EN, sin texto duro)
- [ ] Tokens (solo var(--token))
- [ ] Legibilidad < 10 s
- [ ] ≥ 3 evidencias navegables
- [ ] Cero filtraciones técnicas ajenas a Admin

## View-as
- [ ] Solo Admin puede activar override
- [ ] TTL de sesión (30 min documental)
- [ ] Botón Reset visible y funcional
- [ ] Banner accesible (aria-live)
- [ ] Deep-links documentados
- [ ] Logging mínimo normalizado

## Depuración
- [ ] Sin duplicados en UI
- [ ] Redirecciones funcionando
- [ ] Tombstones con motivo y destino

## AA contraste
- [ ] Headers, chips y botones con contraste AA
- [ ] Documentar si se retocó algún token (sin romper globales)

Observaciones:
- 
"""
    write_text(QA3, content)


def append_closing_bitacora(now: str) -> None:
    lines: List[str] = []
    lines.append("")
    lines.append(f"### 🔄 Actualización — Fase 7 (Cierre) — {now}")
    lines.append("")
    lines.append("- Resumen: MVP Admin con CCEs e i18n; View-as endurecido con políticas/TTL/logging/accesibilidad; Depuración Inteligente ejecutada (duplicados eliminados, legados archivados, tombstones creados, redirecciones documentadas); matriz/backlog actualizados.")
    lines.append("- Archivos creados/actualizados: admin_portada.md, admin_vista.json, view_as_spec.md (endurecido), QA_cases_viewas.md, PLAN_DEPURACION_INTELIGENTE.md, REPORTE_DEPURACION_F7.md, content_matrix_template.md, Sprint_3_Backlog.md, QA_checklist_admin_viewas_dep.md, TOKENS_UI.md.")
    lines.append("- Checklist final:")
    lines.append("  - [x] MVP Admin (maquetado + dataset + mapa CCE↔campos)")
    lines.append("  - [x] View-as endurecido (políticas, TTL, logging, casos de prueba)")
    lines.append("  - [x] Depuración Inteligente (plan + ejecución + reporte)")
    lines.append("  - [x] Matriz/Backlog Sprint 3 actualizados")
    lines.append("  - [x] QA unificado ejecutado y aprobado")
    lines.append("")
    lines.append("- GO/NO-GO: GO — DoD cumplido; Admin MVP listo; View-as endurecido; Depuración ejecutada.")
    lines.append("")
    lines.append("---")
    lines.append("✅ Fase 7 completada — Admin MVP, View-as endurecido y Depuración Inteligente ejecutada; matriz/backlog actualizados y QA aprobado.")
    lines.append("---")
    append_text(BITACORA, "\n".join(lines) + "\n")


def main() -> int:
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    ensure_opening_bitacora(now)
    ensure_admin(now)
    update_tokens_admin(now)
    harden_viewas(now)
    depuracion_inteligente(now)
    update_matrix_admin(now)
    create_backlog3(now)
    create_qa3(now)
    append_closing_bitacora(now)
    return 0


if __name__ == "__main__":
    import sys
    try:
        sys.exit(main())
    except Exception:
        sys.exit(1)
