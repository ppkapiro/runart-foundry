---
status: active
owner: reinaldo.capiro
updated: 2025-10-23
audience: internal
tags: [briefing, runart, ops]
---

# Inventario del Monorepo (Iteración 1)

## Árbol actual (profundidad 2)

```
runart-foundry/
├── assets/            # Biblioteca histórica de media entregada a clientes (por año)
│   ├── 2015/ … 2024/  # Cada carpeta agrupa sesiones/proyectos; sin build automatizado.
│   └── _incoming/     # Depósito temporal antes de clasificar.
├── audits/            # Inspecciones de infraestructura (dumps, logs, scripts para QA)
│   ├── _structure/    # Árboles de archivos, sitemaps, CSV con métricas.
│   ├── axe/, lighthouse/, security/, seo/ # Resultados de herramientas automáticas.
│   └── scripts/       # Scripts de auditoría ejecutados en CI/manual.
├── apps/              # Aplicaciones completas (MkDocs, paneles, front-ends).
│   └── briefing/      # Micrositio MkDocs + Workers (fuente canónica).
├── briefing/          # Capa de compatibilidad que delega en `apps/briefing`.
├── services/          # APIs/Workers desacoplados (placeholder Fase B).
├── packages/          # Librerías compartidas (CSS, JS, tokens, etc.).
├── docs/              # Documentación transversal (proyectos, runbook, arquitectura)
│   ├── projects/      # Catálogo YAML de proyectos.
│   ├── run/, uldis/   # Reportes específicos del programa.
│   └── architecture/  # *Nuevo* directorio (Fase B) con lineamientos.
├── mirror/            # Exportaciones completas (raw/normalized) del sitio legado.
├── reports/           # Reportes analíticos y documentación ejecutiva.
├── scripts/           # Shell scripts generales (auditorías, despliegues auxiliares).
├── tools/             # Scripts CLI compartidos (lint_docs.py, check_env.py, ...).
├── _reports/, source/ # Backups de documentos históricos y fuentes originales.
└── .github/workflows/ # Pipelines CI/CD actuales.
```

## Tabla de módulos principales

| Módulo | Propietarios referenciales | Pipelines asociados | Artefactos de salida |
|--------|----------------------------|---------------------|----------------------|
| `apps/briefing` | Equipo ARQ / Producto | `ci.yml`, `briefing_deploy.yml` (gatillan por cambios en `briefing/**` y `apps/briefing/**`), `presskit_pdf.yml` | `apps/briefing/site` (build MkDocs), PDFs en `_reports/`, bundles Workers `apps/briefing/functions/api/*` |
| `briefing` (compat) | Equipo ARQ / Producto | `ci.yml`, `briefing_deploy.yml` | Makefile y `mkdocs.yml` delegados que apuntan a `apps/briefing`; sin artefactos propios (solo wrappers) |
| `tools` | DX / Operaciones | `structure-guard.yml`, `make lint-docs` (raíz) | CLIs Python (`tools/check_env.py`, `tools/lint_docs.py`), reportes en `audits/` |
| `audits` | QA / Gobernanza | `structure-guard.yml`, ejecuciones manuales | Logs `.txt`, `.csv`, `*_check.log` |
| `docs` (global) | Arquitectura / Operaciones | `presskit_pdf.yml`, `make lint-docs` | Documentación transversal, catálogos YAML y PDFs derivados |
| `assets` | Contenido / Studio | — (sin CI) | Biblioteca histórica de media |
| `mirror` | Archivo / Gobernanza | — (sin CI) | Snapshots `raw/` y `normalized/` del sitio legado |
| `scripts` (raíz) | DX / Operaciones | `structure-guard.yml` | Shell utilities (`validate_structure.sh`, auditorías, despliegues auxiliares) |
| `.github/workflows` | DevOps | Todos los workflows enumerados | Automatizaciones CI/CD |

> *Nota*: Ownership formal se documentará en `020_target_structure.md`; esta tabla refleja responsables de facto tras la modularización.

## Workflows de GitHub Actions

| Workflow | Trigger principal | Propósito |
|----------|-------------------|-----------|
| `ci.yml` | PR y push a `main` tocando `briefing/**` | Build MkDocs, ejecutar scripts de logs, preparar deploy Wrangler (solo en `main`). |
| `briefing_deploy.yml` | PR y push a `main` (briefing) | Pipeline alterno para build MkDocs y deploy a Cloudflare Pages vía `cloudflare/pages-action`. |
| `presskit_pdf.yml` | Push a contenido de proyectos/presskit, `workflow_dispatch` | Genera PDFs (ES/EN) a partir de Markdown/YAML, sube artefactos y copia a `briefing/site/presskit`. |
| `promote_inbox.yml` | `workflow_dispatch` manual | Convierte entradas del inbox (`/api/inbox`) en YAML, actualiza `mkdocs.yml` y bitácoras. |
| `promote_inbox_preview.yml` | `workflow_dispatch` manual | Variante que usa la URL de preview (Pages) para promover fichas en entorno preliminar. |
| `structure-guard.yml` | PR y push a `main` | Ejecuta `scripts/validate_structure.sh` para proteger convención de carpetas y gobierno. |

## Scripts y Make targets existentes

### `Makefile` (raíz)

| Target | Descripción |
|--------|-------------|
| `build`, `serve`, `test`, `lint`, `clean` | Delegan al módulo indicado vía `MODULE=<ruta>` (por defecto `apps/briefing`). `ALL=1` itera sobre todos los módulos listados en `APPS`. |
| `lint-docs` | Ejecuta `tools/lint_docs.py` para validar MkDocs (usa `mkdocs build --strict`). |
| `preview` | Placeholder controlado: documenta el switch de Cloudflare Pages (sin despliegue directo). |
| `status` | Imprime el resumen ejecutivo desde `STATUS.md` (auditoría operacional). |

### `apps/briefing/Makefile`

| Target | Descripción |
|--------|-------------|
| `venv` | Crea entorno virtual local (`.venv`) y instala dependencias de `requirements.txt`. |
| `build` | Corre `scripts/mark_internal.py` y `mkdocs build` sobre la fuente canónica. |
| `serve` | Igual que `build`, pero lanza `mkdocs serve` (preview local). |
| `lint` | Alias que agrupa `lint-app` (placeholder) y `lint-docs` (vía Makefile raíz). |
| `test` | Alias de `test-env` (validaciones de entorno con `tools/check_env.py`). |
| `test-env`, `test-env-preview`, `test-env-prod` | Ejecutan `tools/check_env.py` contra `local`, `preview` y `prod` respectivamente. |
| `test-logs`, `test-logs-strict` | Scripts Node que validan eventos enviados por Workers. |
| `preview` | Placeholder documentado en `docs/architecture/065_switch_pages.md` (no despliega aún). |

### `apps/briefing/scripts/`

- `mark_internal.py`: verifica clases `.interno` y genera mapa de accesos (previo a build).
- `promote_inbox_to_yaml.py`, `generate_preview_from_inbox.py`: pipelines de contenido.
- `qa_arq6.sh`, `corte_control_fase2.py`: rutinas específicas de auditoría ARQ.
- `smoke_arq3.sh`, `smoke_exports.sh`: smoke tests posteriores a despliegue.
- Scripts JS (`test_logs*.mjs`) y Python (`validate_projects.py`) para validar Workers y contenido.

### `tools/`

- `check_env.py`: validador de banderas de entorno y conectividad, ahora compartido.
- `lint_docs.py`: ejecuta `mkdocs --strict`, revisa encabezados y espacios finales.
- (Pendiente) otros utilitarios por modularizar desde `scripts/`.

### `scripts/` (raíz)

- `validate_structure.sh`, `escaneo_estructura_completa.sh`, `fase3_auditoria*.sh`, `generar_informes_maestros.sh`: auditorías y controles de gobernanza.
- `setup_ssh_and_push.sh`, `test_lighthouse.sh`, `test_whoami.mjs`: soporte de despliegue y pruebas externas.

### Otros

- `.tools/`: cache de dependencias locales (node_modules) para scripts específicos.
- `.githooks/`: hooks personalizados (pre-commit, commit-msg).

## Observaciones clave

- `apps/briefing` es la fuente canónica; `briefing/` funciona como capa de compatibilidad para no romper pipelines ni Pages hasta ejecutar el plan de switch.
- El `Makefile` raíz ya delega targets estándar y centraliza `lint-docs`; falta propagar la convención al resto de módulos cuando se creen.
- `tools/check_env.py` y `tools/lint_docs.py` se convirtieron en utilidades compartidas; scripts de MkDocs que antes vivían en `briefing/scripts/` deben migrar gradualmente a `tools/` o `packages/`.
- Los workflows aún dependen de los paths legacy; será necesario actualizar triggers y rutas una vez se publique `docs/architecture/065_switch_pages.md` y se ejecute el corte.
- Directorios `services/` y `packages/` permanecen como placeholders Fase B; deberán incorporar README/Makefile en cuanto reciban módulos reales.

Este inventario sirve como punto de partida para migrar cada componente a la estructura objetivo propuesta en 020.
