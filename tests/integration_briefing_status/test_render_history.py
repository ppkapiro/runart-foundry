"""
Tests para render_history.py
Sprint 3 - Hardening + Observabilidad

Verifica:
- Generación de history.md con tabla y Chart.js
- Carga de snapshots desde status_samples/
- Contenido del canvas y datasets
"""

import sys
import json
from pathlib import Path

# Ajustar path para imports
ROOT = Path(__file__).parent.parent.parent
sys.path.insert(0, str(ROOT / "tools"))

# pylint: disable=import-error,wrong-import-position
import render_history  # noqa: E402


def test_load_snapshots_empty(tmp_path, monkeypatch):
    """Verifica comportamiento cuando no hay snapshots."""
    samples_dir = tmp_path / "status_samples"
    
    monkeypatch.setattr(render_history, "SAMPLES_DIR", samples_dir)
    
    snapshots = render_history.load_snapshots()
    assert snapshots == []


def test_load_snapshots_valid(tmp_path, monkeypatch):
    """Verifica carga correcta de snapshots válidos."""
    samples_dir = tmp_path / "status_samples"
    samples_dir.mkdir()
    
    # Crear snapshots de prueba
    snapshot1 = {
        "generated_at": "2025-10-20T00:00:00Z",
        "docs_live_count": 42,
        "archive_count": 10
    }
    snapshot2 = {
        "generated_at": "2025-10-21T00:00:00Z",
        "docs_live_count": 45,
        "archive_count": 12
    }
    
    (samples_dir / "status_2025-10-20.json").write_text(json.dumps(snapshot1))
    (samples_dir / "status_2025-10-21.json").write_text(json.dumps(snapshot2))
    
    monkeypatch.setattr(render_history, "SAMPLES_DIR", samples_dir)
    
    snapshots = render_history.load_snapshots()
    assert len(snapshots) == 2
    assert snapshots[0]["date"] == "2025-10-20"
    assert snapshots[0]["live"] == 42
    assert snapshots[1]["date"] == "2025-10-21"
    assert snapshots[1]["live"] == 45


def test_generate_table_rows_empty():
    """Verifica generación de tabla vacía."""
    rows = render_history.generate_table_rows([])
    assert "—" in rows


def test_generate_table_rows_with_data():
    """Verifica generación de tabla con datos."""
    snapshots = [
        {"date": "2025-10-20", "live": 42, "archive": 10, "total": 52, "file": "status_2025-10-20.json"},
        {"date": "2025-10-21", "live": 45, "archive": 12, "total": 57, "file": "status_2025-10-21.json"}
    ]
    
    rows = render_history.generate_table_rows(snapshots)
    assert "2025-10-21" in rows  # Más reciente primero
    assert "45" in rows
    assert "status_2025-10-21.json" in rows


def test_generate_history_page_contains_chart_js():
    """Verifica que history.md contenga Chart.js y canvas."""
    snapshots = [
        {"date": "2025-10-20", "live": 42, "archive": 10, "total": 52, "file": "status_2025-10-20.json"},
        {"date": "2025-10-21", "live": 45, "archive": 12, "total": 57, "file": "status_2025-10-21.json"},
        {"date": "2025-10-22", "live": 48, "archive": 14, "total": 62, "file": "status_2025-10-22.json"}
    ]
    
    content = render_history.generate_history_page(snapshots)
    
    # Verificar elementos esenciales
    assert "<canvas id=\"statusHistory\"></canvas>" in content
    assert "https://cdn.jsdelivr.net/npm/chart.js" in content
    assert "new Chart(ctx" in content
    
    # Verificar frontmatter
    assert "---" in content
    assert "title:" in content
    assert "updated:" in content
    
    # Verificar datos en JSON
    assert "2025-10-20" in content
    assert "42" in content  # live count del primer snapshot


def test_generate_history_page_minimum_snapshots():
    """Verifica que funcione con mínimo 1 snapshot."""
    snapshots = [
        {"date": "2025-10-20", "live": 42, "archive": 10, "total": 52, "file": "status_2025-10-20.json"}
    ]
    
    content = render_history.generate_history_page(snapshots)
    
    assert content != ""
    assert "<canvas id=\"statusHistory\"></canvas>" in content
    assert "Total de snapshots:** 1" in content


def test_write_history_file_creates_directory(tmp_path, monkeypatch):
    """Verifica que se cree el directorio si no existe."""
    output_file = tmp_path / "apps" / "briefing" / "docs" / "status" / "history.md"
    
    monkeypatch.setattr(render_history, "OUTPUT_FILE", output_file)
    monkeypatch.setattr(render_history, "ROOT", tmp_path)
    
    content = "# Test content"
    result = render_history.write_history_file(content)
    
    assert result is True
    assert output_file.exists()
    assert output_file.read_text() == "# Test content"
