#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Genera docs/ui_roles/ui_inventory.md a partir del contenido real del repositorio.
- Fuente principal: apps/briefing/docs/ui/ (si existe)
- Comparación: _archive/legacy_removed_20251007/briefing/docs/ui/ (si existe)
- Ignora: node_modules/, site/
- Produce: árbol jerárquico, tabla de duplicados/legados, observaciones automáticas
"""
from __future__ import annotations
import os
import sys
from datetime import datetime
from typing import Dict, List, Tuple, Set

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, ".."))
OUT_DIR = os.path.join(ROOT_DIR, "docs", "ui_roles")
OUT_FILE = os.path.join(OUT_DIR, "ui_inventory.md")

CURR_BASE = os.path.join(ROOT_DIR, "apps", "briefing", "docs", "ui")
ARCH_BASE = os.path.join(ROOT_DIR, "_archive", "legacy_removed_20251007", "briefing", "docs", "ui")

SKIP_DIRS = {"node_modules", "site", ".git", "__pycache__"}

class Node:
    __slots__ = ("dirs", "files")
    def __init__(self) -> None:
        self.dirs: Dict[str, Node] = {}
        self.files: List[str] = []


def add_path(tree: Node, parts: List[str], filename: str | None = None) -> None:
    cur = tree
    for p in parts:
        if p not in cur.dirs:
            cur.dirs[p] = Node()
        cur = cur.dirs[p]
    if filename:
        cur.files.append(filename)


def rel_parts(path: str, base: str) -> List[str]:
    rel = os.path.relpath(path, base)
    if rel == ".":
        return []
    return rel.replace("\\", "/").split("/")


def scan_dir(base: str) -> Tuple[Node, Set[str]]:
    tree = Node()
    files: Set[str] = set()
    if not os.path.isdir(base):
        return tree, files

    for dirpath, dirnames, filenames in os.walk(base, topdown=True):
        # filtrar directorios a ignorar
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        dirnames.sort(key=str.lower)
        filenames.sort(key=str.lower)

        parts = rel_parts(dirpath, base)
        if parts:
            add_path(tree, parts)
        for f in filenames:
            add_path(tree, parts, f)
            rel_file = "/".join(parts + [f]) if parts else f
            files.add(rel_file)

    return tree, files


def render_tree_md(tree: Node, root_label: str) -> str:
    lines: List[str] = []
    lines.append(f"- {root_label}/")

    def _render(node: Node, depth: int, name: str | None = None) -> None:
        indent = "  " * depth
        if name is not None:
            lines.append(f"{indent}- {name}/")
        # Subdirs
        for dname in sorted(node.dirs.keys(), key=str.lower):
            _render(node.dirs[dname], depth + (0 if name is None else 1), dname)
        # Files
        file_indent = "  " * (depth + (0 if name is None else 1))
        for fname in sorted(node.files, key=str.lower):
            lines.append(f"{file_indent}- {fname}")

    for dname in sorted(tree.dirs.keys(), key=str.lower):
        _render(tree.dirs[dname], 1, dname)
    for fname in sorted(tree.files, key=str.lower):
        lines.append(f"  - {fname}")
    return "\n".join(lines)


def main() -> int:
    os.makedirs(OUT_DIR, exist_ok=True)

    curr_tree, curr_files = scan_dir(CURR_BASE)
    arch_tree, arch_files = scan_dir(ARCH_BASE)

    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    lines: List[str] = []
    lines.append("# Inventario de UI (Briefing v2)")
    lines.append("")
    lines.append(f"Generado: {now}")
    lines.append("")

    # Fuentes analizadas
    lines.append("## Fuentes analizadas")
    lines.append("")
    lines.append(f"- Actual: {'apps/briefing/docs/ui/' if os.path.isdir(CURR_BASE) else '(no encontrado)'}")
    lines.append(f"- Legado: {'_archive/legacy_removed_20251007/briefing/docs/ui/' if os.path.isdir(ARCH_BASE) else '(no encontrado)'}")
    lines.append("")

    # Árbol actual
    lines.append("## Estructura actual (jerárquica)")
    lines.append("")
    if os.path.isdir(CURR_BASE) and curr_files:
        lines.append(render_tree_md(curr_tree, "apps/briefing/docs/ui"))
    else:
        lines.append("(no hay contenido actual o no encontrado)")
    lines.append("")

    # Duplicados y legados
    lines.append("## Duplicados y Legados")
    lines.append("")
    lines.append("Origen (legado) | Estado | Destino sugerido | Nota")
    lines.append("--- | --- | --- | ---")
    if os.path.isdir(ARCH_BASE) and arch_files:
        for rel in sorted(arch_files):
            if rel in curr_files:
                lines.append(f"{rel} | duplicado | mantener actual | Existe versión en actual")
            else:
                lines.append(f"{rel} | para_rescatar | apps/briefing/docs/ui/{rel} | Migrar si sigue vigente")
    else:
        lines.append("(sin legado o no encontrado) | - | - | -")
    lines.append("")

    # Observaciones automáticas (heurísticas livianas)
    lines.append("## Observaciones automáticas")
    lines.append("")
    # i18n básica
    if os.path.isdir(CURR_BASE):
        has_es = os.path.isdir(os.path.join(CURR_BASE, 'es'))
        has_en = os.path.isdir(os.path.join(CURR_BASE, 'en'))
        if not (has_es or has_en):
            lines.append("- Falta i18n estructurada: no se detectaron subcarpetas 'es'/'en'.")
    # Exceso técnico en UI
    tech_exts = {'.sh', '.py', '.ts', '.js', '.yml', '.yaml'}
    tech_hits = [p for p in curr_files if os.path.splitext(p)[1].lower() in tech_exts]
    if tech_hits:
        lines.append(f"- Archivos técnicos dentro de UI: {len(tech_hits)} (ej. {', '.join(tech_hits[:5])}{'...' if len(tech_hits)>5 else ''})")
    # Evidencias sin link (heurística: markdown con 'evidencia' en la ruta)
    evid_hits = [p for p in curr_files if p.lower().endswith('.md') and 'evidenc' in p.lower()]
    if evid_hits:
        lines.append(f"- Revisar evidencias con posible ausencia de vínculos externos: {len(evid_hits)} (ej. {', '.join(evid_hits[:5])}{'...' if len(evid_hits)>5 else ''})")
    if not (os.path.isdir(CURR_BASE) and curr_files):
        lines.append("- No se detectó estructura actual para evaluar observaciones.")
    lines.append("")

    with open(OUT_FILE, 'w', encoding='utf-8') as f:
        f.write("\n".join(lines) + "\n")

    print(OUT_FILE)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as e:
        print(f"Error generando ui_inventory: {e}", file=sys.stderr)
        sys.exit(1)
