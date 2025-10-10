# Arquitectura del Monorepo — Estado Actual vs. Objetivo

## Contexto

El monorepo **runart-foundry** concentra los activos operativos del programa RUN Art:

- `apps/briefing/`: micrositio MkDocs privado (fuente canónica) que concentra decisiones, reportes y tableros.
- `briefing/`: capa de compatibilidad que mantiene rutas legacy y delega en `apps/briefing` mientras se actualizan CI/Pages.
- `apps/briefing/functions/`: Cloudflare Pages Functions (API REST mínima) que alimentan al micrositio (`/api/whoami`, `/api/log_event`, `/api/inbox`, etc.).
- `assets/`: repositorio histórico de materiales multimedia entregados a clientes.
- `scripts/`: automatizaciones ad-hoc (auditorías, generación de reportes, validaciones).
- `audits/`, `_reports/`, `mirror/`, `source/`: backups, volcados y reportes internos de auditoría/infraestructura.
- `.github/workflows/`: pipelines CI/CD específicos (build, deploy, PDFs, promoción de inbox).

El objetivo estratégico: evolucionar el monorepo hacia una plataforma modular que permita escalar nuevos sitios (apps), servicios y herramientas comunes, sin interrumpir las rutas actuales de preview ni el despliegue continuo en Cloudflare Pages.

## Estado Actual

### Estructura resumida

```
runart-foundry/
├── assets/                # Bibliotecas de medios (AÑOS/), ingestion manual.
├── audits/                # Logs de auditorías, dumps y checklists.
├── apps/
│   └── briefing/          # MkDocs + Pages Functions + scripts (fuente canónica).
│       ├── docs/          # Contenido Markdown.
│       ├── overrides/     # Plantillas y CSS personalizado.
│       ├── functions/     # Pages Functions (`api/`, `_middleware`...).
│       ├── scripts/       # Scripts específicos del micrositio (mark_internal, smoke tests...).
│       └── Makefile       # Build/serve/test locales (delegan en herramientas compartidas).
├── briefing/              # Wrappers (Makefile/mkdocs.yml) que delegan en `apps/briefing/`.
├── docs/                  # Documentación global ad-hoc (sin índice unificado).
├── scripts/               # Shell scripts operativos (auditorías, Lighthouse, etc.).
├── mirror/, _reports/, source/ # Espacios de staging / histórico.
└── .github/workflows/     # CI/CD orientado a briefing y utilidades puntuales.
```

### Flujos de build y deploy

- **MkDocs local:** `make serve` dentro de `apps/briefing/` (o `make serve MODULE=apps/briefing` desde la raíz) levanta MkDocs usando `.venv` local.
- **MkDocs build:** `make build` ejecuta `scripts/mark_internal.py` + `mkdocs build` dentro de `apps/briefing`.
- **Cloudflare Pages:** `ci.yml` y `briefing_deploy.yml` (hasta migración a workflows compartidos) construyen `apps/briefing/site` y despliegan vía Wrangler/Pages.
- **Workers:** viven en `apps/briefing/functions/` y se empaquetan junto al micrositio (pendiente separarlos a `services/` en fases futuras).
- **Scripts de validación:** `tools/check_env.py` (valida entornos local/preview/prod) y `apps/briefing/scripts/test_logs_*.mjs` (verifica Workers de logging).

### Dependencias principales

- Python 3.11/3.12 (venv local, actions/setup-python@v5).
- Node.js 20 (actions/setup-node@v4, scripts `.mjs`).
- MkDocs 1.6.1 + Material theme.
- Wrangler 3.x para deploy Workers/Pages.
- GitHub Actions + Cloudflare API tokens.

### Puntos frágiles identificados

- **Acoplamiento residual**: Workers, scripts y deploys siguen dentro de `apps/briefing`; separar APIs en `services/` continúa como prioridad.
- **Workflows duplicados** (`ci.yml` vs `briefing_deploy.yml` vs `promote_inbox*`): comparten setup similar sin reutilización.
- **Inventario difuso** (en mejoría): `docs/architecture` centraliza la nueva topología, pero falta declarar ownership formal por módulo.
- **Make targets en transición**: existe `Makefile` raíz delegando a módulos, pero solo `apps/briefing` implementa el set completo.
- **Preview sensibles**: la ruta `/api/*` todavía depende de Access y variables Pages; cualquier separación debe preservar env vars y bindings.

## Estado Objetivo

### Principios

1. **Modularidad explícita**: apps, servicios, paquetes y herramientas se organizan por dominios funcionales.
2. **Ownership declarado**: cada módulo define responsables, pipelines asociados y contratos de entrega.
3. **Previews resilientes**: toda reestructuración debe preservar el flujo actual de Cloudflare Pages/Workers.
4. **Automatización reusable**: Workflows y Make targets siguen convenciones comunes.
5. **Observabilidad**: métricas de build/test/reporting centralizadas para detectar regresiones.

### Límites propuestos por módulo

- `/apps/<app-name>`: front-ends, micrositios, UIs (p.ej. `apps/briefing`).
- `/services/<service-name>`: APIs/Workers independientes del front.
- `/packages/<package-name>`: librerías compartidas (estilos, utilidades, infra).
- `/tools/<tool-name>`: scripts CLI, validadores, generadores.
- `/docs/architecture`, `/docs/operations`: conocimiento transversal.

Cada módulo debe exponer contratos:

- **Entradas:** configuraciones, assets requeridos, variables de entorno.
- **Salidas:** artefactos (site build, bundle workers, reportes), logs, endpoints.
- **Interfaces compartidas:** p.ej. `packages/env-banner` usado por múltiples apps.

### Artefactos esperados

- Builds reproducibles (MkDocs, bundles de Workers).
- Pruebas (lint/test) automatizadas por módulo.
- Workflows compartidos para build/lint/preview/release.
- Documentación de módulo (README, contratos, checklists).

## Decisiones Arquitectónicas (ADR-lite)

| Id | Decisión | Razonamiento |
|----|----------|--------------|
| ADR-B1 | **Nombrado de módulos**: `apps/` y `services/` usan kebab-case (`briefing`, `admin-portal`). | Alinea con URL/path; favorece uniformidad en CI y Make targets. |
| ADR-B2 | **Convención de rutas**: assets compartidos en `/packages/<pkg>/assets`, referenciados vía imports relativos. | Evita duplicación en `apps/`. |
| ADR-B3 | **Workers** migran de `apps/briefing/functions/` a `services/briefing-api/`. | Permite desplegar APIs sin arrastrar MkDocs ni configuración de UI. |
| ADR-B4 | **Scripts de DX** migran a `/tools/` con nombres snake_case (`env_check`, `structure_guard`). | Facilita empaquetar y versionar herramientas. |
| ADR-B5 | **Documentación central** bajo `docs/architecture` y `docs/operations`; MkDocs toma esta carpeta como fuente global. | Proporciona índice único y reduce conocimiento tribal. |

## Métricas de Éxito

- **Tiempo de build**: mantener ≤ 3 min en CI para `apps/briefing` (actual ~2.5 min) pese a modularización.
- **Cobertura de lint/test**: cada módulo con al menos 1 job estándar (`lint` + `build`); sin workflows ad-hoc.
- **Reducción de duplicados**: workflows compartidos ≥ 70% reutilizan plantillas comunes.
- **Claridad de ownership**: todo módulo documenta responsables y outputs.
- **Trazabilidad**: ratio de PRs con checklist de migración cumplido (≥ 90%).

---

Este documento sirve como base de la Fase B: fija el punto de partida y el norte de la reorganización sin mover aún los artefactos de producción.
