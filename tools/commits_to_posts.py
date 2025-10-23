#!/usr/bin/env python3
"""
Generador de posts automáticos a partir de commits recientes

Extrae commits de Git relacionados con documentación y genera publicaciones
automáticas en formato Markdown con frontmatter para el micrositio Briefing.

Uso:
    python3 tools/commits_to_posts.py [--since-hours=24] [--dry-run]

Entrada:
    - Git log (últimos N commits en docs/live/ y docs/archive/)
    - docs/status.json (métricas actuales)

Salida:
    - apps/briefing/docs/news/YYYY-MM-DD-auto-update-{hash}.md

Ejemplo:
    python3 tools/commits_to_posts.py --since-hours=48
    # Genera posts de commits de últimas 48 horas
"""

from __future__ import annotations
import json
import subprocess
import sys
import argparse
from pathlib import Path
from datetime import datetime, timezone, timedelta
from typing import List, Dict, Optional

ROOT = Path(__file__).resolve().parents[1]
STATUS_JSON = ROOT / "docs" / "status.json"
NEWS_DIR = ROOT / "apps" / "briefing" / "docs" / "news"


def get_git_commits(since_hours: int = 24, paths: Optional[List[str]] = None) -> List[Dict]:
    """
    Extrae commits recientes de Git con formato estructurado
    
    Args:
        since_hours: Horas hacia atrás desde ahora
        paths: Lista de rutas a filtrar (ej: ['docs/live/', 'docs/archive/'])
    
    Returns:
        Lista de dicts con: hash, author, date, message, files_changed
    """
    since_date = datetime.now(timezone.utc) - timedelta(hours=since_hours)
    since_str = since_date.strftime("%Y-%m-%d %H:%M:%S")
    
    # Formato: hash|author|date|subject
    # Separador: ||| (poco probable en mensajes)
    cmd = [
        "git", "log",
        f"--since={since_str}",
        "--pretty=format:%H|||%an|||%aI|||%s",
        "--no-merges"
    ]
    
    if paths:
        cmd.append("--")
        cmd.extend(paths)
    
    try:
        result = subprocess.run(
            cmd,
            cwd=ROOT,
            capture_output=True,
            text=True,
            timeout=10,
            check=True
        )
    except subprocess.CalledProcessError as e:
        print(f"❌ ERROR: git log falló: {e}", file=sys.stderr)
        return []
    
    commits = []
    for line in result.stdout.strip().split('\n'):
        if not line:
            continue
        
        parts = line.split('|||')
        if len(parts) != 4:
            continue
        
        commit_hash, author, date_iso, subject = parts
        
        # Obtener archivos cambiados en este commit
        files_cmd = [
            "git", "diff-tree", "--no-commit-id", "--name-only", "-r", commit_hash
        ]
        try:
            files_result = subprocess.run(
                files_cmd,
                cwd=ROOT,
                capture_output=True,
                text=True,
                timeout=5,
                check=True
            )
            files = [f for f in files_result.stdout.strip().split('\n') if f]
        except subprocess.CalledProcessError:
            files = []
        
        commits.append({
            "hash": commit_hash,
            "hash_short": commit_hash[:8],
            "author": author,
            "date": date_iso,
            "message": subject,
            "files": files
        })
    
    return commits


def load_status() -> Dict:
    """Carga status.json si existe"""
    if not STATUS_JSON.exists():
        return {
            "docs_live_count": 0,
            "archive_count": 0,
            "last_ci_ref": "unknown"
        }
    
    try:
        with STATUS_JSON.open('r', encoding='utf-8') as f:
            return json.load(f)
    except json.JSONDecodeError:
        return {"docs_live_count": 0, "archive_count": 0}


def classify_commit(commit: Dict) -> str:
    """
    Clasifica commit por área temática
    
    Returns:
        Una de: "docs-live", "docs-archive", "tools", "ci", "other"
    """
    files = commit["files"]
    
    if any(f.startswith("docs/live/") for f in files):
        return "docs-live"
    elif any(f.startswith("docs/archive/") for f in files):
        return "docs-archive"
    elif any(f.startswith("tools/") or f.startswith("scripts/") for f in files):
        return "tools"
    elif any(f.startswith(".github/workflows/") for f in files):
        return "ci"
    else:
        return "other"


def generate_post(commit: Dict, status: Dict) -> str:
    """
    Genera contenido Markdown de post con frontmatter
    
    Args:
        commit: Diccionario con datos del commit
        status: Diccionario con status.json
    
    Returns:
        String con contenido completo del post
    """
    area = classify_commit(commit)
    date_obj = datetime.fromisoformat(commit["date"].replace('Z', '+00:00'))
    date_str = date_obj.strftime("%Y-%m-%d")
    
    # Emojis por área
    area_emojis = {
        "docs-live": "📝",
        "docs-archive": "🗄️",
        "tools": "🔧",
        "ci": "⚙️",
        "other": "🔄"
    }
    emoji = area_emojis.get(area, "🔄")
    
    # Título corto basado en mensaje de commit
    title_raw = commit["message"][:60]
    if len(commit["message"]) > 60:
        title_raw += "..."
    
    title = f"{emoji} {title_raw}"
    
    # Frontmatter
    frontmatter = f"""---
title: "{title}"
date: "{date_str}"
tags: ["automation", "docs", "status", "{area}"]
commit: "{commit['hash_short']}"
area: "{area}"
kpis:
  total_docs: {status.get('docs_live_count', 0) + status.get('archive_count', 0)}
  live_docs: {status.get('docs_live_count', 0)}
  archive_docs: {status.get('archive_count', 0)}
  stale_flagged: 0
  ci_checks: "green"
---
"""
    
    # Cuerpo del post
    body = f"""
# {title}

**Commit:** `{commit['hash_short']}`  
**Autor:** {commit['author']}  
**Fecha:** {date_obj.strftime("%Y-%m-%d %H:%M UTC")}

---

## 📋 Resumen

{commit['message']}

## 📂 Archivos Modificados

"""
    
    if commit['files']:
        for file in commit['files'][:10]:  # Máximo 10 archivos
            body += f"- `{file}`\n"
        
        if len(commit['files']) > 10:
            body += f"\n_(y {len(commit['files']) - 10} archivos más)_\n"
    else:
        body += "_No se detectaron archivos modificados_\n"
    
    body += f"""
---

## 📊 Estado Post-Update

| Métrica | Valor |
|---------|-------|
| **Documentos activos** | {status.get('docs_live_count', 0)} |
| **Documentos archivados** | {status.get('archive_count', 0)} |
| **Total documentos** | {status.get('docs_live_count', 0) + status.get('archive_count', 0)} |

---

## 🔗 Enlaces Relacionados

- [📁 Ver commit completo](https://github.com/ppkapiro/runart-foundry/commit/{commit['hash']})
- [📊 Estado operativo](/status/)
- [📚 Documentación activa](/docs/live/)

---

_Este post fue generado automáticamente por `tools/commits_to_posts.py`._
"""
    
    return frontmatter + body


def main():
    parser = argparse.ArgumentParser(description="Genera posts automáticos de commits recientes")
    parser.add_argument("--since-hours", type=int, default=24, help="Horas hacia atrás (default: 24)")
    parser.add_argument("--dry-run", action="store_true", help="Mostrar posts sin escribir archivos")
    args = parser.parse_args()
    
    print(f"🔍 Buscando commits de últimas {args.since_hours} horas...")
    
    # Filtrar solo commits de documentación
    paths = ["docs/live/", "docs/archive/", "docs/_meta/"]
    commits = get_git_commits(since_hours=args.since_hours, paths=paths)
    
    if not commits:
        print("ℹ️  No se encontraron commits recientes en docs/")
        return
    
    print(f"✅ Encontrados {len(commits)} commits")
    
    status = load_status()
    
    if args.dry_run:
        print("\n🔍 DRY RUN — Posts que se generarían:\n")
    
    generated = 0
    for commit in commits:
        date_obj = datetime.fromisoformat(commit["date"].replace('Z', '+00:00'))
        filename = f"{date_obj.strftime('%Y-%m-%d')}-auto-update-{commit['hash_short']}.md"
        output_path = NEWS_DIR / filename
        
        content = generate_post(commit, status)
        
        if args.dry_run:
            print(f"📄 {filename}")
            print(f"   Commit: {commit['hash_short']} — {commit['message'][:50]}")
            continue
        
        # Crear directorio si no existe
        NEWS_DIR.mkdir(parents=True, exist_ok=True)
        
        # No sobrescribir posts existentes
        if output_path.exists():
            print(f"⚠️  SKIP: {filename} (ya existe)")
            continue
        
        output_path.write_text(content, encoding='utf-8')
        print(f"✅ Generado: {filename}")
        generated += 1
    
    if not args.dry_run:
        print(f"\n🎉 Generados {generated} posts nuevos en {NEWS_DIR.relative_to(ROOT)}")
    else:
        print(f"\n🔍 DRY RUN completado — {len(commits)} posts potenciales")


if __name__ == "__main__":
    main()
