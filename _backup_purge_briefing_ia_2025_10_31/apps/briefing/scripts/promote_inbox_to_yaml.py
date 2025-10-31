#!/usr/bin/env python3
"""Promote inbox JSON entries to preliminary YAML fichas."""
from __future__ import annotations

import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List

from ruamel.yaml import YAML
from ruamel.yaml.scalarstring import LiteralScalarString
from slugify import slugify

INPUT_DEFAULT = Path("briefing/_tmp/inbox.json")
PROJECTS_ES_DIR = Path("docs/projects")
PROJECTS_EN_DIR = PROJECTS_ES_DIR / "en"
ASSETS_DIR = Path("assets")

yaml = YAML()
yaml.indent(mapping=2, sequence=4, offset=2)
yaml.default_flow_style = False


@dataclass
class PromotionResult:
    created: List[str]
    skipped: List[str]

    def summary(self) -> str:
        return (
            f"Promoción completada — creados: {len(self.created)}, "
            f"omitidos: {len(self.skipped)}"
        )


def load_entries(path: Path) -> List[Dict]:
    if not path.exists():
        print(f"[WARN] No se encontró el archivo de entrada: {path}", file=sys.stderr)
        return []
    with path.open("r", encoding="utf-8") as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError as exc:
            raise SystemExit(f"No se pudo parsear JSON: {exc}") from exc
    if not isinstance(data, list):
        raise SystemExit("El JSON debe ser una lista de objetos")
    return data


def ensure_output_dirs(year: str, slug: str) -> Path:
    PROJECTS_ES_DIR.mkdir(parents=True, exist_ok=True)
    PROJECTS_EN_DIR.mkdir(parents=True, exist_ok=True)
    asset_path = ASSETS_DIR / year / slug
    asset_path.mkdir(parents=True, exist_ok=True)
    gitkeep = asset_path / ".gitkeep"
    if not gitkeep.exists():
        gitkeep.touch()
    return asset_path


def unique_slug(base_slug: str) -> str:
    slug = base_slug
    counter = 2
    while (PROJECTS_ES_DIR / f"{slug}.yaml").exists() or (PROJECTS_EN_DIR / f"{slug}.yaml").exists():
        slug = f"{base_slug}-v{counter}"
        counter += 1
    return slug


def parse_year(raw: str | None) -> str:
    raw = (raw or "").strip()
    if not raw:
        return "0000"
    match = re.search(r"(\d{4})", raw)
    return match.group(1) if match else "0000"


def parse_materials(raw: str | None) -> List[Dict[str, str]]:
    raw = (raw or "").strip()
    if not raw:
        return [{"alloy": "", "finish": ""}]
    if "," in raw:
        parts = [p.strip() for p in raw.split(",") if p.strip()]
        if not parts:
            return [{"alloy": "", "finish": ""}]
        alloy = parts[0]
        finish = ", ".join(parts[1:]) if len(parts) > 1 else ""
        return [{"alloy": alloy, "finish": finish}]
    return [{"alloy": raw, "finish": ""}]


def parse_dimensions(raw: str | None) -> Dict[str, float]:
    dims = {"height_cm": 0, "width_cm": 0, "depth_cm": 0}
    if not raw:
        return dims
    numbers = re.findall(r"[0-9]+(?:[.,][0-9]+)?", raw)
    values: List[float] = []
    for num in numbers[:3]:
        try:
            values.append(float(num.replace(",", ".")))
        except ValueError:
            values.append(0.0)
    while len(values) < 3:
        values.append(0.0)
    dims["height_cm"], dims["width_cm"], dims["depth_cm"] = values[:3]
    return dims


def parse_links(raw: str | None) -> List[Dict[str, str]]:
    raw = (raw or "").strip()
    if not raw:
        return []
    urls = re.findall(r"https?://[^\s]+", raw)
    if not urls:
        urls = [raw]
    return [{"label": "Referencia", "url": url} for url in urls]


def parse_testimony(raw: str | None) -> Dict[str, str]:
    raw = (raw or "").strip()
    if not raw:
        return {"author": "", "quote": ""}
    if ":" in raw:
        author, quote = raw.split(":", 1)
        return {"author": author.strip(), "quote": quote.strip()}
    return {"author": "", "quote": raw}


def build_notes(notes: str | None, otros: str | None) -> str | LiteralScalarString:
    notes = (notes or "").strip()
    otros = (otros or "").strip()
    lines: List[str] = []
    if notes:
        lines.append(notes)
    if otros:
        lines.append("otros_campos:")
        for line in otros.splitlines():
            cleaned = line.strip()
            if cleaned:
                lines.append(f"  - {cleaned}")
    if not lines:
        return ""
    text = "\n".join(lines)
    if "\n" in text:
        return LiteralScalarString(text)
    return text


def collaborators_from_text(raw: str | None) -> List[str]:
    raw = (raw or "").strip()
    if not raw:
        return []
    parts = [item.strip() for item in re.split(r",|;|\n", raw) if item.strip()]
    return parts


def promote_entry(entry: Dict, result: PromotionResult) -> None:
    title = (entry.get("title") or "").strip()
    if not title:
        result.skipped.append("<sin título>")
        return
    year = parse_year(entry.get("year"))
    base_slug = slugify(f"{title}-{year}" or title)
    if not base_slug:
        base_slug = slugify(title) or "proyecto"
    slug = unique_slug(base_slug)

    ensure_output_dirs(year, slug)

    artist = (entry.get("artist") or "").strip()
    location = (entry.get("location") or "").strip()
    materials = parse_materials(entry.get("materials"))
    dimensions = parse_dimensions(entry.get("dimensions"))
    process_text = (entry.get("process") or "").strip()
    credits_text = (entry.get("credits") or "").strip()
    links = parse_links(entry.get("links"))
    testimony = parse_testimony(entry.get("testimony"))
    notes_value = build_notes(entry.get("notes"), entry.get("otros"))

    es_data = {
        "id": slug,
        "title": title,
        "artist": artist,
        "year": year,
        "location": location,
        "materials": materials,
        "dimensions": dimensions,
        "edition": {
            "type": "",
            "size": "",
        },
        "process": {
            "modeling": process_text,
            "molding": "",
            "casting": "",
            "patina": "",
            "mounting": "",
        },
        "credits": {
            "foundry": credits_text or "RUN Art Foundry",
            "lead": "",
            "collaborators": collaborators_from_text(entry.get("credits")),
        },
        "media": {
            "images": [
                {
                    "path": f"assets/{year}/{slug}/img_01.jpg",
                    "alt": "Imagen generada desde inbox (placeholder)",
                },
                {
                    "path": f"assets/{year}/{slug}/img_02.jpg",
                    "alt": "Imagen generada desde inbox (placeholder)",
                },
            ],
            "video": [],
        },
        "links": links,
        "testimony": testimony,
        "notes": notes_value,
    }

    es_path = PROJECTS_ES_DIR / f"{slug}.yaml"
    with es_path.open("w", encoding="utf-8") as f:
        yaml.dump(es_data, f)

    en_stub = {
        "id": slug,
        "title": title,
        "artist": artist,
        "year": year,
        "location": location,
        "notes": "Auto-generated stub from inbox promotion.",
    }
    en_path = PROJECTS_EN_DIR / f"{slug}.yaml"
    with en_path.open("w", encoding="utf-8") as f:
        yaml.dump(en_stub, f)

    result.created.append(slug)


def main(argv: List[str]) -> None:
    input_path = Path(argv[1]) if len(argv) > 1 else INPUT_DEFAULT
    entries = load_entries(input_path)
    if not entries:
        print("No hay entradas que promover.")
        return
    result = PromotionResult(created=[], skipped=[])
    for entry in entries:
        if not isinstance(entry, dict):
            result.skipped.append(str(entry))
            continue
        promote_entry(entry, result)
    if result.skipped:
        print("Omitidos:")
        for item in result.skipped:
            print(f" - {item}")
    print(result.summary())


if __name__ == "__main__":
    main(sys.argv)
