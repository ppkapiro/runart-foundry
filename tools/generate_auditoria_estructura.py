#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Genera AUDITORIA_ESTRUCTURA_SISTEMA.md en la raíz del repo.
- Recorre todo el árbol (incluye carpetas ocultas)
- Construye un mapa tipo árbol en Markdown
- Resume conteo por extensión
- Identifica carpetas clave (UI, roles, docs, etc.)
- Observaciones (vacías, duplicadas por nombre, carpetas de posible legado)
"""
from __future__ import annotations
import os
import sys
import re
from collections import Counter
from datetime import datetime
from typing import Dict, List, Tuple

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, ".."))
PROJECT_NAME = os.path.basename(ROOT_DIR.rstrip(os.sep)) or "repo"
OUTPUT_MD = os.path.join(ROOT_DIR, "AUDITORIA_ESTRUCTURA_SISTEMA.md")

# Heurística de carpetas "legado" o duplicadas/versionadas
LEGACY_HINTS = [
    "archive", "_archive", "archiv", "backup", "bak", "old", "legacy", "tmp", "temp",
    "dist", "build", "copy", "copias", "anteri", "prev", "deprecated", "v\d+", "\.old$"
]
LEGACY_RE = re.compile(r"(" + r"|".join(LEGACY_HINTS) + r")", re.IGNORECASE)

# Palabras clave para carpetas relevantes
KEY_DIR_PATTERNS: List[Tuple[str, str]] = [
    (".github/workflows", "CI/CD Workflows (GitHub Actions)"),
    (".github", "Configuración de GitHub (issues, templates, workflows)"),
    (".vscode", "Configuración de VS Code"),
    ("apps", "Aplicaciones (múltiples apps o servicios)"),
    ("src", "Código fuente principal"),
    ("docs", "Documentación del proyecto"),
    ("content", "Contenido estático/CMS"),
    ("components", "Componentes UI reutilizables"),
    ("ui", "Interfaz de usuario"),
    ("ux", "Experiencia de usuario/diseño"),
    ("roles", "Roles y permisos"),
    ("layout", "Layouts de UI"),
    ("layouts", "Layouts de UI"),
    ("pages", "Rutas de UI (pages)"),
    ("templates", "Plantillas reutilizables"),
    ("tests", "Pruebas automáticas"),
    ("deploy", "Scripts/manifests de despliegue"),
    ("scripts", "Scripts de soporte"),
    ("tools", "Herramientas operativas"),
    ("plugins", "Plugins o extensiones"),
    ("internal", "Código interno/privado"),
    ("briefing", "Material de briefing"),
]

FILE_TYPE_LABEL = {
    "": "(sin extensión)",
}

class TreeNode:
    __slots__ = ("dirs", "files")
    def __init__(self) -> None:
        self.dirs: Dict[str, TreeNode] = {}
        self.files: List[str] = []


def add_dir(root: TreeNode, parts: List[str]) -> None:
    cur = root
    for p in parts:
        if p not in cur.dirs:
            cur.dirs[p] = TreeNode()
        cur = cur.dirs[p]


def add_file(root: TreeNode, parts: List[str], filename: str) -> None:
    cur = root
    for p in parts:
        if p not in cur.dirs:
            cur.dirs[p] = TreeNode()
        cur = cur.dirs[p]
    cur.files.append(filename)


def rel_parts(path: str) -> List[str]:
    rel = os.path.relpath(path, ROOT_DIR)
    if rel == ".":
        return []
    return rel.replace("\\", "/").split("/")


def detect_key_dirs(all_dirs: List[str]) -> List[Tuple[str, str]]:
    hits = []
    lowered = [d.lower() for d in all_dirs]
    for pattern, desc in KEY_DIR_PATTERNS:
        for i, d in enumerate(lowered):
            if pattern in d:
                hits.append((all_dirs[i], desc))
    # De-duplicar conservando orden
    seen = set()
    uniq = []
    for path, desc in hits:
        key = (path, desc)
        if key not in seen:
            seen.add(key)
            uniq.append((path, desc))
    return uniq


def render_tree_md(root_node: TreeNode) -> str:
    lines: List[str] = []

    def _render(node: TreeNode, depth: int, name: str | None = None):
        indent = "  " * depth
        if name is not None:
            lines.append(f"{indent}- {name}/")
        # Directorios primero, luego archivos; orden alfabético
        for dname in sorted(node.dirs.keys(), key=str.lower):
            _render(node.dirs[dname], depth + (0 if name is None else 1), dname)
        # Archivos
        file_indent = "  " * (depth + (0 if name is None else 1))
        for fname in sorted(node.files, key=str.lower):
            lines.append(f"{file_indent}- {fname}")

    # Raíz con nombre del proyecto
    lines.append(f"- {PROJECT_NAME}/")
    for dname in sorted(root_node.dirs.keys(), key=str.lower):
        _render(root_node.dirs[dname], 1, dname)
    for fname in sorted(root_node.files, key=str.lower):
        lines.append(f"  - {fname}")

    return "\n".join(lines)


def ext_of(filename: str) -> str:
    ext = os.path.splitext(filename)[1].lower()
    return FILE_TYPE_LABEL.get(ext, ext if ext else FILE_TYPE_LABEL[""])


def main() -> int:
    tree = TreeNode()
    ext_counter: Counter[str] = Counter()
    all_dirs: List[str] = []
    empty_dirs: List[str] = []
    basename_counts: Counter[str] = Counter()
    legacy_like: List[str] = []

    for dirpath, dirnames, filenames in os.walk(ROOT_DIR, topdown=True):
        # Normalizar y ordenar para salida estable
        dirnames.sort(key=str.lower)
        filenames.sort(key=str.lower)

        # Datos de directorio
        rel_dir = os.path.relpath(dirpath, ROOT_DIR)
        if rel_dir == ".":
            rel_dir = ""
        rel_dir_unix = rel_dir.replace("\\", "/")
        
        if rel_dir_unix != "":
            all_dirs.append(rel_dir_unix)
            basename = os.path.basename(rel_dir_unix)
            if basename:
                basename_counts[basename.lower()] += 1
            if LEGACY_RE.search(rel_dir_unix):
                legacy_like.append(rel_dir_unix)

        # Asegurar nodo del directorio actual
        parts = rel_parts(dirpath)
        if parts:
            add_dir(tree, parts)

        # Registrar subdirectorios vacíos potenciales (si no tienen hijos ni archivos, se sabrá al final,
        # pero aquí no tenemos esa info; lo calcularemos luego recorriendo el árbol construido)

        # Archivos
        for fname in filenames:
            add_file(tree, parts, fname)
            ext_counter[ext_of(fname)] += 1

    # Calcular directorios vacíos recorriendo el árbol
    def collect_empty_dirs(node: TreeNode, path_parts: List[str]):
        # Un directorio vacío si no tiene archivos ni subdirectorios
        if not node.files and not node.dirs:
            if path_parts:
                empty_dirs.append("/".join(path_parts))
        for dname, child in node.dirs.items():
            collect_empty_dirs(child, path_parts + [dname])

    collect_empty_dirs(tree, [])

    # Carpetas clave
    key_dirs = detect_key_dirs(all_dirs)

    # Carpetas duplicadas por basename (p.ej. múltiples "docs/")
    duplicated_basenames = [(name, cnt) for name, cnt in basename_counts.items() if cnt > 1]
    duplicated_basenames.sort(key=lambda x: (-x[1], x[0]))

    # Render de árbol
    tree_md = render_tree_md(tree)

    # Construcción del Markdown final
    now = datetime.now()
    ts = now.strftime("%Y-%m-%d %H:%M:%S")

    lines: List[str] = []
    lines.append("# Auditoría de Estructura del Sistema")
    lines.append("")
    lines.append(f"Generado: {ts}")
    lines.append("")

    # Mapa de directorios
    lines.append("## Mapa de Directorios")
    lines.append("")
    lines.append(tree_md)
    lines.append("")

    # Resumen por tipo de archivo
    lines.append("## Resumen por tipo de archivo")
    lines.append("")
    lines.append("Extensión | Conteo")
    lines.append("--- | ---")
    for ext, cnt in sorted(ext_counter.items(), key=lambda x: (-x[1], x[0])):
        lines.append(f"{ext} | {cnt}")
    if not ext_counter:
        lines.append("(sin archivos) | 0")
    lines.append("")

    # Carpetas clave detectadas
    lines.append("## Carpetas clave detectadas")
    lines.append("")
    if key_dirs:
        for path, desc in key_dirs:
            lines.append(f"- `{path}` — {desc}")
    else:
        lines.append("- No se detectaron carpetas clave por patrones predefinidos.")
    lines.append("")

    # Observaciones automáticas
    lines.append("## Observaciones automáticas")
    lines.append("")
    # Directorios vacíos
    if empty_dirs:
        lines.append(f"- Directorios vacíos: {len(empty_dirs)} (mostrando hasta 20)")
        for d in sorted(empty_dirs)[:20]:
            lines.append(f"  - `{d}/`")
    else:
        lines.append("- No se detectaron directorios vacíos.")
    # Carpetas con nombres duplicados
    if duplicated_basenames:
        lines.append(f"- Carpetas con el mismo nombre en múltiples ubicaciones: {len(duplicated_basenames)} (top 20)")
        for name, cnt in duplicated_basenames[:20]:
            lines.append(f"  - `{name}/` aparece {cnt} veces")
    # Carpetas con indicios de legado/duplicado
    if legacy_like:
        lines.append(f"- Carpetas con indicios de legado/backup/dist/tmp: {len(legacy_like)} (mostrando hasta 20)")
        for d in sorted(legacy_like)[:20]:
            lines.append(f"  - `{d}/`")
    lines.append("")

    # Siguiente paso sugerido
    lines.append("## Siguiente paso sugerido")
    lines.append("")
    lines.append(
        "Estimado Reinaldo Capiro: se recomienda priorizar la revisión de (1) `apps/`, `src/` y `components/` para mapear UI/Roles, (2) `docs/` y `content/` para alinear briefing y documentación, y (3) `.github/workflows` para comprender el ciclo de vida CI/CD. A partir de ahí, elaborar un inventario de vistas, layouts y componentes con su matriz de roles/permisos."
    )
    lines.append("")

    md = "\n".join(lines) + "\n"

    with open(OUTPUT_MD, "w", encoding="utf-8") as f:
        f.write(md)

    print("✅ Auditoría completada: archivo AUDITORIA_ESTRUCTURA_SISTEMA.md generado correctamente.")
    print(OUTPUT_MD)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as e:
        print(f"Error durante la auditoría: {e}", file=sys.stderr)
        sys.exit(1)
