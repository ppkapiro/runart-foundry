#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Enriquece docs/ui_roles/content_matrix_template.md con CCEs sugeridos y Prioridad (P1/P2)
por página a partir de docs/ui_roles/ui_inventory.md.

- No borra nada: agrega una sección "Auto-enriquecimiento — <timestamp>".
- Genera filas para rol=cliente únicamente (enfocado a vista Cliente).
- Heurísticas CCEs por ruta/nombre (minúsculas):
  * kpi -> kpi_chip
  * hito -> hito_card
  * decision/decisión -> decision_chip
  * entrega -> entrega_card
  * eviden -> evidencia_clip
  * ficha|tecnica|técnica -> ficha_tecnica_mini
  * faq|preguntas -> faq_item
- Prioridad: P1 si no es técnico y parece Cliente; P2 si técnico.
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

CCE_MAP = [
    ("kpi", "kpi_chip"),
    ("hito", "hito_card"),
    ("decision", "decision_chip"),
    ("decisión", "decision_chip"),
    ("entrega", "entrega_card"),
    ("eviden", "evidencia_clip"),
    ("ficha", "ficha_tecnica_mini"),
    ("tecnica", "ficha_tecnica_mini"),
    ("técnica", "ficha_tecnica_mini"),
    ("faq", "faq_item"),
    ("preguntas", "faq_item"),
]


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
            text = raw.strip()[2:]
            is_dir = text.endswith("/")
            name = text[:-1] if is_dir else text
            while stack and stack[-1][0] >= indent:
                stack.pop()
            parent = "/".join(p for _, p in stack) if stack else ""
            cur = f"{parent}/{name}" if parent else name
            if is_dir:
                stack.append((indent, cur))
            else:
                files.append(cur)
    norm = []
    for f in files:
        f = f.replace("//", "/")
        if f.startswith("/"):
            f = f[1:]
        norm.append(f)
    return norm


def is_tech(path: str) -> bool:
    base = os.path.basename(path).lower()
    return any(k in base for k in TECH_HINTS)


def suggest_cces(path: str) -> List[str]:
    low = os.path.basename(path).lower()
    hits = []
    for key, cce in CCE_MAP:
        if key in low and cce not in hits:
            hits.append(cce)
    return hits


def main() -> int:
    inv_md = read_text(INV)
    if not inv_md:
        print("ui_inventory.md no encontrado; nada que enriquecer.")
        return 0

    paths = parse_inventory_tree(inv_md)
    if not paths:
        print("No se detectaron rutas; nada que enriquecer.")
        return 0

    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    header = []
    header.append("")
    header.append(f"## Auto-enriquecimiento — {ts}")
    header.append("")
    header.append("Ruta/Página | Rol | CCE(s) | Prioridad | Nota")
    header.append("--- | --- | --- | --- | ---")

    rows: List[str] = []
    for p in paths:
        cces = suggest_cces(p)
        pri = "P2" if is_tech(p) else "P1"
        nota = "heurística"
        rows.append(f"{p} | cliente | {', '.join(cces) if cces else '-'} | {pri} | {nota}")

    append_text(TEMPLATE, "\n".join(header + rows) + "\n")

    print("Content matrix enriquecida con CCEs/Prioridad (rol=cliente)")
    print(TEMPLATE)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as e:
        print(f"Error enriqueciendo content matrix: {e}", file=sys.stderr)
        sys.exit(1)
