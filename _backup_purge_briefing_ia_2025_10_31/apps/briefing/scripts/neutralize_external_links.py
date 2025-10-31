#!/usr/bin/env python3
"""Neutraliza o restaura enlaces internos que apuntan fuera de la carpeta docs/.

Permite alternar entre el estado "neutralizado" (links reemplazados por texto
plano) y el estado "publicado" (links originales restablecidos) empleando un
snapshot almacenado en `_tmp/link_toggle_snapshot.json`.
"""
from __future__ import annotations

import argparse
import datetime as _dt
import json
import os
import re
from collections import defaultdict
from pathlib import Path

DOCS_ROOT = Path(__file__).resolve().parents[1] / "docs"
REPORTS_DIR = Path(__file__).resolve().parents[2] / "audits"
SNAPSHOT_PATH = Path(__file__).resolve().parents[1] / "_tmp" / "link_toggle_snapshot.json"

TRUTHY = {"1", "true", "yes", "on"}

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


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--mode",
        choices=("neutralize", "publish"),
        help="Forzar el modo de ejecución. Por defecto neutraliza; también se puede definir con ENABLE_PUBLISH=1.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Calcula los cambios sin escribir archivos, reportes ni snapshots.",
    )
    return parser.parse_args()


def resolve_mode(args: argparse.Namespace) -> str:
    env_value = os.getenv("ENABLE_PUBLISH", "").strip().lower()
    env_mode = "publish" if env_value in TRUTHY else None
    return args.mode or env_mode or "neutralize"


def should_neutralize(href: str) -> bool:
    return href.startswith(TARGET_PREFIXES)


def neutralize_link(
    md_path: Path,
    match: re.Match[str],
    report_entries: list[str],
    snapshot_entries: list[dict[str, str]],
) -> str:
    prefix, label, href = match.groups()
    if should_neutralize(href):
        replacement = f"`{href}` *(recurso interno no publicado)*"
        report_entries.append(f"{href} => {replacement}")
        snapshot_entries.append(
            {
                "file": str(md_path.relative_to(DOCS_ROOT)),
                "original": match.group(0),
                "replacement": replacement,
            }
        )
        if prefix:
            # Se descarta el prefijo '!' para evitar símbolos residuales.
            return replacement
        return replacement
    return match.group(0)


def process_markdown_file(
    md_path: Path,
    report_entries: list[str],
    snapshot_entries: list[dict[str, str]],
    *,
    dry_run: bool,
) -> bool:
    original = md_path.read_text(encoding="utf-8")
    if not original:
        return False

    def replacer(match: re.Match[str]) -> str:
        return neutralize_link(md_path, match, report_entries, snapshot_entries)

    updated = LINK_PATTERN.sub(replacer, original)

    if updated != original:
        if not dry_run:
            md_path.write_text(updated, encoding="utf-8")
        return True
    return False


def write_report(report_name: str, header: list[str], report_lines: list[str], *, dry_run: bool) -> Path | None:
    if dry_run:
        return None

    REPORTS_DIR.mkdir(parents=True, exist_ok=True)
    report_path = REPORTS_DIR / report_name
    report_path.write_text("\n".join(header + report_lines), encoding="utf-8")
    return report_path


def write_snapshot(payload: dict, *, dry_run: bool) -> None:
    if dry_run:
        return
    SNAPSHOT_PATH.parent.mkdir(parents=True, exist_ok=True)
    SNAPSHOT_PATH.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")


def neutralize(*, dry_run: bool) -> None:
    modified_files: list[str] = []
    report_lines: list[str] = []
    snapshot_entries: list[dict[str, str]] = []

    for md_file in sorted(DOCS_ROOT.rglob("*.md")):
        relative_path = str(md_file.relative_to(DOCS_ROOT))
        file_entries: list[str] = []
        if process_markdown_file(md_file, file_entries, snapshot_entries, dry_run=dry_run):
            modified_files.append(relative_path)
        for entry in file_entries:
            report_lines.append(f"- {relative_path} :: {entry}")

    now = _dt.datetime.now(_dt.timezone.utc)
    report_name = f"ARQ_plus_links_{now.date().isoformat()}.txt"
    if not report_lines:
        report_lines.append("- Sin reemplazos detectados")
    header = [
        "ARQ+ — Neutralización de enlaces internos no publicados",
        f"Fecha: {now.isoformat()}",
        "",
    ]

    report_path = write_report(report_name, header, report_lines, dry_run=dry_run)

    if snapshot_entries:
        write_snapshot(
            {
                "state": "neutralized",
                "generated_at": now.isoformat(),
                "total_entries": len(snapshot_entries),
                "entries": snapshot_entries,
            },
            dry_run=dry_run,
        )

    print("Modo: neutralize")
    if modified_files:
        print("Archivos modificados:")
        for rel_path in modified_files:
            print(f"- {rel_path}")
    else:
        print("Sin modificaciones de archivos.")

    if dry_run:
        print("Ejecución en modo dry-run: no se escribieron cambios ni reportes.")
    elif report_path:
        print(f"Reporte guardado en: {report_path}")
        if snapshot_entries:
            print(f"Snapshot guardado en: {SNAPSHOT_PATH}")
    else:
        print("No se generó reporte.")


def publish(*, dry_run: bool) -> None:
    print("Modo: publish")
    if not SNAPSHOT_PATH.exists():
        print("No se encontró snapshot previo en _tmp/link_toggle_snapshot.json. No hay cambios que revertir.")
        return

    snapshot_data = json.loads(SNAPSHOT_PATH.read_text(encoding="utf-8"))
    entries: list[dict[str, str]] = snapshot_data.get("entries", [])

    if not entries:
        print("El snapshot no contiene entradas guardadas; no se realizaron modificaciones.")
        return

    grouped: dict[str, list[dict[str, str]]] = defaultdict(list)
    for entry in entries:
        grouped[entry["file"]].append(entry)

    modified_files: list[str] = []
    report_lines: list[str] = []
    warnings: list[str] = []

    for rel_path, file_entries in grouped.items():
        md_path = DOCS_ROOT / rel_path
        if not md_path.exists():
            warnings.append(f"- {rel_path} :: archivo no encontrado")
            continue

        original = md_path.read_text(encoding="utf-8")
        updated = original

        for entry in file_entries:
            replacement = entry.get("replacement", "")
            original_md = entry.get("original", "")
            if replacement and replacement in updated:
                updated = updated.replace(replacement, original_md, 1)
                report_lines.append(f"- {rel_path} :: {replacement} => {original_md}")
            else:
                warnings.append(f"- {rel_path} :: marcador no encontrado para {replacement}")

        if updated != original:
            if not dry_run:
                md_path.write_text(updated, encoding="utf-8")
            modified_files.append(rel_path)

    now = _dt.datetime.now(_dt.timezone.utc)
    report_name = f"ARQ_plus_links_publish_{now.date().isoformat()}.txt"
    if not report_lines:
        report_lines.append("- Sin restauraciones aplicadas")
    header = [
        "ARQ+ — Restauración de enlaces internos",
        f"Fecha: {now.isoformat()}",
        "",
    ]

    report_body = report_lines + (["", "Advertencias:"] + warnings if warnings else [])
    report_path = write_report(report_name, header, report_body, dry_run=dry_run)

    if not dry_run:
        write_snapshot(
            {
                "state": "published",
                "restored_at": now.isoformat(),
                "entries": entries,
                "restored_files": modified_files,
                "warnings": warnings,
            },
            dry_run=dry_run,
        )

    if modified_files:
        print("Archivos modificados:")
        for rel_path in modified_files:
            print(f"- {rel_path}")
    else:
        print("Sin modificaciones de archivos.")

    if warnings:
        print("Advertencias:")
        for warning in warnings:
            print(warning)

    if dry_run:
        print("Ejecución en modo dry-run: no se escribieron cambios ni reportes.")
    elif report_path:
        print(f"Reporte guardado en: {report_path}")
        print(f"Snapshot actualizado en: {SNAPSHOT_PATH}")
    else:
        print("No se generó reporte.")


def main() -> None:
    args = parse_args()
    mode = resolve_mode(args)

    if mode == "publish":
        publish(dry_run=args.dry_run)
    else:
        neutralize(dry_run=args.dry_run)


if __name__ == "__main__":
    main()
