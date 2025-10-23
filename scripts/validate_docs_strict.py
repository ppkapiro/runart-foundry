#!/usr/bin/env python3
"""
Strict validator for docs/live
- Requires frontmatter with keys: status, owner, updated, audience, tags
- Fails on broken internal links (.md relative)
- Prohibits duplicate active docs in docs/live (by filename stem)
- Excludes non-live areas implicitly (only scans docs/live)
Exit code: 0 on success, 1 on any error
"""
from __future__ import annotations
import re
import sys
from pathlib import Path
from typing import Dict, List, Tuple

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"
LIVE = DOCS / "live"

FRONTMATTER_BLOCK_RE = re.compile(r"^---\n(.*?)\n---\n", re.DOTALL)
MD_LINK_RE = re.compile(r"\[[^\]]+\]\(([^)]+)\)")

REQUIRED_KEYS = {"status", "owner", "updated", "audience", "tags"}

Error = Tuple[str, str, int, str]  # (file, type, line, message)
errors: List[Error] = []
scanned_files: List[Path] = []


def extract_frontmatter(text: str) -> Dict[str, str] | None:
    m = FRONTMATTER_BLOCK_RE.match(text)
    if not m:
        return None
    block = m.group(1)
    meta: Dict[str, str] = {}
    for raw in block.splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if ":" not in line:
            # allow list items etc. (skip)
            continue
        key, value = line.split(":", 1)
        meta[key.strip()] = value.strip()
    return meta


def check_frontmatter(path: Path, text: str):
    fm = extract_frontmatter(text)
    if fm is None:
        errors.append((str(path.relative_to(ROOT)), "missing_frontmatter", 1, "Falta bloque YAML inicial (---)"))
        return
    missing = [k for k in REQUIRED_KEYS if k not in fm or fm[k] == ""]
    if missing:
        errors.append((str(path.relative_to(ROOT)), "missing_required_keys", 1, f"Faltan claves en frontmatter: {', '.join(sorted(missing))}"))


def is_external_or_anchor(href: str) -> bool:
    if href.startswith("http://") or href.startswith("https://"):
        return True
    if href.startswith("mailto:"):
        return True
    if href.startswith("#"):
        return True
    return False


def check_links(path: Path, text: str):
    for i, line in enumerate(text.splitlines(), start=1):
        for m in MD_LINK_RE.finditer(line):
            href = m.group(1).strip()
            if is_external_or_anchor(href):
                continue
            # Consider only .md files and relative paths
            if not href.endswith(".md"):
                # ignore non-md targets (images, etc.)
                continue
            if href.startswith("/"):
                # absolute path not supported, treat as internal from repo root
                target_path = (ROOT / href.lstrip("/"))
            else:
                target_path = (path.parent / href).resolve()
            try:
                target_path.relative_to(ROOT)
            except Exception:
                # outside repo
                pass
            if not target_path.exists():
                errors.append((str(path.relative_to(ROOT)), "broken_link", i, f"Enlace roto: {href}"))


def check_file(path: Path):
    try:
        text = path.read_text(encoding="utf-8")
    except Exception as e:
        errors.append((str(path), "read_error", 0, str(e)))
        return
    check_frontmatter(path, text)
    check_links(path, text)


def scan_live():
    if not LIVE.exists():
        return
    for p in LIVE.rglob("*.md"):
        # Skip index listings generated elsewhere if needed (keep simple for now)
        scanned_files.append(p)
        check_file(p)


def check_duplicates():
    by_stem: Dict[str, List[Path]] = {}
    for p in scanned_files:
        by_stem.setdefault(p.stem, []).append(p)
    for stem, paths in by_stem.items():
        # permitimos múltiples index.md en distintas rutas
        if stem == "index":
            continue
        if len(paths) > 1:
            for p in paths:
                errors.append((str(p.relative_to(ROOT)), "duplicate_live", 1, f"Duplicado por nombre base '{stem}' en docs/live"))


def main():
    scan_live()
    check_duplicates()
    if errors:
        # Print report to stderr for CI visibility
        print("Strict validation failed (docs/live):", file=sys.stderr)
        for f, t, n, m in errors:
            print(f"- {f}:{n}: {t}: {m}", file=sys.stderr)
        sys.exit(1)
    else:
        print("Strict validation passed (docs/live): 0 errors")


if __name__ == "__main__":
    main()
