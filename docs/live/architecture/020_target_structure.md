---
status: active
owner: reinaldo.capiro
updated: 2025-10-23
audience: internal
tags: [briefing, runart, ops]
---

# Estructura Objetivo (Fase B)

## Árbol propuesto (alto nivel)

```
runart-foundry/
├── apps/
│   ├── briefing/
│   │   ├── README.md
│   │   ├── Makefile
│   │   ├── src/ (o docs/ para MkDocs)
│   │   ├── public/ (assets específicos)
│   │   └── contracts/ (inputs/outputs declarados)
│   └── <nueva-app>/
├── services/
│   ├── briefing-api/
│   │   ├── README.md
│   │   ├── Makefile
│   │   ├── src/ (Workers, handlers)
│   │   └── contracts/
│   └── <nuevo-servicio>/
├── packages/
│   ├── env-banner/
│   ├── ui-tokens/
│   └── utils-node/
├── tools/
│   ├── env_check/
│   ├── structure_guard/
│   └── audit-kit/
├── workflows/
│   ├── lint-build.yml
│   ├── preview.yml
│   └── release.yml
├── docs/
│   ├── architecture/
│   ├── operations/
│   └── playbooks/
└── shared/
    ├── assets/
    └── data/
```

### Justificación por carpeta

- **`apps/`**: agrupa todas las superficies consumidas por usuarios finales (MkDocs, SPA, dashboards). Cada app gestiona su build, assets y previews de forma aislada.
- **`services/`**: concentra APIs, Workers o funciones serverless. Evita mezclar lógica de backend dentro de las apps.
- **`packages/`**: librerías compartidas (estilos, componentes, SDKs). Permite versionar internamente sin depender de repos externos.
- **`tools/`**: scripts y CLIs de developer experience centralizados; se pueden distribuir via `pipx`/`npm link` si es necesario.
- **`workflows/`**: plantillas reusables de GitHub Actions (YAML o composite actions) compartidas por apps/services.
- **`docs/`**: conserva documentación transversal (arquitectura, operaciones, governance).
- **`shared/`**: activos comunes (assets globales, datasets) que no pertenecen a una app específica.

## Reglas por módulo

- **README obligatorio**: explica propósito, owners, requisitos, env vars y comandos.
- **Makefile por módulo**: expone al menos `build`, `serve (si aplica)`, `test`, `lint`, `preview`, `release` (según corresponda).
- **Contracts**: carpeta opcional (`contracts/` o `docs/contract.md`) detallando inputs/outputs, endpoints, artefactos generados y dependencias externas.
- **Tests**: ubicados en `tests/` o integrados según lenguaje; deben ser invocables vía `make test`.
- **Docs locales**: componentes que generen documentación adicional la colocan en `docs/` dentro del módulo y enlazan desde la documentación principal.

## Convenciones estructurales

- **Apps**: carpetas `kebab-case` (`briefing`, `admin-portal`).
- **Servicios**: `kebab-case` + sufijo opcional (`briefing-api`, `analytics-ingest`).
- **Packages**: `kebab-case` (compatible con npm/pip). Cada paquete contiene `package.json` o `pyproject.toml` según el stack.
- **Tools**: directorios `snake_case` para scripts multilenguaje (`env_check`, `audit_kit`).
- **Workflows**: archivos `.yml` descriptivos (`lint-build.yml`, `preview-pages.yml`).

## Artefactos esperados

| Carpeta | Artefactos |
|---------|------------|
| `apps/<app>` | Build estático (`site/`, `dist/`), reportes de pruebas, configuraciones de preview. |
| `services/<service>` | Bundles Workers (`.js`), definiciones de binding, pruebas unitarias y contract tests. |
| `packages/<pkg>` | Bundle publicable (npm/pip), documentación de uso, changelog. |
| `tools/<tool>` | CLI runnable (`python -m`, `node cli.mjs`), integraciones en CI. |
| `workflows/` | Reusable workflows/composite actions con documentación de inputs/outputs. |

## Interfaces entre módulos

- Apps consumen servicios vía HTTP (documentado en `contracts/` de cada servicio).
- Packages proveen componentes y estilos versionados (ej.: `env-banner` provee CSS/JS para apps).
- Tools operan sobre apps/services (ej.: `env_check` usa `contracts/env.json` para validar).
- Workflows invocan Make targets declarados en cada módulo.

Este blueprint será la referencia para los PRs posteriores: la Fase B moverá módulos gradualmente, manteniendo la compatibilidad con CI/CD existente.
