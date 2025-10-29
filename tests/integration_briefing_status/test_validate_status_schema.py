"""
Tests unitarios para tools/validate_status_schema.py

Valida que el validador detecta JSON inválido y schemas incorrectos
"""

import json
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).parents[2] / "tools"))

import pytest


def test_validate_status_schema_success(tmp_path, monkeypatch):
    """Verifica que valida correctamente un status.json válido"""
    import validate_status_schema
    
    docs_dir = tmp_path / "docs"
    docs_dir.mkdir()
    
    status_json = docs_dir / "status.json"
    status_json.write_text(json.dumps({
        "generated_at": "2025-10-23T22:00:00Z",
        "preview_ok": True,
        "prod_ok": True,
        "last_ci_ref": "abc123def456789012345678901234567890",
        "docs_live_count": 6,
        "archive_count": 1
    }))
    
    monkeypatch.setattr(validate_status_schema, "ROOT", tmp_path)
    monkeypatch.setattr(validate_status_schema, "STATUS_FILE", status_json)
    monkeypatch.setattr(validate_status_schema, "BACKUP_FILE", tmp_path / "docs" / "status.json.bak")
    
    assert validate_status_schema.validate_status_json() is True


def test_validate_status_schema_missing_field(tmp_path, monkeypatch, capsys):
    """Verifica que detecta campos faltantes"""
    import validate_status_schema
    
    docs_dir = tmp_path / "docs"
    docs_dir.mkdir()
    
    status_json = docs_dir / "status.json"
    status_json.write_text(json.dumps({
        "generated_at": "2025-10-23T22:00:00Z",
        # Falta docs_live_count, archive_count, last_ci_ref
    }))
    
    monkeypatch.setattr(validate_status_schema, "ROOT", tmp_path)
    monkeypatch.setattr(validate_status_schema, "STATUS_FILE", status_json)
    
    assert validate_status_schema.validate_status_json() is False
    captured = capsys.readouterr()
    assert "ERROR" in captured.err


def test_validate_status_schema_invalid_type(tmp_path, monkeypatch, capsys):
    """Verifica que detecta tipos incorrectos"""
    import validate_status_schema
    
    docs_dir = tmp_path / "docs"
    docs_dir.mkdir()
    
    status_json = docs_dir / "status.json"
    status_json.write_text(json.dumps({
        "generated_at": "2025-10-23T22:00:00Z",
        "preview_ok": True,
        "prod_ok": True,
        "last_ci_ref": "abc123",
        "docs_live_count": "should_be_integer",  # Tipo incorrecto
        "archive_count": 1
    }))
    
    monkeypatch.setattr(validate_status_schema, "ROOT", tmp_path)
    monkeypatch.setattr(validate_status_schema, "STATUS_FILE", status_json)
    
    assert validate_status_schema.validate_status_json() is False


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
