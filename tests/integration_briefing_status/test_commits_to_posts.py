"""
Tests unitarios para tools/commits_to_posts.py

Valida que el generador de posts crea archivos con frontmatter correcto
"""

import json
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).parents[2] / "tools"))

import pytest


def test_commits_to_posts_generates_valid_frontmatter(tmp_path, monkeypatch):
    """Verifica que los posts generados tienen frontmatter válido"""
    import commits_to_posts
    
    # Simular status.json
    docs_dir = tmp_path / "docs"
    docs_dir.mkdir()
    status_json = docs_dir / "status.json"
    status_json.write_text(json.dumps({
        "generated_at": "2025-10-23T22:00:00Z",
        "docs_live_count": 6,
        "archive_count": 1,
        "last_ci_ref": "abc123"
    }))
    
    # Monkeypatch
    monkeypatch.setattr(commits_to_posts, "STATUS_JSON", status_json)
    
    # Crear commit simulado
    fake_commit = {
        "hash": "abc123def456",
        "hash_short": "abc123de",
        "author": "Test Author",
        "date": "2025-10-23T22:00:00+00:00",
        "message": "docs: test commit",
        "files": ["docs/live/test.md"]
    }
    
    status = commits_to_posts.load_status()
    content = commits_to_posts.generate_post(fake_commit, status)
    
    # Validar frontmatter
    lines = content.split('\n')
    assert lines[0] == "---", "Debe iniciar con delimitador frontmatter"
    assert "title:" in content
    assert "date:" in content
    assert "tags:" in content
    assert "commit:" in content
    assert "kpis:" in content
    
    # Verificar cierre de frontmatter
    frontmatter_closes = [i for i, line in enumerate(lines[1:], 1) if line == "---"]
    assert len(frontmatter_closes) > 0, "Frontmatter debe cerrarse"


def test_commits_to_posts_classifies_correctly(tmp_path, monkeypatch):
    """Verifica que clasifica commits por área correctamente"""
    import commits_to_posts
    
    test_cases = [
        ({"files": ["docs/live/test.md"]}, "docs-live"),
        ({"files": ["docs/archive/old.md"]}, "docs-archive"),
        ({"files": ["tools/script.py"]}, "tools"),
        ({"files": [".github/workflows/test.yml"]}, "ci"),
        ({"files": ["README.md"]}, "other"),
    ]
    
    for commit, expected_area in test_cases:
        area = commits_to_posts.classify_commit(commit)
        assert area == expected_area, f"Commit con {commit['files']} debería clasificarse como {expected_area}"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
