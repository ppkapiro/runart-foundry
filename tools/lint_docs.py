#!/usr/bin/env python3
"""Validador ligero para la documentación del monorepo.

Checks:
- mkdocs build --strict (detecta enlaces internos rotos y warnings).
- Referencias --8<-- válidas.
- Encabezado H1 en cada documento de arquitectura.
- Espacios en blanco finales en archivos vigilados.
"""
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CANONICAL_SITE = ("apps/briefing", ROOT / "apps" / "briefing" / "mkdocs.yml")
LEGACY_COMPAT_CONFIG = ROOT / "briefing" / "mkdocs.yml"
LOG_FILE = ROOT / "audits" / "docs_lint.log"

SNIPPET_RE = re.compile(r"--8<--\s*[\"']([^\"']+)[\"']")

WATCH_GLOBS = [
    "docs/architecture/**/*.md",
    "apps/briefing/docs/architecture/**/*.md",
    "briefing/docs/architecture/**/*.md",
    "STATUS.md",
    "CHANGELOG.md",
    "INCIDENTS.md",
]

H1_TARGETS = list((ROOT / "docs" / "architecture").glob("*.md"))


class Report:
    def __init__(self) -> None:
        self.messages: list[str] = []
        self.errors: list[str] = []

    def info(self, message: str) -> None:
        self.messages.append(f"INFO: {message}")

    def warning(self, message: str) -> None:
        self.messages.append(f"WARNING: {message}")

    def error(self, message: str) -> None:
        line = f"ERROR: {message}"
        self.messages.append(line)
        self.errors.append(line)

    def write(self) -> None:
        LOG_FILE.parent.mkdir(parents=True, exist_ok=True)
        LOG_FILE.write_text("\n".join(self.messages) + "\n", encoding="utf-8")

    def exit_code(self) -> int:
        return 1 if self.errors else 0



def run_mkdocs(report: Report) -> None:
    label, config = CANONICAL_SITE
    if not config.exists():
        report.error(f"mkdocs.yml no encontrado ({label}) → {config}")
        return

    if LEGACY_COMPAT_CONFIG.exists():
        report.warning(
            "Se detectó briefing/mkdocs.yml (compat); se omite la build dual hasta 075_cleanup_briefing.md"
        )

    cmd = [sys.executable, "-m", "mkdocs", "build", "--strict", "--config-file", str(config)]
    report.info(f"Ejecutando mkdocs build --strict ({label})")
    proc = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True)
    if proc.stdout.strip():
        report.info(f"mkdocs stdout ({label}):\n{proc.stdout.strip()}")
    if proc.stderr.strip():
        report.info(f"mkdocs stderr ({label}):\n{proc.stderr.strip()}")
    if proc.returncode != 0:
        report.error(f"mkdocs build --strict falló ({label})")


def check_snippets(report: Report) -> None:
    report.info("Validando referencias --8<--")
    for md_path in ROOT.rglob("*.md"):
        text = md_path.read_text(encoding="utf-8", errors="ignore")
        for match in SNIPPET_RE.finditer(text):
            rel = match.group(1)
            target = (ROOT / rel).resolve()
            if not target.exists():
                report.error(f"Snippet inexistente en {md_path.relative_to(ROOT)} → {rel}")


def check_h1(report: Report) -> None:
    report.info("Comprobando encabezados H1 en docs/architecture")
    for path in H1_TARGETS:
        lines = path.read_text(encoding="utf-8", errors="ignore").splitlines()
        first_content = next((ln for ln in lines if ln.strip()), "")
        if not first_content.startswith("# "):
            report.error(f"Falta encabezado H1 al inicio en {path.relative_to(ROOT)}")


def check_trailing_spaces(report: Report) -> None:
    report.info("Buscando espacios finales en archivos vigilados")
    for pattern in WATCH_GLOBS:
        for path in ROOT.glob(pattern):
            if not path.is_file():
                continue
            for idx, line in enumerate(path.read_text(encoding="utf-8", errors="ignore").splitlines()):
                if line.endswith(" ") or line.endswith("\t"):
                    report.error(
                        f"Espacio sobrante en {path.relative_to(ROOT)}:{idx + 1}"
                    )


def main() -> int:
    report = Report()
    run_mkdocs(report)
    check_snippets(report)
    check_h1(report)
    check_trailing_spaces(report)
    report.write()
    for message in report.messages:
        print(message)
    return report.exit_code()


if __name__ == "__main__":
    sys.exit(main())
