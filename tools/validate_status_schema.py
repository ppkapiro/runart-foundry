#!/usr/bin/env python3
"""
Validador de esquema JSON para docs/status.json

Valida que status.json cumpla con el esquema v1.0 definido en
docs/_meta/status_samples/STATUS_SCHEMA.md

Uso:
    python3 tools/validate_status_schema.py

Exit codes:
    0: Validación exitosa
    1: JSON inválido o no cumple esquema
    2: Archivo no encontrado

Dependencias:
    - jsonschema (pip install jsonschema)
"""

from __future__ import annotations
import json
import sys
from pathlib import Path

try:
    import jsonschema
except ImportError:
    print("❌ ERROR: jsonschema no instalado", file=sys.stderr)
    print("   Instalar con: pip install jsonschema", file=sys.stderr)
    sys.exit(2)

ROOT = Path(__file__).resolve().parents[1]
STATUS_FILE = ROOT / "docs" / "status.json"
BACKUP_FILE = ROOT / "docs" / "status.json.bak"

# Esquema JSON v1.0 según STATUS_SCHEMA.md
SCHEMA = {
    "type": "object",
    "required": ["generated_at", "docs_live_count", "archive_count", "last_ci_ref"],
    "properties": {
        "generated_at": {
            "type": "string",
            "pattern": r"^\d{4}-\d{2}-\d{2}T"  # ISO 8601 timestamp
        },
        "preview_ok": {"type": "boolean"},
        "prod_ok": {"type": "boolean"},
        "docs_live_count": {
            "type": "integer",
            "minimum": 0
        },
        "archive_count": {
            "type": "integer",
            "minimum": 0
        },
        "last_ci_ref": {
            "type": "string",
            "minLength": 7,  # Hash corto mínimo
            "maxLength": 40  # Hash completo máximo
        }
    },
    "additionalProperties": True  # Permitir campos extras (forward compatibility)
}


def validate_status_json() -> bool:
    """
    Valida docs/status.json contra el esquema v1.0
    
    Returns:
        True si válido, False si inválido
    """
    if not STATUS_FILE.exists():
        print(f"❌ ERROR: {STATUS_FILE} no encontrado", file=sys.stderr)
        print("   Ejecutar primero: python3 scripts/gen_status.py", file=sys.stderr)
        return False
    
    try:
        with STATUS_FILE.open('r', encoding='utf-8') as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        print(f"❌ ERROR: JSON inválido en {STATUS_FILE}", file=sys.stderr)
        print(f"   {e}", file=sys.stderr)
        return False
    
    try:
        jsonschema.validate(data, SCHEMA)
    except jsonschema.ValidationError as e:
        print("❌ ERROR: JSON no cumple esquema v1.0", file=sys.stderr)
        print(f"   Campo: {'.'.join(str(p) for p in e.path) or 'root'}", file=sys.stderr)
        print(f"   Mensaje: {e.message}", file=sys.stderr)
        return False
    except jsonschema.SchemaError as e:
        print("❌ ERROR: Esquema de validación inválido", file=sys.stderr)
        print(f"   {e}", file=sys.stderr)
        return False
    
    return True


def create_backup():
    """Crea backup de status.json si es válido"""
    if STATUS_FILE.exists():
        try:
            BACKUP_FILE.write_text(
                STATUS_FILE.read_text(encoding='utf-8'),
                encoding='utf-8'
            )
            print(f"💾 Backup creado: {BACKUP_FILE.relative_to(ROOT)}")
        except Exception as e:
            print(f"⚠️  Advertencia: No se pudo crear backup: {e}", file=sys.stderr)


def main():
    print(f"🔍 Validando {STATUS_FILE.relative_to(ROOT)}...")
    
    if validate_status_json():
        print("✅ Validación JSON exitosa (esquema v1.0)")
        create_backup()
        sys.exit(0)
    else:
        print("\n⚠️  FALLBACK: Intentando usar backup...", file=sys.stderr)
        if BACKUP_FILE.exists():
            try:
                STATUS_FILE.write_text(
                    BACKUP_FILE.read_text(encoding='utf-8'),
                    encoding='utf-8'
                )
                print(f"✅ Restaurado desde backup: {BACKUP_FILE.relative_to(ROOT)}")
                sys.exit(0)
            except Exception as e:
                print(f"❌ ERROR: No se pudo restaurar backup: {e}", file=sys.stderr)
        else:
            print(f"❌ ERROR: No existe backup en {BACKUP_FILE.relative_to(ROOT)}", file=sys.stderr)
        
        sys.exit(1)


if __name__ == "__main__":
    main()
