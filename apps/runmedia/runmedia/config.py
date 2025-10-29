import os
from typing import List

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))

# Rutas por defecto para escaneo (se pueden sobrescribir por CLI)
DEFAULT_ROOTS: List[str] = [
    os.path.join(REPO_ROOT, "mirror"),
    os.path.join(REPO_ROOT, "content", "media", "library"),
]

MEDIA_INDEX_PATH = os.path.join(REPO_ROOT, "content", "media", "media-index.json")
ASSOCIATION_RULES_PATH = os.path.join(REPO_ROOT, "content", "media", "association_rules.yaml")
LIBRARY_ROOT = os.path.join(REPO_ROOT, "content", "media", "library")
EXPORTS_DIR = os.path.join(REPO_ROOT, "content", "media", "exports")
REPORTS_DIR = os.path.join(REPO_ROOT, "_reports")
VARIANTS_ROOT = os.path.join(REPO_ROOT, "content", "media", "variants")
