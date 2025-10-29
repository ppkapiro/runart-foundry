"""
Tests unitarios para tools/render_status.py

Valida que el script genera correctamente la página de estado
desde docs/status.json
"""

import json
from pathlib import Path
import sys

# Añadir tools/ al path para importar
sys.path.insert(0, str(Path(__file__).parents[2] / "tools"))

import pytest


def test_render_status_generates_file(tmp_path, monkeypatch):
    """Verifica que render_status.py genera apps/briefing/docs/status/index.md"""
    # Crear estructura temporal
    docs_dir = tmp_path / "docs"
    docs_dir.mkdir()
    
    status_json = docs_dir / "status.json"
    status_json.write_text(json.dumps({
        "generated_at": "2025-10-23T22:00:00Z",
        "preview_ok": True,
        "prod_ok": True,
        "last_ci_ref": "abc123def456",
        "docs_live_count": 6,
        "archive_count": 1
    }))
    
    apps_dir = tmp_path / "apps" / "briefing" / "docs" / "status"
    apps_dir.mkdir(parents=True)
    
    # Monkeypatch ROOT
    import render_status
    monkeypatch.setattr(render_status, "ROOT", tmp_path)
    monkeypatch.setattr(render_status, "STATUS_JSON", status_json)
    monkeypatch.setattr(render_status, "OUTPUT_MD", apps_dir / "index.md")
    
    # Ejecutar
    render_status.main()
    
    # Verificar
    output_file = apps_dir / "index.md"
    assert output_file.exists(), "index.md no fue generado"
    
    content = output_file.read_text()
    assert "KPIs" in content, "Página debe contener sección KPIs"
    assert "6" in content, "Debe mostrar docs_live_count"
    assert "abc123" in content, "Debe mostrar hash de commit"


def test_render_status_validates_frontmatter(tmp_path, monkeypatch):
    """Verifica que el archivo generado tiene frontmatter YAML válido"""
    docs_dir = tmp_path / "docs"
    docs_dir.mkdir()
    
    status_json = docs_dir / "status.json"
    status_json.write_text(json.dumps({
        "generated_at": "2025-10-23T22:00:00Z",
        "preview_ok": True,
        "prod_ok": True,
        "last_ci_ref": "def789abc123",
        "docs_live_count": 10,
        "archive_count": 2
    }))
    
    apps_dir = tmp_path / "apps" / "briefing" / "docs" / "status"
    apps_dir.mkdir(parents=True)
    
    import render_status
    monkeypatch.setattr(render_status, "ROOT", tmp_path)
    monkeypatch.setattr(render_status, "STATUS_JSON", status_json)
    monkeypatch.setattr(render_status, "OUTPUT_MD", apps_dir / "index.md")
    
    render_status.main()
    
    content = (apps_dir / "index.md").read_text()
    lines = content.split('\n')
    
    assert lines[0] == "---", "Debe iniciar con delimitador frontmatter"
    assert "title:" in content, "Frontmatter debe tener título"
    assert "updated:" in content, "Frontmatter debe tener fecha actualización"
    
    # Verificar cierre de frontmatter
    frontmatter_closes = [i for i, line in enumerate(lines[1:], 1) if line == "---"]
    assert len(frontmatter_closes) > 0, "Frontmatter debe tener cierre"


def test_render_status_fails_on_missing_json(tmp_path, monkeypatch, capsys):
    """Verifica que falla correctamente si status.json no existe"""
    import render_status
    monkeypatch.setattr(render_status, "ROOT", tmp_path)
    monkeypatch.setattr(render_status, "STATUS_JSON", tmp_path / "docs" / "status.json")
    
    with pytest.raises(SystemExit) as exc_info:
        render_status.main()
    
    assert exc_info.value.code == 1
    captured = capsys.readouterr()
    assert "ERROR" in captured.err


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
