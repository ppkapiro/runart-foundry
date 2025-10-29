"""
Tests para auto_rollback.py
Sprint 3 - Hardening + Observabilidad

Verifica:
- Restauración de status.json desde backup
- Creación de commit de rollback
- Manejo de errores (backup inexistente, JSON corrupto)
"""

import sys
import json
from pathlib import Path

# Ajustar path para imports
ROOT = Path(__file__).parent.parent.parent
sys.path.insert(0, str(ROOT / "tools"))

# pylint: disable=import-error,wrong-import-position
import auto_rollback  # noqa: E402


def test_backup_exists_check(tmp_path, monkeypatch):
    """Verifica detección de backup existente."""
    # Setup: crear backup válido
    backup_file = tmp_path / "status.json.bak"
    backup_file.write_text('{"generated_at": "2025-10-23T00:00:00Z"}')
    
    # Monkeypatch paths
    monkeypatch.setattr(auto_rollback, "BACKUP_JSON", backup_file)
    
    # Test
    assert auto_rollback.check_backup_exists() is True


def test_backup_not_found(tmp_path, monkeypatch):
    """Verifica manejo cuando no existe backup."""
    backup_file = tmp_path / "status.json.bak"
    
    # Monkeypatch paths
    monkeypatch.setattr(auto_rollback, "BACKUP_JSON", backup_file)
    
    # Test
    assert auto_rollback.check_backup_exists() is False


def test_restore_status_json_success(tmp_path, monkeypatch):
    """Verifica restauración exitosa desde backup válido."""
    # Setup: crear backup y status actual (corrupto)
    backup_file = tmp_path / "status.json.bak"
    status_file = tmp_path / "status.json"
    
    backup_data = {
        "generated_at": "2025-10-23T00:00:00Z",
        "docs_live_count": 42,
        "archive_count": 10,
        "last_ci_ref": "abc123"
    }
    backup_file.write_text(json.dumps(backup_data, indent=2))
    status_file.write_text('{"invalid": json}')
    
    # Monkeypatch paths
    monkeypatch.setattr(auto_rollback, "BACKUP_JSON", backup_file)
    monkeypatch.setattr(auto_rollback, "STATUS_JSON", status_file)
    
    # Test
    assert auto_rollback.restore_status_json() is True
    
    # Verificar que status.json fue restaurado
    restored = json.loads(status_file.read_text())
    assert restored["docs_live_count"] == 42
    assert restored["archive_count"] == 10


def test_restore_corrupted_backup(tmp_path, monkeypatch):
    """Verifica manejo de backup corrupto (JSON inválido)."""
    # Setup: crear backup corrupto
    backup_file = tmp_path / "status.json.bak"
    status_file = tmp_path / "status.json"
    
    backup_file.write_text('{"invalid": json syntax error}')
    status_file.write_text('{"current": "data"}')
    
    # Monkeypatch paths
    monkeypatch.setattr(auto_rollback, "BACKUP_JSON", backup_file)
    monkeypatch.setattr(auto_rollback, "STATUS_JSON", status_file)
    
    # Test: debe fallar y mantener status.json original
    assert auto_rollback.restore_status_json() is False
    current = json.loads(status_file.read_text())
    assert current["current"] == "data"


def test_revert_generated_files_no_changes(tmp_path, monkeypatch):
    """Verifica comportamiento cuando no hay archivos que revertir."""
    # Setup: directorio vacío
    news_dir = tmp_path / "news"
    news_dir.mkdir()
    
    monkeypatch.setattr(auto_rollback, "NEWS_DIR", news_dir)
    monkeypatch.setattr(auto_rollback, "STATUS_PAGE", tmp_path / "status" / "index.md")
    
    # Test: debe retornar True (no hay nada que revertir)
    assert auto_rollback.revert_generated_files() is True


def test_execute_rollback_no_backup(tmp_path, monkeypatch):
    """Verifica exit code 1 cuando no existe backup."""
    backup_file = tmp_path / "status.json.bak"
    
    monkeypatch.setattr(auto_rollback, "BACKUP_JSON", backup_file)
    
    # Test: debe retornar 1 (no hay backup)
    result = auto_rollback.execute_rollback()
    assert result == 1
