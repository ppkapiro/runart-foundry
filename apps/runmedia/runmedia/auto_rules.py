import os
import re
from collections import Counter
from typing import Any, Dict, Iterable, List, Set

import yaml

from .config import ASSOCIATION_RULES_PATH, MEDIA_INDEX_PATH
from .utils import load_json


STOPWORDS: Set[str] = {
    "runart", "foundry", "run", "art", "studio", "image", "img", "photo",
    "the", "and", "of", "de", "la", "el", "los", "las", "en", "para",
    "bronze", "casting", "foundry", "fundicion", "service", "services",
    "wp", "content", "uploads", "thumb", "gallery", "hero", "header",
    "banner", "slide", "slides", "final", "edit", "copy", "small", "large",
    "medium", "webp", "avif", "jpg", "jpeg", "png",
}

TOKEN_RE = re.compile(r"[\W_]+", re.UNICODE)


def _tokenize(name: str) -> List[str]:
    base = os.path.splitext(os.path.basename(name))[0]
    toks = [t for t in TOKEN_RE.split(base.lower()) if t]
    return [t for t in toks if t not in STOPWORDS and not t.isdigit() and len(t) > 2]


def _iter_names_from_index(items: List[Dict[str, Any]]) -> Iterable[str]:
    for it in items:
        yield it.get("filename", "")
        src = (it.get("source") or {}).get("path") or ""
        if src:
            yield src


def build_auto_rules(min_freq: int = 20) -> Dict[str, Any]:
    idx = load_json(MEDIA_INDEX_PATH)
    items: List[Dict[str, Any]] = idx.get("items", [])

    counter: Counter[str] = Counter()
    for name in _iter_names_from_index(items):
        for tok in _tokenize(name):
            counter[tok] += 1

    # Filtrar tokens frecuentes como candidatos a "projects"
    candidates = [tok for tok, cnt in counter.most_common() if cnt >= min_freq]

    projects: Dict[str, List[str]] = {}
    for tok in candidates:
        # slug candidato = token
        slug = tok
        patterns = [tok, f"-{tok}-", f"_{tok}_"]
        projects[slug] = list({p for p in patterns})

    # Servicios básicos (semillas genéricas)
    services = {
        "bronze-casting": ["bronze", "fundicion", "foundry", "casting"],
    }

    # Cargar reglas existentes y fusionar
    existing: Dict[str, Any] = {}
    if os.path.exists(ASSOCIATION_RULES_PATH):
        with open(ASSOCIATION_RULES_PATH, "r", encoding="utf-8") as f:
            existing = yaml.safe_load(f) or {}

    merged = {
        "projects": {**(existing.get("projects") or {}), **projects},
        "services": {**(existing.get("services") or {}), **services},
        "posts": existing.get("posts") or {},
        "pages": existing.get("pages") or {},
    }

    # Guardar yaml fusionado
    os.makedirs(os.path.dirname(ASSOCIATION_RULES_PATH), exist_ok=True)
    with open(ASSOCIATION_RULES_PATH, "w", encoding="utf-8") as f:
        yaml.safe_dump(merged, f, allow_unicode=True, sort_keys=True)

    return merged
