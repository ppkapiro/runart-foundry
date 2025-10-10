#!/usr/bin/env python3
"""Inventory generator for MkDocs site builds.

This script scans a directory (defaults to ``apps/briefing/site``) and lists all
HTML files along with their size in bytes and SHA256 checksum. The output is
written as tab-separated values either to STDOUT or to a file specified via
``--output``.
"""
from __future__ import annotations

import argparse
import hashlib
import sys
from pathlib import Path
from typing import Iterable, Iterator, Tuple

BUFFER_SIZE = 1024 * 1024  # 1 MiB


def repo_root() -> Path:
    return Path(__file__).resolve().parents[1]


def default_site_root() -> Path:
    return repo_root() / "apps" / "briefing" / "site"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root",
        default=str(default_site_root()),
        help="Directorio base a escanear (por defecto apps/briefing/site)",
    )
    parser.add_argument(
        "--output",
        help="Archivo TSV de salida; si se omite, escribe en STDOUT",
    )
    return parser.parse_args()


def iter_html_files(root: Path) -> Iterator[Path]:
    yield from sorted(
        (path for path in root.rglob("*.html") if path.is_file()),
        key=lambda path: path.relative_to(root).as_posix(),
    )


def sha256sum(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(BUFFER_SIZE), b""):
            digest.update(chunk)
    return digest.hexdigest()


def build_inventory(root: Path) -> Iterable[Tuple[str, int, str]]:
    for path in iter_html_files(root):
        relative = path.relative_to(root).as_posix()
        size = path.stat().st_size
        checksum = sha256sum(path)
        yield relative, size, checksum


def write_rows(rows: Iterable[Tuple[str, int, str]], handle) -> None:
    for relative, size, checksum in rows:
        handle.write(f"{relative}\t{size}\t{checksum}\n")


def main() -> int:
    args = parse_args()
    root = Path(args.root).resolve()
    if not root.exists() or not root.is_dir():
        sys.stderr.write(f"[list_site_pages] Directorio inválido: {root}\n")
        return 1

    rows = list(build_inventory(root))
    output_path = Path(args.output).resolve() if args.output else None

    if output_path:
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with output_path.open("w", encoding="utf-8", newline="") as handle:
            write_rows(rows, handle)
    else:
        write_rows(rows, sys.stdout)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
