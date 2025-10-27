from typing import Optional

import click

from . import __version__
from .config import DEFAULT_ROOTS, MEDIA_INDEX_PATH, REPO_ROOT
from .indexer import build_index
from .association import associate
from .organizer import organize
from .exporter import export_json, export_csv
from .verify import verify


@click.group()
@click.version_option(version=__version__)
def main() -> None:
    """RunMedia CLI."""


@main.command()
@click.option("--roots", multiple=True, type=click.Path(exists=False, file_okay=False), help="Carpetas a escanear (se pueden repetir)")
def scan(roots: tuple[str, ...]) -> None:
    """Escanea imágenes y genera/actualiza media-index.json."""
    scan_roots = list(roots) if roots else list(DEFAULT_ROOTS)
    click.echo(f"[scan] Rutas: {scan_roots}")
    out = build_index(REPO_ROOT, scan_roots)
    click.echo(f"[scan] Guardado índice en: {MEDIA_INDEX_PATH} (items={len(out.get('items', []))})")


@main.command()
def assoc() -> None:
    """Asocia imágenes con contenidos usando reglas desde association_rules.yaml."""
    out = associate(REPO_ROOT)
    click.echo(f"[assoc] Asociaciones aplicadas. items={len(out.get('items', []))}")


@main.command()
def organize_cmd() -> None:
    """Organiza carpeta library/ (symlinks) según asociaciones."""
    organize(REPO_ROOT)
    click.echo("[organize] Estructura actualizada.")


@main.command()
@click.argument("format", type=click.Choice(["json", "csv"]))
def export(format: str) -> None:  # noqa: A003
    """Exporta el índice a JSON/CSV en content/media/exports."""
    if format == "json":
        path = export_json()
    else:
        path = export_csv()
    click.echo(f"[export] Escrito: {path}")


@main.command()
def verify_cmd() -> None:
    """Verifica consistencia del índice (huérfanas, alt, duplicados)."""
    summary, _details = verify()
    click.echo(f"[verify] {summary}")


@main.command()
@click.option("--id", "img_id", required=True, help="ID de imagen (sha256[:12])")
@click.option("--title-es", default=None)
@click.option("--title-en", default=None)
@click.option("--alt-es", default=None)
@click.option("--alt-en", default=None)
@click.option("--desc-es", default=None)
@click.option("--desc-en", default=None)
def enrich(img_id: str, title_es: Optional[str], title_en: Optional[str], alt_es: Optional[str], alt_en: Optional[str], desc_es: Optional[str], desc_en: Optional[str]) -> None:
    """Enriquece metadatos de una imagen por ID."""
    from .utils import load_json, atomic_write_json

    idx = load_json(MEDIA_INDEX_PATH)
    items = idx.get("items", [])
    target = next((it for it in items if it.get("id") == img_id), None)
    if not target:
        raise click.ClickException(f"Imagen no encontrada: {img_id}")

    meta = target.setdefault("metadata", {})
    titles = meta.setdefault("title", {"es": "", "en": ""})
    alts = meta.setdefault("alt", {"es": "", "en": ""})
    descs = meta.setdefault("description", {"es": "", "en": ""})

    if title_es is not None:
        titles["es"] = title_es
    if title_en is not None:
        titles["en"] = title_en
    if alt_es is not None:
        alts["es"] = alt_es
    if alt_en is not None:
        alts["en"] = alt_en
    if desc_es is not None:
        descs["es"] = desc_es
    if desc_en is not None:
        descs["en"] = desc_en

    atomic_write_json(MEDIA_INDEX_PATH, idx)
    click.echo(f"[enrich] Actualizado {img_id}")


if __name__ == "__main__":
    main()
