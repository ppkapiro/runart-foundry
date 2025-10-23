#!/usr/bin/env python3
# Soft validator for docs/ live+archive: checks frontmatter and internal links
from __future__ import annotations
import re
from pathlib import Path
from datetime import datetime

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"
LIVE = DOCS / "live"
ARCH = DOCS / "archive"
REPORT = DOCS / "_meta" / "validators_report_soft.md"

FRONTMATTER_RE = re.compile(r"^---\n.*?\n---\n", re.DOTALL)
LINK_RE = re.compile(r"\[[^\]]+\]\(([^)]+\.md)\)")

warnings: list[tuple[str,str,int,str]] = []  # (file, type, line, suggestion)


def has_frontmatter(text: str) -> bool:
    return bool(FRONTMATTER_RE.match(text))


def check_file(path: Path):
    try:
        text = path.read_text(encoding="utf-8")
    except Exception as e:
        warnings.append((str(path), "read_error", 0, f"{e}"))
        return

    if not has_frontmatter(text):
        warnings.append((str(path.relative_to(ROOT)), "missing_frontmatter", 1, "Añadir bloque YAML estándar según docs/_meta/frontmatter_template.md"))

    # Link checks (relative .md only)
    for i, line in enumerate(text.splitlines(), start=1):
        for m in LINK_RE.finditer(line):
            target = m.group(1)
            if target.startswith("http"):
                continue
            target_path = (path.parent / target).resolve()
            if not target_path.exists():
                warnings.append((str(path.relative_to(ROOT)), "broken_link", i, f"Crear/corregir enlace relativo: {target}"))


def scan_tree(base: Path):
    if not base.exists():
        return
    for p in base.rglob("*.md"):
        check_file(p)


def write_report():
    REPORT.parent.mkdir(parents=True, exist_ok=True)
    lines = []
    lines.append("---")
    lines.append("generated_by: copilot")
    lines.append("phase: pr-03-curaduria-activa")
    lines.append(f"date: {datetime.now().isoformat(timespec='seconds')}")
    lines.append("repo: runart-foundry")
    lines.append("---\n")
    lines.append("# Reporte validadores (modo soft)\n")
    lines.append("## Resumen\n")
    lines.append(f"Total warnings: {len(warnings)}")
    lines.append("Errores críticos: 0 (modo soft)\n")
    lines.append("## Detalle\n")
    lines.append("archivo | tipo de warning | línea | acción sugerida")
    lines.append("--- | --- | --- | ---")
    for f, t, n, s in warnings:
        lines.append(f"{f} | {t} | {n} | {s}")
    REPORT.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main():
    scan_tree(LIVE)
    scan_tree(ARCH)
    write_report()
    print(f"Soft validators report written to {REPORT.relative_to(ROOT)} with {len(warnings)} warnings.")


if __name__ == "__main__":
    main()
