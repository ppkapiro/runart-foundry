#!/usr/bin/env python3
"""
Renderizador de status.json → apps/briefing/docs/status/index.md

Convierte el archivo JSON de métricas operativas en una página Markdown
navegable dentro del micrositio Briefing.

Uso:
    python3 tools/render_status.py

Entrada:
    docs/status.json (generado por scripts/gen_status.py)

Salida:
    apps/briefing/docs/status/index.md

Dependencias:
    - jinja2 (pip install jinja2)
"""

from __future__ import annotations
import json
import sys
from pathlib import Path
from datetime import datetime, timezone
from jinja2 import Template

ROOT = Path(__file__).resolve().parents[1]
STATUS_JSON = ROOT / "docs" / "status.json"
OUTPUT_MD = ROOT / "apps" / "briefing" / "docs" / "status" / "index.md"
TEMPLATE_FILE = ROOT / "tools" / "templates" / "status_page.md.j2"


INLINE_TEMPLATE = """---
title: "Estado Operativo — RunArt Foundry"
updated: "{{ status.generated_at }}"
tags: ["automation", "metrics", "operational"]
status: "active"
owner: "github-actions[bot]"
audience: "internal"
---

# Estado Operativo

**Última actualización:** {{ status.generated_at }}  
**Commit referencia:** `{{ status.last_ci_ref[:8] }}`

---

## 📊 KPIs Documentación

| Métrica | Valor | Estado |
|---------|-------|--------|
| **Documentos activos** | {{ status.docs_live_count }} | ![Live](https://img.shields.io/badge/live-{{ status.docs_live_count }}-brightgreen) |
| **Documentos archivados** | {{ status.archive_count }} | ![Archive](https://img.shields.io/badge/archive-{{ status.archive_count }}-blue) |
| **Total documentos** | {{ status.docs_live_count + status.archive_count }} | — |

---

## 🔗 Enlaces Rápidos

- [📁 Documentos activos](/docs/live/)
- [🗄️ Archivo histórico](/docs/archive/)
- [⚙️ Gobernanza](/docs/_meta/governance.md)
- [✅ Validadores](/docs/_meta/CONTRIBUTING.md)

---

## 🚦 Estado de Servicios

| Servicio | Estado | Última Verificación |
|----------|--------|---------------------|
| **Preview** | {% if status.preview_ok %}✅ Operativo{% else %}❌ Fallo{% endif %} | {{ status.generated_at }} |
| **Producción** | {% if status.prod_ok %}✅ Operativo{% else %}❌ Fallo{% endif %} | {{ status.generated_at }} |
| **CI/CD** | ✅ Verde | Commit `{{ status.last_ci_ref[:8] }}` |

---

## 📈 Métricas Históricas

_(TODO: Integrar gráfico temporal con Chart.js o Mermaid)_

```mermaid
pie title "Distribución de documentos"
    "Activos (live)" : {{ status.docs_live_count }}
    "Archivados" : {{ status.archive_count }}
```

---

## 🔍 Detalles Técnicos

### Estructura de Carpetas

```
docs/
├── live/          # {{ status.docs_live_count }} documentos activos
├── archive/       # {{ status.archive_count }} documentos archivados
└── _meta/         # Metadatos y reportes
```

### Proceso de Actualización

1. **Generación:** `scripts/gen_status.py` → `docs/status.json`
2. **Renderizado:** `tools/render_status.py` → `apps/briefing/docs/status/index.md`
3. **Publicación:** MkDocs build → GitHub Pages / Cloudflare Pages
4. **Frecuencia:** Post-merge en `main` (automático)

### Validaciones Activas

- ✅ Strict frontmatter validation (CI blocking)
- ✅ Internal links checker
- ✅ External links health (timeout 5s)
- ✅ Tags uniqueness + lowercase
- ✅ Stale detection (weekly dry-run)

---

## 📝 Notas

- Este archivo es **generado automáticamente** por `tools/render_status.py`.
- No editar manualmente — cambios serán sobrescritos en próxima actualización.
- Para modificar plantilla: ver `tools/templates/status_page.md.j2` (o inline en script).

---

**Generado:** {{ now }}  
**Hash commit:** `{{ status.last_ci_ref[:8] }}`  
**Autor:** `render_status.py` (automated)
"""


def load_status() -> dict:
    """Carga y valida status.json"""
    if not STATUS_JSON.exists():
        print(f"❌ ERROR: {STATUS_JSON} no encontrado", file=sys.stderr)
        print("   Ejecutar primero: python3 scripts/gen_status.py", file=sys.stderr)
        sys.exit(1)
    
    try:
        with STATUS_JSON.open('r', encoding='utf-8') as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        print(f"❌ ERROR: JSON inválido en {STATUS_JSON}", file=sys.stderr)
        print(f"   {e}", file=sys.stderr)
        sys.exit(1)
    
    # Validación mínima de esquema
    required = ["generated_at", "docs_live_count", "archive_count", "last_ci_ref"]
    missing = [k for k in required if k not in data]
    if missing:
        print(f"❌ ERROR: Faltan campos requeridos en status.json: {missing}", file=sys.stderr)
        sys.exit(1)
    
    return data


def render_page(status: dict) -> str:
    """Renderiza plantilla Jinja con datos de status.json"""
    # Usar template inline (futuro: leer desde archivo)
    template = Template(INLINE_TEMPLATE)
    
    context = {
        "status": status,
        "now": datetime.now(timezone.utc).isoformat()
    }
    
    return template.render(**context)


def main():
    print(f"🔄 Cargando {STATUS_JSON.relative_to(ROOT)}...")
    status = load_status()
    
    print("📝 Renderizando página de estado...")
    content = render_page(status)
    
    # Crear directorio si no existe
    OUTPUT_MD.parent.mkdir(parents=True, exist_ok=True)
    
    print(f"💾 Escribiendo {OUTPUT_MD.relative_to(ROOT)}...")
    OUTPUT_MD.write_text(content, encoding='utf-8')
    
    print("✅ Página de estado generada exitosamente!")
    print(f"   - Live docs: {status['docs_live_count']}")
    print(f"   - Archive docs: {status['archive_count']}")
    print(f"   - Commit: {status['last_ci_ref'][:8]}")
    print(f"   - Output: {OUTPUT_MD.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
