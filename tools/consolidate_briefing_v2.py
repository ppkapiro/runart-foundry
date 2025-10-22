#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Consolidación central Briefing v2:
- Relee docs/ui_roles/*, AUDITORIA_ESTRUCTURA_SISTEMA.md y apps/briefing/docs/ui/.
- Genera anexos en docs/ui_roles/:
  * ANALISIS_ARCHIVOS_UI.md
  * TOKENS_UI_DETECTADOS.md
  * CCE_ANALISIS.md
  * PLAN_BACKLOG_SPRINTS.md
  * PLAN_DEPURACION_INTELIGENTE.md
  * RESUMEN_DECISIONES_Y_PENDIENTES.md
- Actualiza docs/ui_roles/BITACORA_INVESTIGACION_BRIEFING_V2.md con una nueva sección de actualización
  que integra resúmenes, decisiones, checklist y referencias a los anexos.
Reglas: no eliminar contenido, solo anexar; rutas relativas; finalizar con bloque de estado.
"""
from __future__ import annotations
import os
import re
import sys
from datetime import datetime
from typing import Dict, List, Tuple, Set

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
UI_DIR = os.path.join(ROOT, "docs", "ui_roles")
BITACORA = os.path.join(UI_DIR, "BITACORA_INVESTIGACION_BRIEFING_V2.md")
AUDITORIA = os.path.join(ROOT, "AUDITORIA_ESTRUCTURA_SISTEMA.md")
APPS_UI = os.path.join(ROOT, "apps", "briefing", "docs", "ui")

FILES = {
    "plan": os.path.join(UI_DIR, "PLAN_INVESTIGACION_UI_ROLES.md"),
    "inventory": os.path.join(UI_DIR, "ui_inventory.md"),
    "roles": os.path.join(UI_DIR, "roles_matrix_base.yaml"),
    "viewas": os.path.join(UI_DIR, "view_as_spec.md"),
    "cmatrix": os.path.join(UI_DIR, "content_matrix_template.md"),
    "glosario": os.path.join(UI_DIR, "glosario_tecnico_cliente.md"),
    "auditoria": AUDITORIA,
    "estilos": os.path.join(APPS_UI, "estilos.md"),
}

ANNEX = {
    "analysis": os.path.join(UI_DIR, "ANALISIS_ARCHIVOS_UI.md"),
    "tokens": os.path.join(UI_DIR, "TOKENS_UI_DETECTADOS.md"),
    "cce": os.path.join(UI_DIR, "CCE_ANALISIS.md"),
    "backlog": os.path.join(UI_DIR, "PLAN_BACKLOG_SPRINTS.md"),
    "depuracion": os.path.join(UI_DIR, "PLAN_DEPURACION_INTELIGENTE.md"),
    "resumen": os.path.join(UI_DIR, "RESUMEN_DECISIONES_Y_PENDIENTES.md"),
}

COLOR_RE = re.compile(r"#(?:[0-9a-fA-F]{3}){1,2}\b|rgba?\([^\)]*\)|hsla?\([^\)]*\)")
SIZE_RE = re.compile(r"\b\d+(?:\.\d+)?\s*(?:px|rem|em|%)\b")
RADIUS_RE = re.compile(r"\b(?:border-radius|radius)\s*[:=]?\s*\d+(?:\.\d+)?\s*(?:px|rem|em)\b", re.IGNORECASE)
SHADOW_RE = re.compile(r"box-shadow\s*[:=]", re.IGNORECASE)
FONT_RE = re.compile(r"font(-family)?\s*[:=]\s*[^;\n]+", re.IGNORECASE)
VAR_RE = re.compile(r"var\(\s*--?[a-zA-Z0-9_-]+\s*\)|--[a-zA-Z0-9_-]+\s*:")

ROLES_ORDER = ["admin", "cliente", "owner_interno", "equipo", "tecnico"]


def read_text(path: str) -> str:
    if not os.path.isfile(path):
        return "(no encontrado)"
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        return f.read()


def write_text(path: str, content: str) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)


def parse_roles_yaml(text: str) -> Tuple[List[str], Dict[str, List[str]]]:
    roles: List[str] = []
    visibility: Dict[str, List[str]] = {}
    current_section = None
    for line in text.splitlines():
        s = line.strip()
        if s.startswith("- id:") and current_section != "cces":
            val = s.split(":", 1)[1].strip()
            if val and val not in roles:
                roles.append(val)
        if s.startswith("visibility:"):
            current_section = "visibility"
            continue
        if current_section == "visibility" and ":" in s:
            key, arr = s.split(":", 1)
            key = key.strip()
            arr = arr.strip()
            if arr.startswith("[") and arr.endswith("]"):
                items = [i.strip() for i in arr[1:-1].split(",") if i.strip()]
                visibility[key] = items
    return roles, visibility


def detect_tokens(text: str) -> Dict[str, List[str]]:
    tokens: Dict[str, List[str]] = {
        "colors": sorted(set(COLOR_RE.findall(text))),
        "sizes": sorted(set(SIZE_RE.findall(text))),
        "radius": sorted(set(RADIUS_RE.findall(text))),
        "fonts": sorted(set(FONT_RE.findall(text))),
        "shadows": ["box-shadow" for _ in SHADOW_RE.findall(text)],
        "vars": sorted(set(VAR_RE.findall(text))),
    }
    # Dedup shadows to a single marker if any
    if tokens["shadows"]:
        tokens["shadows"] = ["box-shadow (detectado)"]
    return tokens


def summarize_inventory_dups(inv_md: str) -> List[Tuple[str, str, str, str]]:
    rows: List[Tuple[str, str, str, str]] = []
    if inv_md == "(no encontrado)":
        return rows
    in_table = False
    for line in inv_md.splitlines():
        if line.strip().startswith("Origen (legado)"):
            in_table = True
            continue
        if in_table:
            if line.strip().startswith("---"):
                continue
            if not line.strip():
                break
            parts = [p.strip() for p in line.split("|")]
            if len(parts) >= 4:
                rows.append((parts[0], parts[1], parts[2], parts[3]))
    return rows


def build_analysis(now: str, sources: Dict[str, str]) -> str:
    lines = []
    lines.append(f"# Análisis de Archivos UI — {now}")
    lines.append("Relación con roles, CCEs y view-as; estado y recomendaciones.")
    lines.append("")
    targets = [
        ("PLAN_INVESTIGACION_UI_ROLES.md", sources["plan"], "Plan maestro de investigación"),
        ("roles_matrix_base.yaml", sources["roles"], "Matriz base de roles y visibilidad CCEs"),
        ("view_as_spec.md", sources["viewas"], "Especificación de view-as (presentación)"),
        ("content_matrix_template.md", sources["cmatrix"], "Plantilla de control de contenido por rol"),
        ("glosario_tecnico_cliente.md", sources["glosario"], "Glosario técnico en lenguaje negocio"),
        ("ui_inventory.md", sources["inventory"], "Inventario real de UI"),
        ("AUDITORIA_ESTRUCTURA_SISTEMA.md", sources["auditoria"], "Auditoría de estructura completa"),
        ("apps/briefing/docs/ui/estilos.md", sources["estilos"], "Estilos UI y posibles tokens"),
    ]
    for name, txt, purpose in targets:
        status = "actual" if txt != "(no encontrado)" else "(no encontrado)"
        role_rel = "Admin (gobernanza)" if name in ("PLAN_INVESTIGACION_UI_ROLES.md", "roles_matrix_base.yaml", "view_as_spec.md") else "Cliente/Equipo (según contexto)"
        viewas_impact = "alto" if name == "view_as_spec.md" else ("medio" if "inventory" in name.lower() or "estilos" in name.lower() else "bajo")
        lines.append(f"## {name}")
        lines.append(f"- Propósito: {purpose}")
        lines.append(f"- Estado: {status}")
        lines.append(f"- Relación con roles: {role_rel}")
        lines.append(f"- Impacto en View-as: {viewas_impact}")
        if name.endswith("ui_inventory.md"):
            lines.append("- Nota: base para poblar la matriz de contenido por rol.")
        if name.endswith("estilos.md") and txt != "(no encontrado)":
            tok = detect_tokens(txt)
            lines.append(f"- Tokens detectados (conteo): colores={len(tok['colors'])}, tamaños={len(tok['sizes'])}, vars={len(tok['vars'])}")
        lines.append("")
    return "\n".join(lines) + "\n"


def build_tokens(now: str, estilos_text: str) -> str:
    lines = []
    lines.append(f"# Tokens UI Detectados — {now}")
    lines.append("Autor: Automatización Consolidación — Relación: BITÁCORA")
    lines.append("")
    if estilos_text == "(no encontrado)":
        lines.append("(No se encontró apps/briefing/docs/ui/estilos.md).")
        return "\n".join(lines) + "\n"
    tok = detect_tokens(estilos_text)
    def section(title: str, items: List[str]):
        lines.append(f"## {title}")
        if items:
            for i in items:
                lines.append(f"- {i}")
        else:
            lines.append("- (no detectado)")
        lines.append("")
    section("Colores", tok["colors"]) 
    section("Tamaños", tok["sizes"]) 
    section("Variables CSS", tok["vars"]) 
    section("Fuentes (declaraciones)", tok["fonts"]) 
    section("Sombras", tok["shadows"]) 
    section("Radio/Bordes (coincidencias)", tok["radius"]) 
    return "\n".join(lines) + "\n"


def build_cce(roles_text: str, now: str) -> str:
    lines = []
    lines.append(f"# Análisis CCE — {now}")
    lines.append("Autor: Automatización Consolidación — Relación: BITÁCORA")
    lines.append("")
    roles, vis = parse_roles_yaml(roles_text)
    cces: Set[str] = set()
    for arr in vis.values():
        for c in arr:
            cces.add(c)
    for cce in sorted(cces):
        lines.append(f"## {cce}")
        lines.append("- Props: id, title, status, owner, links (ejemplo)")
        lines.append("- Data contract: { id: string; title: string; status: 'R'|'G'|'A'; owner?: string; evidence?: string }")
        visible = [r for r in ROLES_ORDER if cce in vis.get(r, [])]
        lines.append(f"- Visibilidad por rol: {', '.join(visible) if visible else '(ninguno)'}")
        lines.append("")
    return "\n".join(lines) + "\n"


def build_backlog(now: str) -> str:
    lines = []
    lines.append(f"# Plan de Backlog por Sprints — {now}")
    lines.append("Autor: Automatización Consolidación — Relación: BITÁCORA")
    lines.append("")
    lines.append("## Sprint 1 — Cliente + View-as")
    lines.append("- Poblar content_matrix_template.md con páginas clave de ui_inventory.md.")
    lines.append("- Implementar selector View-as y banner en UI.")
    lines.append("- Revisar micro-copy de páginas clave para Cliente.")
    lines.append("")
    lines.append("## Sprint 2 — Owner / Equipo")
    lines.append("- Completar matriz de visibilidad de CCEs por rol.")
    lines.append("- Priorizar evidencias y entregas por vista.")
    lines.append("")
    lines.append("## Sprint 3 — Técnico aislado")
    lines.append("- Mover contenido técnico a vistas/espacios aislados.")
    lines.append("- Limpiar legados y normalizar documentación.")
    lines.append("")
    return "\n".join(lines) + "\n"


def build_depuracion(now: str) -> str:
    lines = []
    lines.append(f"# Plan de Depuración Inteligente — {now}")
    lines.append("Autor: Automatización Consolidación — Relación: BITÁCORA")
    lines.append("")
    lines.append("## Política")
    lines.append("- No eliminar: archivar con justificación, evidencia y destino.")
    lines.append("- Mantener gobernanza en la bitácora.")
    lines.append("")
    lines.append("## Reglas de preservación")
    lines.append("- Todo documento con impacto en Cliente permanece hasta revisión del Admin.")
    lines.append("- Legados se etiquetan 'status: deprecated' antes de mover a /_archive/.")
    lines.append("")
    lines.append("## Checklist de revisión")
    lines.append("- [ ] Duplicados validados.")
    lines.append("- [ ] Evidencias con enlaces verificados.")
    lines.append("- [ ] i18n revisada.")
    lines.append("")
    lines.append("## Flujo de archivo controlado")
    lines.append("1. Identificar candidato → 2. Registrar en bitácora → 3. Mover a /_archive/ con README local → 4. Actualizar referencias")
    lines.append("")
    return "\n".join(lines) + "\n"


def build_resumen(now: str) -> str:
    lines = []
    lines.append(f"# Resumen de Decisiones y Pendientes — {now}")
    lines.append("Autor: Automatización Consolidación — Relación: BITÁCORA")
    lines.append("")
    lines.append("## Decisiones (propuestas para validación)")
    lines.append("- Centralizar 'view-as' en header con banner y trazabilidad mínima.")
    lines.append("- Usar roles_matrix_base.yaml como base inicial de visibilidad CCEs.")
    lines.append("")
    lines.append("## Pendientes")
    lines.append("- Completar content_matrix_template.md con rutas del inventario.")
    lines.append("- Validar glosario y adaptar a i18n si aplica.")
    lines.append("")
    lines.append("## Prioridades")
    lines.append("1) Cliente + View-as, 2) Owner/Equipo, 3) Técnico aislado")
    lines.append("")
    return "\n".join(lines) + "\n"


def ensure_bitacora() -> None:
    if os.path.isfile(BITACORA):
        return
    os.makedirs(UI_DIR, exist_ok=True)
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    base = [
        "# 🧭 Bitácora Maestra de Investigación — RunArt Briefing v2",
        "**Administrador General:** Reinaldo Capiro  ",
        "**Proyecto:** Briefing v2 (UI, Roles, View-as)  ",
        f"**Inicio:** {now}  ",
        "**Ubicación:** docs/ui_roles/BITACORA_INVESTIGACION_BRIEFING_V2.md",
        "",
        "## 1. Propósito",
        "Este documento centraliza toda la información...",
        "",
        "## 2. Estructura de la Bitácora",
        "- **Resumen Ejecutivo**: contexto general y estado actual.",
        "- **Investigaciones Ejecutadas**: auditorías, inventarios, comparaciones, roles detectados.",
        "- **Documentos Generados**: lista y ruta de todos los archivos creados.",
        "- **Hallazgos Técnicos**: descubrimientos clave en UI, roles, CCEs y workflows.",
        "- **Pendientes / Checklist**: acciones concretas para corregir, limpiar o expandir.",
        "- **Decisiones Tomadas**: acuerdos sobre diseño, contenido, gobernanza y vistas.",
        "- **Próximos Pasos Planificados**: sprint o etapa siguiente.",
        "- **Anexos Automáticos**: copias resumidas de archivos relevantes (roles_matrix_base.yaml, ui_inventory.md, etc.).",
        "- **Historial de Cambios**: fechas, autor y resumen de cada actualización.",
        "",
        "---",
    ]
    write_text(BITACORA, "\n".join(base) + "\n")


def append_update_section(now: str, roles_text: str, inv_text: str, auditoria_text: str, tokens_preview: Dict[str, int]) -> None:
    lines: List[str] = []
    lines.append("")
    lines.append(f"### 🔄 Actualización — {now}")
    lines.append("")
    # Resumen Ejecutivo
    lines.append("#### Resumen Ejecutivo")
    lines.append("Actualización integral que consolida auditorías, inventarios, roles, CCEs y tokens en anexos y bitácora.")
    lines.append("")
    # Hallazgos Técnicos Detallados
    lines.append("#### Hallazgos Técnicos Detallados")
    inv_snip = inv_text.splitlines()[:20]
    aud_snip = auditoria_text.splitlines()[:20]
    lines.append("- Inventario UI (extracto):")
    lines.extend([f"  {line}" for line in inv_snip])
    lines.append("- Auditoría de estructura (extracto):")
    lines.extend([f"  {line}" for line in aud_snip])
    lines.append("")
    # Tokens y Estilo
    lines.append("#### Tokens y Estilo")
    lines.append("Tipo | Conteo")
    lines.append("--- | ---")
    for k, v in tokens_preview.items():
        lines.append(f"{k} | {v}")
    lines.append("")
    # CCE y Roles
    lines.append("#### CCE y Roles")
    _, vis = parse_roles_yaml(roles_text)
    for role in ROLES_ORDER:
        comps = vis.get(role, [])
        lines.append(f"- {role}: {', '.join(comps) if comps else '(sin CCE asignados)'}")
    lines.append("")
    # Decisiones Estratégicas
    lines.append("#### Decisiones Estratégicas")
    lines.append("- Mantener la bitácora como única fuente de verdad.")
    lines.append("- Avanzar con View-as sin tocar permisos backend.")
    lines.append("")
    # Checklist de Avances
    lines.append("#### Checklist de Avances")
    lines.append("- [x] Auditoría de estructura completada.")
    lines.append("- [x] Inventario de UI consolidado.")
    lines.append("- [x] Matriz de roles base definida.")
    lines.append("- [x] View-as especificado (diseño de presentación).")
    lines.append("- [x] Glosario inicial creado.")
    lines.append("- [ ] Depuración planificada (pendiente de ejecución controlada).")
    lines.append("- [ ] Sprint 1 preparado (poblado de matriz de contenido).")
    lines.append("")
    # Próximos Pasos
    lines.append("#### Próximos Pasos")
    lines.append("- Poblar content_matrix_template.md a partir de ui_inventory.md.")
    lines.append("- Validar roles_matrix_base.yaml con Admin General.")
    lines.append("- Identificar i18n y micro-copy prioritario para Cliente.")
    lines.append("")
    # Depuración Inteligente
    lines.append("#### Depuración Inteligente")
    lines.append("- Registrar duplicados/legados en PLAN_DEPURACION_INTELIGENTE.md y ejecutar archivo controlado.")
    lines.append("")
    # Referencias a anexos
    lines.append("#### Anexos Generados")
    for key, path in ANNEX.items():
        rel = path.replace(ROOT + os.sep, '')
        lines.append(f"- {rel}")
    lines.append("")
    lines.append("---")
    lines.append("✅ Estado actual: consolidado y listo para siguiente fase.")
    lines.append("---")

    with open(BITACORA, "a", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")


def main() -> int:
    os.makedirs(UI_DIR, exist_ok=True)
    ensure_bitacora()

    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # Leer fuentes
    sources = {k: read_text(p) for k, p in FILES.items()}
    roles_text = sources["roles"]
    inv_text = sources["inventory"]
    auditoria_text = sources["auditoria"]
    estilos_text = sources["estilos"]

    # Generar anexos
    analysis_md = build_analysis(now, sources)
    tokens_md = build_tokens(now, estilos_text)
    cce_md = build_cce(roles_text, now)
    backlog_md = build_backlog(now)
    depur_md = build_depuracion(now)
    resumen_md = build_resumen(now)

    write_text(ANNEX["analysis"], analysis_md)
    write_text(ANNEX["tokens"], tokens_md)
    write_text(ANNEX["cce"], cce_md)
    write_text(ANNEX["backlog"], backlog_md)
    write_text(ANNEX["depuracion"], depur_md)
    write_text(ANNEX["resumen"], resumen_md)

    # Resumen de tokens para tabla breve
    tok_counts = {"colores": 0, "tamaños": 0, "variables": 0, "sombras": 0, "radius": 0, "fuentes": 0}
    if estilos_text != "(no encontrado)":
        t = detect_tokens(estilos_text)
        tok_counts = {
            "colores": len(t["colors"]),
            "tamaños": len(t["sizes"]),
            "variables": len(t["vars"]),
            "sombras": len(t["shadows"]),
            "radius": len(t["radius"]),
            "fuentes": len(t["fonts"]),
        }

    # Actualizar bitácora
    append_update_section(now, roles_text, inv_text, auditoria_text, tok_counts)

    print("✅ Consolidación e investigación completadas. Bitácora maestra actualizada correctamente.")
    print(BITACORA)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as e:
        print(f"Error en consolidación: {e}", file=sys.stderr)
        sys.exit(1)
