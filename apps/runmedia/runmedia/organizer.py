import os
from typing import Any, Dict, List

from .config import LIBRARY_ROOT, MEDIA_INDEX_PATH
from .utils import load_json


def _ensure_dir(path: str) -> None:
    os.makedirs(path, exist_ok=True)


def _safe_symlink(src: str, dst: str) -> None:
    try:
        if os.path.islink(dst) or os.path.exists(dst):
            return
        os.symlink(src, dst)
    except Exception:
        # En entornos sin permisos, ignorar
        pass


def organize(repo_root: str) -> Dict[str, Any]:
    index: Dict[str, Any] = load_json(MEDIA_INDEX_PATH)
    items: List[Dict[str, Any]] = index.get("items", [])

    # Estructura base
    for base in ("projects", "services", "site", "brand", "people", "process", "testimonials", "others"):
        _ensure_dir(os.path.join(LIBRARY_ROOT, base))

    for it in items:
        src_path = (it.get("source") or {}).get("path")
        if not src_path:
            continue
        abs_src = os.path.join(repo_root, src_path)

        rel = it.get("related") or {}
        dst_base = None
        dst_slug = None

        proj = rel.get("projects") or []
        serv = rel.get("services") or []
        if proj:
            dst_base = "projects"
            dst_slug = proj[0]
        elif serv:
            dst_base = "services"
            dst_slug = serv[0]
        else:
            dst_base = "others"
            dst_slug = "misc"

        dst_dir = os.path.join(LIBRARY_ROOT, dst_base, dst_slug)
        _ensure_dir(dst_dir)
        dst = os.path.join(dst_dir, it.get("filename", "image"))
        _safe_symlink(abs_src, dst)

    return index
