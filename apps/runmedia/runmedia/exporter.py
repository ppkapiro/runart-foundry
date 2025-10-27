import csv
import os
from typing import Any, Dict, List

from .config import EXPORTS_DIR, MEDIA_INDEX_PATH
from .utils import atomic_write_json, load_json


EXPORT_JSON_NAME = "media-index.json"
EXPORT_CSV_NAME = "media-index.csv"


def export_json() -> str:
    index: Dict[str, Any] = load_json(MEDIA_INDEX_PATH)
    os.makedirs(EXPORTS_DIR, exist_ok=True)
    out_path = os.path.join(EXPORTS_DIR, EXPORT_JSON_NAME)
    atomic_write_json(out_path, index)
    return out_path


def export_csv() -> str:
    index: Dict[str, Any] = load_json(MEDIA_INDEX_PATH)
    items: List[Dict[str, Any]] = index.get("items", [])

    os.makedirs(EXPORTS_DIR, exist_ok=True)
    out_path = os.path.join(EXPORTS_DIR, EXPORT_CSV_NAME)

    fields = [
        "id",
        "filename",
        "ext",
        "checksum.sha256",
        "source.path",
        "width",
        "height",
        "metadata.title.es",
        "metadata.title.en",
        "metadata.alt.es",
        "metadata.alt.en",
        "related.projects",
        "related.services",
    ]

    def pick(d: Dict[str, Any], dotted: str) -> Any:
        cur: Any = d
        for part in dotted.split("."):
            if isinstance(cur, dict):
                cur = cur.get(part)
            else:
                cur = None
                break
        return cur

    with open(out_path, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(fields)
        for it in items:
            row = [pick(it, k) for k in fields]
            w.writerow(row)

    return out_path
