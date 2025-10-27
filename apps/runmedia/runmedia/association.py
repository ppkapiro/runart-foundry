import os
import re
from typing import Any, Dict, List

import yaml

from .config import ASSOCIATION_RULES_PATH, MEDIA_INDEX_PATH
from .utils import atomic_write_json, load_json


def load_rules() -> Dict[str, Any]:
    if not os.path.exists(ASSOCIATION_RULES_PATH):
        return {"projects": {}, "services": {}, "posts": {}, "pages": {}}
    with open(ASSOCIATION_RULES_PATH, "r", encoding="utf-8") as f:
        return yaml.safe_load(f) or {}


def _match_any(patterns: List[str], text: str) -> bool:
    for p in patterns:
        try:
            if re.search(p, text, flags=re.IGNORECASE):
                return True
        except re.error:
            # fallback substring
            if p.lower() in text.lower():
                return True
    return False


def associate(repo_root: str) -> Dict[str, Any]:
    index: Dict[str, Any] = load_json(MEDIA_INDEX_PATH)
    items: List[Dict[str, Any]] = index.get("items", [])
    rules = load_rules()

    # Reglas: dict con listas de patrones por slug
    # {
    #   projects: { slug: ["pattern1", "pattern2"], ... },
    #   services: { slug: ["bronze", "fundicion"], ... }
    # }

    for it in items:
        src_path = (it.get("source") or {}).get("path") or ""
        haystack = f"{it.get('filename','')} {src_path}"
        rel = it.setdefault("related", {"projects": [], "services": [], "posts": [], "pages": []})

        for cat in ("projects", "services", "posts", "pages"):
            cat_rules: Dict[str, List[str]] = (rules.get(cat) or {})
            for slug, patterns in cat_rules.items():
                if _match_any(patterns or [], haystack):
                    lst = rel.setdefault(cat, [])
                    if slug not in lst:
                        lst.append(slug)

    atomic_write_json(MEDIA_INDEX_PATH, index)
    return index
