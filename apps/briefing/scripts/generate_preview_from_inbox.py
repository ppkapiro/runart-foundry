#!/usr/bin/env python3
"""Generate preview YAML files from inbox JSON without touching the repo."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Tuple, Dict, Any

import yaml
from slugify import slugify


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--input",
        default="briefing/_tmp/preview/inbox.json",
        help="Ruta al archivo JSON descargado del inbox",
    )
    parser.add_argument(
        "--output",
        default="briefing/_tmp/preview_out",
        help="Directorio donde guardar los YAML de vista previa",
    )
    return parser.parse_args()


def load_entries(path: Path) -> list[dict[str, Any]]:
    if not path.exists():
        return []
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return []


def to_yaml(entry: dict[str, Any]) -> Tuple[str, Dict[str, Any]]:
    title = (entry.get("title") or "sin-titulo").strip() or "sin-titulo"
    year = (entry.get("year") or "0000").strip() or "0000"
    slug = slugify(f"{title}-{year}") or "sin-titulo-0000"
    payload = {
        "id": slug,
        "title": title,
        "artist": entry.get("artist", ""),
        "year": year,
        "location": entry.get("location", ""),
        "materials": [],
        "media": {
            "images": [
                {
                    "path": f"assets/{year}/{slug}/img_01.jpg",
                    "alt": "placeholder",
                }
            ]
        },
        "links": [],
        "notes": entry.get("notes", ""),
    }
    return slug, payload


def main() -> None:
    args = parse_args()
    input_path = Path(args.input)
    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)

    entries = load_entries(input_path)
    count = 0
    for entry in entries:
        if not isinstance(entry, dict):
            continue
        slug, payload = to_yaml(entry)
        target = output_dir / f"{slug}.yaml"
        target.write_text(
            yaml.safe_dump(payload, allow_unicode=True, sort_keys=False),
            encoding="utf-8",
        )
        count += 1

    print(f"Generados {count} YAML de vista previa en {output_dir}")


if __name__ == "__main__":
    main()
