#!/usr/bin/env python3
"""
Auto-Rollback Script para Briefing + Status.json Integration
Sprint 3 - Hardening + Observabilidad

Detecta fallos en validación JSON o build MkDocs y ejecuta rollback automático:
- Restaura docs/status.json desde docs/status.json.bak
- Revierte cambios generados (apps/briefing/docs/status/index.md, apps/briefing/docs/news/*.md)
- Crea commit de rollback con [skip ci]

Exit codes:
- 0: Rollback exitoso
- 1: No se requiere rollback (backup no encontrado)
- 2: Error durante rollback
"""

import sys
import json
import subprocess
from pathlib import Path
from datetime import datetime, timezone

# Paths relativos al root del repositorio
ROOT = Path(__file__).parent.parent
BACKUP_JSON = ROOT / "docs" / "status.json.bak"
STATUS_JSON = ROOT / "docs" / "status.json"
STATUS_PAGE = ROOT / "apps" / "briefing" / "docs" / "status" / "index.md"
NEWS_DIR = ROOT / "apps" / "briefing" / "docs" / "news"


def log(message: str, level: str = "INFO") -> None:
    """Logger simple con timestamp UTC."""
    timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    prefix = {
        "INFO": "ℹ️",
        "WARN": "⚠️",
        "ERROR": "❌",
        "SUCCESS": "✅"
    }.get(level, "•")
    print(f"{prefix} [{timestamp}] {message}", file=sys.stderr)


def check_backup_exists() -> bool:
    """Verifica que exista el backup de status.json."""
    if not BACKUP_JSON.exists():
        log(f"Backup no encontrado: {BACKUP_JSON}", "WARN")
        return False
    log(f"Backup encontrado: {BACKUP_JSON}", "INFO")
    return True


def restore_status_json() -> bool:
    """Restaura status.json desde backup."""
    try:
        if not BACKUP_JSON.exists():
            log("No se puede restaurar: backup inexistente", "ERROR")
            return False
        
        # Validar que el backup sea JSON válido antes de restaurar
        with open(BACKUP_JSON, 'r', encoding='utf-8') as f:
            json.load(f)
        
        # Restaurar backup
        with open(BACKUP_JSON, 'r', encoding='utf-8') as src:
            content = src.read()
        with open(STATUS_JSON, 'w', encoding='utf-8') as dst:
            dst.write(content)
        
        log(f"✓ Restaurado {STATUS_JSON} desde backup", "SUCCESS")
        return True
    except json.JSONDecodeError as e:
        log(f"Backup corrupto (JSON inválido): {e}", "ERROR")
        return False
    except Exception as e:
        log(f"Error restaurando status.json: {e}", "ERROR")
        return False


def revert_generated_files() -> bool:
    """Revierte archivos generados por render_status.py y commits_to_posts.py."""
    try:
        files_to_revert = []
        
        # Revertir status page si existe
        if STATUS_PAGE.exists():
            files_to_revert.append(str(STATUS_PAGE.relative_to(ROOT)))
        
        # Revertir posts generados (últimos N commits)
        # Buscar archivos .md en news/ que fueron modificados en el último commit
        if NEWS_DIR.exists():
            result = subprocess.run(
                ["git", "diff", "--name-only", "HEAD~1", "HEAD", "--", str(NEWS_DIR)],
                cwd=ROOT,
                capture_output=True,
                text=True
            )
            if result.returncode == 0:
                news_files = [f.strip() for f in result.stdout.split('\n') if f.strip().endswith('.md')]
                files_to_revert.extend(news_files)
        
        if not files_to_revert:
            log("No hay archivos generados que revertir", "INFO")
            return True
        
        # Revertir archivos usando git checkout
        for file_path in files_to_revert:
            result = subprocess.run(
                ["git", "checkout", "HEAD~1", "--", file_path],
                cwd=ROOT,
                capture_output=True,
                text=True
            )
            if result.returncode == 0:
                log(f"✓ Revertido: {file_path}", "SUCCESS")
            else:
                log(f"No se pudo revertir {file_path}: {result.stderr}", "WARN")
        
        return True
    except Exception as e:
        log(f"Error revirtiendo archivos generados: {e}", "ERROR")
        return False


def create_rollback_commit() -> bool:
    """Crea commit de rollback con [skip ci]."""
    try:
        # Stage cambios
        subprocess.run(["git", "add", str(STATUS_JSON.relative_to(ROOT))], cwd=ROOT, check=True)
        subprocess.run(["git", "add", str(STATUS_PAGE.relative_to(ROOT))], cwd=ROOT, check=False)
        
        if NEWS_DIR.exists():
            subprocess.run(["git", "add", str(NEWS_DIR.relative_to(ROOT))], cwd=ROOT, check=False)
        
        # Verificar si hay cambios staged
        result = subprocess.run(
            ["git", "diff", "--cached", "--quiet"],
            cwd=ROOT
        )
        
        if result.returncode == 0:
            log("No hay cambios que commitear (rollback no necesario)", "INFO")
            return True
        
        # Crear commit
        commit_msg = "revert: auto-rollback briefing publish [skip ci]"
        timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
        commit_body = f"\nRollback automático ejecutado: {timestamp}\nRestaurado desde backup ante fallo de validación o build."
        
        subprocess.run(
            ["git", "commit", "-m", commit_msg + commit_body],
            cwd=ROOT,
            check=True
        )
        
        log(f"✓ Commit de rollback creado: {commit_msg}", "SUCCESS")
        return True
    except subprocess.CalledProcessError as e:
        log(f"Error creando commit de rollback: {e}", "ERROR")
        return False


def execute_rollback() -> int:
    """Ejecuta secuencia completa de rollback."""
    log("🔄 Iniciando rollback automático...", "INFO")
    
    # 1. Verificar backup
    if not check_backup_exists():
        log("Rollback cancelado: no hay backup disponible", "WARN")
        return 1
    
    # 2. Restaurar status.json
    if not restore_status_json():
        log("Rollback fallido: no se pudo restaurar status.json", "ERROR")
        return 2
    
    # 3. Revertir archivos generados
    if not revert_generated_files():
        log("Advertencia: algunos archivos no se pudieron revertir", "WARN")
    
    # 4. Crear commit
    if not create_rollback_commit():
        log("Rollback fallido: no se pudo crear commit", "ERROR")
        return 2
    
    log("✅ Rollback completado exitosamente", "SUCCESS")
    return 0


def main() -> int:
    """Entry point."""
    try:
        return execute_rollback()
    except Exception as e:
        log(f"Error inesperado durante rollback: {e}", "ERROR")
        return 2


if __name__ == "__main__":
    sys.exit(main())
