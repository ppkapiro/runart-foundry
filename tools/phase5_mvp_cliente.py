#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Fase 5: MVP Vista Cliente + View-as (documental operativa) — ejecución end-to-end sin salida externa.
- Crea/actualiza wireframe y página de Vista Cliente con CCEs e i18n.
- Actualiza view_as_spec y crea checklist operativa.
- Integra i18n/tokens en la página cliente_portada.md.
- Sincroniza content_matrix y Sprint_1_Backlog con nuevas historias.
- Crea QA_checklist_cliente.md.
- Actualiza la bitácora maestra con toda la ejecución y criterios de aceptación.
"""
from __future__ import annotations
import os
from datetime import datetime
from typing import List

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
UI_DIR = os.path.join(ROOT, "docs", "ui_roles")
WIRE_DIR = os.path.join(UI_DIR, "wireframes")
DATOS_DIR = os.path.join(UI_DIR, "datos_demo")
BITACORA = os.path.join(UI_DIR, "BITACORA_INVESTIGACION_BRIEFING_V2.md")
TOKENS = os.path.join(UI_DIR, "TOKENS_UI.md")
MATRIX = os.path.join(UI_DIR, "content_matrix_template.md")
BACKLOG = os.path.join(UI_DIR, "Sprint_1_Backlog.md")
VIEW_SPEC = os.path.join(UI_DIR, "view_as_spec.md")
VIEW_CHECK = os.path.join(UI_DIR, "view_as_checklist.md")
QA_CHECK = os.path.join(UI_DIR, "QA_checklist_cliente.md")
WIREFRAME = os.path.join(WIRE_DIR, "cliente_portada.md")
CLIENTE_PAGE = os.path.join(ROOT, "apps", "briefing", "docs", "ui", "cliente_portada.md")
DATOS_JSON = os.path.join(DATOS_DIR, "cliente_vista.json")


def write_text(path: str, content: str) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)


def append_text(path: str, content: str) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "a", encoding="utf-8") as f:
        f.write(content)


def ensure_wireframe(now: str) -> None:
    content = f"""# Wireframe — Vista Cliente (Portada) — {now}

Zonas y CCEs:
- Hero: estado global + 3 KPIs (kpi_chip)
- Timeline (-7/+14): hitos (hito_card)
- Decisiones: chips (decision_chip)
- Entregables: cards (entrega_card)
- Evidencias: grid 2×3 (evidencia_clip)
- FAQ: 3 ítems (faq_item)
- CTA: “Tu próximo paso”

Micro-copy (i18n, claves sugeridas):
- es.hero.title = "Resumen del estado"
- en.hero.title = "Status summary"
- es.cta.next = "Tu próximo paso"
- en.cta.next = "Your next step"

Notas:
- Referencias a glosario técnico para evitar jerga en vista Cliente.
- Tokens de color/espaciado tipografía según TOKENS_UI.md.
"""
    write_text(WIREFRAME, content)


def ensure_datos_demo(now: str) -> None:
    data = """
{
  "kpis": [
    {"label": "Progreso", "value": "72%"},
    {"label": "Hitos", "value": "14/20"},
    {"label": "Riesgos", "value": "Bajo"}
  ],
  "hitos": [
    {"fecha": "2025-10-15", "titulo": "Molde listo"},
    {"fecha": "2025-10-20", "titulo": "Colada completada"}
  ],
  "decisiones": [
    {"fecha": "2025-10-18", "asunto": "Aprobar patinado verde"}
  ],
  "entregables": [
    {"id": "E-101", "titulo": "Ficha técnica pieza A"},
    {"id": "E-102", "titulo": "Informe de control dimensional"}
  ],
  "evidencias": [
    {"id": "EV-1", "tipo": "imagen", "url": "./evidencias/piezaA_1.jpg"},
    {"id": "EV-2", "tipo": "video", "url": "https://example.com/demo.mp4"}
  ],
  "faq": [
    {"q": "¿Qué es la pátina?", "a": "Acabado químico de color en superficie."},
    {"q": "¿Cuándo recibiré el próximo avance?", "a": "El día 25, con fotos y notas."}
  ]
}
"""
    write_text(DATOS_JSON, data.strip() + "\n")


def ensure_cliente_page(now: str) -> None:
    content = """# Vista Cliente — Portada

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
"""
    write_text(CLIENTE_PAGE, content)


def update_view_as_spec(now: str) -> None:
    extra = f"""

## Estado: implementable en docs UI ({now})
- Soporte de parámetro ?viewAs=cliente en navegación/documentos.
- Banner “Simulando: Cliente” con i18n y nota de accesibilidad.
- Reglas: solo Admin puede activar; no modifica permisos backend.
"""
    append_text(VIEW_SPEC, extra)


def ensure_view_as_checklist(now: str) -> None:
    content = f"""# View-as (Cliente) — Checklist ({now})
- [ ] Inyección de selector (documental/operativa)
- [ ] Banner y persistencia por pestaña
- [ ] Deep-link con ?viewAs=cliente
- [ ] Evidencias: capturas y enlaces internos
"""
    write_text(VIEW_CHECK, content)


def update_tokens_correspondence(now: str) -> None:
    lines: List[str] = []
    lines.append(f"\n## Correspondencia aplicada — Vista Cliente ({now})\n")
    lines.append("Token | Uso")
    lines.append("--- | ---")
    lines.append("--color-primary | títulos y CTA")
    lines.append("--text-primary | cuerpo de texto")
    lines.append("--space-4 | separaciones principales")
    lines.append("--font-size-h1 | H1 de portada")
    append_text(TOKENS, "\n".join(lines) + "\n")


def update_matrix(now: str) -> None:
    lines: List[str] = []
    lines.append("")
    lines.append(f"## Fase 5 — Vista Cliente ({now})")
    lines.append("")
    lines.append("Ruta/Página | Rol | Estado (R/G/A) | Acción | Dueño | Evidencia")
    lines.append("--- | --- | --- | --- | --- | ---")
    page = "apps/briefing/docs/ui/cliente_portada.md"
    lines.append(f"{page} | cliente | G | Mantener/Validar | PM | docs/ui_roles/datos_demo/cliente_vista.json")
    lines.append(f"{page} | admin | G | Documentar/Operar | Admin General | docs/ui_roles/wireframes/cliente_portada.md")
    lines.append(f"{page} | owner_interno | R | No aplicar en Vista Cliente | Owner | -")
    lines.append(f"{page} | equipo | R | No aplicar en Vista Cliente | UX | -")
    lines.append(f"{page} | tecnico | R | No aplicar en Vista Cliente | Tech Lead | -")
    append_text(MATRIX, "\n".join(lines) + "\n")


def update_backlog(now: str) -> None:
    lines: List[str] = []
    lines.append(f"\n## Historias nuevas — Fase 5 ({now})")
    lines.append("- S1-09 — Maquetar Vista Cliente con CCEs (MVP)")
    lines.append("- S1-10 — Habilitar View-as Cliente (documental/operativa)")
    lines.append("- S1-11 — QA “abuelita” (< 10 s) con 2–3 usuarios internos")
    lines.append("- S1-12 — Evidencias mínimas enlazadas (≥ 3 casos)")
    lines.append("")
    lines.append("## Dependencias")
    lines.append("- Prerrequisitos: S1-07, S1-08")
    lines.append("- Estado: marcar 'Listas para QA' cuando cliente_portada.md esté en G")
    append_text(BACKLOG, "\n".join(lines) + "\n")


def ensure_qa_checklist(now: str) -> None:
    content = f"""# QA — Vista Cliente (MVP) — {now}
- [ ] Comprensión < 10 s (✅/❌)
- [ ] 0 elementos técnicos visibles
- [ ] 1 clic hacia evidencias desde Hitos/Entregables
- [ ] i18n correcto (ES/EN)
- [ ] Contraste AA y tamaño mínimo
Observaciones:
- 
"""
    write_text(QA_CHECK, content)


def append_bitacora(now: str) -> None:
    if not os.path.isfile(BITACORA):
        write_text(BITACORA, f"# 🧭 Bitácora Maestra de Investigación — RunArt Briefing v2\n**Inicio:** {now}\n---\n")
    lines: List[str] = []
    lines.append("")
    lines.append(f"### 🔄 Actualización — {now}")
    lines.append("")
    lines.append("- **Resumen Ejecutivo:** MVP Vista Cliente maquetado con CCEs; View-as habilitado (documental); i18n + tokens aplicados.")
    lines.append("- **Cambios Clave:** cliente_portada.md creada, datos_demo enlazados, tokens e i18n integrados, accesibilidad considerada.")
    lines.append("- **Sincronización:** content_matrix_template.md y Sprint_1_Backlog.md actualizados; nuevas historias (S1-09…S1-12).")
    lines.append("- **QA:** checklist creado; estado inicial pendiente de validación.")
    lines.append("")
    lines.append("- **Criterios de Aceptación (MVP Cliente):**")
    lines.append("  1) Comprensión < 10 s.")
    lines.append("  2) 0 contenido técnico en Vista Cliente.")
    lines.append("  3) Evidencias navegables (≥ 3).")
    lines.append("  4) i18n aplicado y consistente.")
    lines.append("  5) Tokens y contrastes AA en secciones críticas.")
    lines.append("")
    lines.append("- **GO/NO-GO:** GO (pendiente de QA de contraste AA).")
    lines.append("- **Próximos Pasos:** Preparar Sprint 2 (Owner/Equipo) reutilizando CCEs.")
    lines.append("")
    lines.append("---")
    lines.append("✅ Fase 5 completada — MVP Vista Cliente maquetado e integrado con View-as, matriz y backlog.")
    lines.append("---")
    append_text(BITACORA, "\n".join(lines) + "\n")


def main() -> int:
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    ensure_wireframe(now)
    ensure_datos_demo(now)
    ensure_cliente_page(now)
    update_view_as_spec(now)
    ensure_view_as_checklist(now)
    update_tokens_correspondence(now)
    update_matrix(now)
    update_backlog(now)
    ensure_qa_checklist(now)
    append_bitacora(now)
    return 0


if __name__ == "__main__":
    import sys
    try:
        sys.exit(main())
    except Exception:
        sys.exit(1)
