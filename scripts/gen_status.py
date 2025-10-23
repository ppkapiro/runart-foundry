#!/usr/bin/env python3
"""
Generador de docs/status.json (estado operativo mínimo)
"""
from __future__ import annotations
import json
import subprocess
from pathlib import Path
from datetime import datetime, timezone

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"
LIVE = DOCS / "live"
ARCHIVE = DOCS / "archive"
STATUS_FILE = DOCS / "status.json"


def count_md_files(base: Path) -> int:
    if not base.exists():
        return 0
    return len(list(base.rglob("*.md")))


def get_git_ref() -> str:
    try:
        result = subprocess.run(
            ["git", "rev-parse", "HEAD"],
            cwd=ROOT,
            capture_output=True,
            text=True,
            timeout=5
        )
        if result.returncode == 0:
            return result.stdout.strip()
    except Exception:
        pass
    return "unknown"


def main():
    status = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "preview_ok": True,  # TODO: detectar si preview funciona (endpoint?)
        "prod_ok": True,     # TODO: detectar si prod funciona (endpoint?)
        "last_ci_ref": get_git_ref(),
        "docs_live_count": count_md_files(LIVE),
        "archive_count": count_md_files(ARCHIVE),
    }
    
    STATUS_FILE.write_text(json.dumps(status, indent=2) + "\n", encoding="utf-8")
    print(f"Status updated: {STATUS_FILE.relative_to(ROOT)}")
    print(f"  live_count={status['docs_live_count']}, archive_count={status['archive_count']}")
    print(f"  last_ci_ref={status['last_ci_ref'][:8]}")


if __name__ == "__main__":
    main()
