---
status: active
owner: reinaldo.capiro
updated: 2025-10-23
audience: internal
tags: [briefing, runart, ops]
---

# Workflows de CI/CD Compartidos

## Inventario actual (2025-10-04)

| Workflow | Jobs principales | Observaciones |
|----------|------------------|---------------|
| `ci.yml` | `build`, `test-logs`, `deploy` | Duplica setup Python/Node; `deploy` usa Wrangler directo. |
| `briefing_deploy.yml` | `build-and-deploy` | Similar a `ci.yml` pero delega en `cloudflare/pages-action`. |
| `presskit_pdf.yml` | `build` | Compose pesado (pandoc, weasyprint); mezcla validación YAML + generación PDFs. |
| `promote_inbox.yml` | `promote` | Workflow manual con efectos en repo (commits). |
| `promote_inbox_preview.yml` | `promote-preview` | Variación del anterior con URL de preview. |
| `structure-guard.yml` | `validate-structure` | Ejecuta script shell; sin caching. |

Duplicidades: checkout + setup de runtimes repetidos; no existen workflows reusables/composite actions.

## Objetivo

Crear una familia de workflows compartidos ubicada en `/workflows/` (reusable via `workflow_call`) y, cuando convenga, composite actions en `.github/actions/`. Los workflows deben aceptar parámetros que definan el módulo objetivo, aseguren caches y expongan artefactos estándar.

## Plantillas propuestas

### 1. `workflows/lint-build.yml`

**Propósito:** Ejecutar linters y build para cualquier módulo (app/service/package).

```yaml
name: Reusable — Lint & Build
on:
  workflow_call:
    inputs:
      module-path:
        description: "Ruta del módulo (apps/briefing)"
        required: true
        type: string
      runtime:
        description: "python|node|mixed"
        required: false
        default: "python"
        type: string
      cache-key:
        description: "Clave extra para caché"
        required: false
        type: string
    secrets:
      CF_ACCOUNT_ID:
        required: false
    outputs:
      build-dir:
        description: "Directorio con artefactos"
        value: ${{ jobs.build.outputs.build-dir }}

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      build-dir: ${{ steps.build.outputs.dir }}
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        if: inputs.runtime != 'python'
        with:
          node-version: '20'
      - uses: actions/setup-python@v5
        if: inputs.runtime != 'node'
        with:
          python-version: '3.11'
      - name: Cache
        uses: actions/cache@v4
        with:
          key: lint-build-${{ runner.os }}-${{ inputs.module-path }}-${{ inputs.cache-key || 'default' }}
          path: |
            ${{ inputs.module-path }}/.venv
            ${{ inputs.module-path }}/node_modules
      - name: Install
        working-directory: ${{ inputs.module-path }}
        run: make install
      - name: Lint
        working-directory: ${{ inputs.module-path }}
        run: make lint
      - name: Build
        id: build
        working-directory: ${{ inputs.module-path }}
        run: |
          make build
          echo "dir=${PWD}/build" >> "$GITHUB_OUTPUT"
      - name: Upload artifacts
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: ${{ inputs.module-path }}-build
          path: ${{ steps.build.outputs.dir }}
```

### 2. `workflows/preview.yml`

**Propósito:** Publicar previews (Cloudflare Pages/Workers) desde PRs.

- Entradas: `module-path`, `preview-type (pages|workers)`, `wrangler-project`, `deploy-dir`.
- Pasos: reutilizar `lint-build.yml` como primer job (`uses: ./.github/workflows/lint-build.yml`). Luego, job `preview` que usa `cloudflare/pages-action@v1` (para Pages) o `wrangler deploy --env preview` (para Workers). Debe devolver URL (`outputs.preview-url`).

### 3. `workflows/release.yml`

**Propósito:** Deploy a producción en merge a `main` (o tags).

- Entradas: `module-path`, `release-type (pages|workers|package)`, `deploy-dir`, `npm-token`/`pypi-token` opcional.
- Reusa `lint-build.yml` como `needs` para asegurar build consistente.
- Outputs: `release-version`, `artifact-url`.

## Inputs y outputs estandarizados

| Workflow | Inputs obligatorios | Outputs |
|----------|--------------------|---------|
| `lint-build.yml` | `module-path` | `build-dir` |
| `preview.yml` | `module-path`, `preview-type`, `deploy-dir` | `preview-url` |
| `release.yml` | `module-path`, `release-type`, `deploy-dir` | `release-url` / `package-version` |

## Plan para converger

1. **Fase F1**: Crear directorio `/workflows/` con las plantillas anteriores + documentación en `docs/architecture`. No modificar workflows existentes.
2. **Fase F4 (ver 060_migration_plan)**: Migrar `ci.yml` para que consuma `lint-build.yml` (job build) y `release.yml` (deploy) preservando environment actual.
3. Posteriormente: mover lógica de PDFs a `tools/presskit-builder` + workflow específico que invoque `lint-build` + job custom.

## Buenas prácticas

- **Caching**: usar `actions/cache@v4` con claves separadas por módulo.
- **Secrets**: pasar como `secrets` en `workflow_call`, evitar `env:` global.
- **Artefactos**: siempre subir `build/` o `site/` para debugging.
- **Observabilidad**: incluir step final que publique métricas (tiempo de build, tamaño artefacto) en `audits/`.

Documentar estos workflows antes de implementarlos permite coordinar la migración sin interrumpir CI/CD.
