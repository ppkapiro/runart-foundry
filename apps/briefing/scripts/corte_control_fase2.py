#!/usr/bin/env python3
"""Genera el reporte de corte de control para la Fase 2."""
from __future__ import annotations

import json
import sys
from collections import Counter
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, Iterable, List

try:
    import requests
except ImportError:  # pragma: no cover
    print(
        "[ERROR] La biblioteca 'requests' es necesaria para ejecutar este script."
        " Instálala con 'pip install requests'.",
        file=sys.stderr,
    )
    raise
import yaml

ROOT = Path(__file__).resolve().parents[2]
PROJECTS_DIR = ROOT / "docs" / "projects"
PROJECTS_EN_DIR = PROJECTS_DIR / "en"
SCHEMA_EXCLUDES = {"_template.yaml", "schema.yaml"}
TMP_DIR = ROOT / "briefing" / "_tmp"
JSON_OUTPUT = TMP_DIR / "corte_fase2.json"
MD_OUTPUT = ROOT / "briefing" / "_reports" / "corte_control_fase2.md"
PRESSKIT_DIR = ROOT / "briefing" / "site" / "presskit"
PDF_FILES = {
    "presskit_v0_ES.pdf": "Press-kit v0 ES",
    "presskit_v0_EN.pdf": "Press-kit v0 EN",
    "presskit_v1_ES.pdf": "Press-kit v1 ES",
    "presskit_v1_EN.pdf": "Press-kit v1 EN",
}
HEADERS = {"User-Agent": "RUNArtFoundry-CorteFase2/1.0"}
TIMEOUT = 5
DUMMY_BYTES_THRESHOLD = 200 * 1024  # 200 KB


@dataclass
class ProjectMetrics:
    slug: str
    title: str
    year: str
    images_real: int = 0
    images_dummy: int = 0
    images_missing: int = 0
    missing_paths: List[str] = field(default_factory=list)
    links_ok: int = 0
    links_alert: int = 0
    link_alert_urls: List[str] = field(default_factory=list)

    @property
    def has_dummy(self) -> bool:
        return self.images_dummy > 0

    @property
    def has_link_alert(self) -> bool:
        return self.links_alert > 0

    @property
    def has_missing_images(self) -> bool:
        return self.images_missing > 0


def iter_project_files() -> Iterable[Path]:
    for path in sorted(PROJECTS_DIR.glob("*.yaml")):
        if path.name in SCHEMA_EXCLUDES:
            continue
        yield path


def load_yaml(path: Path) -> Dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        data = yaml.safe_load(handle) or {}
    if not isinstance(data, dict):
        raise ValueError(f"El archivo {path} no contiene un diccionario de datos válido")
    return data


def classify_image(path_str: str, alt: str) -> Dict[str, Any]:
    alt = alt or ""
    image_path = (ROOT / path_str).resolve()
    result = {
        "exists": image_path.exists(),
        "size": None,
        "is_dummy": False,
        "classified": "missing",
    }
    if not image_path.exists() or not image_path.is_file():
        return result

    size = image_path.stat().st_size
    result["size"] = size
    filename = image_path.name.lower()
    alt_dummy = "dummy" in alt.lower()
    name_dummy = "img_0" in filename

    is_dummy = (alt_dummy or name_dummy) and size <= DUMMY_BYTES_THRESHOLD
    result["is_dummy"] = is_dummy
    result["classified"] = "dummy" if is_dummy else "real"
    return result


def check_link(url: str, session: requests.Session) -> bool:
    if not url:
        return False
    try:
        response = session.head(url, allow_redirects=True, timeout=TIMEOUT, headers=HEADERS)
        if response.status_code == 405:  # Method not allowed
            response = session.get(url, allow_redirects=True, timeout=TIMEOUT, headers=HEADERS)
        return 200 <= response.status_code < 400
    except requests.RequestException:
        return False


def inspect_projects() -> Dict[str, Any]:
    metrics: List[ProjectMetrics] = []
    per_year = Counter()
    total_images_real = 0
    total_images_dummy = 0
    missing_assets: List[str] = []

    total_links_ok = 0
    total_links_alert = 0

    session = requests.Session()

    for path in iter_project_files():
        data = load_yaml(path)
        slug = data.get("id") or path.stem
        title = data.get("title") or slug
        year = str(data.get("year") or "0000")
        per_year[year] += 1

        project = ProjectMetrics(slug=slug, title=title, year=year)

        media = data.get("media") or {}
        images = media.get("images") or []
        for image in images:
            if not isinstance(image, dict):
                continue
            path_str = image.get("path")
            if not path_str:
                continue
            classification = classify_image(path_str, image.get("alt") or "")
            status = classification["classified"]
            if status == "real":
                project.images_real += 1
                total_images_real += 1
            elif status == "dummy":
                project.images_dummy += 1
                total_images_dummy += 1
            else:
                project.images_missing += 1
                missing_assets.append(path_str)
                project.missing_paths.append(path_str)

        links = data.get("links") or []
        for link in links:
            if not isinstance(link, dict):
                continue
            url = (link.get("url") or "").strip()
            if not url:
                continue
            ok = check_link(url, session)
            if ok:
                project.links_ok += 1
                total_links_ok += 1
            else:
                project.links_alert += 1
                total_links_alert += 1
                project.link_alert_urls.append(url)

        metrics.append(project)

    pdf_status = {}
    for filename, label in PDF_FILES.items():
        pdf_path = PRESSKIT_DIR / filename
        pdf_status[label] = "OK" if pdf_path.exists() else "FAIL"

    result = {
        "generated_at": datetime.utcnow().isoformat() + "Z",
        "projects_total": len(metrics),
        "per_year": dict(sorted(per_year.items())),
        "images": {
            "real": total_images_real,
            "dummy": total_images_dummy,
            "missing_paths": sorted(set(missing_assets)),
        },
        "links": {
            "ok": total_links_ok,
            "alerts": total_links_alert,
        },
        "pdf_status": pdf_status,
        "projects": [project.__dict__ for project in metrics],
    }
    return result


def build_markdown(data: Dict[str, Any]) -> str:
    today = datetime.utcnow().date().isoformat()
    pdf_lines = [f"{label}: {status}" for label, status in data["pdf_status"].items()]
    dummy_projects = [p["slug"] for p in data["projects"] if p["images_dummy"] > 0]
    link_alert_projects = [p["slug"] for p in data["projects"] if p["links_alert"] > 0]
    missing_image_projects = [p["slug"] for p in data["projects"] if p["images_missing"] > 0]

    resumen = [
        f"- Fichas totales: {data['projects_total']}",
        f"- Imágenes: {data['images']['real']} reales / {data['images']['dummy']} dummy",
        f"- Enlaces externos válidos: {data['links']['ok']} / con alerta: {data['links']['alerts']}",
        "- PDFs publicados: "
        + ", ".join([f"{line}"
                      for line in pdf_lines])
    ]

    detalle_lines = []
    for project in data["projects"]:
        detalle_lines.append(
            "- {slug} — Año {year} — Imágenes: r={real}, d={dummy}, m={missing} — Links OK={ok}, Alertas={alert}".format(
                slug=project["slug"],
                year=project["year"],
                real=project["images_real"],
                dummy=project["images_dummy"],
                missing=project["images_missing"],
                ok=project["links_ok"],
                alert=project["links_alert"],
            )
        )

    acciones = [
        "- Reemplazar imágenes dummy en: "
        + (", ".join(dummy_projects) if dummy_projects else "N/A"),
        "- Corregir/confirmar enlaces: "
        + (", ".join(link_alert_projects) if link_alert_projects else "N/A"),
        "- Ejecutar build/deploy si faltan PDFs: "
        + (", ".join([label for label, status in data["pdf_status"].items() if status != "OK"]) or "N/A"),
    "- Revisar assets faltantes en: "
    + (", ".join(missing_image_projects) if missing_image_projects else "N/A"),
    ]

    anexos = ["- Conteo por año:"]
    for year, count in data["per_year"].items():
        anexos.append(f"  - {year}: {count}")
    missing_paths = data["images"]["missing_paths"]
    anexos.append("- Listado de rutas faltantes:")
    if missing_paths:
        for path_str in missing_paths:
            anexos.append(f"  - {path_str}")
    else:
        anexos.append("  - Sin incidencias")

    lines = [
        f"# Corte de Control — Fase 2 ({today})",
        "",
        "**Resumen ejecutivo**",
        *resumen,
        "",
        "**Detalle por ficha**",
        *detalle_lines,
        "",
        "**Acciones recomendadas**",
        *acciones,
        "",
        "**Anexos**",
        *anexos,
        "",
    ]
    return "\n".join(lines)


def ensure_tmp_dir() -> None:
    TMP_DIR.mkdir(parents=True, exist_ok=True)


def main() -> None:
    ensure_tmp_dir()
    data = inspect_projects()

    with JSON_OUTPUT.open("w", encoding="utf-8") as json_file:
        json.dump(data, json_file, indent=2, ensure_ascii=False)

    markdown = build_markdown(data)
    MD_OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    MD_OUTPUT.write_text(markdown, encoding="utf-8")

    print(f"Corte de control generado en {JSON_OUTPUT} y {MD_OUTPUT}")


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:  # pragma: no cover
        print(f"[ERROR] {exc}", file=sys.stderr)
        sys.exit(1)
