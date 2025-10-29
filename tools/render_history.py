#!/usr/bin/env python3
"""
Render History for Briefing Status Integration
Sprint 3 - Hardening + Observabilidad

Genera apps/briefing/docs/status/history.md con:
- Tabla de snapshots históricos (fecha, live, archive)
- Gráfico Chart.js con tendencias temporales

Requisitos:
- Snapshots en docs/_meta/status_samples/status_YYYY-MM-DD.json
- Chart.js CDN para visualización

Exit codes:
- 0: Generación exitosa
- 1: No hay snapshots suficientes (mínimo 1)
- 2: Error durante generación
"""

import sys
import json
from pathlib import Path
from datetime import datetime, timezone
from typing import List, Dict

# Paths relativos al root del repositorio
ROOT = Path(__file__).parent.parent
SAMPLES_DIR = ROOT / "docs" / "_meta" / "status_samples"
OUTPUT_FILE = ROOT / "apps" / "briefing" / "docs" / "status" / "history.md"

# Template para history.md con Chart.js
HISTORY_TEMPLATE = """---
title: "Status History — Tendencias"
updated: "{updated}"
description: "Historial de snapshots semanales de status.json con visualización de tendencias"
---

# 📊 Status History — Tendencias

Historial de snapshots semanales mostrando la evolución de la documentación del proyecto.

## 📈 Tendencias Temporales

<div style="max-width: 900px; margin: 2rem auto;">
    <canvas id="statusHistory"></canvas>
</div>

## 📋 Tabla de Snapshots

| Fecha | Live Docs | Archive Docs | Total | Snapshot |
|-------|-----------|--------------|-------|----------|
{table_rows}

---

**Última actualización:** {updated}  
**Total de snapshots:** {total_snapshots}

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
(function() {{
    const ctx = document.getElementById('statusHistory');
    if (!ctx) return;
    
    const data = {{
        labels: {labels_json},
        datasets: [
            {{
                label: 'Docs Live',
                data: {live_data_json},
                borderColor: 'rgb(75, 192, 192)',
                backgroundColor: 'rgba(75, 192, 192, 0.2)',
                tension: 0.1
            }},
            {{
                label: 'Archive',
                data: {archive_data_json},
                borderColor: 'rgb(255, 159, 64)',
                backgroundColor: 'rgba(255, 159, 64, 0.2)',
                tension: 0.1
            }},
            {{
                label: 'Total',
                data: {total_data_json},
                borderColor: 'rgb(153, 102, 255)',
                backgroundColor: 'rgba(153, 102, 255, 0.2)',
                tension: 0.1,
                borderDash: [5, 5]
            }}
        ]
    }};
    
    new Chart(ctx, {{
        type: 'line',
        data: data,
        options: {{
            responsive: true,
            plugins: {{
                legend: {{
                    position: 'top',
                }},
                title: {{
                    display: true,
                    text: 'Evolución de Documentación (Snapshots Semanales)'
                }}
            }},
            scales: {{
                y: {{
                    beginAtZero: true,
                    ticks: {{
                        stepSize: 5
                    }}
                }}
            }}
        }}
    }});
}})();
</script>
"""


def log(message: str, level: str = "INFO") -> None:
    """Logger simple con timestamp UTC."""
    timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    prefix = {
        "INFO": "ℹ️",
        "WARN": "⚠️",
        "ERROR": "❌",
        "SUCCESS": "✅"
    }.get(level, "•")
    print(f"{prefix} [{timestamp}] {message}", file=sys.stderr)


def load_snapshots() -> List[Dict]:
    """Carga todos los snapshots de status_samples/*.json ordenados por fecha."""
    if not SAMPLES_DIR.exists():
        log(f"Directorio de snapshots no encontrado: {SAMPLES_DIR}", "WARN")
        return []
    
    snapshots = []
    for json_file in sorted(SAMPLES_DIR.glob("status_*.json")):
        try:
            with open(json_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            # Extraer fecha del nombre del archivo (status_YYYY-MM-DD.json)
            date_str = json_file.stem.replace("status_", "")
            
            snapshots.append({
                "date": date_str,
                "live": data.get("docs_live_count", 0),
                "archive": data.get("archive_count", 0),
                "total": data.get("docs_live_count", 0) + data.get("archive_count", 0),
                "file": json_file.name
            })
        except (json.JSONDecodeError, KeyError) as e:
            log(f"Error cargando {json_file.name}: {e}", "WARN")
            continue
    
    log(f"Cargados {len(snapshots)} snapshots", "INFO")
    return snapshots


def generate_table_rows(snapshots: List[Dict]) -> str:
    """Genera filas de la tabla Markdown."""
    if not snapshots:
        return "| — | — | — | — | — |"
    
    rows = []
    for snap in reversed(snapshots):  # Más reciente primero
        row = f"| {snap['date']} | {snap['live']} | {snap['archive']} | {snap['total']} | `{snap['file']}` |"
        rows.append(row)
    
    return "\n".join(rows)


def generate_history_page(snapshots: List[Dict]) -> str:
    """Genera contenido completo de history.md."""
    if not snapshots:
        log("No hay snapshots para generar historial", "WARN")
        return ""
    
    # Extraer datos para Chart.js
    labels = [snap["date"] for snap in snapshots]
    live_data = [snap["live"] for snap in snapshots]
    archive_data = [snap["archive"] for snap in snapshots]
    total_data = [snap["total"] for snap in snapshots]
    
    # Generar timestamp actual
    updated = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    
    # Renderizar template
    content = HISTORY_TEMPLATE.format(
        updated=updated,
        table_rows=generate_table_rows(snapshots),
        total_snapshots=len(snapshots),
        labels_json=json.dumps(labels),
        live_data_json=json.dumps(live_data),
        archive_data_json=json.dumps(archive_data),
        total_data_json=json.dumps(total_data)
    )
    
    return content


def write_history_file(content: str) -> bool:
    """Escribe history.md al filesystem."""
    try:
        # Crear directorio si no existe
        OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
        
        # Escribir archivo
        with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
            f.write(content)
        
        log(f"✓ Historial generado: {OUTPUT_FILE.relative_to(ROOT)}", "SUCCESS")
        return True
    except Exception as e:
        log(f"Error escribiendo {OUTPUT_FILE}: {e}", "ERROR")
        return False


def main() -> int:
    """Entry point."""
    try:
        log("🔄 Generando historial de status...", "INFO")
        
        # 1. Cargar snapshots
        snapshots = load_snapshots()
        if not snapshots:
            log("No hay snapshots suficientes (mínimo 1)", "ERROR")
            return 1
        
        # 2. Generar contenido
        content = generate_history_page(snapshots)
        if not content:
            log("No se pudo generar contenido del historial", "ERROR")
            return 2
        
        # 3. Escribir archivo
        if not write_history_file(content):
            return 2
        
        log(f"✅ Historial completado: {len(snapshots)} snapshots procesados", "SUCCESS")
        return 0
    except Exception as e:
        log(f"Error inesperado: {e}", "ERROR")
        return 2


if __name__ == "__main__":
    sys.exit(main())
