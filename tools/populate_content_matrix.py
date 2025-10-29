#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Puebla docs/ui_roles/content_matrix_template.md con filas iniciales a partir de docs/ui_roles/ui_inventory.md.
Reglas:
- Mantiene el contenido previo del template; agrega una sección "Auto-populación — <timestamp>".
- Ignora node_modules/ y site/ (ya lo hace el inventario).
- Heurísticas de estado por rol:
  * Si la ruta/archivo parece técnico (estilo/style/tecnic/dev/config/build):
      - admin: G, cliente: A, owner_interno: A, equipo: A, tecnico: G
  * Si no es técnico:
      - admin: G, cliente: G, owner_interno: A, equipo: A, tecnico: R
- Acciones por estado: G=Maintener, A=Re-escribir micro-copy, R=Mover a vista técnica
- Dueño por rol: admin=Admin General, cliente=PM, owner_interno=Owner, equipo=UX, tecnico=Tech Lead
"""
from __future__ import annotations
import os
import sys
from datetime import datetime
from typing import List, Tuple

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
UI_DIR = os.path.join(ROOT, "docs", "ui_roles")
INV = os.path.join(UI_DIR, "ui_inventory.md")
TEMPLATE = os.path.join(UI_DIR, "content_matrix_template.md")

TECH_HINTS = ("estilo", "style", "tecnic", "tech", "dev", "config", "build")
ROLES = ["cliente", "owner_interno", "equipo", "tecnico", "admin"]
ACTION_BY_STATE = {"G": "Mantener", "A": "Re-escribir micro-copy", "R": "Mover a vista técnica"}
OWNER_BY_ROLE = {"admin": "Admin General", "cliente": "PM", "owner_interno": "Owner", "equipo": "UX", "tecnico": "Tech Lead"}


def read_text(path: str) -> str:
    if not os.path.isfile(path):
        return ""
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        return f.read()


def append_text(path: str, content: str) -> None:
    with open(path, "a", encoding="utf-8") as f:
        f.write(content)


def parse_inventory_tree(md: str) -> List[str]:
    if not md:
        return []
    lines = md.splitlines()
    # Buscar sección "## Estructura actual (jerárquica)"
    start = -1
    for i, line in enumerate(lines):
        if line.strip().lower().startswith("## estructura actual"):
            start = i + 1
            break
    if start == -1:
        return []
    # Capturar hasta la próxima sección
    section: List[str] = []
    for j in range(start, len(lines)):
        if lines[j].startswith("## ") and j != start:
            break
        section.append(lines[j])
    # Parse tipo árbol con indentación de dos espacios por nivel
    stack: List[Tuple[int, str]] = []  # (indent_level, path)
    files: List[str] = []
    for raw in section:
        if raw.strip().startswith("- "):
            indent = len(raw) - len(raw.lstrip(" "))
            text = raw.strip()[2:]  # quitar '- '
            is_dir = text.endswith("/")
            name = text[:-1] if is_dir else text
            # Ajustar stack según indentación
            while stack and stack[-1][0] >= indent:
                stack.pop()
            parent = "/".join(p for _, p in stack) if stack else ""
            cur = f"{parent}/{name}" if parent else name
            if is_dir:
                stack.append((indent, cur))
            else:
                files.append(cur)
    # Normalizar sin dobles barras
    norm = []
    for f in files:
        f = f.replace("//", "/")
        if f.startswith("/"):
            f = f[1:]
        norm.append(f)
    return norm


def classify_states(path: str) -> dict:
    base = os.path.basename(path).lower()
    is_tech = any(k in base for k in TECH_HINTS)
    if is_tech:
        return {"admin": "G", "cliente": "A", "owner_interno": "A", "equipo": "A", "tecnico": "G"}
    return {"admin": "G", "cliente": "G", "owner_interno": "A", "equipo": "A", "tecnico": "R"}


def build_rows(paths: List[str]) -> List[str]:
    rows: List[str] = []
    for p in paths:
        states = classify_states(p)
        for role in ROLES:
            state = states[role]
            action = ACTION_BY_STATE[state]
            owner = OWNER_BY_ROLE[role]
            rows.append(f"{p} | {role} | {state} | {action} | {owner} | ")
    return rows


def main() -> int:
    inv_md = read_text(INV)
    if not inv_md:
        print("ui_inventory.md no encontrado; nada que poblar.")
        return 0

    paths = parse_inventory_tree(inv_md)
    if not paths:
        print("No se detectaron rutas en el inventario; nada que poblar.")
        return 0

    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    header = []
    header.append("")
    header.append(f"## Auto-populación — {ts}")
    header.append("")
    header.append("Ruta/Página | Rol | Estado (R/G/A) | Acción | Dueño | Evidencia")
    header.append("--- | --- | --- | --- | --- | ---")

    rows = build_rows(paths)

    append_text(TEMPLATE, "\n".join(header + rows) + "\n")

    print("Content matrix poblada automáticamente desde ui_inventory.md")
    print(TEMPLATE)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as e:
        print(f"Error poblando content matrix: {e}", file=sys.stderr)
        sys.exit(1)
