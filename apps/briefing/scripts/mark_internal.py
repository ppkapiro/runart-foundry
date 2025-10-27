#!/usr/bin/env python3
"""Scan Markdown docs for access front-matter and enforce .interno tagging."""

from __future__ import annotations

import json
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List

import yaml

ROOT = Path(__file__).resolve().parents[1]
DOCS_DIR = ROOT / "docs"
OUTPUT = DOCS_DIR / "assets" / "access_map.json"


@dataclass
class AccessEntry:
    path: str
    access: List[str]
    internal: bool

    def to_dict(self) -> dict:
        return {
            "path": self.path,
            "access": self.access,
            "internal": self.internal,
        }


def split_front_matter(text: str) -> tuple[dict, str]:
    if not text.startswith("---"):
        return {}, text

    lines = text.splitlines()
    closing = None
    for idx in range(1, len(lines)):
        if lines[idx].strip() == "---":
            closing = idx
            break

    if closing is None:
        return {}, text

    front = "\n".join(lines[1:closing])
    body = "\n".join(lines[closing + 1 :])

    try:
        data = yaml.safe_load(front) or {}
    except yaml.YAMLError:
        # Treat malformed front matter as plain content so legacy docs without YAML blocks do not halt the build.
        return {}, text

    if not isinstance(data, dict):
        data = {}

    return data, body


def normalize_access(values) -> List[str]:
    if values is None:
        return []
    if isinstance(values, str):
        values = [values]
    result: List[str] = []
    for value in values:
        normalized = str(value).strip().lower()
        if not normalized:
            continue
        normalized = normalized.replace(" ", "_")
        result.append(normalized)
    return result


def is_internal_access(access_values: Iterable[str]) -> bool:
    normalized = {value for value in access_values}
    if not normalized:
        return False
    if any(value in {"public", "cliente", "publico", "publica"} for value in normalized):
        return False
    return any(value in {"admin", "equipo", "interno", "team"} for value in normalized)


def collect_entries() -> tuple[List[AccessEntry], List[str]]:
    entries: List[AccessEntry] = []
    missing: List[str] = []

    for md_path in sorted(DOCS_DIR.rglob("*.md")):
        if "site" in md_path.parts:
            continue
        rel_path = md_path.relative_to(DOCS_DIR).as_posix()
        text = md_path.read_text(encoding="utf-8")
        meta, body = split_front_matter(text)
        access_values = normalize_access(meta.get("access"))
        if not access_values:
            continue

        internal = is_internal_access(access_values)
        if internal and ".interno" not in body:
            missing.append(rel_path)

        entries.append(AccessEntry(rel_path, access_values, internal))

    return entries, missing


def write_access_map(entries: Iterable[AccessEntry]) -> None:
  OUTPUT.parent.mkdir(parents=True, exist_ok=True)
  serializable = [entry.to_dict() for entry in sorted(entries, key=lambda e: e.path)]
  OUTPUT.write_text(
    json.dumps(serializable, indent=2, ensure_ascii=False) + "\n",
    encoding="utf-8",
  )


def main() -> None:
    import os
    if os.environ.get("AUTH_MODE", "").lower() == "none":
        # Modo local: generar mapa pero no fallar por faltas de .interno
        entries, _ = collect_entries()
        write_access_map(entries)
        print("[mark_internal] Modo local (AUTH_MODE=none): validaciones de acceso desactivadas.")
        return
    entries, missing = collect_entries()
    write_access_map(entries)

    if missing:
        sys.stderr.write(
            "[mark_internal] Archivos sin marca .interno pese a requerir acceso interno:\n"
        )
        for rel in missing:
            sys.stderr.write(f"  - {rel}\n")
        sys.exit(1)

    print(f"[mark_internal] Mapeo generado ({len(entries)} archivos con access).")


if __name__ == "__main__":
  main()
