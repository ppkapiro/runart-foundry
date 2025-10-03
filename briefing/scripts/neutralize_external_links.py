#!/usr/bin/env python3
"""Neutraliza enlaces internos que apuntan fuera de la carpeta docs/.

Reemplaza enlaces markdown con destinos internos no publicados por texto plano
seguido de una marca aclaratoria. Genera un reporte con los reemplazos.
"""
from __future__ import annotations

import datetime as _dt
import re
from pathlib import Path

DOCS_ROOT = Path(__file__).resolve().parents[1] / "docs"
REPORTS_DIR = Path(__file__).resolve().parents[2] / "audits"

# Patrones que representan rutas internas no publicadas.
TARGET_PREFIXES = (
    "audits/",
    "../audits/",
    "../../audits/",
    "scripts/",
    "../scripts/",
    "../../scripts/",
    "assets/",
    "../assets/",
    "../../assets/",
    "../docs/",
    "../../docs/",
    "briefing/_reports/",
    "../briefing/_reports/",
    "../../briefing/_reports/",
)

LINK_PATTERN = re.compile(r"(!)?\[([^\]]+)\]\(([^)]+)\)")


def should_neutralize(href: str) -> bool:
    return href.startswith(TARGET_PREFIXES)


def neutralize_link(match: re.Match[str], report_entries: list[str]) -> str:
    prefix, label, href = match.groups()
    if should_neutralize(href):
        replacement = f"`{href}` *(recurso interno no publicado)*"
        report_entries.append(f"{href} => {replacement}")
        if prefix:
            # Se descarta el prefijo '!' para evitar símbolos residuales.
            return replacement
        return replacement
    return match.group(0)


def process_markdown_file(md_path: Path, report_entries: list[str]) -> bool:
    original = md_path.read_text(encoding="utf-8")
    if not original:
        return False

    def replacer(match: re.Match[str]) -> str:
        return neutralize_link(match, report_entries)

    updated = LINK_PATTERN.sub(replacer, original)

    if updated != original:
        md_path.write_text(updated, encoding="utf-8")
        return True
    return False


def main() -> None:
    modified_files: list[str] = []
    report_lines: list[str] = []

    for md_file in DOCS_ROOT.rglob("*.md"):
        file_entries: list[str] = []
        if process_markdown_file(md_file, file_entries):
            modified_files.append(str(md_file.relative_to(DOCS_ROOT)))
            for entry in file_entries:
                report_lines.append(f"- {md_file.relative_to(DOCS_ROOT)} :: {entry}")

    timestamp = _dt.date.today().isoformat()
    report_name = f"ARQ_plus_links_{timestamp}.txt"
    report_path = REPORTS_DIR / report_name
    header = [
        "ARQ+ — Neutralización de enlaces internos no publicados",
        f"Fecha: {timestamp}",
        "",
    ]
    report_path.write_text("\n".join(header + report_lines), encoding="utf-8")

    print("Archivos modificados:")
    for rel_path in modified_files:
        print(f"- {rel_path}")
    print(f"Reporte guardado en: {report_path}")


if __name__ == "__main__":
    main()
