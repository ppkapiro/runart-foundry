#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Crea/actualiza docs/ui_roles/BITACORA_INVESTIGACION_BRIEFING_V2.md con información consolidada:
- Si no existe, genera base con estructura y contenido inicial.
- Siempre agrega una sección "Actualización" con timestamp y resúmenes.
- Integra resúmenes de: PLAN_INVESTIGACION_UI_ROLES.md, ui_inventory.md, roles_matrix_base.yaml,
  view_as_spec.md, content_matrix_template.md, glosario_tecnico_cliente.md y AUDITORIA_ESTRUCTURA_SISTEMA.md.
"""
from __future__ import annotations
import os
import sys
from datetime import datetime
from typing import Optional, List, Tuple

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
UI_ROLES_DIR = os.path.join(ROOT, "docs", "ui_roles")
BITACORA = os.path.join(UI_ROLES_DIR, "BITACORA_INVESTIGACION_BRIEFING_V2.md")

FILES = {
    "plan": os.path.join(UI_ROLES_DIR, "PLAN_INVESTIGACION_UI_ROLES.md"),
    "inventory": os.path.join(UI_ROLES_DIR, "ui_inventory.md"),
    "roles": os.path.join(UI_ROLES_DIR, "roles_matrix_base.yaml"),
    "viewas": os.path.join(UI_ROLES_DIR, "view_as_spec.md"),
    "content_matrix": os.path.join(UI_ROLES_DIR, "content_matrix_template.md"),
    "glosario": os.path.join(UI_ROLES_DIR, "glosario_tecnico_cliente.md"),
    "auditoria": os.path.join(ROOT, "AUDITORIA_ESTRUCTURA_SISTEMA.md"),
}


def read_text(path: str, max_lines: Optional[int] = None) -> str:
    if not os.path.isfile(path):
        return "(no encontrado)"
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        if max_lines is None:
            return f.read()
        lines = []
        for i, line in enumerate(f):
            lines.append(line.rstrip("\n"))
            if i + 1 >= max_lines:
                break
        return "\n".join(lines)


def count_lines(path: str) -> int:
    if not os.path.isfile(path):
        return 0
    c = 0
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        for _ in f:
            c += 1
    return c


def summarize_roles_yaml(text: str) -> Tuple[int, List[str]]:
    roles = []
    for line in text.splitlines():
        s = line.strip()
        if s.startswith("- id:"):
            r = s.split(":", 1)[1].strip()
            if r:
                roles.append(r)
    return len(roles), roles


def ensure_base() -> bool:
    """Garantiza que existe el archivo de bitácora. Si no existe, crea base.
    Devuelve True si el archivo fue creado nuevo.
    """
    os.makedirs(UI_ROLES_DIR, exist_ok=True)
    if os.path.isfile(BITACORA):
        return False
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    base = []
    base.append("# 🧭 Bitácora Maestra de Investigación — RunArt Briefing v2")
    base.append("**Administrador General:** Reinaldo Capiro  ")
    base.append("**Proyecto:** Briefing v2 (UI, Roles, View-as)  ")
    base.append(f"**Inicio:** {now}  ")
    base.append("**Ubicación:** docs/ui_roles/BITACORA_INVESTIGACION_BRIEFING_V2.md")
    base.append("")
    base.append("## 1. Propósito")
    base.append("Este documento centraliza toda la información, hallazgos, auditorías, rutas, tareas, decisiones y planes relacionados con la reestructuración del Briefing v2. Sustituye la dispersión de múltiples archivos y actúa como bitácora guía única para todo el proceso.")
    base.append("")
    base.append("## 2. Estructura de la Bitácora")
    base.append("- **Resumen Ejecutivo**: contexto general y estado actual.")
    base.append("- **Investigaciones Ejecutadas**: auditorías, inventarios, comparaciones, roles detectados.")
    base.append("- **Documentos Generados**: lista y ruta de todos los archivos creados.")
    base.append("- **Hallazgos Técnicos**: descubrimientos clave en UI, roles, CCEs y workflows.")
    base.append("- **Pendientes / Checklist**: acciones concretas para corregir, limpiar o expandir.")
    base.append("- **Decisiones Tomadas**: acuerdos sobre diseño, contenido, gobernanza y vistas.")
    base.append("- **Próximos Pasos Planificados**: sprint o etapa siguiente.")
    base.append("- **Anexos Automáticos**: copias resumidas de archivos relevantes (roles_matrix_base.yaml, ui_inventory.md, etc.).")
    base.append("- **Historial de Cambios**: fechas, autor y resumen de cada actualización.")
    base.append("")
    base.append("## 3. Contenido Inicial (auto-cargar)")
    base.append("Secciones dinámicas que se rellenan con cada actualización.")
    base.append("")
    base.append("## 4. Formato de actualización")
    base.append("Cada ejecución agrega una sección con resumen de cambios y acciones recomendadas.")
    base.append("")
    base.append("## 5. Checklist de Control (editable)")
    base.append("- [ ] Auditoría de estructura completada.")
    base.append("- [ ] Inventario de UI consolidado.")
    base.append("- [ ] Matriz de roles validada.")
    base.append("- [ ] View-as especificado y en desarrollo.")
    base.append("- [ ] Glosario completado.")
    base.append("- [ ] Eliminación de documentación obsoleta planificada.")
    base.append("- [ ] Sprint 1 (Cliente + View-as) preparado.")
    base.append("")
    base.append("## 6. Normas")
    base.append("- Todas las referencias y decisiones deben aparecer aquí.")
    base.append("- Ningún archivo auxiliar se considera final sin registro en esta bitácora.")
    base.append("- La bitácora siempre se guarda en docs/ui_roles/.")
    base.append("")
    base.append("---")
    with open(BITACORA, "w", encoding="utf-8") as f:
        f.write("\n".join(base) + "\n")
    return True


def append_update() -> None:
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    lines: List[str] = []

    # Resumen Ejecutivo (ligero)
    plan = read_text(FILES["plan"], max_lines=30)
    inv = read_text(FILES["inventory"], max_lines=60)
    roles_yaml = read_text(FILES["roles"], max_lines=200)
    viewas = read_text(FILES["viewas"], max_lines=60)
    cmatrix = read_text(FILES["content_matrix"], max_lines=40)
    glosario = read_text(FILES["glosario"], max_lines=40)
    auditoria = read_text(FILES["auditoria"], max_lines=120)

    roles_count, roles_list = summarize_roles_yaml(roles_yaml)

    # Documentos generados
    docs_gen = []
    for key, path in FILES.items():
        exists = os.path.isfile(path)
        size = os.path.getsize(path) if exists else 0
        docs_gen.append((path.replace(ROOT + os.sep, ''), exists, size))

    # Hallazgos rápidos desde inventario/auditoría
    obs_lines = []
    if inv and inv != "(no encontrado)":
        for line in inv.splitlines():
            if line.startswith("- ") or line.startswith("(no hay "):
                obs_lines.append(line)
    if auditoria and auditoria != "(no encontrado)":
        cap = False
        for line in auditoria.splitlines():
            if line.strip().lower().startswith("## observaciones"):
                cap = True
                continue
            if cap:
                if line.strip().startswith("## "):
                    break
                if line.strip():
                    obs_lines.append(line)

    # Anexos (resúmenes)
    def section(title: str):
        lines.append("")
        lines.append(title)
        lines.append("")

    lines.append(f"### 🔄 Actualización — {now}")
    lines.append("")

    # Resumen Ejecutivo
    section("#### Resumen Ejecutivo")
    lines.append(f"- Roles definidos: {roles_count} — {', '.join(roles_list) if roles_list else '(no especificados)'}")
    inv_found = os.path.isfile(FILES['inventory'])
    lines.append(f"- Inventario UI: {'presente' if inv_found else 'no encontrado'}")
    lines.append(f"- Auditoría de estructura: {'presente' if os.path.isfile(FILES['auditoria']) else 'no encontrada'}")

    # Documentos Generados
    section("#### Documentos Generados")
    lines.append("Ruta | Estado | Tamaño (bytes)")
    lines.append("--- | --- | ---")
    for rel, exists, size in docs_gen:
        lines.append(f"{rel} | {'ok' if exists else 'no_encontrado'} | {size}")

    # Investigaciones Ejecutadas
    section("#### Investigaciones Ejecutadas")
    lines.append("- Auditoría de estructura del sistema (resumen parcial).")
    lines.append("- Inventario de UI (estructura actual y legados).")

    # Hallazgos Técnicos (auto)
    section("#### Hallazgos Técnicos (automáticos)")
    if obs_lines:
        for obs in obs_lines[:20]:
            lines.append(f"- {obs.lstrip('- ').strip()}")
    else:
        lines.append("- (Sin observaciones nuevas detectadas)")

    # Decisiones Tomadas (placeholder editable)
    section("#### Decisiones Tomadas (pendiente de validación)")
    lines.append("- Centralizar ‘view-as’ en header con banner y trazabilidad mínima.")

    # Próximos Pasos Planificados
    section("#### Próximos Pasos Planificados")
    lines.append("- Completar content_matrix_template.md con páginas del inventario.")
    lines.append("- Validar roles_matrix_base.yaml con Admin General.")

    # Anexos Automáticos (resumenes)
    section("#### Anexos Automáticos (resúmenes)")
    lines.append("```yaml\n# roles_matrix_base.yaml (extracto)\n" + roles_yaml[:1000] + "\n```")
    lines.append("```markdown\n# ui_inventory.md (extracto)\n" + inv[:1000] + "\n```")
    lines.append("```markdown\n# PLAN_INVESTIGACION_UI_ROLES.md (extracto)\n" + plan[:800] + "\n```")
    lines.append("```markdown\n# view_as_spec.md (extracto)\n" + viewas[:600] + "\n```")
    lines.append("```markdown\n# content_matrix_template.md (extracto)\n" + cmatrix[:400] + "\n```")
    lines.append("```markdown\n# glosario_tecnico_cliente.md (extracto)\n" + glosario[:600] + "\n```")
    lines.append("```markdown\n# AUDITORIA_ESTRUCTURA_SISTEMA.md (extracto)\n" + auditoria[:1000] + "\n```")

    # Historial de Cambios
    section("#### Historial de Cambios")
    lines.append(f"- {now}: Actualización automática consolidada.")

    with open(BITACORA, "a", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")


def main() -> int:
    ensure_base()
    append_update()
    print("✅ Bitácora Maestra creada/actualizada correctamente: docs/ui_roles/BITACORA_INVESTIGACION_BRIEFING_V2.md")
    print(BITACORA)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as e:
        print(f"Error actualizando bitácora: {e}", file=sys.stderr)
        sys.exit(1)
