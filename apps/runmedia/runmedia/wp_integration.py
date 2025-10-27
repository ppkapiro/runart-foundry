import os
from typing import Any, Dict, List, Tuple

from .config import EXPORTS_DIR, MEDIA_INDEX_PATH
from .utils import load_json
import csv

ENV_URL = "RUNMEDIA_WP_URL"
ENV_USER = "RUNMEDIA_WP_USER"
ENV_PASS = "RUNMEDIA_WP_PASS"  # puede ser app-password


def plan_alt_updates() -> str:
    idx: Dict[str, Any] = load_json(MEDIA_INDEX_PATH)
    items: List[Dict[str, Any]] = idx.get("items", [])

    os.makedirs(EXPORTS_DIR, exist_ok=True)
    out_path = os.path.join(EXPORTS_DIR, "wp_alt_updates.csv")

    with open(out_path, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["id", "filename", "suggested_alt_es", "suggested_alt_en", "project", "service"]) 
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
            w.writerow([it.get("id"), it.get("filename"), sugg_es, sugg_en, proj or "", serv or ""]) 

    return out_path


def get_env_credentials() -> Tuple[str, str, str]:
    url = os.environ.get(ENV_URL, "")
    user = os.environ.get(ENV_USER, "")
    pwd = os.environ.get(ENV_PASS, "")
    return url, user, pwd


def sync_alt_via_rest(dry_run: bool = True) -> Dict[str, Any]:
    """Borrador: preparar payloads para WP REST; requiere credenciales por ENV.
    No ejecuta llamadas si dry_run=True.
    """
    url, user, pwd = get_env_credentials()
    if not (url and user and pwd):
        return {"ok": False, "reason": "Missing env credentials", "env": {ENV_URL: bool(url), ENV_USER: bool(user), ENV_PASS: bool(pwd)}}
    # Nota: Implementación futura. Aquí se construiría la tabla id->media_id WP y updates de alt.
    return {"ok": True, "dry_run": dry_run, "updated": 0}
