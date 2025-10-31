#!/usr/bin/env python3
"""
FASE 3.E — Verificación REST en Staging y decisión A/B

Uso:
  python tools/fase3e_verify_rest.py --staging-url https://staging.example.com \
      --header "X-WP-Nonce: <nonce>" \
      --header "Authorization: Bearer <token>"

- Descarga ping_staging.json y data_scan.json a _reports/
- Analiza summary.dataset_real_status en data_scan.json
- Genera _reports/informe_resultados_verificacion_rest_staging.md con decisión A/B

Requisitos: Solo librerías estándar de Python (sin dependencias externas)
"""

import argparse
import datetime as dt
import json
import os
import sys
import urllib.request
from urllib.error import HTTPError, URLError

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
REPORTS_DIR = os.path.join(REPO_ROOT, "_reports")

PING_PATH = "/wp-json/runart/v1/ping-staging"
SCAN_PATH = "/wp-json/runart/v1/data-scan"


def http_get(url: str, headers: dict) -> tuple[int, dict | list | None, str | None]:
    req = urllib.request.Request(url)
    for k, v in headers.items():
        req.add_header(k, v)
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            status = resp.getcode()
            body = resp.read().decode("utf-8", errors="replace")
            try:
                data = json.loads(body)
            except json.JSONDecodeError:
                data = None
            return status, data, None
    except HTTPError as e:
        try:
            body = e.read().decode("utf-8", errors="replace")
        except Exception:
            body = ""
        return e.code, None, f"HTTPError {e.code}: {e.reason} {body[:200]}"
    except URLError as e:
        return 0, None, f"URLError: {e.reason}"
    except Exception as e:
        return 0, None, f"Error: {e}"


def save_json(path: str, data: dict | list | None | str):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    if isinstance(data, (dict, list)):
        content = json.dumps(data, ensure_ascii=False, indent=2)
    else:
        content = str(data) if data is not None else "null"
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)


def build_report_md(
    staging_url: str,
    ping_status: int,
    ping_data: dict | None,
    ping_err: str | None,
    scan_status: int,
    scan_data: dict | None,
    scan_err: str | None,
):
    now = dt.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")

    # Extraer resumen y decisión
    dataset_status = None
    decision = "UNKNOWN"
    uploads_enriched_items = None
    uploads_enriched_entry = None

    if isinstance(scan_data, dict):
        summary = scan_data.get("summary") or {}
        dataset_status = summary.get("dataset_real_status")
        # Buscar la entrada uploads-enriched
        for entry in (scan_data.get("scan") or []):
            if entry.get("label") == "uploads-enriched":
                uploads_enriched_entry = entry
                uploads_enriched_items = entry.get("item_count")
                break

    if dataset_status == "FOUND_IN_STAGING":
        decision = "B (ampliar cascada)"
    elif dataset_status == "NOT_FOUND_IN_STAGING":
        decision = "A (sync de índice a ruta soportada)"
    else:
        decision = "UNKNOWN (revisar auth/permisos)"

    # Secciones del informe
    lines = []
    lines.append("# Informe — Resultados verificación REST en staging (FASE 3.E)")
    lines.append("")
    lines.append(f"Fecha: {now}")
    lines.append(f"Staging URL: {staging_url}")
    lines.append("")

    # 1) Ping
    lines.append("## 1) Resultado ping-staging")
    if ping_status == 200 and isinstance(ping_data, dict):
        site_url = ping_data.get("site_url")
        theme = ping_data.get("theme") or {}
        plugin = ping_data.get("runart_plugin") or {}
        lines.append(f"- status HTTP: {ping_status}")
        lines.append(f"- site_url: {site_url}")
        lines.append(f"- theme: {theme.get('name')} ({theme.get('version')})")
        lines.append(f"- plugin: {plugin.get('name')} ({plugin.get('version')})")
    else:
        lines.append(f"- status HTTP: {ping_status}")
        lines.append(f"- error: {ping_err or 'respuesta inválida'}")
    lines.append("")

    # 2) Scan
    lines.append("## 2) Resultado data-scan (rutas probadas)")
    lines.append(f"- status HTTP: {scan_status}")
    if isinstance(scan_data, dict):
        for entry in (scan_data.get("scan") or []):
            label = entry.get("label")
            path = entry.get("path")
            exists = entry.get("exists")
            size = entry.get("size_bytes")
            item_count = entry.get("item_count")
            error = entry.get("error")
            lines.append(f"  - [{label}] {path}\n    exists={exists}, size_bytes={size}, item_count={item_count}, error={error}")
    else:
        lines.append(f"- error: {scan_err or 'respuesta inválida'}")
    lines.append("")

    # 3) Decisión
    lines.append("## 3) Evaluación y decisión")
    lines.append(f"- dataset_real_status: {dataset_status}")
    if uploads_enriched_entry:
        lines.append(f"- uploads-enriched item_count: {uploads_enriched_items}")
        lines.append(f"- uploads-enriched path: {uploads_enriched_entry.get('path')}")
    lines.append(f"- Decisión tomado por el sistema: {decision}")
    lines.append("")

    # 4) Próximos pasos
    lines.append("## 4) Próximos pasos automáticos recomendados")
    if dataset_status == "FOUND_IN_STAGING":
        lines.append("- Proceder con Opción B: ampliar la cascada en el plugin para incluir wp-content/uploads/runart-jobs/enriched/index.json (sólo lectura).")
        lines.append("- Actualizar CHANGELOG: 'Fase 3.E: Ampliación de cascada REST habilitada para ruta 4 (dataset real confirmado en staging).' ")
    elif dataset_status == "NOT_FOUND_IN_STAGING":
        lines.append("- Mantener dataset pequeño (3 ítems) como red de seguridad.")
        lines.append("- Documentar en README que el staging opera con el demo dataset.")
    else:
        lines.append("- Revisar cabeceras de autenticación REST (X-WP-Nonce o Authorization: Bearer <token>) o políticas de acceso (Cloudflare Access).")
        lines.append("- Reintentar la verificación una vez ajustadas las credenciales.")

    lines.append("")
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="FASE 3.E — Verificación REST en Staging y decisión A/B")
    parser.add_argument("--staging-url", required=True, help="URL base del staging (ej: https://staging.example.com)")
    parser.add_argument(
        "--header",
        action="append",
        default=[],
        help="Cabecera HTTP adicional (puede repetirse). Ej: --header 'X-WP-Nonce: <nonce>'",
    )
    args = parser.parse_args()

    staging_url = args.staging_url.rstrip("/")

    # Construir headers
    headers: dict[str, str] = {"Accept": "application/json"}
    for h in args.header:
        if ":" in h:
            k, v = h.split(":", 1)
            headers[k.strip()] = v.strip()

    # Timestamps y rutas de salida
    ts = dt.datetime.utcnow().strftime("%Y%m%dT%H%M%SZ")
    os.makedirs(REPORTS_DIR, exist_ok=True)

    ping_url = staging_url + PING_PATH
    scan_url = staging_url + SCAN_PATH

    # 1) Ping
    ping_status, ping_data, ping_err = http_get(ping_url, headers)
    ping_out = os.path.join(REPORTS_DIR, f"ping_staging_{ts}.json")
    save_json(ping_out, ping_data if ping_data is not None else {"error": ping_err, "status": ping_status})

    # 2) Data Scan
    scan_status, scan_data, scan_err = http_get(scan_url, headers)
    scan_out = os.path.join(REPORTS_DIR, f"data_scan_{ts}.json")
    save_json(scan_out, scan_data if scan_data is not None else {"error": scan_err, "status": scan_status})

    # 3) Informe
    report_md = build_report_md(staging_url, ping_status, ping_data if isinstance(ping_data, dict) else None, ping_err,
                                scan_status, scan_data if isinstance(scan_data, dict) else None, scan_err)
    report_path = os.path.join(REPORTS_DIR, "informe_resultados_verificacion_rest_staging.md")
    with open(report_path, "w", encoding="utf-8") as f:
        f.write(report_md)

    print("✅ Verificación completada.")
    print(f"  - {ping_out}")
    print(f"  - {scan_out}")
    print(f"  - {report_path}")

    # Salir con código según decisión para CI opcional
    # FOUND -> 0, NOT_FOUND -> 10, UNKNOWN -> 20
    dataset_status = None
    if isinstance(scan_data, dict):
        dataset_status = (scan_data.get("summary") or {}).get("dataset_real_status")

    if dataset_status == "FOUND_IN_STAGING":
        sys.exit(0)
    elif dataset_status == "NOT_FOUND_IN_STAGING":
        sys.exit(10)
    else:
        sys.exit(20)


if __name__ == "__main__":
    main()
