#!/usr/bin/env python3
"""Valida un archivo YAML de ficha comprobando campos mínimos."""
from __future__ import annotations

import sys
from pathlib import Path
from typing import Any, Iterable

import yaml

REQUIRED_FIELDS = {
    "slug": ("slug", "id"),
    "titulo": ("titulo", "title"),
    "artista": ("artista", "artist"),
    "anio": ("anio", "year"),
}


def load_yaml(path: Path) -> dict[str, Any]:
    try:
        with path.open("r", encoding="utf-8") as handle:
            data = yaml.safe_load(handle) or {}
    except FileNotFoundError as exc:
        raise ValueError(f"No se encontró el archivo: {path}") from exc
    except yaml.YAMLError as exc:
        raise ValueError(f"YAML inválido en {path}: {exc}") from exc

    if not isinstance(data, dict):
        raise ValueError("El YAML debe contener un objeto (mapa) en la raíz")
    return data


def first_present(data: dict[str, Any], keys: Iterable[str]) -> Any:
    for key in keys:
        if key in data:
            return data[key]
    return None


def validate_required(data: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    for label, aliases in REQUIRED_FIELDS.items():
        value = first_present(data, aliases)
        if value is None:
            errors.append(f"Campo obligatorio ausente: {label}")
        elif isinstance(value, str) and not value.strip():
            errors.append(f"Campo vacío: {label}")
    return errors


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        print("Uso: python scripts/validate_projects.py <ruta-al-archivo.yaml>", file=sys.stderr)
        return 1

    file_path = Path(argv[1]).expanduser().resolve()

    try:
        data = load_yaml(file_path)
        errors = validate_required(data)
    except ValueError as exc:
        print(f"[ERROR] {exc}", file=sys.stderr)
        return 1

    if errors:
        print("[ERROR] Validación fallida:", file=sys.stderr)
        for error in errors:
            print(f"  - {error}", file=sys.stderr)
        return 1

    print(f"[OK] {file_path.name} válido para publicación preliminar.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
