import os
from typing import Any, Dict, List, Optional, Tuple

import io

import click

from .config import MEDIA_INDEX_PATH, REPO_ROOT, VARIANTS_ROOT
from .utils import Image, atomic_write_json, load_json, now_iso, read_image_size, relpath_under

# Intentar AVIF si está disponible
_AVIF_AVAILABLE = False
try:
    # pillow-avif-plugin registra soporte AVIF al importarse
    import pillow_avif  # type: ignore  # noqa: F401

    _AVIF_AVAILABLE = True
except Exception:
    _AVIF_AVAILABLE = False


def _ensure_dir(path: str) -> None:
    os.makedirs(path, exist_ok=True)


def _target_sizes(orig_w: Optional[int]) -> List[int]:
    # Tamaños por defecto (ancho). No escalar por encima del original.
    base = [2560, 1600, 1200, 800, 400]
    if not orig_w:
        return base
    return [w for w in base if w <= orig_w]


def _resize_keep_ratio(src_path: str, target_w: int) -> Tuple[Optional[Any], Optional[int], Optional[int]]:
    if Image is None:
        return None, None, None
    try:
        with Image.open(src_path) as img:
            w, h = img.size
            if target_w >= w:
                # No upscaling: devolver original
                return img.copy(), w, h
            ratio = target_w / float(w)
            target_h = max(1, int(h * ratio))
            out = img.convert("RGB").resize((target_w, target_h), Image.LANCZOS)
            return out, target_w, target_h
    except Exception:
        return None, None, None


def _save_variant(img: Any, fmt: str, dst_path: str, quality: int = 82) -> Optional[int]:
    if Image is None or img is None:
        return None
    _ensure_dir(os.path.dirname(dst_path))
    buf = io.BytesIO()
    params: Dict[str, Any] = {}
    if fmt == "webp":
        params = {"format": "WEBP", "quality": quality, "method": 6}
    elif fmt == "avif":
        # pillow-avif-plugin usa encoder AVIF al indicar format="AVIF"
        params = {"format": "AVIF", "quality": quality}
    else:
        return None
    try:
        img.save(buf, **params)  # type: ignore[arg-type]
        data = buf.getvalue()
        with open(dst_path, "wb") as f:
            f.write(data)
        return len(data)
    except Exception:
        return None


def optimize(formats: List[str], widths: Optional[List[int]] = None, limit: Optional[int] = None, force: bool = False, quality: int = 82) -> Dict[str, Any]:
    """Genera variantes WebP/AVIF y tamaños y actualiza el índice.

    - formats: ["webp", "avif"]
    - widths: lista de anchos objetivo (si None, usa _target_sizes)
    - limit: procesa solo los primeros N ítems (útil para pruebas)
    - force: rehacer aunque existan
    - quality: calidad de compresión (por defecto 82)
    """
    index: Dict[str, Any] = load_json(MEDIA_INDEX_PATH)
    items: List[Dict[str, Any]] = index.get("items", [])

    processed = 0
    created_files = 0
    skipped = 0

    # Comprobar disponibilidad AVIF
    fmts: List[str] = []
    for f in formats:
        if f == "avif" and not _AVIF_AVAILABLE:
            click.echo("[optimize] AVIF no disponible (instala pillow-avif-plugin). Se omite.")
            continue
        fmts.append(f)

    for it in items:
        if limit is not None and processed >= limit:
            break

        src_rel = ((it.get("source") or {}).get("path"))
        if not src_rel:
            skipped += 1
            continue
        src = os.path.join(REPO_ROOT, src_rel)
        if not os.path.exists(src):
            skipped += 1
            continue

        orig_size = read_image_size(src)
        orig_w = orig_size[0] if orig_size else None
        target_ws = widths if widths else _target_sizes(orig_w)
        if not target_ws:
            skipped += 1
            continue

        img_id = it.get("id")
        if not img_id:
            skipped += 1
            continue

        # Preparar estructura en el índice
        variants = it.setdefault("variants", {"webp": False, "avif": False})
        sizes = it.setdefault("sizes", {})

        for fmt in fmts:
            fmt_dir = os.path.join(VARIANTS_ROOT, img_id, fmt)
            _ensure_dir(fmt_dir)

            fmt_sizes: Dict[str, Dict[str, Any]] = sizes.get(fmt, {}) or {}

            # mtime del origen para invalidar si cambió
            try:
                src_mtime = os.path.getmtime(src)
            except Exception:
                src_mtime = 0

            # Abrir la imagen una sola vez por ítem para múltiple resize
            # Se reabre dentro de _resize_keep_ratio por seguridad; aquí solo controlamos loop
            any_created = False
            for w in target_ws:
                name = f"w{w}.{fmt}"
                dst = os.path.join(fmt_dir, name)
                rel = relpath_under(REPO_ROOT, dst)

                # Saltar si existe y no force y no es más antiguo que el origen
                if os.path.exists(dst) and not force:
                    try:
                        if os.path.getmtime(dst) >= src_mtime:
                            # Mantener registro en índice si aún no está
                            if f"w{w}" not in fmt_sizes:
                                fmt_sizes[f"w{w}"] = {"path": rel, "width": w}
                            continue
                    except Exception:
                        pass

                # Redimensionar y guardar
                img_resized, tw, th = _resize_keep_ratio(src, w)
                if img_resized is None or tw is None or th is None:
                    continue
                size_bytes = _save_variant(img_resized, fmt, dst, quality=quality)
                if size_bytes:
                    fmt_sizes[f"w{w}"] = {"path": rel, "width": tw, "height": th, "bytes": size_bytes, "generated_at": now_iso()}
                    created_files += 1
                    any_created = True

            if fmt_sizes:
                sizes[fmt] = fmt_sizes
                if any_created or variants.get(fmt) is False:
                    variants[fmt] = True

        processed += 1

    # Guardar índice actualizado
    index["generated_at"] = now_iso()
    atomic_write_json(MEDIA_INDEX_PATH, index)

    return {"processed": processed, "created": created_files, "skipped": skipped, "formats": fmts}
