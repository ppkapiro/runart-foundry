import csv
import os
from typing import Any, Dict, List

from .config import EXPORTS_DIR, MEDIA_INDEX_PATH
from .utils import atomic_write_json, load_json


EXPORT_JSON_NAME = "media-index.json"
EXPORT_CSV_NAME = "media-index.csv"
EXPORT_ALT_SUGG_NAME = "alt_suggestions.csv"


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


def export_alt_suggestions() -> str:
    index: Dict[str, Any] = load_json(MEDIA_INDEX_PATH)
    items: List[Dict[str, Any]] = index.get("items", [])

    os.makedirs(EXPORTS_DIR, exist_ok=True)
    out_path = os.path.join(EXPORTS_DIR, EXPORT_ALT_SUGG_NAME)

    with open(out_path, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["id", "filename", "project", "service", "suggestion_es", "suggestion_en"])
        for it in items:
            alt = ((it.get("metadata") or {}).get("alt") or {})
            if alt.get("es") or alt.get("en"):
                continue
            rel = it.get("related") or {}
            proj = (rel.get("projects") or [None])[0]
            serv = (rel.get("services") or [None])[0]
            base = os.path.splitext(it.get("filename", ""))[0].replace("-", " ").replace("_", " ")
            if proj:
                sugg_es = f"Proyecto {proj}: {base}"
                sugg_en = f"Project {proj}: {base}"
            elif serv:
                sugg_es = f"Servicio {serv}: {base}"
                sugg_en = f"Service {serv}: {base}"
            else:
                sugg_es = f"RUN Art Foundry: {base}"
                sugg_en = f"RUN Art Foundry: {base}"
            w.writerow([it.get("id"), it.get("filename"), proj or "", serv or "", sugg_es, sugg_en])

    return out_path
