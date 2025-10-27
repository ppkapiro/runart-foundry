import os
from typing import Any, Dict, List, Tuple

from .config import MEDIA_INDEX_PATH, REPORTS_DIR
from .utils import load_json, now_iso


def verify() -> Tuple[Dict[str, Any], Dict[str, Any]]:
    index: Dict[str, Any] = load_json(MEDIA_INDEX_PATH)
    items: List[Dict[str, Any]] = index.get("items", [])

    by_checksum: Dict[str, List[Dict[str, Any]]] = {}
    orphans: List[Dict[str, Any]] = []
    missing_alt: List[Dict[str, Any]] = []

    for it in items:
        chk = (it.get("checksum") or {}).get("sha256")
        by_checksum.setdefault(chk, []).append(it)

        rel = it.get("related") or {}
        if not any(rel.get(k) for k in ("projects", "services", "posts", "pages")):
            orphans.append(it)

        alt = ((it.get("metadata") or {}).get("alt") or {})
        if not (alt.get("es") or alt.get("en")):
            missing_alt.append(it)

    duplicates = [v for v in by_checksum.values() if len(v) > 1]

    summary = {
        "total": len(items),
        "orphans": len(orphans),
        "missing_alt": len(missing_alt),
        "duplicate_groups": len(duplicates),
    }

    # Guardar reporte ligero
    os.makedirs(REPORTS_DIR, exist_ok=True)
    report_path = os.path.join(REPORTS_DIR, f"runmedia_verify_{now_iso().replace(':','').replace('-','')}.md")
    with open(report_path, "w", encoding="utf-8") as f:
        f.write("# RunMedia Verify Report\n\n")
        f.write(f"Generado: {now_iso()}\n\n")
        f.write(f"- Total imágenes: {summary['total']}\n")
        f.write(f"- Huérfanas: {summary['orphans']}\n")
        f.write(f"- Sin alt (ES/EN): {summary['missing_alt']}\n")
        f.write(f"- Grupos duplicados: {summary['duplicate_groups']}\n")

    return summary, {"orphans": orphans, "missing_alt": missing_alt, "duplicates": duplicates}
