import os
from typing import Any, Dict, Iterable, List

from .config import MEDIA_INDEX_PATH
from .utils import IMAGE_EXTS, atomic_write_json, load_json, now_iso, read_image_size, relpath_under, sha256_file


def _iter_image_files(roots: Iterable[str]) -> Iterable[str]:
    seen = set()
    for root in roots:
        if not root or not os.path.exists(root):
            continue
        for dirpath, _dirnames, filenames in os.walk(root):
            for name in filenames:
                ext = os.path.splitext(name)[1].lower()
                if ext in IMAGE_EXTS:
                    full = os.path.join(dirpath, name)
                    if full not in seen:
                        seen.add(full)
                        yield full


def _existing_items_by_checksum(index: Dict[str, Any]) -> Dict[str, Dict[str, Any]]:
    items = index.get("items", [])
    by_sum: Dict[str, Dict[str, Any]] = {}
    for it in items:
        chk = (it.get("checksum") or {}).get("sha256")
        if chk:
            by_sum[chk] = it
    return by_sum


def build_index(repo_root: str, roots: List[str]) -> Dict[str, Any]:
    index: Dict[str, Any] = load_json(MEDIA_INDEX_PATH)
    version = index.get("version", 1)
    items: List[Dict[str, Any]] = index.get("items", [])
    by_checksum = _existing_items_by_checksum(index)

    for path in _iter_image_files(roots):
        try:
            checksum = sha256_file(path)
        except Exception:
            continue
        if checksum in by_checksum:
            # ya existe, saltar (idempotente)
            continue

        rel = relpath_under(repo_root, path)
        size = read_image_size(path)
        width, height = (size if size else (None, None))

        item: Dict[str, Any] = {
            "id": checksum[:12],
            "filename": os.path.basename(path),
            "ext": os.path.splitext(path)[1].lower().lstrip("."),
            "checksum": {"sha256": checksum},
            "source": {"origin": "repo", "path": rel},
            "logical_path": None,
            "created_at": None,
            "width": width,
            "height": height,
            "ratio": None,
            "language": [],
            "metadata": {
                "title": {"es": "", "en": ""},
                "alt": {"es": "", "en": ""},
                "description": {"es": "", "en": ""},
                "shot_type": None,
                "tags": [],
                "copyright": {
                    "holder": "RUN Art Foundry",
                    "license": "All Rights Reserved",
                    "credits": "",
                },
            },
            "related": {"projects": [], "services": [], "posts": [], "pages": []},
            "primary_usage": [],
            "variants": {"webp": False, "avif": False},
            "sizes": {},
            "notes": "",
        }
        items.append(item)
        by_checksum[checksum] = item

    out = {"version": version, "generated_at": now_iso(), "items": items}
    atomic_write_json(MEDIA_INDEX_PATH, out)
    return out
