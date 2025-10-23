#!/usr/bin/env python3
"""
Strict validator for docs/live
- Requires frontmatter with keys: status, owner, updated, audience, tags
- Fails on broken internal links (.md relative)
- Fails on broken external links (HTTP/HTTPS with timeout)
- Requires unique lowercase tags in frontmatter
- Prohibits duplicate active docs in docs/live (by filename stem)
- Excludes non-live areas implicitly (only scans docs/live)
Exit code: 0 on success, 1 on any error
"""
from __future__ import annotations
import re
import sys
import urllib.request
from pathlib import Path
from typing import Dict, List, Tuple, Any

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"
LIVE = DOCS / "live"

FRONTMATTER_BLOCK_RE = re.compile(r"^---\n(.*?)\n---\n", re.DOTALL)
MD_LINK_RE = re.compile(r"\[[^\]]+\]\(([^)]+)\)")
EXTERNAL_URL_RE = re.compile(r"https?://[^\s<>\"']+")

REQUIRED_KEYS = {"status", "owner", "updated", "audience", "tags"}
EXTERNAL_LINK_WHITELIST = {"localhost", "127.0.0.1", "0.0.0.0"}
LINK_TIMEOUT = 5
LINK_MAX_RETRIES = 1

Error = Tuple[str, str, int, str]  # (file, type, line, message)
errors: List[Error] = []
scanned_files: List[Path] = []
checked_external_urls: Dict[str, bool] = {}  # cache: url -> is_valid


def extract_frontmatter(text: str) -> Dict | None:
    m = FRONTMATTER_BLOCK_RE.match(text)
    if not m:
        return None
    block = m.group(1)
    meta: Dict = {}
    current_key = None
    for raw in block.splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if ":" in line and not line.startswith("-"):
            key, value = line.split(":", 1)
            key = key.strip()
            value = value.strip()
            # Handle inline list: tags: [foo, bar]
            if value.startswith("[") and value.endswith("]"):
                value = [v.strip() for v in value[1:-1].split(",") if v.strip()]
            meta[key] = value
            current_key = key
        elif line.startswith("-") and current_key:
            # multi-line list item
            item = line[1:].strip()
            if current_key not in meta:
                meta[current_key] = []
            elif not isinstance(meta[current_key], list):
                meta[current_key] = [meta[current_key]]
            meta[current_key].append(item)
    return meta


def check_frontmatter(path: Path, text: str):
    fm = extract_frontmatter(text)
    if fm is None:
        errors.append((str(path.relative_to(ROOT)), "missing_frontmatter", 1, "Falta bloque YAML inicial (---)"))
        return
    missing = [k for k in REQUIRED_KEYS if k not in fm or fm[k] == ""]
    if missing:
        errors.append((str(path.relative_to(ROOT)), "missing_required_keys", 1, f"Faltan claves en frontmatter: {', '.join(sorted(missing))}"))
    
    # Check tags: must be list, unique, lowercase
    if "tags" in fm:
        tags = fm["tags"]
        if isinstance(tags, str):
            tags = [tags]
        if not isinstance(tags, list):
            errors.append((str(path.relative_to(ROOT)), "invalid_tags", 1, "tags debe ser una lista"))
            return
        # Normalize and check
        normalized = []
        seen = set()
        for tag in tags:
            tag_clean = tag.strip()
            if not tag_clean:
                errors.append((str(path.relative_to(ROOT)), "invalid_tags", 1, "tag vacío detectado"))
                continue
            if tag_clean != tag_clean.lower():
                errors.append((str(path.relative_to(ROOT)), "invalid_tags", 1, f"tag no está en minúsculas: '{tag_clean}'"))
            if tag_clean.lower() in seen:
                errors.append((str(path.relative_to(ROOT)), "duplicate_tags", 1, f"tag duplicado: '{tag_clean.lower()}'"))
            seen.add(tag_clean.lower())
            normalized.append(tag_clean.lower())


def is_external_link(href: str) -> bool:
    return href.startswith("http://") or href.startswith("https://")


def is_whitelisted_domain(url: str) -> bool:
    for domain in EXTERNAL_LINK_WHITELIST:
        if domain in url:
            return True
    return False


def check_external_url(url: str) -> bool:
    """Check if external URL is reachable. Returns True if valid, False if broken."""
    if url in checked_external_urls:
        return checked_external_urls[url]
    
    if is_whitelisted_domain(url):
        checked_external_urls[url] = True
        return True
    
    for attempt in range(LINK_MAX_RETRIES + 1):
        try:
            req = urllib.request.Request(url, method="HEAD")
            req.add_header("User-Agent", "RunArtFoundry-DocsValidator/1.0")
            with urllib.request.urlopen(req, timeout=LINK_TIMEOUT) as response:
                is_valid = response.status < 400
                checked_external_urls[url] = is_valid
                return is_valid
        except Exception:
            # Try GET if HEAD fails
            try:
                req = urllib.request.Request(url, method="GET")
                req.add_header("User-Agent", "RunArtFoundry-DocsValidator/1.0")
                with urllib.request.urlopen(req, timeout=LINK_TIMEOUT) as response:
                    is_valid = response.status < 400
                    checked_external_urls[url] = is_valid
                    return is_valid
            except Exception:
                if attempt < LINK_MAX_RETRIES:
                    continue
                checked_external_urls[url] = False
                return False
    
    checked_external_urls[url] = False
    return False


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
            
            # Check external links
            if is_external_link(href):
                if not check_external_url(href):
                    errors.append((str(path.relative_to(ROOT)), "broken_external_link", i, f"Enlace externo roto o inaccesible: {href}"))
                continue
            
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
